import os
import datetime
import traceback
import sys
import uuid
import time
import subprocess
import paramiko

ip = '216.58.153.146'
username = 'viktor'
password = 'a1441262' #os.environ.get('SERVER_PASSWORD', '')

IMAGE_PATH = '../images/1.jpg'
TEMP_PATH = '../images/temp.txt'
TO_PATH = '/storage/pi/{}'.format(hex(uuid.getnode()))
IMG_NAME = '1.jpg'
TEMP_NAME = 'temp.txt'
CONVERT_SCRIPT = './convert.sh'

ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

while True:
    try:
        ssh_client.connect(hostname=ip, username=username, password=password)
    except:
        traceback.print_exc()
        time.sleep(5)
        continue
    print('connected')
    with ssh_client.open_sftp() as sftp_client:
        (stdin, stdout, stderr) = ssh_client.exec_command('mkdir -p {}'.format(TO_PATH))
        if stderr.read():
            print('Cannot create dir ', TO_PATH)
            sys.exit(1)
        while True:
            subprocess.call(CONVERT_SCRIPT, shell=True)
            sftp_client.put(IMAGE_PATH, os.path.join(TO_PATH, IMG_NAME))
            sftp_client.put(TEMP_PATH, os.path.join(TO_PATH, TEMP_NAME))
            print(datetime.datetime.now())
            time.sleep(0.1)

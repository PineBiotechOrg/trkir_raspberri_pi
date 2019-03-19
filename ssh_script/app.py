import os
import sys
import uuid
import time
import paramiko

ip = '216.58.153.146'
username = 'viktor'
password = os.environ.get('SERVER_PASSWORD', '')

IMAGE_PATH = '../images/1.jpg'
TEMP_PATH = '../images/temp.txt'
TO_PATH = '/storage/pi/{}'.format(hex(uuid.getnode()))
IMG_NAME = '1.jpg'

ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

while True:
    try:
        ssh_client.connect(hostname=ip, username=username, password=password)
    except:
        time.sleep(5)
        continue

    with ssh_client.open_sftp() as sftp_client:
        (stdin, stdout, stderr) = sftp_client.exec_command('mkdir -p {}'.format(TO_PATH))
        if stderr.read():
            print('Cannot create dir ', TO_PATH)
            sys.exit(1)
        while True:
            sftp_client.put(IMAGE_PATH, os.path.join(TO_PATH, IMG_NAME))
            time.sleep(0.2)

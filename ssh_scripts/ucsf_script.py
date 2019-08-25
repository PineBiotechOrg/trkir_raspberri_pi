from PIL import Image
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
password = 'lalala'#os.environ.get('SERVER_PASSWORD', '')

HERE_PATH = '../images/2.jpg'
IMAGE_PATH = '../images/1.jpg'
TEMP_PATH = '../images/temp.txt'
TO_PATH = '/storage/pi/{}'.format('0x802bf985e3c4') #hex(uuid.getnode()))
IMG_NAME = '1.jpg'
TEMP_NAME = 'temp.txt'
CONVERT_SCRIPT = './convert.sh'

ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

while True:
    try:
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
                try:
                    im = Image.open(HERE_PATH)
          #          im = im.crop((50, 240, 360, 470))
          #          im.thumbnail((160, 120))
                    im.save(IMAGE_PATH)
                except:
                    continue
                sftp_client.put(IMAGE_PATH, TO_PATH + '/' + IMG_NAME)
                sftp_client.put(TEMP_PATH, TO_PATH + '/' + TEMP_NAME)
           #     print(datetime.datetime.now())
    except:
        traceback.print_exc()
        time.sleep(5)
        continue

import time
from datetime import datetime

import psutil

import json
# Import smtplib for the actual sending function
import smtplib

from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


def send_email(data, sending_ts):
    msg = MIMEMultipart()

    sub = "UCSF PC data from %s" % sending_ts.strftime('%Y-%m-%d %H:%M:%S')
    msg['From'] = 'victor@pine.bio'
    msg['To'] = 'mousetracker@outlook.com'
    msg['Subject'] = sub

    msg.attach(MIMEText(data, 'plain'))

    # create server
    s = smtplib.SMTP('smtp.gmail.com: 587')

    s.starttls()

    # Login Credentials for sending the mail
    s.login(msg['From'], 'Novosad1441262')

    s.send_message(msg)
    s.quit()
    return 0


while True:
    sending_ts = datetime.now()
    cpu = psutil.cpu_percent()
    memory_percent = psutil.virtual_memory()[2]
    avg_load = psutil.getloadavg()
    send_email("""Date: {date}\n\n%CPU: {cpu}%,\n\n%MEM: {memory_percent}%,\n\nAvg.Load: {av1}, {av5}, {av15},\n\nAvg.Load Description:
    Return the average system load over the last 1, 5 and 15 minutes as a tuple.
    The load represents how many processes are waiting to be run by the operating system.
    On Windows this is emulated by using a Windows API that spawns a thread which updates the average every 5 seconds, mimicking the UNIX behavior.
    Thus, the first time this is called and for the next 5 seconds it will return a meaningless"""
               .format(date=sending_ts.strftime('%Y-%m-%d %H:%M:%S'),
                       cpu=cpu,
                       memory_percent=memory_percent,
                       av1=round(avg_load[0], 2), av5=round(avg_load[1], 2), av15=round(avg_load[2], 2),
               ), sending_ts)

    print('sended')
    time.sleep(60 * 60)

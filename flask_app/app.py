import subprocess
from flask import Flask, send_from_directory

SCRIPT_NAME = '../viewer/lepton3'
IMG_PATH = './'
IMG_NAME = '1.png'

app = Flask(__name__)


@app.route('/get_image', methods=['GET'])
def get_image():
    p = subprocess.Popen([SCRIPT_NAME])
    p.wait()

    return send_from_directory(IMG_PATH, IMG_NAME)


if __name__ == '__main__':
    app.run(host='0.0.0.0')

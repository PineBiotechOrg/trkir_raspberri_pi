from PIL import Image
import datetime
import shutil
import time
import sys

IMG_NAME = '1.jpg'
TEMP_NAME = 'temp.txt'
CORE_PATH = '/storage/pi/'


def cut_image(mac_address):
    img_path = CORE_PATH + '{}/{}'.format(mac_address, IMG_NAME)
    temp_path = CORE_PATH + '{}/{}'.format(mac_address, TEMP_NAME)
    save_path = CORE_PATH + '{}/' + '{}'.format(IMG_NAME)
    temp_save_path = CORE_PATH + '{}/'

    while True:
        try:
            im = Image.open(img_path)

            j = 0
            for i in range(4):
                if i == 2:
                    j = 1
                cur_img = im.crop((320 * (i % 2), 240 * j, 320 * ((i % 2) + 1), 240 * (j + 1)))
                cur_img.thumbnail((160, 120))
                cur_img.save(save_path.format(mac_address + '_' + str(i)))
                shutil.copy(temp_path, temp_save_path.format(mac_address + '_' + str(i)))
        except:
            time.sleep(0.15)
            continue
        time.sleep(0.15)
        print(datetime.datetime.now())


if __name__ == '__main__':
    cut_image(sys.argv[1])
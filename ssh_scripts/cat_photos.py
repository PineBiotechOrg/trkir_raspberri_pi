from PIL import Image
import datetime
import time
import traceback

IMG_NAME = '1.jpg'
CORE_PATH = '/storage/pi/'


def cut_image(mac_address):
    img_path = CORE_PATH + '{}/{}'.format(mac_address, IMG_NAME)
    save_path = CORE_PATH + '{}/' + '{}'.format(IMG_NAME)

    while True:
        try:
            im = Image.open(img_path)

            j = 0
            for i in range(4):
                if i == 2:
                    j = 1
                cur_img = im.crop((320 * i, 240 * j, 320 * (i + 1), 240 * (j + 1)))
                cur_img.thumbnail((160, 120))
                cur_img.save(save_path.format(mac_address + '_' + str(i)))
        except:
            traceback.print_exc()
            continue
        time.sleep(0.1)
        print(datetime.datetime.now())
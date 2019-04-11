#include "LeptonThread.h"
#include "Palettes.h"
#include "SPI.h"
#include "Lepton_I2C.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string>

static const char *device = "/dev/spidev0.0";
uint8_t mode;
static uint8_t bits = 8;
static uint32_t speed = 32000000;
int selectedColorMap = 0;

int snapshotCount = 0;
int frame = 0;
static int raw [120][160];
static void pabort(const char *s)
{
	perror(s);
	abort();
}

const int* getColorMap() 
{
	if  ( selectedColorMap == 0) 
		return colormap_rainbow;
	if  ( selectedColorMap == 1) 
		return colormap_grayscale;
	if  ( selectedColorMap == 2) 
		return colormap_ironblack;
	if  ( selectedColorMap == 3) 
		return colormap_blackHot;
	if  ( selectedColorMap == 4) 
		return colormap_arctic;
	if  ( selectedColorMap == 5) 
		return colormap_blueRed;
	if  ( selectedColorMap == 6) 
		return colormap_coldest;
	if  ( selectedColorMap == 7) 
		return colormap_contrast;
	if  ( selectedColorMap == 8) 
		return colormap_doubleRainbow;
	if  ( selectedColorMap == 9) 
		return colormap_grayRed;
	if  ( selectedColorMap == 10) 
		return colormap_grayRed;
	if  ( selectedColorMap == 11) 
		return colormap_glowBow;

}

LeptonThread::LeptonThread() : QThread()
{
SpiOpenPort(0);
}

LeptonThread::~LeptonThread() {
}

void LeptonThread::run()
{
	int ret = 0;
	int fd;

	fd = open(device, O_RDWR);
	if (fd < 0)
	{
		pabort("can't open device");
	}

	ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
	if (ret == -1)
	{
		pabort("can't set spi mode");
	}

	ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
	if (ret == -1)
	{
		pabort("can't get spi mode");
	}

	ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
	if (ret == -1)
	{
		pabort("can't set bits per word");
	}

	ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
	if (ret == -1)
	{
		pabort("can't get bits per word");
	}

	ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
	if (ret == -1)
	{
		pabort("can't set max speed hz");
	}

	ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
	if (ret == -1)
	{
		pabort("can't get max speed hz");
	}

    while (true) {
        int resets = 0;
        int segmentNumber = 0;
        for(int i = 0; i < NUMBER_OF_SEGMENTS; i++){
            for(int j=0;j<PACKETS_PER_SEGMENT;j++) {
//                printf("%d", i);
                //read data packets from lepton over SPI
                read(spi_cs0_fd, result+sizeof(uint8_t)*PACKET_SIZE*(i*PACKETS_PER_SEGMENT+j), sizeof(uint8_t)*PACKET_SIZE);
                int packetNumber = result[((i*PACKETS_PER_SEGMENT+j)*PACKET_SIZE)+1];
                //if it's a drop packet, reset j to 0, set to -1 so he'll be at 0 again loop
                if(packetNumber != j) {
                    j = -1;
                    resets += 1;
                    if (resets == 500) {
                        SpiClosePort(0);
                        printf("\nrestarting spi...\n");
                        usleep(3000000);
                        SpiOpenPort(0);
                    }
                    usleep(1000);
                    continue;
                } else
                if(packetNumber == 20) {

                    segmentNumber = result[(i*PACKETS_PER_SEGMENT+j)*PACKET_SIZE] >> 4;
                        if(segmentNumber != (i+1)%4){
                            j = -1;
                            resets += 1;
                            usleep(1000);
                        }
                }
            }
        }

        frameBuffer = (uint16_t *)result;
        int row, column;
        uint16_t value;
        uint16_t minValue = 65535;
        uint16_t maxValue = 0;


        for(int i=0;i<FRAME_SIZE_UINT16;i++) {
            //skip the first 2 uint16_t's of every packet, they're 4 header bytes
            if(i % PACKET_SIZE_UINT16 < 2) {
                continue;
            }

            //flip the MSB and LSB at the last second
            int temp = result[i*2];
            result[i*2] = result[i*2+1];
            result[i*2+1] = temp;

            value = frameBuffer[i];
            if(value> maxValue) {
                maxValue = value;
            }
            if(value < minValue) {
                if(value != 0)
                    minValue = value;
            }
        }
        float temp = raw2Celsius(maxValue);

        float diff = maxValue - minValue;
        float scale = 255/diff;

        for(int k=0; k<FRAME_SIZE_UINT16; k++) {
            if(k % PACKET_SIZE_UINT16 < 2) {
                continue;
            }

            value = (frameBuffer[k] - minValue) * scale;

            if((k/PACKET_SIZE_UINT16) % 2 == 0){
                column = (k % PACKET_SIZE_UINT16 - 2);
                row = (k / PACKET_SIZE_UINT16)/2;
            }
            else{
                column = ((k % PACKET_SIZE_UINT16 - 2))+(PACKET_SIZE_UINT16-2);
                row = (k / PACKET_SIZE_UINT16)/2;
            }
            raw[row][column] = value;
        }

        snapshot(temp);
	    usleep(200000);
    }

    SpiClosePort(0);
}


void LeptonThread::snapshot(float temp){
	const char *name = "/home/pi/raspberry_pi/images/1.png";
    int width = 160;
    int height = 120;

    FILE* pgmimg;
    pgmimg = fopen(name, "wb");

    // Writing Magic Number to the File
    fprintf(pgmimg, "P2\n");

    // Writing Width and Height
    fprintf(pgmimg, "%d %d\n", width, height);

    // Writing the maximum gray value
    fprintf(pgmimg, "255\n");
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {

            // Writing the gray values in the 2D array to the file
            fprintf(pgmimg, "%d ", raw[i][j]);
        }
        fprintf(pgmimg, "\n");
    }

    fclose(pgmimg);

    FILE* temp_file;
    temp_file = fopen("/home/pi/raspberry_pi/images/temp.txt", "wb");

    fprintf(temp_file, "%f", temp);

    fclose(temp_file);
}

void LeptonThread::performFFC() {
	//perform FFC
	lepton_perform_ffc();
}

void LeptonThread::restart() {
	lepton_restart();
}

void LeptonThread::disable_agc() {
	lepton_disable_agc();
}

void LeptonThread::enable_agc() {
	lepton_enable_agc();
}

void LeptonThread::setColorMap(int index) {
	selectedColorMap = index;
}

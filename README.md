Lepton 3.5 viewer

Install the 'qt4-dev-tools' package, which allows compiling of QT applications.
$ sudo apt-get install qt4-dev-tools

To build (will build any SDK dependencies as well):
$ cd viewer
$ qmake && make

To clean:
$ make sdkclean && make distclean

To start image saving:
$ ./start_script.sh &

To start download image to server:
$ cd .. (you should be at project root directory now (lepton_raspberry_pi/)
$ pip3 install -r requirements.txt
$ cd ssh_scripts
$ python3 app.py &

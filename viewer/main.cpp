#include <QApplication>
#include <QThread>
#include <QMutex>
#include <QMessageBox>

#include <QColor>
#include <QLabel>
#include <QtDebug>
#include <QString>
#include <QPushButton>
#include <QComboBox>

#include <unistd.h>
#include "LeptonThread.h"
#include "MyLabel.h"


int main( int argc, char **argv ) {
	LeptonThread *thread = new LeptonThread();

	while (true) {
		usleep(1000000);
		thread->run();
		usleep(1000 * 1000 * 60);
		thread->restart();
	}

	return 0;
}


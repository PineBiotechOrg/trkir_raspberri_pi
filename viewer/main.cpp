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

	thread->restart();
	usleep(2000000);
	thread->run();

	return 0;
}


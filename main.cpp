#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QmlCppBridge.h>
#include <QThread>
int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN) && QT_VERSION_CHECK(5, 6, 0) <= QT_VERSION && QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    qmlRegisterType<QmlCppBridge>("com.company.bridge", 1, 0, "QmlCppBridge");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("./main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

	QObject* rootObject = engine.rootObjects().first();
	QmlCppBridge* bridge = rootObject->findChild<QmlCppBridge*>("bridge");

	if (bridge) {
		QThread* workerThread = new QThread;
		bridge->moveToThread(workerThread);

		QObject::connect(workerThread, &QThread::finished, bridge, &QObject::deleteLater);
		workerThread->start();
	}

    return app.exec();
}

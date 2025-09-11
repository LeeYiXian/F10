#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QmlCppBridge.h>
#include <QThread>
#include <QIcon>
int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN) && QT_VERSION_CHECK(5, 6, 0) <= QT_VERSION && QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
	// 设置全局窗口图标
	app.setWindowIcon(QIcon(":/qt/qml/f10system/image/app.png"));

	qmlRegisterType<QmlCppBridge>("com.company.bridge", 1, 0, "QmlCppBridge");
	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("./main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;
    return app.exec();
}

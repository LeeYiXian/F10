#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "QmlCppBridge.h"
#include <QThread>
#include <QIcon>

//新增
#include "qxtglobalshortcut.h"   // 引入头文件
#include <QObject>
#include <QScreen>

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

	//新增
	QxtGlobalShortcut* sc = new QxtGlobalShortcut(QKeySequence("Ctrl+Alt+T"), &app);
	QObject::connect(sc, &QxtGlobalShortcut::activated, []() {
		QScreen* screen = QGuiApplication::primaryScreen();
		if (screen) {
			QPixmap pixmap = screen->grabWindow(0); // 0 = 全屏
			QString path = QString("screenshot/screenshot_%1.png")
				.arg(QDateTime::currentMSecsSinceEpoch());  // 毫秒级时间戳
			pixmap.save(path);
		}
	});

    return app.exec();
}

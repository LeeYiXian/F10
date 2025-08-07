#include "QmlCppBridge.h"
#include <QDebug>
#include <QCryptographicHash>
#include <QDateTime>
#include <QThread>

QmlCppBridge::QmlCppBridge(QObject * parent)
    : QObject(parent) 
{
    m_networkManager = new NetworkManager();
    m_serialPort = new SerialPort();



}

void QmlCppBridge::sendtoCpp(const QVariant& data)
{
    if (!data.canConvert<QVariantMap>())
    {
        qDebug() << "Invalid data type";
        return;
    }

	QVariantMap map = data.toMap();
	QString method = map["method"].toString();

	method.remove(QChar(0x200C));  // 显式移除零宽非连接符

    if (method == "switchmechanism.open")
    {
        
    }
    else if (method == "switchmechanism.close")
    {

    }
    else if (method == "switchmechanism.findzero")
    {

    }
    else if (method == "filterwheel.setgear‌")
    {
        //取出挡位值
        int index = map["value"].toInt();


    }
    else if (method == "waveplate.open")
    {

    }
    else if (method == "waveplate.close")
    {
    }
    else if (method == "waveplate.findzero")
    {


    }
}

void QmlCppBridge::onReceivedMsg(const QVariant& params)
{
    // 仅做基础类型检查后直接转发
    if (params.canConvert<QVariantMap>()) {
        emit sendtoQml(params); // 直接传递原始 QVariant
    }
}

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

void QmlCppBridge::sendtoCpp(const QVariant& data) {

    

    //滤光轮控制
    if (data.toString() == "switchmechanism.open‌")
    {
        //

    }
    else if (data.toString() == "switchmechanism.close‌")
    {

    }
    else if (data.toString() == "switchmechanism.findzero‌")
    {

    }

	else if (data.toString() == "shakingtable.open‌")
	{
        QVariantMap map = data.toMap();

        int chl = map["chl"].toInt();
        int wave = map["wave"].toInt();
        int peak = map["peak"].toInt();
        int fre = map["fre"].toInt();
        int offset = map["offset"].toInt();

        QByteArray data;
        //组装数据


        m_serialPort->sendData(data);
	}

    else if (data.toString() == "shakingtable.close‌")
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

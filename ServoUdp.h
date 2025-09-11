#pragma once
#include <QObject>
#include <QThread>
#include <QHostAddress>
#include <QByteArray>

class ServoUdpWorker; // 前置声明

class ServoUdp : public QObject
{
    Q_OBJECT
public:
    // 构造时即创建线程与socket并绑定本地端口
    // 若 remoteAddr/remotePort 固定，可直接传入；也可以后续 setRemote() 再设
    explicit ServoUdp(quint16 localPort,
                      const QHostAddress& remoteAddr = QHostAddress::Null,
                      quint16 remotePort = 0,
                      QObject* parent = nullptr);

    ~ServoUdp() override;

    // 发送到构造/设置的默认远端
    Q_INVOKABLE void send(const QByteArray& data);

    // 重绑定本地端口（会在工作线程里执行）
    Q_INVOKABLE void rebind(quint16 localPort);

    // 改变默认远端地址与端口（工作线程里保存并使用）
    Q_INVOKABLE void setRemote(const QHostAddress& addr, quint16 port);

signals:
    // 收到任意数据报时发出
    void received(const QByteArray& data, const QHostAddress& from, quint16 port);
    // 发送完成（返回 writeDatagram 的字节数）
    void sent(qint64 bytes);
    // 绑定成功
    void bound(quint16 localPort);
    // 发生错误（绑定/收发等）
    void errorOccurred(const QString& message);

private:
    QThread m_thread;
    ServoUdpWorker* m_worker = nullptr;
};

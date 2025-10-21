#pragma once
#include <QObject>
#include <QThread>
#include <QHostAddress>
#include <QByteArray>

class ServoUdpWorker; // ǰ������

class ServoUdp : public QObject
{
    Q_OBJECT
public:
    // ����ʱ�������߳���socket���󶨱��ض˿�
    // �� remoteAddr/remotePort �̶�����ֱ�Ӵ��룻Ҳ���Ժ��� setRemote() ����
    explicit ServoUdp(quint16 localPort,
                      const QHostAddress& remoteAddr = QHostAddress::Null,
                      quint16 remotePort = 0,
                      QObject* parent = nullptr);

    ~ServoUdp() override;

    // ���͵�����/���õ�Ĭ��Զ��
    Q_INVOKABLE void send(const QByteArray& data);

    // �ذ󶨱��ض˿ڣ����ڹ����߳���ִ�У�
    Q_INVOKABLE void rebind(quint16 localPort);

    // �ı�Ĭ��Զ�˵�ַ��˿ڣ������߳��ﱣ�沢ʹ�ã�
    Q_INVOKABLE void setRemote(const QHostAddress& addr, quint16 port);

signals:
    // �յ��������ݱ�ʱ����
    void received(const QByteArray& data, const QHostAddress& from, quint16 port);
    // ������ɣ����� writeDatagram ���ֽ�����
    void sent(qint64 bytes);
    // �󶨳ɹ�
    void bound(quint16 localPort);
    // �������󣨰�/�շ��ȣ�
    void errorOccurred(const QString& message);

private:
    QThread m_thread;
    ServoUdpWorker* m_worker = nullptr;
};

#pragma once


struct sFilterOutData
{
    int addr;   //�����ַ
    int functionId;//������
    int registerAddr;//0-��ȡ���״̬��1-ʵ�ʲ�����functionIdΪ10ʱ�����˶���ָ��λ�ã���2-ֹͣ�ҹ��㣬16-�˶���ָ��λ�ã�64-ǰ��

    /*
    ����״̬��ȡ��//���״̬��0-�����л򵽴�λ�� 1-�������� 2-��ײͣ 3-�����ͣ 4-�����ͣ
    */
    int getValue; //��ȡ���ľ���ָ

};

// ����ʵ����
class FilterWheelImpl
{
public:

    

public:
    //virtual int init(const char* serverIp, int serverPort, int addr = 1, int mode = 2) override;

    //��ȡ�����ǰλ��
    int readMotorPosition(int addr, char* outBuffer);

    //����˶���ָ��λ��
    int moveToSetPosition(int addr, int position, char* outBuffer);

    //�����ǰ�˶���stepΪ��ʱ��ת
    int moveByStep(int addr, int step, char* outBuffer);

    //ֹͣת���ҹ���λ
    int motorZeroing(int addr, char* outBuffer);//�ݲ�֧��

    int setZeroing(int addr, char* outBuffer);

    int motorEnablement(int addr, char* outBuffer);//�ݲ�֧��

    //ֹͣת��
    int stopRunning(int addr, char* outBuffer);

    //��ȡ���״̬
    int getMotorStatus(int addr, char* outBuffer);

    //���ݽ���
    bool dataParse(char* buffer, int len, sFilterOutData* outData);

    void modBusCRC(const char* data, int cnt, char* outData);


private:
    char* sendBuffer_;


};

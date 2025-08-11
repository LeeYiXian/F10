#pragma once

// ����ʵ����
class Stm2038bImpl
{
public:

    struct sOutData
    {
        int addr;   //�����ַ
        int functionId;//������
        int registerAddr;//897-��ȡ���״̬��968-ʵ�ʲ���
        int registerNum;//�Ĵ�������

        int getValue; //��ȡ���ľ���ָ�������״̬ʱ����ֵ��Ч��

        //�������״̬ʱ�������ֶ���Ч
        int positionStatus;  //��λ״̬: 1-��λ��ɣ�2��λ���ڴ���
        int positionOffset;  //��λ��1-����� 2-�����

    };

    typedef enum
    {
        ZEROPOINT_MODEING = 0,
        POSITION_CONTROL

    }workModes;

    //���ÿ���ģʽ
    int setContorMode(int addr, char* outBuffer);

    //���ù���ģʽ
    int setWorkMode(int addr, workModes mode, char* outBuffer);

    //����Ŀ��λ��
    int setTargetPosition(int addr, int position, char* outBuffer);

    //����Ŀ���ٶ�
    int setTargetSpeed(int addr, int speed, char* outBuffer);

    //���ü��ٶ�
    int setAcceleration(int addr, int acceleration, char* outBuffer);

    //���ü��ٶ�
    int setDeceleration(int addr, int deceleration, char* outBuffer);

    //ʹ���ʹ��
    int motorEnablement(int addr, char* outBuffer);

    //��ȡ�����ǰλ��
    int readMotorPosition(int addr, char* outBuffer);

    //��λ���
    int motorZeroing(int addr, char* outBuffer);

    //ֹͣת��
    int stopRunning(int addr, char* outBuffer);

    //����˶���ָ��λ��
    int moveToSetPosition(int addr, int position, char* outBuffer);

    //�����ǰ�˶���stepΪ��ʱ��ת
    int moveByStep(int addr, int step, int speed, int acceleration, int offset, char* outBuffer);

    //��ȡ���״̬
    int getMotorStatus(int addr, char* outBuffer);

    //���ݽ���
    bool dataParse(char* buffer, int len, sOutData* outData, int registerValue);

    void modBusCRC(const char* data, int cnt, char* outData);

private:
    workModes workMode_;

};
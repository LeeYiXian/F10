#pragma once
/*

*/
// ����ʵ����
class LinearGuideRailImpl
{
public:

    struct sOutData
    {
        int addr;   //�����ַ
        int functionId;//������
        int registerAddr;//0-��ȡ���״̬��1-ʵ�ʲ�����functionIdΪ10ʱ�����˶���ָ��λ�ã���2-ֹͣ�ҹ��㣬16-�˶���ָ��λ�ã�64-ǰ��
        int registerNum;//�Ĵ�������

        int getValue; //��ȡ���ľ���ָ�������״̬ʱ����ֵ��Ч��

        //�������״̬ʱ�������ֶ���Ч
        int powerOnStatus;  //����״̬: 1-����δ����״̬
        int runningStatus;  //���п���״̬��1-����״̬ 2-����״̬
        int resetStatus;    //��λ״̬��1-��λ��  2-���ڸ�λ��
        int otherStatus;    //����״̬��1-��λ״̬���� 2-��תʱ����up����  3-��תʱ����up����

    };

    //��ȡ�����ǰλ��
    int readMotorPosition(int addr, char* outBuffer);

    //��λ���
    int motorZeroing(int addr, char* outBuffer);

    //ֹͣת��
    int stopRunning(int addr, char* outBuffer);

    //����˶���ָ��λ�ã���ʱ���ã���moveByStep�����ݵ��Խ��ѡ�øýӿڻ���moveByStep���ýӿ���Ҫ��װ������λ����������
    int moveToSetPosition(int addr, int position, char* outBuffer);

    //�����ǰ�˶���stepΪ��ʱ��ת
    int moveByStep(int addr, int step, char* outBuffer);

    //��ȡ���״̬
    int getMotorStatus(int addr, char* outBuffer);

    //���ݽ���
    bool dataParse(char* buffer, int len, sOutData* outData, int registerValue);

    void modBusCRC(const char* data, int cnt, char* outData);

};

#include "filterWheelImpl.h"
#include <stdexcept>
#include <string>

int FilterWheelImpl::readMotorPosition(int addr, char* outBuffer)
{
    outBuffer[0] = addr;//�����ַ
    outBuffer[1] = 0x03;//������

    outBuffer[2] = 0x00;//�Ĵ�����ַ
    outBuffer[3] = 0x00;

    outBuffer[4] = 0x00;//�Ĵ�������
    outBuffer[5] = 0x02;

    //У��λ
    char calcData[2];
    modBusCRC(outBuffer, 6, calcData);
    outBuffer[6] = calcData[0];
    outBuffer[7] = calcData[1];
    return 8;
}

int FilterWheelImpl::moveToSetPosition(int addr, int position, char* outBuffer)
{
    outBuffer[0] = addr;//�����ַ
    outBuffer[1] = 0x10;//������

    outBuffer[2] = 0x00;//�Ĵ�����ַ
    outBuffer[3] = 0x10;

    outBuffer[4] = 0x00;//�Ĵ�������
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    //�ĸ��ֽڵ�int
    memcpy(outBuffer + 7, &position, 4);

    //У��λ
    char calcData[2];
    modBusCRC(outBuffer, 11, calcData);
    outBuffer[11] = calcData[0];
    outBuffer[12] = calcData[1];

    return 13;


    //outBuffer[0] = addr;//�����ַ
    //outBuffer[1] = 0x10;//������

    //outBuffer[2] = 0x00;//�Ĵ�����ַ
    //outBuffer[3] = 0x10;

    //outBuffer[4] = 0x00;//�Ĵ�������
    //outBuffer[5] = 0x06;

    //outBuffer[6] = 0x0C;

    ////�ĸ��ֽڵ�int
    //memcpy(outBuffer + 7, &position, 4);

    //outBuffer[11] = 0x00;
    //outBuffer[12] = 0x00;

    //memcpy(outBuffer + 13, &speed, 2);

    //memcpy(outBuffer + 15, &acceleration, 2);

    //memcpy(outBuffer + 17, &offset, 2);

    ////У��λ
    //char calcData[2];
    //modBusCRC(outBuffer, 19, calcData);
    //outBuffer[19] = calcData[0];
    //outBuffer[20] = calcData[1];

    //return 21;
}

int FilterWheelImpl::moveByStep(int addr, int step, int speed, int acceleration, int offset, char* outBuffer)
{
    outBuffer[0] = addr;//�����ַ
    outBuffer[1] = 0x10;//������

    outBuffer[2] = 0x00;//�Ĵ�����ַ
    outBuffer[3] = 0x40;

    outBuffer[4] = 0x00;//�Ĵ�������
    outBuffer[5] = 0x06;

    outBuffer[6] = 0x0C;

    //�ĸ��ֽڵ�int
    memcpy(outBuffer + 7, &step, 4);

    outBuffer[11] = 0x00;
    outBuffer[12] = 0x00;

    memcpy(outBuffer + 13, &speed, 2);

    memcpy(outBuffer + 15, &acceleration, 2);

    memcpy(outBuffer + 17, &offset, 2);

    //У��λ
    char calcData[2];
    modBusCRC(outBuffer, 19, calcData);
    outBuffer[19] = calcData[0];
    outBuffer[20] = calcData[1];

    return 21;
}

int FilterWheelImpl::motorZeroing(int addr, char* outBuffer)
{
    outBuffer[0] = addr;//�����ַ
    outBuffer[1] = 0x10;//������

    outBuffer[2] = 0x00;//�Ĵ�����ַ
    outBuffer[3] = 0x02;

    outBuffer[4] = 0x00;//�Ĵ�������
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    outBuffer[7] = 0x00;
    outBuffer[8] = 0x00;
    outBuffer[9] = 0x00;
    outBuffer[10] = 0x00;

    //У��λ
    char calcData[2];
    modBusCRC(outBuffer, 11, calcData);
    outBuffer[11] = calcData[0];
    outBuffer[12] = calcData[1];

    return 13;
}

int FilterWheelImpl::motorEnablement(int addr, char* outBuffer)
{
    return 0;
}

int FilterWheelImpl::stopRunning(int addr, char* outBuffer)
{
    outBuffer[0] = addr;//�����ַ
    outBuffer[1] = 0x10;//������

    outBuffer[2] = 0x00;//�Ĵ�����ַ
    outBuffer[3] = 0x01;

    outBuffer[4] = 0x00;//�Ĵ�������
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    outBuffer[7] = 0x00;
    outBuffer[8] = 0x00;
    outBuffer[9] = 0x00;
    outBuffer[10] = 0x00;

    //У��λ
    char calcData[2];
    modBusCRC(outBuffer, 11, calcData);
    outBuffer[11] = calcData[0];
    outBuffer[12] = calcData[1];

    return 0;
}

int FilterWheelImpl::getMotorStatus(int addr, char* outBuffer)
{
    outBuffer[0] = addr;//�����ַ
    outBuffer[1] = 0x03;//������

    outBuffer[2] = 0x00;//�Ĵ�����ַ
    outBuffer[3] = 0x00;

    outBuffer[4] = 0x00;//�Ĵ�������
    outBuffer[5] = 0x01;

    //У��λ
    char calcData[2];
    modBusCRC(outBuffer, 11, calcData);
    outBuffer[6] = calcData[0];
    outBuffer[7] = calcData[1];

    return 8;
}

void FilterWheelImpl::modBusCRC(const char* data, int cnt, char* outData)
{
    uint16_t wCrc = 0xFFFF;  // CRC ��ʼֵ

    for (int i = 0; i < cnt; i++) {
        wCrc ^= (uint16_t)(data[i]);  // ���ֽ����

        for (int j = 0; j < 8; j++) {
            if (wCrc & 0x0001) {  // ������λ�� 1
                wCrc >>= 1;
                wCrc ^= 0xA001;   // ������ʽ 0xA001 (Modbus)
            }
            else {
                wCrc >>= 1;
            }
        }
    }

    // ���� CRC У���루��λ��ǰ��
    outData[0] = static_cast<char>(wCrc & 0xFF);
    outData[1] = static_cast<char>((wCrc >> 8) & 0xFF);

}

bool FilterWheelImpl::dataParse(char* buffer, int len, sOutData* outData)
{
    if (len < 6)
    {
        return false;
    }

    outData->registerAddr = -1;//��ʼ���Ĵ�����ַΪ-1��

    outData->addr = buffer[0];
    outData->functionId = buffer[1];

    if (outData->functionId == 0x03)
    {
        int datalen = buffer[2];
        memcpy(&outData->getValue, buffer + 3, datalen);
    }
    else if (outData->functionId == 0x06 || outData->functionId == 0x10)
    {
        memcpy(&outData->registerAddr, buffer + 2, 2);
    }


    return true;
}


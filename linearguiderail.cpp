#include "linearguiderailimpl.h"
#include "Loggers.h"
#include <stdexcept>
#include <string>


int LinearGuideRailImpl::readMotorPosition(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x03;

    int nRegister = 1000;
    //memcpy(outBuffer + 2, &nRegister, 2);
    outBuffer[2] = (nRegister >> 8) & 0xFF;
    outBuffer[3] = nRegister & 0xFF;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x02;

    char clc16[2];
    modBusCRC(outBuffer, 6, clc16);

    outBuffer[6] = clc16[0];
    outBuffer[7] = clc16[1];

    return 8;
}

int LinearGuideRailImpl::motorZeroing(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x06;

    int nRegester = 2000;
    memcpy(outBuffer + 2, &nRegester, 2);

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x00;

    char clc16[2];
    modBusCRC(outBuffer, 6, clc16);
    outBuffer[6] = clc16[0];
    outBuffer[7] = clc16[1];

    return 8;
}

int LinearGuideRailImpl::stopRunning(int addr, char* outBuffer)
{

    outBuffer[0] = addr;
    outBuffer[1] = 0x06;

    int nRegester = 2001;
    memcpy(outBuffer + 2, &nRegester, 2);

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x00;

    char clc16[2];
    modBusCRC(outBuffer, 6, clc16);
    outBuffer[6] = clc16[0];
    outBuffer[7] = clc16[1];

    return 8;
}

int LinearGuideRailImpl::moveToSetPosition(int addr, int position, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    int nRegester = 2002;
    memcpy(outBuffer + 2, &nRegester, 2);

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    memcpy(outBuffer + 7, &position, 4);

    char clc16[2];
    modBusCRC(outBuffer, 11, clc16);
    outBuffer[11] = clc16[0];
    outBuffer[12] = clc16[1];

    return 13;
}

int LinearGuideRailImpl::moveByStep(int addr, int step, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    int nRegester = 2004;
    if (step < 0)
    {
        nRegester = 2006;
        step = std::abs(step);
    }

    outBuffer[2] = (nRegester >> 8) & 0xFF;
    outBuffer[3] = nRegester & 0xFF;
    //memcpy(outBuffer + 2, &nRegester, 2);

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    //memcpy(outBuffer + 7, &step, 4);

    outBuffer[7] = (step >> 24) & 0xFF;
    outBuffer[8] = (step >> 16) & 0xFF;
    outBuffer[9] = (step >> 8) & 0xFF;
    outBuffer[10] = step & 0xFF;

    char clc16[2];
    modBusCRC(outBuffer, 11, clc16);
    outBuffer[11] = clc16[0];
    outBuffer[12] = clc16[1];

    return 13;

}

int LinearGuideRailImpl::getMotorStatus(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x03;

    int nRegister = 1004;
    //memcpy(outBuffer + 2, &nRegister, 2);

	outBuffer[2] = (nRegister >> 8) & 0xFF;
	outBuffer[3] = nRegister & 0xFF;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x01;

    char clc16[2];
    modBusCRC(outBuffer, 6, clc16);
    outBuffer[6] = clc16[0];
    outBuffer[7] = clc16[1];

    return 8;
}

bool LinearGuideRailImpl::dataParse(char* buffer, int len, sLinearOutData* outData, int registerValue)
{
    if (len < 5)
    {
        return false;
    }

    outData->addr = buffer[0];
    outData->functionId = buffer[1];

    if (0x03 == outData->functionId)
    {
        int dataLen = buffer[2];

        if (dataLen > len - 5)//5ΪУ��2Bit + ��ַ1Bit + ������1Bit + ���ݳ���1Bit
        {
            return false; 
        }

        //���ؼĴ���
        outData->registerAddr = registerValue;

		/*if (1)
		{*/

            int status = 0;

            //memcpy(&status, buffer + 3, dataLen);
            status =(buffer[3] << 8) | buffer[4];
            if (0xFF == status)
            {
                outData->powerOnStatus = 1;
                return true;
            }

            //�ж��Ƿ������л��߿���״̬��
            if ((status & 0x0007) == 0)
            {
                outData->runningStatus = 1;
            }
            else if ((status & 0x0007) >= 1 || (status & 0x0007) <= 7)
            {
                outData->runningStatus = 2;
            }

            //�ж��Ƿ��ڸ�λ��
            if ((status & 0x0008) == 0)
            {
                outData->resetStatus = 1;
            }
            else
            {
                outData->resetStatus = 2;
            }

            if (((status & 0x00F0) >> 4) == 1)
            {
                outData->otherStatus = 1;
            }
            else if (((status & 0x00F0) >> 4) == 6)
            {
                outData->otherStatus = 2;
            }
            else if (((status & 0x00F0) >> 4) == 7)
            {
                outData->otherStatus = 3;
            }

        //}
        /*else
        {
            int dataValue = 0;
            memcpy(&dataValue, buffer + 3, dataLen);
            outData->getValue = dataValue;
        }*/
    }
    else if (0x06 == outData->functionId)
    {
        memcpy(&outData->registerAddr, buffer + 2, 2);
        memcpy(&outData->getValue, buffer + 4, 2);
        outData->registerNum = 1;
    }
    else if (0x10 == outData->functionId)
    {
        memcpy(&outData->registerAddr, buffer + 2, 2);
        memcpy(&outData->registerNum, buffer + 4, 2);
    }

    return true;
}

void LinearGuideRailImpl::modBusCRC(const char* data, int cnt, char* outData)
{
    unsigned short CRC = 0xffff;//��1��CRC�Ĵ�����ֵ0xffff

    int dataSize = cnt;
    for (int i = 0; i < dataSize; i++)//��5���ظ�����2~4
    {
        //LX_LOG_INFO("data [%d] [%02x] cnt[%d]",i, data[i], cnt);
        CRC = CRC ^ (unsigned char)data[i];//(2)������CRC���
        for (int j = 0; j < 8; j++)//��4���ظ�8�β���3
        {
            //(3)����λ�Ƿ�Ϊ1����������1���룬��λΪ1����Ϊ1����λΪ0����Ϊ0
            if (CRC & 1)//�����λΪ1����������һλ������A001H�����
            {
                CRC >>= 1;
                CRC ^= 0xA001;
            }
            else//��λΪ0��������һλ
                CRC >>= 1;
        }
    }
    //LX_LOG_INFO("data  [%04x] ", CRC);
    // ת��Ϊ4λʮ�������ַ������洢��char����
    memcpy(outData, &CRC, 2);
    return;
}



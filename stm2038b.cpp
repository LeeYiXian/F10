#include "Stm2038bImpl.h"
#include <stdexcept>
#include <string>

int Stm2038bImpl::setContorMode(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x06;
    outBuffer[2] = 0x00;
    outBuffer[3] = (char)0xB1;
    outBuffer[4] = (char)0x00;
    outBuffer[5] = (char)0x00;
    outBuffer[6] = (char)0xD9;
    outBuffer[7] = (char)0xED;
    return 8;
}

int Stm2038bImpl::setWorkMode(int addr, workModes mode, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x06;
    outBuffer[2] = 0x03;
    outBuffer[3] = (char)0xC2;
    outBuffer[4] = (char)0x00;
    outBuffer[5] = (char)0x01;
    outBuffer[6] = (char)0xE9;
    outBuffer[7] = (char)0xB2;
    return 8;
}

int Stm2038bImpl::setTargetPosition(int addr, int position, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0xE7;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    //四个字节的int
    outBuffer[7] = (position >> 24) & 0xFF;
    outBuffer[8] = (position >> 16) & 0xFF;
    outBuffer[9] = (position >> 8) & 0xFF;
    outBuffer[10] = position & 0xFF;

    char crc16[2];
    modBusCRC(outBuffer, 11, crc16);
    outBuffer[11] = crc16[0];
    outBuffer[12] = crc16[1];

    return 13;
}

int Stm2038bImpl::setTargetSpeed(int addr, int speed, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0xF8;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;
    
    outBuffer[7] = 0x00;
    outBuffer[8] = 0x01;
    outBuffer[9] = 0x86;
    outBuffer[10] = 0xA0;
    
    outBuffer[11] = 0xDA;
    outBuffer[12] = 0x65;

    return 13;

}

int Stm2038bImpl::setAcceleration(int addr, int acceleration, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0xFC;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    memcpy(outBuffer + 7, &acceleration, 4);
    return 11;
}

int Stm2038bImpl::setDeceleration(int addr, int deceleration, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0xFE;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x02;

    outBuffer[6] = 0x04;

    memcpy(outBuffer + 7, &deceleration, 4);
    return 11;
}

int Stm2038bImpl::motorReady(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x06;
    outBuffer[2] = 0x03;
    outBuffer[3] = 0x80;
    outBuffer[4] = 0x00;
    outBuffer[5] = 0x06;
    outBuffer[6] = 0x08;
    outBuffer[7] = 0x64;
    return 8;
}

int Stm2038bImpl::motorDisablement(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x06;
    outBuffer[2] = 0x03;
    outBuffer[3] = 0x80;
    outBuffer[4] = 0x00;
    outBuffer[5] = 0x06;
    outBuffer[6] = 0xC9;
    outBuffer[7] = 0xA4;
    return 8;
}

int Stm2038bImpl::motorEnablement(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0x80;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x01;

    outBuffer[6] = 0x02;

    outBuffer[7] = 0x00;
    outBuffer[8] = 0x0F;

    return 9;

}

int Stm2038bImpl::readMotorPosition(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x03;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0xC8;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x01;

    return 6;
}

int Stm2038bImpl::motorZeroing(int addr, char* outBuffer)
{
    return 0;
}

int Stm2038bImpl::stopRunning(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x06;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0x80;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x7F;

    outBuffer[6] = 0xC9;
    outBuffer[7] = 0x86;
    
    return 8;
}

int Stm2038bImpl::moveToSetPosition(int addr, int position, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x06;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0x80;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x3F;

    outBuffer[6] = 0xC8;
    outBuffer[7] = 0x76;

    return 8;
}

int Stm2038bImpl::moveByStep(int addr, int step, int speed, int acceleration, int offset, char* outBuffer)
{

    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0x80;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x01;

    outBuffer[6] = 0x02;

    outBuffer[7] = 0x00;
    outBuffer[8] = 0x6F;

    return 9;
}

int Stm2038bImpl::getMotorStatus(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x03;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0x81;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x01;

    return 6;
}

bool Stm2038bImpl::dataParse(char* buffer, int len, sOutData* outData, int registerValue)
{
    if (len < 5)
    {
        return false;
    }

    outData->addr = buffer[0];
    outData->functionId = buffer[1];

    if (0x03 == outData->functionId)
    {
        if (897 == registerValue)
        {
            int dataValue;
            memcpy(&dataValue, buffer + 3, 2);
            if ((dataValue >> 12 & 0x01) == 0)
            {
                outData->positionStatus = 1;
            }
            else
            {
                outData->positionStatus = 2;
            }

            if ((dataValue >> 13 & 0x01) == 0)
            {
                outData->positionOffset = 1;
            }
            else
            {
                outData->positionOffset = 2;
            }
        }
        else if (968 == registerValue)
        {
            memcpy(&outData->getValue, buffer + 3, 2);
        }

    }
    else
    {
        memcpy(&outData->registerAddr, buffer + 2, 2);
        memcpy(&outData->registerNum, buffer + 4, 2);
    }

    return true;
}

void Stm2038bImpl::modBusCRC(const char* data, int cnt, char* outData)
{
    uint16_t wCrc = 0xFFFF;  // CRC 初始值

    for (int i = 0; i < cnt; i++) {
        wCrc ^= (unsigned char)(data[i]);  // 逐字节异或

        for (int j = 0; j < 8; j++) {
            if (wCrc & 0x0001) {  // 如果最低位是 1
                wCrc >>= 1;
                wCrc ^= 0xA001;   // 异或多项式 0xA001 (Modbus)
            }
            else {
                wCrc >>= 1;
            }
        }
    }

    // 返回 CRC 校验码（低位在前）
    outData[0] = static_cast<char>(wCrc & 0xFF);
    outData[1] = static_cast<char>((wCrc >> 8) & 0xFF);
}


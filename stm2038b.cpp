#include "Stm2038bImpl.h"
#include <stdexcept>
#include <string>

int Stm2038bImpl::setContorMode(int addr, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;
    outBuffer[2] = 0x00;
    outBuffer[3] = (char)0xB1;
    outBuffer[4] = (char)0x00;
    outBuffer[5] = (char)0x01;
    outBuffer[6] = (char)0x02;
    outBuffer[7] = (char)0x00;
    outBuffer[8] = (char)0x00;
    return 9;
}

int Stm2038bImpl::setWorkMode(int addr, workModes mode, char* outBuffer)
{
    workMode_ = mode;
    if (mode == workModes::ZEROPOINT_MODEING)
    {
        outBuffer[0] = addr;
        outBuffer[1] = 0x10;

        outBuffer[2] = 0x03;
        outBuffer[3] = 0xC2;

        outBuffer[4] = 0x00;
        outBuffer[5] = 0x01;

        outBuffer[6] = 0x02;

        outBuffer[7] = 0x00;
        outBuffer[8] = 0x06;

        return 9;
    }
    else if (mode == workModes::POSITION_CONTROL)
    {
        outBuffer[0] = addr;
        outBuffer[1] = 0x10;

        outBuffer[2] = 0x03;
        outBuffer[3] = 0xC2;

        outBuffer[4] = 0x00;
        outBuffer[5] = 0x01;

        outBuffer[6] = 0x02;

        outBuffer[7] = 0x00;
        outBuffer[8] = 0x01;
        return 9;
    }

    return 0;
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

    memcpy(outBuffer + 7, &position, 4);

    return 11;
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

    memcpy(outBuffer + 7, &speed, 4);
    return 11;

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
    return 0;
}

int Stm2038bImpl::moveToSetPosition(int addr, int position, char* outBuffer)
{
    outBuffer[0] = addr;
    outBuffer[1] = 0x10;

    outBuffer[2] = 0x03;
    outBuffer[3] = 0x80;

    outBuffer[4] = 0x00;
    outBuffer[5] = 0x01;

    outBuffer[6] = 0x02;

    outBuffer[7] = 0x00;
    outBuffer[8] = 0x3F;

    return 9;
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

}


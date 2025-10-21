#pragma once


struct sFilterOutData
{
    int addr;   //电机地址
    int functionId;//功能码
    int registerAddr;//0-读取电机状态，1-实际步数（functionId为10时代表运动到指定位置），2-停止且归零，16-运动到指定位置，64-前进

    /*
    对于状态获取：//电机状态，0-待机中或到达位置 1-正在运行 2-碰撞停 3-正光电停 4-反光电停
    */
    int getValue; //读取到的具体指

};

// 具体实现类
class FilterWheelImpl
{
public:

    

public:
    //virtual int init(const char* serverIp, int serverPort, int addr = 1, int mode = 2) override;

    //读取电机当前位置
    int readMotorPosition(int addr, char* outBuffer);

    //电机运动到指定位置
    int moveToSetPosition(int addr, int position, char* outBuffer);

    //电机向前运动，step为负时反转
    int moveByStep(int addr, int step, char* outBuffer);

    //停止转动且归零位
    int motorZeroing(int addr, char* outBuffer);//暂不支持

    int setZeroing(int addr, char* outBuffer);

    int motorEnablement(int addr, char* outBuffer);//暂不支持

    //停止转动
    int stopRunning(int addr, char* outBuffer);

    //获取电机状态
    int getMotorStatus(int addr, char* outBuffer);

    //数据解析
    bool dataParse(char* buffer, int len, sFilterOutData* outData);

    void modBusCRC(const char* data, int cnt, char* outData);


private:
    char* sendBuffer_;


};

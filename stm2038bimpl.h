#pragma once

// 具体实现类
class Stm2038bImpl
{
public:

    struct sOutData
    {
        int addr;   //电机地址
        int functionId;//功能码
        int registerAddr;//897-读取电机状态，968-实际步数
        int registerNum;//寄存器数量

        int getValue; //读取到的具体指（读电机状态时，改值无效）

        //仅读电机状态时，下述字段有效
        int positionStatus;  //定位状态: 1-定位完成，2定位正在处理
        int positionOffset;  //定位误差：1-无误差 2-有误差

    };

    typedef enum
    {
        ZEROPOINT_MODEING = 0,
        POSITION_CONTROL

    }workModes;

    //设置控制模式
    int setContorMode(int addr, char* outBuffer);

    //设置工作模式
    int setWorkMode(int addr, workModes mode, char* outBuffer);

    //设置目标位置
    int setTargetPosition(int addr, int position, char* outBuffer);

    //设置目标速度
    int setTargetSpeed(int addr, int speed, char* outBuffer);

    //设置加速度
    int setAcceleration(int addr, int acceleration, char* outBuffer);

    //设置减速度
    int setDeceleration(int addr, int deceleration, char* outBuffer);

    //使电机使能
    int motorEnablement(int addr, char* outBuffer);

    //读取电机当前位置
    int readMotorPosition(int addr, char* outBuffer);

    //复位电机
    int motorZeroing(int addr, char* outBuffer);

    //停止转动
    int stopRunning(int addr, char* outBuffer);

    //电机运动到指定位置
    int moveToSetPosition(int addr, int position, char* outBuffer);

    //电机向前运动，step为负时反转
    int moveByStep(int addr, int step, int speed, int acceleration, int offset, char* outBuffer);

    //获取电机状态
    int getMotorStatus(int addr, char* outBuffer);

    //数据解析
    bool dataParse(char* buffer, int len, sOutData* outData, int registerValue);

    void modBusCRC(const char* data, int cnt, char* outData);

private:
    workModes workMode_;

};
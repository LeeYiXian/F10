@echo off
setlocal enabledelayedexpansion

REM ��� protoc �Ƿ����
where protoc >nul 2>&1
if %errorlevel% neq 0 (
    echo ����: δ�ҵ� protoc ����������ȷ�� protoc ����ӵ�ϵͳ PATH ��������
    pause
)

REM ���� pb Ŀ¼����������ڣ�
if not exist "pb\" mkdir pb

REM ���� proto Ŀ¼�е����� .proto �ļ�
for %%f in (proto\*.proto) do (
    echo ��������: %%~nxf
    protoc -Iproto --cpp_out=pb "%%f"
    if !errorlevel! neq 0 (
        echo ����: ����ʧ�� - "%%f"
        pause
    )
)

echo ��ɣ������ļ��ѱ��浽 pb Ŀ¼
pause

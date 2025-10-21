@echo off
setlocal

REM NSIS ��װ·�����������ʵ������޸ģ�
set NSIS_PATH="C:\Program Files (x86)\NSIS\makensis.exe"

REM Ŀ��Ŀ¼
set QML_DEST=..\x64\Release

echo [INFO] ��ʼ������װ����...

echo [INFO] ���ڿ���QML�ļ��� %QML_DEST%...
xcopy /E /I /Y ..\*.qml "%QML_DEST%\" >nul 2>&1

echo [INFO] Building installer from F10System.nsi ...
%NSIS_PATH% F10System.nsi

if %errorlevel% neq 0 (
    echo [ERROR] NSIS build failed!
    exit /b %errorlevel%
)

echo [INFO] Build completed successfully.
endlocal
pause

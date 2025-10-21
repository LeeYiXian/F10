@echo off
setlocal

REM NSIS 安装路径（根据你的实际情况修改）
set NSIS_PATH="C:\Program Files (x86)\NSIS\makensis.exe"

REM 目标目录
set QML_DEST=..\x64\Release

echo [INFO] 开始构建安装程序...

echo [INFO] 正在拷贝QML文件到 %QML_DEST%...
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

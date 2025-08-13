@echo off
setlocal

REM NSIS 安装路径（根据你的实际情况修改）
set NSIS_PATH="C:\Program Files (x86)\NSIS\makensis.exe"

echo [INFO] Building installer from F10System.nsi ...
%NSIS_PATH% F10System.nsi

if %errorlevel% neq 0 (
    echo [ERROR] NSIS build failed!
    exit /b %errorlevel%
)

echo [INFO] Build completed successfully.
endlocal
pause

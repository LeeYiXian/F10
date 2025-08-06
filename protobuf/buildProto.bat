@echo off
setlocal enabledelayedexpansion

REM 检查 protoc 是否可用
where protoc >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 protoc 编译器，请确保 protoc 已添加到系统 PATH 环境变量
    pause
)

REM 创建 pb 目录（如果不存在）
if not exist "pb\" mkdir pb

REM 遍历 proto 目录中的所有 .proto 文件
for %%f in (proto\*.proto) do (
    echo 正在生成: %%~nxf
    protoc -Iproto --cpp_out=pb "%%f"
    if !errorlevel! neq 0 (
        echo 错误: 生成失败 - "%%f"
        pause
    )
)

echo 完成！生成文件已保存到 pb 目录
pause

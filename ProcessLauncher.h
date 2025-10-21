#pragma once
#include <windows.h>
#include <string>
#include <stdexcept>
#include <tlhelp32.h>
class ProcessLauncher
{
public:
	ProcessLauncher() : m_hProcess(nullptr) {}

	~ProcessLauncher()
	{
		// 析构时关闭句柄，避免资源泄露
		if (m_hProcess)
		{
			CloseHandle(m_hProcess);
			m_hProcess = nullptr;
		}
	}

	// 工具函数：检查某个进程名是否已在运行
	bool isProcessRunning(const std::wstring& processName)
	{
		HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
		if (hSnapshot == INVALID_HANDLE_VALUE)
			return false;

		PROCESSENTRY32W pe;
		pe.dwSize = sizeof(pe);

		if (Process32FirstW(hSnapshot, &pe))
		{
			do
			{
				if (_wcsicmp(pe.szExeFile, processName.c_str()) == 0)
				{
					CloseHandle(hSnapshot);
					return true;
				}
			} while (Process32NextW(hSnapshot, &pe));
		}

		CloseHandle(hSnapshot);
		return false;
	}

	// 启动exe程序
	void launch(const std::wstring& exePath, const std::wstring& arguments = L"")
	{
		if (exePath.empty())
			return;

		// 取 exe 文件名（不含路径）用于查重
		std::wstring exeName = exePath.substr(exePath.find_last_of(L"\\/") + 1);

		if (isProcessRunning(exeName))
		{
			return;
		}

		std::wstring cmdLine = L"\"" + exePath + L"\" " + arguments;

		// ===== 提取 exe 所在目录 =====
		std::wstring exeDir = exePath;
		size_t pos = exeDir.find_last_of(L"\\/");
		if (pos != std::wstring::npos)
		{
			exeDir = exeDir.substr(0, pos); // 取路径部分
		}
		else
		{
			exeDir = L"."; // 没有路径信息时，用当前目录
		}

		STARTUPINFOW si = { 0 };
		si.cb = sizeof(si);

		PROCESS_INFORMATION pi = { 0 };

		BOOL result = CreateProcessW(
			nullptr,                  // 应用程序名
			&cmdLine[0],              // 命令行
			nullptr,                  // 进程安全属性
			nullptr,                  // 线程安全属性
			FALSE,                    // 是否继承句柄
			0,                        // 创建标志
			nullptr,                  // 使用父进程环境变量
			exeDir.c_str(),           // 设置为 exe 所在目录
			&si,
			&pi);

		// 保存进程句柄
		m_hProcess = pi.hProcess;

		// 不再需要线程句柄
		CloseHandle(pi.hThread);
	}


	// 等待程序退出
	void wait()
	{
		if (m_hProcess)
		{
			WaitForSingleObject(m_hProcess, INFINITE);
		}
	}

	// 关闭进程（可选）
	void terminate()
	{
		if (m_hProcess)
		{
			TerminateProcess(m_hProcess, 0);
			CloseHandle(m_hProcess);
			m_hProcess = nullptr;
		}
	}

private:
	HANDLE m_hProcess;
};

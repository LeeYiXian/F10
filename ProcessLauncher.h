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
		// ����ʱ�رվ����������Դй¶
		if (m_hProcess)
		{
			CloseHandle(m_hProcess);
			m_hProcess = nullptr;
		}
	}

	// ���ߺ��������ĳ���������Ƿ���������
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

	// ����exe����
	void launch(const std::wstring& exePath, const std::wstring& arguments = L"")
	{
		if (exePath.empty())
			return;

		// ȡ exe �ļ���������·�������ڲ���
		std::wstring exeName = exePath.substr(exePath.find_last_of(L"\\/") + 1);

		if (isProcessRunning(exeName))
		{
			return;
		}

		std::wstring cmdLine = L"\"" + exePath + L"\" " + arguments;

		// ===== ��ȡ exe ����Ŀ¼ =====
		std::wstring exeDir = exePath;
		size_t pos = exeDir.find_last_of(L"\\/");
		if (pos != std::wstring::npos)
		{
			exeDir = exeDir.substr(0, pos); // ȡ·������
		}
		else
		{
			exeDir = L"."; // û��·����Ϣʱ���õ�ǰĿ¼
		}

		STARTUPINFOW si = { 0 };
		si.cb = sizeof(si);

		PROCESS_INFORMATION pi = { 0 };

		BOOL result = CreateProcessW(
			nullptr,                  // Ӧ�ó�����
			&cmdLine[0],              // ������
			nullptr,                  // ���̰�ȫ����
			nullptr,                  // �̰߳�ȫ����
			FALSE,                    // �Ƿ�̳о��
			0,                        // ������־
			nullptr,                  // ʹ�ø����̻�������
			exeDir.c_str(),           // ����Ϊ exe ����Ŀ¼
			&si,
			&pi);

		// ������̾��
		m_hProcess = pi.hProcess;

		// ������Ҫ�߳̾��
		CloseHandle(pi.hThread);
	}


	// �ȴ������˳�
	void wait()
	{
		if (m_hProcess)
		{
			WaitForSingleObject(m_hProcess, INFINITE);
		}
	}

	// �رս��̣���ѡ��
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

@echo off
setlocal EnableDelayedExpansion

:: --- �Ǘ��Ҍ����̊m�F�Ə��i ---
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo �Ǘ��Ҍ������K�v�ł��B�Ď��s���܂�...
    mshta "javascript:var shell = new ActiveXObject('Shell.Application'); shell.ShellExecute('%~f0', '', '', 'runas', 1);close();"
    exit /b
)

:: --- �ݒ� ---
set "REPO=manju-summoner/YukkuriMovieMaker4"
set "API=https://api.github.com/repos/%REPO%/releases/latest"
set "INSTALLDIR=C:\Temp\YMM4"
set "ZIPFILE=%TEMP%\YMM4_latest.zip"
set "EXE=%INSTALLDIR%\YukkuriMovieMaker4.exe"
set "DESKTOP=%USERPROFILE%\Desktop"
set "STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: --- ���łɃC���X�g�[���ς݂��m�F ---
if exist "%EXE%" (
    set /p REINSTALL="�C���X�g�[���ς݂ł��B�ăC���X�g�[�����܂����H (y/n): "
    if /i not "!REINSTALL!"=="y" (
        echo ���~���܂����B
        pause
        exit /b
    )
    rmdir /s /q "%INSTALLDIR%"
)

:: --- �ŐV�����[�XURL��curl + findstr�Ŏ擾 ---
echo [1/5] �_�E�����[�hURL���擾��...
curl -s %API% > "%TEMP%\ymm_api.json"
for /f "delims=" %%A in ('findstr /i "browser_download_url.*\.zip" "%TEMP%\ymm_api.json"') do (
    set "DOWNLOAD_LINE=%%A"
)
for /f "tokens=2 delims=:" %%B in ("!DOWNLOAD_LINE!") do (
    set "URL=%%B"
)
set "URL=!URL:~2,-2!"

:: --- �_�E�����[�h ---
echo [2/5] �ŐV�ł��_�E�����[�h��...
curl -L -o "%ZIPFILE%" "!URL!"

:: --- �� ---
echo [3/5] �𓀒�...
mkdir "%INSTALLDIR%" >nul
tar -xf "%ZIPFILE%" -C "%INSTALLDIR%"

del "%ZIPFILE%" >nul
del "%TEMP%\ymm_api.json" >nul

:: --- �V���[�g�J�b�g�쐬�m�F ---
set /p MKDESKTOP="�f�X�N�g�b�v�ɃV���[�g�J�b�g���쐬���܂����H (y/n): "
if /i "%MKDESKTOP%"=="y" (
    call :MakeShortcut "%EXE%" "%DESKTOP%\YMM4.lnk"
)

set /p MKSTART="�X�^�[�g���j���[�ɃV���[�g�J�b�g���쐬���܂����H (y/n): "
if /i "%MKSTART%"=="y" (
    call :MakeShortcut "%EXE%" "%STARTMENU%\YMM4.lnk"
)

:: --- �N�� ---
echo [4/5] YMM4���N�����܂�...
start "" "%EXE%"
echo [5/5] �������܂����I
pause
exit /b

:: === �V���[�g�J�b�g�쐬�p�֐��iVBScript�g�p�j ===
:MakeShortcut
set "VBS=%TEMP%\mkshortcut.vbs"
> "%VBS%" (
    echo Set oWS = WScript.CreateObject("WScript.Shell")
    echo sLinkFile = WScript.Arguments(1)
    echo Set oLink = oWS.CreateShortcut(sLinkFile)
    echo oLink.TargetPath = WScript.Arguments(0)
    echo oLink.Save
)
cscript //nologo "%VBS%" "%~1" "%~2"
del "%VBS%"
goto :eof

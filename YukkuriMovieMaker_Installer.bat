@echo off
setlocal EnableDelayedExpansion

:: --- �Ǘ��Ҍ����̊m�F�Ə��i ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo �Ǘ��Ҍ������K�v�ł��B�Ď��s���܂�...
    mshta "vbscript:CreateObject(\"Shell.Application\").ShellExecute(\"%~f0\", \"\", \"\", \"runas\", 1)(close)"
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

:: --- ���ɃC���X�g�[������Ă��邩�m�F ---
if exist "%EXE%" (
    set /p REINSTALL="�C���X�g�[���ς݂ł��B�ăC���X�g�[�����܂����H (y/n): "
    if /i not "!REINSTALL!"=="y" (
        echo ���~���܂����B
        pause
        exit /b
    )
    rmdir /s /q "%INSTALLDIR%" >nul 2>&1
)

:: --- �ŐV��zip�_�E�����[�hURL���擾 ---
echo [1/5] ZIP��URL���擾��...
curl -s %API% -o "%TEMP%\ymm_api.json"
set "URL="
for /f "tokens=2 delims=:" %%A in ('findstr /i "browser_download_url" "%TEMP%\ymm_api.json" ^| findstr /i ".zip"') do (
    set "URL=%%A"
)

:: �N�H�[�g����s�E�X�y�[�X����
set "URL=!URL: =!"
set "URL=!URL:~1,-2!"

if not defined URL (
    echo ZIP��URL��������܂���ł����BAPI�\�����ύX���ꂽ�\��������܂��B
    pause
    exit /b 1
)

:: --- ZIP���_�E�����[�h ---
echo [2/5] ZIP���_�E�����[�h��...
curl -L -o "%ZIPFILE%" "!URL!"

if not exist "%ZIPFILE%" (
    echo ZIP�̃_�E�����[�h�Ɏ��s���܂����B
    pause
    exit /b 1
)

:: --- �� ---
echo [3/5] ZIP���𓀒�...
mkdir "%INSTALLDIR%" >nul 2>&1
tar -xf "%ZIPFILE%" -C "%INSTALLDIR%"

if not exist "%EXE%" (
    echo �𓀌�Ɏ��s�t�@�C����������܂���ł����B
    pause
    exit /b 1
)

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

echo [5/5] �C���X�g�[�������I
pause
exit /b

:: === �V���[�g�J�b�g�쐬�i�C���Łj ===
:MakeShortcut
set "VBS=%TEMP%\mkshortcut.vbs"
> "%VBS%" (
    echo Set oWS = CreateObject("WScript.Shell")
    echo Set oLink = oWS.CreateShortcut(WScript.Arguments(1))
    echo oLink.TargetPath = WScript.Arguments(0)
    echo oLink.Save
)
cscript //nologo "%VBS%" "%~1" "%~2"
del "%VBS%" >nul
goto :eof

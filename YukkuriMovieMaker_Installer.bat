@echo off
setlocal EnableDelayedExpansion

:: --- �Ǘ��Ҍ����̊m�F�Ə��i ---
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
  echo �Ǘ��Ҍ������K�v�ł��B�ċN�����܂�...
  powershell -Command "Start-Process '%~f0' -Verb runAs"
  exit /b
)

:: --- �ݒ� ---
set "REPO=manju-summoner/YukkuriMovieMaker4"
set "INSTALLDIR=C:\Temp\YMM4"
set "ZIPFILE=%TEMP%\YMM4_latest.zip"
set "EXE=%INSTALLDIR%\YukkuriMovieMaker4.exe"
set "DESKTOP=%USERPROFILE%\Desktop"
set "STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: --- ���łɃC���X�g�[���ς݂��m�F ---
if exist "%EXE%" (
  set /p REINSTALL="�C���X�g�[�����������Ă��܂��I�ăC���X�g�[�����܂����H (y/n): "
  if /i not "%REINSTALL%"=="y" (
    echo ���~���܂����B
    pause
    exit /b
  )
)

:: --- GitHub API�ōŐVZIP��URL�擾 ---
echo [1/5] �ŐV�o�[�W�����̎擾...
for /f "delims=" %%A in ('powershell -Command ^
  "(Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/%REPO%/releases/latest).Content |
   ConvertFrom-Json |
   Select-Object -ExpandProperty assets |
   Where-Object { $_.name -like '*.zip' } |
   Select-Object -First 1 -ExpandProperty browser_download_url"') do (
   set "DOWNLOAD_URL=%%A"
)

if not defined DOWNLOAD_URL (
  echo �G���[: �_�E�����[�hURL���擾�ł��܂���ł����B
  pause
  exit /b 1
)

:: --- �_�E�����[�h ---
echo [2/5] �ŐV�ł��_�E�����[�h��...
powershell -Command "Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -OutFile '%ZIPFILE%'"

:: --- �𓀐�쐬 ---
if exist "%INSTALLDIR%" rmdir /s /q "%INSTALLDIR%"
mkdir "%INSTALLDIR%" >nul 2>&1

:: --- �� ---
echo [3/5] �𓀒�...
powershell -Command "Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%INSTALLDIR%' -Force"

:: --- ZIP�폜 ---
del "%ZIPFILE%" >nul

:: --- �V���[�g�J�b�g�쐬���m�F ---
set /p MKDESKTOP="�f�X�N�g�b�v�ɃV���[�g�J�b�g���쐬���܂����H (y/n): "
if /i "%MKDESKTOP%"=="y" (
  powershell -Command ^
    "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\YMM4.lnk');" ^
    "$s.TargetPath='%EXE%'; $s.Save()"
)

set /p MKSTART="�X�^�[�g���j���[�ɃV���[�g�J�b�g���쐬���܂����H (y/n): "
if /i "%MKSTART%"=="y" (
  powershell -Command ^
    "$s=(New-Object -COM WScript.Shell).CreateShortcut('%STARTMENU%\YMM4.lnk');" ^
    "$s.TargetPath='%EXE%'; $s.Save()"
)

:: --- �N�� ---
echo [4/5] YMM4���N�����܂�...
start "" "%EXE%"

echo [5/5] �������܂����I
pause
exit /b
@echo off
setlocal EnableDelayedExpansion

:: --- 管理者権限の確認と昇格 ---
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
  echo 管理者権限が必要です。再起動します...
  powershell -Command "Start-Process '%~f0' -Verb runAs"
  exit /b
)

:: --- 設定 ---
set "REPO=manju-summoner/YukkuriMovieMaker4"
set "INSTALLDIR=C:\Temp\YMM4"
set "ZIPFILE=%TEMP%\YMM4_latest.zip"
set "EXE=%INSTALLDIR%\YukkuriMovieMaker4.exe"
set "DESKTOP=%USERPROFILE%\Desktop"
set "STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: --- すでにインストール済みか確認 ---
if exist "%EXE%" (
  set /p REINSTALL="インストールが完了しています！再インストールしますか？ (y/n): "
  if /i not "%REINSTALL%"=="y" (
    echo 中止しました。
    pause
    exit /b
  )
)

:: --- GitHub APIで最新ZIPのURL取得 ---
echo [1/5] 最新バージョンの取得...
for /f "delims=" %%A in ('powershell -Command ^
  "(Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/%REPO%/releases/latest).Content |
   ConvertFrom-Json |
   Select-Object -ExpandProperty assets |
   Where-Object { $_.name -like '*.zip' } |
   Select-Object -First 1 -ExpandProperty browser_download_url"') do (
   set "DOWNLOAD_URL=%%A"
)

if not defined DOWNLOAD_URL (
  echo エラー: ダウンロードURLを取得できませんでした。
  pause
  exit /b 1
)

:: --- ダウンロード ---
echo [2/5] 最新版をダウンロード中...
powershell -Command "Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -OutFile '%ZIPFILE%'"

:: --- 解凍先作成 ---
if exist "%INSTALLDIR%" rmdir /s /q "%INSTALLDIR%"
mkdir "%INSTALLDIR%" >nul 2>&1

:: --- 解凍 ---
echo [3/5] 解凍中...
powershell -Command "Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%INSTALLDIR%' -Force"

:: --- ZIP削除 ---
del "%ZIPFILE%" >nul

:: --- ショートカット作成を確認 ---
set /p MKDESKTOP="デスクトップにショートカットを作成しますか？ (y/n): "
if /i "%MKDESKTOP%"=="y" (
  powershell -Command ^
    "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\YMM4.lnk');" ^
    "$s.TargetPath='%EXE%'; $s.Save()"
)

set /p MKSTART="スタートメニューにショートカットを作成しますか？ (y/n): "
if /i "%MKSTART%"=="y" (
  powershell -Command ^
    "$s=(New-Object -COM WScript.Shell).CreateShortcut('%STARTMENU%\YMM4.lnk');" ^
    "$s.TargetPath='%EXE%'; $s.Save()"
)

:: --- 起動 ---
echo [4/5] YMM4を起動します...
start "" "%EXE%"

echo [5/5] 完了しました！
pause
exit /b
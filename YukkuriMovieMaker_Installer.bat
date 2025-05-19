@echo off
setlocal EnableDelayedExpansion

:: --- 管理者権限の確認と昇格 ---
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo 管理者権限が必要です。再実行します...
    mshta "javascript:var shell = new ActiveXObject('Shell.Application'); shell.ShellExecute('%~f0', '', '', 'runas', 1);close();"
    exit /b
)

:: --- 設定 ---
set "REPO=manju-summoner/YukkuriMovieMaker4"
set "API=https://api.github.com/repos/%REPO%/releases/latest"
set "INSTALLDIR=C:\Temp\YMM4"
set "ZIPFILE=%TEMP%\YMM4_latest.zip"
set "EXE=%INSTALLDIR%\YukkuriMovieMaker4.exe"
set "DESKTOP=%USERPROFILE%\Desktop"
set "STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"

:: --- すでにインストール済みか確認 ---
if exist "%EXE%" (
    set /p REINSTALL="インストール済みです。再インストールしますか？ (y/n): "
    if /i not "!REINSTALL!"=="y" (
        echo 中止しました。
        pause
        exit /b
    )
    rmdir /s /q "%INSTALLDIR%"
)

:: --- 最新リリースURLをcurl + findstrで取得 ---
echo [1/5] ダウンロードURLを取得中...
curl -s %API% > "%TEMP%\ymm_api.json"
for /f "delims=" %%A in ('findstr /i "browser_download_url.*\.zip" "%TEMP%\ymm_api.json"') do (
    set "DOWNLOAD_LINE=%%A"
)
for /f "tokens=2 delims=:" %%B in ("!DOWNLOAD_LINE!") do (
    set "URL=%%B"
)
set "URL=!URL:~2,-2!"

:: --- ダウンロード ---
echo [2/5] 最新版をダウンロード中...
curl -L -o "%ZIPFILE%" "!URL!"

:: --- 解凍 ---
echo [3/5] 解凍中...
mkdir "%INSTALLDIR%" >nul
tar -xf "%ZIPFILE%" -C "%INSTALLDIR%"

del "%ZIPFILE%" >nul
del "%TEMP%\ymm_api.json" >nul

:: --- ショートカット作成確認 ---
set /p MKDESKTOP="デスクトップにショートカットを作成しますか？ (y/n): "
if /i "%MKDESKTOP%"=="y" (
    call :MakeShortcut "%EXE%" "%DESKTOP%\YMM4.lnk"
)

set /p MKSTART="スタートメニューにショートカットを作成しますか？ (y/n): "
if /i "%MKSTART%"=="y" (
    call :MakeShortcut "%EXE%" "%STARTMENU%\YMM4.lnk"
)

:: --- 起動 ---
echo [4/5] YMM4を起動します...
start "" "%EXE%"
echo [5/5] 完了しました！
pause
exit /b

:: === ショートカット作成用関数（VBScript使用） ===
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

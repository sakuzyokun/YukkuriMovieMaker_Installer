@echo off
setlocal EnableDelayedExpansion

:: --- 管理者権限の確認と昇格 ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 管理者権限が必要です。再実行します...
    mshta "vbscript:CreateObject(\"Shell.Application\").ShellExecute(\"%~f0\", \"\", \"\", \"runas\", 1)(close)"
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

:: --- 既にインストールされているか確認 ---
if exist "%EXE%" (
    set /p REINSTALL="インストール済みです。再インストールしますか？ (y/n): "
    if /i not "!REINSTALL!"=="y" (
        echo 中止しました。
        pause
        exit /b
    )
    rmdir /s /q "%INSTALLDIR%" >nul 2>&1
)

:: --- 最新のzipダウンロードURLを取得 ---
echo [1/5] ZIPのURLを取得中...
curl -s %API% -o "%TEMP%\ymm_api.json"
set "URL="
for /f "tokens=2 delims=:" %%A in ('findstr /i "browser_download_url" "%TEMP%\ymm_api.json" ^| findstr /i ".zip"') do (
    set "URL=%%A"
)

:: クォートや改行・スペース除去
set "URL=!URL: =!"
set "URL=!URL:~1,-2!"

if not defined URL (
    echo ZIPのURLが見つかりませんでした。API構造が変更された可能性があります。
    pause
    exit /b 1
)

:: --- ZIPをダウンロード ---
echo [2/5] ZIPをダウンロード中...
curl -L -o "%ZIPFILE%" "!URL!"

if not exist "%ZIPFILE%" (
    echo ZIPのダウンロードに失敗しました。
    pause
    exit /b 1
)

:: --- 解凍 ---
echo [3/5] ZIPを解凍中...
mkdir "%INSTALLDIR%" >nul 2>&1
tar -xf "%ZIPFILE%" -C "%INSTALLDIR%"

if not exist "%EXE%" (
    echo 解凍後に実行ファイルが見つかりませんでした。
    pause
    exit /b 1
)

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

echo [5/5] インストール完了！
pause
exit /b

:: === ショートカット作成（修正版） ===
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

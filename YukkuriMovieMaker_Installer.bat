@echo off
chcp 65001 > nul
title ゆっくりムービーメーカー インストーラー
echo ゆっくりムービーメーカー インストーラー
echo Version 1.0.1

:: フォルダ作成
if not exist "C:\Temp" (
    mkdir "C:\Temp"
)
if not exist "C:\YMM" (
    mkdir "C:\YMM"
)

:: ZIP ダウンロード
echo.
echo ZIPファイルをダウンロード中...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/manju-summoner/YukkuriMovieMaker4/releases/download/v4.41.0.6/YukkuriMovieMaker_v4.41.0.6.zip' -OutFile 'C:\Temp\YukkuriMovieMaker.zip'"

:: 解凍
echo.
echo 解凍中...
powershell -Command "Expand-Archive -Path 'C:\Temp\YukkuriMovieMaker.zip' -DestinationPath 'C:\YMM' -Force"

:: ショートカット作成
echo.
echo ショートカット作成中...

:: デスクトップとスタートメニューのパスを取得
set desktop=%USERPROFILE%\Desktop
set startmenu=%APPDATA%\Microsoft\Windows\Start Menu\Programs

:: PowerShellでショートカット作成（デスクトップ）
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%desktop%\YukkuriMovieMaker.lnk'); $s.TargetPath='C:\YMM\YukkuriMovieMaker.exe'; $s.Save()"

:: PowerShellでショートカット作成（スタートメニュー）
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%startmenu%\YukkuriMovieMaker.lnk'); $s.TargetPath='C:\YMM\YukkuriMovieMaker.exe'; $s.Save()"

:: 起動
echo.
echo ゆっくりムービーメーカーを起動します...
start "" "C:\YMM\YukkuriMovieMaker.exe"

echo.
echo インストール完了！
pause

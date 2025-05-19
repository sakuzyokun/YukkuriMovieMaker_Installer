@echo off
echo ゆっくりMovieMaker インストーラー
echo Version 1.0.0

echo
echo ゆっくりMovieMakerをダウンロードしています…
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/manju-summoner/YukkuriMovieMaker4/releases/download/v4.41.0.6/YukkuriMovieMaker_v4.41.0.6.zip' -OutFile 'C:\Temp\YMM\YukkuriMovieMaker.zip'"

echo ダウンロードしたファイルを解凍しています…
powershell -Command "Expand-Archive -Path 'C:\Temp\YMM\YukkuriMovieMaker.zip' -DestinationPath 'C:\Program files\YukkuriMovieMaker'"

echo ゆっくりMovieMakerを起動しています…
start C:\Program files\YukkuriMovieMaker\YukkuriMovieMaker.exe
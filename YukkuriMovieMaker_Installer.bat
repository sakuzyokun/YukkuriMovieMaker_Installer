@echo off
echo �������MovieMaker �C���X�g�[���[
echo Version 1.0.0

echo
echo �������MovieMaker���_�E�����[�h���Ă��܂��c
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/manju-summoner/YukkuriMovieMaker4/releases/download/v4.41.0.6/YukkuriMovieMaker_v4.41.0.6.zip' -OutFile 'C:\Temp\YMM\YukkuriMovieMaker.zip'"

echo �_�E�����[�h�����t�@�C�����𓀂��Ă��܂��c
powershell -Command "Expand-Archive -Path 'C:\Temp\YMM\YukkuriMovieMaker.zip' -DestinationPath 'C:\Program files\YukkuriMovieMaker'"

echo �������MovieMaker���N�����Ă��܂��c
start C:\Program files\YukkuriMovieMaker\YukkuriMovieMaker.exe
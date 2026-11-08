@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion
title Spotify MP3 Downloader

:: Betigin calistigi klasoru ana dizin olarak sabitler (Klasor ve bosluk hatalarini onler)
cd /d "%~dp0"

set "YTDLP=yt-dlp.exe"

if not exist "%YTDLP%" (
    echo [HATA] yt-dlp.exe bulunamadi!
    echo Lutfen yt-dlp.exe dosyasini bu .bat dosyasi ile ayni klasore koyun.
    echo.
    pause
    exit
)

:start
cls
echo ===================================================
echo          SPOTIFY MP3 DOWNLOADER (TEK KLASOR)
echo ===================================================
echo.
set /p song_name="Sarki veya sanatci adi girin: "

if "%song_name%"=="" (
    echo.
    echo Gecerli bir sarki adi girmelisiniz!
    timeout /t 2 > nul
    goto start
)

echo.
echo En iyi 5 sonuc taraniyor...
echo ---------------------------------------------------

:: Sarki basliklarini ve direkt URL'lerini gecici dosyaya kaydeder
"%YTDLP%" "ytsearch5:%song_name%" --print "%%(title)s^|%%(webpage_url)s" --no-warnings > results.tmp

set count=0
for /f "delims=" %%a in (results.tmp) do (
    set /a count+=1
    set "line[!count!]=%%a"
    
    for /f "tokens=1,* delims=|" %%i in ("%%a") do (
        echo [!count!] %%i
    )
)

echo ---------------------------------------------------
if !count! EQU 0 (
    echo Sonuc bulunamadi!
    del results.tmp > nul 2>&1
    timeout /t 3 > nul
    goto start
)

echo.
set /p choice="Indirmek istediginiz sarkinin numarasini girin (1-5): "

set "chosen_line=!line[%choice%]!"
del results.tmp > nul 2>&1

if "%chosen_line%"=="" (
    echo Gecersiz secim!
    timeout /t 2 > nul
    goto start
)

for /f "tokens=1,* delims=|" %%i in ("%chosen_line%") do (
    set "target_url=%%j"
)

echo.
echo Indiriliyor ve bu klasora kaydediliyor...
echo ---------------------------------------------------

:: Secilen URL'yi dogrudan calisilan klasore indirir
"%YTDLP%" --extract-audio --audio-format mp3 --audio-quality 0 "%target_url%"

echo ---------------------------------------------------
echo.
echo Islem Tamamlandi! MP3 dosyasi bu klasore kaydedildi.
echo.
set /p again="Baska bir sarki indirmek ister misiniz? (E/H): "
if /i "%again%"=="E" goto start
if /i "%again%"=="e" goto start

echo.
echo Cikis yapiliyor...
timeout /t 2 > nul
exit
@echo off
chcp 65001 >nul
title FFmpeg Video Processor - Interactive Setup
setlocal EnableDelayedExpansion

REM ============================================
REM ПРОВЕРКА ВХОДНОГО ФАЙЛА
REM ============================================
set "input_file="
if "%~1"=="" (
    echo Использование:
    echo 1. Перетащите видеофайл на этот BAT-файл
    echo 2. Или запустите и укажите путь к файлу
    echo.
    set /p input_file="Введите путь к видеофайлу: "
    if "!input_file!"=="" (
        echo Файл не указан
        pause
        exit /b 1
    )
) else (
    set "input_file=%~1"
)

REM Проверяем существование файла
if not exist "%input_file%" (
    echo Файл не найден: "%input_file%"
    pause
    exit /b 1
)

REM Определяем имена файлов (на основе input_file, а не %1)
for %%I in ("%input_file%") do (
    set "input_dir=%%~dpI"
    set "input_name=%%~nxI"
    set "output_default=%%~dpnI_processed.mp4"
)

set "input_filename=!input_name!"
set "output_file="

echo ============================================
echo        FFMPEG VIDEO PROCESSOR
echo ============================================
echo Входной файл: !input_filename!
echo.

REM ============================================
REM НАСТРОЙКА ПАРАМЕТРОВ
REM ============================================
:configure_parameters
cls
echo ============================================
echo         НАСТРОЙКА ПАРАМЕТРОВ
echo ============================================
echo.

REM 1. Пресет кодирования
echo 1. Пресет кодирования (скорость/качество)
echo    ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
set /p preset="Введите пресет [ultrafast]: "
if "!preset!"=="" set "preset=ultrafast"

REM 2. Профиль H.264
echo.
echo 2. Профиль H.264
echo    baseline, main, high, high10, high422
set /p profile="Введите профиль [baseline]: "
if "!profile!"=="" set "profile=baseline"

REM 3. Уровень H.264
echo.
echo 3. Уровень H.264
echo    1.0, 1.1, 1.2, 1.3, 2.0, 2.1, 2.2, 3.0, 3.1, 3.2, 4.0, 4.1, 4.2, 5.0, 5.1, 5.2
set /p level="Введите уровень [1.0]: "
if "!level!"=="" set "level=1.0"

REM 4. FPS (кадров в секунду)
echo.
echo 4. Частота кадров (FPS)
echo    Например: 24, 25, 29.97, 30, 50, 60
set /p fps="Введите FPS [25]: "
if "!fps!"=="" set "fps=25"

REM 5. Битрейт видео
echo.
echo 5. Битрейт видео
echo    Примеры: 32k, 64k, 128k, 256k, 512k, 1M, 2M, 5M
set /p video_bitrate="Введите битрейт видео [32k]: "
if "!video_bitrate!"=="" set "video_bitrate=32k"

REM 6. Максимальный битрейт
echo.
echo 6. Максимальный битрейт (maxrate)
set /p maxrate="Введите максимальный битрейт [!video_bitrate!]: "
if "!maxrate!"=="" set "maxrate=!video_bitrate!"

REM 7. Размер буфера
echo.
echo 7. Размер буфера (bufsize)
echo    Обычно в 2 раза больше битрейта
set /p bufsize="Введите размер буфера [авто]: "
if "!bufsize!"=="" (
    REM Автоматический расчет на основе битрейта
    for /f "tokens=1 delims=kKmM" %%a in ("!video_bitrate!") do (
        set /a double=%%a * 2
        set "bufsize=!double!k"
    )
)

REM 8. Интервал между ключевыми кадрами (GOP)
echo.
echo 8. Интервал между ключевыми кадрами (GOP size)
echo    Рекомендуется: 2x FPS (например, для 25 FPS = 50)
set /p gop="Введите GOP size [999]: "
if "!gop!"=="" set "gop=999"

REM 9. Кодек аудио
echo.
echo 9. Кодек аудио
echo    libmp3lame, aac, libopus, copy (без перекодировки)
set /p audio_codec="Введите кодек аудио [libmp3lame]: "
if "!audio_codec!"=="" set "audio_codec=libmp3lame"

REM 10. Битрейт аудио
echo.
echo 10. Битрейт аудио
echo     Примеры: 16k, 32k, 64k, 96k, 128k, 192k, 256k, 320k
set /p audio_bitrate="Введите битрейт аудио [16k]: "
if "!audio_bitrate!"=="" set "audio_bitrate=16k"

REM 11. Частота дискретизации аудио
echo.
echo 11. Частота дискретизации аудио (Hz)
echo     22050, 44100, 48000, 96000
set /p audio_sample_rate="Введите частоту дискретизации [48000]: "
if "!audio_sample_rate!"=="" set "audio_sample_rate=48000"

REM 12. Количество аудио каналов
echo.
echo 12. Количество аудио каналов
echo      1 (моно), 2 (стерео), 6 (5.1)
set /p audio_channels="Введите количество каналов [2]: "
if "!audio_channels!"=="" set "audio_channels=2"

REM 13. Имя выходного файла
echo.
set "default_output=!output_default!"
echo 13. Имя выходного файла
set /p output_file="Введите путь выходного файла [!default_output!]: "
if "!output_file!"=="" set "output_file=!default_output!"

REM ============================================
REM ПОДТВЕРЖДЕНИЕ ПАРАМЕТРОВ
REM ============================================
cls
echo ============================================
echo        ПОДТВЕРЖДЕНИЕ ПАРАМЕТРОВ
echo ============================================
echo.
echo Входной файл:  !input_filename!
echo Выходной файл: !output_file!
echo.
echo ВИДЕО:
echo   Пресет:        !preset!
echo   Профиль:       !profile!
echo   Уровень:       !level!
echo   FPS:           !fps!
echo   Битрейт:       !video_bitrate!
echo   Maxrate:       !maxrate!
echo   Bufsize:       !bufsize!
echo   GOP:           !gop!
echo.
echo АУДИО:
echo   Кодек:         !audio_codec!
echo   Битрейт:       !audio_bitrate!
echo   Частота:       !audio_sample_rate! Hz
echo   Каналы:        !audio_channels!
echo.
if not "!extra_params!"=="" echo Доп. параметры: !extra_params!
echo.

choice /c YNR /m "Начать обработку с этими параметрами? (Y=Да, N=Настроить заново, R=Выход): "
if errorlevel 3 goto :eof
if errorlevel 2 goto configure_parameters

REM ============================================
REM ФОРМИРОВАНИЕ КОМАНДЫ FFMPEG
REM ============================================
cls
echo ============================================
echo        ЗАПУСК ОБРАБОТКИ
echo ============================================
echo.
echo Формирую команду FFmpeg...
echo.

set "ffmpeg_cmd=ffmpeg -i "!input_file!""
set "ffmpeg_cmd=!ffmpeg_cmd! -c:v libx264 -preset !preset!"
set "ffmpeg_cmd=!ffmpeg_cmd! -profile:v !profile! -level !level!"
set "ffmpeg_cmd=!ffmpeg_cmd! -r !fps!"
set "ffmpeg_cmd=!ffmpeg_cmd! -b:v !video_bitrate! -maxrate !maxrate! -bufsize !bufsize!"
set "ffmpeg_cmd=!ffmpeg_cmd! -g !gop!"
set "ffmpeg_cmd=!ffmpeg_cmd! -c:a !audio_codec! -b:a !audio_bitrate!"
set "ffmpeg_cmd=!ffmpeg_cmd! -ar !audio_sample_rate! -ac !audio_channels!"

REM Добавляем дополнительные параметры если есть
if not "!extra_params!"=="" (
    set "ffmpeg_cmd=!ffmpeg_cmd! !extra_params!"
)

set "ffmpeg_cmd=!ffmpeg_cmd! "!output_file!""

echo Команда FFmpeg:
echo !ffmpeg_cmd!
echo.
echo ============================================
echo.

REM ============================================
REM ВЫПОЛНЕНИЕ FFMPEG
REM ============================================
echo Начинаю обработку...
echo Это может занять некоторое время...
echo.

!ffmpeg_cmd!

if errorlevel 1 (
    echo.
    echo ОШИБКА при обработке файла!
    echo.
    echo Возможные причины:
    echo 1. Неправильные параметры
    echo 2. Недостаточно места на диске
    echo 3. Проблемы с исходным файлом
    echo.
    pause
    exit /b 1
)

REM ============================================
REM ЗАВЕРШЕНИЕ
REM ============================================
cls
echo ============================================
echo        ОБРАБОТКА ЗАВЕРШЕНА!
echo ============================================
echo.
echo УСПЕХ: Файл успешно обработан!
echo.
echo Входной файл:  !input_filename!
echo Выходной файл: !output_file!
echo.
echo Параметры обработки сохранены выше.
echo.
echo 1. Открыть папку с выходным файлом
echo 2. Запустить другой файл
echo 3. Выход
echo.

choice /c 123 /m "Выберите действие: "
if errorlevel 3 goto :eof
if errorlevel 2 (
    REM Очистка переменных и перезапуск настройки параметров
    set "preset="
    set "profile="
    set "level="
    set "fps="
    set "video_bitrate="
    set "maxrate="
    set "bufsize="
    set "gop="
    set "audio_codec="
    set "audio_bitrate="
    set "audio_sample_rate="
    set "audio_channels="
    set "extra_params="
    set "output_file="
    goto :configure_parameters
)

if errorlevel 1 (
    REM Открываем папку с файлом
    explorer.exe /select,"!output_file!"
    timeout /t 2 /nobreak >nul
)

echo.
echo Нажмите любую клавишу для выхода...
pause >nul
endlocal
exit /b 0

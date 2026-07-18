@echo off
@chcp 866
rem ================================
rem Purpose: Сброс настроек Liftoff
rem Author:  Dray001
rem Version: 1.5
rem ================================
:restart? 
cls
title Liftoff Reset
set "LOCAL_VERSION=1.5"
set "D=%date%"
set "T=%time%"
set "DAY=%d:~0,2%"
set "MONTH=%d:~3,2%"
set "YEAR=%d:~8,2%"
set "TIME_STR=%t:~0,8%"
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/Dray4747/Liftoff-Reset/main/version.txt"
set "GITHUB_KEY_URL=https://raw.githubusercontent.com/Dray4747/Liftoff-Reset/main/protection"
set "GITHUB_RELEASE_URL=https://github.com/Dray4747/Liftoff-Reset/releases/tag/"
set "GITHUB_DOWNLOAD_URL=https://github.com/Dray4747/Liftoff-Reset/releases/latest"
set "CONFIG=config.ini"
set "CREATEDCFG=false"
set "CREATEDFOLDER=false"
set "NHCOLOREXIST=true"

:: ============= Создание файла настроек =================
cd "C:\Liftoff\Liftoff_Data\Config\"
if not exist "C:\Liftoff\Liftoff_Data\Config\" (
	rem LINT:IGNORE W025
	mkdir "C:\Liftoff\Liftoff_Data\Config\"
	set "CREATEDFOLDER=true"
)
if not exist "C:\Liftoff\Liftoff_Data\Config\%CONFIG%" (
	(
		echo debug=false
		echo nhcolor=%APPDATA%\nhcolor.exe
		echo Folder=C:\Liftoff
		echo Liftoff=liftoff.exe
		echo config.xml=config.xml
		echo frconfig.xml=frconfig.xml
	) > "%CONFIG%"
	set "CREATEDCFG=true"
)
::================== Чтение кфг файла ====================
cd "C:\Liftoff\Liftoff_Data\Config\"
for /F "tokens=1* delims==" %%a in (config.ini) do (
	set "%%a=%%b"
)
if /i "%~1"=="debug" (
	set "debug=true"
)
if "%debug%"=="true" (
	set "lt=[%day%.%month%.%year% %time_str%] "
) else (
	set lt=""
)
if "%nhcolor%"=="" (
	set "NHCOLOR=%APPDATA%\nhcolor.exe"
	set "NHCOLOREXIST=false"
)
if /i "%~1"=="debug" (
	%nhcolor% 03 %lf% [DEBUG] Задан параметр запуска: -debug. | %nhcolor% 03,DEBUG
)
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Включен режим отладки. | %nhcolor% 03,DEBUG
)
::================= Запуск | Step 1/3 ====================
if "%NHCOLOREXIST%"=="false" if "%debug%"=="true" (
	%NHCOLOR% 07 %LT%[DEBUG] Параметр nhcolor не указан или указан неверно. | %nhcolor% 03,DEBUG
)
if "%CREATEDFOLDER%"=="true" (
	%NHCOLOR% 0e %lt%[WARN] Папка C:\Liftoff\ не найдена. Она была создана автоматически.
	timeout 3 /nobreak > nul
)
if "%CREATEDCFG%"=="true" (
	%NHCOLOR% 07 %lt%[INFO] Создан файл конфигурации. Для настройки используйте %CONFIG% | %NHCOLOR% 02,INFO
	%NHCOLOR% 07 %lt%[INFO] Перезапуск через 5 секунд.. | %NHCOLOR% 02,INFO
	timeout 5 /nobreak > nul
	goto restart?
)
::================= Запуск | Step 2/3 ====================
cd /d "%Folder%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
	%NHCOLOR% 0c %lt%[ERROR] Проверка входа отклонена. Указанный раздел не найден.
)
if not exist "%Folder%\KEY" (
	if "%debug%"=="true" (
		%NHCOLOR% 07 %lt%[DEBUG] Ключ авторизации не найден. %Folder%\KEY| %nhcolor% 03,DEBUG 
	)
	%NHCOLOR% 0c %lt%[ERROR] Проверка входа отклонена. Отсутствует ключ авторизации.
	%NHCOLOR% 07 ============================================================
	%NHCOLOR% 02 %lt%[INFO] Вы можете запросить разрешение на запуск, продолжить? | %NHCOLOR% 02,INFO
	pause
	goto server_key
)
set /p key=<KEY
if not "%key%" == "Андрей Борисович" (
	%NHCOLOR% 0c %lt%[ERROR] Проверка входа отклонена. Неверный ключ авторизации.
	%NHCOLOR% 07 ============================================================
	%NHCOLOR% 02 %lt%[INFO] Вы можете запросить разрешение на запуск, продолжить? | %NHCOLOR% 02,INFO
	pause
	goto server_key
)
::================= Запуск | Step 3/3 ====================
:KEY_ALLOWED
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Отправка запроса серверу. %GITHUB_VERSION_URL% | %NHCOLOR% 03,DEBUG
)
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Ответ сервера: %GITHUB_VERSION% | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] Локальная версия: %LOCAL_VERSION% | %nhcolor% 03,DEBUG
)
if "%GITHUB_VERSION%"=="" (
	%NHCOLOR% 0e %lt%Не удалось проверить наличие обновлений.
	goto Menu
) else if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
	%NHCOLOR% 07 %lt%Установлена последняя версия: %LOCAL_VERSION%
	goto Menu
) else (
	%NHCOLOR% 02 %lt%Найдена новая версия: %GITHUB_VERSION%
	%NHCOLOR% 07 %lt%Скачать: %GITHUB_RELEASE_URL%%GITHUB_VERSION%
)
:: =================== ГЛАВНОЕ МЕНЮ ===================
:Menu
%NHCOLOR% 07 ---------------------------------
%NHCOLOR% 03 Сброс настроек Liftoff. Автор: Dray001.
%NHCOLOR% 03 GitHub: github.com/Dray4747/Liftoff-Reset
%NHCOLOR% 07 ---------------------------------
if "%NHCOLOREXIST%"=="false" (
	%NHCOLOR% 0e %lt%[WARN] Путь к файлу nhcolor не задан. Используйте %CONFIG% для настройки.
)
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Отладка файла конфигурации... %config% | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] =====================         | %nhcolor% 03,DEBUG 09,=====================
	%NHCOLOR% 07 %lt%[DEBUG] nhcolor = %nhcolor%           | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] Папка = %Folder%              | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] Файл Liftoff = %Liftoff%      | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] Config.xml = %config.xml%     | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] frconfig.xml = %frconfig.xml% | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] =====================         | %nhcolor% 03,DEBUG 09,=====================
)
:: =================== Поиск и выключение Liftoff. ===================
%NHCOLOR% 07 %lt%[INFO] Попытка завершения работы Liftoff.. | %NHCOLOR% 02,INFO
REM LINT:IGNORE W043, SEC015
taskkill /f /im "%liftoff%" >nul 2>&1

if %ERRORLEVEL% equ 0 (
	%NHCOLOR% 07 %lt%[INFO] Liftoff успешно завершил работу. | %NHCOLOR% 02,INFO
) else if %ERRORLEVEL% equ 128 (
	%NHCOLOR% 07 %lt%[INFO] Процесс Liftoff не найден. | %NHCOLOR% 02,INFO
) else if %ERRORLEVEL% equ 1 (
	%NHCOLOR% 0c %lt%[ERROR] Произошла ошибка при попытке завершить работу Liftoff.
)
:: =================== Поиск и вход в директорию Liftoff. ===================
cd /d "%Folder%\Liftoff_Data\Config" >nul 2>&1
if %ERRORLEVEL% neq 0 (
	%NHCOLOR% 0c %lt%[ERROR] Не удается найти раздел: %Folder%\Liftoff_Data\Config
	pause
	exit /b 1
)

:: =================== ПРОВЕРКА ФАЙЛА SYSTEM.XML ===================
if not exist System.xml (
	if "%debug%"=="false" (
		cls
	)
	if "%debug%"=="true" (
		echo.
		%NHCOLOR% 07 %lt%[DEBUG] System.xml не найден. Путь: %Folder%\Liftoff_Data\System.xml | %nhcolor% 03,DEBUG
		echo.
	)
	%NHCOLOR% 07 Обнаружено нарушение целостности работы системы.
	%NHCOLOR% 07 Запуск системы устранения неполадок..
	%NHCOLOR% 07 ==========================================================
	%NHCOLOR% 0c Файл System.xml не найден. Запуск Liftoff невозможен. 
	%NHCOLOR% 0e Файл конфигурации будет скопирован с %frconfig.xml%, продолжить?
	pause
	goto recovery
) else goto copy
:: =================== ОПЕРАЦИЯ КОПИРОВАНИЯ ===================
:copy
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Копирование %config.xml% на System.xml. Путь: %Folder%\Liftoff_Data\Config | %NHCOLOR% 03,DEBUG
)
copy /y "%config.xml%" "System.xml" >nul 2>&1
set "RC=%ERRORLEVEL%"
if %RC% GEQ 1 (
	%NHCOLOR% 0e %lt%[WARN] Файл конфигурации config.xml не найден, пропуск..
	timeout 3 >nul
	goto Liftoff
) else (
%NHCOLOR% 07 %lt%[INFO] Файл заменен успешно. | %NHCOLOR% 02,INFO
)
:: =================== Запуск Liftoff. ===================
:Liftoff
%NHCOLOR% 07 %lt%[INFO] Запуск Liftoff.. | %NHCOLOR% 02,INFO
if "%debug%"=="True" (
	%NHCOLOR% 07 %lt%[DEBUG] Файл: %Liftoff% Путь: %Folder% | %NHCOLOR% 03,DEBUG
)
cd %Folder%
if not exist %liftoff% (
	%NHCOLOR% 0c %lt%[ERROR] Файл %liftoff% не найден. Запуск Liftoff невозможен.
	pause
	exit /b 1
)
start %liftoff%
%NHCOLOR% 02 Операция, запрошенная пользователем, завершена.

:: Пауза в случае: 2. Новая версия.  1. Версия не найдена.
if not defined GITHUB_VERSION (                                     
	timeout 10 /nobreak > nul 	
	exit /b 1
)
if not "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
	timeout 10 /nobreak > nul 
	exit /b 1
)
timeout 3 /nobreak > nul 
exit /b 1

:: ВОСCТАНОВЛЕНИЕ
:recovery
%NHCOLOR% 07 Запуск восcтановления... 
cd /d "%Folder%\Liftoff_Data\Config" >nul 2>&1
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Путь: %Folder%\Liftoff_Data\Config | %nhcolor% 03,DEBUG
)
if %ERRORLEVEL% neq 0 (
	%NHCOLOR% 0c %lt%[ERROR] Не удается найти раздел: %Folder%\Liftoff_Data\Config
	%NHCOLOR% 0e %lt%[WARN] Завершение работы..
	pause
	exit /b 1
)
if not exist %frconfig.xml% (
	%NHCOLOR% 0c %lt%[ERROR] Файл frconfig.xml не найден.
	%NHCOLOR% 0c %lt%[ERROR] Системе восстановления не удалось выполнить запрошенную операцию.
	%NHCOLOR% 02 %lt%[INFO] Лог файл создан в %Folder%\Liftoff_Data\Config
	set "lt=[%day%.%month%.%year% %time_str%] "
	ECHO %lt% File frconfig.xml not found. FILE: %frconfig.xml% > log.txt
	pause
	exit /b 1
) else (
	%NHCOLOR% 07 Файл %frconfig.xml% найден, восстановление..
	goto rec_if_ok
)

:rec_if_ok
:: Операция копирования.
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Копирование. Из %frconfig.xml% в System.xml | %NHCOLOR% 03,DEBUG
)
copy /y "%frconfig.xml%" "System.xml" >nul 2>&1
set "RC=%ERRORLEVEL%"
if %RC% GEQ 1 goto :copy_err
%NHCOLOR% 07 [INFO] Файл заменен успешно! Перезапуск.. | %NHCOLOR% 02,INFO
timeout 5 /nobreak > nul
goto restart?
:server_key
%NHCOLOR% 02 %lt%[INFO] Подключение к серверу.. | %NHCOLOR% 02,INFO

if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Отправка запроса серверу. %GITHUB_KEY_URL% | %NHCOLOR% 03,DEBUG
)

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%GITHUB_KEY_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_KEY=%%A"
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Ответ сервера: %GITHUB_KEY% | %NHCOLOR% 03,DEBUG
)
if "%GITHUB_KEY%"=="" (
	%NHCOLOR% 0e "%lt%[WARN] Не удалось установить соединение с сервером. (Таймаут)"
	timeout 5 /nobreak > nul
	exit /b 1
) else if "%GITHUB_KEY%"=="yes" (
	%NHCOLOR% 0с %lt%[INFO] Ответ получен: ОК   | %NHCOLOR% 02,INFO 02,ОК
	%NHCOLOR% 02 %lt%Перезапуск..
	
	if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] ПЕРЕЗАПУСК. 5 секунд. | %NHCOLOR% 03,DEBUG
)
	timeout 5 /nobreak > nul
	cls
	goto KEY_ALLOWED
) else (
	%NHCOLOR% 0c %lt%[ERROR] Сервер отклонил входящий запрос.
	timeout 5 /nobreak > nul
	REM LINT:IGNORE W001
	exit /b 0
)

::[Bat To Exe Converter]
::
::fBE1pAF6MU+EWHreyHcjLQlHcACQPXLuOpEZ++Pv4Pq7Er+stVLqMbPV0reBLO8BpED8cPY=
::YAwzoRdxOk+EWAjk
::fBw5plQjdCuDJGyQ/U4jFDlVWES2MyufHrAg4aby7OXn
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF25
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF25
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpSI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFB9GTR3WAE+/Fb4I5/jHw+OBtkIbUqw6YIq7
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
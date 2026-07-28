@echo off
@chcp 866 >nul
rem ================================
rem Purpose:  Сброс настроек Liftoff
rem Author:   Dray001
rem Version:  1.5
rem Encoding: CP866
rem ================================
rem equ	равно				==
rem neq	не равно			!=
rem lss	меньше				<
rem leq	меньше или равно	<=
rem gtr	больше				>
rem geq	больше или равно	>=

set "CHECK_NHCOLOR=true"
:restart? 
cls
title Liftoff Reset
set "LOCAL_VERSION=1.5a"
set "D=%date%"
set "T=%time%"
set "DAY=%d:~0,2%"
set "MONTH=%d:~3,2%"
set "YEAR=%d:~8,2%"
set "TIME_STR=%t:~0,8%"
set "EXIT_CODE=0"
set "GITHUB_VERSION_URL=raw.githubusercontent.com/Dray4747/Liftoff-Reset/main/version.txt"
set "GITHUB_KEY_URL=raw.githubusercontent.com/Dray4747/Liftoff-Reset/main/protection"
set "GITHUB_RELEASE_URL=github.com/Dray4747/Liftoff-Reset/releases/tag/"
set "GITHUB_DOWNLOAD_URL=github.com/Dray4747/Liftoff-Reset/releases/latest"

set "CONFIG=config.ini"
set "CHECK_CONFIG=true"
set "CHECK_FOLDER=true"

:: ============= Создание файла настроек =================
if not exist "C:\Liftoff\Liftoff_Data\Config\" (
	REM LINT:IGNORE W025
	mkdir "C:\Liftoff\Liftoff_Data\Config\"
	set "CHECK_FOLDER=false"
)
cd "C:\Liftoff\Liftoff_Data\Config\"
if not exist "C:\Liftoff\Liftoff_Data\Config\%CONFIG%" (
	(
		echo debug=false
		echo nhcolor=%APPDATA%\nhcolor.exe
		echo Folder=C:\Liftoff
		echo Liftoff=liftoff.exe
		echo config.xml=config.xml
		echo frconfig.xml=frconfig.xml
		echo IGNORE_CODES=
	) > "%CONFIG%"
	set "CHECK_CONFIG=false"
)
::================== Чтение кфг файла ====================
cd /d "C:\Liftoff\Liftoff_Data\Config\"
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
	set "CHECK_NHCOLOR=false"
)
if /i "%~1"=="debug" (
	call :dbg "Задан параметр запуска: debug." 
)
call :dbg "Включен режим отладки." 

::================= Запуск | Step 1/3 ====================
if "%CHECK_NHCOLOR%"=="false" (
	call :dbg "Параметр nhcolor не указан."
)
if "%CHECK_FOLDER%"=="false" (
	%NHCOLOR% 0e %lt%[WARN] Папка C:\Liftoff\ не найдена. Она была создана автоматически.
	timeout 3 /nobreak > nul
)
if "%CHECK_CONFIG%"=="false" (
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
	call :dbg "Ключ авторизации не найден. %Folder%\KEY"
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
call :dbg "Отправка запроса серверу. %GITHUB_VERSION_URL%"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

call :dbg "Ответ сервера: %GITHUB_VERSION%"
call :dbg "Локальная версия: %LOCAL_VERSION%"

if "%GITHUB_VERSION%"=="" (
	%NHCOLOR% 0e %lt%Не удалось проверить наличие обновлений.
	set "EXIT_CODE=1"
	goto Menu
) else if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
	%NHCOLOR% 07 %lt%Установлена актуальная версия: %LOCAL_VERSION%
	goto Menu
) else (
	%NHCOLOR% 02 %lt%Доступна новая версия: %GITHUB_VERSION%
	%NHCOLOR% 07 %lt%Скачать: %GITHUB_RELEASE_URL%%GITHUB_VERSION%
	set "EXIT_CODE=2"
)
:: =================== ГЛАВНОЕ МЕНЮ ===================
:Menu
%NHCOLOR% 07 ---------------------------------
%NHCOLOR% 03 Сброс настроек Liftoff. Автор: Dray001.
%NHCOLOR% 03 GitHub: github.com/Dray4747/Liftoff-Reset
%NHCOLOR% 07 ---------------------------------
if "%CHECK_NHCOLOR%"=="false" (
	%NHCOLOR% 0e %lt%[WARN] Путь к файлу nhcolor не задан. Используйте %CONFIG% для настройки.
)
if "%debug%"=="true" (
	%NHCOLOR% 07 %lt%[DEBUG] Отладка файла конфигурации... %config% | %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] =====================			| %nhcolor% 03,DEBUG 09,=====================
	%NHCOLOR% 07 %lt%[DEBUG] nhcolor      = %nhcolor%		| %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] Папка        = %Folder%		| %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] Файл Liftoff = %Liftoff%		| %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] Config.xml   = %config.xml%	| %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] frconfig.xml = %frconfig.xml%	| %nhcolor% 03,DEBUG 
	%NHCOLOR% 07 %lt%[DEBUG] =====================			| %nhcolor% 03,DEBUG 09,=====================
	%NHCOLOR% 07 %lt%[DEBUG] NHCOLOR = %CHECK_NHCOLOR%		| %nhcolor% 03,DEBUG 0c,False 0a,True
	%NHCOLOR% 07 %lt%[DEBUG] =====================			| %nhcolor% 03,DEBUG 09,=====================
)
if not "%Folder%"=="C:\Liftoff" (
	call :warn_ignore W001
	call :dbg "Папка: %Folder%"
	if "%CODE_IGNORED%"=="false" (
		%nhcolor% 0e %lt%[WARN] Внимание: Не удаляйте папку C:\Liftoff\Liftoff_Data\Config
		%nhcolor% 0e %lt%[WARN] Чтобы скрыть предупреждение, читайте инструкцию на сайте.
	)
)
:: =================== Поиск и выключение Liftoff. ===================
%NHCOLOR% 07 %lt%[INFO] Завершение работы Liftoff.. | %NHCOLOR% 02,INFO
REM LINT:IGNORE W043, SEC015
taskkill /f /im "%liftoff%" >nul 2>&1

if %ERRORLEVEL% equ 0 (
	%NHCOLOR% 07 %lt%[INFO] Liftoff успешно завершил работу. | %NHCOLOR% 02,INFO
) else if %ERRORLEVEL% equ 128 (
	%NHCOLOR% 07 %lt%[INFO] Процесс %Liftoff% не найден. | %NHCOLOR% 02,INFO
) else if %ERRORLEVEL% equ 1 (
	%NHCOLOR% 0c %lt%[ERROR] Произошла ошибка при завершении работы %Liftoff%.
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
	%NHCOLOR% 07 ==========================================================
	%NHCOLOR% 0c Файл System.xml не найден. Запуск Liftoff невозможен. 
	%NHCOLOR% 0e Файл конфигурации будет скопирован с %frconfig.xml%, продолжить?
	pause
	goto recovery
) else goto copy
:: =================== ОПЕРАЦИЯ КОПИРОВАНИЯ ===================
:copy

call :dbg "Копирование из %config.xml% в System.xml. Путь: %Folder%\Liftoff_Data\Config"
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
call :dbg "Файл: %Liftoff% Путь: %Folder% "

cd %Folder%
if not exist %liftoff% (
	%NHCOLOR% 0c %lt%[ERROR] Файл %liftoff% не найден. Запуск Liftoff невозможен.
	pause
	exit /b 1
)
call :dbg "Запуск %liftoff%"
start %liftoff%
%NHCOLOR% 02 Операция, запрошенная пользователем, завершена.

:: EXIT CODES: 0=OK 1=5s 2=10s 3=PAUSE
call :dbg "EXIT CODE: %EXIT_CODE%"

if "%EXIT_CODE%"=="0" set "EXIT_T=3"
if "%EXIT_CODE%"=="1" set "EXIT_T=5"
if "%EXIT_CODE%"=="2" set "EXIT_T=10"
if "%EXIT_CODE%"=="3" set "EXIT_T=PAUSE"
if not defined EXIT_T set "EXIT_T=3"

if "%EXIT_T%"=="PAUSE" (
	call :dbg "Пауза."
	pause >nul
	exit
) else (
	call :dbg "Пауза на %EXIT_T% сек."
	timeout /t %EXIT_T% /nobreak >nul
	exit
)
call :dbg АВАРИЙНЫЙ ВЫХОД
exit /b 

:: ВОСCТАНОВЛЕНИЕ
:recovery
%NHCOLOR% 07 Запуск восстановления... 
cd /d "%Folder%\Liftoff_Data\Config" >nul 2>&1
call :dbg "Путь: %Folder%\Liftoff_Data\Config"

if %ERRORLEVEL% neq 0 (
	%NHCOLOR% 0c %lt%[ERROR] Не удается найти раздел: %Folder%\Liftoff_Data\Config
	pause
	exit /b 1
)
if not exist %frconfig.xml% (
	call :dbg "%frconfig.xml% не найден. Путь: %Folder%\Liftoff_Data\Config"
	%NHCOLOR% 0c %lt%[ERROR] Файл %frconfig.xml% не найден.
	%NHCOLOR% 07 %lt%[INFO] Лог файл создан в %Folder%\Liftoff_Data\Config | %nhcolor% 02,INFO
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

call :dbg "Копирование из %frconfig.xml% в System.xml"

copy /y "%frconfig.xml%" "System.xml" >nul 2>&1
set "RC=%ERRORLEVEL%"

if %RC% GEQ 1 goto :copy_err
%NHCOLOR% 07 [INFO] Файл заменен успешно! Перезапуск.. | %NHCOLOR% 02,INFO
timeout 5 /nobreak > nul
goto restart?

:server_key
%NHCOLOR% 02 %lt%[INFO] Подключение к серверу.. | %NHCOLOR% 02,INFO
call :dbg "Отправка запроса серверу. %GITHUB_KEY_URL%"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%GITHUB_KEY_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_KEY=%%A"
call :dbg "Ответ сервера: %GITHUB_KEY%"

if "%GITHUB_KEY%"=="" (
	%NHCOLOR% 0e "%lt%[WARN] Не удалось установить соединение с сервером. (Таймаут)"
	timeout 5 /nobreak > nul
	exit /b 1
) else if "%GITHUB_KEY%"=="yes" (
	%NHCOLOR% 0с %lt%[INFO] Ответ получен: ОК	| %NHCOLOR% 02,INFO 02,ОК
	%NHCOLOR% 02 %lt%Перезапуск..
	timeout 5 /nobreak > nul
	cls
	goto KEY_ALLOWED
) else (
	%NHCOLOR% 0c %lt%[ERROR] Сервер отклонил входящий запрос.
	timeout 5 /nobreak > nul
	REM LINT:IGNORE W001
	exit /b 0
)

:dbg
if /i "%debug%"=="true" (
	REM LINT:IGNORE W001
	%NHCOLOR% 07 %lt%[DEBUG] %~1 | %nhcolor% 03,DEBUG
)

:warn_ignore
setlocal
set "CODE_TO_CHECK=%~1"
set "IGNORE_LIST=%IGNORE_CODES%"
set "CODE_IGNORED=false"

if "%IGNORE_LIST%"=="" (
	endlocal & set "CODE_IGNORED=false"
	exit /b
)

for %%i in (%IGNORE_LIST%) do (
	if "%%i"=="%CODE_TO_CHECK%" (
		endlocal & set "CODE_IGNORED=true"
		exit /b
	)
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
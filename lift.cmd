@echo off
@chcp 866 >nul
rem ================================
rem Purpose:  Сброс настроек Liftoff
rem Author:   Dray001
rem Version:  1.6
rem Encoding: CP866
rem ================================
rem equ	равно				==
rem neq	не равно			!=
rem lss	меньше				<
rem leq	меньше или равно	<=
rem gtr	больше				>
rem geq	больше или равно	>=
set "CHECK_NHCOLOR=true"
set "CHECK_FSTART=true"
:restart? 
cls
title Liftoff Reset
set "LOCAL_VERSION=1.6"
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
		echo DEBUG=false
		echo NHCOLOR=%APPDATA%\nhcolor.exe
		echo FOLDER=C:\Liftoff
		echo LIFTOFF=Liftoff.exe
		echo CONFIG=config.xml
		echo FRCONFIG=frconfig.xml
		echo CHECK_UPDATES=false
		echo IGNORE_CODES=
	) > "%CONFIG%"
	set "CHECK_CONFIG=false"
)
::================== Чтение кфг файла ====================
cd /d "C:\Liftoff\Liftoff_Data\Config\"
for /F "tokens=1* delims==" %%a in (config.ini) do (
	set "%%a=%%b"
)
if /i "%~1"=="DEBUG" (
	set "DEBUG=true"
)
if "%DEBUG%"=="true" (
	set "LT=[%day%.%month%.%year% %time_str%] "
) else (
	set LT=""
)
if "%NHCOLOR%"=="" (
	set "NHCOLOR=%APPDATA%\nhcolor.exe"
	set "CHECK_NHCOLOR=false"
)
if /i "%~1"=="DEBUG" (
	call :dbg "Задан параметр запуска: DEBUG." 
)
call :dbg "Включен режим отладки." 

::================= Запуск | Step 1/3 ====================
if "%CHECK_NHCOLOR%"=="false" (
	call :dbg "Параметр nhcolor не указан."
)
if "%CHECK_FOLDER%"=="false" (
	%NHCOLOR% 0e %LT%[WARN] Папка C:\Liftoff\ не найдена. Она была создана автоматически.
	timeout 3 /nobreak > nul
)
if "%CHECK_CONFIG%"=="false" (
	%NHCOLOR% 07 %LT%[INFO] Создан файл конфигурации. Для настройки используйте %CONFIG% | %NHCOLOR% 02,INFO
	%NHCOLOR% 07 %LT%[INFO] Перезапуск через 5 секунд.. | %NHCOLOR% 02,INFO
	timeout 5 /nobreak > nul
	goto restart?
)
::================= Запуск | Step 2/3 ====================
cd /d "%FOLDER%" >nul 2>&1
if %ERRORLEVEL% neq 0 (
	%NHCOLOR% 0c %LT%[ERROR] Проверка входа отклонена. Указанный раздел не найден.
)
if not exist "%FOLDER%\KEY" (
	call :dbg "Ключ авторизации не найден. %FOLDER%\KEY"
	%NHCOLOR% 0c %LT%[ERROR] Проверка входа отклонена. Отсутствует ключ авторизации.
	%NHCOLOR% 07 ============================================================
	%NHCOLOR% 02 %LT%[INFO] Вы можете запросить разрешение на запуск, продолжить? | %NHCOLOR% 02,INFO
	pause
	goto server_KEY
)
set /p KEY=<KEY
if not "%KEY%" == "Андрей Борисович" (
	%NHCOLOR% 0c %LT%[ERROR] Проверка входа отклонена. Неверный ключ авторизации.
	%NHCOLOR% 07 ============================================================
	%NHCOLOR% 02 %LT%[INFO] Вы можете запросить разрешение на запуск, продолжить? | %NHCOLOR% 02,INFO
	pause
	goto server_KEY
)
::================= Запуск | Step 3/3 ====================
:KEY_ALLOWED
if "%CHECK_UPDATES%"=="true" (
	call :CHECK_UPDATES
	goto Menu
) else (
	%NHCOLOR% 07 %LT%Проверка обновлений отключена.
	goto Menu
)
:: =================== ГЛАВНОЕ МЕНЮ ===================
:Menu
%NHCOLOR% 07 ---------------------------------
%NHCOLOR% 03 Сброс настроек Liftoff. Автор: Dray001.
%NHCOLOR% 03 GitHub: github.com/Dray4747/Liftoff-Reset
%NHCOLOR% 07 ---------------------------------
if "%CHECK_NHCOLOR%"=="false" (
	%NHCOLOR% 0e %LT%[WARN] Путь к файлу NHCOLOR не задан. Используйте %CONFIG% для настройки.
)
if "%DEBUG%"=="true" (
	%NHCOLOR% 07 %LT%[DEBUG] Отладка файла конфигурации... %config% | %NHCOLOR% 03,DEBUG 
	%NHCOLOR% 07 %LT%[DEBUG] =====================			| %NHCOLOR% 03,DEBUG 09,=====================
	%NHCOLOR% 07 %LT%[DEBUG] nhcolor      = %NHCOLOR%		| %NHCOLOR% 03,DEBUG 
	%NHCOLOR% 07 %LT%[DEBUG] Папка        = %FOLDER%		| %NHCOLOR% 03,DEBUG 
	%NHCOLOR% 07 %LT%[DEBUG] Файл Liftoff = %LIFTOFF%		| %NHCOLOR% 03,DEBUG 
	%NHCOLOR% 07 %LT%[DEBUG] Config       = %CONFIG%		| %NHCOLOR% 03,DEBUG 
	%NHCOLOR% 07 %LT%[DEBUG] frconfig     = %FRCONFIG%		| %NHCOLOR% 03,DEBUG 
	%NHCOLOR% 07 %LT%[DEBUG] =====================			| %NHCOLOR% 03,DEBUG 09,=====================
	%NHCOLOR% 07 %LT%[DEBUG] NHCOLOR = %CHECK_NHCOLOR%		| %NHCOLOR% 03,DEBUG 0c,False 0a,True
	%NHCOLOR% 07 %LT%[DEBUG] FSTART  = %CHECK_FSTART%		| %NHCOLOR% 03,DEBUG 0c,False 0a,True
	%NHCOLOR% 07 %LT%[DEBUG] CHKUPD  = %CHECK_UPDATES%		| %NHCOLOR% 03,DEBUG 0e,False 0a,True
	%NHCOLOR% 07 %LT%[DEBUG] =====================			| %NHCOLOR% 03,DEBUG 09,=====================
)
if not "%FOLDER%"=="C:\Liftoff" (
	call :warn_ignore W001
	call :dbg "Папка: %FOLDER%"
	if "%CODE_IGNORED%"=="false" (
		%NHCOLOR% 0e %LT%[WARN] Внимание: Не удаляйте папку C:\Liftoff\Liftoff_Data\Config
		%NHCOLOR% 0e %LT%[WARN] Чтобы скрыть предупреждение, читайте инструкцию на сайте.
	)
)
:: =================== Поиск и выключение Liftoff. ===================
%NHCOLOR% 07 %LT%[INFO] Завершение работы Liftoff.. | %NHCOLOR% 02,INFO
REM LINT:IGNORE W043, SEC015
taskkill /f /im "%LIFTOFF%" >nul 2>&1

if %ERRORLEVEL% equ 0 (
	%NHCOLOR% 07 %LT%[INFO] Liftoff успешно завершил работу. | %NHCOLOR% 02,INFO
) else if %ERRORLEVEL% equ 128 (
	%NHCOLOR% 07 %LT%[INFO] Процесс %LIFTOFF% не найден. | %NHCOLOR% 02,INFO
) else if %ERRORLEVEL% equ 1 (
	%NHCOLOR% 0c %LT%[ERROR] Произошла ошибка при завершении работы %LIFTOFF%.
)
:: =================== Поиск и вход в директорию Liftoff. ===================
cd /d "%FOLDER%\Liftoff_Data\Config" >nul 2>&1
if %ERRORLEVEL% neq 0 (
	%NHCOLOR% 0c %LT%[ERROR] Не удается найти раздел: %FOLDER%\Liftoff_Data\Config
	pause
	exit /b 1
)

:: =================== ПРОВЕРКА ФАЙЛА SYSTEM.XML ===================
if not exist System.xml (
	if "%DEBUG%"=="false" (
		cls
	)
	if "%DEBUG%"=="true" (
		echo.
		%NHCOLOR% 07 %LT%[DEBUG] System.xml не найден. Путь: %FOLDER%\Liftoff_Data\System.xml | %NHCOLOR% 03,DEBUG
		echo.
	)
	%NHCOLOR% 07 ==========================================================
	%NHCOLOR% 0c Файл System.xml не найден. Запуск Liftoff невозможен. 
	%NHCOLOR% 0e Файл конфигурации будет скопирован с %FRCONFIG%, продолжить?
	pause
	goto recovery
) else goto copy
:: =================== ОПЕРАЦИЯ КОПИРОВАНИЯ ===================
:copy
if "%CHECK_FSTART%"=="false" (
	call :dbg "Параметр FSTART не прошел проверку, ПРОПУСК копирования."
	%NHCOLOR% 0e %lt%[WARN] Настройки не заменены. Это первый запуск.
	goto LIFTOFF
)
call :dbg "Копирование из %CONFIG% в System.xml. Путь: %FOLDER%\Liftoff_Data\Config"
copy /y "%CONFIG%" "System.xml" >nul 2>&1
set "RC=%ERRORLEVEL%"

if %RC% GEQ 1 (
	%NHCOLOR% 0e %LT%[WARN] Файл конфигурации %CONFIG% не найден, пропуск..
	timeout 3 >nul
	goto Liftoff
) else (
%NHCOLOR% 07 %LT%[INFO] Файл заменен успешно. | %NHCOLOR% 02,INFO
)
:: =================== Запуск Liftoff. ===================
:LIFTOFF
%NHCOLOR% 07 %LT%[INFO] Запуск Liftoff.. | %NHCOLOR% 02,INFO
call :dbg "Файл: %LIFTOFF% Путь: %FOLDER% "

cd %FOLDER%
if not exist %LIFTOFF% (
	%NHCOLOR% 0c %LT%[ERROR] Файл %LIFTOFF% не найден. Запуск Liftoff невозможен.
	pause
	exit /b 1
)
call :dbg "Запуск %LIFTOFF%"
start %LIFTOFF%
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
cd /d "%FOLDER%\Liftoff_Data\Config" >nul 2>&1
call :dbg "Путь: %FOLDER%\Liftoff_Data\Config"

if %ERRORLEVEL% neq 0 (
	%NHCOLOR% 0c %LT%[ERROR] Не удается найти раздел: %FOLDER%\Liftoff_Data\Config
	pause
	exit /b 1
)
if not exist %FRCONFIG% (
	call :dbg "%FRCONFIG% не найден. Путь: %FOLDER%\Liftoff_Data\Config"
	%NHCOLOR% 0c %LT%[ERROR] Файл %FRCONFIG% не найден.
	%NHCOLOR% 07 %LT%[INFO] Лог файл создан в %FOLDER%\Liftoff_Data\Config | %NHCOLOR% 02,INFO
	set "LT=[%day%.%month%.%year% %time_str%] "
	ECHO %LT% File frconfig not found. FILE: %FRCONFIG% > log.txt
	pause
	exit /b 1
) else (
	%NHCOLOR% 07 Файл %FRCONFIG% найден, восстановление..
	goto rec_if_ok
)

:rec_if_ok
:: Операция копирования.

call :dbg "Копирование из %FRCONFIG% в System.xml"

copy /y "%FRCONFIG%" "System.xml" >nul 2>&1
set "RC=%ERRORLEVEL%"

if %RC% GEQ 1 goto :copy_err
%NHCOLOR% 07 [INFO] Файл заменен успешно! Перезапуск.. | %NHCOLOR% 02,INFO
set "CHECK_FSTART=false"
timeout 5 /nobreak > nul
goto restart?

:server_KEY
%NHCOLOR% 02 %LT%[INFO] Подключение к серверу.. | %NHCOLOR% 02,INFO
call :dbg "Отправка запроса серверу. %GITHUB_KEY_URL%"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%GITHUB_KEY_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_KEY=%%A"
call :dbg "Ответ сервера: %GITHUB_KEY%"

if "%GITHUB_KEY%"=="" (
	%NHCOLOR% 0e "%LT%[WARN] Не удалось установить соединение с сервером. (Таймаут)"
	timeout 5 /nobreak > nul
	exit /b 1
) else if "%GITHUB_KEY%"=="yes" (
	%NHCOLOR% 0с %LT%[INFO] Ответ получен: ОК	| %NHCOLOR% 02,INFO 02,ОК
	%NHCOLOR% 02 %LT%Перезапуск..
	timeout 5 /nobreak > nul
	cls
	goto KEY_ALLOWED
) else (
	%NHCOLOR% 0c %LT%[ERROR] Сервер отклонил входящий запрос.
	timeout 5 /nobreak > nul
	exit /b 0
)

:dbg
if /i "%DEBUG%"=="true" (
	%NHCOLOR% 07 %LT%[DEBUG] %~1 | %NHCOLOR% 03,DEBUG
)
exit /b

:warn_ignore
setlocal enabledelayedexpansion
set "CODE_TO_CHECK=%~1"
set "IGNORE_LIST=%IGNORE_CODES%"
set "CODE_IGNORED=false"

if "!IGNORE_LIST!"=="" (
	endlocal & set "CODE_IGNORED=false"
	exit /b
)

for %%i in (!IGNORE_LIST!) do (
	if "%%i"=="!CODE_TO_CHECK!" (
		endlocal & set "CODE_IGNORED=true"
		exit /b
	)
)
:: Если цикл закончился и ничего не найдено
endlocal & set "CODE_IGNORED=false"
exit /b


:CHECK_UPDATES
call :dbg "Отправка запроса серверу. %GITHUB_VERSION_URL%"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

call :dbg "Ответ сервера: %GITHUB_VERSION%"
call :dbg "Локальная версия: %LOCAL_VERSION%"

if "%GITHUB_VERSION%"=="" (
	%NHCOLOR% 0e %LT%Не удалось проверить наличие обновлений.
	set "EXIT_CODE=1"
) else if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
	%NHCOLOR% 07 %LT%Установлена актуальная версия: %LOCAL_VERSION%
) else (
	%NHCOLOR% 02 %LT%Доступна новая версия: %GITHUB_VERSION%
	%NHCOLOR% 07 %LT%Скачать: %GITHUB_RELEASE_URL%%GITHUB_VERSION%
	set "EXIT_CODE=2"
)
REM LINT:IGNORE W001
exit /b


:: 04.09.2026 и час убитого времени..
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
@echo off
@chcp 866 >nul
rem ================================
rem Purpose:  Сброс настроек Liftoff
rem Author:   Dray001
rem Version:  1.7
rem Encoding: CP866
rem ================================
rem equ	равно				==
rem neq	не равно			!=
rem lss	меньше				<
rem leq	меньше или равно	<=
rem gtr	больше				>
rem geq	больше или равно	>=
set "CHECK_NHCOLOR=true"

:RESTART
cls
set "TITLE=Liftoff_Reset"
title %TITLE%
set "LOCAL_VERSION=1.7"
set "D=%date%"
set "T=%time%"
set "DAY=%d:~0,2%"
set "MONTH=%d:~3,2%"
set "YEAR=%d:~8,2%"
set "TIME_STR=%t:~0,8%"
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/Dray4747/Liftoff-Reset/main/version.txt"

set "INIFILE=config.ini"
set "CHECK_CONFIG=true"
set "CHECK_FOLDER=true"

:: ============= Создание файла настроек =================
if not exist "C:\Liftoff\Liftoff_Data\Config\" (
	REM LINT:IGNORE W025
	mkdir "C:\Liftoff\Liftoff_Data\Config\"
	set "CHECK_FOLDER=false"
)
cd /d "C:\Liftoff\Liftoff_Data\Config\"
if not exist "C:\Liftoff\Liftoff_Data\Config\%INIFILE%" (
	(
		echo DEBUG=false
		echo NHCOLOR=%APPDATA%\nhcolor.exe
		echo FOLDER=C:\Liftoff
		echo LIFTOFF=Liftoff.exe
		echo CONFIG=config.xml
		echo CHECK_UPDATES=true
		echo IGNORE_CODES=
	) > "%INIFILE%"
	set "CHECK_CONFIG=false"
)
:: ================== Чтение кфг файла ====================
REM LINT:IGNORE W036
for /f "tokens=1* delims==" %%a in (%INIFILE%) do (
	set "%%a=%%b"
)
:: ================== Подготовка к запуску | Step 1/2 ====================
if /i "%~1"=="DOWNLOAD_UPDATE" (

	if "%~4"=="" (
		call :log 0c "Параметры аргумента DOWNLOAD_UPDATE указаны неверно."
		timeout /t 10 >nul
		exit /b 1
	)

	title Liftoff Updater
	goto DOWNLOAD_UPDATE
)

if /i "%~1"=="DEBUG" (
	set "DEBUG=true"
)
if "%DEBUG%"=="true" (
	set "LT=[%day%.%month%.%year% %time_str%] "
) else (
	set "LT="
)

if /i "%~1"=="INSTALL_UPDATE" (
	
	if "%~3"=="" (
		call :log 0c "Параметры аргумента INSTALL_UPDATE указаны неверно."
		timeout /t 10 >nul
		exit /b 1
	)
		
	title Liftoff Updater
	goto INSTALL_UPDATE
)

if "%NHCOLOR%"=="" (
	set "NHCOLOR=%APPDATA%\nhcolor.exe"
	set "CHECK_NHCOLOR=false"
)
if not exist "%NHCOLOR%" (
	echo [ERROR] nhcolor.exe не найден: %NHCOLOR%
	echo Настройте путь NHCOLOR в config.ini
	pause
	exit /b 1
)

call :log DEBUG "Включен режим отладки."

::================= Подготовка к запуску | Step 2/2 ====================
if "%CHECK_FOLDER%"=="false" (
	call :log WARN "Папка C:\Liftoff\ не найдена. Она была создана автоматически."
	timeout 3 /nobreak > nul
)
if "%CHECK_CONFIG%"=="false" (
	call :log INFO "Создан файл конфигурации. Для настройки используйте config.ini"
	call :log INFO "Перезапуск через 5 секунд.."
	timeout 5 /nobreak > nul
	goto RESTART
)
::================= Проверка обновлений ====================
if "%CHECK_UPDATES%"=="true" (
	goto CHECK_UPDATES
) else (
call :log 07 "Проверка обновлений отключена."
	goto Menu
)
:: =================== ГЛАВНОЕ МЕНЮ ===================
:Menu
call :log 07 "---------------------------------"
call :log 03 "Сброс настроек Liftoff. Автор: Dray001."
call :log 03 "github.com/Dray4747/Liftoff-Reset"
call :log 07 "---------------------------------"
if "%CHECK_NHCOLOR%"=="false" (
	call :log WARN "Путь к файлу NHCOLOR не задан. Используйте %INIFILE% для настройки."
)
if not "%FOLDER%"=="C:\Liftoff" (
	call :warn_ignore W001
	call :log DEBUG "Папка: %FOLDER%"
	if "%CODE_IGNORED%"=="false" (
		call :log WARN "Внимание: Не удаляйте папку C:\Liftoff\Liftoff_Data\Config"
		call :log WARN "Чтобы скрыть предупреждение, читайте инструкцию на сайте."
	)
)
:: =================== Поиск и выключение Liftoff. ===================
call :log INFO "Завершение работы Liftoff.."
REM LINT:IGNORE W043, SEC015
taskkill /f /im "%LIFTOFF%" >nul 2>&1

if %ERRORLEVEL% equ 0 (
	call :log INFO "Liftoff успешно завершил работу."
) else if %ERRORLEVEL% equ 128 (
	call :log INFO "Процесс %LIFTOFF% не найден."
) else if %ERRORLEVEL% equ 1 (
	call :log ERROR "Произошла ошибка при завершении работы %LIFTOFF%."
)

:: =================== Поиск и вход в директорию Liftoff. ===================
cd /d "%FOLDER%\Liftoff_Data\Config" >nul 2>&1
if %ERRORLEVEL% neq 0 (
	call :log ERROR "Не удается найти раздел: %FOLDER%\Liftoff_Data\Config"
	pause
	exit /b 1
)

:: =================== ПРОВЕРКА ФАЙЛА SYSTEM.XML ===================
if not exist System.xml (
	call :log WARN "System.xml не найден. Файл будет создан автоматически."
	call :log DEBUG "System.xml не найден. Путь: %FOLDER%\Liftoff_Data\Config\System.xml"
)
:: =================== ПРОВЕРКА ФАЙЛА CONFIG.XML ===================
if not exist "%CONFIG%" (
	call :log ERROR "Файл %CONFIG% не найден, настройки не заменены."
	goto Liftoff
)
:: =================== ОПЕРАЦИЯ КОПИРОВАНИЯ ===================
call :log DEBUG "Копирование из %CONFIG% в System.xml. Путь: %FOLDER%\Liftoff_Data\Config"
set "RC=1"
set "COPY_TRY=0"
:copy_retry
set /a COPY_TRY+=1
copy /y "%CONFIG%" "System.xml" >nul 2>&1
set "RC=%ERRORLEVEL%"
if %RC% GEQ 1 (
	if %COPY_TRY% LSS 3 (
		call :log WARN "Ошибка копирования %CONFIG%, повторная попытка %COPY_TRY% из 3..."
		timeout 2 /nobreak >nul
		goto copy_retry
	)
	call :log ERROR "Ошибка копирования %CONFIG%. Возможно, файл занят другой программой."
	goto Liftoff
)
call :log INFO "Файл заменен успешно."
:: =================== Запуск Liftoff. ===================
:LIFTOFF
call :log INFO "Запуск Liftoff.."
call :log DEBUG "Запуск %LIFTOFF% по пути: %FOLDER%"

cd /d "%FOLDER%"
if not exist "%FOLDER%\%LIFTOFF%" (
	call :log ERROR "Файл %LIFTOFF% не найден. Запуск Liftoff невозможен."
	pause
	exit /b 1
)
start "" "%FOLDER%\%LIFTOFF%"
call :log 02 "Операция, запрошенная пользователем, завершена."

timeout /t 3 /nobreak >nul
exit

:log
rem %1 - тег (INFO/WARN/ERROR/DEBUG) или код цвета для текста без тега (напр. 02), %2 - текст в кавычках
if /i "%~1"=="DEBUG" (
	if /i "%DEBUG%"=="true" (
		%NHCOLOR% 07 "%LT%[DEBUG] %~2" | %NHCOLOR% 03,DEBUG
	)
	exit /b
)
if /i "%~1"=="INFO" (
	%NHCOLOR% 07 "%LT%[INFO]  %~2" | %NHCOLOR% 02,INFO
	exit /b
)
if /i "%~1"=="WARN" (
	%NHCOLOR% 0e "%LT%[WARN]  %~2"
	exit /b
)
if /i "%~1"=="ERROR" (
	%NHCOLOR% 0c "%LT%[ERROR] %~2"
	exit /b
)
rem otherwise %1 = hex color: plain text without tag
%NHCOLOR% %~1 "%LT%%~2"
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
	if /i "%%i"=="!CODE_TO_CHECK!" (
		endlocal & set "CODE_IGNORED=true"
		exit /b
	)
)
:: Если цикл закончился и ничего не найдено
endlocal & set "CODE_IGNORED=false"
exit /b

:CHECK_UPDATES
call :log 07 "Проверка наличия обновлений..."

for /f "tokens=1 delims=" %%A in ('powershell -NoProfile -Command "$c=(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -UseBasicParsing -TimeoutSec 5).Content.Trim(); if($c -match \"^[0-9A-Za-z._-]+$\"){$c}else{\"\"}" 2^>nul') do set "GITHUB_VERSION=%%A"

cls
call :log DEBUG "Сервер: %GITHUB_VERSION% - Локально: %LOCAL_VERSION%"

if "%GITHUB_VERSION%"=="" (
call :log 0e "Не удалось проверить наличие обновлений."
	goto menu
) else if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
call :log 07 "Установлена актуальная версия: %LOCAL_VERSION%"
	goto menu
) else (
call :log 02 "Доступна новая версия: %GITHUB_VERSION%"
	goto PREPARE_UPDATE
)

:PREPARE_UPDATE
set "PID="
for /f "tokens=2 delims= " %%a in ('tasklist /nh /fi "windowtitle eq %TITLE%" 2^>nul') do set "PID=%%a"

if not defined PID (
	call :log 0c "PID не получен. Обновление невозможно."
	goto menu
)

REM LINT:IGNORE S026
echo %PID%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
	call :log 0c "PID некорректен. Обновление невозможно."
	goto menu
)
start /min "Liftoff Updater" "%~f0" DOWNLOAD_UPDATE %PID% "%LOCAL_VERSION%" "%GITHUB_VERSION%"
goto menu

:DOWNLOAD_UPDATE
set "PID=%~2"
set "LOCAL_VERSION=%~3"
set "GITHUB_VERSION=%~4"
set "DOWNLOAD_URL=https://github.com/Dray4747/Liftoff-Reset/releases/download/%GITHUB_VERSION%/Liftoff.exe"

if not exist "C:\Liftoff\Versions\" (
	REM LINT:IGNORE W025
	mkdir "C:\Liftoff\Versions\"
)

copy /Y "%~f0" "C:\Liftoff\Versions\Liftoff_%LOCAL_VERSION%.exe" >nul
if errorlevel 1 (
	call :log 0e "Резервная копия не сохранена."
)

powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile 'C:\Liftoff\Versions\Liftoff_%GITHUB_VERSION%.exe' -TimeoutSec 60"

if errorlevel 1 ( 
	call :log 0c "Не удалось скачать обновление."
	timeout /t 10 >nul
	exit /b 1
)

if not exist "C:\Liftoff\Versions\Liftoff_%GITHUB_VERSION%.exe" (
	call :log 0c "Обновление не найдено, не скачано или не распознано как исполняющий файл."
	timeout /t 10 >nul
	exit /b 1
)
goto PID_KILL

:PID_KILL
REM LINT:IGNORE S026
tasklist /FI "PID eq %PID%" >nul
if errorlevel 1 (
	call :log 07 "%PID% не найден."
	goto PID_INSTALL
)
REM LINT:IGNORE W043, SEC013, SEC015
taskkill /PID %PID% /F >nul
if errorlevel 1 (
	call :log 0e "Процесс %PID% не завершён."
	timeout /t 10 >nul
	exit /b 1
)
call :log 07 "Процесс %PID% успешно завершён."
:PID_INSTALL
start /min "" "C:\Liftoff\Versions\Liftoff_%LOCAL_VERSION%.exe" INSTALL_UPDATE "%GITHUB_VERSION%" "%~f0"
exit /b 0

:INSTALL_UPDATE
set "GITHUB_VERSION=%~2"
set "PATH_EXE=%~3"
timeout /t 2 /nobreak >nul

copy /Y "C:\Liftoff\Versions\Liftoff_%GITHUB_VERSION%.exe" "%PATH_EXE%"
if errorlevel 1 (
	call :log 0c "Произошла ошибка при установке обновлений."
	timeout /t 10 >nul
	exit /b 1
)
start "" "%PATH_EXE%"
:: 04.09.2026 и час убитого времени..
REM LINT:IGNORE W001
exit /b 0
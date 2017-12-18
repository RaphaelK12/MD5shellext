@echo off
setlocal


:Main:
:: Some initialisation work
title %~n0
color 07
cls
chdir /d "%~dp0"
call :PrintHeader

:: First argument required
set "setupSwitch=%~1"
if not defined setupSwitch (
    call :PrintUsage
    call :PrintFooter "Aborted."
    call :Exit
)

:: Check admin rights
call :IsElevatedCMD
if not "%errorlevel%"=="0" (
    if "%~2"=="/uac" (
        call :PrintFooter "Failed to elevate CMD."
        call :Exit
    ) else (
        call :PrintFooter "Elevating..."
        call :RestartWithUAC "%setupSwitch%"
    )
)

:: Determine framework root
set "regasmDirectory=%SystemRoot%\Microsoft.NET\Framework"
call :Is32bitOS
if not "%errorlevel%"=="0" (
    set "regasmDirectory=%regasmDirectory%64"
)
set "regasmDirectory=%regasmDirectory%\v4.0.30319"

:: Setup MD5shellext server
if "%~1"=="/install" (
    "%regasmDirectory%\regasm.exe" /codebase "%~dp0\MD5shellext.dll" >nul 2>&1
    set "isArgumentValid=true"
)
if "%~1"=="/uninstall" (
    "%regasmDirectory%\regasm.exe" /unregister "%~dp0\MD5shellext.dll" >nul 2>&1
    set "isArgumentValid=true"
)
if not defined isArgumentValid (
    call :PrintUsage
    call :PrintFooter "Aborted."
    call :Exit
)

call :PrintFooter "Done!"
call :Exit

exit


:: PRIVATE

:PrintHeader: ""
echo #######################################################
echo ##            MD5 Shell Extension Setup              ##
echo #######################################################
exit /b

:PrintUsage: ""
echo Usage: %~n0 /install
echo Usage: %~n0 /uninstall
echo.
exit /b

:PrintFooter: "message"
echo %~1
echo.
echo /-------------------------------------------------------------------\
echo  Fork me on GitHub: https://github.com/Svetomech/MD5shellext
echo \-------------------------------------------------------------------/
exit /b

:: PUBLIC

:Is32bitOS: ""
set "errorlevel=0"
reg query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" >nul 2>&1 || set "errorlevel=1"
exit /b %errorlevel%

:IsElevatedCMD: ""
set "errorlevel=0"
net session >nul 2>&1 || set "errorlevel=1"
exit /b %errorlevel%

:RestartWithUAC: "args="
set "_helperPath=%temp%\%~n0.helper-%random%.vbs"
echo Set UAC = CreateObject^("Shell.Application"^) > "%_helperPath%"
echo UAC.ShellExecute "%~f0", "%~1 /uac", "", "runas", 1 >> "%_helperPath%"
cscript "%_helperPath%" //b //nologo >nul 2>&1
erase /f /s /q /a "%_helperPath%" >nul 2>&1
set "_helperPath="
exit

:Exit: ""
timeout /t 2 /nobreak >nul 2>&1
exit

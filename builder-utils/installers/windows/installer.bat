@echo off

set drive=%cd:~0,1%
pushd ..
set folder=%cd:~3%
popd

if "%folder%" == "" goto Install
echo PorteuX must be copied to the root of the partition, not into a folder.
echo Move "\%folder%\boot" to "%drive%:\boot" and run the installer again.
goto Error

:Install

echo Installing PorteuX to %drive%:
echo WARNING: Make sure %drive%: is the right partition before proceeding.
echo.
echo Press any key to continue
pause > nul

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer.ps1" %drive%
if %ERRORLEVEL% == 0 goto Done
goto Error

:Done
echo Installation finished successfully.
echo You may reboot your system now and start using PorteuX.
echo Don't forget to set your BIOS to boot from this unit.
goto end

:Error
echo.
echo Installation failed.
echo Make sure this unit is not readonly and you have permission to change files.
echo Try to unplug/plug this unit or reboot your system and run the installer again.
echo If the problem persists, try to create a new partition from scratch.
goto end

:end
echo.
echo Press any key to exit
pause > nul

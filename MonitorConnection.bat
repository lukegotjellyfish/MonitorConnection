@ECHO OFF
CLS

:loop
  set a='"netsh wlan show interfaces | find "Profile" /I /C"'
  for /f "delims=" %%c in (%a%) do (set netshResult=%%c)
  IF %netshResult% equ 0 goto :connect
  ECHO Still connected to TALKTALK5F2228.
  ECHO Waiting 2 seconds
  timeout 2 >nul
goto :loop

:connect
ECHO Not connected, attempting reconnect
netsh wlan connect name=TALKTALK5F2228 | echo Connecting to TALKTALK5F2228
ECHO Waiting 2 seconds
timeout 2 >nul
for /f "delims=" %%c in (%a%) do (set netshResult=%%c)
IF %netshResult% equ 0 goto :offandonagain
goto :loop


:offandonagain
ECHO Disabling interface
netsh interface set interface "WiFi 3" disable
ECHO Waiting one second
timeout 1 >nul
ECHO Enabling interface
netsh interface set interface "WiFi 3" enable
ECHO Waiting for 8 seconds
timeout 8 >nul
goto :loop
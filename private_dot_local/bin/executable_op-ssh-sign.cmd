@echo off
setlocal

set "OP_SSH_SIGN="

for /f "delims=" %%I in ('where op-ssh-sign.exe 2^>nul') do (
  set "OP_SSH_SIGN=%%~fI"
  goto run
)

if defined LOCALAPPDATA (
  if exist "%LOCALAPPDATA%\1Password\app\8\op-ssh-sign.exe" (
    set "OP_SSH_SIGN=%LOCALAPPDATA%\1Password\app\8\op-ssh-sign.exe"
    goto run
  )
  for /d %%D in ("%LOCALAPPDATA%\1Password\app\*") do (
    if exist "%%~fD\op-ssh-sign.exe" (
      set "OP_SSH_SIGN=%%~fD\op-ssh-sign.exe"
      goto run
    )
  )
)

echo op-ssh-sign.exe not found. Install 1Password SSH support or add it to PATH. 1>&2
exit /b 1

:run
"%OP_SSH_SIGN%" %*

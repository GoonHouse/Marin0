@echo off
ROBOCOPY "%appdata%\LOVE\Marin0\mappacks" "marin0\mappacks" /DCOPY:DA /FFT /Z /XA:SH /IT /R:0 /TEE /XJD /E /MOVE
exit
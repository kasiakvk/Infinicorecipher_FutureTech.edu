@echo off
echo Starting InfiniCoreCipher Continuous Monitoring...
cd /d "%~dp0"
python infinicore_cipher_automation.py monitor
pause

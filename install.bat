@echo off

py -3.10 -c "..." >nul 2>&1

echo Checking Python

if %ERRORLEVEL% NEQ 0 (
    echo Python 3.10 is not installed, installing...

    curl -o python-3.10.11-amd64.exe https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe

    echo Waiting for Python installer to finish...
    start /wait python-3.10.11-amd64.exe

    del python-3.10.11-amd64.exe

    echo Installed Python 3.10
)

echo Checking requirements

py -3.10 -m pip install -r requirements.txt

echo Finished, press any key to continue...

pause
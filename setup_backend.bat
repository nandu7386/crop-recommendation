@echo off
echo Setting up backend environment...
cd backend
python -m venv venv
call venv\Scripts\activate.bat
pip install -r requirements.txt
echo.
echo Backend setup complete!
echo VS Code will now use the installed packages. You may need to restart VS Code to clear the warnings completely.
pause

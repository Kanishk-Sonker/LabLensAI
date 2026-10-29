@echo off
setlocal enabledelayedexpansion
set PATH=%PATH%;C:\Users\saumy\AppData\Local\Programs\Git\cmd;C:\Users\saumy\AppData\Local\Programs\Git\mingw64\bin
cd /d "%~dp0"

echo ===================================================================
echo   LabLens AI - GitHub Auto-Push
echo   Target Repository: https://github.com/Kanishk-Sonker/LabLensAI
echo ===================================================================
echo.
echo Choose authentication method:
echo   [1] Sign in via Browser (Default Git Credential Manager)
echo   [2] Paste GitHub Personal Access Token (PAT)
echo.
set /p CHOICE="Enter choice (1 or 2, default is 1): "

if "%CHOICE%"=="2" (
    echo.
    set /p GHTOKEN="Paste your GitHub Token (ghp_...): "
    if "!GHTOKEN!"=="" (
        echo Token cannot be empty.
        pause
        exit /b
    )
    git remote remove origin 2>nul
    git remote add origin https://Kanishk-Sonker:!GHTOKEN!@github.com/Kanishk-Sonker/LabLensAI.git
) else (
    git remote remove origin 2>nul
    git remote add origin https://github.com/Kanishk-Sonker/LabLensAI.git
)

git branch -M main
echo.
echo Pushing project files to GitHub main branch...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================================
    echo   SUCCESS! All LabLens AI files uploaded to GitHub!
    echo   Repository URL: https://github.com/Kanishk-Sonker/LabLensAI
    echo ===================================================================
) else (
    echo.
    echo Push encountered an issue. Please verify your GitHub login or token.
)
echo.
pause

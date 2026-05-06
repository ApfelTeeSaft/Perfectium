@echo off
setlocal EnableDelayedExpansion

set CONFIG=%1
if "%CONFIG%"=="" set CONFIG=Release

set OUTDIR=.\output\bin\%CONFIG%
set OBJDIR=.\output\obj\%CONFIG%

if not exist "%OUTDIR%" mkdir "%OUTDIR%"
if not exist "%OBJDIR%" mkdir "%OBJDIR%"

set ML_FLAGS=/nologo /W3 /WX /c /Cx /Zi /Fo"%OBJDIR%\\"
if /I "%CONFIG%"=="Debug" (
    set ML_FLAGS=%ML_FLAGS% /DDEBUG
) else (
    set ML_FLAGS=%ML_FLAGS% /DNDEBUG
)

set LINK_FLAGS=/nologo /DLL /SUBSYSTEM:WINDOWS /MACHINE:X64 /DEBUG
set LINK_FLAGS=%LINK_FLAGS% /DEF:raider.def
set LINK_FLAGS=%LINK_FLAGS% /OUT:"%OUTDIR%\raider.dll"
set LINK_FLAGS=%LINK_FLAGS% /PDB:"%OUTDIR%\raider.pdb"
set LINK_FLAGS=%LINK_FLAGS% /IMPLIB:"%OUTDIR%\raider.lib"

set LIBS=kernel32.lib user32.lib detours.lib

set ASM_FILES=^
    raider.asm ^
    sdk_globals.asm ^
    patterns.asm ^
    native.asm ^
    util.asm ^
    logger.asm ^
    hooks.asm ^
    ufunctionhooks.asm ^
    gui.asm ^
    zerogui.asm ^
    zeroinput.asm ^
    logic\game.asm ^
    logic\inventory.asm ^
    logic\abilities.asm ^
    logic\spawners.asm ^
    logic\teams.asm ^
    gamemodes\gamemode_base.asm ^
    gamemodes\gamemode_solos.asm ^
    gamemodes\gamemode_duos.asm ^
    gamemodes\gamemode_50v50.asm ^
    gamemodes\gamemode_playground.asm ^
    gamemodes\gamemode_lategame.asm ^
    sdk\sdk_structs.asm ^
    sdk\sdk_classes.asm ^
    sdk\sdk_fort.asm

set OBJ_LIST=
set ERRORS=0

for %%F in (%ASM_FILES%) do (
    set SRC=%%F
    set FNAME=%%~nF
    set FDIR=%%~dpF

    set OBJNAME=!FDIR:logic\=logic_!
    set OBJNAME=!OBJNAME:gamemodes\=gm_!
    set OBJNAME=!OBJNAME:sdk\=sdk_!
    set OBJNAME=!OBJNAME:\=_!

    set OBJ=%OBJDIR%\!OBJNAME!!FNAME!.obj

    echo [ML64] %%F
    ml64.exe %ML_FLAGS% /Fo"!OBJ!" "%%F"
    if errorlevel 1 (
        echo   ERROR: failed to assemble %%F
        set /A ERRORS=!ERRORS!+1
    ) else (
        set OBJ_LIST=!OBJ_LIST! "!OBJ!"
    )
)

if !ERRORS! GTR 0 (
    echo.
    echo BUILD FAILED: !ERRORS! file(s) failed to assemble.
    exit /b 1
)

echo.
echo [LINK] raider.dll
link.exe %LINK_FLAGS% %OBJ_LIST% %LIBS%
if errorlevel 1 (
    echo   ERROR: link failed.
    exit /b 1
)

echo.
echo BUILD SUCCEEDED: %OUTDIR%\raider.dll
exit /b 0

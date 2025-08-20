@echo off
echo Cleaning up build files...

if exist lex.yy.c (
    del lex.yy.c
    echo     ✓ Removed lex.yy.c
)

if exist parser.tab.c (
    del parser.tab.c  
    echo     ✓ Removed parser.tab.c
)

if exist parser.tab.h (
    del parser.tab.h
    echo     ✓ Removed parser.tab.h
)

if exist interpreter.exe (
    del interpreter.exe
    echo     ✓ Removed interpreter.exe
)

if exist a.exe (
    del a.exe
    echo     ✓ Removed a.exe
)

echo.
echo Cleanup complete!
pause
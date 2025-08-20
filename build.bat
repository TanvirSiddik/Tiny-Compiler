@echo off
cls
echo ==========================================
echo  Simple Programming Language Interpreter
echo ==========================================
echo.

echo [1/3] Generating lexical analyzer...
win_flex scanner.l
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate lexer with flex
    echo Make sure flex is installed and in PATH
    pause
    exit /b 1
)
echo     ✓ Lexer generated (lex.yy.c)

echo.
echo [2/3] Generating parser...
win_bison -d parser.y
if %errorlevel% neq 0 (
    echo Trying alternative bison command...
    bison -d parser.y
    if %errorlevel% neq 0 (
        echo ERROR: Failed to generate parser
        echo Make sure bison/win_bison is installed and in PATH
        echo.
        echo Try installing: https://github.com/lexxmark/winflexbison
        pause
        exit /b 1
    )
)
echo     ✓ Parser generated (parser.tab.c, parser.tab.h)

echo.
echo [3/3] Compiling interpreter...
gcc -std=c99 -Wall -Wextra -O2 lex.yy.c parser.tab.c -o interpreter.exe
if %errorlevel% neq 0 (
    echo ERROR: Compilation failed
    echo Make sure GCC is installed and in PATH
    pause
    exit /b 1
)
echo     ✓ Compilation successful

echo.
echo ==========================================
echo BUILD SUCCESSFUL!
echo ==========================================
echo.
echo Usage:
echo   interpreter.exe filename.txt    (run file)
echo   interpreter.exe                 (interactive mode)
echo.
echo Example test files have been created:
echo   - test_basic.txt
echo   - test_loops.txt  
echo   - test_conditions.txt
echo.
pause
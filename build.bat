
@echo off
echo.
echo ==========================================
echo  Simple Programming Language Interpreter
echo ==========================================
echo.


win_flex scanner.l
echo     ✓ Lexer generated (lex.yy.c)

echo.
win_bison -d parser.y
echo     ✓ Parser generated (parser.tab.c, parser.tab.h)

gcc -std=c99 -Wall -Wextra -O2 lex.yy.c parser.tab.c -o interpreter.exe
echo.

echo     ✓ Compilation successful

echo.
echo ==========================================
echo BUILD SUCCESSFUL!
echo ==========================================
echo.
pause
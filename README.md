# Simple Programming Language Interpreter

A lightweight interpreter for a simple programming language built with Flex and Bison. This project implements a C-based interpreter that supports variables, arithmetic operations, conditional statements, loops, and print functionality.

## Features

### Core Language Features
- **Variables**: Declare and use variables with automatic type handling
- **Arithmetic Operations**: Addition (+), Subtraction (-), Multiplication (*), Division (/)
- **Comparison Operations**: Equal (==), Not Equal (!=), Less Than (<), Greater Than (>), Less/Greater or Equal (<=, >=)
- **Control Flow**: If-else statements and for loops
- **Print Statements**: Output variables, expressions, and strings
- **Comments**: Single-line comments using `//`

### Technical Features
- Abstract Syntax Tree (AST) based execution
- Symbol table for variable management
- Memory management with proper cleanup
- Error handling for division by zero and undefined variables
- Interactive and file-based execution modes

## Language Syntax

### Variable Assignment
```javascript
x = 10;
y = 20.5;
name = "Hello";
```

### Arithmetic Expressions
```javascript
result = (10 + 5) * 2 - 3;
division = x / y;
```

### Print Statements
```javascript
print("Hello, World!");
print(x);
print(x + y);
```

### Conditional Statements
```javascript
if(x > y) {
    print("x is greater than y");
} else {
    print("x is not greater than y");
}
```

### For Loops
```javascript
for(i = 0; i <= 10; i = i + 1) {
    print(i);
}
```

### Comments
```javascript
// This is a comment
x = 5; // End of line comment
```

## Prerequisites

### Windows
- **Flex for Windows** (win_flex) - Download from [Win flex-bison](https://github.com/lexxmark/winflexbison)
- **GCC Compiler** - Available through MinGW, MSYS2, or Dev-C++
- **Command Prompt** or **PowerShell**

### Linux/macOS
- **Flex** - `sudo apt install flex` (Ubuntu/Debian) or `brew install flex` (macOS)
- **Bison** - `sudo apt install bison` (Ubuntu/Debian) or `brew install bison` (macOS)
- **GCC** - Usually pre-installed or `sudo apt install gcc`

## Installation and Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/simple-programming-language-interpreter.git
   cd simple-programming-language-interpreter
   ```

2. **For Windows users:**
   - Ensure `win_flex.exe` and `win_bison.exe` are in your PATH
   - Or place them in the project directory

3. **For Linux/macOS users:**
   - Install flex and bison using your package manager
   - Modify `build.bat` commands to use `flex` and `bison` instead of `win_flex` and `win_bison`

## Building the Project

### Windows
Run the build script:
```cmd
build.bat
```

### Linux/macOS
Create a build script or run manually:
```bash
flex scanner.l
bison -d parser.y
gcc -std=c99 -Wall -Wextra -O2 lex.yy.c parser.tab.c -o interpreter
```

## Usage

### Interactive Mode
Run without arguments for interactive mode:
```cmd
interpreter.exe
```
Type your code and press `Ctrl+Z` (Windows) or `Ctrl+D` (Unix) to execute.

### File Mode
Run with a source file:
```cmd
interpreter.exe program.txt
```

## Example Programs

### Basic Arithmetic
```javascript
x = 10;
y = 20;
print("Basic arithmetic test:");
print(x + y);
print(x - y);
print(x * y);
print(x / y);
```

### Conditional Logic
```javascript
a = 15;
b = 10;
if(a > b) {
    print("a is greater than b");
} else {
    print("a is not greater than b");
}
```

### Loops
```javascript
print("Countdown:");
for(j = 5; j > 0; j = j - 1) {
    print(j);
}
```

### Complex Expressions
```javascript
result = (10 + 5) * 2 - 3;
print(result);

for(x = 1; x <= 3; x = x + 1) {
    if(x == 2) {
        print("Found number 2");
    } else {
        print("Not number 2");
    }
}
```

## Test Files

The project includes several test files in the `test_file/` directory:

- `test_basic.txt` - Basic arithmetic and variable operations
- `test_conditions.txt` - Conditional statements and comparisons
- `test_loops.txt` - For loop examples
- `test_complex.txt` - Complex expressions and nested control structures

Run tests:
```cmd
interpreter.exe test_file/test_basic.txt
interpreter.exe test_file/test_conditions.txt
interpreter.exe test_file/test_loops.txt
interpreter.exe test_file/test_complex.txt
```

## Project Structure

```
├── scanner.l          # Lexical analyzer (tokenizer)
├── parser.y           # Parser and AST implementation
├── build.bat          # Windows build script
├── clean.bat          # Cleanup script
├── test_file/         # Example programs
│   ├── test_basic.txt
│   ├── test_conditions.txt
│   ├── test_loops.txt
│   └── test_complex.txt
└── README.md          # This file
```

## Architecture

### Components
1. **Lexer (scanner.l)**: Tokenizes input into language symbols
2. **Parser (parser.y)**: Builds Abstract Syntax Tree and executes code
3. **AST Nodes**: Represent different language constructs
4. **Symbol Table**: Manages variable storage and retrieval
5. **Evaluator**: Executes AST nodes and performs operations

### AST Node Types
- Numbers and identifiers
- Binary operations (arithmetic and comparison)
- Unary operations
- Variable assignments
- Print statements
- If-else conditionals
- For loops
- Statement sequences

## Error Handling

The interpreter handles several types of errors:
- **Syntax Errors**: Invalid language constructs
- **Division by Zero**: Runtime protection
- **Undefined Variables**: Access to non-existent variables
- **Memory Allocation Failures**: Graceful handling of memory issues

## Limitations

- Variables are limited to double-precision floating-point numbers
- Maximum of 100 variables in the symbol table
- String literals are only supported in print statements
- No function definitions or advanced data structures
- Single-threaded execution only

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements

- [ ] Function definitions and calls
- [ ] Arrays and data structures
- [ ] While loops
- [ ] String manipulation operations
- [ ] File I/O operations
- [ ] More data types (integers, booleans)
- [ ] Scoped variables
- [ ] Error recovery in parser

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

Created as a demonstration of building interpreters using Flex and Bison.

---

**Note**: This is an educational project designed to demonstrate compiler construction principles. It's suitable for learning about lexical analysis, parsing, AST construction, and basic interpreter implementation.
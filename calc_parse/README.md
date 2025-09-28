# CSC 254 Assignment 2: Extended Calculator Language Frontend

**Course**: CSC 254 - Programming Language Design and Implementation  
**University**: University of Rochester, Fall 2025  
**Team Members**: 
- Zhenhao Zhang (zzh133@u.rochester.edu) - AST Construction
- Zhijie Wang (zwang179@u.rochester.edu) - Scanner & Error Recovery

## Project Overview

This is Assignment 2, implementing an extended calculator language frontend with syntax error recovery and AST generation. The project builds upon the basic calculator from Assignment 1, adding support for control structures, multiple data types, and robust error handling through a table-driven LL(1) parser implemented in Rust.

## Compilation and Execution

### Prerequisites
- Rust toolchain (cargo)
- Access to `table_gen` utility (for generating parsing tables)

### Build Instructions
```bash
# Generate parsing tables (if modified)
table_gen < calc_gram.txt > src/tables.rs

# Compile the project
cargo build

# Or compile and run directly
cargo run < tests/test_01_basic_declarations.txt
```

### Running Tests
```bash
# Run individual test
cargo run < tests/test_01_basic_declarations.txt

# Compare with sample solution
~cs254/bin/calc_parse < tests/test_01_basic_declarations.txt > expected1.txt
cargo run < tests/test_01_basic_declarations.txt > output1.txt
diff expected1.txt output1.txt
```

## Test Cases

The `tests/` directory contains 11 test cases that progressively test different language features:

| Test File | Language Features Tested |
|-----------|-------------------------|
| `test_01_basic_declarations.txt` | Variable declarations, read/write operations, basic assignment |
| `test_02_real_type.txt` | Real number type support, floating-point literals |
| `test_03_conditional.txt` | If-then-else statements, comparison operators |
| `test_04_loop_basic.txt` | Do-while loops, check statements, arithmetic in assignments |
| `test_05_loop_advanced.txt` | Advanced loops with subtraction, countdown patterns |
| `test_06_nested_loops.txt` | Nested loop structures, multiple variable manipulation |
| `test_07_complex_conditional.txt` | Elsif clauses, complex branching logic |
| `test_08_multiple_elsif.txt` | Multiple elsif branches, equality/comparison operators |
| `test_09_comments.txt` | Comment parsing, end-of-file handling, inline comments |
| `test_10_binary_expressions.txt` | Parenthesized expressions, binary operations in write statements |
| `test_11_comprehensive.txt` | Nested control structures, complex program flow |

### Detailed Test Descriptions

### test_01_basic_declarations.txt
**Purpose**: Tests basic variable declarations, input, assignment, and output
```
int n
read n
n := 2
write n
```
**Tests**: 
- Integer variable declaration
- Read operation
- Simple assignment
- Write operation

### test_02_real_type.txt
**Purpose**: Tests real number type support
```
real x
x := 3.14
```
**Tests**:
- Real variable declaration
- Assignment with floating-point literal

### test_03_conditional.txt
**Purpose**: Tests basic conditional statements
```
int n  read n
if n > 0 then
  write n
else
  write 0
fi
```
**Tests**:
- If-then-else structure
- Comparison operators (`>`)
- Conditional execution

### test_04_loop_basic.txt
**Purpose**: Tests basic loop functionality
```
int i
i := 0
do
  check i < 10
  write i
  i := i + 1
od
```
**Tests**:
- Do-while loop structure
- Check statements (loop conditions)
- Arithmetic expressions in assignments

### test_05_loop_advanced.txt
**Purpose**: Tests advanced loop with decrementation
```
int n  read n
do
  check n > 0
  write n
  n := n - 1
od
```
**Tests**:
- Subtraction operations
- Countdown loop pattern
- Dynamic loop conditions

### test_06_nested_loops.txt
**Purpose**: Tests nested loop structures
```
int n  read n
int m  read m
do
  check n > 0
  do
    check m > 0
    write n
    write m
    m := m - 1
  od
  n := n - 1
  m := 2
od
```
**Tests**:
- Nested do-while loops
- Multiple variable manipulation
- Complex control flow

### test_07_complex_conditional.txt
**Purpose**: Tests complex conditional with multiple branches
```
int a  read a
int b  read b
if a > b then
  a := a - b
elsif b > a then
  b := b - a
else
  write a
fi
```
**Tests**:
- Elsif clauses
- Multiple comparison operations
- Complex branching logic

### test_08_multiple_elsif.txt
**Purpose**: Tests multiple elsif conditions
```
int x  read x
if x < 0 then
  write 0
elsif x == 0 then
  write 1
elsif x < 10 then
  write 2
else
  write 3
fi
```
**Tests**:
- Multiple elsif branches
- Equality operator (`==`)
- Less-than operator (`<`)
- Cascading conditions

### test_09_comments.txt
**Purpose**: Tests comment handling and edge cases
```
// last line has no newline
int x  x := 1 // trailing comment at end
```
**Tests**:
- Comment parsing
- End-of-file handling
- Inline comments

### test_10_binary_expressions.txt
**Purpose**: Tests parenthesized binary expressions (the main fix)
```
int a
a := 10
write ( a + 2 )
```
**Tests**:
- Parenthesized expressions
- Binary addition in write statements
- Proper AST construction for complex expressions

### test_11_comprehensive.txt
**Purpose**: Comprehensive test combining multiple features
```
int n  n := 3
do
  if n > 1 then
    write n
    write n + 1
  else
    write 0
  fi
  n := n - 1
  check n >= 0
od
```
**Tests**:
- Nested control structures (do-if-then-else)
- Binary expressions in write statements
- Greater-than-or-equal operator (`>=`)
- Complex program flow

## Implementation Details

### Scanner Extensions
- **Comments**: Support for line comments (`//`) with proper filtering in lexical analysis
- **Real numbers**: Extended tokenization to handle floating-point literals with decimal points
- **Double-character operators**: Added support for `<=`, `>=`, `!=`, `==` comparison operators
- **Robust tokenization**: Improved handling of whitespace and end-of-file conditions

### Parser Error Recovery
- **Table-driven recovery**: Implemented global FOLLOW set-based error recovery mechanism
- **Token insertion**: Supports automatic insertion of missing tokens when syntactically required
- **Token skipping**: Gracefully skips illegal tokens while maintaining parse state
- **Line number tracking**: Provides accurate error location reporting for debugging

### AST Construction (Zhenhao's Implementation)
- **Node definitions**: Comprehensive AST node types defined in `attributes.rs` using Rust enums
- **Action routines**: Implemented approximately 50 action routines in `actions.rs` for AST construction
- **Memory management**: Used `Box<T>` for recursive AST structures to handle Rust ownership
- **Output formatting**: Square brackets for statement lists, parentheses for expressions, fully compatible with sample solution

### Team Division of Labor
As suggested in the assignment guidelines, we divided the work as follows:
- **Zhenhao Zhang**: Focused on AST construction, implementing the attribute grammar mechanism and action routines
- **Zhijie Wang**: Handled scanner extensions and error recovery implementation

### Programming Experience with Rust
This project provided valuable experience with Rust's ownership system and memory safety features. Key learning points included:
- Using `enum` types for representing different AST node variants
- Managing memory with `Box<T>` for recursive data structures
- Working with Rust's strict borrowing rules in parser implementation
- Leveraging pattern matching for clean AST construction code

### Output Format
The parser generates AST output in S-expression format:
- **Square brackets `[]`**: Represent statement lists
- **Parentheses `()`**: Represent fixed structures (operators, function calls)
- **Atoms**: Variable names, numbers, and operators

Example output for `test_10_binary_expressions.txt`:
```
Parse completed.  AST is
[ (decl (a) (int)) (:= (a) (10)) (write (+ (a) (2))) ]
```

## Known Issues / Special Notes

- Error recovery focuses on global FOLLOW set recovery rather than immediate local recovery
- Real number parsing supports decimal notation but not scientific notation (e.g., `1.23e4`)
- The implementation prioritizes correctness and compatibility with the sample solution over performance optimizations

## Architecture Overview

- **`scanner.rs`**: Lexical analysis with extended token support
- **`parser.rs`**: Table-driven LL(1) parsing with error recovery
- **`tables.rs`**: Parse tables generated by external `table_gen` utility
- **`actions.rs`**: Action routines for AST construction and semantic analysis
- **`attributes.rs`**: AST node type definitions and attribute handling
# CSC 254 Assignment 2: Extended Calculator Language Frontend

## Project Overview

This is Assignment 2 for CSC 254. We work in groups of two. 
- Zhenhao Zhang (zzh133@u.rochester.edu) - AST Construction
- Zhijie Wang (zwang179@u.rochester.edu) - Scanner & Error Recovery

## Compilation and Execution

### Build Instructions
```bash
# Generate parsing tables (if modified)
table_gen < calc_gram.txt > src/tables.rs

# Compile the project
cargo build
```

### Running Tests
```bash
# Run individual test
cargo run < tests/test_01_basic_declarations.txt

~cs254/bin/calc_parse < tests/test_01_basic_declarations.txt


# Compare with sample solution
~cs254/bin/calc_parse < tests/test_01_basic_declarations.txt > expected1.txt
cargo run < tests/test_01_basic_declarations.txt > output1.txt
diff expected1.txt output1.txt
```

## Test Cases

The `tests/` directory contains **39 comprehensive test cases** grouped by language features:

### Basic Test Series (test1-test10)
- `test1.txt` through `test10.txt` - Initial development and regression tests

### Basic Declarations & Types (3 tests)
- `test_01_basic_declarations.txt` - Variable declarations, read/write operations
- `test_02_real_type.txt` - Real number literals with decimal notation
- `test_02_real_withe.txt` - Scientific notation (e.g., `10e+2`, `3.14e-10`)

### Conditional Statements (4 tests)
- `test_03_conditional.txt` - If-then-else with comparison operators
- `test_03_compare.txt` - Less-than operator edge cases
- `test_07_complex_conditional.txt` - Elsif clauses
- `test_08_multiple_elsif.txt` - Multiple elsif branches

### Loops (4 tests)
- `test_04_loop_basic.txt` - Basic do-od loops with check statements
- `test_05_loop_advanced.txt` - Advanced loops with countdown patterns
- `test_06_nested_loops.txt` - Nested loop structures
- `test_18_loop_with_conditions.txt` - Loops combined with conditional logic

### Expressions & Operators (5 tests)
- `test_10_binary_expressions.txt` - Parenthesized expressions, binary operations
- `test_12_multiplication_division.txt` - Multiplication and division operators
- `test_13_complex_arithmetic.txt` - Complex arithmetic expressions
- `test_14_inequality_operators.txt` - Inequality comparison operators (`!=`, `<=`, `>=`)
- `test_17_complex_expressions.txt` - Advanced expression combinations

### Comments (1 test)
- `test_09_comments.txt` - Line comment parsing (`//`) and EOF handling

### Mixed Features & Comprehensive Tests (9 tests)
- `test_11_comprehensive.txt` - Nested control structures
- `test_15_mixed_types.txt` - Operations with mixed int/real types
- `test_16_triple_nested.txt` - Triple nested control structures
- `test_16_comp1.txt` - Comprehensive feature test 1
- `test_17_comp2.txt` - Comprehensive feature test 2
- `test_18_comp3.txt` - Comprehensive feature test 3
- `test_19_factorial_calculation.txt` - Factorial calculation algorithm
- `test_20_comprehensive_advanced.txt` - Advanced comprehensive integration test

### Error Handling (4 tests)
- `test_12_error.txt` - Syntax error recovery test 1
- `test_13_error2.txt` - Syntax error recovery test 2
- `test_14_error3.txt` - Syntax error recovery test 3 (premature EOF)
- `test_15_error4.txt` - Syntax error recovery test 4 (token deletion)


## Implementation Details

### Scanner Extensions
- **Comments**: Added line comments (`//`) support with proper filtering
- **Real numbers**: Added support for decimal numbers like `1.23`
- **Two-character operators**: Added `<=`, `>=`, `!=`, `==` operators


### Parser Error Recovery
- **Error recovery**: Added FOLLOW set recovery with token skip and insert
- **Token insertion**: Auto-adds missing tokens when needed
- **Token skipping**: Skips bad tokens while keeping parse state
- **Line tracking**: Shows exact error locations for debugging

### AST Construction
- **Node types**: Made complete AST nodes in `attributes.rs` using Rust enums
- **Action routines**: Built 28 action routines in `actions.rs` for AST building (actions 0-72)
- **Memory handling**: Used `Box<T>` for recursive AST parts to handle Rust ownership
- **Output format**: Square brackets for statements, parentheses for expressions, perfectly matches instructor's expected format


### Team Division of Labor
As suggested in the assignment guidelines, we divided the work as follows:
- **Zhenhao Zhang**: Focused on AST construction, implementing the attribute grammar mechanism and action routines and the scanner and parser integration
- **Zhijie Wang**: Handled scanner extensions and error recovery implementation

### Programming Experience with Rust

Zhenhao:
In this project, I was mainly responsible for building the AST, while my teammate worked on the scanner. Later, when updating and running the tests, we discovered that the scanner did not cover operators like != and ==, which caused the AST to fail during parsing. This experience showed me the importance of clearly defining module interfaces at the beginning of a project, and also demonstrated how integration testing can reveal issues that may not appear during individual development.

On the technical side, this project taught me many important Rust concepts. While building the AST, I used the ownership system and borrow checker, and applied Box<T> to handle recursive data structures. I also combined traits with Box<dyn Trait> to implement different types of expressions. While improving the scanner, I appreciated the simplicity and safety of Rust’s match and enum. With the Cargo toolchain (such as cargo build and cargo run), I experienced efficient development and debugging.



Zihijie:
My programming experience with Rust was decent. The syntax of Rust is not super complicated and kind similar to programing languages that we are familiar with such as C++ and java. The Rust resources given the instructor are very helpful--- they provided lot of fundamentals such as control flow, loop, data structures, which gave me a solid foundation to work through the project. I also gained a lot of new experience with Rust features such as `match`, `enum`, and a Cargo-based workflow such as `cargo run`, `cargo build`.

### Output Format
Is the same as the sample solution provided by the instructor, with square brackets for statements and parentheses for expressions.

## Known Issues / Special Notes

- Error recovery uses FOLLOW sets and supports token insert and delete
- Real number parsing handles decimal and scientific notation with optional exponent
- Implementation focuses on correctness and matching sample solution over speed

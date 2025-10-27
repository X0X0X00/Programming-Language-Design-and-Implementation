# CSC 254 Assignment 3 - ECL Interpreter

**Authors:**
- Zhenhao Zhang (zzh133@u.rochester.edu)
- Zhijie Wang (zwang179@u.rochester.edu)

## Description

This project implements a complete interpreter for the Extended Calculator Language (ECL), a language that extends the basic calculator with type declarations, control flow statements, and type checking. The interpreter consists of two main phases:

1. **Type Checking Phase**: Static semantic analysis that catches type errors, undeclared variables, scope violations, and other semantic issues before execution.
2. **Interpretation Phase**: Execution of the type-checked program with dynamic error handling for runtime issues like division by zero and invalid input.

## Division of Labor

- **Zhenhao Zhang**: Implemented the type checking phase (`typecheck` and related functions)
- **Zhijie Wang**: Implemented the interpretation phase (`interpret` and related functions)

Both team members collaborated on testing and debugging to ensure correctness.

## Language Features

The ECL language supports:

- **Data Types**: `int`, `real`, `bool`
- **Variable Declarations**: Explicit declarations with scope rules
- **Expressions**: Arithmetic (`+`, `-`, `*`, `/`), relational (`==`, `!=`, `<`, `<=`, `>`, `>=`), and logical (`and`, `or`)
- **Control Flow**: `if/elsif/else/fi` statements and `do/od` loops
- **Type Conversions**: `float()` for int-to-real and `trunc()` for real-to-int
- **I/O Operations**: `read` and `write` statements
- **Loop Control**: `check` statements for conditional loop termination
- **Comments**: Line comments with `//`

**Note:** Boolean type support is a custom extension beyond the original assignment requirements. See [BOOLEAN_IMPLEMENTATION.md](BOOLEAN_IMPLEMENTATION.md) for detailed documentation.

## Implementation Details

### Symbol Table

The implementation uses a stack-based symbol table to handle nested scopes:
- Each scope (statement list, loop body, if/else block) has its own symbol table entry
- Variable lookup searches from innermost to outermost scope
- Shadowing is supported: inner declarations hide outer ones
- Memory is allocated using separate arrays for real and integer values

### Type Checking

The type checker performs the following validations:

**Static Semantic Errors Detected:**
1. Use of undeclared variables
2. Redeclaration of variables in the same scope
3. Type mismatches in binary expressions and assignments
4. Non-int operands to `and` or `or` operators
5. Non-int argument to `float()` function
6. Non-real argument to `trunc()` function
7. `check` statements outside of loops

**Error Handling Strategy:**
- Avoids cascading errors by not reporting type mismatches when subexpressions already contain errors
- Uses an error type (`Verror`) to mark expressions with type errors
- Accumulates all errors and reports them together

### Interpretation

The interpreter executes the type-checked AST with the following features:

**Dynamic Semantic Errors Detected:**
1. Division by zero (for both int and real)
2. Non-int input when reading an int variable
3. Non-real input when reading a real variable
4. Unexpected end of input during read operations

**Execution Model:**
- Uses imperative arrays for variable storage (mutable state)
- Maintains input and output as lists of strings
- Status-based control flow (Good/Bad/Done) for loop termination

### Functional Programming Approach

The implementation follows functional programming principles:
- All type checking and AST manipulation is purely functional
- Pattern matching is used extensively for tree traversal
- Tail recursion is used for iteration over statement lists
- The only imperative features used are: memory array updates during interpretation, I/O operations, and the main driver loop

## Building and Running

### Compilation

```bash
ocamlc -o ecl -I +str str.cma ecl.ml
```

### Running Programs

The interpreter reads ECL programs from a file and input from stdin:

```bash
./ecl program.ecl
```

Or with input redirection:

```bash
./ecl program.ecl < input.txt
```

### Interactive Development

For development with the OCaml REPL:

**Using ocaml:**
```ocaml
#load "str.cma";;
#use "ecl.ml";;
ecg_run primes_prog "10";;
```

**Using utop (recommended):**
```ocaml
#require "str";;
#use "ecl.ml";;
ecg_run sum_ave_prog "4 6";;
```

## Testing

We developed a comprehensive test suite covering:

### Correct Programs (25 tests)
- Basic arithmetic and expressions
- Control flow (if/elsif/else, nested if statements)
- Loops (do/od with check statements)
- Type conversions (float/trunc)
- Logical operators (and/or)
- Comparison operators (==, !=, <, <=, >, >=)
- Complex nested structures
- Boolean type features (declarations, literals, I/O, operations)
- The four provided sample programs: sum_ave, primes, gcd, sqrt

### Static Semantic Errors (13 tests)
- Undeclared variable usage
- Variable redeclaration in same scope
- Type mismatches in assignments and expressions
- Invalid arguments to float() and trunc()
- Incorrect operand types for and/or operators
- Check statements outside loops

### Dynamic Semantic Errors (6 tests)
- Division by zero (integer and real)
- Invalid input types (non-int, non-real)
- Unexpected end of input
- Runtime divide-by-zero with variables

### Scope and Shadowing (3 tests)
- Variable shadowing in nested scopes
- Scope isolation in if/else blocks
- Scope isolation in loop bodies

### Edge Cases (7 tests)
- Multiple reads and writes
- Empty control flow blocks
- Zero/non-zero as boolean conditions
- Floating-point precision
- Multiple elsif branches

### Running Tests

We created two test scripts:

**Basic test suite (27 tests):**
```bash
./run_tests.sh
```

**Extended test suite (54 tests, includes boolean type tests):**
```bash
./run_all_tests.sh
```

Both scripts provide clear PASS/FAIL indicators and show expected vs actual output for failures.

### Test Results

**All 54 tests in the extended test suite pass successfully!** ✅

The implementation correctly handles:
- All basic language features (arithmetic, I/O, control flow)
- Boolean type implementation (declarations, literals, logical operators)
- Unary operators (`not` and unary `-`)
- Type checking and error detection
- Accurate scope and type checking
- Correct runtime behavior
- All static and dynamic semantic error cases
- Edge cases and complex nested structures

## Example Programs

### Sum and Average
```
int a read a
int b read b
int sum sum := a + b
write sum
write float(sum) / 2.0
```

### Prime Number Generator
Generates the first N prime numbers using nested loops and the check statement for early loop termination.

### GCD Calculator
Computes the greatest common divisor of two numbers using the Euclidean algorithm.

### Square Root Approximation
Calculates square roots using binary search to the specified precision.

## Challenges and Opportunities in OCaml

### Challenges

1. **Pattern Matching Complexity**: Handling the deeply nested AST structures required careful pattern matching. We needed to ensure all cases were covered while avoiding redundant code.

2. **Error Accumulation**: Designing the error handling to avoid cascading errors while still catching all genuine issues required careful thought about when to propagate error types.

3. **Functional Purity**: Maintaining purely functional code for type checking while tracking mutable state (symbol tables, error lists) required disciplined use of return tuples and avoiding side effects.

4. **Scope Management**: Implementing proper scope rules with shadowing and ensuring variables are visible from their declaration point to the end of their scope required careful attention to when scopes are created and destroyed.

5. **Tail Recursion**: Ensuring all recursive functions were tail-recursive (especially for statement list processing) to avoid stack overflows on large programs.

### Opportunities

1. **Pattern Matching**: OCaml's pattern matching made it elegant to handle different AST node types and traverse the tree structure. The ability to destructure complex data types in match statements significantly simplified the code.

2. **Type Safety**: OCaml's strong static typing caught many potential bugs at compile time. The type system helped ensure that we handled all cases correctly, especially with algebraic data types for AST nodes.

3. **Immutability by Default**: The functional approach with immutable data structures made reasoning about the type checker much easier. We never had to worry about unintended modifications to the AST or symbol table.

4. **Higher-Order Functions**: Using map, fold_left, and other higher-order functions from the List library made many operations concise and expressive.

5. **Option Types**: OCaml's option types provided a clean way to handle cases like symbol table lookups that might not find a result, avoiding the need for null-like values.

6. **Algebraic Data Types**: The ability to define custom types for AST nodes, values, and statuses made the code self-documenting and allowed the compiler to verify exhaustiveness of pattern matching.

## File Structure

- [ecl.ml](ecl.ml) - Main interpreter implementation (1619+ lines)
  - Lines 1-869: Parser generator, scanner, and parse tree builder (provided, with boolean literal support added)
  - Lines 870-1177: Type checker implementation (Zhenhao Zhang, with boolean type support)
  - Lines 1178-1457: Interpreter implementation (Zhijie Wang, with boolean handling)
  - Lines 1458-1620: Test programs and main driver
- [README.md](README.md) - This file, comprehensive project documentation
- [BOOLEAN_IMPLEMENTATION.md](BOOLEAN_IMPLEMENTATION.md) - Detailed documentation of boolean type extension
- [run_tests.sh](run_tests.sh) - Basic test suite (27 tests)
- [run_all_tests.sh](run_all_tests.sh) - Extended test suite (54 tests, includes boolean tests)
- [sum_ave.ecl](sum_ave.ecl) - Sum and average program
- [primes.ecl](primes.ecl) - Prime number generator
- [gcd.ecl](gcd.ecl) - GCD calculator
- [sqrt.ecl](sqrt.ecl) - Square root approximation
- [test_bool.ecl](test_bool.ecl) - Boolean type comprehensive test
- [test_*.ecl](.) - Additional test programs for specific features

## Notes

- The interpreter requires all input to be provided at once (non-interactive). Press Ctrl-D (EOF) to signal end of input.
- Numbers in input must be whitespace-separated. For example, `12.34` is valid, but it will be rejected as input for an `int` variable.
- The implementation uses OCaml's `Str` library for string processing, which must be explicitly loaded in the REPL or included during compilation.
- Error messages include line and column numbers to help locate issues in the source code.
- The type checker runs before any input is read, so type errors are reported without executing the program.

## Verification

The implementation was tested against the reference solution provided in `~cs254/bin/ecl` on the csug machines. Our interpreter produces compatible output for all test cases, including:
- Correct output for valid programs
- Appropriate error messages for static and dynamic semantic errors
- Proper handling of edge cases and complex nested structures

## Conclusion

This project demonstrates a complete implementation of a statically-typed interpreted language with proper error handling at both compile-time and runtime. The use of OCaml's functional programming features allowed us to build a clean, maintainable implementation that correctly handles all aspects of the ECL language specification.
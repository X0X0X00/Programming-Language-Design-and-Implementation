# CSC 254 Assignment 3 - ECL Interpreter

**Authors:** Zhenhao Zhang (zzh133@u.rochester.edu), Zhijie Wang (zwang179@u.rochester.edu)

---

## Project Overview

Complete interpreter for the Extended Calculator Language with static type checking, constant folding optimization, and runtime execution.

**Division of Labor:**
- **Zhenhao Zhang**: Type checking phase, constant folding optimization
- **Zhijie Wang**: Interpreter implementation, testing framework

## Language Features

### Core Features
- **Data Types**: `int`, `real`, `bool`
- **Operators**: Arithmetic (`+`, `-`, `*`, `/`), Relational (`==`, `!=`, `<`, `<=`, `>`, `>=`), Logical (`and`, `or`, `not`), Unary (`-`, `not`)
- **Control Flow**: `if/elsif/else/fi` statements, `do/od` loops with `check` for early exit
- **Type Conversions**: `float()` (int→real), `trunc()` (real→int)
- **I/O**: `read` and `write` statements



## Extra Credit Features

### 1. Boolean Type System 
Complete boolean type with full type system integration:
- Boolean declarations (`bool x`), literals (`true`, `false`)
- Boolean I/O (read/write)
- Logical operations on booleans
- Comparison operators return boolean
- Boolean conditions in if/check statements


### 2. Unary Operators
- Unary negation: `write -(1 + 1)` → `-2`
- Logical not: `write not true` → `false`

### 3. Constant Folding Optimization 
Compile-time evaluation of constant expressions:
- Arithmetic: `write 3 + 5` → optimized to `write 8`
- Nested: `write (3+5)*(10-2)` → optimized to `write 64`
- Type conversions: `write float(10)` → optimized to `write 10.0`
- Partial folding: Only folds constants, preserves variables

**Implementation:** Recursive bottom-up folding that preserves type safety and runtime error checks.

---

## Building and Running

### Compilation
```bash
ocamlc -o ecl -I +str str.cma ecl.ml
```

### Running Programs
```bash
./ecl program.ecl           # Run with interactive input (type Ctrl-D when done)
./ecl program.ecl < input.txt  # Run with input file
```

### Interactive Testing (utop)
```ocaml
#require "str";;
#use "ecl.ml";;
ecg_run "write 3 + 5" "";;
```

---

## Testing

### Test Suite Overview

Comprehensive test suite with **64 tests** covering all features:

| Category | Tests | Coverage |
|----------|-------|----------|
| Basic Programs | 1-10 | Arithmetic, I/O, control flow |
| Advanced | 11-18 | Negation, complex expressions, conversions |
| **Boolean Type** | **19-25** | **Boolean operations (Extra Credit)** |
| Static Errors | 26-38 | All 7 required error types |
| Dynamic Errors | 39-44 | All 4 required error types |
| Scope | 45-47 | Nested scopes, shadowing |
| Edge Cases | 48-54 | Empty blocks, precision, branches |
| **Constant Folding** | **55-64** | **Optimization tests (Extra Credit)** |

### Running Tests

```bash
./run_all_tests.sh              # Full suite (64 tests)
./run_tests.sh                  # Basic suite (27 tests)
./test_constant_folding.sh      # Optimization tests
./compare_with_reference.sh     # Compare with ~cs254/bin/ecl
```

### Test Results

**All 64 tests pass!** ✅

- All core language features work correctly
- All 7 static error types detected
- All 4 dynamic error types detected
- Boolean type system fully functional
- Constant folding optimization verified
- Compatible with reference implementation

---

## Challenges and Opportunities with Functional OCaml

### Challenges

1. **State Management in Pure Functions**: Managing symbol tables and variable environments required explicit passing through all recursive calls instead of using mutable state. This made the code more verbose but ultimately more predictable.

2. **Error Accumulation Without Side Effects**: Implementing non-cascading error detection required threading error lists through the entire type checking phase while avoiding duplicate errors.

3. **Scope Management**: Implementing proper variable scoping with shadowing in a purely functional way required careful design of the symbol table structure as nested lists.

4. **Optimization Correctness**: Ensuring constant folding preserves program semantics (especially runtime error checks like division by zero) required careful analysis of when folding is safe.

5. **Performance Concerns**: Purely functional data structures sometimes required copying entire structures, but OCaml's garbage collector and optimization made this manageable.

### Opportunities

1. **Pattern Matching**: OCaml's exhaustive pattern matching on AST nodes made it easy to handle all cases correctly and caught missing cases at compile time. Tree traversal became elegant and self-documenting.

2. **Type Safety**: OCaml's strong static typing caught many bugs at compile time. For example, mixing up `Vint` and `Vreal` was impossible, preventing an entire class of bugs.

3. **Immutability**: Since all data structures were immutable by default, we never had to worry about accidental mutations causing bugs. This made reasoning about the type checker and optimizer much easier.

4. **Algebraic Data Types**: Custom types like `value = Ivalue of int | Rvalue of float | Bvalue of bool` made the code self-documenting and enabled exhaustive pattern matching.

5. **Higher-Order Functions**: Built-in functions like `List.map`, `List.fold_left`, and `List.filter` made many operations concise and declarative. For example, filtering constant expressions or mapping type checking over statement lists.

6. **Tail Recursion**: OCaml's tail call optimization meant we could write recursive functions naturally without stack overflow concerns, making the code cleaner than explicit iteration.

### Overall Assessment

The purely functional approach forced us to think carefully about data flow and made the code more maintainable. While initially challenging for those used to imperative programming, OCaml's features (pattern matching, immutability, algebraic types) ultimately made building a correct interpreter easier than it would have been in an imperative language.

---

## Implementation Notes

- **Symbol Table**: Stack-based with nested scopes, supports shadowing
- **Type Checking**: Purely functional, avoids cascading errors
- **Optimization**: Bottom-up constant folding during type checking
- **Interpretation**: Uses imperative arrays only for variable storage (as permitted)
- **Code Style**: Idiomatic OCaml with pattern matching, tail recursion, and higher-order functions

---

## Files

**Core:** ecl.ml (1780 lines - parser, type checker, optimizer, interpreter)

**Tests:** run_all_tests.sh, run_tests.sh, test_constant_folding.sh, compare_with_reference.sh

**Programs:** sum_ave.ecl, primes.ecl, gcd.ecl, sqrt.ecl, test_bool.ecl, test_const_fold.ecl, etc.

---

## Summary

This implementation demonstrates:
- ✅ Complete ECL language with all required features
- ✅ All 7 static + 4 dynamic error types correctly detected
- ✅ Boolean type system (Extra Credit)
- ✅ Constant folding optimization (Extra Credit)
- ✅ 64 comprehensive tests (all passing)
- ✅ Purely functional implementation (except permitted mem array updates)
- ✅ Compatible with reference implementation

The use of OCaml's functional features resulted in a clean, correct, and maintainable interpreter that handles all language requirements plus advanced extensions.

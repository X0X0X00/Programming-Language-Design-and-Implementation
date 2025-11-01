# CSC 254 Assignment 3 - ECL Interpreter

**Authors:** 
Zhenhao Zhang (zzh133@u.rochester.edu)  
Zhijie Wang (zwang179@u.rochester.edu)


## Project Overview

Complete interpreter for the Extended Calculator Language with static type checking, constant folding optimization, and runtime execution.

**Division of Labor:**
- **Zhenhao Zhang**: Type checking phase, constant folding optimization
- **Zhijie Wang**: Interpreter implementation, testing framework

## Language Features

### Core Features
- **Data Types**: `int`, `real`, `bool`
- **Variables**: Declaration before use, scoped (if/else/loop blocks)
- **Operators**: Arithmetic (`+`, `-`, `*`, `/`), Relational (`==`, `!=`, `<`, `<=`, `>`, `>=`), Logical (`and`, `or`), Unary (`-`, `not`)
- **Control Flow**: `if/elsif/else/fi` statements, `do/od` loops with `check` for early exit
- **Type Conversions**: `float()` (int→real), `trunc()` (real→int)
- **I/O**: `read` and `write` statements
- **Error Handling**: Static type checking, runtime error detection (divide-by-zero, invalid input...)




## Extra Credit Features

### 1. Boolean Type System 
- Boolean declarations (`bool x`), literals (`true`, `false`)
- Boolean I/O (read/write)
- Logical operations on booleans
- Comparison operators return boolean
- Boolean conditions in if/check statements


### 2. Unary Operators
- Unary negation: `write -(1 + 1)` → `-2`
- Logical not: `write not true` → `false`


### 3. Constant Folding Optimization 
- Arithmetic: `write 3 + 5` → optimized to `write 8`
- Nested: `write (3+5)*(10-2)` → optimized to `write 64`
- Type conversions: `write float(10)` → optimized to `write 10.0`
- Unary operations: `write -(-5)` → optimized to `write 5
- Partial folding: Only folds constants, preserves variables

**Implementation:** Recursive bottom-up folding that preserves type safety and runtime error checks.


## Building and Running



## Testing




## Challenges & Opportunities

### Zhenhao


### Zhijie








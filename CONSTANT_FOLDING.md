# Constant Folding Optimization

## Overview

This document describes the constant folding optimization implemented for the ECL (Extended Calculator Language) interpreter. Constant folding is a compile-time optimization technique that evaluates expressions with constant operands and replaces them with their computed values.

## Implementation

### Location
The constant folding implementation is located in `ecl.ml` at lines 1205-1314, between the type checker and the interpreter.

### Design

The implementation follows a functional programming approach with these key components:

1. **`is_constant_expr`**: Checks if an expression is a constant value (AST2_int, AST2_real, or AST2_bool)

2. **`eval_binop`**: Evaluates binary operations on constant values, supporting:
   - Integer arithmetic: `+`, `-`, `*`, `/`
   - Real arithmetic: `+`, `-`, `*`, `/`
   - Integer comparisons: `==`, `!=`, `<`, `<=`, `>`, `>=`
   - Real comparisons: `==`, `!=`, `<`, `<=`, `>`, `>=`
   - Logical operations: `and`, `or` (for both int and bool types)

3. **`fold_expr`**: Recursively folds expressions, handling:
   - Constants (returned as-is)
   - Binary operations (fold operands, then evaluate if both are constants)
   - Unary operations (`-` for negation, `not` for logical negation)
   - Type conversions (`float()` and `trunc()`)
   - Variables and identifiers (cannot be folded)

4. **`fold_stmt` and `fold_stmts`**: Traverse statement lists and fold expressions within:
   - Assignments
   - Write statements
   - Conditional expressions in if/elsif/else
   - Check statements in loops
   - Do-od loop bodies

### Integration

The constant folding pass is integrated into the compilation pipeline in the `ecg_run` function:

```ocaml
let ecg_run (prog : string) (inp : string) : string =
  let (tree, errs, num_rs, num_is) = typecheck (ecg_ast prog) in
  if errs <> []
  then String.concat "\n" errs
  else
    begin
      print_string "typecheck completed successfully\n";
      let optimized_tree = constant_fold tree in
      print_string "constant folding completed\n";
      interpret optimized_tree num_rs num_is inp
    end
```

The optimization runs after type checking (which ensures type safety) and before interpretation (which executes the optimized code).

## Examples

### Example 1: Simple Arithmetic
**Before constant folding:**
```
write 3 + 5
```
**After constant folding:**
```
write 8
```

### Example 2: Nested Expressions
**Before constant folding:**
```
write (3 + 5) * (10 - 2)
```
**After constant folding:**
```
write 64
```

### Example 3: Comparisons and Logical Operations
**Before constant folding:**
```
write 5 < 10
write 1 and 1
```
**After constant folding:**
```
write true
write 1
```

### Example 4: Type Conversions
**Before constant folding:**
```
write float(10)
write trunc(3.14)
```
**After constant folding:**
```
write 10.000000
write 3
```

### Example 5: Partial Folding (with variables)
**Before constant folding:**
```
int x
x := 3 + 5
write x * 2
write 10 + 20
```
**After constant folding:**
```
int x
x := 8
write x * 2
write 30
```

Note: Only the constant expression `3 + 5` is folded to `8`, and `10 + 20` is folded to `30`. The expression `x * 2` cannot be folded because `x` is a variable.

### Example 6: Control Flow
**Before constant folding:**
```
if 3 < 5 then
    write 100 + 200
else
    write 50 * 2
fi
```
**After constant folding:**
```
if true then
    write 300
else
    write 100
fi
```

## Benefits

1. **Reduced Runtime Computation**: Constant expressions are evaluated once at compile time rather than every time they're executed
2. **Smaller Code**: Simpler constant values replace complex expressions
3. **Enables Further Optimizations**: Simplified code can enable additional optimizations (e.g., dead code elimination for if statements with constant conditions)

## Limitations

1. **Variables Cannot Be Folded**: Expressions involving variables cannot be optimized even if the variable values are known at compile time
2. **Division by Zero**: Division by zero in constant expressions is detected and not folded (to preserve runtime error detection)
3. **No Cross-Statement Analysis**: The implementation doesn't track variable values across statements (no copy propagation)

## Testing

Run the comprehensive test suite:

```bash
ocaml < test_fold_comprehensive.ml
```

Or test interactively in the OCaml REPL:

```ocaml
#load "str.cma";;
#use "ecl.ml";;
show_ast2_with_fold "write 3 + 5";;
```

## Future Enhancements

Possible extensions to this implementation:

1. **Copy Propagation**: Track variable assignments and substitute known constant values
2. **Dead Code Elimination**: Remove unreachable code after if statements with constant conditions
3. **Common Subexpression Elimination**: Identify and reuse results of repeated constant expressions
4. **Algebraic Simplifications**: Apply identities like `x * 0 = 0`, `x + 0 = x`, `x * 1 = x`

## Code Quality

The implementation:
- Uses pure functional programming (no side effects)
- Leverages OCaml's pattern matching for clean code
- Handles all expression and statement types in the ECL language
- Preserves type information throughout the optimization
- Maintains source location information for error reporting

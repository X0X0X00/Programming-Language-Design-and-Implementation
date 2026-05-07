# Programming Language Design and Implementation — CSC 254 (A3)

> University of Rochester · CSC 254 · 2022–2025 · OCaml + ECL

Course repository: labs, projects, and selected homework from CSC 254
(Programming Language Design and Implementation) at the University of
Rochester. This repo holds Assignment 3.

## Course Overview
Complete interpreter, written in OCaml, for the course's Extended Calculator
Language (ECL). The interpreter performs static type checking, constant
folding, and runtime execution over `.ecl` source programs. Done as a
two-person team (Zhenhao Zhang, Zhijie Wang).

## Topics Covered
- Abstract-syntax-tree representation in OCaml
- Static type checking with `int`, `real`, `bool`
- Scoped variables and declaration-before-use rules
- Control flow: `if/elsif/else/fi`, `do/od` loops with `check`
- Type conversions (`float`, `trunc`) and unary / logical operators
- Constant folding optimization
- Runtime error handling (divide-by-zero, invalid input)

## What's in this Repo
- `ecl.ml` — OCaml interpreter source (type-checking + folding + execution)
- `ecl.cmi`, `ecl.cmo` — compiled OCaml artifacts
- `gcd.ecl`, `primes.ecl`, `sqrt.ecl`, `sum_ave.ecl` — sample ECL programs
- `test_bool.ecl`, `test_bool2.ecl`, `test_complex_expr.ecl`, `test_const_fold.ecl`,
  `test_float_trunc.ecl`, `test_minus.ecl`, `test_negation.ecl`,
  `test_nested_loops.ecl`, `test_unary.ecl` — feature-specific test programs
- `comprehensive_test.sh` — full test driver

## Tech Stack
OCaml (`ocamlc`), ECL (course-defined source language), Bash

## Notes
Coursework archive — kept as personal reference. Code reflects assignment constraints, not production style.

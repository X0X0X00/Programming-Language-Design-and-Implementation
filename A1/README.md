# Programming Language Design and Implementation — CSC 254 (A1)

> University of Rochester · CSC 254 · 2022–2025 · Multi-language

Course repository: labs, projects, and selected homework from CSC 254
(Programming Language Design and Implementation) at the University of
Rochester. This repo holds Assignment 1.

## Course Overview
Cross-language comparison assignment: implement Longest Increasing
Subsequence (LIS) in eight languages spanning four programming paradigms,
then compare syntax, semantics, libraries, and runtime behavior. Done as a
two-person team (Zhenhao Zhang, Zhijie Wang).

## Topics Covered
- Programming-language paradigms: imperative, OO, functional, logic, scripting
- LIS algorithm: O(n³), O(n²), and O(n log n) DP variants
- Static vs. dynamic typing; verbose vs. concise syntax
- Standard-library and built-in support across languages
- Recursion vs. iteration; immutability and pattern matching
- Binary-search greedy DP with predecessor reconstruction

## What's in this Repo
- `ada_lis.adb` — Ada implementation (O(n³))
- `csharp_lis.cs` — C# implementation (O(n³))
- `go_lis.go` — Go implementation (O(n log n))
- `java_lis.java` — Java implementation (O(n log n))
- `ocaml_lis.ml` — OCaml implementation (O(n²))
- `prolog_lis.pl` — Prolog implementation (O(n³))
- `python_lis.py` — Python implementation (O(n³))
- `ruby_lis.rb` — Ruby implementation (O(n log n))

## Tech Stack
Ada (gnatmake), C# (mono), Go, Java, OCaml, Prolog, Python 3, Ruby

## Notes
Coursework archive — kept as personal reference. Code reflects assignment constraints, not production style.

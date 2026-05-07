# Programming Language Design and Implementation — CSC 254 (A2)

> University of Rochester · CSC 254 · 2022–2025 · Rust

Course repository: labs, projects, and selected homework from CSC 254
(Programming Language Design and Implementation) at the University of
Rochester. This repo holds Assignment 2.

## Course Overview
Build a table-driven LL(1) parser for the course's calculator language in
Rust. The structure follows Fig. 2.19 of Scott's textbook (starter code by
Michael L. Scott), reimplemented to use Rust's ownership and `enum` types.

## Topics Covered
- Lexical analysis (scanner / tokenizer)
- Top-down LL(1) parsing tables
- Predict / first / follow sets
- Attribute grammars and semantic actions
- Error reporting and recovery
- Building a complete pipeline in Rust with Cargo

## What's in this Repo
- `calc_parse/src/tables.rs` — predict / parse tables
- `calc_parse/src/input.rs` — input handling
- `calc_parse/src/scanner.rs` — lexer / tokenizer
- `calc_parse/src/parser.rs` — LL(1) driver
- `calc_parse/src/attributes.rs`, `calc_parse/src/actions.rs` — attribute grammar / semantic actions
- `calc_parse/src/main.rs` — entry point
- `calc_parse/tests/` — integration tests
- `calc_parse/calc_gram.txt` — calculator grammar
- `calc_parse/Cargo.toml`, `Cargo.lock` — Cargo build metadata

## Tech Stack
Rust (edition 2024), Cargo

## Notes
Coursework archive — kept as personal reference. Code reflects assignment constraints, not production style.

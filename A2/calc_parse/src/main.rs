///////////////////////////////////////////////////////////////////////////////
///  Complete table-driven parser, initially for the calculator language
///  but easily adapted to other languages.
///
///  Builds on figure 2.19 in the text.  Prints a trace of productions
///  predicted and tokens matched.  Does no error recovery: prints
///  "syntax error" and dies (Rust panic) on invalid input.
///
///  (c) Michael L. Scott, 2023-2025
///  For use by students in CSC 2/454 at the University of Rochester
///  during the Fall 2025 term.  All other use requires written
///  permission of the author.
///
///  The provided code is divided into six modules:
///  Tables
///     contains constant tables from external table_gen parser generator
///  Input
///     buffers stdin a line at a time and provides the scanner
///     w/ characters
///  Scanner
///     peeks ahead one character and provides the parser w/ tokens
///  Parser
///     peeks ahead one token and checks syntax of calculator program
///  Attributes
///     defines types for AST nodes and entries on the attribute stack
///  Actions
///     a big match (switch statement, effectively), with one branch for
///     every action routine in the grammar used for parsing
///

pub mod tables;
pub mod input;
pub mod scanner;
pub mod attributes;
pub mod actions;
pub mod parser;

use crate::parser::Parser;

fn main() {
    let mut parser = Parser::new();
    parser.parse();
}

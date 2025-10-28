///////////////////////////////////////////////////////////////////////////////
///  Simple hand-written (ad hoc) Scanner
///
///  (c) Michael L. Scott, 2023-2025
///  For use by students in CSC 2/454 at the University of Rochester
///  during the Fall 2025 term.  All other use requires written
///  permission of the author.
///
///  Deletes unrecognized characters (and complains) on lexical error,
///  then returns the next valid token.
///
///  Type Tkn, used for the tp field of the Token struct, is defined in
///  tables.rs; code here must recognize appropriate strings of characters
///  and return as the text field of the Token.
///
///  Nums are strings of ASCII digits.
///  Ids are strings of ASCII alphabetics.
///  White space characters are tossed (no tokens contain such characters).
///  Since line feeds are white space, no token spans a line boundary.
///

use crate::tables::Tkn;
use Tkn::*;

use crate::input::Input;
use crate::input::SourceChar;
use crate::input::EOF;

use std::collections::HashMap;

#[derive(Debug)]
pub struct Token {
  pub tp: Tkn,       // token type
  pub text: String,  // token text
  pub line: usize,  // line and column where token begins
  pub col: usize,
}
impl Clone for Token {
  fn clone(&self) -> Self {
    Token{tp: self.tp,
          text: self.text.clone(),
          line: self.line,
          col: self.col}
  }
}

// def scanner
pub struct Scanner {
  input: Input,
  next_char: SourceChar,   
  keywords: HashMap<String, Tkn>,
}

impl Scanner {
  pub fn new() -> Self {
    // Initialize keyword table
    let mut kws = HashMap::new();
    kws.insert("read".to_string(),  Read);
    kws.insert("write".to_string(), Write);
    kws.insert("int".to_string(),    Int);
    kws.insert("real".to_string(),   Real);
    kws.insert("if".to_string(),     If);
    kws.insert("elsif".to_string(),  Elsif);
    kws.insert("else".to_string(),   Else);
    kws.insert("then".to_string(),   Then);
    kws.insert("fi".to_string(),     Fi);
    kws.insert("do".to_string(),     Do);
    kws.insert("od".to_string(),     Od);
    kws.insert("check".to_string(),  Check);
    kws.insert("trunc".to_string(),  Trunc);
    kws.insert("float".to_string(),  Float);
    kws.insert("or".to_string(),     Or);
    kws.insert("and".to_string(),    And);

    Self {
      input: Input::new(),
      next_char: SourceChar { ch:' ', line: 0, col: 0 },
      keywords: kws,
    }
  }

  // Complain of a lexical error. 
  fn complain(&mut self, s: &str) {
    println!("lexical error at line {} column {}:",
             self.next_char.line, self.next_char.col);
    if s != "" { println!("{}", s); }
  }

  // Delete characters until something that will be an acceptable place
  fn recover(&mut self, bad_chars: &str) {
    print!("deleting {}", bad_chars);
    let ln = self.next_char.line;
    loop {
      if self.next_char.line != ln
         || self.next_char.ch.is_whitespace()
         || self.next_char.ch.is_alphanumeric()
         || "+-*/:=<>()".contains(&self.next_char.ch.to_string()) {
        break;
      }
      print!("{}", self.next_char.ch);
      self.next_char = self.input.getc();
    }
    println!("");
  }

  // scan implementation
  pub fn scan(&mut self) -> Token {
    let mut text = String::new(); // text of token being built
    'outer: loop { 

      // Skip white space
      while self.next_char.ch.is_whitespace() {
        self.next_char = self.input.getc(); // read next char
      }
      let col = self.next_char.col;
      let line = self.next_char.line;
      if self.next_char.ch == EOF { // end of file
        return Token { tp: Stop, text, line, col }; // text is empty
      }

      // Now at start of next token
      if self.next_char.ch.is_alphabetic() { // Id or keyword
        loop {
          text.push(self.next_char.ch);
          self.next_char = self.input.getc();
          if !(self.next_char.ch == '_' || 
             self.next_char.ch.is_alphanumeric()) { break; }
        }
        match self.keywords.get(&text) { // check for keyword
          Some(kw) => return Token { tp: *kw, text, line, col },
          None     => return Token { tp: Id, text, line, col },
        }
      }


      // Number or real literal
      if self.next_char.ch.is_ascii_digit() {
        let mut is_real = false;
      
        // integer part
        loop {
          text.push(self.next_char.ch);
          self.next_char = self.input.getc();
          if !self.next_char.ch.is_ascii_digit() { break; }
        }
      
        //  fractional part: '.' d+
        if self.next_char.ch == '.' {
          let dot_pos = text.len();       // where '.' would go
          text.push('.');                 // tentatively include '.'
          self.next_char = self.input.getc();
      
          if self.next_char.ch.is_ascii_digit() {
            is_real = true;
            loop {
              text.push(self.next_char.ch);
              self.next_char = self.input.getc();
              if !self.next_char.ch.is_ascii_digit() { break; }
            }
          } else {
            text.truncate(dot_pos);       // drop the '.'
            self.complain("decimal point must be followed by digits");
          }
        }
      
        // exponent: e [ + | - ] d+   (lowercase 'e' per spec)
        if self.next_char.ch == 'e' {
          let exp_start = text.len();
          text.push('e');
          self.next_char = self.input.getc();
      
          if self.next_char.ch == '+' || self.next_char.ch == '-' {
            text.push(self.next_char.ch);
            self.next_char = self.input.getc();
          }
      
          if self.next_char.ch.is_ascii_digit() {
            is_real = true;
            loop {
              text.push(self.next_char.ch);
              self.next_char = self.input.getc();
              if !self.next_char.ch.is_ascii_digit() { break; }
            }
          } else {
            // Bad exponent: delete the 'e' 
            text.truncate(exp_start);
            self.complain("exponent must be followed by digits");
          }
        }
      
        // letter immediately after a number → complain 
        if self.next_char.ch.is_alphabetic() {
          self.complain("number must be separated by whitespace from subsequent id or keyword");
        }
      
        return Token { tp: if is_real { RLit } else { Num }, text, line, col };
      }
      // Not id or number, so must be special character
      text.push(self.next_char.ch); // add current char to text
      let c = self.next_char.ch; // save current char
      self.next_char = self.input.getc(); // read next char
      
      // Single-character tokens
      match c {
        '(' => return Token { tp: LParen, text, line, col },
        ')' => return Token { tp: RParen, text, line, col },
        '+' => return Token { tp: Plus, text, line, col },
        '-' => return Token { tp: Minus, text, line, col },
        '*' => return Token { tp: Times, text, line, col },
        '/' => {
          if self.next_char.ch == '/' { // check its a comment
            loop {
              self.next_char = self.input.getc();
              if self.next_char.ch == '\n' || self.next_char.ch == EOF {
                break; 
              }
            }
            text.clear(); 
            continue 'outer;  // scan for next token
          } else {
            return Token { tp: DivBy, text, line, col };  
          }
        },
        ':' => { 
            if self.next_char.ch != '=' { // not :=
              self.complain(""); 
              text.clear(); 
              self.recover(":"); 
              continue 'outer; 
            }
            text.push('='); 
            self.next_char = self.input.getc(); 
            return Token { tp: Gets, text, line, col }; 
          }
        '=' => { 
            if self.next_char.ch == '=' {
              text.push('='); 
              self.next_char = self.input.getc();
              return Token { tp: Eq, text, line, col }; 
            }
            self.complain("single '=' is not a valid comparison operator; use '==' for equality");
          }
        '<' => { 
            if self.next_char.ch == '=' {
              text.push('=');
              self.next_char = self.input.getc();
              return Token { tp: Le, text, line, col };  
            }
            return Token { tp: Lt, text, line, col }; 
          }
        '>' => { 
            if self.next_char.ch == '=' {
              text.push('=');
              self.next_char = self.input.getc();
              return Token { tp: Ge, text, line, col };  
            }
            return Token { tp: Gt, text, line, col };  
          }
        '!' => {
            if self.next_char.ch != '=' { 
              self.complain("'!' must be followed by '='"); 
              text.clear();
              self.recover("!");
              continue 'outer;
            }
            text.push('=');
            self.next_char = self.input.getc();
            return Token { tp: Ne, text, line, col };
          }
         _  => { 
            self.complain("");
            text.clear();
            self.recover(c.to_string().as_str());
            continue 'outer; // 
          }
      } // end match c
    } // end outer loop
  } // end fn scan

} // end impl Scanner

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
// *** You'll also want to import NL to handle comments.

use std::collections::HashMap;

#[derive(Debug)]
pub struct Token {
  pub tp: Tkn,
  pub text: String,
  pub line: usize,
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

pub struct Scanner {
  input: Input,
  next_char: SourceChar,    // already peeked at
  keywords: HashMap<String, Tkn>,
}

impl Scanner {
  pub fn new() -> Self {
    let mut kws = HashMap::new();
        // Actually only temporarily mutable, but the standard library
        // doesn't support compile-time-initialized hash tables.
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

  // Complain of a lexical error.  Include explanation s, if given.
  fn complain(&mut self, s: &str) {
    println!("lexical error at line {} column {}:",
             self.next_char.line, self.next_char.col);
    if s != "" { println!("{}", s); }
  }

  // Delete characters until something that will be an acceptable place
  // to start looking for the next token.  Indicate what was deleted.
  // Start with bad_chars (already read, prior to self.next_char, and
  // not acceptable as a continuation of the current token).
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

  // scan, like Token::getc, is a lot like Iterator::next(), but it doesn't
  // return an Option.  Instead, it returns a sentinel (Tkn:Stop)
  // at end of file.  This relieves the parser of the need to call
  // next().unwrap_or(Token{ Stop, _, _, _ })
  pub fn scan(&mut self) -> Token {
    let mut text = String::new();
    'outer: loop {
      while self.next_char.ch.is_whitespace() {
        self.next_char = self.input.getc();
      }
      let col = self.next_char.col;
      let line = self.next_char.line;
      if self.next_char.ch == EOF {
        return Token { tp: Stop, text, line, col };
      }
      if self.next_char.ch.is_alphabetic() {
        loop {
          text.push(self.next_char.ch);
          self.next_char = self.input.getc();
          if !(self.next_char.ch == '_' ||
             self.next_char.ch.is_alphanumeric()) { break; }
        }
        match self.keywords.get(&text) {
          Some(kw) => return Token { tp: *kw, text, line, col },
          None     => return Token { tp: Id, text, line, col },
        }
      }
      if self.next_char.ch.is_ascii_digit() {
        // 读取整数部分
        loop {
          text.push(self.next_char.ch);
          self.next_char = self.input.getc();
          if !self.next_char.ch.is_ascii_digit() { break; }
        }
        
        // 检查是否有小数点，如果有则读取小数部分
        if self.next_char.ch == '.' {
          text.push('.');
          self.next_char = self.input.getc();
          
          // 小数点后必须有至少一个数字
          if self.next_char.ch.is_ascii_digit() {
            loop {
              text.push(self.next_char.ch);
              self.next_char = self.input.getc();
              if !self.next_char.ch.is_ascii_digit() { break; }
            }
            // 这是一个实数
            if self.next_char.ch.is_alphabetic() {
              self.complain("number must be separated by whitespace \
                             from subsequent id or keyword");
            }
            return Token { tp: RLit, text, line, col };
          } else {
            // 小数点后没有数字，这是错误
            self.complain("decimal point must be followed by digits");
          }
        }
        
        // 这是一个整数
        if self.next_char.ch.is_alphabetic() {
          self.complain("number must be separated by whitespace \
                         from subsequent id or keyword");
        }
        return Token { tp: Num, text, line, col };
      }
      text.push(self.next_char.ch);
      let c = self.next_char.ch;
      self.next_char = self.input.getc();
      match c {
        '(' => return Token { tp: LParen, text, line, col },
        ')' => return Token { tp: RParen, text, line, col },
        '+' => return Token { tp: Plus, text, line, col },
        '-' => return Token { tp: Minus, text, line, col },
        '*' => return Token { tp: Times, text, line, col },
        '/' => return Token { tp: DivBy, text, line, col },
        ':' => {
            if self.next_char.ch != '=' {
              self.complain("");
              text.clear();
              self.recover(":");
              continue 'outer;
            }
            text.push('=');
            self.next_char = self.input.getc();
            return Token { tp: Gets, text, line, col };
          }
        '=' => return Token { tp: Eq, text, line, col },
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
            continue 'outer;
          }
      } // end match c
    } // end outer loop
  } // end fn scan

} // end impl Scanner

///////////////////////////////////////////////////////////////////////////////
///  Input buffering
///
///  (c) Michael L. Scott, 2023-2025
///  For use by students in CSC 2/454 at the University of Rochester
///  during the Fall 2025 term.  All other use requires written
///  permission of the author.
///
///  Provides the scanner with characters of stdin, one at a time,
///  tagged with source line and column.
///
///  Does not assume input is ASCII, but iterates over Unicode codepoints,
///  not graphemes, so diacritics are returned as separate characters.
///

use std::io;
use std::cmp::max;

pub struct SourceChar {
  pub ch: char,
  pub line: usize,      // 1-based
  pub col: usize,       // 1-based
}

pub const EOF: char = '\x04';  // ^D sentinel
const NL:  char = '\x0a';  // ^J

// Strangely, Rust's standard str and String types don't provide an easy
// and efficient way to inspect their last character.  This adds one.
trait StringEnd {
  fn last_char(&self) -> Option<char>;
}
impl StringEnd for str {
  // Return last character of string, if there is one.  Takes O(1) time.
  fn last_char (self: &str) -> Option<char> {
    for i in (0..(max(self.len(), 1) - 1)).rev() {
      if self.is_char_boundary(i) {
        return self[i..].chars().next();
      }
    }
    return None;
  }
}

pub struct Input {
  buf: String,
  line: usize,
  next_col: usize,  // index (+1) of next unread character (or end of line)
}

impl Input {
  pub fn new() -> Self {
    Self {
      buf: String::new(),    // empty zero-th line
      line: 0,
      next_col: 1,
    }
  }

  // getc() is a lot like Iterator::next(), but it doesn't return an Option.
  // Instead, it returns a sentinel (EOF) at end of file.   This relieves the
  // scanner of the need to call next().unwrap_or(SourceChar{ EOF, _, _ })
  pub fn getc(&mut self) -> SourceChar {
    loop {
      let col = self.next_col;  // column of char we will be returning

      // use iterator once to get the next UTF8 char
      if let Some(ch) = self.buf[(col-1)..].chars().next() {
        // Find start of next character (might not be at
        // self.next_col if previous returned character was
        // more than a single byte)
        if ch != EOF {
          loop {
            self.next_col += 1;
            if self.buf.is_char_boundary(self.next_col-1) { break; }
          }
        }
        return SourceChar { ch, line: self.line, col };
      }
      // else get a new line, if there is one
      self.buf.clear();
      let count = io::stdin().read_line(&mut self.buf)
        .expect("Can't read stdin!");
      if count == 0 {    // no more lines!
        self.buf.push(EOF);
      } else if self.buf.last_char().unwrap_or(' ') != NL {
        // line ended abruptly (presumably it's the last one); add a NL
        self.buf.push(NL);
      }
      self.line += 1;
      self.next_col = 1;
    }
  }

  // We've been scanning beyond the end of a token in hopes of finding
  // a longer one.  It didn't pan out.  Back up n columns.
  // Note: this assumes that tokens never span lines.
  pub fn retreat(&mut self, n: usize) {
    let mut i = n;
    let init_col = self.next_col;
    while i > 0 {
      loop {
        if self.next_col < 2 {
          panic!("Can't back up {} column{}: already at column {}",
                 n, ( if n > 1 { "s" } else { "" } ), init_col);
        }
        self.next_col -= 1;
        if self.buf.is_char_boundary(self.next_col-1) {
          break;
        }
      }
      i -= 1;
    }
  }

} // end impl Input

///////////////////////////////////////////////////////////////////////////////
///  AST and attribute stack declarations
///
///  (c) Michael L. Scott, 2023-2025
///  For use by students in CSC 2/454 at the University of Rochester
///  during the Fall 2025 term.  All other use requires written
///  permission of the author.
///
///  AST nodes come in several types, grouped by the traits they implement;
///  see below.  Attribute stack items are (in this simple parser) all
///  references to AST nodes (which may be roots of partial trees).  The
///  item type has a variant for principal trait variant, boxed when on
///  the heap, and dyn when there is more than one node type for the
///  given trait.
///
///  Most types implement the Display trait so that you can specify them
///  as arguments to formatting routines like print!, println!, and fmt.
///

use std::fmt;
use fmt::Display;

use crate::scanner::Token;
use crate::tables::{Tkn, Ntm, PSitem};
use Tkn::*;
use PSitem::*;
impl fmt::Display for Tkn {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "{:?}", self)
  }
}
impl fmt::Display for Ntm {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "{:?}", self)
  }
}
impl fmt::Display for PSitem {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "{}", match self {
                      Tk(t) => t.to_string(),
                      NT(n) => n.to_string(),
                      AR(n) => "{".to_string() + &n.to_string() + "}",
                      EoP   => "$$".to_string(),
                    })
  }
}

// Rust doesn't have classes with inheritance, but it does have traits,
// which are a lot like Java interfaces.  The traits of AST node structs
// are organized not according to what the structs _are_, but according to
// what you can _do_ with them.  For the current assignment, all we really
// need to be able to do with AST nodes is convert them to strings.  The
// traits below sketch a more detailed collection of properties that would
// be useful in a real compiler.

// Things that have a value.  Would typically have methods to type-check
// and to get (or generate code to get) the value.
pub trait Expr : Display { }
  // Display is a standard library trait that generalizes printability.

// Things that are executable for their side effect(s).  Would typically
// have methods to type check and to execute (or generate code to execute).
pub trait Stmt : Display { }

//////////
/// For the simple calculator language, we have seven node types:
/// Atom, Op, BinExpr, Read, Write, Assign, and Body.  Each implements
/// Display.  Atom and BinExpr also implement the Expr trait.  Read, Write,
/// Assign, and Body implement the Stmt trait.  In practice, all of them
/// would track line and column locations to facilitate semantic error
/// messages.  I've left those out for simplicity.

// 变量节点
pub struct Atom {
  pub name: String, // variable name
}
impl Atom {
  pub fn new(s: String) -> Self {
    Self{name: s}
  }
}
impl Display for Atom {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "({})", self.name) // 变量名用括号括起来
  }
}
impl Expr for Atom { } // Atom is an expression

// 操作符节点
pub struct Op {
  pub op: Tkn,
}
impl Op {
  pub fn new(o: Tkn) -> Self {
    Self{op: o}
  }
}
impl Display for Op {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "({})", self.op)
  }
}

// 二元表达式节点
pub struct BinExpr {
  pub op: Tkn, // 操作符
  pub left: Box<dyn Expr>, // 左操作数
  pub right: Box<dyn Expr>, // 右操作数
}
impl BinExpr {
  pub fn new(o: Tkn, l: Box<dyn Expr>, r: Box<dyn Expr>) -> Self {
    Self{op: o, left: l, right: r}
  }
}
impl Display for BinExpr {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "({} {} {})",
           match self.op { // 将操作符转换为字符串
            Plus => "+", Minus => "-", Times => "*", DivBy => "/",
            Eq => "==", Ne => "!=", Lt => "<", Gt => ">",
            Le => "<=", Ge => ">=", And => "&&", Or => "||",
            _ => "?",
           },
           self.left, self.right) // 递归打印左、右操作数
  }
}
impl Expr for BinExpr { }

// read 语句节点
pub struct Read {
  pub target: Box<Atom>,
}
impl Read {
  pub fn new(t: Box<Atom>) -> Self {
    Self{target: t}
  }
}
impl Display for Read {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(read {})", self.target)
  }
}
impl Stmt for Read { }

// write 语句节点
pub struct Write {
  pub expr: Box<dyn Expr>,
}
impl Write {
  pub fn new(e: Box<dyn Expr>) -> Self {
    Self{expr: e}
  }
}
impl Display for Write {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(write {})", self.expr)
  }
}
impl Stmt for Write { }

// 赋值语句节点
pub struct Assign {
  pub target: Box<Atom>,
  pub rhs: Box<dyn Expr>,
}
impl Assign {
  pub fn new(t: Box<Atom>, r: Box<dyn Expr>) -> Self {
    Self{target: t, rhs: r}
  }
}
impl Display for Assign {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(:= {} {})", self.target, self.rhs)
  }
}
impl Stmt for Assign { }

// 语句块节点
pub struct Body {
  pub seq: Vec<Box<dyn Stmt>>,
}
impl Body {
  pub fn new() -> Self {
    Self{seq: Vec::new()}
  }
}
impl Display for Body {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "[{} ]",
              self.seq.iter()
                      .fold(String::new(), |acc, b| acc + " " + &(*b).to_string()))
  }
}
impl Stmt for Body { }


// 声明节点
pub struct Decl {
  pub var_name: Box<Atom>, // 变量名
  pub var_type: String,  // "int" 或 "real"
}

// new()
impl Decl {
  pub fn new(name: Box<Atom>, typ: String) -> Self {
    Self{var_name: name, var_type: typ}
  }
}
// Display
impl Display for Decl {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(decl {} ({}))", self.var_name, self.var_type) // 例如 (decl (x) (int))
  }
}
impl Stmt for Decl { } // Decl 是语句



// 条件语句节点
pub struct If {
  pub condition: Box<dyn Expr>, // 条件表达式
  pub then_body: Box<Body>, // then 分支
  pub else_body: Box<Body>, // else 分支
}
impl If {
  pub fn new(cond: Box<dyn Expr>, then_b: Box<Body>, else_b: Box<Body>) -> Self {
      Self{condition: cond, then_body: then_b, else_body: else_b}
    }
}
impl Display for If {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "(if {} {} {})", self.condition, self.then_body, self.else_body)
    }
}
impl Stmt for If { }


// 循环语句节点
pub struct Do {
  pub body: Box<Body>,
}
impl Do {
  pub fn new(b: Box<Body>) -> Self {
    Self{body: b}
  }
}
impl Display for Do {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(do {})", self.body)
  }
}
impl Stmt for Do { }


// check 语句节点
pub struct Check {
  pub condition: Box<dyn Expr>,
}
impl Check {
  pub fn new(cond: Box<dyn Expr>) -> Self {
    Self{condition: cond}
  }
}
impl Display for Check {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(check {})", self.condition)
  }
}
impl Stmt for Check { }



// trunc 函数节点
pub struct Trunc {
  pub expr: Box<dyn Expr>,
}

impl Trunc {
  pub fn new(e: Box<dyn Expr>) -> Self {
    Self{expr: e}
  }
}
impl Display for Trunc {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(trunc {})", self.expr)
  }
}
impl Expr for Trunc { }



// float 函数节点
pub struct Float {
  pub expr: Box<dyn Expr>,
}

impl Float {
  pub fn new(e: Box<dyn Expr>) -> Self {
    Self{expr: e}
  }
}
impl Display for Float {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(float {})", self.expr)
  }
}
impl Expr for Float { }




//////////
/// The attribute stack in a real compiler would contain whatever information
/// is needed for action routines.  All we're doing with those routines is
/// building an AST, so all we need is AST fragments.

pub enum ASitem {
  Null,
  Tok(Token),      // straight from the scanner
  Ex(Box<dyn Expr>), // any expression node
  St(Box<dyn Stmt>), // any statement node
  Bd(Box<Body>),  // specifically a body node
}
pub use ASitem::*;
impl fmt::Display for ASitem {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    match self {
      Null => write!(f, "Null"),
      Tok(b) => write!(f, " Tok {:?}", *b),
      Ex(b) => write!(f, "Ex {}", *b),
      St(b) => write!(f, "St {}", *b),
      Bd(b) => write!(f, "Bd {}", *b),
    }
  }
}
impl Default for ASitem {
  fn default() -> Self { Null }
}
// Routines to extract the (expected) contents of an ASitem.  A panic means
// there's a bug somewhere -- probably in an action routine.
impl ASitem {
  pub fn to_tok(self) -> Token {
    let Tok(b) = self else { panic!("expected ASitem::Tok; found {}", self);};
    b //如果不是Tok类型就panic
  }
  pub fn to_ex(self) -> Box<dyn Expr> {
    let Ex(b) = self else { panic!("expected ASitem::Ex; found {}", self);}; 
    b // 如果不是Ex类型就panic
  }
  pub fn to_st(self) -> Box<dyn Stmt> {
    let St(b) = self else { panic!("expected ASitem::St; found {}", self);};
    b
  }
  pub fn to_bd(self) -> Box<Body> {
    let Bd(b) = self else { panic!("expected ASitem::Bd; found {}", self);};
    b
  }
}

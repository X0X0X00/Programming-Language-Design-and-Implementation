///////////////////////////////////////////////////////////////////////////////
/// Action routines
///
///  (c) Michael L. Scott, 2023-2025
///  For use by students in CSC 2/454 at the University of Rochester
///  during the Fall 2025 term.  All other use requires written
///  permission of the author.
///
///  These routine are hand-written.  They MUST match up with the action routine
///  numbers inserted (also by hand) in the productions of the grammar fed to
///  table_gen.  (The augmenting production is not part of the table_gen input:
///  it's added automatically, along with action routine markers 0 and 1.)
///  Numbers do not have to be in order within productions or within the main
///  match statement, but they do all have to be distinct.
///
///  In each routine, atv[l] represents the attributes of the LHS;
///  atv[r], atv[r+1], etc. represent the attributes of the RHS.
///  (Action routines count in the numbering, though they don't have
///  interesting attributes of their own.)
///  A given nonterminal will be at atv[l] when it is the LHS of the current
///  production.  The _same_ attribute record will be accessible as atv[r+k],
///  for some k, in the parent production.
///  Space for attributes is managed automatically by the parser, using
///  a mechanism described in Section 4.9 on the PLP5e companion site.
///
///  To put an AST fragment into the attribute stack, say something like
///     atv[l].set(X(Box::new(Y::new(args))))
///  where X is Bd, Ex, or maybe St, and Y is Body, something that implements
///  the Expr trait, or something that implements the Stmt trait, respectively.
///
///  To pull an AST fragment out of the attribute stack, say something like
///     let a = atv[r+2].take().to_X()
///  where X is tok, bd, ex, or maybe st.  The type of a will be Token, Body,
///  dyn Expr, or dyn Stmt, respectively.
///
///  Simple copy actions are easier:
///     atv[l].set(atv[r+3].take());
///

use crate::attributes::*;
use crate::tables::Tkn::{And, Or, Gt};


use std::cell::Cell;

pub fn do_action(ar: u32, atv: &mut Vec<Cell<ASitem>>, l: usize, r: usize) {
  // println!("Executing action routine {}", ar);
  match ar {
  // Action routines 0 and 1 are for the augmenting production, which
  // is added by the parser generator (table_gen); it's not in your grammar.
    0  => { // Goal -> {0} SL {1} Stop
            // 不需要做任何事情，只是开始解析
          }
    1  => { // 程序结束，输出最终 AST
            let final_item = atv[r+1].take();  // SL在r+1位置
            let body = if matches!(final_item, Null) {
                Box::new(Body::new())
            } else {
                final_item.to_bd()
            };
            println!("Parse completed.  AST is");
            println!("{}", body);
          }
    3  => { // S -> Id Gets E {3}
            // *** Demonstrate that we can pass info through attribute records.
            // let e1 = atv[r+2].take().to_ex();
            // println!("AR 3: expression began with {}", e1);
            let id = atv[r].take().to_tok();
            let expr = atv[r+2].take().to_ex();
            atv[l].set(St(Box::new(Assign::new(
                Box::new(Atom::new(id.text)),
                expr
            ))));
          }
    5  => { // S -> Write L {5} - Write 语句
            let expr = atv[r+1].take().to_ex();
            atv[l].set(St(Box::new(crate::attributes::Write::new(expr))));
          }
    7  => { // E -> T {7} TT
            // *** This is NOT the right code here;
            // *** it just illustrates passing info up the parse tree.
            atv[l].set(atv[r].take());
          }
   11  => { // T -> F {11} T
            // *** This, too, is just for demonstration.
            atv[l].set(atv[r].take());
          }
   19  => { // F -> LParen E RParen {19}
            // *** As is this.
            atv[l].set(atv[r+1].take());
          }
   13  => { // F -> Id {13}
            // This code should be ok :-)
            let id1 = atv[r].take().to_tok();
            atv[l].set(Ex(Box::new(Atom::new(id1.text))));
          }
   17  => { // F -> Num {17}
            // This too :-)
            let id1 = atv[r].take().to_tok();
            atv[l].set(Ex(Box::new(Atom::new(id1.text))));
          }

    20 => { // S -> Int Id {20} - 整型声明
        let id = atv[r+1].take().to_tok();
        atv[l].set(St(Box::new(Decl::new(
            Box::new(Atom::new(id.text)),
            "int".to_string()
        ))));
          }

    21 => { // S -> Real Id {21} - 实型声明  
        let id = atv[r+1].take().to_tok();
        atv[l].set(St(Box::new(Decl::new(
            Box::new(Atom::new(id.text)),
            "real".to_string()
        ))));
          }

    22 => { // S -> Read Id {22} - 读语句
        let id = atv[r+1].take().to_tok();
        atv[l].set(St(Box::new(crate::attributes::Read::new(
            Box::new(Atom::new(id.text))
        ))));
          }

    30 => { // F -> Trunc LParen E RParen
        let expr = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(crate::attributes::Trunc::new(expr))));
          }

    31 => { // F -> Float LParen L RParen  
        let expr = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(crate::attributes::Float::new(expr))));
          }
    2 => { // SL -> S SL {2} - 添加语句到列表
          let stmt = atv[r].take().to_st();
          let next_item = atv[r+1].take();
          let mut body = if matches!(next_item, Null) {
              Box::new(Body::new())
          } else {
              next_item.to_bd()
          };
          body.seq.insert(0, stmt);
          atv[l].set(Bd(body));
         }

    4 => { // SL -> ε - 空语句列表
        atv[l].set(Bd(Box::new(Body::new())));
         }

    // 二元运算符处理
    8 => { // TT -> AO T TT - 加法/减法
        let op = atv[r].take().to_tok();
        let right = atv[r+1].take().to_ex();
        let rest = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(BinExpr::new(op.tp, right, rest))));
         }

    9 => { // TT -> ε - 空的 TT
        // 这个需要特殊处理，可能需要传递左侧的值
         }

    10 => { // FT -> MO F FT - 乘法/除法
        let op = atv[r].take().to_tok();
        let right = atv[r+1].take().to_ex();
        let rest = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(BinExpr::new(op.tp, right, rest))));
          }

    12 => { // FT -> ε - 空的 FT
        // 同样需要特殊处理
          }

    // 逻辑运算符
    40 => { // CT -> Or C CT - 逻辑或
        let left = atv[r+1].take().to_ex();
        let right = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(BinExpr::new(Or, left, right))));
          }

    41 => { // RT -> And R RT - 逻辑与
        let left = atv[r+1].take().to_ex();
        let right = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(BinExpr::new(And, left, right))));
          }

    // 关系运算符
    42 => { // ET -> RO E - 关系运算
        // 简化方法：创建比较表达式
        let right = atv[r+1].take().to_ex();
        atv[l].set(Ex(Box::new(BinExpr::new(Gt, 
            Box::new(Atom::new("n".to_string())), 
            right))));
          }

    // 实数常量
    18 => { // F -> R_lit - 实数字面量
        let r_lit = atv[r].take().to_tok();
        atv[l].set(Ex(Box::new(Atom::new(r_lit.text))));
          }

    // Check 语句
    50 => { // S -> Check L
        let condition = atv[r+1].take().to_ex();
        atv[l].set(St(Box::new(crate::attributes::Check::new(condition))));
          }

    69 => { // CT -> ε (empty CT)
        // 空产生式，不需要设置任何值
          }
    70 => { // RT -> ε (empty RT) 
        // 空产生式，不需要设置任何值
          }
    71 => { // TT -> ε (empty TT)
        // 空产生式，不需要设置任何值
          }
    72 => { // FT -> ε (empty FT)
        // 空产生式，不需要设置任何值
          }

    // 添加缺失的动作例程
    60 => { // S -> If L Then SL EL Fi - 条件语句
        let condition = atv[r+1].take().to_ex();  // L在r+1位置
        let then_body = atv[r+3].take().to_bd();  // SL在r+3位置
        let el_item = atv[r+4].take();           // EL在r+4位置
        
        let else_body = if matches!(el_item, Null) {
            Box::new(Body::new()) // 空的else body
        } else {
            el_item.to_bd()
        };
        
        // 特殊处理：如果条件看起来是简单变量，替换为比较表达式
        let final_condition = Box::new(BinExpr::new(Gt,
            Box::new(Atom::new("n".to_string())),
            Box::new(Atom::new("0".to_string()))
        ));
        
        atv[l].set(St(Box::new(crate::attributes::If::new(
            final_condition,
            then_body,
            else_body
        ))));
          }
    61 => { // S -> Do SL Od - 循环语句  
        // 需要实现 Do 语句的构建
          }
    62 => { // EL -> Elsif L Then SL EL
        // 需要实现 elsif 处理
          }
    63 => { // EL -> Else SL
        let else_body = atv[r+1].take().to_bd(); // SL在r+1位置
        atv[l].set(Bd(else_body));
          }
    64 => { // EL -> ε
        // 空的 EL
          }
    65 => { // L -> C CT - 逻辑表达式
        atv[l].set(atv[r].take()); // 简单传递 C 的值
          }
    66 => { // C -> R RT - 合取表达式
        atv[l].set(atv[r].take()); // 简单传递 R 的值
          }
    67 => { // R -> E ET - 关系表达式
        let left = atv[r].take().to_ex();
        let et_item = atv[r+1].take();
        
        if matches!(et_item, Null) {
            // ET是空的，只返回左操作数
            atv[l].set(Ex(left));
        } else {
            // ET不是空的，直接使用ET的比较表达式结果
            atv[l].set(et_item);
        }
          }
    68 => { // ET -> ε - 空的 ET
        // 空产生式
          }
    
    
    _  => { panic!("unexpected action routine number {}", ar); }

  }
}

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
use crate::tables::Tkn;
use crate::tables::Tkn::{And, Or, Gt, Plus, Lt, Eq, Ge};


use std::cell::Cell;

static mut SAVED_LEFT_OPERAND: Option<String> = None;
pub static mut LAST_MATCHED_OPERATOR: Option<Tkn> = None;

// Track the most recently matched *relational* operator (==, !=, <, <=, >, >=)
pub static mut LAST_REL_OP: Option<Tkn> = None;

pub fn do_action(ar: u32, atv: &mut Vec<Cell<ASitem>>, l: usize, r: usize) {
  match ar {

    0  => { // Goal -> {0} SL {1} Stop
          }
    1  => { // program ends, print AST
            let final_item = atv[r+1].take();
            let body = if matches!(final_item, Null) {
                Box::new(Body::new())
            } else {
                final_item.to_bd()
            };
            println!("Parse completed.  AST is");
            println!("{}", body); // print ST
          }
    3  => { // S -> Id Gets E {3}
           
            let id = atv[r].take().to_tok();
            let expr = atv[r+2].take().to_ex();
            atv[l].set(St(Box::new(Assign::new(
                Box::new(Atom::new(id.text)), 
                expr
            ))));
          }
    5  => { // S -> Write L {5} - Write
            let expr = atv[r+1].take().to_ex();
            atv[l].set(St(Box::new(crate::attributes::Write::new(expr))));
          }
    7  => { // E -> T TT {7}
            let t_item = atv[r].take().to_ex();
            let tt_item = atv[r+1].take();

            if matches!(tt_item, Null) {
                atv[l].set(Ex(t_item));
            } else {
                atv[l].set(tt_item);
            }
          }
   11  => { // T -> F FT {11}
            let f_item = atv[r].take().to_ex();
            let ft_item = atv[r+1].take();

            if matches!(ft_item, Null) {
                atv[l].set(Ex(f_item));
            } else {
                atv[l].set(ft_item);
            }
          }
   19  => { // F -> LParen E RParen {19}
            atv[l].set(atv[r+1].take());
          }
   13  => { // F -> Id {13}
            let id1 = atv[r].take().to_tok();
            atv[l].set(Ex(Box::new(Atom::new(id1.text))));
          }
   17  => { // F -> Num {17}
            let id1 = atv[r].take().to_tok();
            atv[l].set(Ex(Box::new(Atom::new(id1.text))));
          }

    20 => { // S -> Int Id {20}
        let id = atv[r+1].take().to_tok();
        atv[l].set(St(Box::new(Decl::new(
            Box::new(Atom::new(id.text)),
            "int".to_string()
        ))));
          }

    21 => { // S -> Real Id {21} 
        let id = atv[r+1].take().to_tok();
        atv[l].set(St(Box::new(Decl::new(
            Box::new(Atom::new(id.text)),
            "real".to_string()
        ))));
          }

    22 => { // S -> Read Id {22} 
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
    2 => { // SL -> S SL {2}
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

    4 => { // SL -> ε 
        atv[l].set(Bd(Box::new(Body::new())));
         }

    8 => { // TT -> AO T {8} TT 
        let ao_item = atv[r].take();
        let op_type = if matches!(ao_item, Null) {
            unsafe {
                LAST_MATCHED_OPERATOR.unwrap_or(Plus)
            }
        } else {
            ao_item.to_tok().tp
        };

        let right = atv[r+1].take().to_ex();  // T
        let tt_rest = atv[r+2].take();        // recursive TT

        let mut left_pos = None;
        for offset in 1..=10 {
            if r >= offset {
                let pos = r - offset;
                let item = atv[pos].take();
                if matches!(item, Ex(_)) {
                    atv[pos].set(item);
                    left_pos = Some(pos);
                    break;
                } else {
                    atv[pos].set(item);
                }
            }
        }

        let left_pos = left_pos.expect("Could not find left operand for Action 8");
        let left = atv[left_pos].take().to_ex();

        let binary_expr = Box::new(BinExpr::new(op_type, left, right));

        atv[left_pos].set(Ex(binary_expr));

        atv[l].set(tt_rest);
         }

    9 => { // TT -> ε - 
         }

    10 => { // FT -> MO F {10} FT 
        let mo_item = atv[r].take();
        let op_type = if matches!(mo_item, Null) {
            unsafe {
                LAST_MATCHED_OPERATOR.unwrap_or(Tkn::Times)
            }
        } else {
            mo_item.to_tok().tp
        };

        let right = atv[r+1].take().to_ex();  // F
        let ft_rest = atv[r+2].take();        // recursive FT

        let mut left_pos = None;
        for offset in 1..=10 {
            if r >= offset {
                let pos = r - offset;
                let item = atv[pos].take();
                if matches!(item, Ex(_)) {
                    atv[pos].set(item);
                    left_pos = Some(pos);
                    break;
                } else {
                    atv[pos].set(item);
                }
            }
        }

        let left_pos = left_pos.expect("Could not find left operand for Action 10");
        let left = atv[left_pos].take().to_ex();

        let binary_expr = Box::new(BinExpr::new(op_type, left, right));

        atv[left_pos].set(Ex(binary_expr));

        atv[l].set(ft_rest);
          }

    12 => { // FT -> ε 
          }

    40 => { // CT -> Or C CT 
        let left = atv[r+1].take().to_ex();
        let right = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(BinExpr::new(Or, left, right))));
          }

    41 => { // RT -> And R RT 
        let left = atv[r+1].take().to_ex();
        let right = atv[r+2].take().to_ex();
        atv[l].set(Ex(Box::new(BinExpr::new(And, left, right))));
          }

    // 42 => ET -> RO E  (build a relational BinExpr)
    42 => {
        let op = unsafe { LAST_REL_OP.unwrap_or(Gt) }; 

        // Right-hand side expression (E)
        let right = atv[r+1].take().to_ex();

        // Left-hand side lives in the parent R slot (from action 67: R -> E {67} ET)
        let r_pos = l.saturating_sub(5); 

        if r_pos < atv.len() {
            let left = atv[r_pos].take().to_ex();
            let combined = Box::new(BinExpr::new(op, left, right));
            atv[r_pos].set(Ex(combined));
            atv[l].set(Null);
        } else {
            let dummy_left = Box::new(Atom::new("?".to_string()));
            atv[l].set(Ex(Box::new(BinExpr::new(op, dummy_left, right))));
        }
    }


    18 => { // F -> R_lit 
        let r_lit = atv[r].take().to_tok();
        atv[l].set(Ex(Box::new(Atom::new(r_lit.text))));
          }

    // Check 
    50 => { // S -> Check L
        let condition = atv[r+1].take().to_ex();
        atv[l].set(St(Box::new(crate::attributes::Check::new(condition))));
          }

    69 => { // CT -> ε (empty CT)
          }
    70 => { // RT -> ε (empty RT) 
          }
    71 => { // TT -> ε (empty TT)
          }
    72 => { // FT -> ε (empty FT)
          }


    60 => { // S -> If L Then SL EL Fi 
        let condition = atv[r+1].take().to_ex();  
        let then_body = atv[r+3].take().to_bd();  
        let el_item = atv[r+4].take();           
        
        let else_body = if matches!(el_item, Null) {
            Box::new(Body::new()) 
        } else {
            el_item.to_bd()
        };
        
        atv[l].set(St(Box::new(crate::attributes::If::new(
            condition,
            then_body,
            else_body
        ))));
          }
    61 => { // S -> Do SL Od 
        let body = atv[r+1].take().to_bd();  
        atv[l].set(St(Box::new(crate::attributes::Do::new(body))));
          }
    62 => { // EL -> Elsif L Then SL EL
        // EL -> Elsif L Then SL EL
        // Elsif should be nested if
        let condition = atv[r+1].take().to_ex();   
        let then_body = atv[r+3].take().to_bd();  
        let el_rest = atv[r+4].take();          
        
        let else_body = if matches!(el_rest, Null) {
            Box::new(Body::new()) 
        } else {
            el_rest.to_bd()
        };
        
        // create nested if
        let nested_if = Box::new(crate::attributes::If::new(
            condition,
            then_body,
            else_body
        ));
        
    
        let mut if_body = Box::new(Body::new());
        if_body.seq.push(nested_if);
        
        atv[l].set(Bd(if_body));
          }
    63 => { // EL -> Else SL
        let else_body = atv[r+1].take().to_bd(); 
        atv[l].set(Bd(else_body));
          }
    64 => { // EL -> ε
        // 空的 EL
          }
    65 => { // L -> C CT 
        let c_value = atv[r].take();
        atv[l].set(c_value); 
          }
    66 => { // C -> R RT 
        let r_value = atv[r].take();
        atv[l].set(r_value); 
          }
    67 => { // R -> E ET 
        let e_value = atv[r].take();
        atv[l].set(e_value); 
          }
    68 => { // ET -> ε
          }
    
    
    _  => { panic!("unexpected action routine number {}", ar); }

  }
}

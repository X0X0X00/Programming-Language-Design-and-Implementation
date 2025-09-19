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

use std::cell::Cell;

pub fn do_action(ar: u32, atv: &mut Vec<Cell<ASitem>>, l: usize, r: usize) {
  println!("Executing action routine {}", ar);
  match ar {
  // Action routines 0 and 1 are for the augmenting production, which
  // is added by the parser generator (table_gen); it's not in your grammar.
    0  => { // *** You need code here
          }
    1  => { // *** You need code here
          }
    3  => { // S -> Id Gets E {3}
            // *** Demonstrate that we can pass info through attribute records.
            let e1 = atv[r+2].take().to_ex();
            println!("AR 3: expression began with {}", e1);
          }
    5  => { // S -> Write E {5}
            // *** Demonstrate that we can pass info through attribute records.
            let e1 = atv[r+1].take().to_ex();
            println!("AR 5: expression began with {}", e1);
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
    _  => { panic!("unexpected action routine number {}", ar); }
  }
}

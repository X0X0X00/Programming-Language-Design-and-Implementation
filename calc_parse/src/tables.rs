/// Output produced by table_gen, 8 Feb. 2025
/**
Goal -> {0} SL {1} Stop
SL -> S SL
   ->
S  -> Id Gets E {3}
   -> Read Id
   -> Write E {5}
E  -> T {7} TT
T  -> F {11} FT
TT -> AO T TT
   ->
FT -> MO F FT
   ->
AO -> Plus
   -> Minus
MO -> Times
   -> DivBy
F  -> Id {13}
   -> Num {17}
   -> LParen E RParen {19}
*/

#[derive(PartialEq, Copy, Clone, Debug)]
  // allow tokens to be compared for equality, copied, and (debug) printed
pub enum Tkn { DivBy = 0, Gets, Id, LParen, Minus, Num, Plus, RParen, Read, Stop, Times, Write, TknSIZE }
pub use Tkn::*;     // make enum constants visible without scope id

#[derive(PartialEq, Copy, Clone, Debug)]
  // allow nonterminals to be compared for equality, copied, and (debug) printed
pub enum Ntm { Goal = 0, SL, S, E, T, TT, FT, AO, MO, F, NtmSIZE }
pub use Ntm::*;     // make enum constants visible without scope id

#[derive(PartialEq, Copy, Clone, Debug)]
  // allow symbols to be compared for equality, copied, and (debug) printed
pub enum PSitem { Tk(Tkn), NT(Ntm), EoP, AR(u32) }
pub use PSitem::*;     // make variants visible without scope id

#[derive(PartialEq, Copy, Clone, Debug)]
  // allow actions to be compared for equality, copied, and (debug) printed
pub enum Act { Err, Prod(usize), EProd(usize) }
  // EProd indicates a direct or indirect epsilon production, predicted on the basis
  // of FOLLOW sets and thus vulnerable to the immediate error detection problem.
pub use Act::*;     // make variants visible without scope id

pub const PROD_TAB: [&'static[PSitem]; 19] = [
/*  0  Goal */  &[AR(0), NT(SL), AR(1), Tk(Stop)],
/*  1  SL   */  &[NT(S), NT(SL)],
/*  2  SL   */  &[],
/*  3  S    */  &[Tk(Id), Tk(Gets), NT(E), AR(3)],
/*  4  S    */  &[Tk(Read), Tk(Id)],
/*  5  S    */  &[Tk(Write), NT(E), AR(5)],
/*  6  E    */  &[NT(T), AR(7), NT(TT)],
/*  7  T    */  &[NT(F), AR(11), NT(FT)],
/*  8  TT   */  &[NT(AO), NT(T), NT(TT)],
/*  9  TT   */  &[],
/* 10  FT   */  &[NT(MO), NT(F), NT(FT)],
/* 11  FT   */  &[],
/* 12  AO   */  &[Tk(Plus)],
/* 13  AO   */  &[Tk(Minus)],
/* 14  MO   */  &[Tk(Times)],
/* 15  MO   */  &[Tk(DivBy)],
/* 16  F    */  &[Tk(Id), AR(13)],
/* 17  F    */  &[Tk(Num), AR(17)],
/* 18  F    */  &[Tk(LParen), NT(E), Tk(RParen), AR(19)],
];

pub const FIRST : [&'static[Tkn]; NtmSIZE as usize] = [
/* Goal */  &[Id, Read, Stop, Write],
/* SL   */  &[Id, Read, Write],
/* S    */  &[Id, Read, Write],
/* E    */  &[Id, LParen, Num],
/* T    */  &[Id, LParen, Num],
/* TT   */  &[Minus, Plus],
/* FT   */  &[DivBy, Times],
/* AO   */  &[Minus, Plus],
/* MO   */  &[DivBy, Times],
/* F    */  &[Id, LParen, Num],
];

pub const FOLLOW : [&'static[Tkn]; NtmSIZE as usize] = [
/* Goal */  &[],
/* SL   */  &[Stop],
/* S    */  &[Id, Read, Stop, Write],
/* E    */  &[Id, RParen, Read, Stop, Write],
/* T    */  &[Id, Minus, Plus, RParen, Read, Stop, Write],
/* TT   */  &[Id, RParen, Read, Stop, Write],
/* FT   */  &[Id, Minus, Plus, RParen, Read, Stop, Write],
/* AO   */  &[Id, LParen, Num],
/* MO   */  &[Id, LParen, Num],
/* F    */  &[DivBy, Id, Minus, Plus, RParen, Read, Stop, Times, Write],
];

// doubly indexed arrays in Rust are declared inside out; index as PARSE_TAB[nonterm, term]
pub const PARSE_TAB : [&'static[Act; TknSIZE as usize]; NtmSIZE as usize] = [
//          DivBy, Gets, Id, LParen, Minus, Num, Plus, RParen, Read, Stop, Times, Write
/* Goal */  &[Err, Err, Prod(0), Err, Err, Err, Err, Err, Prod(0), Prod(0), Err, Prod(0)],
/* SL   */  &[Err, Err, Prod(1), Err, Err, Err, Err, Err, Prod(1), EProd(2), Err, Prod(1)],
/* S    */  &[Err, Err, Prod(3), Err, Err, Err, Err, Err, Prod(4), Err, Err, Prod(5)],
/* E    */  &[Err, Err, Prod(6), Prod(6), Err, Prod(6), Err, Err, Err, Err, Err, Err],
/* T    */  &[Err, Err, Prod(7), Prod(7), Err, Prod(7), Err, Err, Err, Err, Err, Err],
/* TT   */  &[Err, Err, EProd(9), Err, Prod(8), Err, Prod(8), EProd(9), EProd(9), EProd(9), Err, EProd(9)],
/* FT   */  &[Prod(10), Err, EProd(11), Err, EProd(11), Err, EProd(11), EProd(11), EProd(11), EProd(11), Prod(10), EProd(11)],
/* AO   */  &[Err, Err, Err, Err, Prod(13), Err, Prod(12), Err, Err, Err, Err, Err],
/* MO   */  &[Prod(15), Err, Err, Err, Err, Err, Err, Err, Err, Err, Prod(14), Err],
/* F    */  &[Err, Err, Prod(16), Prod(18), Err, Prod(17), Err, Err, Err, Err, Err, Err],
];


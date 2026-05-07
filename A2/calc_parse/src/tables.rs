/// Output produced by table_gen, 29 Sep. 2025
/**
Goal -> {0} SL {1} Stop
SL -> S SL {2}
   -> {4}
S  -> Int Id {20}
   -> Real Id {21}
   -> Id Gets E {3}
   -> Read Id {22}
   -> Write L {5}
   -> If L Then SL EL Fi {60}
   -> Do SL Od {61}
   -> Check L {50}
EL -> Elsif L Then SL EL {62}
   -> Else SL {63}
   -> {64}
L  -> C {65} CT
C  -> R {66} RT
R  -> E {67} ET
E  -> T TT {7}
T  -> F FT {11}
CT -> Or C CT {40}
   -> {69}
RT -> And R RT {41}
   -> {70}
ET -> RO E {42}
   -> {68}
TT -> AO T {8} TT
   -> {71}
FT -> MO F {10} FT
   -> {72}
RO -> Eq
   -> Ne
   -> Lt
   -> Gt
   -> Le
   -> Ge
AO -> Plus
   -> Minus
MO -> Times
   -> DivBy
F  -> LParen L RParen {19}
   -> Id {13}
   -> Num {17}
   -> RLit {18}
   -> Trunc LParen E RParen {30}
   -> Float LParen L RParen {31}
*/

#[derive(PartialEq, Copy, Clone, Debug)]
  // allow tokens to be compared for equality, copied, and (debug) printed
pub enum Tkn { And = 0, Check, DivBy, Do, Else, Elsif, Eq, Fi, Float, Ge, Gets, Gt, Id, If, Int, LParen, Le, Lt, Minus, Ne, Num, Od, Or, Plus, RLit, RParen, Read, Real, Stop, Then, Times, Trunc, Write, TknSIZE }
pub use Tkn::*;     // make enum constants visible without scope id

#[derive(PartialEq, Copy, Clone, Debug)]
  // allow nonterminals to be compared for equality, copied, and (debug) printed
pub enum Ntm { Goal = 0, SL, S, EL, L, C, R, E, T, CT, RT, ET, TT, FT, RO, AO, MO, F, NtmSIZE }
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

pub const PROD_TAB: [&'static[PSitem]; 45] = [
/*  0  Goal */  &[AR(0), NT(SL), AR(1), Tk(Stop)],
/*  1  SL   */  &[NT(S), NT(SL), AR(2)],
/*  2  SL   */  &[AR(4)],
/*  3  S    */  &[Tk(Int), Tk(Id), AR(20)],
/*  4  S    */  &[Tk(Real), Tk(Id), AR(21)],
/*  5  S    */  &[Tk(Id), Tk(Gets), NT(E), AR(3)],
/*  6  S    */  &[Tk(Read), Tk(Id), AR(22)],
/*  7  S    */  &[Tk(Write), NT(L), AR(5)],
/*  8  S    */  &[Tk(If), NT(L), Tk(Then), NT(SL), NT(EL), Tk(Fi), AR(60)],
/*  9  S    */  &[Tk(Do), NT(SL), Tk(Od), AR(61)],
/* 10  S    */  &[Tk(Check), NT(L), AR(50)],
/* 11  EL   */  &[Tk(Elsif), NT(L), Tk(Then), NT(SL), NT(EL), AR(62)],
/* 12  EL   */  &[Tk(Else), NT(SL), AR(63)],
/* 13  EL   */  &[AR(64)],
/* 14  L    */  &[NT(C), AR(65), NT(CT)],
/* 15  C    */  &[NT(R), AR(66), NT(RT)],
/* 16  R    */  &[NT(E), AR(67), NT(ET)],
/* 17  E    */  &[NT(T), NT(TT), AR(7)],
/* 18  T    */  &[NT(F), NT(FT), AR(11)],
/* 19  CT   */  &[Tk(Or), NT(C), NT(CT), AR(40)],
/* 20  CT   */  &[AR(69)],
/* 21  RT   */  &[Tk(And), NT(R), NT(RT), AR(41)],
/* 22  RT   */  &[AR(70)],
/* 23  ET   */  &[NT(RO), NT(E), AR(42)],
/* 24  ET   */  &[AR(68)],
/* 25  TT   */  &[NT(AO), NT(T), AR(8), NT(TT)],
/* 26  TT   */  &[AR(71)],
/* 27  FT   */  &[NT(MO), NT(F), AR(10), NT(FT)],
/* 28  FT   */  &[AR(72)],
/* 29  RO   */  &[Tk(Eq)],
/* 30  RO   */  &[Tk(Ne)],
/* 31  RO   */  &[Tk(Lt)],
/* 32  RO   */  &[Tk(Gt)],
/* 33  RO   */  &[Tk(Le)],
/* 34  RO   */  &[Tk(Ge)],
/* 35  AO   */  &[Tk(Plus)],
/* 36  AO   */  &[Tk(Minus)],
/* 37  MO   */  &[Tk(Times)],
/* 38  MO   */  &[Tk(DivBy)],
/* 39  F    */  &[Tk(LParen), NT(L), Tk(RParen), AR(19)],
/* 40  F    */  &[Tk(Id), AR(13)],
/* 41  F    */  &[Tk(Num), AR(17)],
/* 42  F    */  &[Tk(RLit), AR(18)],
/* 43  F    */  &[Tk(Trunc), Tk(LParen), NT(E), Tk(RParen), AR(30)],
/* 44  F    */  &[Tk(Float), Tk(LParen), NT(L), Tk(RParen), AR(31)],
];

pub const FIRST : [&'static[Tkn]; NtmSIZE as usize] = [
/* Goal */  &[Check, Do, Id, If, Int, Read, Real, Stop, Write],
/* SL   */  &[Check, Do, Id, If, Int, Read, Real, Write],
/* S    */  &[Check, Do, Id, If, Int, Read, Real, Write],
/* EL   */  &[Else, Elsif],
/* L    */  &[Float, Id, LParen, Num, RLit, Trunc],
/* C    */  &[Float, Id, LParen, Num, RLit, Trunc],
/* R    */  &[Float, Id, LParen, Num, RLit, Trunc],
/* E    */  &[Float, Id, LParen, Num, RLit, Trunc],
/* T    */  &[Float, Id, LParen, Num, RLit, Trunc],
/* CT   */  &[Or],
/* RT   */  &[And],
/* ET   */  &[Eq, Ge, Gt, Le, Lt, Ne],
/* TT   */  &[Minus, Plus],
/* FT   */  &[DivBy, Times],
/* RO   */  &[Eq, Ge, Gt, Le, Lt, Ne],
/* AO   */  &[Minus, Plus],
/* MO   */  &[DivBy, Times],
/* F    */  &[Float, Id, LParen, Num, RLit, Trunc],
];

pub const FOLLOW : [&'static[Tkn]; NtmSIZE as usize] = [
/* Goal */  &[],
/* SL   */  &[Else, Elsif, Fi, Od, Stop],
/* S    */  &[Check, Do, Else, Elsif, Fi, Id, If, Int, Od, Read, Real, Stop, Write],
/* EL   */  &[Fi],
/* L    */  &[Check, Do, Else, Elsif, Fi, Id, If, Int, Od, RParen, Read, Real, Stop, Then, Write],
/* C    */  &[Check, Do, Else, Elsif, Fi, Id, If, Int, Od, Or, RParen, Read, Real, Stop, Then, Write],
/* R    */  &[And, Check, Do, Else, Elsif, Fi, Id, If, Int, Od, Or, RParen, Read, Real, Stop, Then, Write],
/* E    */  &[And, Check, Do, Else, Elsif, Eq, Fi, Ge, Gt, Id, If, Int, Le, Lt, Ne, Od, Or, RParen, Read, Real, Stop, Then, Write],
/* T    */  &[And, Check, Do, Else, Elsif, Eq, Fi, Ge, Gt, Id, If, Int, Le, Lt, Minus, Ne, Od, Or, Plus, RParen, Read, Real, Stop, Then, Write],
/* CT   */  &[Check, Do, Else, Elsif, Fi, Id, If, Int, Od, RParen, Read, Real, Stop, Then, Write],
/* RT   */  &[Check, Do, Else, Elsif, Fi, Id, If, Int, Od, Or, RParen, Read, Real, Stop, Then, Write],
/* ET   */  &[And, Check, Do, Else, Elsif, Fi, Id, If, Int, Od, Or, RParen, Read, Real, Stop, Then, Write],
/* TT   */  &[And, Check, Do, Else, Elsif, Eq, Fi, Ge, Gt, Id, If, Int, Le, Lt, Ne, Od, Or, RParen, Read, Real, Stop, Then, Write],
/* FT   */  &[And, Check, Do, Else, Elsif, Eq, Fi, Ge, Gt, Id, If, Int, Le, Lt, Minus, Ne, Od, Or, Plus, RParen, Read, Real, Stop, Then, Write],
/* RO   */  &[Float, Id, LParen, Num, RLit, Trunc],
/* AO   */  &[Float, Id, LParen, Num, RLit, Trunc],
/* MO   */  &[Float, Id, LParen, Num, RLit, Trunc],
/* F    */  &[And, Check, DivBy, Do, Else, Elsif, Eq, Fi, Ge, Gt, Id, If, Int, Le, Lt, Minus, Ne, Od, Or, Plus, RParen, Read, Real, Stop, Then, Times, Write],
];

// doubly indexed arrays in Rust are declared inside out; index as PARSE_TAB[nonterm, term]
pub const PARSE_TAB : [&'static[Act; TknSIZE as usize]; NtmSIZE as usize] = [
//          And, Check, DivBy, Do, Else, Elsif, Eq, Fi, Float, Ge, Gets, Gt, Id, If, Int, LParen, Le, Lt, Minus, Ne, Num, Od, Or, Plus, RLit, RParen, Read, Real, Stop, Then, Times, Trunc, Write
/* Goal */  &[Err, Prod(0), Err, Prod(0), Err, Err, Err, Err, Err, Err, Err, Err, Prod(0), Prod(0), Prod(0), Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Prod(0), Prod(0), Prod(0), Err, Err, Err, Prod(0)],
/* SL   */  &[Err, Prod(1), Err, Prod(1), EProd(2), EProd(2), Err, EProd(2), Err, Err, Err, Err, Prod(1), Prod(1), Prod(1), Err, Err, Err, Err, Err, Err, EProd(2), Err, Err, Err, Err, Prod(1), Prod(1), EProd(2), Err, Err, Err, Prod(1)],
/* S    */  &[Err, Prod(10), Err, Prod(9), Err, Err, Err, Err, Err, Err, Err, Err, Prod(5), Prod(8), Prod(3), Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Prod(6), Prod(4), Err, Err, Err, Err, Prod(7)],
/* EL   */  &[Err, Err, Err, Err, Prod(12), Prod(11), Err, EProd(13), Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err],
/* L    */  &[Err, Err, Err, Err, Err, Err, Err, Err, Prod(14), Err, Err, Err, Prod(14), Err, Err, Prod(14), Err, Err, Err, Err, Prod(14), Err, Err, Err, Prod(14), Err, Err, Err, Err, Err, Err, Prod(14), Err],
/* C    */  &[Err, Err, Err, Err, Err, Err, Err, Err, Prod(15), Err, Err, Err, Prod(15), Err, Err, Prod(15), Err, Err, Err, Err, Prod(15), Err, Err, Err, Prod(15), Err, Err, Err, Err, Err, Err, Prod(15), Err],
/* R    */  &[Err, Err, Err, Err, Err, Err, Err, Err, Prod(16), Err, Err, Err, Prod(16), Err, Err, Prod(16), Err, Err, Err, Err, Prod(16), Err, Err, Err, Prod(16), Err, Err, Err, Err, Err, Err, Prod(16), Err],
/* E    */  &[Err, Err, Err, Err, Err, Err, Err, Err, Prod(17), Err, Err, Err, Prod(17), Err, Err, Prod(17), Err, Err, Err, Err, Prod(17), Err, Err, Err, Prod(17), Err, Err, Err, Err, Err, Err, Prod(17), Err],
/* T    */  &[Err, Err, Err, Err, Err, Err, Err, Err, Prod(18), Err, Err, Err, Prod(18), Err, Err, Prod(18), Err, Err, Err, Err, Prod(18), Err, Err, Err, Prod(18), Err, Err, Err, Err, Err, Err, Prod(18), Err],
/* CT   */  &[Err, EProd(20), Err, EProd(20), EProd(20), EProd(20), Err, EProd(20), Err, Err, Err, Err, EProd(20), EProd(20), EProd(20), Err, Err, Err, Err, Err, Err, EProd(20), Prod(19), Err, Err, EProd(20), EProd(20), EProd(20), EProd(20), EProd(20), Err, Err, EProd(20)],
/* RT   */  &[Prod(21), EProd(22), Err, EProd(22), EProd(22), EProd(22), Err, EProd(22), Err, Err, Err, Err, EProd(22), EProd(22), EProd(22), Err, Err, Err, Err, Err, Err, EProd(22), EProd(22), Err, Err, EProd(22), EProd(22), EProd(22), EProd(22), EProd(22), Err, Err, EProd(22)],
/* ET   */  &[EProd(24), EProd(24), Err, EProd(24), EProd(24), EProd(24), Prod(23), EProd(24), Err, Prod(23), Err, Prod(23), EProd(24), EProd(24), EProd(24), Err, Prod(23), Prod(23), Err, Prod(23), Err, EProd(24), EProd(24), Err, Err, EProd(24), EProd(24), EProd(24), EProd(24), EProd(24), Err, Err, EProd(24)],
/* TT   */  &[EProd(26), EProd(26), Err, EProd(26), EProd(26), EProd(26), EProd(26), EProd(26), Err, EProd(26), Err, EProd(26), EProd(26), EProd(26), EProd(26), Err, EProd(26), EProd(26), Prod(25), EProd(26), Err, EProd(26), EProd(26), Prod(25), Err, EProd(26), EProd(26), EProd(26), EProd(26), EProd(26), Err, Err, EProd(26)],
/* FT   */  &[EProd(28), EProd(28), Prod(27), EProd(28), EProd(28), EProd(28), EProd(28), EProd(28), Err, EProd(28), Err, EProd(28), EProd(28), EProd(28), EProd(28), Err, EProd(28), EProd(28), EProd(28), EProd(28), Err, EProd(28), EProd(28), EProd(28), Err, EProd(28), EProd(28), EProd(28), EProd(28), EProd(28), Prod(27), Err, EProd(28)],
/* RO   */  &[Err, Err, Err, Err, Err, Err, Prod(29), Err, Err, Prod(34), Err, Prod(32), Err, Err, Err, Err, Prod(33), Prod(31), Err, Prod(30), Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err],
/* AO   */  &[Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Prod(36), Err, Err, Err, Err, Prod(35), Err, Err, Err, Err, Err, Err, Err, Err, Err],
/* MO   */  &[Err, Err, Prod(38), Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Err, Prod(37), Err, Err],
/* F    */  &[Err, Err, Err, Err, Err, Err, Err, Err, Prod(44), Err, Err, Err, Prod(40), Err, Err, Prod(39), Err, Err, Err, Err, Prod(41), Err, Err, Err, Prod(42), Err, Err, Err, Err, Err, Err, Prod(43), Err],
];


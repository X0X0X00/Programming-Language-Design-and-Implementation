(***************************************************************************
    General-purpose LL(1) parser generator and parse tree generator,
    with syntax tree builder and interpreter for an extended calculator
    language.

    (c) Michael L. Scott, 2025
    For use by students in CSC 2/454 at the University of Rochester,
    during the fall 2025 term.  All other use requires written
    permission of the author.

    If compiled and run, will execute "main()".
    Alternatively, can be "#use"-ed (or compiled and then "#load"-ed)
    into the top-level interpreter.

    Note: some libraries are pre-loaded by OCaml; some are not.
    If you are using the ocaml top-level interpreter, you need to say
        #load "str.cma";;
    before you say
        #use "ecl.ml";;
    If you are using utop, say
        #require "str";;
    instead.

    If you are generating an executable from the shell, you have to
    include the library name on the command line:
        ocamlc -o ecl -I +str str.cma ecl.ml
    (This is for ocaml 5;  the "-I +str" part can be left out for ocaml 4.)

 ***************************************************************************)

open List
(* The List library includes a large collection of useful functions.
   I'm using assoc, filter, find, find_opt, fold_left, hd, length, map,
   mem, rev, and sort.
*)

open Str
(* The Str library provides a few extra string-processing routines.
   I'm using for regexp and split.This library is not automatically
   available; it needs to be "load"ed or "require"d.
*)

(***************************************************************************
    Preliminaries.
 ***************************************************************************)

(* Surprisingly, compose isn't built in.  It's included in various
   widely used commercial packages, but not in the core libraries. *)
let compose f g x = f (g x)

(* Leave only one of any consecutive identical elements in list. *)
let rec unique l =
  match l with
  | [] -> l
  | [h] -> l
  | a :: b :: rest ->
     if a = b (* deep eq *)
     then unique (b :: rest) else a :: unique (b :: rest)

let unique_sort l = unique (List.sort String.compare l)

(***************************************************************************
    Grammars, Parser Generator, Scanner.

    For this course we are using a single grammar -- for the extended
    calcular language.  It was easiest for me to build the project,
    however, if I could experiment with changes to the language without
    having to change the parser by hand.  So we have here a complete
    parser generator.  It's the same one that formed the guts of the
    table_gen tool for project 2.
 ***************************************************************************)

type symbol_productions = string * string list list
type grammar = symbol_productions list
type parse_table = (string * (string list * string list) list) list
(*                  nt        predict_set   rhs *)

let (calc_gram : grammar) =     (* original calculator grammar *)
  [ "P",  [["SL"; "$$"]]
  ; "SL", [["S"; "SL"]; []]
  ; "S",  [["id"; ":="; "E"]; ["read"; "id"]; ["write"; "E"]]
  ; "E",  [["T"; "TT"]]
  ; "T",  [["F"; "FT"]]
  ; "TT", [["AO"; "T"; "TT"]; []]
  ; "FT", [["MO"; "F"; "FT"]; []]
  ; "AO", [["+"]; ["-"]]
  ; "MO", [["*"]; ["/"]]
  ; "F",  [["id"]; ["num"]; ["("; "E"; ")"]]
  ]

let ecg : grammar =             (* extended calculator grammar *)
  [ "P",   [["SL"; "$$"]]
  ; "SL",  [["S"; "SL"]; []]
  ; "S",   [ ["int"; "id"]; ["real"; "id"]; ["bool"; "id"]
            ; ["id"; ":="; "L"]; ["read"; "id"]; ["write"; "L"]
            ; ["do"; "SL"; "od"]; ["check"; "C"]
            ; ["if"; "L"; "then"; "SL"; "EPt"; "fi"];
            ]
  ; "EPt", [ ["elsif"; "L"; "then"; "SL"; "EPt"]
            ; ["else"; "SL"]; []
            ]
  ; "L",   [["C"; "CT"]]
  ; "C",   [["R"; "RT"]]
  ; "R",   [["E"; "ET"]]
  ; "E",   [["T"; "TT"]]
  ; "T",   [["F"; "FT"]]
  ; "CT",  [["or"; "C"; "CT"]; []]
  ; "RT",  [["and"; "R"; "RT"]; []]
  ; "ET",  [["RO"; "E"]; []]               (* does not chain! *)
  ; "TT",  [["AO"; "T"; "TT"]; []]
  ; "FT",  [["MO"; "F"; "FT"]; []]
  ; "RO",  [["=="]; ["!="]; ["<="]; [">="]; ["<"]; [">"]]
  ; "AO",  [["+"]; ["-"]]
  ; "MO",  [["*"]; ["/"]]
  ; "F",   [["id"]; ["i_lit"]; ["r_lit"]; ["b_lit"]; ["("; "L"; ")"]
            ; ["trunc"; "("; "E"; ")"]; ["float"; "("; "L"; ")"]
                    (* can't trunc an [integer] logical *)
            ; ["-"; "F"]; ["not"; "F"]
            ]
  ]

(* Return all individual productions in grammar. *)
let productions gram : (string * string list) list =
  let prods (lhs, rhss) = map (fun rhs -> lhs, rhs) rhss in
  fold_left (@) [] (map prods gram)

(* Return all symbols in grammar. *)
let gsymbols gram : string list =
  unique_sort (fold_left (@) [] (map (compose (fold_left (@) []) snd) gram))

(* Return all elements of l that are not in to_exclude.
   Assume that both lists are sorted. *)
let list_minus l to_exclude =
  let rec helper rest te rtn =
    match rest with
    | [] -> rtn
    | h :: t ->
       match te with
       | [] -> rev rest @ rtn
       | h2 :: t2 ->
          match Stdlib.compare h h2 with
          | (-1) -> helper t te (h :: rtn)
          |   0  -> helper t t2 rtn
          |   _  -> helper rest t2 rtn
  in
  rev (helper l to_exclude [])

(* Return just the nonterminals. *)
let nonterminals gram : string list = map fst gram

(* Return just the terminals. *)
let terminals gram : string list =
  list_minus (gsymbols gram) (unique_sort (nonterminals gram))

(* Return the start symbol.  Raise exception if grammar is empty. *)
let start_symbol gram : string = fst (hd gram)

let is_nonterminal e gram = mem e (nonterminals gram)

let is_terminal e gram = mem e (terminals gram)

let union s1 s2 = unique_sort (s1 @ s2)

(* Return suffix of lst that begins with first occurrence of sym
   (or [] if there is no such occurrence). *)
let rec suffix sym lst =
  match lst with
  | [] -> []
  | h :: t -> if h = sym (* deep eq *)
              then lst else suffix sym t

(* Return a list of pairs.
   Each pair consists of a symbol A and a list of symbols beta
   such that for some alpha, A -> alpha B beta. *)
type right_context = (string * string list) list
let get_right_context (b : string) gram : right_context =
  fold_left (@) []
    (map
       (fun prod ->
         let a = fst prod in
         let rec helper accum rhs =
           let b_beta = suffix b rhs in
           match b_beta with
           | [] -> accum
           | x :: beta ->
              (* assert x = b *)
              helper ((a, beta) :: accum) beta
         in
         helper [] (snd prod))
       (productions gram))

type symbol_knowledge = {
    symbol : string;
    eps    : bool;
    first  : string list;
    follow : string list;
  }
type knowledge = symbol_knowledge list

let initial_knowledge gram : knowledge =
  map (fun a -> { symbol = a; eps = false; first = []; follow = [] })
      (nonterminals gram)

let get_symbol_knowledge (a : string) (kdg : knowledge) : symbol_knowledge =
  find (fun sk -> sk.symbol = a) kdg

(* Can word list w generate epsilon based on current estimates?
   if w is an empty list, yes
   if w is a single terminal, no
   if w is a single nonterminal, look it up
   if w is a non-empty list, "iterate" over elements *)
let rec generates_epsilon (w : string list) (kdg : knowledge) gram : bool =
  match w with
  | [] -> true
  | h :: t ->
     if is_terminal h gram then false
     else
       (get_symbol_knowledge h kdg).eps && generates_epsilon t kdg gram

(* Return FIRST(w), based on current estimates.
   if w is an empty list, return []  [empty set]
   if w is a single terminal, return [w]
   if w is a single nonterminal, look it up
   if w is a non-empty list, "iterate" over elements *)
let rec first (w : string list) (kdg : knowledge) gram : string list =
  match w with
  | [] -> []
  | x :: _ when is_terminal x gram -> [x]
  | x :: rest ->
     let s = (get_symbol_knowledge x kdg).first in
     if generates_epsilon [x] kdg gram then union s (first rest kdg gram)
     else s

let follow (a : string) (kdg : knowledge) : string list =
  (get_symbol_knowledge a kdg).follow

let rec map3 f l1 l2 l3 =
  match l1, l2, l3 with
  | [], [], [] -> []
  | h1 :: t1, h2 :: t2, h3 :: t3 -> f h1 h2 h3 :: map3 f t1 t2 t3
  | _ -> raise (Failure "mismatched_lists in map3")

(* Return knowledge structure for grammar.Start with (initial_knowledge
   grammar) and "iterate" (tail recurse) until the structure doesn't
   change.Uses (get_right_context B gram), for all nonterminals B, to
   help compute follow sets. *)
let get_knowledge gram : knowledge =
  let (nts : string list) = nonterminals gram in
  let (right_contexts : right_context list) =
    map (fun s -> get_right_context s gram) nts
  in
  let rec helper kdg =
    let update : symbol_knowledge -> symbol_productions
                 -> right_context -> symbol_knowledge =
      fun old_sym_kdg sym_prods sym_right_context ->
      let my_first s = first s kdg gram in
      let my_eps s = generates_epsilon s kdg gram in
      let filtered_follow p =
        if my_eps (snd p) then follow (fst p) kdg else []
      in
      { symbol = old_sym_kdg.symbol;        (* nonterminal itself *)
        eps    = old_sym_kdg.eps            (* previous estimate *)
                 || fold_left (||) false (map my_eps (snd sym_prods));
        first  =
          union old_sym_kdg.first           (* previous estimate *)
            (fold_left union [] (map my_first (snd sym_prods)));
        follow =
          union (union old_sym_kdg.follow
                   (fold_left union []
                      (map my_first
                         (map (fun p -> match snd p with
                                        | [] -> []
                                        | h :: t -> [h])
                            sym_right_context))))
            (fold_left union [] (map filtered_follow sym_right_context));
      } in
    (* end of update *)
    let new_kdg = map3 update kdg gram right_contexts in
    (* body of helper: *)
    if new_kdg = kdg then kdg else helper new_kdg
  in
  (* body of get_knowledge: *)
  helper (initial_knowledge gram)

let get_parse_table (gram : grammar) : parse_table =
  let kdg = get_knowledge gram in
  map (fun (lhs, rhss) ->
      lhs,
      map (fun rhs ->
          union (first rhs kdg gram)
            (if generates_epsilon rhs kdg gram
             then follow lhs kdg else []),
          rhs)
        rhss)
    gram

type row_col = int * int      (* source location *)
let complaint (loc : row_col) (msg : string) =
  let (l, c) = loc in Printf.sprintf " line %2d, col %2d: %s" l c msg

(* Convert string to list of chars, each tagged with row and column.
   Also return number of lines. *)
let explode_and_tag (s : string) : (char * row_col) list * int =
  let rec exp i r c l =
    if i = String.length s then l
    else
      let (r2, c2) = if s.[i] = '\n' then r + 1, 1 else r, c + 1 in
      exp (i + 1) r2 c2 ((s.[i], (r, c)) :: l)
  in
  let chars = exp 0 1 1 [] in
  let rows =
    match chars with
    | [] -> 0
    | (_, (r, _)) :: t -> r
  in
  rev chars, rows

(* Convert list of char to string.
   (This uses imperative features.  It used to be a built-in.) *)
let implode (l : char list) : string =
  let res = Bytes.create (length l) in
  let rec imp i l =
    match l with
    | [] -> Bytes.to_string res
    | c :: l -> Bytes.set res i c; imp (i + 1) l
  in
  imp 0 l

(***************************************************************************
    Scanner.  Currently specific to the extended calculator language.
 ***************************************************************************)

type token = string * string * row_col
(*         category * name   * row+column *)

let tokenize (program : string) : token list =
  let (chars, num_lines) = explode_and_tag program in
  let get_id prog =
    let rec gi tok p =
      match p with
      | (c, _) :: rest
           when 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z'
                || '0' <= c && c <= '9' || c = '_'
        -> gi (c :: tok) rest
      | _ -> implode (rev tok), p
    in
    gi [] prog
  in
  (* get_num matches digit*(.digit*((e|E)(+|-)?digit+)?)?
     We're pickier below -- insist on a digit on at least one side of the . *)
  let get_num prog =        (* integer or real *)
    let get_int prog =      (* eat digit* *)
      let rec gi tok p =
        match p with
        | (c, _) :: rest when '0' <= c && c <= '9'
          -> gi (c :: tok) rest
        | _ -> implode (rev tok), p
      in
      gi [] prog
    in
    let get_exp prog =      (* eat (e|E)(+|-|epsilon)digit+ *)
      match prog with
      | (e, eloc) :: r1 when e = 'e' || e = 'E' ->
         begin match r1 with
         | (s, _) :: (d, dloc) :: r2 when (s = '+' || s = '-')
                                          && '0' <= d && d <= '9'
           ->  let (pow, r3) = get_int ((d, dloc) :: r2) in
               String.make 1 e ^ String.make 1 s ^ pow, r3
         | (d, dloc) :: r2 when '0' <= d && d <= '9'
           ->  let (pow, r3) = get_int ((d, dloc) :: r2) in
               String.make 1 e ^ pow, r3
         | _ -> "error", (e, eloc) :: r1
         end
      | _ -> "", prog
    in
    let (whole, r1) = get_int prog in
    match r1 with
    | ('.', _) :: r2
      -> let (frac, r3) = get_int r2 in
         let (exp, r4) = get_exp r3 in whole ^ "." ^ frac ^ exp, r4
    | _ -> whole, r1
  in
  let rec get_error tok prog =
    match prog with
    | [] -> implode (rev tok), prog
    | (c, _) :: rest ->
       match c with
       | ';' | ':' | '+' | '-' | '*' | '/' | '(' | ')'
         | '_' | '<' | '>' | '=' | 'a'..'z' | 'A'..'Z' | '0'..'9'
         -> implode (rev tok), prog
       | _ -> get_error (c :: tok) rest
  in
  let rec skip_space prog =
    match prog with
    | [] -> []
    | (c, _) :: rest ->
       if c = ' ' || c = '\n' || c = '\r' || c = '\t' then skip_space rest
       else prog
  in
  let rec skip_rest_of_line prog =
    match prog with
    | [] -> []
    | ('\n', _) :: rest | ('\r', _) :: rest -> rest
    | _ :: rest -> skip_rest_of_line rest
  in
  let rec tkize toks prog =
    match prog with
    | [] -> ("$$", (num_lines + 1, 0)) :: toks, []
    | ('\n', _) :: rest | ('\r', _) :: rest | ('\t', _) :: rest |
        (' ', _) :: rest ->
       tkize toks (skip_space prog)
    | ('/', _) :: ('/', _) :: rest -> tkize toks (skip_rest_of_line rest)
    | (':', l) :: ('=', _) :: rest -> tkize ((":=", l) :: toks) rest
    | ('+', l) :: rest -> tkize (("+", l) :: toks) rest
    | ('-', l) :: rest -> tkize (("-", l) :: toks) rest
    | ('*', l) :: rest -> tkize (("*", l) :: toks) rest
    | ('/', l) :: rest -> tkize (("/", l) :: toks) rest
    | ('(', l) :: rest -> tkize (("(", l) :: toks) rest
    | (')', l) :: rest -> tkize ((")", l) :: toks) rest
    | ('<', l) :: ('=', _) :: rest -> tkize (("<=", l) :: toks) rest
    | ('<', l) :: rest -> tkize (("<", l) :: toks) rest
    | ('>', l) :: ('=', _) :: rest -> tkize ((">=", l) :: toks) rest
    | ('>', l) :: rest -> tkize ((">", l) :: toks) rest
    | ('=', l) :: ('=', _) :: rest -> tkize (("==", l) :: toks) rest
    | ('!', l) :: ('=', _) :: rest -> tkize (("!=", l) :: toks) rest
    | (h, l) :: t ->
       match h with
       | '.' | '0'..'9' ->
          let (nm, rest) = get_num prog in tkize ((nm, l) :: toks) rest
       | 'a'..'z' | 'A'..'Z' | '_' ->
          let (nm, rest) = get_id prog in tkize ((nm, l) :: toks) rest
       | x ->
          let (nm, rest) = get_error [x] t in tkize ((nm, l) :: toks) rest
  in
  let (toks, _) = tkize [] chars in
  let categorize tok =
    let (nm, loc) = tok in
    match nm with
    | "and" | "bool" | "check" | "do" | "else" | "elsif" | "end" | "false" | "fi" |
      "float" | "if" | "int" | "od" | "or" | "read" | "real" | "then" | "true" |
      "trunc" | "write" |
      ":=" | "+" | "-" | "*" | "/" | "(" | ")" |
      "<" | "<=" | ">" | ">=" | "!=" | "==" | "$$" ->
       nm, nm, loc
    | _ ->
       match nm.[0] with
       | '.' ->
          begin try
              if '0' <= nm.[1] && nm.[1] <= '9' then "r_lit", nm, loc
              else "error", nm, loc
            with Invalid_argument _ -> "error", nm, loc
          end
       | '0'..'9' ->
          if String.contains nm '.' then "r_lit", nm, loc
          else "i_lit", nm, loc
       | 'a'..'z' | 'A'..'Z' | '_' ->
          if nm = "true" || nm = "false" then "b_lit", nm, loc
          else "id", nm, loc
       | _ -> "error", nm, loc
  in
  map categorize (rev toks)

(***************************************************************************
    Parser.  The main parse routine returns a parse tree (or PT_error if
    the input program is syntactically invalid).  To build that tree it
    employs a simplified version of the "attribute stack" described in
    Section 4.6.4 (pages 67-69) on the PLP 5e companion site.

    When it predicts A -> B C D, the parser pops A from the parse stack
    and then, before pushing D, C, and B (in that order), it pushes a
    number (in this case 3) indicating the length of the right hand side.
    It also pushes A into the attribute stack.

    When it matches a token, the parser pushes this into the attribute
    stack as well.

    Finally, when it encounters a number (say k) in the stack (as opposed
    to a character string), the parser pops k+1 symbols from the
    attribute stack, joins them together into a list, and pushes the list
    back into the attribute stack.

    These rules suffice to accumulate a complete parse tree into the
    attribute stack at the end of the parse.

    Note that everything is done functionally.  We don't really modify
    the stacks; we pass new versions to tail recursive routines.
    Note also that we don't do syntax error recovery -- we simply die
    (return PT_error) when we first run into trouble.
 ***************************************************************************)

(* Extract grammar from parse-tab, so we can invoke the various routines
   that expect a grammar as argument. *)
let grammar_of (parse_tab : parse_table) : grammar =
  map (fun p -> fst p, fold_left (@) [] (map (fun (a, b) -> [b]) (snd p)))
    parse_tab

type parse_tree =   (* among other things, parse_trees are *)
  | PT_error        (* the elements of the attribute stack *)
  | PT_id of string * row_col
  | PT_int of string * row_col
  | PT_real of string * row_col
  | PT_bool of string * row_col
  | PT_term of string * row_col
  | PT_nt of string * row_col * parse_tree list

(* Pop rhs-len + 1 symbols off the attribute stack,
   assemble into a production, and push back onto the stack. *)
let reduce_1_prod (astack : parse_tree list)
    (rhs_len : int) : parse_tree list =
  let rec helper atk k prod =
    match k, atk with
    | 0, PT_nt (nt, loc, []) :: t -> PT_nt (nt, loc, prod) :: t
    | n, h :: t when n != 0 -> helper t (k - 1) (h :: prod)
    | _ -> raise (Failure "expected nonterminal at top of astack")
  in
  helper astack rhs_len []

type parse_action = | PA_error | PA_prediction of string list
(* Double-index to find prediction (list of RHS symbols) for
   nonterminal nt and terminal t.  Return PA_error if not found. *)
let get_parse_action (nt : string) (t : string) (parse_tab : parse_table)
    : parse_action =
  let rec helper l =
    match l with
    | [] -> PA_error
    | (fs, rhs) :: rest -> if mem t fs then PA_prediction rhs else helper rest
  in
  helper (assoc nt parse_tab)

type ps_item =      (* elements of parse stack *)
  | PS_end of int
  | PS_sym of string

(* Parse program according to grammar.
   [Commented-out code would
       print predictions and matches (imperatively) along the way.]
   Return parse tree if the program is in the language; PT_error if it's not. *)
let parse (parse_tab : parse_table) (program : string) : parse_tree =
  let die loc msg =
    let (l, c) = loc in
    (* print to screen in REPL; to stderr when compiled *)
    (if !(Sys.interactive) then Printf.printf else Printf.eprintf)
      "syntax error at line %d, col %d: %s\n" l c msg;
    PT_error
  in
  let gram = grammar_of parse_tab in
  let rec helper pstack tokens astack =
    match pstack with
    | [] ->
       if tokens = [] then
         (* assert: astack is nonempty *)
         hd astack
       else die (0, 0) "extra input beyond end of program"
    | PS_end n :: ps_tail -> helper ps_tail tokens (reduce_1_prod astack n)
    | PS_sym tos :: ps_tail ->
       match tokens with
       | [] -> die (0, 0) "unexpected end of program"
       | (term, nm, loc) :: more_tokens ->
          (* if nm is an individual identifier or number,
             term will be a generic "id" or "i_lit" or "r_lit" *)
          if is_terminal tos gram then
            if tos = term then begin
                (*
                  print_string ("   match " ^ tos);
                  print_string
                  (if tos <> term      (* deep comparison *)
                  then (" (" ^ nm ^ ")") else "");
                  print_newline ();
                 *)
                helper ps_tail more_tokens
                  ((match term with
                    | "id" -> PT_id (nm, loc)
                    | "i_lit" -> PT_int (nm, loc)
                    | "r_lit" -> PT_real (nm, loc)
                    | "b_lit" -> PT_bool (nm, loc)
                    | _ -> PT_term (nm, loc))
                   :: astack)       (* note push of nm into astack *)
              end
            else die loc ("expected " ^ tos ^ " ; saw " ^ nm)
          else (* nonterminal *)
            match get_parse_action tos term parse_tab with
            | PA_error ->
               die loc ("no prediction for " ^ tos ^ " when seeing " ^ nm)
            | PA_prediction rhs -> begin
                (*
                  print_string ("   predict " ^ tos ^ " ->");
                  print_string (fold_left (fun a b -> a ^ " " ^ b) "" rhs);
                  print_newline ();
                 *)
                helper
                  (fold_left (@) [] (map (fun s -> [PS_sym s]) rhs)
                   @ [PS_end (length rhs)] @ ps_tail)
                  tokens (PT_nt (tos, loc, []) :: astack)
              end
  in
  helper [PS_sym (start_symbol gram)] (tokenize program) []

let cg_parse_table = get_parse_table calc_gram

let ecg_parse_table = get_parse_table ecg

(***************************************************************************
    Syntax tree builder.  In contrast to project 2, which built a
    syntax tree while parsing, this project separates parse tree
    construction (above) from AST construction (below).
 ***************************************************************************)

(* Syntax tree node types.
   We distinguish between statements and expressions.
   Comments below indicate what syntactic element in the source
   is associated with the location [row_col] values.
   Note that if..elsif...else..fi statements are turned into cascaded
   if..then..else statements, with no explicit elsif component.
*)

type ast_sl = ast_s list
and ast_s =
  | AST_error
  | AST_i_dec of string * row_col     (* id location *)
  | AST_r_dec of string * row_col     (* id location *)
  | AST_b_dec of string * row_col     (* id location *)
  | AST_read of string * row_col      (* id location *)
  | AST_write of ast_e
  | AST_assign of string * ast_e * row_col * row_col
                            (* id location, := location *)
  | AST_if of ast_e * ast_sl * ast_sl
  | AST_do of ast_sl
  | AST_check of ast_e * row_col
and ast_e =
  | AST_int of string * row_col
  | AST_real of string * row_col
  | AST_bool of string * row_col
  | AST_id of string * row_col
  | AST_float of ast_e * row_col      (* lparen location *)
  | AST_trunc of ast_e * row_col      (* lparen location *)
  | AST_binop of string * ast_e * ast_e * row_col
                                      (* op location *)

(* Convert parse tree to syntax tree.
   Walks the parse tree using a collection of mutually recursive subroutines. *)
let rec ast_ize_prog (p : parse_tree) : ast_sl =
  match p with
  | PT_error -> [AST_error]
  | PT_nt ("P", _, [sl; PT_term ("$$", _)]) -> ast_ize_stmt_list sl
  | _ -> raise (Failure "malformed parse tree in ast_ize_prog")

and ast_ize_stmt_list (sl:parse_tree) : ast_sl =
  match sl with
  | PT_nt ("SL", _, []) -> []
  | PT_nt ("SL", _, s :: sl2 :: rest) -> ast_ize_stmt s :: ast_ize_stmt_list sl2
  | PT_nt ("EPt", _, [PT_term ("elsif", _); cond; PT_term ("then", _);
                      then_pt; else_pt]) ->
     [AST_if (ast_ize_expr cond, ast_ize_stmt_list then_pt,
              ast_ize_stmt_list else_pt)]
  | PT_nt ("EPt", _, [PT_term ("else", _); sl]) -> ast_ize_stmt_list sl
  | PT_nt ("EPt", _, []) -> []
  | _ -> raise (Failure "malformed parse tree in ast_ize_stmt_list")

and ast_ize_stmt (s : parse_tree) : ast_s =
  match s with
  | PT_nt ("S", _, [PT_term ("int", _); PT_id (var, vloc)]) ->
        AST_i_dec (var, vloc)
  | PT_nt ("S", _, [PT_term ("real", _); PT_id (var, vloc)]) ->
        AST_r_dec (var, vloc)
  | PT_nt ("S", _, [PT_term ("bool", _); PT_id (var, vloc)]) ->
        AST_b_dec (var, vloc)
  | PT_nt ("S", _, [PT_id (var, vloc); PT_term (":=", aloc); expr]) ->
        AST_assign (var, ast_ize_expr expr, vloc, aloc)
  | PT_nt ("S", _, [PT_term ("read", _); PT_id (var, vloc)]) ->
        AST_read (var, vloc)
  | PT_nt ("S", _, [PT_term ("write", _); expr]) ->
     AST_write (ast_ize_expr expr)
  | PT_nt ("S", _, [PT_term ("if", _); cond; PT_term ("then", _);
                    then_pt; else_pt; PT_term ("fi", _)]) ->
     AST_if (ast_ize_expr cond, ast_ize_stmt_list then_pt,
             ast_ize_stmt_list else_pt)
  | PT_nt ("S", _, [PT_term ("check", cloc); cond]) ->
     AST_check (ast_ize_expr cond, cloc)
  | PT_nt
      ("S", _, [PT_term ("do", _); sl; PT_term ("od", _)]) ->
     AST_do (ast_ize_stmt_list sl)
  | _ -> raise (Failure "malformed parse tree in ast_ize_stmt")

and ast_ize_expr (e : parse_tree) : ast_e =
  (* L, C, R, E, T, or F *)
  match e with
  | PT_nt ("F", _, [PT_term ("(", _); expr; PT_term (")", _)]) ->
     ast_ize_expr expr
  | PT_nt ("F", _, [PT_id (var, vloc)]) -> AST_id (var, vloc)
  | PT_nt ("F", _, [PT_int (value, iloc)]) -> AST_int (value, iloc)
  | PT_nt ("F", _, [PT_real (value, rloc)]) -> AST_real (value, rloc)
  | PT_nt ("F", _, [PT_bool (value, bloc)]) -> AST_bool (value, bloc)
  | PT_nt ("F", _, [PT_term ("float", _); PT_term ("(", eloc);
                    expr; PT_term (")", _)]) ->
     AST_float (ast_ize_expr expr, eloc)
  | PT_nt
      ("F", _,
       [PT_term ("trunc", _); PT_term ("(", eloc); expr; PT_term (")", _)]) ->
     AST_trunc (ast_ize_expr expr, eloc)
  | PT_nt ("L", _, [lhs; tail]) | PT_nt ("C", _, [lhs; tail])
  | PT_nt ("R", _, [lhs; tail]) | PT_nt ("E", _, [lhs; tail])
  | PT_nt ("T", _, [lhs; tail]) ->
     ast_ize_expr_tail (ast_ize_expr lhs) tail
  | _ -> raise (Failure "malformed parse tree in ast_ize_expr")

and ast_ize_expr_tail (lo : ast_e) (tail : parse_tree) : ast_e =
  (* CT, RT, ET, TT or FT *)
  (* lo is a left operand for a potential operator in tail *)
  match tail with
  | PT_nt ("CT", _, []) | PT_nt ("RT", _, [])
  | PT_nt ("ET", _, []) | PT_nt ("TT", _, [])
  | PT_nt ("FT", _, []) -> lo
  | PT_nt ("ET", _, [PT_nt("RO", oloc, [PT_term (op, _)]); ro]) ->
     AST_binop (op, lo, ast_ize_expr ro, oloc)

  | PT_nt ("CT", _, [PT_term (op, oloc); ro; t2])
  | PT_nt ("RT", _, [PT_term (op, oloc); ro; t2])
  | PT_nt ("TT", _, [PT_nt ("AO", oloc, [PT_term (op, _)]); ro; t2])
  | PT_nt ("FT", _, [PT_nt ("MO", oloc, [PT_term (op, _)]); ro; t2]) ->
     ast_ize_expr_tail (AST_binop (op, lo, ast_ize_expr ro, oloc)) t2
  | _ -> raise (Failure "malformed parse tree in ast_ize_expr_tail")

(***************************************************************************
    Post-typecheck syntax tree.

    Declarations aren't needed anymore.  For numbers, strings are
    replaced by int or real values.  For ids, strings (names) are
    augmented by (type, index) pairs.  We don't really need the names
    anymore, but I retain them for pretty-printing.  Source code
    locations are retained for read statements and binops, which can
    suffer run-time errors during interpretation (out of input /
    wrong-type input and divide-by-zero, respectively).
 ***************************************************************************)

type val_type = Real | Int | Bool | Verror

let type_name = function
  | Real -> "real"
  | Int -> "int"
  | Bool -> "bool"
  | Verror -> "error"

type index = int
type vtp_ind = val_type * index
type ast2_sl = ast2_s list
and ast2_s =
  | AST2_error
  | AST2_read of string * vtp_ind * row_col   (* id location *)
  | AST2_write of ast2_e
  | AST2_assign of string * vtp_ind * ast2_e
  | AST2_if of ast2_e * ast2_sl * ast2_sl
  | AST2_do of ast2_sl
  | AST2_check of ast2_e
and ast2_e =
  | AST2_real of float
  | AST2_int of int
  | AST2_bool of bool
  | AST2_id of string * vtp_ind
  | AST2_float of ast2_e
  | AST2_trunc of ast2_e
  | AST2_binop of string * val_type * ast2_e * ast2_e * row_col
                                              (* op location *)
let ast2_etype =
  function
  | AST2_real _                 -> Real
  | AST2_int _                  -> Int
  | AST2_bool _                 -> Bool
  | AST2_id (_, (tp, ix))       -> tp
  | AST2_float _                -> Real
  | AST2_trunc _                -> Int
  | AST2_binop (_, tp, _, _, _) -> tp

(***************************************************************************
    AST Pretty-printers.  These should be complete and usable as-is.
 ***************************************************************************)

(********
    Pre-typecheck trees:
********)

let rec pp_sl (sl : ast_sl) (ind : string) : string =
  match sl with
  | [] -> ""
  | [s] -> pp_s s ind
  | s :: tl -> pp_s s ind ^ "\n" ^ ind ^ pp_sl tl ind

and pp_s (s : ast_s) (ind : string) : string =
  match s with
  | AST_i_dec (id, _)           -> "(int \"" ^ id ^ "\")"
  | AST_r_dec (id, _)           -> "(real \"" ^ id ^ "\")"
  | AST_b_dec (id, _)           -> "(bool \"" ^ id ^ "\")"
  | AST_read (id, _)            -> "(read \"" ^ id ^ "\")"
  | AST_write expr              -> "(write " ^ pp_e expr ^ ")"
  | AST_assign (id, expr, _, _) -> "(:= \"" ^ id ^ "\" " ^ pp_e expr ^ ")"
  | AST_check (cond, _)         -> "(check " ^ pp_e cond ^ ")"
  | AST_if (cond, tpt, ept)     -> "(if " ^ pp_e cond ^ " ["
                                   ^ "\n" ^ ind ^ "    "
                                   ^ pp_sl tpt (ind ^ "    ")
                                   ^ "\n" ^ ind ^ "  ] ["
                                   ^ (if ept = [] then ""
                                      else "\n" ^ ind ^ "    ")
                                   ^ pp_sl ept (ind ^ "    ")
                                   ^ "\n" ^ ind ^ "  ]\n" ^ ind ^ ")"
  | AST_do sl                   -> "(do [\n" ^ ind ^ "    "
                                   ^ pp_sl sl (ind ^ "    ")
                                   ^ "\n" ^ ind ^ "  ]\n" ^ ind ^ ")"
  | AST_error                   -> "error"

and pp_e (e : ast_e) : string =
  match e with
  | AST_int (num, _)          -> "\"" ^ num ^ "\""
  | AST_real (num, _)         -> "\"" ^ num ^ "\""
  | AST_bool (b, _)           -> "\"" ^ b ^ "\""
  | AST_id (id, _)            -> "\"" ^ id ^ "\""
  | AST_float (e, _)          -> "(float " ^ pp_e e ^ ")"
  | AST_trunc (e, _)          -> "(trunc " ^ pp_e e ^ ")"
  | AST_binop (op, lo, ro, _) -> "(" ^ op ^ " " ^ pp_e lo ^ " " ^ pp_e ro ^ ")"

let pp_p (sl : ast_sl) = print_string ("[ " ^ pp_sl sl "  " ^ "\n]\n")

(********
    Post-typecheck trees:
********)

let rec pp2_sl (sl : ast2_sl) (ind : string) : string =
  match sl with
  | []      -> ""
  | [s]     -> pp2_s s ind
  | s :: tl -> pp2_s s ind ^ "\n" ^ ind ^ pp2_sl tl ind

and pp2_s (s : ast2_s) (ind : string) : string =
  match s with
  | AST2_read (id, (tp, ix), _) ->
     Printf.sprintf "(read \"%s\" (%s %d))" id (type_name tp) ix
  | AST2_write expr -> "(write " ^ pp2_e expr ^ ")"
  | AST2_assign (id, (tp, ix), expr) ->
     let note =
       match tp with
       | Verror -> "(error)"
       | _ -> Printf.sprintf "(%s %d)" (type_name tp) ix
     in
     Printf.sprintf "(:= \"%s\" %s %s)" id note (pp2_e expr)
  | AST2_check cond             -> "(check " ^ pp2_e cond ^ ")"
  | AST2_if (cond, tpt, ept)    -> "(if " ^ pp2_e cond ^ " ["
                                   ^ "\n" ^ ind ^ "    "
                                   ^ pp2_sl tpt (ind ^ "    ")
                                   ^ "\n" ^ ind ^ "  ] ["
                                   ^ (if ept = [] then "" else "\n" ^ ind ^ "    ")
                                   ^ pp2_sl ept (ind ^ "    ")
                                   ^ "\n" ^ ind ^ "  ]\n" ^ ind ^ ")"
  | AST2_do sl                  -> "(do [\n" ^ ind ^ "    "
                                   ^ pp2_sl sl (ind ^ "    ")
                                   ^ "\n" ^ ind ^ "  ]\n" ^ ind ^ ")"
  | AST2_error                  -> "error"

and pp2_e (e : ast2_e) : string =
  match e with
  | AST2_real rv           -> Printf.sprintf "%f" rv
  | AST2_int iv            -> Printf.sprintf "%d" iv
  | AST2_bool bv           -> Printf.sprintf "%b" bv
  | AST2_id (id, (tp, ix)) ->
     Printf.sprintf "\"%s\" (%s %d)" id (type_name tp) ix
  | AST2_float e           -> "(float " ^ pp2_e e ^ ")"
  | AST2_trunc e           -> "(trunc " ^ pp2_e e ^ ")"
  | AST2_binop (op, tp, lo, ro, _) ->
     Printf.sprintf "(%s %s %s %s)" (type_name tp) op (pp2_e lo) (pp2_e ro)

let pp2_p (sl : ast2_sl) = print_string ("[ " ^ pp2_sl sl "  " ^ "\n]\n")

(***************************************************************************
    Everything above this point in the file is complete and (I think)
    usable as-is.  The rest of the file, from here down, is a working
    version of what I want students to write.
 ***************************************************************************)

(***************************************************************************
    Symbol Table

    The symbol table is a stack of scopes and a pair of indices, with
    the innermost scope at the top of the stack.  Each scope consists of
    a list of (name, vtp_ind) pairs. The indices indicate slots in the
    (to be created) real and integer memory arrays.
 ***************************************************************************)

type 'a stack = 'a list
let push (x : 'a) (s : 'a stack) : 'a stack = x :: s
let pop (s : 'a stack) : 'a option * 'a stack =
  match s with
  | [] -> None, []
  | x :: r -> Some x, r

type symtab = {
    scopes : (string * vtp_ind) list stack;
    next_r : index;
    next_i : index;
  }
let new_symtab = {scopes = []; next_r = 0; next_i = 0}

let new_scope (stab:symtab) : symtab = {
    scopes = push [] stab.scopes;
    next_r = stab.next_r;
    next_i = stab.next_i;
  }
let end_scope (stab:symtab) : symtab = {
    scopes = (let (_, surround) = pop stab.scopes in surround);
    next_r = stab.next_r;
    next_i = stab.next_i;
  }

let name_match id (sym, _) = (id = sym)     (* deep eq *)

(* Insert name in current scope of symtab; return updated symtab.
   If already present in innermost scope, return error msg. *)
let stab_insert (id : string) (tp : val_type) (loc : row_col)
      (stab : symtab) : symtab * string =
  match stab.scopes with
  | [] -> raise (Failure "empty scope in stab_insert")
  | scope :: surround ->
     match find_opt (name_match id) scope with
     | Some (_, _) ->
        stab, complaint loc (id ^ " is already defined in this scope")
     | None ->
        let (vi, ri, ii) =
          match tp with
          | Real -> stab.next_r, stab.next_r + 1, stab.next_i
          | Int -> stab.next_i, stab.next_r, stab.next_i + 1
          | Verror -> 0, stab.next_r, stab.next_i
        in {
          scopes = ((id, (tp, vi)) :: scope) :: surround;
          next_r = ri;
          next_i = ii
        }, ""

(* Look up name in symtab and return type and index.
   If not present, insert error entry in innermost scope and
   return new symtab and error msg *)
let rec stab_lookup (id : string) (loc : row_col) (stab : symtab)
    : symtab * vtp_ind * string =
  (* helper just does the lookup *)
  let rec helper scopes : (val_type * index) option =
    match scopes with
    | [] -> None
    | scope :: surround ->
       match find_opt (name_match id) scope with
       | Some (_, t_i) -> Some t_i
       | None -> helper surround
  in
    (** YOUR CODE HERE **)
    match helper stab.scopes with
    | Some t_i -> stab, t_i, ""
    | None -> 
      let (new_stab, err) = stab_insert id Verror loc stab in
      new_stab, (Verror, 0), complaint loc (id ^ " has not been declared")


(***************************************************************************
    Type-checker

    As an alternative to fully dynamic semantics, this code checks
    static semantic rules before program execution.  Specifically:
      - all variables must be declared before use.
      - no variable can be redeclared in the same scope (global,
        loop body, then clause, else clause), though nested declarations
        can hide outer ones.  For the sake of simplicity, we'll say (as
        in C) that the outer declaration remains visible in the inner
        scope prior to the nested declaration.
      - operands of binary operators must agree in type
      - lhs and rhs of assignments must agree in type
      - argument of trunc must be real
      - argument of float must be integer
      - check statements must appear only within do loops

    These errors should never arise during execution of a program that
    has passed typechecking (that is, the typechecking should be sound).
 ***************************************************************************)

(* Typecheck statement list in nested scope; accumulate error messages. *)
let rec typecheck_sl (sl : ast_sl) (stab : symtab) (in_loop : bool)
    : ast2_sl * symtab * string list =
   (* new_ast   new_stab   errors *)
  let rec helper (sl2 : ast_sl) (stab2 : symtab)
                 (slsf : ast2_sl) (esf : string list)
      : ast2_sl * symtab * string list =
    (** YOUR CODE HERE
        You'll want to (tail-recursively) "iterate" over the statements
        of sl2, building a new ast2_sl.  Note that declarations change
        the symbol table, but will not be part of the new list.
        Individual statements can produce more than one error, so you'll
        need list concatenation (@) to join them.  This isn't constant
        time, but error lists are expected to be short.
     **)

    match sl2 with
    | [] -> rev slsf, stab2, esf
    | s :: rest ->
      let (s2, stab2_checked, errs) = typecheck_s s stab2 in_loop in
      match s2 with
      | AST2_error -> helper rest stab2_checked slsf (errs @ esf)
      | _ -> helper rest stab2_checked (s2 :: slsf) (errs @ esf)

  in
  (** YOUR CODE HERE
      You'll want to think about how to handle scopes.
   **)
  let stab2 = new_scope stab in
  let (sl2, stab2_checked, errs) = helper sl stab2 [] [] in
  sl2, end_scope stab2_checked, errs

and typecheck_s (s : ast_s) (stab : symtab) (in_loop : bool)
    : ast2_s * symtab * string list =
  (* new_ast   new_stab   errors *)
  match s with
  | AST_i_dec (id, vloc) ->
     let (stab2, err) = stab_insert id Int vloc stab in
     AST2_error (* ignored by caller *), stab2,
     (if err = "" (* deep eq *) then [] else [err])
  | AST_r_dec (id, vloc) ->
     (** YOUR CODE HERE **)
     let (stab2, err) = stab_insert id Real vloc stab in
     AST2_error, stab2, (if err = "" then [] else [err])



  | AST_read (id, vloc) ->
     let (stab2, tl, err) = stab_lookup id vloc stab in
     AST2_read (id, tl, vloc), stab2,
     (if err = "" (* deep eq *) then [] else [err])
  | AST_write expr ->
     (** YOUR CODE HERE **)
     let (checked_expr, stab2, errs) = typecheck_e expr stab in
     AST2_write checked_expr, stab2, errs



  | AST_assign (id, expr, id_loc, gets_loc) ->
     (** YOUR CODE HERE
         You'll want to catch type clashes, but avoid cascading errors.
      **)

     let (stab2, (id_tp, id_ix), lookup_err) = stab_lookup id id_loc stab in
     let (checked_expr, stab3, expr_errs) = typecheck_e expr stab2 in
     let error_tp = ast2_etype checked_expr in
     let type_err = 
       if id_tp = Verror || error_tp = Verror then []
       else if id_tp <> error_tp then 
         [complaint gets_loc ("type mismatch in assignment")]
       else []
     in
     AST2_assign (id, (id_tp, id_ix), checked_expr), stab3,
       (if lookup_err = "" then [] else [lookup_err]) @ expr_errs @ type_err


  | AST_if (cond, tsl, esl) ->
     (** YOUR CODE HERE **)
     let (cond_checked, stab2, cond_errs) = typecheck_e cond stab in
     let (tsl2, stab3, t_errs) = typecheck_sl tsl stab2 in_loop in
     let (esl2, stab4, e_errs) = typecheck_sl esl stab3 in_loop in
     AST2_if (cond_checked, tsl2, esl2), stab4, cond_errs @ t_errs @ e_errs



  | AST_check (cond, cloc) ->
     (** YOUR CODE HERE **)

     let (cond_checked, stab2, cond_errs) = typecheck_e cond stab in
     let loop_err =
       if not in_loop then [complaint cloc "check statement outside loop"]
       else []
     in
     AST2_check cond_checked, stab2, cond_errs @ loop_err




  | AST_do sl ->
     (** YOUR CODE HERE **)
     let (sl2, stab2, errs) = typecheck_sl sl stab true in
     AST2_do sl2, stab2, errs



  | AST_error -> raise (Failure "cannot interpret erroneous tree")

  
and typecheck_e (e : ast_e) (stab : symtab)
    : ast2_e * symtab * string list =
  (* new_ast   new_stab   errors *)
  match e with
  | AST_int (str, iloc) ->
     AST2_int (int_of_string str), stab, []
  (* raises Failure "int_of_string" on (unexpected) error *)
  | AST_real (str, rloc) ->
     (** YOUR CODE HERE **)
     AST2_real (float_of_string str), stab, []

  

   
  | AST_id (id, vloc) ->
     let (stab2, tl, err) = stab_lookup id vloc stab in
     AST2_id (id, tl), stab2, (if err = "" (* deep eq *)
                               then [] else [err])
  | AST_float (expr, eloc) ->
     (** YOUR CODE HERE
         You'll want to catch non-int input.
      **)
       let (checked_expr, stab2, errs) = typecheck_e expr stab in
       let tp = ast2_etype checked_expr in
       let type_err =
          if tp = Verror then []
          else if tp <> Int then [complaint eloc "non-int argument to float"]
          else []
       in
       AST2_float checked_expr, stab2, errs @ type_err





  | AST_trunc (expr, eloc) ->
     (** YOUR CODE HERE
         You'll want to catch non-real input.
      **)
      let (checked_expr, stab2, errs) = typecheck_e expr stab in
      let tp = ast2_etype checked_expr in
      let type_err =
        if tp = Verror then []
        else if tp <> Real then [complaint eloc "non-real argument to trunc"]
        else []
      in
      AST2_trunc checked_expr, stab2, errs @ type_err





  | AST_binop (op, lo, ro, oloc) ->
     (** YOUR CODE HERE
         You'll want to catch type clashes, but avoid cascading errors.
         Think carefully about how "and", "or", and the comparison operators
         ought to behave.
      **)

      let (lo_checked, stab2, lo_errs) = typecheck_e lo stab in
      let (ro_checked, stab3, ro_errs) = typecheck_e ro stab2 in
      let lo_tp = ast2_etype lo_checked in
      let ro_tp = ast2_etype ro_checked in
      let (result_tp, type_err) = 
        if lo_tp = Verror || ro_tp = Verror then (Verror, [])
        else if lo_tp <> ro_tp then (Verror, [complaint oloc "type mismatch in binop"])
        else 
          match op with
          | "and" | "or" -> 
            if lo_tp <> Int then (Verror, [complaint oloc "non-int operand to and/or"])
            else (Int, [])
          | "==" | "!=" | "<" | "<=" | ">" | ">=" -> (Int, [])
          | _ -> (lo_tp, [])
      in
      AST2_binop (op, result_tp, lo_checked, ro_checked, oloc), stab3, lo_errs @ ro_errs @ type_err




      
(* Typecheck a whole AST.  Return an AST2, a (properly ordered) error list,
   and counts of real and int vars. *)
let typecheck (p : ast_sl)
    : ast2_sl * string list * index * index =
   (* new_ast   new_stab   errors    num_rs   num_is *)
  let (p2, stab2, errs) = typecheck_sl p new_symtab false in
  p2, errs, stab2.next_r, stab2.next_i

(***************************************************************************
    Actual interpreter

    Catches divide-by-zero, invalid input, and unexpected end of input
    on read.  Uses imperative code (mutable array slots) to modify
    values of calculator variables during execution.  (We could pass
    around updated environments instead, but there's no easy way to do
    that without making every assignment or read statement take time
    O(log n), where n is the number of variables in the program.)
 ***************************************************************************)

type memory = { reals : float array; ints : int array }

type status =
  | Good
  | Bad     (* run-time error *)
  | Done    (* loop-terminating check *)

type value =
  | Rvalue of float
  | Ivalue of int
  | Evalue of string    (* divide-by-zero is the only bad case at present *)

(* Accumulated output is constructed in reverse. *)
let rec interpret_sl (sl : ast2_sl) (mem : memory)
                     (inp : string list) (outp : string list)
    : status * string list * string list =
   (*   ok?    new_input     new_output *)
  (** YOUR CODE HERE
      You'll want to tail-recursively "iterate" over the statements of
      the list, accumulating reversed output.  You should stop when you
      reach the end of the list or you encounter a run-time error
      (status of Bad returned from a call to interpret_s) or a
      loop-terminating check (status of Done returned from a call to
      interpret_s).
   **)

   let rec helper sl2 inp2 outp2 =
    match sl2 with
    | [] -> Good, inp2, outp2
    | s :: rest ->
      let (status, inp3, outp3) = interpret_s s mem inp2 outp2 in
      match status with
      | Good -> helper rest inp3 outp3
      | _ -> status, inp3, outp3
  in
  helper sl inp outp

   


and interpret_s (s : ast2_s) (mem : memory)
                (inp : string list) (outp : string list)
    : status * string list * string list =
   (*   ok?    new_input     new_output *)
  match s with
  | AST2_error                -> raise (Failure "cannot interpret erroneous tree")
  | AST2_read (_, tl, loc)    -> interpret_read tl loc mem inp outp
  | AST2_write expr           -> interpret_write expr mem inp outp
  | AST2_assign (_, tl, expr) -> interpret_assign tl expr mem inp outp
  | AST2_if (cond, tsl, esl)  -> interpret_if cond tsl esl mem inp outp
  | AST2_check cond           -> interpret_check cond mem inp outp
  | AST2_do sl                -> interpret_do sl mem inp outp

and interpret_read (tp, ix : vtp_ind) (loc : row_col) (mem : memory)
                   (inp : string list) (outp : string list)
    : status * string list * string list =
   (*   ok?    new_input     new_output *)
  (** YOUR CODE HERE
      You'll want to catch bad input (non-int or non-real, as appropriate).
      In the error-free case, you'll need to convert the string to an int
      or float (as appropriate) and then update (imperatively) the
      appropriate slot in mem.
   **)

  match inp with
  | [] -> Bad, inp, complaint loc "unexpected end of input" :: outp
  | h :: t ->
    match tp with
    | Int ->
        (try
          mem.ints.(ix) <- int_of_string h;
          Good, t, outp
        with Failure _ -> 
          Bad, inp, complaint loc "non-int input" :: outp)
    | Real ->
        (try
          mem.reals.(ix) <- float_of_string h;
          Good, t, outp
        with Failure _ -> 
          Bad, inp, complaint loc "non-real input" :: outp)
    | Verror -> raise (Failure "error type in read")

   




and interpret_write (expr : ast2_e) (mem : memory)
                    (inp : string list) (outp : string list)
    : status * string list * string list =
   (*   ok?    new_input     new_output *)
  (** YOUR CODE HERE **)

  match interpret_e expr mem with
  | Rvalue r -> Good, inp, (Printf.sprintf "%f" r) :: outp
  | Ivalue i -> Good, inp, (string_of_int i) :: outp
  | Evalue msg -> Bad, inp, msg :: outp


  



and interpret_assign (tp, ix : vtp_ind) (expr : ast2_e) (mem : memory)
                     (inp : string list) (outp : string list)
    : status * string list * string list =
   (*   ok?    new_input     new_output *)
  (** YOUR CODE HERE **)
  match interpret_e expr mem with
  | Rvalue r -> mem.reals.(ix) <- r; Good, inp, outp
  | Ivalue i -> mem.ints.(ix) <- i; Good, inp, outp
  | Evalue msg -> Bad, inp, msg :: outp
    



and interpret_if (cond : ast2_e) (tsl : ast2_sl) (esl : ast2_sl)
                 (mem : memory) (inp : string list) (outp : string list)
    : status * string list * string list =
   (*   ok?    new_input     new_output *)
  (** YOUR CODE HERE **)

  match interpret_e cond mem with
  | Ivalue 0 -> interpret_sl esl mem inp outp
  | Ivalue _ -> interpret_sl tsl mem inp outp
  | Evalue msg -> Bad, inp, msg :: outp
  | _ -> raise (Failure "non-int condition")

  


and interpret_check (cond : ast2_e) (mem : memory)
    (inp : string list) (outp : string list)
    : status * string list * string list =
  (*   ok?    new_input     new_output *)
  (** YOUR CODE HERE **)

  match interpret_e cond mem with
  | Ivalue 0 -> Done, inp, outp
  | Ivalue _ -> Good, inp, outp
  | Evalue msg -> Bad, inp, msg :: outp
  | _ -> raise (Failure "non-int condition")

  


and interpret_do (sl : ast2_sl) (mem : memory)
    (inp : string list) (outp : string list)
    : status * string list * string list =
  (*   ok?    new_input     new_output *)
  (** YOUR CODE HERE
      This is a somewhat tricky case.  It needs to be (tail) recursive,
      and it has to terminate, without further action, whenever a check
      (nested anywhere inside) has a false condition.
   **)

  let rec loop inp2 outp2 =
    match interpret_sl sl mem inp2 outp2 with
    | (Done, inp3, outp3) -> Good, inp3, outp3
    | (Good, inp3, outp3) -> loop inp3 outp3
    | (Bad, inp3, outp3) -> Bad, inp3, outp3
  in
  loop inp outp
   



and interpret_e (expr : ast2_e) (mem : memory) : value =
  match expr with
  | AST2_real r -> Rvalue r
  | AST2_int n -> Ivalue n
  | AST2_id (_, (tp, ix)) ->
     begin match tp with
     | Real -> Rvalue mem.reals.(ix)
     | Int -> Ivalue mem.ints.(ix)
     | Verror -> raise (Failure "error type id??")
     end
  | AST2_float e ->
      (** YOUR CODE HERE **)
      (match interpret_e e mem with
      | Ivalue i -> Rvalue (float_of_int i)
      | _ -> raise (Failure "non-int to float"))




  | AST2_trunc e ->
     (** YOUR CODE HERE **)
     (match interpret_e e mem with
      | Rvalue r -> Ivalue (int_of_float r)
      | _ -> raise (Failure "non-real to trunc"))


  | AST2_binop (op, tp, lo, ro, loc) ->
     (** YOUR CODE HERE
         In the division case you'll need to check for a zero denominator.
      **)
    let lv = interpret_e lo mem in
    let rv = interpret_e ro mem in
    (match lv, rv with
      | Evalue msg, _ | _, Evalue msg -> Evalue msg
      | Rvalue l, Rvalue r ->
        (match op with
          | "+" -> Rvalue (l +. r)
          | "-" -> Rvalue (l -. r)
          | "*" -> Rvalue (l *. r)
          | "/" -> if r = 0. then Evalue (complaint loc "divide by zero")
                  else Rvalue (l /. r)
          | "==" -> Ivalue (if l = r then 1 else 0)
          | "!=" -> Ivalue (if l <> r then 1 else 0)
          | "<" -> Ivalue (if l < r then 1 else 0)
          | "<=" -> Ivalue (if l <= r then 1 else 0)
          | ">" -> Ivalue (if l > r then 1 else 0)
          | ">=" -> Ivalue (if l >= r then 1 else 0)
          | _ -> raise (Failure "unknown real op"))
      | Ivalue l, Ivalue r ->
        (match op with
          | "+" -> Ivalue (l + r)
          | "-" -> Ivalue (l - r)
          | "*" -> Ivalue (l * r)
          | "/" -> if r = 0 then Evalue (complaint loc "divide by zero")
                  else Ivalue (l / r)
          | "and" -> Ivalue (if l <> 0 && r <> 0 then 1 else 0)
          | "or" -> Ivalue (if l <> 0 || r <> 0 then 1 else 0)
          | "==" -> Ivalue (if l = r then 1 else 0)
          | "!=" -> Ivalue (if l <> r then 1 else 0)
          | "<" -> Ivalue (if l < r then 1 else 0)
          | "<=" -> Ivalue (if l <= r then 1 else 0)
          | ">" -> Ivalue (if l > r then 1 else 0)
          | ">=" -> Ivalue (if l >= r then 1 else 0)
          | _ -> raise (Failure "unknown int op"))
      | _ -> raise (Failure "type mismatch in binop"))

(* Input to a calculator program is just a sequence of numbers, entered
   as one long character string.  We use the standard Str library to
   split the string into whitespace-separated words, each of which is
   subsequently checked for validity. *)
let interpret (sl : ast2_sl) (num_reals : int) (num_ints : int)
              (full_input : string) : string =
  let inp = split (regexp "[ \t\n\r]+") full_input in
  let mem = { reals = Array.make num_reals 0.;
              ints  = Array.make num_ints 0 } in
  let (_, _, outp) = interpret_sl sl mem inp [] in
  String.concat " " (rev outp) ^ "\n"

(***************************************************************************
    Testing
 ***************************************************************************)

let sum_ave_prog =
  " int a read a
    int b read b
    int sum sum := a + b
    write sum
    write float(sum) / 2.0"

let primes_prog =
  " int n read n
    int cp cp := 2
    do 
        check n > 0
        int found found := 0
        int cf1 cf1 := 2
        int cf1s cf1s := cf1 * cf1
        do
            check cf1s <= cp
            int cf2 cf2 := 2
            int pr pr := cf1 * cf2
            do
                check pr <= cp
                if pr == cp then
                    found := 1
                fi
                cf2 := cf2 + 1
                pr := cf1 * cf2
            od
            cf1 := cf1 + 1
            cf1s := cf1 * cf1
        od
        if found == 0 then
            write cp
            n := n - 1
        fi
        cp := cp + 1
    od"

let gcd_prog =
  " int a read a
    int b read b
    do 
        if a > b then
            a := a - b
        elsif b > a then
            b := b - a
        else
            write a
            check 0     // break
        fi
    od"

let sqrt_prog =
  " real d read d
    real l l := d / 2.0
    do
        check l * l > d
        l := l / 2.0
    od
    real h h := 2.0 * l
    real err err := d - (l * l)
    if err < 0.0 then err := 0.0 - err fi
    do
        check err > 1.e-8
        real a a := (l + h) / 2.0
        if (a * a) < d then
            l := a
        else
            h := a
        fi
        err := d - (l * l)
        if err < 0.0 then err := 0.0 - err fi
    od
    write l"

let ecg_parse prog = parse ecg_parse_table prog

let ecg_ast prog = ast_ize_prog (ecg_parse prog)

let ecg_run (prog : string) (inp : string) : string =
  let (tree, errs, num_rs, num_is) = typecheck (ecg_ast prog) in
  if errs <> [] (* deep comparison *)
  then String.concat "\n" errs
  else
    begin
      print_string "typecheck completed successfully\n";
      interpret tree num_rs num_is inp
    end

let show_ast prog = pp_p (ecg_ast prog)
let show_ast2 prog =
  let (tree, errs, num_rs, num_is) = typecheck (ecg_ast prog) in
  print_string
    ((if errs = [] then "no errors" else String.concat "\n" errs)
     ^ Printf.sprintf "\n# reals:%3d\n# ints: %3d\n" num_rs num_is);
  pp2_p tree

let main () =
  (*
    let sum_ave_parse_tree = parse ecg_parse_table sum_ave_prog
    let sum_ave_syntax_tree = ast_ize_prog sum_ave_parse_tree
    let primes_parse_tree = parse ecg_parse_table primes_prog
    let primes_syntax_tree = ast_ize_prog primes_parse_tree
    let gcd_parse_tree = parse ecg_parse_table gcd_prog
    let gcd_syntax_tree = ast_ize_prog gcd_parse_tree
    print_string (ecg_run sum_ave_prog "4 6");
      (* should print "typecheck completed successfully
                       10 5." *)
    print_string (ecg_run primes_prog "10");
      (* should print "typecheck completed successfully
                       2 3 5 7 11 13 17 19 23 29" *)
    print_string (ecg_run sum_ave_prog "4 foo");
      (* should print "typecheck completed successfully
                        line 1, col 24: non-int input" *)
    print_string (ecg_run "write 3 write 2 / 0" "");
      (* should print "typecheck completed successfully
                       3  line1, col 17: divide by zero" *)
    print_string (ecg_run "write foo" "");
      (* should print " line 1, col 7: foo has not been declared" *)
    print_string (ecg_run "read int a read int b" "3");
      (* should print "typecheck completed successfully
                        line 1, col 21: unexpected end of input" *)
    print_string (ecg_run "int a := 2 int a := 3" "");
      (* should print " line  1, col 16: a is already defined in this scope" *)
  *)

  (* Code below expects there to be a single command-line argument, which
     names a file containing an ecg program.  It runs that program, taking
     input from stdin.  It does NOT run interactively: it sucks up _all_
     input and runs only once it reaches end-of-file. *)

  let read_prog () =
    if Array.length Sys.argv != 2 then
      raise (Failure ("usage: " ^ Sys.argv.(0) ^ " prog_file_name"))
    else
      let ic = open_in Sys.argv.(1) in
      let lines = ref [] in
      try while true do lines := input_line ic :: !lines
          done; ""
      with End_of_file -> String.concat "\n" (rev !lines)
  in
  let read_input () =
    let lines = ref [] in
    try while true do lines := read_line () :: !lines done; "" with
      End_of_file -> String.concat "\n" (rev !lines)
  in
  let (tree, errs, num_rs, num_is) = typecheck (ecg_ast (read_prog())) in
  let output =
    if errs <> [] (* deep comparison *)
    then String.concat "\n" errs
    else
      begin
        print_string "typecheck completed successfully\n";
        interpret tree num_rs num_is (read_input ())
      end
  in
  print_string output

(* Execute function "main" iff run as a stand-alone program. *)
let _ = if !(Sys.interactive) then () else main ()
(* Time Complexity: O(n^2) *)
(* Space Complexity: O(n) *)

(* candidate[length] = length of the subsequence *)
type candidate = { length : int; last : int; rev_seq : int list }

(* Pick the longer candidate *)
let better a b = if a.length >= b.length then a else b

(* Find the best predecessor with last < x *)
let extend_best (candidates : candidate list) (x : int) : candidate =
  let best_prev =
    List.fold_left
      (fun acc c -> if c.last < x then better acc c else acc)
      { length = 0; last = min_int; rev_seq = [] }
      candidates
  in
  match best_prev.length with
  | 0 -> { length = 1; last = x; rev_seq = [x] }
  | _ -> { length = best_prev.length + 1; last = x; rev_seq = x :: best_prev.rev_seq }

(* Reconstruct *)
let lis (nums : int list) : int list =
  let rec build (candidates : candidate list) (best_cand : candidate) = function
    | [] -> List.rev best_cand.rev_seq
    | x :: rest ->
        let cand = extend_best candidates x in
        let best_cand' = if cand.length > best_cand.length then cand else best_cand in
        build (cand :: candidates) best_cand' rest
  in
  build [] { length = 0; last = min_int; rev_seq = [] } nums

  (* One-line input parsing *)
let parse_nums (line : string) : int list =
  line
  |> String.split_on_char ' '
  |> List.filter (fun s -> s <> "")
  |> List.map int_of_string

let () =
  if not !Sys.interactive then
    try
      let line = input_line stdin in
      let nums = parse_nums line in
      let lis_seq = lis nums in
      let rec print_seq = function
        | [] -> print_newline ()
        | [x] -> print_int x; print_newline ()
        | x :: xs -> print_int x; print_char ' '; print_seq xs
      in
      print_seq lis_seq
    with End_of_file ->
      print_newline ()

#load "str.cma";;
#use "ecl.ml";;

(* Test constant folding *)
print_string "\n=== Test 1: Simple Arithmetic ===\n";;
show_ast2_with_fold "write 3 + 5";;

print_string "\n\n=== Test 2: Multiple Operations ===\n";;
show_ast2_with_fold "write 10 * 2 + 5";;

print_string "\n\n=== Test 3: With Variables ===\n";;
show_ast2_with_fold "int x x := 3 + 5 write x";;

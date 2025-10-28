#load "str.cma";;
#use "ecl.ml";;

print_string "\n";;
print_string "========================================\n";;
print_string "  CONSTANT FOLDING DEMONSTRATION\n";;
print_string "========================================\n\n";;

print_string "=== Test 1: Integer Arithmetic ===\n";;
show_ast2_with_fold "write 3 + 5 write 10 * 2 write 20 - 8 write 100 / 4";;

print_string "\n\n=== Test 2: Real Arithmetic ===\n";;
show_ast2_with_fold "write 3.0 + 5.5 write 10.0 * 2.5 write 20.0 / 4.0";;

print_string "\n\n=== Test 3: Comparisons ===\n";;
show_ast2_with_fold "write 5 < 10 write 10 == 10 write 3 > 7";;

print_string "\n\n=== Test 4: Logical Operations ===\n";;
show_ast2_with_fold "write 1 and 1 write 0 or 1";;

print_string "\n\n=== Test 5: Nested Expressions ===\n";;
show_ast2_with_fold "write (3 + 5) * (10 - 2)";;

print_string "\n\n=== Test 6: Type Conversions ===\n";;
show_ast2_with_fold "write float(10) write trunc(3.14)";;

print_string "\n\n=== Test 7: Unary Operators ===\n";;
show_ast2_with_fold "write -(5 + 3) write not 0";;

print_string "\n\n=== Test 8: With Variables (partial folding) ===\n";;
show_ast2_with_fold "int x int y x := 3 + 5 y := x * 2 write 10 + 20";;

print_string "\n\n=== Test 9: Control Flow ===\n";;
show_ast2_with_fold "if 3 < 5 then write 100 + 200 else write 50 * 2 fi";;

print_string "\n\n========================================\n";;
print_string "  All tests completed!\n";;
print_string "========================================\n\n";;

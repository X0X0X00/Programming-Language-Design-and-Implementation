#!/bin/bash

# Extended comprehensive test suite for ECL interpreter
# Includes all basic tests plus additional edge cases and complex scenarios

echo "=========================================="
echo "Testing Correct Programs - Basic"
echo "=========================================="

echo -n "Test 1 (sum and average): "
result=$(echo "4 6" | ./ecl sum_ave.ecl 2>&1 | tail -1)
if [[ $result == "10 5.000000" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 2 (first 10 primes): "
result=$(echo "10" | ./ecl primes.ecl 2>&1 | tail -1)
if [[ $result == "2 3 5 7 11 13 17 19 23 29" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 3 (gcd of 15 and 10): "
result=$(echo "15 10" | ./ecl gcd.ecl 2>&1 | tail -1)
if [[ $result == "5" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 4 (square root): "
result=$(echo "16.0" | ./ecl sqrt.ecl 2>&1 | tail -1)
expected="4.000000"
if [[ $result == $expected* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 5 (basic arithmetic): "
result=$(echo "" | ./ecl <(echo "write 3 + 4 * 2") 2>&1 | tail -1)
if [[ $result == "11" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 6 (nested if statements): "
result=$(echo "" | ./ecl <(echo "int x x := 5 if x > 3 then if x < 10 then write 1 fi fi") 2>&1 | tail -1)
if [[ $result == "1" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 7 (elsif chain): "
result=$(echo "" | ./ecl <(echo "int x x := 5 if x == 3 then write 1 elsif x == 5 then write 2 else write 3 fi") 2>&1 | tail -1)
if [[ $result == "2" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 8 (real arithmetic): "
result=$(echo "" | ./ecl <(echo "real x x := 3.5 real y y := 2.0 write x * y") 2>&1 | tail -1)
if [[ $result == "7.000000" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 9 (logical and operator): "
result=$(echo "" | ./ecl <(echo "int x x := 1 int y y := 1 write x and y") 2>&1 | tail -1)
if [[ $result == "1" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 10 (logical or operator): "
result=$(echo "" | ./ecl <(echo "int x x := 0 int y y := 1 write x or y") 2>&1 | tail -1)
if [[ $result == "1" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo ""
echo "=========================================="
echo "Testing Correct Programs - Advanced"
echo "=========================================="

echo -n "Test 11 (negation with subtraction): "
result=$(echo "" | ./ecl test_negation.ecl 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"-5"* && $output == *"-3.5"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 12 (complex expression): "
result=$(echo "" | ./ecl test_complex_expr.ecl 2>&1 | tail -1)
if [[ $result == "6" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 13 (float and trunc conversions): "
result=$(echo "" | ./ecl test_float_trunc.ecl 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"3.5"* && $output == *"3"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 14 (nested loops): "
result=$(echo "" | ./ecl test_nested_loops.ecl 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"6"* && $output == *"3"* && $output == *"4"* && $output == *"2"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 15 (comparison operators): "
result=$(echo "" | ./ecl <(echo "int a a := 5 if a < 10 then write 1 fi if a > 3 then write 2 fi if a == 5 then write 3 fi") 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"1"* && $output == *"2"* && $output == *"3"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 16 (else clause): "
result=$(echo "" | ./ecl <(echo "int x x := 10 if x < 5 then write 1 else write 2 fi") 2>&1 | tail -1)
if [[ $result == "2" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 17 (not operator): "
result=$(echo "" | ./ecl <(echo "int x x := 0 write not x") 2>&1 | tail -1)
if [[ $result == "1" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 18 (unary minus): "
result=$(echo "" | ./ecl <(echo "int x x := 5 write -x") 2>&1 | tail -1)
if [[ $result == "-5" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo ""
echo "=========================================="
echo "Testing Boolean Type Implementation"
echo "=========================================="

echo -n "Test 19 (boolean declarations and literals): "
result=$(echo "" | ./ecl test_bool.ecl 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"true"* && $output == *"false"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 20 (boolean logical operators): "
result=$(echo "" | ./ecl <(echo "bool a a := true bool b b := false write a and b write a or b") 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"false"* && $output == *"true"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 21 (boolean comparison operators): "
result=$(echo "" | ./ecl <(echo "bool a a := true bool b b := true write a == b write a != b") 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"true"* && $output == *"false"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 22 (boolean in if statement): "
result=$(echo "" | ./ecl <(echo "bool x x := true if x then write 1 else write 2 fi") 2>&1 | tail -1)
if [[ $result == "1" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 23 (boolean read and write): "
result=$(echo "true false" | ./ecl <(echo "bool a read a bool b read b write a write b") 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"true"* && $output == *"false"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 24 (comparison returns boolean): "
result=$(echo "" | ./ecl <(echo "int x x := 5 int y y := 10 bool b b := x < y write b") 2>&1 | tail -1)
if [[ $result == "true" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 25 (not operator on boolean): "
result=$(echo "" | ./ecl <(echo "bool x x := true write not x") 2>&1 | tail -1)
if [[ $result == "false" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo ""
echo "=========================================="
echo "Testing Static Semantic Errors"
echo "=========================================="

echo -n "Test 26 (undeclared variable use): "
result=$(echo "" | ./ecl <(echo "write foo") 2>&1)
if [[ $result == *"has not been declared"* || $result == *"undeclared"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected undeclared variable error"
fi

echo -n "Test 27 (variable redeclaration in same scope): "
result=$(echo "" | ./ecl <(echo "int a a := 2 int a a := 3") 2>&1)
if [[ $result == *"already defined"* || $result == *"redeclar"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected redeclaration error"
fi

echo -n "Test 28 (type mismatch in assignment int to real): "
result=$(echo "" | ./ecl <(echo "int a a := 5 real b b := a") 2>&1)
if [[ $result == *"type mismatch"* || $result == *"type clash"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected type mismatch error"
fi

echo -n "Test 29 (type mismatch in assignment real to int): "
result=$(echo "" | ./ecl <(echo "real a a := 5.0 int b b := a") 2>&1)
if [[ $result == *"type mismatch"* || $result == *"type clash"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected type mismatch error"
fi

echo -n "Test 30 (non-int operand to 'and'): "
result=$(echo "" | ./ecl <(echo "real x x := 3.5 write x and 1") 2>&1)
if [[ $result == *"type"* || $result == *"int"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected non-int to 'and' error"
fi

echo -n "Test 31 (non-int operand to 'or'): "
result=$(echo "" | ./ecl <(echo "real x x := 3.5 write 1 or x") 2>&1)
if [[ $result == *"type"* || $result == *"int"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected non-int to 'or' error"
fi

echo -n "Test 32 (non-int argument to float): "
result=$(echo "" | ./ecl <(echo "real x x := 3.5 write float(x)") 2>&1)
if [[ $result == *"non-int argument to float"* || $result == *"float"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected non-int argument to float error"
fi

echo -n "Test 33 (non-real argument to trunc): "
result=$(echo "" | ./ecl <(echo "int x x := 3 write trunc(x)") 2>&1)
if [[ $result == *"non-real argument to trunc"* || $result == *"trunc"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected non-real argument to trunc error"
fi

echo -n "Test 34 (check statement outside loop): "
result=$(echo "" | ./ecl <(echo "check 1") 2>&1)
if [[ $result == *"outside loop"* || $result == *"check"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected check outside loop error"
fi

echo -n "Test 35 (check in if block but not in loop): "
result=$(echo "" | ./ecl <(echo "int x x := 5 if x > 3 then check 0 fi") 2>&1)
if [[ $result == *"outside loop"* || $result == *"check"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected check outside loop error"
fi

echo -n "Test 36 (type mismatch in binary expression): "
result=$(echo "" | ./ecl <(echo "int x x := 5 real y y := 3.5 write x + y") 2>&1)
if [[ $result == *"type"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected type mismatch in expression error"
fi

echo -n "Test 37 (undeclared variable in expression): "
result=$(echo "" | ./ecl <(echo "int x x := 5 write x + undeclared_var") 2>&1)
if [[ $result == *"declared"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected undeclared variable error"
fi

echo -n "Test 38 (inequality operators): "
result=$(echo "" | ./ecl <(echo "int a a := 5 if a != 3 then write 1 fi if a >= 5 then write 2 fi if a <= 5 then write 3 fi") 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"1"* && $output == *"2"* && $output == *"3"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo ""
echo "=========================================="
echo "Testing Dynamic Semantic Errors"
echo "=========================================="

echo -n "Test 39 (division by zero): "
result=$(echo "" | ./ecl <(echo "write 5 / 0") 2>&1)
if [[ $result == *"divide by zero"* || $result == *"division"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected division by zero error"
fi

echo -n "Test 40 (non-int input when reading int): "
result=$(echo "3.5" | ./ecl <(echo "int a read a write a") 2>&1)
if [[ $result == *"non-int input"* || $result == *"int"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected non-int input error"
fi

echo -n "Test 41 (non-real input when reading real): "
result=$(echo "abc" | ./ecl <(echo "real x read x write x") 2>&1)
if [[ $result == *"non-real input"* || $result == *"real"* || $result == *"input"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected non-real input error"
fi

echo -n "Test 42 (unexpected end of input): "
result=$(echo "" | ./ecl <(echo "int a read a write a") 2>&1)
if [[ $result == *"end of input"* || $result == *"EOF"* || $result == *"input"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected unexpected end of input error"
fi

echo -n "Test 43 (division by zero with variables): "
result=$(echo "" | ./ecl <(echo "int x x := 0 write 10 / x") 2>&1)
if [[ $result == *"divide by zero"* || $result == *"division"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected division by zero error"
fi

echo -n "Test 44 (real division by zero): "
result=$(echo "" | ./ecl <(echo "real x x := 0.0 write 10.0 / x") 2>&1)
if [[ $result == *"divide by zero"* || $result == *"division"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: Expected division by zero error"
fi

echo ""
echo "=========================================="
echo "Testing Scope and Shadowing"
echo "=========================================="

echo -n "Test 45 (variable shadowing in nested scope): "
result=$(echo "" | ./ecl <(echo "int x x := 5 write x do check 0 int x x := 10 write x od") 2>&1 | tail -1)
if [[ $result == "5" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 46 (variable scope in if block): "
result=$(echo "" | ./ecl <(echo "int x x := 5 if x > 3 then int y y := 10 write y fi") 2>&1 | tail -1)
if [[ $result == "10" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 47 (variable scope in else block): "
result=$(echo "" | ./ecl <(echo "int x x := 2 if x > 3 then int y y := 10 else int z z := 20 write z fi") 2>&1 | tail -1)
if [[ $result == "20" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo ""
echo "=========================================="
echo "Testing Edge Cases"
echo "=========================================="

echo -n "Test 48 (multiple reads): "
result=$(echo "10 20 30" | ./ecl <(echo "int a read a int b read b int c read c write a + b + c") 2>&1 | tail -1)
if [[ $result == "60" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 49 (multiple writes on same line): "
result=$(echo "" | ./ecl <(echo "int a a := 5 int b b := 10 write a write b") 2>&1)
output=$(echo "$result" | grep -v "typecheck" | tr '\n' ' ')
if [[ $output == *"5"* && $output == *"10"* ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $output"
fi

echo -n "Test 50 (empty if-then block): "
result=$(echo "" | ./ecl <(echo "int x x := 5 if x < 3 then fi write 10") 2>&1 | tail -1)
if [[ $result == "10" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 51 (zero as condition): "
result=$(echo "" | ./ecl <(echo "int x x := 0 if x then write 1 else write 2 fi") 2>&1 | tail -1)
if [[ $result == "2" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 52 (non-zero as condition): "
result=$(echo "" | ./ecl <(echo "int x x := 5 if x then write 1 else write 2 fi") 2>&1 | tail -1)
if [[ $result == "1" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 53 (real number precision): "
result=$(echo "" | ./ecl <(echo "real x x := 1.0 / 3.0 write x * 3.0") 2>&1 | tail -1)
if [[ $result == "1.000000" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo -n "Test 54 (nested elsif): "
result=$(echo "" | ./ecl <(echo "int x x := 7 if x < 5 then write 1 elsif x < 8 then write 2 elsif x < 10 then write 3 else write 4 fi") 2>&1 | tail -1)
if [[ $result == "2" ]]; then
    echo "✓ PASS"
else
    echo "✗ FAIL: $result"
fi

echo ""
echo "=========================================="
echo "All Tests Completed"
echo "=========================================="

# Count results
echo ""
echo "Test Summary:"
total=54
echo "Total tests: $total"

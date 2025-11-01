#!/bin/bash

# Comprehensive test suite - Compare with reference implementation
# 全面测试套件 - 与参考实现比较

STUDENT="./ecl"
REFERENCE="/u/cs254/bin/ecl"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
TOTAL=0
PASSED=0
FAILED=0
EXTRA=0  # Extra credit features (no reference comparison)

# Test results arrays
declare -a FAILED_TESTS
declare -a EXTRA_TESTS

# Run test and compare with reference
test_compare() {
    local name="$1"
    local prog="$2"
    local input="$3"

    ((TOTAL++))

    # Run both implementations (with 5s timeout)
    local student_out=$(timeout 5 bash -c "echo '$input' | $STUDENT <(echo '$prog') 2>&1")
    local ref_out=$(timeout 5 bash -c "echo '$input' | $REFERENCE <(echo '$prog') 2>&1")

    # Exact match
    if [[ "$student_out" == "$ref_out" ]]; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
        return 0
    fi

    # Try normalizing float format (5.000000 -> 5.)
    local student_norm=$(echo "$student_out" | sed -E 's/([0-9]+)\.0+($|[^0-9])/\1.\2/g')
    local ref_norm=$(echo "$ref_out" | sed -E 's/([0-9]+)\.0+($|[^0-9])/\1.\2/g')

    if [[ "$student_norm" == "$ref_norm" ]]; then
        echo -e "${YELLOW}≈${NC} $name ${CYAN}(float format)${NC}"
        ((PASSED++))
        return 0
    fi

    # Failed
    echo -e "${RED}✗${NC} $name"
    echo -e "  ${CYAN}Reference:${NC}"
    echo "$ref_out" | sed 's/^/    /'
    echo -e "  ${CYAN}Student:${NC}"
    echo "$student_out" | sed 's/^/    /'
    FAILED_TESTS+=("$name")
    ((FAILED++))
    return 1
}

# Test extra credit feature (no reference comparison)
test_extra() {
    local name="$1"
    local prog="$2"
    local input="$3"
    local expected="$4"

    ((TOTAL++))

    local student_out=$(echo "$input" | $STUDENT <(echo "$prog") 2>&1)

    if [[ "$student_out" == *"$expected"* ]]; then
        echo -e "${BLUE}⊕${NC} $name ${CYAN}(extra credit)${NC}"
        ((EXTRA++))
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $name ${CYAN}(extra credit)${NC}"
        echo -e "  Expected substring: $expected"
        echo -e "  Got: $student_out"
        EXTRA_TESTS+=("$name")
        ((FAILED++))
    fi
}

echo "============================================"
echo "  ECL Comprehensive Test Suite"
echo "============================================"
echo "Student:   $STUDENT"
echo "Reference: $REFERENCE"
echo ""

# ====================
# Section 1: Basic Arithmetic
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 1: Basic Arithmetic (12 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "1.1: Addition" "write 3 + 5" ""
test_compare "1.2: Subtraction" "write 10 - 7" ""
test_compare "1.3: Multiplication" "write 4 * 5" ""
test_compare "1.4: Division" "write 20 / 4" ""
test_compare "1.5: Precedence (mult)" "write 3 + 4 * 2" ""
test_compare "1.6: Precedence (div)" "write 20 - 12 / 3" ""
test_compare "1.7: Left associativity" "write 10 - 3 - 2" ""
test_compare "1.8: Complex expr" "write 2 * 3 + 4 * 5" ""
test_compare "1.9: Real arithmetic" "real x x := 3.5 real y y := 2.0 write x * y" ""
test_compare "1.10: Real division" "real x x := 7.0 real y y := 2.0 write x / y" ""
test_compare "1.11: Int division" "write 7 / 2" ""
test_compare "1.12: Separate int/real" "int x x := 5 real y y := 2.5 write x write y" ""

echo ""

# ====================
# Section 2: Variables
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 2: Variables & Assignment (6 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "2.1: Int declaration" "int x x := 42 write x" ""
test_compare "2.2: Real declaration" "real x x := 3.14 write x" ""
test_compare "2.3: Multiple vars" "int a a := 5 int b b := 10 write a + b" ""
test_compare "2.4: Var in expr" "int x x := 5 int y y := x + 3 write y" ""
test_compare "2.5: Reuse var" "int x x := 10 write x write x * 2" ""
test_compare "2.6: Chain assignment" "int a a := 5 int b b := a int c c := b write c" ""

echo ""

# ====================
# Section 3: I/O
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 3: Input/Output (6 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "3.1: Read int" "int x read x write x" "42"
test_compare "3.2: Read real" "real x read x write x" "3.14"
test_compare "3.3: Multiple reads" "int a read a int b read b write a + b" "10 20"
test_compare "3.4: Sum and average" "int a read a int b read b write a + b write (a + b) / 2" "4 6"
test_compare "3.5: Multiple writes" "int a a := 5 int b b := 10 write a write b write a + b" ""
test_compare "3.6: Write expr" "write 5 * (3 + 2)" ""

echo ""

# ====================
# Section 4: Control Flow
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 4: If/Elsif/Else (10 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "4.1: If true" "int x x := 10 if x > 5 then write 1 fi" ""
test_compare "4.2: If false" "int x x := 3 if x > 5 then write 1 fi write 2" ""
test_compare "4.3: If-else (then)" "int x x := 10 if x > 5 then write 1 else write 2 fi" ""
test_compare "4.4: If-else (else)" "int x x := 3 if x > 5 then write 1 else write 2 fi" ""
test_compare "4.5: Elsif (if)" "int x x := 2 if x == 2 then write 1 elsif x == 3 then write 2 else write 3 fi" ""
test_compare "4.6: Elsif (elsif)" "int x x := 3 if x == 2 then write 1 elsif x == 3 then write 2 else write 3 fi" ""
test_compare "4.7: Elsif (else)" "int x x := 4 if x == 2 then write 1 elsif x == 3 then write 2 else write 3 fi" ""
test_compare "4.8: Multiple elsif" "int x x := 7 if x < 5 then write 1 elsif x < 8 then write 2 elsif x < 10 then write 3 else write 4 fi" ""
test_compare "4.9: Nested if" "int x x := 5 if x > 3 then if x < 10 then write 1 fi fi" ""
test_compare "4.10: Nested if-else" "int x x := 5 if x > 3 then if x > 7 then write 1 else write 2 fi else write 3 fi" ""

echo ""

# ====================
# Section 5: Comparisons
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 5: Comparison Operators (14 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "5.1: Less than (T)" "int x x := 3 if x < 5 then write 1 else write 0 fi" ""
test_compare "5.2: Less than (F)" "int x x := 7 if x < 5 then write 1 else write 0 fi" ""
test_compare "5.3: LE (equal)" "int x x := 5 if x <= 5 then write 1 else write 0 fi" ""
test_compare "5.4: LE (less)" "int x x := 3 if x <= 5 then write 1 else write 0 fi" ""
test_compare "5.5: Greater (T)" "int x x := 7 if x > 5 then write 1 else write 0 fi" ""
test_compare "5.6: Greater (F)" "int x x := 3 if x > 5 then write 1 else write 0 fi" ""
test_compare "5.7: GE (equal)" "int x x := 5 if x >= 5 then write 1 else write 0 fi" ""
test_compare "5.8: GE (greater)" "int x x := 7 if x >= 5 then write 1 else write 0 fi" ""
test_compare "5.9: Equal (T)" "int x x := 5 if x == 5 then write 1 else write 0 fi" ""
test_compare "5.10: Equal (F)" "int x x := 3 if x == 5 then write 1 else write 0 fi" ""
test_compare "5.11: Not equal (T)" "int x x := 3 if x != 5 then write 1 else write 0 fi" ""
test_compare "5.12: Not equal (F)" "int x x := 5 if x != 5 then write 1 else write 0 fi" ""
test_compare "5.13: Compare expr" "int x x := 10 if x + 5 > 12 then write 1 else write 0 fi" ""
test_compare "5.14: Real compare" "real x x := 3.5 if x > 3.0 then write 1 else write 0 fi" ""

echo ""

# ====================
# Section 6: Logical Ops
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 6: Logical Operators (12 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "6.1: And (T∧T)" "int x x := 1 int y y := 1 write x and y" ""
test_compare "6.2: And (T∧F)" "int x x := 1 int y y := 0 write x and y" ""
test_compare "6.3: And (F∧T)" "int x x := 0 int y y := 1 write x and y" ""
test_compare "6.4: And (F∧F)" "int x x := 0 int y y := 0 write x and y" ""
test_compare "6.5: Or (T∨T)" "int x x := 1 int y y := 1 write x or y" ""
test_compare "6.6: Or (T∨F)" "int x x := 1 int y y := 0 write x or y" ""
test_compare "6.7: Or (F∨T)" "int x x := 0 int y y := 1 write x or y" ""
test_compare "6.8: Or (F∨F)" "int x x := 0 int y y := 0 write x or y" ""
test_compare "6.9: Not (¬T)" "int x x := 1 write not x" ""
test_compare "6.10: Not (¬F)" "int x x := 0 write not x" ""
test_compare "6.11: Combined" "int a a := 1 int b b := 0 int c c := 1 write a and (b or c)" ""
test_compare "6.12: In condition" "int x x := 5 if x > 3 and x < 10 then write 1 else write 0 fi" ""

echo ""

# ====================
# Section 7: Type Conversions
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 7: Type Conversions (9 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "7.1: float(literal)" "write float(5)" ""
test_compare "7.2: float(var)" "int x x := 10 write float(x)" ""
test_compare "7.3: float(expr)" "write float(3 + 7)" ""
test_compare "7.4: trunc(literal)" "write trunc(5.9)" ""
test_compare "7.5: trunc(var)" "real x x := 7.8 write trunc(x)" ""
test_compare "7.6: trunc(expr)" "write trunc(3.5 + 2.3)" ""
test_compare "7.7: float+trunc" "int x x := 5 real y y := float(x) int z z := trunc(y) write z" ""
test_compare "7.8: float assign" "int x x := 10 real y y := float(x) write y" ""
test_compare "7.9: trunc assign" "real x x := 7.9 int y y := trunc(x) write y" ""

echo ""

# ====================
# Section 8: Loops
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 8: Loops (6 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "8.1: Simple loop" "int i i := 0 do check i >= 5 write i i := i + 1 od" ""
test_compare "8.2: Immediate exit" "do check 1 write 999 od write 1" ""
test_compare "8.3: Loop sum" "int sum sum := 0 int i i := 1 do check i > 10 sum := sum + i i := i + 1 od write sum" ""
test_compare "8.4: Nested loops" "int i i := 0 do check i >= 3 int j j := 0 do check j >= 2 write i * 10 + j j := j + 1 od i := i + 1 od" ""
test_compare "8.5: Multiple checks" "int x x := 0 do x := x + 1 check x >= 5 write x od" ""
test_compare "8.6: Loop countdown" "int x x := 10 do check x <= 0 x := x - 1 write x od" ""

echo ""

# ====================
# Section 9: Scope
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 9: Scope & Shadowing (6 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "9.1: Scope in if" "int x x := 5 if x > 3 then int y y := 10 write y fi write x" ""
test_compare "9.2: Scope in else" "int x x := 2 if x > 3 then int y y := 10 else int z z := 20 write z fi" ""
test_compare "9.3: Shadow in loop" "int x x := 5 write x do check 0 int x x := 10 write x od" ""
test_compare "9.4: Shadow in if" "int x x := 5 if x > 0 then int x x := 10 write x fi write x" ""
test_compare "9.5: Multi-level" "int x x := 1 write x if x > 0 then int x x := 2 write x if x > 0 then int x x := 3 write x fi write x fi write x" ""
test_compare "9.6: Scope in elsif" "int x x := 5 if x < 3 then int a a := 1 elsif x < 10 then int b b := 2 write b else int c c := 3 fi" ""

echo ""

# ====================
# Section 10: Complex Programs
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 10: Complex Programs (7 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "sum_ave.ecl" ]; then
    test_compare "10.1: sum_ave" "$(cat sum_ave.ecl)" "4 6"
else
    echo -e "${YELLOW}⊘${NC} 10.1: sum_ave (file not found)"
fi

if [ -f "gcd.ecl" ]; then
    test_compare "10.2: gcd (15,10)" "$(cat gcd.ecl)" "15 10"
    test_compare "10.3: gcd (48,18)" "$(cat gcd.ecl)" "48 18"
else
    echo -e "${YELLOW}⊘${NC} 10.2-3: gcd (file not found)"
fi

if [ -f "primes.ecl" ]; then
    test_compare "10.4: primes (10)" "$(cat primes.ecl)" "10"
    test_compare "10.5: primes (5)" "$(cat primes.ecl)" "5"
else
    echo -e "${YELLOW}⊘${NC} 10.4-5: primes (file not found)"
fi

if [ -f "sqrt.ecl" ]; then
    test_compare "10.6: sqrt (16)" "$(cat sqrt.ecl)" "16.0"
    test_compare "10.7: sqrt (25)" "$(cat sqrt.ecl)" "25.0"
else
    echo -e "${YELLOW}⊘${NC} 10.6-7: sqrt (file not found)"
fi

echo ""

# ====================
# Section 11: Static Errors
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 11: Static Errors (18 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "11.1: Undeclared" "write foo" ""
test_compare "11.2: Undeclared in expr" "int x x := 5 write x + y" ""
test_compare "11.3: Redeclaration" "int a a := 2 int a a := 3" ""
test_compare "11.4: Redecl before use" "int x real x" ""
test_compare "11.5: Type int→real" "int a a := 5 real b b := a" ""
test_compare "11.6: Type real→int" "real a a := 5.0 int b b := a" ""
test_compare "11.7: Type in expr" "int x x := 5 real y y := 3.5 write x + y" ""
test_compare "11.8: and left" "real x x := 3.5 write x and 1" ""
test_compare "11.9: and right" "real x x := 3.5 write 1 and x" ""
test_compare "11.10: or left" "real x x := 3.5 write x or 1" ""
test_compare "11.11: or right" "real x x := 3.5 write 1 or x" ""
test_compare "11.12: float(real)" "real x x := 3.5 write float(x)" ""
test_compare "11.13: trunc(int)" "int x x := 3 write trunc(x)" ""
test_compare "11.14: check outside" "check 1" ""
test_compare "11.15: check in if" "int x x := 5 if x > 3 then check 0 fi" ""
test_compare "11.16: check nested if" "int x x := 5 if x > 0 then if x < 10 then check 0 fi fi" ""
test_compare "11.17: Type in compare" "int x x := 5 real y y := 3.5 if x < y then write 1 fi" ""
test_compare "11.18: Assign undeclared" "x := 5" ""

echo ""

# ====================
# Section 12: Dynamic Errors
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 12: Dynamic Errors (10 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "12.1: Div/0 literal" "write 5 / 0" ""
test_compare "12.2: Div/0 var" "int x x := 0 write 10 / x" ""
test_compare "12.3: Div/0 expr" "write 10 / (5 - 5)" ""
test_compare "12.4: Real div/0" "real x x := 0.0 write 10.0 / x" ""
test_compare "12.5: Non-int input" "int a read a" "3.5"
test_compare "12.6: Text for int" "int a read a" "abc"
test_compare "12.7: Text for real" "real x read x" "abc"
test_compare "12.8: EOF int" "int a read a" ""
test_compare "12.9: EOF real" "real x read x" ""
test_compare "12.10: EOF partial" "int a read a int b read b" "5"

echo ""

# ====================
# Section 13: Edge Cases
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 13: Edge Cases (15 tests)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_compare "13.1: Zero condition" "int x x := 0 if x then write 1 else write 2 fi" ""
test_compare "13.2: Nonzero cond" "int x x := 5 if x then write 1 else write 2 fi" ""
test_compare "13.3: Negative cond" "int x x := -5 if x then write 1 else write 2 fi" ""
test_compare "13.4: Empty then" "int x x := 5 if x < 3 then fi write 10" ""
test_compare "13.5: Empty else" "int x x := 5 if x > 3 then write 1 else fi" ""
test_compare "13.6: Large int" "write 1000000 + 2000000" ""
test_compare "13.7: Small real" "write 0.0001 + 0.0002" ""
test_compare "13.8: Negatives" "int x x := -10 int y y := -5 write x + y" ""
test_compare "13.9: Multi-read" "int a read a int b read b int c read c write a + b + c" "10 20 30"
test_compare "13.10: Complex expr" "write ((5 + 3) * (10 - 2)) / (2 + 2)" ""
test_compare "13.11: All compares" "int a a := 5 if a < 10 then write 1 fi if a > 3 then write 2 fi if a == 5 then write 3 fi if a != 4 then write 4 fi if a <= 5 then write 5 fi if a >= 5 then write 6 fi" ""
test_compare "13.12: Deep nesting" "int x x := 5 if x > 0 then if x > 1 then if x > 2 then if x > 3 then if x > 4 then write 1 fi fi fi fi fi" ""
test_compare "13.13: Count up" "int i i := 0 do check i >= 10 write i i := i + 1 od" ""
test_compare "13.14: Count down" "int i i := 10 do check i <= 0 write i i := i - 1 od" ""
test_compare "13.15: Precision" "real x x := 1.0 / 3.0 write x * 3.0" ""

echo ""

# ====================
# Section 14: Unary Operators (Extra - may differ)
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 14: Unary Operators"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${CYAN}(Note: Reference may not support all unary ops)${NC}"

test_compare "14.1: Unary -" "write -5" ""
test_compare "14.2: Unary - var" "int x x := 5 write -x" ""
test_compare "14.3: Unary - expr" "write -(3 + 2)" ""
test_compare "14.4: Double neg" "int x x := 5 write -(-x)" ""
test_compare "14.5: Unary - real" "real x x := 3.5 write -x" ""
test_compare "14.6: Unary in expr" "int x x := 5 write -x + 10" ""

echo ""

# ====================
# Section 15: Boolean Type (Extra Credit)
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 15: Boolean Type (EXTRA CREDIT)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${CYAN}(Reference doesn't support bool - testing student only)${NC}"

test_extra "15.1: Bool decl" "bool x x := true write x" "" "true"
test_extra "15.2: Bool false" "bool x x := false write x" "" "false"
test_extra "15.3: Bool and" "bool a a := true bool b b := false write a and b" "" "false"
test_extra "15.4: Bool or" "bool a a := true bool b b := false write a or b" "" "true"
test_extra "15.5: Bool not" "bool x x := true write not x" "" "false"
test_extra "15.6: Bool ==" "bool a a := true bool b b := true write a == b" "" "true"
test_extra "15.7: Bool !=" "bool a a := true bool b b := false write a != b" "" "true"
test_extra "15.8: Compare→bool" "int x x := 5 bool b b := x < 10 write b" "" "true"
test_extra "15.9: Bool in if" "bool x x := true if x then write 1 else write 2 fi" "" "1"
test_extra "15.10: Bool I/O" "bool a read a write a" "true" "true"

echo ""

# ====================
# Section 16: Constant Folding (Extra Credit)
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Section 16: Constant Folding (EXTRA CREDIT)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${CYAN}(Optimization is internal - checking output)${NC}"

test_compare "16.1: Fold 3+5" "write 3 + 5" ""
test_compare "16.2: Fold nested" "write (3 + 5) * (10 - 2)" ""
test_compare "16.3: Fold in assign" "int x x := 10 + 20 write x" ""
test_compare "16.4: Fold w/ var" "int x x := 5 write x + (10 + 20)" ""
test_compare "16.5: Fold real" "write 3.5 + 2.5" ""
test_compare "16.6: Fold conversion" "write float(10 + 5)" ""
test_compare "16.7: Fold unary" "write -(5 + 3)" ""
test_compare "16.8: Fold logical" "write 1 and 1" ""
test_compare "16.9: Fold in if" "if 3 < 5 then write 100 + 200 fi" ""
test_compare "16.10: Fold mixed" "int a a := 10 * 2 + 5 write a write 1000 + 2000" ""

echo ""

# ====================
# Summary
# ====================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "Total tests:        ${BLUE}$TOTAL${NC}"
echo -e "Passed:             ${GREEN}$PASSED${NC}"
echo -e "  - Core matched:   ${GREEN}$((PASSED - EXTRA))${NC}"
echo -e "  - Extra credit:   ${BLUE}$EXTRA${NC}"
echo -e "Failed:             ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  Failed Tests:${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $test"
    done
    for test in "${EXTRA_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $test ${CYAN}(extra)${NC}"
    done
    echo ""
fi

# Calculate percentage
percent=$((PASSED * 100 / TOTAL))

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $percent -ge 90 ]; then
    echo -e "${GREEN}  Score: $percent% - EXCELLENT!${NC}"
elif [ $percent -ge 80 ]; then
    echo -e "${YELLOW}  Score: $percent% - Good${NC}"
else
    echo -e "${RED}  Score: $percent% - Needs work${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED

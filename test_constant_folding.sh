#!/bin/bash

# Test script for constant folding optimization
# This script demonstrates the constant folding optimization in the ECL interpreter

echo "========================================"
echo "  Constant Folding Test Suite"
echo "========================================"
echo ""

# Compile the interpreter if needed
if [ ! -f ./ecl ]; then
    echo "Compiling ECL interpreter..."
    ocamlc -o ecl -I +str str.cma ecl.ml
    if [ $? -ne 0 ]; then
        echo "Compilation failed!"
        exit 1
    fi
    echo "Compilation successful!"
    echo ""
fi

# Test 1: Simple arithmetic
echo "Test 1: Simple Arithmetic Folding"
echo "===================================="
cat > /tmp/test1.ecl << 'EOF'
// Test constant folding of simple arithmetic
write 3 + 5
write 10 * 2
write 100 / 4
write 20 - 8
EOF
echo "Program:"
cat /tmp/test1.ecl
echo ""
echo "Output:"
./ecl /tmp/test1.ecl
echo ""
echo ""

# Test 2: Nested expressions
echo "Test 2: Nested Expression Folding"
echo "===================================="
cat > /tmp/test2.ecl << 'EOF'
// Nested constant expressions should be fully folded
write (3 + 5) * (10 - 2)
write ((4 + 6) / 2) + (8 * 3)
EOF
echo "Program:"
cat /tmp/test2.ecl
echo ""
echo "Output:"
./ecl /tmp/test2.ecl
echo ""
echo ""

# Test 3: Comparisons
echo "Test 3: Comparison Folding"
echo "===================================="
cat > /tmp/test3.ecl << 'EOF'
// Constant comparisons should fold to boolean values
write 5 < 10
write 10 == 10
write 3 > 7
write 5 <= 5
EOF
echo "Program:"
cat /tmp/test3.ecl
echo ""
echo "Output:"
./ecl /tmp/test3.ecl
echo ""
echo ""

# Test 4: Real arithmetic
echo "Test 4: Real Number Arithmetic"
echo "===================================="
cat > /tmp/test4.ecl << 'EOF'
// Real number constant folding
write 3.5 + 2.5
write 10.0 * 2.5
write 20.0 / 4.0
EOF
echo "Program:"
cat /tmp/test4.ecl
echo ""
echo "Output:"
./ecl /tmp/test4.ecl
echo ""
echo ""

# Test 5: Type conversions
echo "Test 5: Type Conversion Folding"
echo "===================================="
cat > /tmp/test5.ecl << 'EOF'
// Type conversions of constants should fold
write float(10)
write trunc(3.14)
write float(5 + 3)
EOF
echo "Program:"
cat /tmp/test5.ecl
echo ""
echo "Output:"
./ecl /tmp/test5.ecl
echo ""
echo ""

# Test 6: Logical operations
echo "Test 6: Logical Operation Folding"
echo "===================================="
cat > /tmp/test6.ecl << 'EOF'
// Logical operations on constants
write 1 and 1
write 0 or 1
write 1 and 0
EOF
echo "Program:"
cat /tmp/test6.ecl
echo ""
echo "Output:"
./ecl /tmp/test6.ecl
echo ""
echo ""

# Test 7: Unary operators
echo "Test 7: Unary Operator Folding"
echo "===================================="
cat > /tmp/test7.ecl << 'EOF'
// Unary operators on constant expressions
write -(5 + 3)
write -10
write not 0
write not 1
EOF
echo "Program:"
cat /tmp/test7.ecl
echo ""
echo "Output:"
./ecl /tmp/test7.ecl
echo ""
echo ""

# Test 8: Mixed with variables
echo "Test 8: Partial Folding (with variables)"
echo "===================================="
cat > /tmp/test8.ecl << 'EOF'
// Only constant parts should be folded
int x
int y
x := 3 + 5
y := x * 2
write 10 + 20
write x + y
EOF
echo "Program:"
cat /tmp/test8.ecl
echo ""
echo "Output (note: 10 + 20 is folded to 30, but x * 2 is not):"
echo "5" | ./ecl /tmp/test8.ecl
echo ""
echo ""

# Test 9: Control flow
echo "Test 9: Control Flow with Constants"
echo "===================================="
cat > /tmp/test9.ecl << 'EOF'
// Constants in control flow should be folded
if 3 < 5 then
    write 100 + 200
else
    write 50 * 2
fi
EOF
echo "Program:"
cat /tmp/test9.ecl
echo ""
echo "Output (condition 3 < 5 folded to true, 100 + 200 folded to 300):"
./ecl /tmp/test9.ecl
echo ""
echo ""

# Test 10: Complex example
echo "Test 10: Complex Program with Multiple Optimizations"
echo "===================================="
cat > /tmp/test10.ecl << 'EOF'
// More realistic example with multiple constant folding opportunities
int a
int b
a := 10 * 2 + 5
b := (100 - 50) / 2
write a
write b
write 1000 + 2000
write 5 < 10
EOF
echo "Program:"
cat /tmp/test10.ecl
echo ""
echo "Output:"
./ecl /tmp/test10.ecl
echo ""
echo ""

# Cleanup
rm -f /tmp/test*.ecl

echo "========================================"
echo "  All Tests Completed!"
echo "========================================"
echo ""
echo "Summary:"
echo "- Constants in arithmetic expressions are folded"
echo "- Nested constant expressions are fully evaluated"
echo "- Type conversions on constants are performed"
echo "- Comparison and logical operations are optimized"
echo "- Unary operators are applied to constants"
echo "- Variables prevent folding (as expected)"
echo ""
echo "For detailed before/after AST comparison, use:"
echo "  ocaml"
echo "  # #load \"str.cma\";;"
echo "  # #use \"ecl.ml\";;"
echo "  # show_ast2_with_fold \"write 3 + 5\";;"

#!/bin/bash

# 全面测试比较脚本
# 比较我们的实现和官方版本的输出

cd "/home/hoover/u5/zzh133/CSC 254/Assignment 2/calc_parse"

echo "=========================================="
echo "🔍 calc_parse 完整测试比较报告"
echo "=========================================="
echo

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 统计变量
total_tests=0
passed_tests=0
failed_tests=0

# 函数：比较两个输出
compare_outputs() {
    local test_name="$1"
    local official_output="$2"
    local our_output="$3"
    
    # 提取AST部分
    local official_ast=$(echo "$official_output" | grep -A1 "Parse completed.*AST is" | tail -1 | sed 's/^[ \t]*//')
    local our_ast=$(echo "$our_output" | grep -A1 "Parse completed.*AST is" | tail -1 | sed 's/^[ \t]*//')
    
    # 检查是否有错误
    local official_error=$(echo "$official_output" | grep -i "error\|panic\|syntax error")
    local our_error=$(echo "$our_output" | grep -i "error\|panic\|syntax error")
    
    total_tests=$((total_tests + 1))
    
    if [ "$official_ast" = "$our_ast" ] && [ -z "$our_error" ]; then
        echo -e "✅ ${GREEN}PASS${NC}: $test_name"
        echo -e "   AST: $official_ast"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        echo -e "❌ ${RED}FAIL${NC}: $test_name"
        if [ "$official_ast" != "$our_ast" ]; then
            echo -e "   ${YELLOW}AST差异:${NC}"
            echo -e "   官方: $official_ast"
            echo -e "   我们: $our_ast"
        fi
        if [ -n "$our_error" ]; then
            echo -e "   ${RED}我们的版本有错误:${NC}"
            echo "$our_error" | head -3 | sed 's/^/   /'
        fi
        if [ -n "$official_error" ] && [ -z "$our_error" ]; then
            echo -e "   ${YELLOW}官方版本有错误但我们没有:${NC}"
            echo "$official_error" | head -3 | sed 's/^/   /'
        fi
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

# 测试所有tests目录中的文件
echo -e "${BLUE}📁 测试目录中的文件:${NC}"
for testfile in tests/*.txt; do
    if [ -f "$testfile" ]; then
        test_name=$(basename "$testfile")
        echo -e "\n${BLUE}🧪 测试文件: $test_name${NC}"
        echo "----------------------------------------"
        
        # 运行官方版本
        official_output=$(timeout 10s ~cs254/bin/calc_parse < "$testfile" 2>&1)
        official_exit_code=$?
        
        # 运行我们的版本
        our_output=$(timeout 10s cargo run < "$testfile" 2>&1)
        our_exit_code=$?
        
        # 检查超时
        if [ $official_exit_code -eq 124 ]; then
            echo -e "   ${YELLOW}警告: 官方版本超时${NC}"
        fi
        if [ $our_exit_code -eq 124 ]; then
            echo -e "   ${RED}错误: 我们的版本超时${NC}"
        fi
        
        compare_outputs "$test_name" "$official_output" "$our_output"
    fi
done

# 测试一些手写的测试案例
echo -e "\n${BLUE}📝 额外测试案例:${NC}"

test_cases=(
    "int n"
    "int n\nread n\nn := 2\nwrite n"
    "int n\nread n\nif n > 0 then\n  write n\nfi"
    "int n\nread n\nif n > 0 then\n  write n\nelse\n  write 0\nfi"
    "real x\nx := 3.14\nwrite x"
    "int i\ni := 0\ndo\n  check i < 10\n  write i\n  i := i + 1\nod"
)

test_names=(
    "简单声明"
    "基本读写"
    "if语句"
    "if-else语句"
    "实数测试"
    "do循环测试"
)

for i in "${!test_cases[@]}"; do
    test_name="${test_names[$i]}"
    test_input="${test_cases[$i]}"
    
    echo -e "\n${BLUE}🧪 测试案例: $test_name${NC}"
    echo "----------------------------------------"
    
    # 运行官方版本
    official_output=$(echo -e "$test_input" | timeout 10s ~cs254/bin/calc_parse 2>&1)
    official_exit_code=$?
    
    # 运行我们的版本
    our_output=$(echo -e "$test_input" | timeout 10s cargo run 2>&1)
    our_exit_code=$?
    
    # 检查超时
    if [ $official_exit_code -eq 124 ]; then
        echo -e "   ${YELLOW}警告: 官方版本超时${NC}"
    fi
    if [ $our_exit_code -eq 124 ]; then
        echo -e "   ${RED}错误: 我们的版本超时${NC}"
    fi
    
    compare_outputs "$test_name" "$official_output" "$our_output"
done

# 边界情况测试
echo -e "\n${BLUE}🎯 边界情况测试:${NC}"

edge_cases=(
    ""
    "int"
    "int n\nn := \n"
    "if then fi"
    "int n\nif n >= 5 then\n  write n\nelsif n <= 2 then\n  write 0\nelse\n  write 1\nfi"
)

edge_names=(
    "空输入"
    "不完整声明"
    "语法错误1"
    "语法错误2"
    "复杂条件"
)

for i in "${!edge_cases[@]}"; do
    test_name="${edge_names[$i]}"
    test_input="${edge_cases[$i]}"
    
    echo -e "\n${BLUE}🧪 边界测试: $test_name${NC}"
    echo "----------------------------------------"
    
    # 运行官方版本
    official_output=$(echo -e "$test_input" | timeout 10s ~cs254/bin/calc_parse 2>&1)
    official_exit_code=$?
    
    # 运行我们的版本
    our_output=$(echo -e "$test_input" | timeout 10s cargo run 2>&1)
    our_exit_code=$?
    
    compare_outputs "$test_name" "$official_output" "$our_output"
done

# 最终统计
echo -e "\n=========================================="
echo -e "${BLUE}📊 测试结果统计${NC}"
echo "=========================================="
echo -e "总测试数: $total_tests"
echo -e "${GREEN}通过: $passed_tests${NC}"
echo -e "${RED}失败: $failed_tests${NC}"

if [ $failed_tests -eq 0 ]; then
    echo -e "\n🎉 ${GREEN}恭喜！所有测试都通过了！${NC}"
    exit 0
else
    echo -e "\n⚠️  ${YELLOW}有 $failed_tests 个测试失败，需要修复${NC}"
    echo -e "\n${BLUE}建议:${NC}"
    echo "1. 检查失败的测试案例"
    echo "2. 分析AST差异的原因"
    echo "3. 修复相应的语义动作"
    echo "4. 重新运行测试"
    exit 1
fi
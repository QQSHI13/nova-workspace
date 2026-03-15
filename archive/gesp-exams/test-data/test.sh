#!/bin/bash

# 测试脚本
# 用法: ./test.sh [problem_number]
# 例如: ./test.sh 1

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROBLEM=${1:-1}  # 默认测试第1题

echo "================================"
echo "Testing Problem $PROBLEM"
echo "================================"
echo ""

# 检查可执行文件
if [ ! -f "solution" ]; then
    echo "❌ Error: 'solution' not found!"
    echo "Please compile first: g++ your_code.cpp -o solution"
    exit 1
fi

PASSED=0
FAILED=0

for infile in problem$PROBLEM/*.in; do
    # 获取测试点编号
    testnum=$(basename "$infile" .in)
    outfile="problem$PROBLEM/$testnum.out"
    
    echo -n "Test $testnum: "
    
    # 运行程序
    ./solution < "$infile" > tmp.out 2>/dev/null
    
    # 比较输出
    if diff -q tmp.out "$outfile" > /dev/null 2>&1; then
        echo "✓ PASSED"
        ((PASSED++))
    else
        echo "✗ FAILED"
        echo "  Input:"
        head -5 "$infile" | sed 's/^/    /'
        echo "  Expected: $(cat $outfile)"
        echo "  Got:      $(cat tmp.out)"
        ((FAILED++))
    fi
done

echo ""
echo "================================"
echo "Results: $PASSED passed, $FAILED failed"
echo "================================"

# 清理
rm -f tmp.out

# 返回状态
if [ $FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    exit 1
fi

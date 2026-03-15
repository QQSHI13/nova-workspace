# 测试数据说明

## 使用方法

### Linux/Mac/WSL:
```bash
# 编译你的程序
g++ your_code.cpp -o solution

# 测试单个文件
./solution < problem1/1.in > my_output.txt
diff my_output.txt problem1/1.out

# 或者用脚本批量测试
for i in 1 2 3 4 5; do
    echo "Testing $i..."
    ./solution < problem1/$i.in > tmp.out
    if diff -q tmp.out problem1/$i.out > /dev/null; then
        echo "✓ PASSED"
    else
        echo "✗ FAILED"
        echo "Expected:"
        cat problem1/$i.out
        echo "Got:"
        cat tmp.out
    fi
done
```

### Windows:
```cmd
:: 编译
g++ your_code.cpp -o solution.exe

:: 测试
solution.exe < problem1\1.in > my_output.txt
fc my_output.txt problem1\1.out
```

---

## 第1题：矩阵中的最长递增路径

**测试点说明：**
- 1.in：样例，基础测试
- 2.in：最小规模 1x1
- 3.in：所有元素相同，答案为1
- 4.in：严格递增矩阵
- 5.in：大数值随机数据

---

## 第2题：最小花费爬楼梯

**测试点说明：**
- 1.in：样例1，基础测试
- 2.in：样例2，跳跃模式
- 3.in：最小规模 n=2
- 4.in：全部相同花费
- 5.in：递增花费

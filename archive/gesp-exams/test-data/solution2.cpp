#include <bits/stdc++.h>
using namespace std;

// 参考解法2：最小花费爬楼梯
int main() {
    int n;
    cin >> n;
    vector<int> cost(n);
    for (int i = 0; i < n; i++) cin >> cost[i];
    
    // dp[i] = 到达第i级的最小花费
    vector<int> dp(n + 1, 0);
    dp[0] = 0;  // 从第0级开始，花费0
    dp[1] = 0;  // 从第1级开始，花费0
    
    for (int i = 2; i <= n; i++) {
        // 可以从i-1爬1级，或从i-2爬2级
        dp[i] = min(dp[i-1] + cost[i-1], dp[i-2] + cost[i-2]);
    }
    
    cout << dp[n] << endl;
    return 0;
}

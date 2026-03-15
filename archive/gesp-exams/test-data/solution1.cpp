#include <bits/stdc++.h>
using namespace std;

// 参考解法1：矩阵中的最长递增路径
int main() {
    int n, m;
    cin >> n >> m;
    vector<vector<int>> a(n, vector<int>(m));
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            cin >> a[i][j];
    
    // 记忆化搜索
    vector<vector<int>> dp(n, vector<int>(m, 0));
    int ans = 1;
    
    function<int(int, int)> dfs = [&](int x, int y) -> int {
        if (dp[x][y]) return dp[x][y];
        int res = 1;
        int dx[] = {-1, 1, 0, 0};
        int dy[] = {0, 0, -1, 1};
        for (int i = 0; i < 4; i++) {
            int nx = x + dx[i], ny = y + dy[i];
            if (nx >= 0 && nx < n && ny >= 0 && ny < m && a[nx][ny] > a[x][y]) {
                res = max(res, 1 + dfs(nx, ny));
            }
        }
        dp[x][y] = res;
        return res;
    };
    
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            ans = max(ans, dfs(i, j));
    
    cout << ans << endl;
    return 0;
}

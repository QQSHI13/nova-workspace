# GESP 7级 Exam Post-Mortem

## Result
- **Status**: Failed
- **Score**: Only 5 points on coding problems
- **Date**: March 14, 2026

## Problem Analysis

### Problem 1: Integer Break (Maximum Product)
**What it was**: Given n (n ≤ 1,000,000), break into sum of integers and maximize product.

**Optimal Strategy**:
- Break into as many 3s as possible
- Why 3? Closest integer to e ≈ 2.718
- Edge case: when remainder is 1, use two 2s instead of 3+1

**Why QQ Failed**:
- Thought larger numbers = better product
- Didn't realize multiplication favors balance over size
- Didn't know the mathematical pattern (3s are optimal)

**Solution Pattern**:
```cpp
if (n <= 3) return n - 1;  // Special cases
long long product = 1;
while (n > 4) {
    product *= 3;
    n -= 3;
}
return product * n;  // n is now 2, 3, or 4
```

---

### Problem 2: Shortest Path with Bonus
**What it was**: Shortest path from 1 to n, where each edge has (weight, bonus). Can subtract the maximum bonus in the path once.

**Why QQ Failed**:
- Used DFS (wrong algorithm entirely)
- DFS finds any path, not shortest path
- Weighted shortest path requires Dijkstra
- Problem was beyond GESP 7 syllabus (which only covered DFS/BFS/Flood Fill)

**Correct Approach**:
```cpp
// Try each possible max bonus value
for each bonus B in sorted_order:
    // Run Dijkstra using only edges with bonus <= B
    dist = dijkstra(edges_with_bonus_leq_B)
    if (node n reachable):
        answer = min(answer, dist[n] - B)
```

**Key Insight**: For any valid path with max bonus B*, only edges with bonus ≤ B* can be used. So when we process B = B*, we find the optimal path.

---

## Lessons Learned

1. **Syllabus Gap**: GESP 7 teaches "basic graph theory" (DFS/BFS) but tests on shortest path algorithms (Dijkstra)
2. **Algorithm Confusion**: DFS is for "can I reach there?", not "what's the shortest path?"
3. **Mathematical Intuition**: Multiplication problems often require counter-intuitive patterns (like using 3s)
4. **Time Management**: Need to quickly identify algorithm category and match to correct approach

---

## Algorithms to Learn for Next Exam

### Graph Algorithms (Priority 1)
- **Dijkstra** — weighted single-source shortest path
- **Floyd-Warshall** — all-pairs shortest path, O(n³)
- **Bellman-Ford / SPFA** — shortest path with negative edges
- **Kruskal / Prim** — Minimum Spanning Tree
- **Topological Sort** — ordering with dependencies

### Data Structures (Priority 1)
- **Disjoint Set Union (DSU/Union-Find)** — connectivity, cycle detection
- **Binary Indexed Tree (Fenwick)** — prefix sums, range queries
- **Segment Tree** — range queries and updates
- **Sparse Table** — RMQ in O(1) after O(n log n) preprocessing

### Advanced DP
- **Tree DP** — DP on tree structures
- **Digit DP** — counting with digit constraints
- **Knapsack variations** — 0/1, complete, multiple

### String Algorithms
- **KMP** — pattern matching
- **Rolling Hash / Prefix Hash** — string comparison

### Math
- **Fast Power (modular)** — a^b mod m in O(log b)
- **Extended Euclidean** — ax + by = gcd(a,b)
- **Sieve of Eratosthenes** — prime generation

---

## Next Steps
- Review these algorithms systematically
- Practice implementation from scratch
- Do timed practice problems
- Re-take GESP 7 in next exam cycle

**Created**: March 14, 2026

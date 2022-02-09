### 总结

+ BFS 广度优先遍历使用队列（quue）模拟每一层的结果
+ bfs就跟二叉树的层次遍历一样，需要统计每一层的结果

### 994. 腐烂的橘子

+ 力扣994：[994. 腐烂的橘子](https://leetcode-cn.com/problems/rotting-oranges/)

```
在给定的 m x n 网格 grid 中，每个单元格可以有以下三个值之一：
值 0 代表空单元格；
值 1 代表新鲜橘子；
值 2 代表腐烂的橘子。
每分钟，腐烂的橘子 周围 4 个方向上相邻 的新鲜橘子都会腐烂。
返回 直到单元格中没有新鲜橘子为止所必须经过的最小分钟数。如果不可能，返回 -1 。

输入：grid = [[2,1,1],[1,1,0],[0,1,1]]
输出：4
```

+ 题解：
  + 需要统计一个烂橘子向四周扩散的情况，就是层次遍历
  + 需要统计每层的情况，有多少层就需要多少时间
  + 先计算出一个坏橘子的位置和好橘子的个数
  + 然后用一个队列模拟坏橘子四周扩散的情况

```cpp
class Solution {
 public:
  int orangesRotting(vector<vector<int>>& grid) {
    if (grid.size() <= 0) return -1;

    int ans = 0;
    queue<pair<int, int>> bad;  // 保存坏橘子的下标
    int cnt = 0;                // 保存好橘子的个数
    for (int i = 0; i < grid.size(); i++) {
      for (int j = 0; j < grid[0].size(); j++) {
        if (grid[i][j] == 2) {
          bad.push({i, j});
        } else if (grid[i][j] == 1) {
          cnt++;
        }
      }
    }

    while (!bad.empty() && cnt > 0) {
      int n = bad.size();
      ans++;
      // 跟二叉树层次遍历一样，遍历该层情况
      while (n--) {
        pair<int, int> pos = bad.front();
        bad.pop();
        int i = pos.first;
        int j = pos.second;

        if (i - 1 >= 0 && grid[i - 1][j] == 1) {
          grid[i - 1][j] = 2;
          bad.push({i - 1, j});
          cnt--;
        }

        if (i + 1 < grid.size() && grid[i + 1][j] == 1) {
          grid[i + 1][j] = 2;
          bad.push({i + 1, j});
          cnt--;
        }

        if (j - 1 >= 0 && grid[i][j - 1] == 1) {
          grid[i][j - 1] = 2;
          bad.push({i, j - 1});
          cnt--;
        }

        if (j + 1 < grid[0].size() && grid[i][j + 1] == 1) {
          grid[i][j + 1] = 2;
          bad.push({i, j + 1});
          cnt--;
        }
      }
    }

    return cnt == 0 ? ans : -1;
  }
};
```


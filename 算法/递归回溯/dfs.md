## 总结

+ 画出二叉树的结果图，选与不选的情况。二叉树的递归遍历
+ 模板

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(vector<int>& nums, int idx, vector<int>& tmp) {
    // 退出条件
    // 如果满足条件则加入结果     ans.push_back(tmp);
    
    // 从idx开始遍历
    for (int i = idx; i < nums.size(); i++) {
      tmp.push_back(nums[i]);	// 选择该元素
      dfs(nums, i + 1, tmp);	// idx之前处理完了，处理
      tmp.pop_back();			// 该元素不选择
    }
  }

  vector<vector<int>> subsets(vector<int>& nums) {
    vector<int> tmp;
    dfs(nums, 0, tmp;
    return ans;
  }
};
```

## 子集

### 子集

+ 力扣78：[78. 子集](https://leetcode-cn.com/problems/subsets/)

```
给你一个整数数组 nums ，数组中的元素 互不相同 。返回该数组所有可能的子集（幂集）。
解集 不能 包含重复的子集。你可以按 任意顺序 返回解集。

输入：nums = [1,2,3]
输出：[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]

输入：nums = [0]
输出：[[],[0]]
```

+ 题解
  + 将选择和不选择的情况都统计出来

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(vector<int>& nums, int idx, vector<int>& tmp) {
    ans.push_back(tmp);	// 将一个子集加入结果
    if (idx >= nums.size()) return;
    for (int i = idx; i < nums.size(); i++) {
      tmp.push_back(nums[i]);
      dfs(nums, i + 1, tmp);
      tmp.pop_back();
    }
  }

  vector<vector<int>> subsets(vector<int>& nums) {
    vector<int> tmp;
    dfs(nums, 0, tmp);
    return ans;
  }
};
```

### 子集 II

+ 力扣90：[子集 II](https://leetcode-cn.com/problems/subsets-ii/)

```cpp
给你一个整数数组 nums ，其中可能包含重复元素，请你返回该数组所有可能的子集（幂集）。
解集 不能 包含重复的子集。返回的解集中，子集可以按 任意顺序 排列。

输入：nums = [1,2,2]
输出：[[],[1],[1,2],[1,2,2],[2],[2,2]]

输入：nums = [0]
输出：[[],[0]]
```

+ 题解
  + 这道题有重复元素，且不能重复，所以先排序，后续可以过滤部分情况
  + 如果当前值跟上一个值相同，则这个值得情况都已经遍历过，无需在遍历

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(vector<int>& nums, int idx, vector<int>& tmp) {
    ans.push_back(tmp);
    if (idx >= nums.size()) return;
    for (int i = idx; i < nums.size(); i++) {
      // 如果当前值跟上一个值相同则，当前值不需要遍历，因为已经重复了
      if (i > idx && nums[i] == nums[i - 1]) continue;
      tmp.push_back(nums[i]);  // 选上当前数值
      dfs(nums, i + 1, tmp);
      tmp.pop_back();  // 取消当前数值
    }
  }

  vector<vector<int>> subsetsWithDup(vector<int>& nums) {
    vector<int> tmp;
    sort(nums.begin(), nums.end());  // 先排序，让结果可以直接跳过部分情况
    dfs(nums, 0, {});
    return ans;
  }
};
```

## 组合

### 组合

+ 力扣77：[77. 组合](https://leetcode-cn.com/problems/combinations/)

```
给定两个整数 n 和 k，返回范围 [1, n] 中所有可能的 k 个数的组合。
你可以按 任何顺序 返回答案。

输入：n = 4, k = 2
输出：
[
  [2,4],
  [3,4],
  [2,3],
  [1,2],
  [1,3],
  [1,4],
]
```

+ 题解：
  + 统计选择和不选择的情况
  + 满足条件则加入到结果集

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(int n, int k, int idx, vector<int>& tmp) {
    // 满足k则不再循环
    if (tmp.size() == k) {
      ans.push_back(tmp);
      return;
    }
    for (int i = idx; i < n + 1; i++) {
      tmp.push_back(i);       // 选择i
      dfs(n, k, i + 1, tmp);  // 选择i的情况，进行下一个数选择
      tmp.pop_back();         // 不选择i
    }
  }
  vector<vector<int>> combine(int n, int k) {
    vector<int> tmp;
    dfs(n, k, 1, tmp);
    return ans;
  }
};
```

### 组合总和

+ 力扣39：[39. 组合总和](https://leetcode-cn.com/problems/combination-sum/)

```
给你一个 无重复元素 的整数数组 candidates 和一个目标整数 target ，找出 candidates 中可以使数字和为目标数 target 的 所有 不同组合 ，并以列表形式返回。你可以按 任意顺序 返回这些组合。
candidates 中的 同一个 数字可以 无限制重复被选取 。如果至少一个数字的被选数量不同，则两种组合是不同的。 
对于给定的输入，保证和为 target 的不同组合数少于 150 个。

输入：candidates = [2,3,6,7], target = 7
输出：[[2,2,3],[7]]
解释：
2 和 3 可以形成一组候选，2 + 2 + 3 = 7 。注意 2 可以使用多次。
7 也是一个候选， 7 = 7 。
仅有这两种组合。

输入: candidates = [2,3,5], target = 8
输出: [[2,2,2,2],[2,3,3],[3,5]]
```

+ 题解
  + 统计选择和不选择的情况
  + 满足条件则加入到结果集

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(vector<int>& candidates, int target, int idx, vector<int>& tmp) {
    if (target < 0) return;
    if (target == 0) {
      ans.push_back(tmp);
      return;
    }
    for (int i = idx; i < candidates.size(); i++) {
      tmp.push_back(candidates[i]);  // 选择该值
      // target减去该值，因为选上了该值。从i的位置开始下次递归，因为数值可以重复
      dfs(candidates, target - candidates[i], i + 1, tmp);       
      tmp.pop_back();  // 这里得target还是旧值
    }
  }
  vector<vector<int>> combinationSum(vector<int>& candidates, int target) {
      vector<int> tmp;
    dfs(candidates, target, 0, tmp);
    return ans;
  }
};
```

### 组合总和 II

+ 力扣40：[40. 组合总和 II](https://leetcode-cn.com/problems/combination-sum-ii/)

```
给定一个候选人编号的集合 candidates 和一个目标数 target ，找出 candidates 中所有可以使数字和为 target 的组合。
candidates 中的每个数字在每个组合中只能使用 一次 。
注意：解集不能包含重复的组合。 

输入: candidates = [10,1,2,7,6,1,5], target = 8,
输出:
[
[1,1,6],
[1,2,5],
[1,7],
[2,6]
]
```

+ 题解
  + 这道题有重复元素，且不能重复，所以先排序，后续可以过滤部分情况
  + 统计选择和不选择的情况
  + 满足条件则加入到结果集

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(vector<int>& candidates, int target, int idx, vector<int>& tmp) {
    if (target < 0) return;
    if (target == 0) {
      ans.push_back(tmp);
      return;
    }
    for (int i = idx; i < candidates.size(); i++) {
      if (i > idx && candidates[i] == candidates[i - 1]) continue;
      tmp.push_back(candidates[i]);  // 选择该值
      // target减去该值，因为选上了
      dfs(candidates, target - candidates[i], i + 1, tmp);        
      tmp.pop_back();  // 这里得target还是旧值
    }
  }
  vector<vector<int>> combinationSum2(vector<int>& candidates, int target) {
    sort(candidates.begin(), candidates.end());
    vector<int> tmp;
    dfs(candidates, target, 0, tmp);
    return ans;
  }
};
```

### 组合总和 III

+ 力扣216：[216. 组合总和 III](https://leetcode-cn.com/problems/combination-sum-iii/)

```
找出所有相加之和为 n 的 k 个数的组合。组合中只允许含有 1 - 9 的正整数，并且每种组合中不存在重复的数字。
说明：
所有数字都是正整数。
解集不能包含重复的组合。 

输入: k = 3, n = 7
输出: [[1,2,4]]

输入: k = 3, n = 9
输出: [[1,2,6], [1,3,5], [2,3,4]]
```

+ 题解
  + 这题跟**力扣39组合总和**解法一样

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(int k, int n, int idx, vector<int>& tmp) {
    if (n < 0) return;
    if (n == 0) {
      if (tmp.size() == k) {
        ans.push_back(tmp);
      }
      return;
    }
    for (int i = idx; i <= 9; i++) {
      tmp.push_back(i);
      dfs(k, n - i, i + 1, tmp);
      tmp.pop_back();
    }
  }
  vector<vector<int>> combinationSum3(int k, int n) {
    vector<int> tmp;
    dfs(k, n, 1, tmp);
    return ans;
  }
};
```

### 组合总和4（TODO）

## 全排列

### 全排列

+ 力扣46：[46. 全排列](https://leetcode-cn.com/problems/permutations/)

```
给定一个不含重复数字的数组 nums ，返回其 所有可能的全排列 。你可以 按任意顺序 返回答案。

输入：nums = [1,2,3]
输出：[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
```

+ 题解
  + 这道题用交换
  + 两两元素交换，idx大于nums.size则nums就是结果

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(vector<int>& nums, int idx) {
    if (idx >= nums.size()) {
      ans.push_back(nums);
      return;
    }
    for (int i = idx; i < nums.size(); i++) {
      swap(nums[i], nums[idx]);
      dfs(nums, idx + 1);
      swap(nums[idx], nums[i]);
    }
  }
  vector<vector<int>> permute(vector<int>& nums) {
    dfs(nums, 0);
    return ans;
  }
};
```

### 全排列 II

+ 力扣47：[47. 全排列 II](https://leetcode-cn.com/problems/permutations-ii/)

```
给定一个可包含重复数字的序列 nums ，按任意顺序 返回所有不重复的全排列。

输入：nums = [1,1,2]
输出：
[[1,1,2],
 [1,2,1],
 [2,1,1]]
 
输入：nums = [1,2,3]
输出：[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
```

+ 题解：[回溯搜索 + 剪枝（Java、Python）](https://leetcode-cn.com/problems/permutations-ii/solution/hui-su-suan-fa-python-dai-ma-java-dai-ma-by-liwe-2/)
  + 用一个used保存数组每个元素是否访问过
  + 先对数组排序，才能进行裁剪
  + 数组遍历从0开始，因为每个元素都要加入到tmp数组中，且每个元素加入数组的时机不同，所以得从0开始遍历
  + 如果元素访问过则跳过
  + 如果元素下表大于0，且当前元素跟上一个元素相同，且上一个元素没被访问过，则跳过。因为如果上个元素没被访问过，那他就是已经访问过一次，然后撤回导致没被访问。这种情况已经包含了，所以跳过

```cpp
class Solution {
  vector<vector<int>> ans;

 public:
  void dfs(vector<int>& nums, vector<bool>& used, vector<int>& tmp) {
    if (tmp.size() == nums.size()) {
      ans.push_back(tmp);
      return;
    }
    // 数组遍历从0开始，因为每个元素都要加入到tmp数组中，且每个元素加入数组的时机不同，所以得从0开始遍历
    for (int i = 0; i < nums.size(); i++) {
      // 如果元素访问过则跳过
      // 元素下表大于0，且当前元素跟上一个元素相同，且上一个元素没被访问过，则跳过。因为如果上个元素没被访问过，那他就是已经访问过一次，然后撤回导致没被访问。这种情况已经包含了，所以跳过
      if (used[i] || (i > 0 && nums[i] == nums[i - 1] && !used[i - 1])) continue;
      tmp.push_back(nums[i]);
      used[i] = true;		// 先被访问
      dfs(nums, used, tmp);
      tmp.pop_back();		// 撤销，后被访问
      used[i] = false;
    }
  }
  vector<vector<int>> permuteUnique(vector<int>& nums) {
    sort(nums.begin(), nums.end());
    vector<bool> used(nums.size(), false);
    vector<int> tmp;
    dfs(nums,  used, tmp);
    return ans;
  }
};
```

### 下一个排列（TODO）

## 应用题

### 括号生成

+ 力扣22：[22. 括号生成](https://leetcode-cn.com/problems/generate-parentheses/)

```
数字 n 代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且 有效的 括号组合。

输入：n = 3
输出：["((()))","(()())","(())()","()(())","()()()"]
```

+ 题解
  + 一定是先输入左括号，再输入右括号
  + 用left和right分别表示左右括号剩余数量

```cpp
class Solution {
  vector<string> ans;

 public:
  void dfs(int left, int right, string tmp) {
    if (left == 0 && right == 0) {
      ans.push_back(tmp);
      return;
    }
    // 剩余 ‘(’ 的个数比 ‘)’ 要多则，不是配对的()，所以退出
    if (left > right) return;

    // 左括号剩余个数大于0则继续
    // 先选择左括号
    if (left > 0) {
      dfs(left - 1, right, tmp + '(');
    }

    // 右括号剩余个数大于0则继续
    // 在选择右括号
    if (right > 0) {
      dfs(left, right - 1, tmp + ')');
    }
  }
  vector<string> generateParenthesis(int n) {
    dfs(n, n, "");
    return ans;
  }
};
```

### 电话号码的字母组合

+ 力扣17：[电话号码的字母组合](https://leetcode-cn.com/problems/letter-combinations-of-a-phone-number/)

```
给定一个仅包含数字 2-9 的字符串，返回所有它能表示的字母组合。答案可以按 任意顺序 返回。
给出数字到字母的映射如下（与电话按键相同）。注意 1 不对应任何字母。

输入：digits = "23"
输出：["ad","ae","af","bd","be","bf","cd","ce","cf"]

提示：
0 <= digits.length <= 4
digits[i] 是范围 ['2', '9'] 的一个数字。
```

+ 题解
  + 先建立数字对应的所有可能字符
  + 然后遍历每个数字
  + 对数字的所有可能字符都分两种情况：选择和不选择处理

```cpp
class Solution {
  vector<string> ans;

 public:
  void dfs(string& digits, int i, unordered_map<char, string>& mp,
           string& tmp) {
    if (tmp.length() == digits.size()) {
      ans.push_back(tmp);
      return;
    }
    char ch = digits[i];

    // 遍历当前数字所有可能的字符
    for (int idx = 0; idx < mp[ch].length(); idx++) {
      tmp.push_back(mp[ch][idx]);   // 选择当前字符
      dfs(digits, i + 1, mp, tmp);  // 处理下个数字
      tmp.pop_back();               // 不选择当前字符
    }
  }
  vector<string> letterCombinations(string digits) {
    if (digits.length() == 0) return ans;
    // 建立数字对应的所有可能字符
    unordered_map<char, string> mp{{'2', "abc"}, {'3', "def"}, {'4', "ghi"},
                                   {'5', "jkl"}, {'6', "mno"}, {'7', "pqrs"},
                                   {'8', "tuv"}, {'9', "wxyz"}};
    string tmp;
    dfs(digits, 0, mp, tmp);
    return ans;
  }
};
```

### 复原 IP 地址

+ 力扣93：[复原 IP 地址](https://leetcode-cn.com/problems/restore-ip-addresses/)

```
有效 IP 地址 正好由四个整数（每个整数位于 0 到 255 之间组成，且不能含有前导 0），整数之间用 '.' 分隔。
给定一个只包含数字的字符串 s ，用以表示一个 IP 地址，返回所有可能的有效 IP 地址，这些地址可以通过在 s 中插入 '.' 来形成。你不能重新排序或删除 s 中的任何数字。你可以按 任何 顺序返回答案。

输入：s = "25525511135"
输出：["255.255.11.135","255.255.111.35"]

输入：s = "0000"
输出：["0.0.0.0"]
```

+ 题解：
  + 字符串长度不在IP最大长度和最小长度范围【4~12】直接返回false
  + 一个IP段符合范围【0~255】，长度大于1时不能以0开头
  + 一个字符串最多切割成4个IP段
  + 用一个begin表示开始的字符下标，这个IP段的范围为【begin，begin+3】

```cpp
class Solution {
  vector<string> ans;

 public:
  bool isValidIpSegment(string &s, int left, int right) {
    // 起始位0，不符合
    if (right - left + 1 > 1 && s[left] == '0') return false;
    // 截取这个IP段是否符合0~255
    int num = atoi(s.substr(left, right - left + 1).c_str());
    return num >= 0 && num <= 255;
  }

  /*
  s：输入的字符串
  begin：起始切割的位置
  path：保存切割结果
  split：剩余切割次数，一个IP只能切割4次
  */
  void dfs(string &s, int begin, vector<string> &path, int split) {
    if (s.length() == begin) {
      // 已经切割4次，且整个字符串都处理了，才是合格的IP
      if (split == 0) {
        string tmp;
        for (auto elm : path) {
          tmp += elm + '.';
        }
        tmp.pop_back();  // 去掉最后一个.
        ans.push_back(tmp);
      }
      return;
    }
    if (split == 0) return;

    // 计算剩余的字符串长度
    // 剩余字符串长度 小于 剩余切割次数的话，不够切割直接退出
    // 剩余字符串 大于 剩余切割次数*3（每次切割最多用3个字符）的话，那切割次数消耗完还有剩余字符串，不符合直接退出
    int freeLen = s.length() - begin;
    if (freeLen < split || split * 3 < freeLen) return;

    // 从begin开始切割，切割1位，切割2位，切割3位
    for (int i = begin; i < begin + 3; i++) {
      // 如果要切割的位置大于字符串长度直接退出
      if (i >= s.length()) break;

      // begin~i之间的字符，符合ip段（0~255）
      if (isValidIpSegment(s, begin, i)) {
        // 选择这个区间
        path.push_back(s.substr(begin, i - begin + 1));
        dfs(s, i + 1, path, split - 1);
        // 不选这个区间，选下个区间
        path.pop_back();
      }
    }
  }
  vector<string> restoreIpAddresses(string s) {
    // 字符串长度不在IP最大长度和最小长度范围直接返回false
    if (s.length() < 4 || s.length() > 12) return ans;
    vector<string> path;
    // 一个IP只能切割4次
    int split = 4;
    dfs(s, 0, path, split);
    return ans;
  }
};
```

### 分割回文串

+ 力扣131：[分割回文串](https://leetcode-cn.com/problems/palindrome-partitioning/)

```
给你一个字符串 s，请你将 s 分割成一些子串，使每个子串都是 回文串 。返回 s 所有可能的分割方案。
回文串 是正着读和反着读都一样的字符串。

输入：s = "aab"
输出：[["a","a","b"],["aa","b"]]
```

+ 题解
  + 选与不选
  + 如果s[i~idx]是回文字符串，则加入到path（选择）
  + 从i+1开始下个递归（不选择）

```cpp
class Solution {
  vector<vector<string>> ans;

 public:
  vector<vector<string>> partition(string s) {
    vector<string> path;
    dfs(s, 0, path);
    return ans;
  }

  void dfs(string &s, int idx, vector<string> &path) {
    if (idx == s.length()) {
      ans.push_back(path);
      return;
    }
    for (int i = idx; i < s.length(); i++) {
      // 如果s[i~idx]是回文字符串，则加入到path中
      // 从i+1开始下个递归
      if (check(s, idx, i)) {
        path.push_back(s.substr(idx, i - idx + 1));
        dfs(s, i + 1, path);
        path.pop_back();
      }
    }
  }
  bool check(string &s, int left, int right) {
    while (left < right) {
      if (s[left] != s[right]) return false;
      left++;
      right--;
    }
    return true;
  }
};
```

## 岛屿问题

### 岛屿数量

+ 力扣200：[岛屿数量](https://leetcode-cn.com/problems/number-of-islands/)

```
给你一个由 '1'（陆地）和 '0'（水）组成的的二维网格，请你计算网格中岛屿的数量。
岛屿总是被水包围，并且每座岛屿只能由水平方向和/或竖直方向上相邻的陆地连接形成。
此外，你可以假设该网格的四条边均被水包围。

输入：grid = [
  ["1","1","1","1","0"],
  ["1","1","0","1","0"],
  ["1","1","0","0","0"],
  ["0","0","0","0","0"]
]
输出：1
```

+ 题解：
  + 向四个方向都访问，每次访问都将元素设置为0
  + 循环遍历有几个出现1的情况就是有多少个岛屿

```cpp
class Solution {
 public:
  void dfs(vector<vector<char>>& grid, int i, int j) {
    if (i < 0 || i >= grid.size() || j < 0 || j >= grid[0].size() ||
        grid[i][j] == '0')
      return;
    grid[i][j] = '0';
    dfs(grid, i - 1, j);
    dfs(grid, i + 1, j);
    dfs(grid, i, j - 1);
    dfs(grid, i, j + 1);
  }
  int numIslands(vector<vector<char>>& grid) {
    if (grid.size() <= 0) return 0;
    int num = 0;
    for (int i = 0; i < grid.size(); i++) {
      for (int j = 0; j < grid[0].size(); j++) {
        if (grid[i][j] != '0') {
          num++;
          dfs(grid, i, j);
        }
      }
    }
    return num;
  }
};
```

### 岛屿的最大面积

+ 力扣695：[岛屿的最大面积](https://leetcode-cn.com/problems/max-area-of-island/)

```
给你一个大小为 m x n 的二进制矩阵 grid 。
岛屿 是由一些相邻的 1 (代表土地) 构成的组合，这里的「相邻」要求两个 1 必须在 水平或者竖直的四个方向上 相邻。你可以假设 grid 的四个边缘都被 0（代表水）包围着。
岛屿的面积是岛上值为 1 的单元格的数目。
计算并返回 grid 中最大的岛屿面积。如果没有岛屿，则返回面积为 0 。

输入：grid = [
[0,0,1,0,0,0,0,1,0,0,0,0,0],
[0,0,0,0,0,0,0,1,1,1,0,0,0],
[0,1,1,0,1,0,0,0,0,0,0,0,0],
[0,1,0,0,1,1,0,0,1,0,1,0,0],
[0,1,0,0,1,1,0,0,1,1,1,0,0],
[0,0,0,0,0,0,0,0,0,0,1,0,0],
[0,0,0,0,0,0,0,1,1,1,0,0,0],
[0,0,0,0,0,0,0,1,1,0,0,0,0]]
输出：6
解释：答案不应该是 11 ，因为岛屿只能包含水平或垂直这四个方向上的 1 。
```

+ 题解：
  + 解法跟上面一样，只是多了一个参数统计当前岛屿的面积
  + 每遍历一次就比较大小，得出遍历到当前岛屿最大面积

```cpp
class Solution {
  int ans = 0;

 public:
  void dfs(vector<vector<int>>& grid, int i, int j, int& num) {
    if (i < 0 || i >= grid.size() || j < 0 || j >= grid[0].size() ||
        grid[i][j] == 0)
      return;
    grid[i][j] = 0;
    num++;
    dfs(grid, i - 1, j, num);
    dfs(grid, i + 1, j, num);
    dfs(grid, i, j - 1, num);
    dfs(grid, i, j + 1, num);
  }
  int maxAreaOfIsland(vector<vector<int>>& grid) {
    if (grid.size() <= 0) return 0;

    for (int i = 0; i < grid.size(); i++) {
      for (int j = 0; j < grid[0].size(); j++) {
        if (grid[i][j] != 0) {
          int num = 0;
          dfs(grid, i, j, num);
          ans = max(ans, num);
        }
      }
    }
    return ans;
  }
};
```

## 剑指offer

### 剑指 Offer 12. 矩阵中的路径

+ 力扣：[剑指 Offer 12. 矩阵中的路径](https://leetcode-cn.com/problems/ju-zhen-zhong-de-lu-jing-lcof/)

  ```
  给定一个 m x n 二维字符网格 board 和一个字符串单词 word 。如果 word 存在于网格中，返回 true ；否则，返回 false 。
  
  单词必须按照字母顺序，通过相邻的单元格内的字母构成，其中“相邻”单元格是那些水平相邻或垂直相邻的单元格。同一个单元格内的字母不允许被重复使用。
  
  输入：board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCCED"
  输出：true
  
  输入：board = [["a","b"],["c","d"]], word = "abcd"
  输出：false
  ```

+ 题解：（DFS）

  + 上下左右分别遍历

  ```c++
  class Solution {
  
   public:
    bool dfs(vector<vector<char>>& board, string word, int i, int j, int k) {
      if (word.length() == k) return true;
      if (i >= board.size() || i < 0) return false;
      if (j >= board[i].size() || j < 0) return false;
      if (board[i][j] != word[k]) return false;
  
      board[i][j] = '\0';    // 设置访问过
      bool ret = dfs(board, word, i, j + 1, k + 1) ||
                 dfs(board, word, i, j - 1, k + 1) ||
                 dfs(board, word, i + 1, j, k + 1) ||
                 dfs(board, word, i - 1, j, k + 1);
      board[i][j] = word[k];	// 将字符设置回来，给下次遍历使用。
      return ret;
    }
  
    bool exist(vector<vector<char>>& board, string word) {
      if (word.length() == 0) return true;
      int m = board.size();
      if (m == 0) return true;
      int n = board[0].size();
      if (n == 0) return true;
      for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
          if (dfs(board, word, i, j, 0)) return true;
        }
      }
  
      return false;
    }
  };
  ```

  

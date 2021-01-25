# **！！！例子使用的是myemployees.sql的库！！！**
# 基础查询
## 基础查询语法
+ 语法：select 查询列表 from 表名;
+ 特点：
  1. 查询列表可以是：表中字段，常量值，表达式，函数
  2. 查询的结果是一个虚拟的表格
+ 例子：
  1. 查询表中的单个字段：SELECT last_name FROM employees;
  2. 查询多个字段：SELECT last_name, job_id FROM employees;
  3. 查询所有字段：SELECT * FROM employees;
  4. 查询常量值：SELECT 100; SELECT 'km';
  5. 查询表达式：SELECT 100*98;
  6. 查询方法：SELECT version();

## 起别名
+ 语法：
  1. 字段名 AS 别名
  2. 字段名  （空一格） 别名
+ 特点：
  1. 便于理解
  2. 如果要查询的字段有重名的情况，可以使用别名区分开来
  3. 如果别名有特殊符号，则用""引起来
+ 例子：
  + SELECT 100*98 AS 结果;
  + SELECT last_name AS 姓, first_name AS 名 FROM employees;
  + SELECT last_name  姓, first_name  名 FROM employees;
  + SELECT salary AS "out put" FROM employees;

## 去重
+ 语法：DISTINCT 去重字段
+ 特点：过滤掉该字段重复的值
+ 例子：
  + SELECT DISTINCT department_id FROM  employees;

## +号的作用
+ 语法：字段1+字段2
+ 特点：
  1. mysql中+号只有一个功能：运算符
  2. select 100+99; 两个操作数都为数值型，则做加法算数
  3. select "100"+99; 其中一方为字符型，试图将字符型转换为数值型
     1. 如果转换成功，则继续做加法运算
     2. 如果转换失败，则数值型转成0
     3. select null+10; 只要其中一方为null，则结果肯定为null
+ 例子：
  + SELECT last_name+first_name AS 姓名 FROM employees;

## 字符串拼接
+ 语法：CONCAT(str1, str2)
+ 特点：将两个字符串拼接在一起
+ 例子：
  + SELECT CONCAT(last_name, first_name) AS 姓名 FROM employees;

## 判断一个值是否为null
+ IFNUNLL(arg, exp)
+ 特点： 判断一个字段是否为null，如果是则取参数2
+ 例子：
  + SELECT IFNULL(commission_pct,0 ) FROM employees;

+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/tcp/select_server.c)！！！**

# 条件查询
## 条件查询
+ 语法：select 查询列表 from 表名 where 筛选条件
  
+ 执行顺序：
  1. 先去查看表名，释放存在该表
  2. 过滤筛选条件
  3. 查询对应的列表

+ 分类：
  + 条件表达式筛选：条件运算符：> < = != <>(也是不等于) >= <=
  + 按逻辑表达式筛选：逻辑运算符： and or not(&& || !)这一组都相同
  + 模糊查询：
    + like：一般跟通配符一起使用。
        %：包含任意多个字符，包括0个字符
        _：任意单个字符
    + between and
    + in
    + is null

## 按条件表达式筛选
+ 语法：arg op(条件运算符) val
+ 特点：
  + 支持运算符：> < = != <>(也是不等于) >= <=
  + 可以直接使用运算表达式进行筛选
+ 例子：
  + SELECT * FROM employees WHERE salary>12000;
  + SELECT last_name, department_id FROM employees WHERE employee_id!=90; 
  + SELECT last_name, department_id FROM employees WHERE employee_id<>90;

## 逻辑表达式查询
+ **语法：arg op(逻辑运算符) val**
+ 特点：
  + 支持运算符：and or not(&& || !)
  + 直接运算逻辑运算符进行筛选
  + 一般建议使用：and or not（与或非）
+ 例子：
  + SELECT last_name, salary, commission_pct FROM employees WHERE salary>=10000 and salary<=20000;
  + SELECT * FROM employees WHERE NOT(commission_pct>=90 AND commission_pct<=110) OR salary>15000;

## 模糊运算

### LIKE 
+ **语法：进行字符串的模糊匹配。LIKE 'val'**
+ 特点：
  + 可以进行的模糊匹配。可以是字符型或者数值型（整型）
  + 一般跟通配符一起使用。%：包含任意多个字符，包括0个字符。_：任意单个字符
  + 可以给转移符其别名：用关键字ESCAPE
+ 例子：
  + SELECT * FROM employees WHERE last_name LIKE '%a%';
  + SELECT last_name, salary FROM employees WHERE last_name LIKE '__n_l%';
  + SELECT last_name FROM employees WHERE last_name LIKE '_\_%'; #这里\是转移字符
  + SELECT last_name FROM employees WHERE last_name LIKE '_$_%' ESCAPE '$' ; #这里$是转移字符

### BETWEEN AND
+ **语法：判断值是否在该范围。BETWEEN val1 AND val2**
+ 特点：
  + 提高代码整洁度
  + 包含临界值
  + 不能颠倒临界值
  + 等价于>=val and val<=
+ 例子：
  + SELECT * FROM employees WHERE employee_id BETWEEN 100 AND 200

### in
+ **语法：判断某个字段的值是否属于in列表中的某一项。IN(val1,val2,val3...)**
+ 特点：
  + 使用in提高代码整洁度
  + in列表的值类型必须是可以转换的（例如int转字符串，字符串转int）
  + in列表的参数不支持通配符
  + 等价于=val or =val1 or =val2 ...
+ 例子：
  + SELECT last_name, job_id FROM employees WHERE job_id IN ('IT_PROG','AD_VP','AD_PRES');

### is NULL 
+ **语法：判断一个值是否为NLL。val is NULL **
+ 特点：
  + is只能用来判断是否为NULL，不支持其他类型
  + != == <> 不能用于判断NULL值
+ 例子：
  + SELECT last_name, commission_pct FROM employees WHERE commission_pct IS NULL ;
  + SELECT last_name, commission_pct FROM employees WHERE commission_pct IS NOT  NULL ;

### 安全等于<=>
+ **语法：val <=> NULL**
+ 特点：
  + IS NULL 仅仅可以判断NULL值，可读性较高
  + <=> 既可以判断NULL值，又可以判断普通的数值，可读性较低
+ 例子：
  + SELECT last_name, commission_pct FROM employees WHERE commission_pct <=> NULL ;
  + SELECT last_name, salary FROM employees WHERE salary<=>12000;

+ **！！+！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/tcp/select_server.c)！！！**

# 排序查询
+ 语法：SELECT 查询列表 FROM 表【where 筛选条件】ORDER BY 字段 （排序方式asc或者desc）
+ 特点：
  + asc：低到高（默认情况），升序
  + desc：高到低，降序
  + 可以使用别名进行排序
  + order by 子句中可以支持单个字段，多个字段，表达式，函数，别名
  + order by 子句一般是放到查询语句的最后面，limit语句例外
  + 如果有多个字段排序的话，则按照从左到右排序
+ 例子：
  + SELECT * FROM employees ORDER BY salary; #【升序】
  + SELECT * FROM employees ORDER BY salary ASC ; #【升序】
  + SELECT * FROM employees ORDER BY salary DESC  ; #【降序】
  + SELECT * FROM  employees WHERE  department_id >= 90 ORDER BY hiredate ASC ; #【跟条件表达式】
  + SELECT *, salary*12*(1+IFNULL(commission_pct, 0)) AS 年薪 FROM employees ORDER BY salary*12*(1+IFNULL(commission_pct, 0)) DESC ; #【表达式】
  + SELECT *, salary*12*(1+IFNULL(commission_pct, 0)) AS 年薪 FROM employees ORDER BY 年薪 DESC ; #【别名】
  + SELECT LENGTH(last_name) AS 姓名长度 FROM employees ORDER BY LENGTH(last_name); #【按照函数排序】
  + SELECT * FROM employees ORDER BY salary ASC , employee_id DESC ; #【多个字段排序】
  
+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/tcp/select_server.c)！！！**

# 常见函数
+ 语法：函数名（实参列表）
+ 特点：
  + 叫什么（函数名）
  + 干什么（函数功能）
+ 分类：
  + 单行函数：传入一组函数进行操作，返回操作结果：
    1. 字符函数
    2. 数学函数
    3. 日期函数
    4. 其他函数
    5. 流程控制函数
  + 分组函数：传入一组参数统计一个结果返回

## 字符函数
```
LENGTH：获取参数值的字节个数

例子：
SELECT LENGTH('km');
# 一个汉字占3个字节
SELECT LENGTH('张三丰');
```

```
CONCAT 拼接字符串

例子：
SELECT CONCAT(last_name, '_', first_name) AS 姓名 FROM employees;
```

```
upper：转大写
lower：转小写

例子：
SELECT CONCAT(UPPER(last_name), '_',LOWER( first_name)) AS 姓名 FROM employees;
```

```
substr, substring：字符串截断
# 注意：索引都是从1开始

例子：
# 从下标开始截取到末尾
SELECT SUBSTR('李莫愁爱上了陆展元', 7); 
# 从下标开始截取指定字符长度的字符
SELECT SUBSTR('李莫愁爱上了陆展元', 1, 3);
```

```
INSRT : 返回子串第一次出现的索引，如果没有返回0

例子：
SELECT INSTR('杨不悔爱上了殷六侠', '殷六侠');
```

```
TRIM：去掉首位的字符

例子：
SELECT TRIM('  张翠山   ');
SELECT TRIM('a' FROM  'aaaaaa张翠山aaaaaa');
```

```
LPAD 用指定的字符实现左填充指定长度
RPAD 用指定的字符实现右填充指定长度
#注意：最后返回的长度，是以传递的长度为主。

例子：
SELECT LPAD('殷素素', 12, '*');
SELECT LPAD('殷素素', 2, '*'); #殷素
SELECT RPAD('殷素素', 12, '*'); 
SELECT RPAD('殷素素', 2, '*'); #殷素
```

```
REPLACE 替换：替换所有的字符串

例子：
SELECT REPLACE('张无忌爱上了周芷若','周芷若','赵敏');
SELECT REPLACE('周芷若张无忌爱上了周芷若','周芷若','赵敏');
```

## 数学函数
```
round：四舍五入
# 第二个参数：支持小数点几位

例子：
SELECT ROUND(1.22); # 1
SELECT ROUND(1.5); # 2
SELECT ROUND(-1.22); # -1
SELECT ROUND(-1.5); # -2
SELECT ROUND(1.567, 2); #1.57
SELECT ROUND(1, 2); # 1
```

```
ceil 向上取整 返回>=该参数的最小值

例子：
SELECT CEIL(1.00); # 1
SELECT CEIL(1.01); # 2
SELECT CEIL(-1.01); # -1
```

```
floor 向下取整，返回<=该参数的最大整数

例子：
SELECT FLOOR(-9.99); # -10
SELECT FLOOR(1.01); # 1
```

```
TRUNCATE ：截断小数点N位

例子：
SELECT TRUNCATE(1.666666, 1);
```

```
mod取余
# 公式：MOD(a,b) => a - a/b *b
# 举例：mod(-10, -3) => -10 - (-10)/(-3) * (-3) = -1

例子：
SELECT MOD(-10, -3); # -1
```

## 日期函数
+ 日期格式化参数含义：![参数含义](G:\knowledge\网络\images\domain原理.png)
```
NOW 返回当前系统日期+时间
SELECT NOW();

CURDATE 返回当前系统日志，不包含时间
SELECT CURDATE();

CURTIME 返回当前时间，不包含日期
SELECT CURTIME();

可以获取指定部分，年，月，日，小时，分钟，秒
SELECT YEAR(NOW());
SELECT YEAR('1996-01-02');
SELECT MONTH(now());
SELECT MONTHNAME(NOW()); # 英文月名
...(小时，分钟类似)
```

```
STR_TO_DATE：将日期格式的字符转换成指定格式的日期

例子：
SELECT  STR_TO_DATE('1996-01-02', '%Y-%c-%d');
SELECT * FROM employees WHERE hiredate = STR_TO_DATE('4-3 1992', '%c-%d %Y');
```

```
DATE_FORMAT：将日期转换成字符

例子：
SELECT DATE_FORMAT(NOW(),'%y年%m月%d日');
SELECT last_name ,DATE_FORMAT(hiredate, '%m月/%d日/%Y年') FROM employees;
```

## 流出控制函数
```
if函数：if else效果

例子：
SELECT IF(10<5, '大', '小');
```

```
# CASE 函数
一：switch case 的效果
    case 要判断的字段或者表达式
    when 常量1 then 要显示的值1或者语句1;
    when 常量2 then 要显示的值2或者语句2;
    ...
    else 要显示的值N或者语句N;
    end
例子：
SELECT department_id, salary AS 原始工资, 
CASE department_id
WHEN 30 THEN salary*1.1
WHEN 40 THEN salary*1.2
WHEN 50 THEN salary*1.3
WHEN 60 THEN salary*1.4
ELSE salary
END AS 新工资
FROM employees;

二：类似于多重IF
    case
    when 条件1 then 要显示的值1或者语句1;
    when 条件2 then 要显示的值1或者语句2;
    when 条件3 then 要显示的值1或者语句3;
    else 要显示的值N或者语句N;
    end
例子：
SELECT salary , 
CASE 
WHEN salary > 20000 THEN 'A'
WHEN salary > 15000 THEN 'B'
WHEN salary > 10000 THEN 'C'
ELSE 'D'
END AS 工资级别
FROM employees;
```

# 分组函数
# 分组查询 
+ 语法：select 分组函数，列（要求出现在group by的后面）from 表【where 筛选条件】
  group by 分组的列表【order by 子句】

+ 注意：查询列表比较特殊：要求是分组函数和group by后出现的字段

+ 特点：
    1. 分组查询中的筛选条件分为两类：分组前筛选和分组后筛选

    | 分类       | 数据源       | 位置            | 关键字 |
    | ---------- | ------------ | --------------- | ------ |
    | 分组前筛选 | 原始表       | group by 语句前 | where  |
    | 分组后筛选 | 分组后的结果 | group by 语句后 | having |

    2. 分组函数做条件肯定是放在having子句中
    3. GROUP BY 子句支持单个字段分组，多个字段分组。（多个字段分组之间用，逗号隔开，没有先后顺序要求）
    4. 表达式或者函数用的比较少
    5. 也可以添加排序（排序放在整个分组查询的最后）

## 简单的分组查询
```
# 查询每个工种的最高工资
SELECT MAX(salary) FROM employees GROUP BY job_id;

# 查询每个位置上的部门个数
SELECT COUNT(*), location_id FROM departments GROUP BY location_id;
```

## 添加分组前的筛选条件
```
# 查询邮箱中包含a字符的，每个部门的平均工资
SELECT AVG(salary) FROM employees WHERE email LIKE '%a%' GROUP BY department_id;

# 查询有奖金的每个领导手下员工的最高工资
SELECT MAX(salary) FROM employees WHERE commission_pct is NOT NULL GROUP BY manager_id;
```

## 添加分组后的筛选条件
```
# 查看哪个部门的员工个数>2
# 步骤：1，2
# 1：查询每个部门的员工个数
SELECT COUNT(*), department_id FROM employees GROUP BY department_id;
# 2: 根据1的结果进行筛选，查询哪个部门员工个数>2。
SELECT COUNT(*), department_id FROM employees GROUP BY department_id HAVING COUNT(*) >2;

# 查询每个工种有奖金的员工的最高工资>12000的工种编号和最高工资
# 步骤1，2
# 1：查询每个工种的编号和最高工资
SELECT job_id, MAX(salary) FROM employees WHERE commission_pct is NOT  NULL  GROUP BY department_id;
# 2：根据1的结果筛选最高工资>12000
SELECT job_id, MAX(salary) FROM employees WHERE commission_pct is NOT  NULL  GROUP BY department_id HAVING MAX(salary)>12000;

# 查询领导编号>102的每个领导手下最低工资>5000的领导编号是哪个，以及最低工资
# 步骤1，2
# 1：查询领导编号>102的领导及手下最低工资
SELECT manager_id, MIN(salary) FROM employees WHERE manager_id>102 GROUP BY  manager_id;
# 2：根据1的结果查询最低工资>5000
SELECT manager_id, MIN(salary) FROM employees WHERE manager_id>102 GROUP BY  manager_id HAVING MIN(salary) > 5000;
```

## 按表达式或者函数分组
```
# 按照员工姓名长度，查询每一组的员工个数，筛选员工个数>5有哪些
SELECT COUNT(*), LENGTH(last_name)  FROM employees GROUP BY LENGTH(last_name) HAVING COUNT(*)>5;
# 支持别名分组
SELECT COUNT(*) AS c, LENGTH(last_name) AS l FROM employees GROUP BY l HAVING c>5;
```

## 按照多个字段分组。
```
多个字段为一组，只要组里面有的字段值不一样则认为该组不一样。跟字段的前后无关
# 查询每个部门每个工种的员工的平均工资
SELECT AVG(salary),department_id, job_id FROM employees GROUP BY  department_id, job_id;
```

## 按照排序
```
# 查询每个部门每个工种的员工的平均工资，并且按照平均工资的高低显示
SELECT AVG(salary),department_id, job_id FROM employees GROUP BY  department_id, job_id ORDER BY AVG(salary) DESC ;
SELECT AVG(salary),department_id, job_id FROM employees WHERE department_id is NOT NULL  GROUP BY  department_id, job_id ORDER BY AVG(salary) DESC ;
```
# 连接查询
# 子查询
# 分页查询
# union联合查询
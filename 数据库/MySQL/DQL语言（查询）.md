# 语法

|          语法          | 执行顺序 |
| :--------------------: | :------: |
|    select 查询列表     |    7     |
|     from 表1 别名      |    1     |
| 连接类型 join 表2 别名 |    2     |
|      on 连接条件       |    3     |
|     where 筛选条件     |    4     |
|   group by 分组字段    |    5     |
|  having 分组后的筛选   |    6     |
|   order by 排序字段    |    8     |
|   limit offset, size   |    9     |




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

+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DQL%EF%BC%88%E5%9F%BA%E7%A1%80%EF%BC%89.sql)！！！**


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

+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DQL%EF%BC%88%E6%9D%A1%E4%BB%B6%EF%BC%89.sql)！！！**

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
  
+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DQL%EF%BC%88%E6%8E%92%E5%BA%8F%EF%BC%89.sql)！！！**

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
+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DQL%EF%BC%88%E5%B8%B8%E8%A7%81%E5%87%BD%E6%95%B0%EF%BC%89.sql)！！！**
  
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
+ 日期格式化参数含义：![参数含义]([G:\knowledge\网络\images\domain原理.png](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E6%97%A5%E6%9C%9F%E6%A0%BC%E5%BC%8F%E7%AC%A6.png))
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

```
DATEDIFF: 返回两个日期相差的天数
```

## 其他函数
```
VERSION: 当前数据库服务器的版本
DATABASE： 当前打开的数据库
USER：当前用户
PASSWORD('字符串')：返回该字符的密码形式
MD5('字符串')：返回该字符的md5加密形式
```

## 流出控制函数
```
if函数：if else效果
IF(条件表达式，表达式1，表达式2)：如果条件成功，返回表达式1，否则返回表达式2
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
+ 功能：用作统计使用呢，又称为聚合函数或者统计函数或者组函数
+ 分类：
  + sum 求和
  + avg 平均值
  + max 最大值
  + min 最小值
  + count 统计个数
+ 特点：
  1. SUM，AVG一般用于处理数值型，MAX，MIN，COUNT可以处理任何类型
  2. 以上分组函数都忽略NULL值
  3. 可以和DISTINCT搭配使用，实现去重计算
  4. 一般用COUNT(*)统计行数 
  5. 和分组函数一同查询的字段要求是group by后的字段
+ + **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DQL%EF%BC%88%E5%88%86%E7%BB%84%E5%87%BD%E6%95%B0%EF%BC%89.sql)！！！**

## 简单使用
```
SELECT SUM(salary) FROM employees;
SELECT AVG(salary) FROM employees;
SELECT MAX(salary) FROM employees;
SELECT MIN(salary) FROM employees;
SELECT COUNT(salary) FROM employees;

SELECT  SUM(salary) 和, AVG(salary) 平均值 FROM employees;
SELECT  SUM(salary) 和, ROUND(AVG(salary), 2) 平均值 FROM employees;
```

## 参数支持哪些类型
```
# 虽然不报错，但是没有实际意义了
# SUM和AVG只对数值型有实际意义
SELECT  SUM(last_name) 和, AVG(last_name) 平均值 FROM employees;
SELECT  SUM(hiredate) 和, AVG(hiredate) 平均值 FROM employees;

# 支持数值型，字符串，和日期
SELECT MAX(last_name), MIN(last_name) FROM employees;
SELECT  MAX(hiredate) 和, MIN(hiredate) 平均值 FROM employees;
```

## 是否忽略NULL
```
# SUM和AVG都忽略NULL
SELECT  SUM(commission_pct) 和, AVG(commission_pct) 平均值 FROM employees;

# COUNT只计算不为NULL的个数
SELECT COUNT(commission_pct) FROM employees;
SELECT COUNT(*) FROM employees;
```

## 和DISTINCT搭配
```
SELECT  SUM(DISTINCT salary) 去重和, SUM(salary) 和 FROM employees;
SELECT COUNT(DISTINCT salary), COUNT(salary) FROM employees;
```

## COUNT函数的详细介绍
```
# 统计表中个数
SELECT COUNT(*) FROM employees;
# 生产一列1，实现统计表中个数
SELECT COUNT(1) FROM employees;

# 效率：
# MYISAM存储引擎下，COUNT(*)的效率高
# INNODB存储引擎下，COUNT(*)的效率和COUNT(1)差不多，但是比COUNT(字段)要高
```

## 和分组函数一同查询的字段有限制
```
# 分组函数查询到的是一个数字，但是查询字段确实有多个数字。这样查询没有意义
SELECT AVG(salary), employee_id FROM employees;
```

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

+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DQL%EF%BC%88%E5%88%86%E7%BB%84%E6%9F%A5%E8%AF%A2%EF%BC%89.sql)！！！**
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
+ 含义：又称多表查询，当查询的字段来自多于多个表时，就会用到连接查询
+ 笛卡尔乘积现象：表1有m行，表2有n行，结果m*n行
  + 发生原因：没有有效的连接条件
  + 如何避免：添加有效的连接条件
+ 分类：
  > 按照年份分类：
  > + sql92标准：仅支持内连接
  > + sql99标准（推荐）：支持内连接，外连接（左外，右外），交叉连接

  > 按照功能分类：
  > + 内连接：  
  >   + 等值连接
  >   + 非等值连接
  > + 外连接
  >   + 自连接
  >   + 左外连接
  >   + 右外连接
  >   + 全外连接
  > + 交叉连接
+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DQL%EF%BC%88%E8%BF%9E%E6%8E%A5%E6%9F%A5%E8%AF%A2%EF%BC%89.sql)！！！**

## sql92标准
### 等值连接
+ 语法：
    select 查询列表
    from 表1 别名1，表2 别名2。。。
    where 别名1.key = 别名2.key 【and 筛选条件】
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】
+ 特点：
  1. 多表等值连接的结果为多表的交集部分
  2. n表连接，至少需要n-1个连接条件
  3. 多表的顺序没有要求
  4. 一般需要为表起别名
  5. 可以搭配所有子句使用：排序，分组
  
+ 为表起别名：
  1. 提高代码的简洁度
  2. 区分多个重名的字段
  3. 注意：如果为表起了别名，则查询的字段就不能使用原来的表名，要使用别名
#### 简单查询
```
# 查询女神名和对应的男神名
SELECT name, boyName FROM beauty, boys WHERE beauty.boyfriend_id = boys.id;

# 1. 查询员工名和对应的部门名
SELECT last_name , department_name FROM employees, departments WHERE employees.department_id = departments.department_id;

# 2. 查询员工名，工种号，工种名
SELECT last_name, j.job_id, j.job_title  FROM employees as e , jobs as j WHERE e.job_id = j.job_id;
```

#### 两个表的顺序可以调换
```
SELECT last_name, j.job_id, j.job_title  FROM jobs as j, employees as e WHERE e.job_id = j.job_id;
```

#### 加筛选条件
```
# 查询有奖金的员工们和部门名
SELECT last_name, department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id AND e.commission_pct is NOT NULL ;

# 查询城市名中第二个字符为o的部门和城市名
SELECT department_name, city
FROM departments d, locations l
WHERE d.location_id = l.location_id AND l.city LIKE "_o%";
```

#### 分组
```
# 查询每个城市的部门个数
SELECT COUNT(*), city
FROM departments d, locations l
WHERE d.location_id = l.location_id
GROUP BY city;

# 查询有奖金的每个部门的部门名和部门的领导编号和该部门的最低工资
SELECT department_name, d.manager_id, MIN(salary)
FROM departments d, employees e
WHERE d.department_id = e.department_id AND e.commission_pct is NOT NULL 
GROUP BY d.department_id;
```

#### 排序
```
# 查询每个工种的工种名和员工的个数，并且按员工个数降序
SELECT job_title, COUNT(*)
FROM  employees, jobs
WHERE employees.job_id = jobs.job_id
GROUP BY jobs.job_id
ORDER BY COUNT(*) DESC ;
```

#### 多表连接
```
# 查询员工名，部门名和所在的城市
SELECT last_name, department_name, city
FROM employees e, departments d, locations l
WHERE e.department_id = d.department_id AND d.location_id = l.location_id;
```

### 非等值连接
+ 语法：
    select 查询列表
    from 表1 别名1，表2 别名2。。。
    where 非等值连接条件（不一定是！=号）
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】

#### 例子
```
# 查询员工的工资和工资级别
SELECT salary , grade_level
FROM employees, job_grades
WHERE salary BETWEEN lowest_sal AND highest_sal;
```

### 自连接
+ 语法：
    select 查询列表
    from 表 别名1，表 别名2。。。（都是同个表）
    where 等值连接条件
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】

#### 例子
```
# 查询员工名和上级名
SELECT e.employee_id, e.last_name,  m.employee_id,  m.last_name
FROM employees e, employees m
WHERE e.manager_id = m.employee_id AND e.manager_id is NOT NULL ;
```

## sql99标准
+ 语法：<br>
    select 查询列表           <br>
    from 表1 别名             <br>
    连接类型 join 表2 别名    <br>
    on 连接条件               <br>
    【where 筛选条件】        <br>
    【group by 分组字段】     <br>
    【having 分组后的筛选】   <br>
    【order by 排序字段】     <br>

+ 内连接：inner：交集
+ 外连接
  + 左外：left 【outer】    左表全集
  + 右外：right 【outer】   右边全集
  + 全外：full 【outer】    并集
+ 交叉连接：cross

### 内连接
+ 语法：                        <br>
    select 查询列表             <br>
    from 表1 别名               <br>
    inner join 表2 别名         <br>
    on 连接条件                 <br>
    【where 筛选条件】          <br>
    【group by 分组字段】       <br>
    【having 分组后的筛选】     <br>
    【order by 排序字段】       <br>

+ 分类：
  + 等值（有字段值相等）
  + 非等值（有字段值不相等）
  + 自连接

+ 特点：
  1. 添加排序，分组，筛选，多表
  2. inner可以省略
  3. 筛选条件放在where后面，连接条件放在on后面，便于阅读
  4. inner join连接和sql92语法中的等值连接效果一样，都是查询多表的交集

#### 等值连接
##### 简单查询。多表顺序可以调换
```
# 查询员工名，部门名
SELECT last_name, d.department_id
FROM employees e
INNER JOIN departments d
on e.department_id = d.department_id;
```

##### 加筛选条件
```
# 查询名字中包含e的员工名和工种名
SELECT e.last_name, j.job_title
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
WHERE e.last_name LIKE '%e%';
```

##### 添加分组
```
# 查询部门个数>3的城市名和部门个数
# 1. 查询每个城市的部门个数
# 2. 在1结果上筛选满足条件
SELECT city, COUNT(*)
FROM departments d
INNER JOIN locations l
ON d.location_id = l.location_id
GROUP BY city
HAVING COUNT(*) > 3;
```

##### 添加排序
```
# 查询哪个部门的员工个数>3，对应的部门名和员工个数，并按照个数降序
SELECT d.department_name, COUNT(*) 员工个数
FROM departments d
INNER JOIN employees e
ON d.department_id = e.department_id
GROUP BY d.department_id
HAVING COUNT(*) > 3
ORDER BY COUNT(*) DESC ;
```

##### 多表连接
```
# 查询员工名，部门名，工种名，并按照部门名排序
SELECT e.last_name, d.department_name, j.job_title
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN jobs j ON e.job_id = j.job_id
ORDER BY d.department_name DESC ;
```

#### 非等值连接
##### 简单查询
```
# 查询员工的工资级别
SELECT e.last_name, e.salary, j.grade_level
FROM employees e
INNER JOIN job_grades j
ON e.salary BETWEEN j.lowest_sal AND J.highest_sal;
```

##### 分组，筛选条件，排序
```
# 查询工资级别个数>20的个数，并且按照工资级别降序
SELECT j.grade_level, COUNT(*) 个数
FROM employees e
INNER JOIN job_grades j
ON e.salary BETWEEN j.lowest_sal AND J.highest_sal
GROUP BY j.grade_level
HAVING COUNT(*) > 20
ORDER BY j.grade_level DESC ;
```

#### 自连接
```
# 查询员工的名字，上级的名字
SELECT e.last_name, m.last_name
FROM employees e
INNER JOIN employees m
ON e.manager_id = m.employee_id;
```

### 外连接
+ 语法：                        <br>
    select 查询列表             <br>
    from 表1 别名               <br>
    left/right/full join 表2 别名         <br>
    on 连接条件                 <br>
    【where 筛选条件】          <br>
    【group by 分组字段】       <br>
    【having 分组后的筛选】     <br>
    【order by 排序字段】       <br>
+ 分类：
  + 左外连接
  + 右外连接
  + 全外连接
+ 特点：
  1. 外连接的查询结果为主表中的所有记录
  2. 如果从表中有和它匹配的，则显示匹配的值
  3. 如果从表中没有和它匹配的，则显示NULL
  4. 外连接的查询结果 = 内连接结果 + 主表中有而从表没有的记录
  5. 左外连接，left join左边的是主表
  6. 右外连接，right join右边的是主表
  7. 左外和右外交换两表的顺序，可以实现同样的效果
  8. 全外连接 = 内连接的结果 + 表1中有但是表2没有 + 表2中有但是表1没有
+ 应用场景：用于查询一个表中有，另外一个表没有的记录

#### 左外连接
```
# 查询没有男朋友的女神名
SELECT *
FROM beauty b
LEFT JOIN boys bo
ON b.boyfriend_id = bo.id
WHERE bo.id IS NULL;

# 查询哪个部门没有员工
SELECT d.*, e.employee_id
FROM departments d
LEFT JOIN employees e
ON d.department_id = e.department_id
WHERE e.employee_id IS NULL ;
```

#### 右外连接
```
# 查询没有男朋友的女神名
SELECT *
FROM boys bo
RIGHT JOIN beauty b
ON b.boyfriend_id = bo.id
WHERE bo.id IS NULL;
```

#### 全外

```
# MySQL不支持
SELECT *
FROM beauty b
FULL JOIN boys bo
ON b.boyfriend_id = bo.id;

# 可以用这个做到
SELECT * FROM beauty b LEFT JOIN boys bo ON b.boyfriend_id = bo.id
UNION
SELECT * FROM beauty b RIGHT JOIN boys bo ON b.boyfriend_id = bo.id

# 全外去掉共有部分
SELECT * FROM beauty b LEFT JOIN boys bo ON b.boyfriend_id = bo.id where b.id is NULL
UNION
SELECT * FROM beauty b RIGHT JOIN boys bo ON b.boyfriend_id = bo.id where bo.id is NULL
```

### 交叉连接：笛卡尔乘积 = 表1的行数*表2的行数

```
 SELECT *
 FROM beauty bo
 cross JOIN boys b
```
## 图解
> 内连接：![内连接](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%86%85%E8%BF%9E%E6%8E%A5.png)

> 左外连接：![左外连接](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%B7%A6%E5%A4%96%E8%BF%9E%E6%8E%A5.png)

> 左外加筛选：![左外加筛选](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%B7%A6%E5%A4%96%E5%8A%A0%E7%AD%9B%E9%80%89.png)

> 右外连接：![右外连接](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%8F%B3%E5%A4%96%E8%BF%9E%E6%8E%A5.png)

> 右外加筛选：![右外加筛选](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%8F%B3%E5%A4%96%E5%8A%A0%E7%AD%9B%E9%80%89.png)

> 全外连接：![全外连接](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%85%A8%E5%A4%96%E8%BF%9E%E6%8E%A5.png)

> 全外加筛选：![全外加筛选](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%85%A8%E5%A4%96%E5%8A%A0%E7%AD%9B%E9%80%89.png)


# 子查询
+ 含义：出现在其他语句（增删改查）中的select语句，称为子查询和内查询。外部的查询语句，称为主查询或者外查询
+ **子查询的执行优先于主查询执行，主查询的条件用到了子查询的结果**
+ 分类：
  + 按照子查询出现的位置：
    + select后面：仅仅支持标量子查询
    + from后面：支持表子查询
    + where或者having后面：支持标量子查询，行子查询，列子查询
    + exists后面：支持表子查询

  + 按照结果集的行列数不同
    + 标量子查询（结果集只有一行一列）
    + 列子查询（结果集只有多行一列）
    + 行子查询（结果集只有一行多列）
    + 表子查询（结果集一般为多行多列）

## where或having后面
1. 标量子查询（单行子查询）
2. 列子查询（多行子查询）
3. 行子查询（多列多行，用的较少）

+ 特点：
    1. 子查询放在小括号内
    2. 子查询一般放在条件的右侧
    3. 标量子查询，一般搭配单行操作符使用
        \> < >= <= = !=
    4. 列子查询，一般搭配多行操作使用
        IN ANY/SOME ALL 

### 标量子查询：
+ \> < >= <= = !=
```
# 谁的工资比Abel高
SELECT last_name, salary
FROM employees
WHERE salary > (
    SELECT salary
    FROM employees
    WHERE last_name = "Abel"
);

# 查询job_id与141号员工相同，salary比143号员工多的员工，姓名，job_id和工资
SELECT last_name, job_id, salary
FROM employees
WHERE salary > (
    SELECT salary
    FROM employees
    WHERE employee_id = 143
) AND job_id = (
    SELECT job_id
    FROM employees
    WHERE employee_id = 141
)

# 查询公司工资最少的员工的last_name，job_id和salary
SELECT last_name, job_id, salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
)

# 查询最低工资大于50号部门最低工资的部门id和其最低工资
SELECT department_id, MIN(salary)
FROM employees
GROUP BY department_id
HAVING MIN(salary) > (
    SELECT MIN(salary)
    FROM employees
    WHERE department_id = 50
)
ORDER BY MIN(salary)
```

### 列子查询（多行子查询）
+ IN ANY/SOME ALL 
```
# 查询location_id是1400或者1700的部门中的所有员工姓名
SELECT DISTINCT department_id
FROM departments
WHERE departments.location_id IN(1400,1700)

SELECT last_name
FROM employees
WHERE department_id IN(
    SELECT DISTINCT department_id
    FROM departments
    WHERE departments.location_id IN(1400,1700) 
)

# 查询其他部门比job_id为‘IT_PROG’部门任一工资低的员工的员工号，姓名，job_id以及salary
SELECT salary
FROM employees
WHERE job_id = 'IT_PROG'

SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary < ANY (
    SELECT salary
    FROM employees
    WHERE job_id = 'IT_PROG'
) AND job_id != 'IT_PROG';

# 或者
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary <  (
    SELECT MAX(salary)
    FROM employees
    WHERE job_id = 'IT_PROG'
) AND job_id != 'IT_PROG';

# 查询其他部门比job_id为‘IT_PROG’部门所有工资低的员工的员工号，姓名，job_id以及salary
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary < ALL (
    SELECT salary
    FROM employees
    WHERE job_id = 'IT_PROG'
) AND job_id != 'IT_PROG';

# 或者
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary <  (
    SELECT MIN(salary)
    FROM employees
    WHERE job_id = 'IT_PROG'
) AND job_id != 'IT_PROG';
```

### 行子查询（多列子查询）
+ IN ANY/SOME ALL 
```
# 查询员工编号最小且工资最高的员工信息
SELECT MIN(employee_id)
FROM employees;
 
 SELECT MAX(salary)
 FROM employees;

SELECT *
FROM employees
WHERE (employee_id, salary) = (
    SELECT MIN(employee_id), MAX(salary)
    FROM employees
);

# 或者
 SELECT *
 FROM employees
 WHERE employee_id = (
    SELECT MIN(employee_id)
    FROM employees
 ) AND salary = (
     SELECT MAX(salary)
    FROM employees
 );
```

 ## select后面
 + 可以用其他的语法实现。仅仅支持标量子查询
 ```
 # 查询每个部门的员工个数
 SELECT *, (
     SELECT COUNT(*)
     FROM employees
     WHERE employees.department_id = departments.department_id
 ) 个数
 FROM departments ;
 ```

## from后面
+ 将子查询结果充当一张表，要求必须起别名
```
# 查询每个部门的平均工资的工资等级
SELECT AVG(salary)
FROM employees
GROUP BY employees.department_id;

SELECT ag.ag_salary, jb.grade_level, department_id
FROM job_grades jb
INNER JOIN (
    SELECT AVG(salary) ag_salary, employees.department_id
    FROM employees
    GROUP BY employees.department_id
) ag ON ag.ag_salary BETWEEN jb.lowest_sal AND jb.highest_sal
```

## exists后面（相关子查询）
+ 语法： exists（完整的查询语句）
+ 结果：0或者1
```
SELECT EXISTS( 
    SELECT employee_id FROM employees  
);
SELECT EXISTS( 
    SELECT employee_id FROM employees WHERE salary=3000000  
);

# 查询有员工的部门名
SELECT department_name
FROM departments d
WHERE EXISTS(
    SELECT * 
    FROM employees e
    WHERE d.department_id = e.department_id
);

SELECT department_name
FROM departments d
WHERE d.department_id IN (
    SELECT e.department_id
    FROM employees e
    WHERE d.department_id = e.department_id
);

# 查询没有女朋友的男神信息
SELECT boys.*
FROM boys 
WHERE boys.id NOT IN(
    SELECT beauty.boyfriend_id
    FROM beauty
);

SELECT boys.*
FROM boys 
WHERE  NOT EXISTS (
    SELECT beauty.boyfriend_id
    FROM beauty
    WHERE boys.id = beauty.boyfriend_id
);
```

# 分页查询
+ 应用场景：当腰显示的数据，一页显示不全，需要分页提交sql请求
+ 语法：<br>
    select 查询列表                         <br>
    from 表1 别名                           <br>   
    【连接类型 join 表2 别名                 <br>   
    on 连接条件                             <br>
    where 筛选条件                          <br>
    group by 分组字段                       <br>
    having 分组后的筛选                     <br>
    order by 排序字段】                     <br>
    limit offset, size;                    <br>

+ offest：要显示条目的起始索引（起始索引从0开始）
+ size：要显示的条目个数

+ 特点：
    1. limit语句放在查询语句的最后
    2. **要显示的页数page，每页的条目数size，offset = (page-1) * size**

## 例子
```
# 查询前5条员工信息
SELECT * FROM employees LIMIT 0, 5;

# 查询第11-25条
SELECT * FROM employees LIMIT 10,15;

# 查询有奖金的员工信息，并且工资较高的前10名
SELECT *
FROM employees
WHERE commission_pct IS NOT NULL 
ORDER BY salary DESC 
LIMIT 0, 10;
```

# union联合查询
+ union 联合：将多条查询语句的结果合并成一个结果
  
+ 语法：<br>
  查询语句1 <br>
  UNION <br>
  查询语句2 <br>
  UNION <br>
  ... <br>
  查询语句n <br>

+ **应用场景：要查询的结果来自多个表，且多个表可以没有直接的连接关系，但是查询的信息要一致**

+ 特点：
    1. ****要求多条查询语句的列数个数要一致**
    2. **要求多条查询语句的每一列的类型和顺序最好是一致的**
    3. **unioin关键字默认区中，如果要使用union all可以包含重复项**
    4. **每个表可以没有直接关系**

## 例子
```
# 查询部门编号>90或者邮箱包含a的员工信息
SELECT * FROM employees WHERE department_id > 90 OR  email LIKE '%a%';

SELECT * FROM employees WHERE department_id > 90
UNION 
SELECT * FROM employees WHERE  email LIKE '%a%';
```
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

**！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/tcp/select_server.c)！！！**

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

**！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/tcp/select_server.c)！！！**

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
**！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/tcp/select_server.c)！！！**

# 常见函数
# 分组函数
# 分组查询
# 连接查询
# 子查询
# 分页查询
# union联合查询
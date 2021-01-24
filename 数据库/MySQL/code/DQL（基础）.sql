# ！！！例子使用的是myemployees.sql的库！！！
# 基础查询
/*
语法：select 查询列表 from 表名;

特点：
1. 查询列表可以是：表中字段，常量值，表达式，函数
2. 查询的结果是一个虚拟的表格
*/

#1. 查询表中的单个字段
SELECT last_name FROM employees;

#2. 查询多个字段
SELECT last_name, job_id FROM employees;

# 查询所有字段
SELECT * FROM employees;

# 查询常量值
SELECT 100;
SELECT 'km';

# 查询表达式：
SELECT 100*98;

# 查询方法：
SELECT version();

# 起别名
/*
语法：
1. 字段名 AS 别名
2. 字段名  （空一格） 别名

特点：
1. 便于理解
2. 如果要查询的字段有重名的情况，可以使用别名区分开来
3. 如果别名有特殊符号，则用""引起来
*/

SELECT 100*98 AS 结果;
SELECT last_name AS 姓, first_name AS 名 FROM employees;
SELECT last_name  姓, first_name  名 FROM employees;
#SELECT salary AS "out put" FROM employees;

# 去重
SELECT DISTINCT department_id FROM  employees;

# +号的作用
/*
mysql中+号只有一个功能：运算符
1. select 100+99; 两个操作数都为数值型，则做加法算数
2. select "100"+99; 其中一方为字符型，试图将字符型转换为数值型
    如果转换成功，则继续做加法运算
    如果转换失败，则数值型转成0
3. select null+10; 只要其中一方为null，则结果肯定为null
*/
SELECT last_name+first_name AS 姓名 FROM employees;
SELECT CONCAT(last_name, first_name) AS 姓名 FROM employees;
SELECT CONCAT()

# IFNUNLL 判断一个字段是否为null，如果是则取参数2
SELECT IFNULL(commission_pct,0 ) FROM employees;
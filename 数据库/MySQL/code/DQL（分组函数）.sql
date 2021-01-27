# ！！！例子使用的是myemployees.sql的库！！！
# 分组函数
/*
功能：用作统计使用呢，又称为聚合函数或者统计函数或者组函数

分类：
sum 求和
avg 平均值
max 最大值
min 最小值
count 统计个数

特点：
1. SUM，AVG一般用于处理数值型
    MAX，MIN，COUNT可以处理任何类型
2. 以上分组函数都忽略NULL值
3. 可以和DISTINCT搭配使用，实现去重计算
4. 一般用COUNT(*)统计行数 
5. 和分组函数一同查询的字段要求是group by后的字段
*/


# 1. 简单使用
SELECT SUM(salary) FROM employees;
SELECT AVG(salary) FROM employees;
SELECT MAX(salary) FROM employees;
SELECT MIN(salary) FROM employees;
SELECT COUNT(salary) FROM employees;

SELECT  SUM(salary) 和, AVG(salary) 平均值 FROM employees;
SELECT  SUM(salary) 和, ROUND(AVG(salary), 2) 平均值 FROM employees;


# 2. 参数支持哪些类型
# 虽然不报错，但是没有实际意义了
# SUM和AVG只对数值型有实际意义
SELECT  SUM(last_name) 和, AVG(last_name) 平均值 FROM employees;
SELECT  SUM(hiredate) 和, AVG(hiredate) 平均值 FROM employees;

# 支持数值型，字符串，和日期
SELECT MAX(last_name), MIN(last_name) FROM employees;
SELECT  MAX(hiredate) 和, MIN(hiredate) 平均值 FROM employees;


# 3. 是否忽略NULL
# SUM和AVG都忽略NULL
SELECT  SUM(commission_pct) 和, AVG(commission_pct) 平均值 FROM employees;

# COUNT只计算不为NULL的个数
SELECT COUNT(commission_pct) FROM employees;
SELECT COUNT(*) FROM employees;

# 4. 和DISTINCT搭配
SELECT  SUM(DISTINCT salary) 去重和, SUM(salary) 和 FROM employees;
SELECT COUNT(DISTINCT salary), COUNT(salary) FROM employees;

# 5. COUNT函数的详细介绍
# 统计表中个数
SELECT COUNT(*) FROM employees;
# 生产一列1，实现统计表中个数
SELECT COUNT(1) FROM employees;

# 效率：
# MYISAM存储引擎下，COUNT(*)的效率高
# INNODB存储引擎下，COUNT(*)的效率和COUNT(1)差不多，但是比COUNT(字段)要高

# 6 和分组函数一同查询的字段有限制
# 分组函数查询到的是一个数字，但是查询字段确实有多个数字。这样查询没有意义
SELECT AVG(salary), employee_id FROM employees;
# ！！！例子使用的是myemployees.sql的库！！！
# ！！！例子使用的是girls.sql的库！！！

# 联合查询
/*
union 联合：将多条查询语句的结果合并成一个结果

语法：
查询语句1
UNION
查询语句2
UNION
...
查询语句n

应用场景：要查询的结果来自多个表，且多个表可以没有直接的连接关系，但是查询的信息要一致

特点：
    1. 要求多条查询语句的列数个数要一致
    2. 要求多条查询语句的每一列的类型和顺序最好是一致的
    3. unioin关键字默认区中，如果要使用union all可以包含重复项

*/

# 查询部门编号>90或者邮箱包含a的员工信息
SELECT * FROM employees WHERE department_id > 90 OR  email LIKE '%a%';

SELECT * FROM employees WHERE department_id > 90
UNION 
SELECT * FROM employees WHERE  email LIKE '%a%';
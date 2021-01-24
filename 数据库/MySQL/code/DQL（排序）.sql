# ！！！例子使用的是myemployees.sql的库！！！
# 排序查询
/*
语法：
    SELECT 查询列表 
    FROM 表
    【where 筛选条件】
    ORDER BY 字段 （排序方式asc或者desc）
特点：
    asc：低到高（默认情况），升序
    desc：高到低，降序
    可以使用别名进行排序
    order by 子句中可以支持单个字段，多个字段，表达式，函数，别名
    order by 子句一般是放到查询语句的最后面，limit语句例外
    如果有多个字段的话，则按照从左到右排序
*/

# 查询员工信息，要求工资从低到高
SELECT * FROM employees ORDER BY salary;
SELECT * FROM employees ORDER BY salary ASC ;
# 查询员工信息，要求工资从高到低
SELECT * FROM employees ORDER BY salary DESC  ;


# 查询部门编号>=90的员工信息，按照入职时间先后进行排序
SELECT * FROM  employees WHERE  department_id >= 90 ORDER BY hiredate ASC ;

#按照年薪的高低显示员工的信息和年薪【表达式和别名】
SELECT *, salary*12*(1+IFNULL(commission_pct, 0)) AS 年薪 FROM employees ORDER BY salary*12*(1+IFNULL(commission_pct, 0)) DESC ;
SELECT *, salary*12*(1+IFNULL(commission_pct, 0)) AS 年薪 FROM employees ORDER BY 年薪 DESC ;

# 按照姓名的长度显示员工信息和工资【按照函数排序】
SELECT LENGTH(last_name) AS 姓名长度 FROM employees ORDER BY LENGTH(last_name);

# 查询员工信息，要求先按照工资排序，再按照员工编号排序【多个字段排序】
SELECT * FROM employees ORDER BY salary ASC , employee_id DESC ;
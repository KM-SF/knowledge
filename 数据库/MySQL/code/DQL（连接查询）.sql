# ！！！例子使用的是myemployees.sql的库！！！
# ！！！例子使用的是girls.sql的库！！！

# ！！！例子使用的是girls.sql的库！！！
# 连接查询
/*
含义：又称多表查询，当查询的字段来自多于多个表时，就会用到连接查询

笛卡尔乘积现象：表1有m行，表2有n行，结果m*n行

发生原因：没有有效的连接条件
如何避免：添加有效的连接条件

分类：
    按照年份分类：
        sql92标准：仅支持内连接
        sql99标准（推荐）：支持内连接，外连接（左外，右外），交叉连接

    按照功能分类：
        内连接：
            等值连接
            非等值连接
            自连接
        外连接：
            左外连接
            右外连接
            全外连接
        交叉连接
*/

# ------------------------------------------------------------------------------
# 一. sql92标准
/*
# 1. 等值连接

语法：
    select 查询列表
    from 表1 别名1，表2 别名2。。。
    where 别名1.key = 别名2.key 【and 筛选条件】
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】
    

1. 多表等值连接的结果为多表的交集部分
2. n表连接，至少需要n-1个连接条件
3. 多表的顺序没有要求
4. 一般需要为表起别名
5. 可以搭配所有子句使用：排序，分组
*/
# 查询女神名和对应的男神名
SELECT name, boyName FROM beauty, boys WHERE beauty.boyfriend_id = boys.id;

# 1. 查询员工名和对应的部门名
SELECT last_name , department_name FROM employees, departments WHERE employees.department_id = departments.department_id;

/*
为表起别名：
1. 提高代码的简洁度
2. 区分多个重名的字段
注意：如果为表起了别名，则查询的字段就不能使用原来的表名，要使用别名
*/
# 2. 查询员工名，工种号，工种名
SELECT last_name, j.job_id, j.job_title  FROM employees as e , jobs as j WHERE e.job_id = j.job_id;

# 3. 两个表的顺序可以调换
SELECT last_name, j.job_id, j.job_title  FROM jobs as j, employees as e WHERE e.job_id = j.job_id;

# 4. 加筛选条件
# 查询有奖金的员工们和部门名
SELECT last_name, department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id AND e.commission_pct is NOT NULL ;

# 查询城市名中第二个字符为o的部门和城市名
SELECT department_name, city
FROM departments d, locations l
WHERE d.location_id = l.location_id AND l.city LIKE "_o%";

# 5. 分组
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

# 6. 排序
# 查询每个工种的工种名和员工的个数，并且按员工个数降序
SELECT job_title, COUNT(*)
FROM  employees, jobs
WHERE employees.job_id = jobs.job_id
GROUP BY jobs.job_id
ORDER BY COUNT(*) DESC ;

# 7. 多表连接
# 查询员工名，部门名和所在的城市
SELECT last_name, department_name, city
FROM employees e, departments d, locations l
WHERE e.department_id = d.department_id AND d.location_id = l.location_id;


/*
# 2. 非等值连接

语法：
    select 查询列表
    from 表1 别名1，表2 别名2。。。
    where 非等值连接条件（不一定是！=号）
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】
*/

# 查询员工的工资和工资级别
SELECT salary , grade_level
FROM employees, job_grades
WHERE salary BETWEEN lowest_sal AND highest_sal;

/*
# 3. 自连接
语法：
    select 查询列表
    from 表 别名1，表 别名2。。。（都是同个表）
    where 等值连接条件
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】
*/
# 查询员工名和上级名
SELECT e.employee_id, e.last_name,  m.employee_id,  m.last_name
FROM employees e, employees m
WHERE e.manager_id = m.employee_id AND e.manager_id is NOT NULL ;


#-----------------------------------------------------------------
# 二. sql99语法
/*
语法：
    select 查询列表
    from 表1 别名 【连接类型】
    join 表2 别名
    on 连接条件
    【where 筛选条件】
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】

内连接：inner：交集
外连接
    左外：left 【outer】    左表全集
    右外：right 【outer】   右边全集
    全外：full 【outer】    并集
交叉连接：cross

*/

# 内连接
/*
语法：
    select 查询列表
    from 表1 别名 
    inner join 表2 别名
    on 连接条件
    【where 筛选条件】
    【group by 分组字段】
    【having 分组后的筛选】
    【order by 排序字段】

分类：
    等值
    非等值
    自连接

特点：
1. 添加排序，分组，筛选，多表
2. inner可以省略
3. 筛选条件放在where后面，连接条件放在on后面，便于阅读
4. inner join连接和sql92语法中的等值连接效果一样，都是查询多表的交集
*/

# 1. 等值连接
# 简单查询。多表顺序可以调换
# 查询员工名，部门名
SELECT last_name, d.department_id
FROM employees e
INNER JOIN departments d
on e.department_id = d.department_id;

# 加筛选条件
# 查询名字中包含e的员工名和工种名
SELECT e.last_name, j.job_title
FROM employees e
INNER JOIN jobs j
ON e.job_id = j.job_id
WHERE e.last_name LIKE '%e%';

# 添加分组
# 查询部门个数>3的城市名和部门个数
# 1. 查询每个城市的部门个数
# 2. 在1结果上筛选满足条件
SELECT city, COUNT(*)
FROM departments d
INNER JOIN locations l
ON d.location_id = l.location_id
GROUP BY city
HAVING COUNT(*) > 3;

# 添加排序
# 查询哪个部门的员工个数>3，对应的部门名和员工个数，并按照个数降序
SELECT d.department_name, COUNT(*) 员工个数
FROM departments d
INNER JOIN employees e
ON d.department_id = e.department_id
GROUP BY d.department_id
HAVING COUNT(*) > 3
ORDER BY COUNT(*) DESC ;

# 多表连接
# 查询员工名，部门名，工种名，并按照部门名排序
SELECT e.last_name, d.department_name, j.job_title
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN jobs j ON e.job_id = j.job_id
ORDER BY d.department_name DESC ;

# 2. 非等值连接
# 简单查询
# 查询员工的工资级别
SELECT e.last_name, e.salary, j.grade_level
FROM employees e
INNER JOIN job_grades j
ON e.salary BETWEEN j.lowest_sal AND J.highest_sal;

# 分组，筛选条件，排序
# 查询工资级别个数>20的个数，并且按照工资级别降序
SELECT j.grade_level, COUNT(*) 个数
FROM employees e
INNER JOIN job_grades j
ON e.salary BETWEEN j.lowest_sal AND J.highest_sal
GROUP BY j.grade_level
HAVING COUNT(*) > 20
ORDER BY j.grade_level DESC ;

# 3. 自连接
# 查询员工的名字，上级的名字
SELECT e.last_name, m.last_name
FROM employees e
INNER JOIN employees m
ON e.manager_id = m.employee_id;

# 二. 外连接
/*
应用场景：用于查询一个表中有，另外一个表没有的记录

特点：
1. 外连接的查询结果为主表中的所有记录
2. 如果从表中有和它匹配的，则显示匹配的值
3. 如果从表中没有和它匹配的，则显示NULL
4. 外连接的查询结果 = 内连接结果 + 主表中有而从表没有的记录
5. 左外连接，left join左边的是主表
6. 右外连接，right join右边的是主表
7. 左外和右外交换两表的顺序，可以实现同样的效果
8. 全外连接 = 内连接的结果 + 表1中有但是表2没有 + 表2中有但是表1没有
*/
# 查询没有男朋友的女神名
# 左外连接
SELECT *
FROM beauty b
LEFT JOIN boys bo
ON b.boyfriend_id = bo.id
WHERE bo.id IS NULL;

# 右外连接
SELECT *
FROM boys bo
RIGHT JOIN beauty b
ON b.boyfriend_id = bo.id
WHERE bo.id IS NULL;

# 查询哪个部门没有员工
SELECT d.*, e.employee_id
FROM departments d
LEFT JOIN employees e
ON d.department_id = e.department_id
WHERE e.employee_id IS NULL ;


# 全外
SELECT *
FROM beauty b
FULL JOIN boys bo
ON b.boyfriend_id = bo.id;

# 交叉连接：笛卡尔乘积 = 表1的行数*表2的行数
 SELECT *
 FROM beauty bo
 cross JOIN boys b

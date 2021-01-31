# ！！！例子使用的是myemployees.sql的库！！！
# ！！！例子使用的是girls.sql的库！！！

# 子查询
/*
含义：出现在其他语句（增删改查）中的select语句，称为子查询和内查询。外部的查询语句，称为主查询或者外查询
子查询的执行优先于主查询执行，主查询的条件用到了子查询的结果

分类：
按照子查询出现的位置：
    select后面：仅仅支持标量子查询
    from后面：支持表子查询
    where或者having后面：支持标量子查询，行子查询，列子查询
    exists后面：支持表子查询

按照结果集的行列数不同
    标量子查询（结果集只有一行一列）
    列子查询（结果集只有多行一列）
    行子查询（结果集只有一行多列）
    表子查询（结果集一般为多行多列）
*/

#一、where活having后面
/*
1. 标量子查询（单行子查询）
2. 列子查询（多行子查询）
3. 行子查询（多列多行，用的较少）

特点：
    1. 子查询放在小括号内
    2. 子查询一般放在条件的右侧
    3. 标量子查询，一般搭配单行操作符使用
        > < >= <= = !=
    4. 列子查询，一般搭配多行操作费使用
        IN ANY/SOME ALL 

*/

# 标量子查询：> < >= <= = !=
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

# 列子查询（多行子查询）：IN ANY/SOME ALL 
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

# 行子查询（多列子查询）：IN ANY/SOME ALL 
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

 # 二. select后面。可以用其他的语法实现。仅仅支持标量子查询
 # 查询每个部门的员工个数
 SELECT *, (
     SELECT COUNT(*)
     FROM employees
     WHERE employees.department_id = departments.department_id
 ) 个数
 FROM departments ;


# 三. from后面
# 将子查询结果充当一张表，要求必须起别名
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


# 四. exists后面（相关子查询）
/*
语法： exists（完整的查询语句）
结果：0或者1
*/
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
# ！！！例子使用的是myemployees.sql的库！！！
# 分组查询
/*
语法：
    select 分组函数，列（要求出现在group by的后面）
    from 表
    【where 筛选条件】
    group by 分组的列表
    【order by 子句】

注意：
    1. 查询列表必须特殊：要求是分组函数和group by后出现的字段

特点：
    1. 分组查询中的筛选条件分为两类
                    数据源              位置                关键字
    分组前筛选      原始表              group by 语句前     where
    分组后筛选      分组后的结果        group by 语句后     having
    2. 分组函数做条件肯定是放在having子句中
    3. GROUP BY 子句支持单个字段分组，多个字段分组。（多个字段分组之间用，逗号隔开，没有先后顺序要求）
    4. 表达式或者函数用的比较少
    5. 也可以添加排序（排序放在整个分组查询的最后）
*/

# 简单的分组查询
# 查询每个工种的最高工资
SELECT MAX(salary) FROM employees GROUP BY job_id;

# 查询每个位置上的部门个数
SELECT COUNT(*), location_id FROM departments GROUP BY location_id;


# 添加分组前的筛选条件
# 查询邮箱中包含a字符的，每个部门的平均工资
SELECT AVG(salary) FROM employees WHERE email LIKE '%a%' GROUP BY department_id;

# 查询有奖金的每个领导手下员工的最高工资
SELECT MAX(salary) FROM employees WHERE commission_pct is NOT NULL GROUP BY manager_id;

# 添加分组后的筛选条件
# 查看哪个部门的员工个数>2

#步骤：1，2
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


# 按表达式或者函数分组
# 按照员工姓名长度，查询每一组的员工个数，筛选员工个数>5有哪些

SELECT COUNT(*), LENGTH(last_name)  FROM employees GROUP BY LENGTH(last_name) HAVING COUNT(*)>5;
# 支持别名分组
SELECT COUNT(*) AS c, LENGTH(last_name) AS l FROM employees GROUP BY l HAVING c>5;

# 按照多个字段分组。多个字段为一组，只要组里面有的字段值不一样则认为该组不一样。跟字段的前后无关
# 查询每个部门每个工种的员工的平均工资
SELECT AVG(salary),department_id, job_id FROM employees GROUP BY  department_id, job_id;

# 按照排序
# 查询每个部门每个工种的员工的平均工资，并且按照平均工资的高低显示
SELECT AVG(salary),department_id, job_id FROM employees GROUP BY  department_id, job_id ORDER BY AVG(salary) DESC ;
SELECT AVG(salary),department_id, job_id FROM employees WHERE department_id is NOT NULL  GROUP BY  department_id, job_id ORDER BY AVG(salary) DESC ;
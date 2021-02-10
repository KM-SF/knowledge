# 视图
/*
含义：虚拟表，行和列的数据来自定义视图的查询中使用的表，并且是使用视图时动态生成的，只保存sql逻辑，不保存查询的结果
应用场景：
    1. 多个地方用到同样的查询结果
    2. 该查询结果使用的sql语句较复杂

            语法                空间占用            使用
视图        create view         只保存了sql逻辑     增删改查，一般只查询
表          create TABLE        保存了数据          增删改查
*/

# 查询姓张的学生名和专业名
SELECT s.stdName, m.majorName
FROM stuinfo s
INNER JOIN major m ON s.majorId=m.id
WHERE s.stdName LIKE '张%';

CREATE VIEW v1
AS 
SELECT s.stdName, m.majorName
FROM stuinfo s
INNER JOIN major m ON s.majorId=m.id;

SELECT * FROM v1 WHERE s.stdName LIKE '张%';

# 创建视图
/*
语法：
CREATE VIEW 视图名
AS
查询语句;

特点：
    1. 重用sql语句
    2. 简化复杂的sql操作，不必知道他的查询细节
    3. 保护数据，提高安全

*/

# 查询邮箱中包含a字符的员工名，部门名和工种信息
# 1. 创建视图
CREATE VIEW myv1
AS
SELECT e.last_name, d.department_name , j.job_title
FROM employees e
INNER  JOIN departments d ON e.department_id = d.department_id
INNER  JOIN jobs j ON j.job_id = e.job_id;

# 2. 使用视图
SELECT * FROM myv1 WHERE last_name LIKE '%a%';


# 查询各个部门的平均工资级别
CREATE VIEW myv2
AS
SELECT AVG(salary) ag, department_id
FROM employees 
GROUP BY department_id;

SELECT *
FROM myv2 
INNER JOIN job_grades g ON  myv2.ag BETWEEN g.lowest_sal AND g.highest_sal;

# 查询平均工资最低的部门信息
SELECT * FROM myv2 ORDER BY ag LIMIT 1;

# 查询平均工资最低的部门名和工资
CREATE VIEW myv3
AS
SELECT * FROM myv2 ORDER BY ag LIMIT 1;

SELECT d.department_id, d.department_name, myv3.ag
FROM myv3
INNER JOIN departments d ON myv3.department_id = d.department_id;


# 修改视图结构
/*
方法一：
CREATE OR REPLACE VIEW 视图名
AS
查询语句;
*/

SELECT * FROM myv3;
CREATE OR REPLACE VIEW  myv3
AS
SELECT AVG(salary), job_id
FROM employees
GROUP BY job_id;

/*
方法二：
ALTER VIEW 视图名
AS
查询语句;
*/
ALTER VIEW myv3
AS
SELECT * FROM employees;


# 删除视图
/*
DROP VIEW 视图名，视图名。。。
*/
DROP VIEW myv1, myv2, myv3;

# 查看视图结构
DESC myv3;
SHOW CREATE VIEW myv3;

# 更新视图数据
/*
更新视图的数据实际是操作原表
视图的可更新性和视图查询的定义有关系，以下类型的视图不能更新。
    1. 包含关键字的sql语句：分组函数，distinct，group by，having，union或者union ALL 
    2. 常量视图
    3. select中包含子查询
    4. JOIN 
    5. from一个不能更新的视图
    6. where子句的子查询引用了from子句中的表
*/

CREATE OR REPLACE VIEW  myv1
AS
SELECT last_name, email
FROM employees;

SELECT * FROM myv1;
SELECT * FROM employees;

# 1. 插入数据
INSERT INTO myv1 VALUES('张飞','111111');

# 2. 修改数据
UPDATE myv1 SET last_name='张无忌' WHERE last_name='张飞';

# 3. 删除
DELETE  FROM myv1 WHERE last_name='张无忌';
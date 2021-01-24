# ！！！例子使用的是myemployees.sql的库！！！
# 条件查询
/*
语法：
select 
    查询列表
from
    表名
where
    筛选条件

执行顺序：
1. 先去查看表名，释放存在该表
2. 过滤筛选条件
3. 查询对应的列表

分类：
一.条件表达式筛选
    条件运算符：> < = != <>(也是不等于) >= <=
二.按逻辑表达式筛选
    逻辑运算符： and or not(&& || !)这一组都相同
三.模糊查询
    like：
        一般跟通配符一起使用
        %：包含任意多个字符，包括0个字符
        _：任意单个字符
    between and
    in
    is null
*/

# 按条件表达式筛选
# 查询工资大于12000的员工信息
SELECT * FROM employees WHERE salary>12000;
# 查询部门编号不等于90的员工名和部门编号
SELECT last_name, department_id FROM employees WHERE employee_id!=90;
SELECT last_name, department_id FROM employees WHERE employee_id<>90;


# 逻辑表达式查询
# 查询工资在10000~20000之间的员工名，工资以及奖金
SELECT last_name, salary, commission_pct FROM employees WHERE salary>=10000 and salary<=20000;
# 查询部门编号不在90~110之间，或者工资高于15000的员工信息
SELECT * FROM employees WHERE NOT(commission_pct>=90 AND commission_pct<=110) OR salary>15000;

# 模糊运算符

# LIKE 
# 查询员工名中包含字符a的员工信息
SELECT * FROM employees WHERE last_name LIKE '%a%';
# 查询员工名中第三个字符为e，第5个字符为l的员工名和工资
SELECT last_name, salary FROM employees WHERE last_name LIKE '__n_l%';
# 查看员工名中第二个字符为_的员工名
SELECT last_name FROM employees WHERE last_name LIKE '_\_%'; #这里\是转移字符
SELECT last_name FROM employees WHERE last_name LIKE '_$_%' ESCAPE '$' ; #这里$是转移字符

# BETWEEN AND
/*
1. 提高代码整洁度
2. 包含临界值
3. 不能颠倒临界值
4. 等价于>=val and val<=
*/
# 查询员工编号在100到120之间的员工信息
SELECT * FROM employees WHERE employee_id BETWEEN 100 AND 200

#in
/*
语法：判断某个字段的值是否属于in列表中的某一项
特点：
    1. 使用in提高代码整洁度
    2. in列表的值类型必须是可以转换的（例如int转字符串，字符串转int）
    3. in列表的参数不支持通配符
    4. 等价于=val or =val1 or =val2 ...
*/
# 查询员工工种编号是IT_PROG,AD_VP,AD_PRES中一个员工名和工种编号
SELECT last_name, job_id FROM employees WHERE job_id IN ('IT_PROG','AD_VP','AD_PRES');

# is NULL 
/*
!= == <> 不能用于判断NULL值
*/
# 查询没有奖金的员工名字和奖金率
SELECT last_name, commission_pct FROM employees WHERE commission_pct IS NULL ;
SELECT last_name, commission_pct FROM employees WHERE commission_pct IS NOT  NULL ;

# 安全等于<=>
# IS NULL 仅仅可以判断NULL值，可读性较高
# <=> 既可以判断NULL值，又可以判断普通的数值，可读性较低
# 查询没有奖金的员工名字和奖金率
SELECT last_name, commission_pct FROM employees WHERE commission_pct <=> NULL ;
SELECT last_name, salary FROM employees WHERE salary<=>12000;
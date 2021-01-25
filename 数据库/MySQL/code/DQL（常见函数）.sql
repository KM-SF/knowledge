# ！！！例子使用的是myemployees.sql的库！！！
# 常见函数
/*
语法：函数名（实参列表）
特点：
    叫什么（函数名）
    干什么（函数功能）
分类：
    1. 单行函数：传入一组函数进行操作，返回操作结果
        1. 字符函数
        2. 数学函数
        3. 日期函数
        4. 其他函数
        5. 流程控制函数
    2. 分组函数：传入一组参数统计一个结果返回
*/

# 字符函数
# LENGTH：获取参数值的字节个数
SELECT LENGTH('km');
# 一个汉字占3个字节
SELECT LENGTH('张三丰');

# CONCAT 拼接字符串
SELECT CONCAT(last_name, '_', first_name) AS 姓名 FROM employees;

#upper：转大写
#lower：转小写
# 将姓变大写，名变小写，然后拼接
SELECT CONCAT(UPPER(last_name), '_',LOWER( first_name)) AS 姓名 FROM employees;

# substr, substring：字符串截断
# 注意：索引都是从1开始
# 从下标开始截取到末尾
SELECT SUBSTR('李莫愁爱上了陆展元', 7); 
# 从下标开始截取指定字符长度的字符
SELECT SUBSTR('李莫愁爱上了陆展元', 1, 3);

# INSRT : 返回子串第一次出现的索引，如果没有返回0
SELECT INSTR('杨不悔爱上了殷六侠', '殷六侠');

# TRIM：去掉首位的字符
SELECT TRIM('  张翠山   ');
SELECT TRIM('a' FROM  'aaaaaa张翠山aaaaaa');

#LPAD 用指定的字符实现左填充指定长度
#RPAD 用指定的字符实现右填充指定长度
#注意：最后返回的长度，是以传递的长度为主。
SELECT LPAD('殷素素', 12, '*');
SELECT LPAD('殷素素', 2, '*'); #殷素
SELECT RPAD('殷素素', 12, '*'); 
SELECT RPAD('殷素素', 2, '*'); #殷素

# REPLACE 替换：替换所有的字符串
SELECT REPLACE('张无忌爱上了周芷若','周芷若','赵敏');
SELECT REPLACE('周芷若张无忌爱上了周芷若','周芷若','赵敏');

#--------------------------------------------------------
# 数学函数
# round：四舍五入
# 第二个参数：支持小数点几位
SELECT ROUND(1.22); # 1
SELECT ROUND(1.5); # 2
SELECT ROUND(-1.22); # -1
SELECT ROUND(-1.5); # -2
SELECT ROUND(1.567, 2); #1.57
SELECT ROUND(1, 2); # 1

# ceil 向上取整 返回>=该参数的最小值
SELECT CEIL(1.00); # 1
SELECT CEIL(1.01); # 2

SELECT CEIL(-1.01); # -1

# floor 向下取整，返回<=该参数的最大整数
SELECT FLOOR(-9.99); # -10
SELECT FLOOR(1.01); # 1

# TRUNCATE ：截断小数点N位
SELECT TRUNCATE(1.666666, 1);

# mod取余
# 公式：MOD(a,b) => a - a/b *b
# mod(-10, -3) => -10 - (-10)/(-3) * (-3) = -1
SELECT MOD(-10, -3); # -1

# 日期函数
# NOW 返回当前系统日期+时间
SELECT NOW();
# CURDATE 返回当前系统日志，不包含时间
SELECT CURDATE();
# CURTIME 返回当前时间，不包含日期
SELECT CURTIME();
# 可以获取指定部分，年，月，日，小时，分钟，秒
SELECT YEAR(NOW());
SELECT YEAR('1996-01-02');
SELECT MONTH(now());
SELECT MONTHNAME(NOW()); # 英文月名

# STR_TO_DATE：将日期格式的字符转换成指定格式的日期
SELECT  STR_TO_DATE('1996-01-02', '%Y-%c-%d');
# 查询入职日期为1992-4-3的员工信息
SELECT * FROM employees WHERE hiredate = STR_TO_DATE('4-3 1992', '%c-%d %Y');

# DATE_FORMAT：将日期转换成字符
SELECT DATE_FORMAT(NOW(),'%y年%m月%d日');
# 查询有奖金的员工名和入职日期（xx月/xx日/xx年）
SELECT last_name ,DATE_FORMAT(hiredate, '%m月/%d日/%Y年') FROM employees;

# 流出控制函数
# 1. if函数：if else效果
SELECT IF(10<5, '大', '小');

# CASE 函数
/*
一：switch case 的效果
    case 要判断的字段或者表达式
    when 常量1 then 要显示的值1或者语句1;
    when 常量2 then 要显示的值2或者语句2;
    ...
    else 要显示的值N或者语句N;
    end
*/
SELECT department_id, salary AS 原始工资, 
CASE department_id
WHEN 30 THEN salary*1.1
WHEN 40 THEN salary*1.2
WHEN 50 THEN salary*1.3
WHEN 60 THEN salary*1.4
ELSE salary
END AS 新工资
FROM employees;


/*
二：类似于多重IF
    case
    when 条件1 then 要显示的值1或者语句1;
    when 条件2 then 要显示的值1或者语句2;
    when 条件3 then 要显示的值1或者语句3;
    else 要显示的值N或者语句N;
    end
*/
SELECT salary , 
CASE 
WHEN salary > 20000 THEN 'A'
WHEN salary > 15000 THEN 'B'
WHEN salary > 10000 THEN 'C'
ELSE 'D'
END AS 工资级别
FROM employees;
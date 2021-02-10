# 存储过程
/*
存储过程：类似于编程方法
好处：
    1. 提高代码的重用性
    2. 简化操作
*/

# 存储过程
/*
含义：一组预先编译好的SQL语句和集合，理解成批量处理语句
好处：
    1. 提高代码的重用性
    2. 简化操作
    3. 减少编译次数并且减少了和数据库服务器的连接次数，提高效率
*/

## 一。创建语法
/*
DELIMITER 结束符
CREATE PROCEDURE 存储过程名(参数列表)
BEGIN 
    存储过程体(一组合法的sql语句)
END 结束符

注意：
    1. 参数列表包含三个部分：参数模式 参数名 参数类型（IN stunam VARCHAR (20)）
    2. 如果存储过程体仅仅只有一句话，BEGIN END 可以省略
    3. 存储过程体重的每条SQL语句的结尾要求必须加分号
    4. 存储过程的结尾（END 结束符）可以使用DELIMITER 重新设置结束符（DELIMITER $）

参数模式：
    IN：该参数可以作为输入，也就是入参
    OUT：该参数可以作为输出，也就是出参（返回值）
    INOUT：该参数可以作为输入和输出，也就是入参和出参（返回值）

*/

## 二。调用语法
/*
CALL 存储过程名(实参列表);
*/


### 空参列表
# 插入到admin表中3条记录
SELECT * FROM admin;
DELIMITER $
CREATE PROCEDURE myp1()
BEGIN 
    INSERT INTO admin(username, `password`) VALUES('y','1'),('s','2'),('f','3');
END $
# 调用
CALL myp1();

### 创建带IN的参数
# 创建存储过程实现，根据女神名，查询对应男神信息
DELIMITER $
CREATE PROCEDURE myp2(IN beautyName VARCHAR (20))
BEGIN 
    SELECT bo.*
    FROM beauty b
    INNER   JOIN boys bo  ON b.boyfriend_id = bo.id
    WHERE b.name = beautyName;
END $
# 调用
CALL myp2('王语嫣')$

# 创建存储过程实现，用户是否登录成功
CREATE PROCEDURE myp4(IN username VARCHAR (20), IN pwd VARCHAR (20))
BEGIN 
    DECLARE res VARCHAR (20) DEFAULT ''; # 声明并且初始化
    SELECT COUNT(*) INTO res # 复制
    FROM admin
    WHERE admin.username = username AND admin.password = pwd;
    SELECT IF(res>0,'成功','失败');
END $
# 调用
CALL myp3('张飞','8888888');

### 创建带OUT的参数
# 根据女神名，返回男神名
CREATE PROCEDURE myp5(IN gName VARCHAR (20), OUT bName VARCHAR (20))
BEGIN 
    SELECT bo.boyName INTO bName
    FROM beauty b
    INNER JOIN boys bo ON b.boyfriend_id = bo.id
    WHERE b.name = gName;
END $

# 调用
SET @bName=''$
CALL myp5('小昭', @bName)$
SELECT @bName$

# 根据女神名，返回对应的男神名和魅力值
CREATE PROCEDURE myp6(IN gName VARCHAR (20), OUT bName VARCHAR (20), OUT CP INT)
BEGIN 
    SELECT bo.boyName, bo.userCP INTO bName, CP
    FROM beauty b
    INNER JOIN boys bo ON b.boyfriend_id = bo.id
    WHERE b.name = gName;
END $
# 调用
SET @bName=''$
SET @bCP=0$
CALL myp6('小昭', @bName, @bCP)$
SELECT @bName, @bCP$


### 创建带INOUT的参数
# 传入a和b，a和b都翻倍并返回
CREATE PROCEDURE myp7(INOUT a INT, INOUT b INT)
BEGIN 
    SET a=a*2;
    SET b=b*2;
END $
# 调用
SET @M=10;
SET @N=20;
CALL myp7(@M,@N)$
SELECT @M,@N$


## 三。删除存储过程
/*
语法：DROP PROCEDURE 存储过程名
一次只能删除一个
*/
DROP PROCEDURE myp7;

## 四。查看存储过程信息
SHOW CREATE PROCEDURE myp6;

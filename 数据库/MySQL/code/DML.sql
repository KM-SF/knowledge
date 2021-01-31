#DML语言
/*
数据操作语言
插入：insert
修改：update
删除：delete
*/

# 一。插入语句
/*
方式一：
语法：insert into 表名(列名) values(值1,值2...)

特点：
    1. 插入的值的类型要与列的类型一致或者兼容
*/

DESC beauty;
SELECT * FROM beauty;

# 插入的值的类型要与列的类型一致或者兼容
INSERT INTO beauty(id, name, sex, borndate, phone, photo, boyfriend_id) 
VALUES (13, "唐艺昕", '女', '1990-4-23','18988888888', NULL, 2);

# 不可以为null的值必须插入，可以为NULL的值，可以不插入，不插入时则用默认值
INSERT INTO beauty(id, name, sex,  phone ) 
VALUES (14, "娜扎", '女', '18988888888');

# 调换列的顺序
INSERT INTO beauty(name, id,  sex,  phone ) 
VALUES ("迪丽热巴", 15, '女', '18988888888');

# 列数和值的个数必须一致。不一致会报错
INSERT INTO beauty(name, id,  sex,  phone ) 
VALUES ("高圆圆", 16, '女');

# 可以省略列名，默认所有列，而且列的顺序和表中的顺序一致
INSERT INTO beauty
VALUES (17, "女神", '女', '1990-4-23','18988888888', NULL, 2);

# 支持插入多行
INSERT INTO beauty(id, name, sex, borndate, phone, photo, boyfriend_id) 
VALUES (18, "唐艺昕2", '女', '1990-4-23','18988888888', NULL, 2),
 (16, "唐艺昕3", '女', '1990-4-23','18988888888', NULL, 2),
 (20, "唐艺昕4", '女', '1990-4-23','18988888888', NULL, 2);

# 支持子查询
INSERT INTO beauty(id, name, phone)
    SELECT boys.id + 20, boys.boyName, "123321"
    FROM boys
    WHERE boys.id = 4


/*
# 方式二
语法：
    INSERT INTO 表名
    SET 列名=值, 列名=值...
*/
INSERT INTO beauty
SET id=19, name="刘涛", phone='18988888888';




# 二。修改语句
/*
1. 修改单标的记录
语法：
    UPDATE 表名
    set 列=新值，列=新值...
    where 筛选条件;
执行顺序：
    1. 执行update
    2. 执行where
    3. 执行set

2. 修改多表记录
语法：
92语法：
    UPDATE 表名 别名, 表2 别名2
    set 列=新值，列=新值...
    where 连接条件 and
     筛选条件;

99语法：
    UPDATE 表名 别名
    inner|left|right|cross 表2 别名2
    ON 连接条件
    set 列=新值，列=新值...
    where 筛选条件;
    
*/

DESC beauty;
SELECT * FROM beauty;
SELECT * FROM boys;

# 1. 修改单表记录
# 修改beauty表中姓唐的女生电话为888
UPDATE beauty SET phone = '888'
WHERE name LIKE '%唐%';

# 修改boys表中id为2的名称为张飞，魅力值为10
UPDATE boys SET boys.boyName = '张飞', boys.userCP=10
WHERE id=2;


# 2. 修改多表记录
# 修改张无忌女朋友电话为999
UPDATE boys bo 
INNER JOIN beauty be
ON be.boyfriend_id = bo.id
SET be.phone='999'
WHERE bo.boyName='张无忌';

# 修改没有男朋友的女神，男朋友编号为2
UPDATE boys bo 
RIGHT  JOIN beauty be
ON be.boyfriend_id = bo.id
SET be.boyfriend_id=2
WHERE bo.id IS NULL ;



# 三. 删除语句
/*
方式一：delete：只删除筛选出来的行数据
语法：
1. 单表删除
    delete from 表名 where 筛选条件;

2. 多表删除
92语法：
    delete 表1的别名, [表2的别名]
    from 表1 别名1, 表2 别名2
    where 连接条件
    and 筛选条件

92语法：
    delete 表1的别名, [表2的别名]
    from 表1 别名1
    inner|left|right|cross  表2 别名2
    on 连接条件
    where 筛选条件

方式二：truncate：删除整个表
语法：truncate table 表名;
*/

DESC beauty;
SELECT * FROM beauty;
SELECT * FROM boys;

# 方式一：
# 1. 单表删除
# 删除手机号为9结尾的女神信息
DELETE FROM beauty WHERE phone LIKE '%9';

# 2. 多表删除
# 删除张无忌的女朋友
DELETE b
FROM beauty b
INNER JOIN boys bo
ON  bo.id = b.boyfriend_id 
WHERE bo.boyName = '张无忌';

# 删除黄晓明的信息以及他女朋友的信息
DELETE b, bo
FROM beauty b
INNER JOIN boys bo
ON  bo.id = b.boyfriend_id 
WHERE bo.boyName = '黄晓明';


# 方式二：truncate语句(清空)
# truncate不支持条件筛选
TRUNCATE TABLE boys;

/* delete PK truncate
1. delete可以加where条件，truncate不支持
2. truncate删除，效率高一点
3. 加入用delete删除后，再插入，自增长列的值从断点开始。而truncate删除后，再插入，则从1开始
4. truncate没有返回值，delete有返回值
5. truncate不支持回滚，delete可以回滚
*/
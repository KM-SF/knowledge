# 插入语句
+ 插入：insert
## 方式一：
+ 语法：insert into 表名(列名) values(值1,值2...)
+ 特点：
    1. 插入的值的类型要与列的类型一致或者兼容
    2. 不可以为null的值必须插入，可以为NULL的值，不插入时则用默认值
    3. 调换列的顺序
    4. 列数和值的个数必须一致。不一致会报错
    5. 可以省略列名，默认所有列，而且列的顺序和表中的顺序一致
    6. 支持插入多行
    7. 支持子查询

### 插入的值的类型要与列的类型一致或者兼容
```
INSERT INTO beauty(id, name, sex, borndate, phone, photo, boyfriend_id) 
VALUES (13, "唐艺昕", '女', '1990-4-23','18988888888', NULL, 2);
```

### 不可以为null的值必须插入，可以为NULL的值，不插入时则用默认值
```
INSERT INTO beauty(id, name, sex,  phone ) 
VALUES (14, "娜扎", '女', '18988888888');
```

### 调换列的顺序
```
INSERT INTO beauty(name, id,  sex,  phone ) 
VALUES ("迪丽热巴", 15, '女', '18988888888');
```

### 列数和值的个数必须一致。不一致会报错
```
INSERT INTO beauty(name, id,  sex,  phone ) 
VALUES ("高圆圆", 16, '女');
```

### 可以省略列名，默认所有列，而且列的顺序和表中的顺序一致
```
INSERT INTO beauty
VALUES (17, "女神", '女', '1990-4-23','18988888888', NULL, 2);
```

### 支持插入多行
```
INSERT INTO beauty(id, name, sex, borndate, phone, photo, boyfriend_id) 
VALUES (18, "唐艺昕2", '女', '1990-4-23','18988888888', NULL, 2),
 (16, "唐艺昕3", '女', '1990-4-23','18988888888', NULL, 2),
 (20, "唐艺昕4", '女', '1990-4-23','18988888888', NULL, 2);
```

### 支持子查询
```
INSERT INTO beauty(id, name, phone)
    SELECT boys.id + 20, boys.boyName, "123321"
    FROM boys
    WHERE boys.id = 4
```

## 方式二
+ 语法：INSERT INTO 表名 SET 列名=值, 列名=值...

### 例子
```
INSERT INTO beauty
SET id=19, name="刘涛", phone='18988888888';
```

## 比较

|      | 方法一                                    | 方法二                                   |
| ---- | ----------------------------------------- | ---------------------------------------- |
| 语法 | insert into 表名(列名) values(值1,值2...) | INSERT INTO 表名 SET 列名=值, 列名=值... |
| 特性 | 支持插入多行                              | 不支持插入多行                           |
| 特性 | 支持子查询插入                            | 不支持子查询插入                         |



# 修改语句
+ 修改：update
+ 修改单表的记录
    > + 语法：<br>
    >     UPDATE 表名 <br>
    >     set 列=新值，列=新值... <br>
    >     where 筛选条件; <br>
    > + 执行顺序：
    >   1. 执行update
    >   2. 执行where
    >   3. 执行set

+ 修改多表记录
    > 语法：
    > + 92语法：    <br>
    >    UPDATE 表名 别名, 表2 别名2    <br>
    >    set 列=新值，列=新值...    <br>
    >    where 连接条件 and <br>
    >    筛选条件;  <br>
    >
    > + 99语法：    <br>
    >    UPDATE 表名 别名   <br>
    >    inner|left|right|cross 表2 别名2   <br>
    >    ON 连接条件    <br>
    >    set 列=新值，列=新值...    <br>
    >    where 筛选条件;    <br>
    

## 修改单表记录
```
# 修改beauty表中姓唐的女生电话为888
UPDATE beauty SET phone = '888'
WHERE name LIKE '%唐%';

# 修改boys表中id为2的名称为张飞，魅力值为10
UPDATE boys SET boys.boyName = '张飞', boys.userCP=10
WHERE id=2;
```

## 修改多表记录
```
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
```


# 删除语句
+ 删除：delete

## 方式一：

  > + delete：只删除筛选出来的行数据
  > + 语法：
  >   + 单表删除：delete from 表名 where 筛选条件;
  >   + 多表删除
  >     + 92语法：  <br>
  >         delete 表1的别名, [表2的别名]    <br>
  >         from 表1 别名1, 表2 别名2    <br>
  >         where 连接条件   <br>
  >         and 筛选条件 <br>
  >     + 99语法：  <br>
  >         delete 表1的别名, [表2的别名] <br>
  >         from 表1 别名1    <br>
  >         inner|left|right|cross  表2 别名2 <br>
  >         on 连接条件   <br>
  >         where 筛选条件    <br>

方式二：truncate：删除整个表
语法：truncate table 表名;
*/

DESC beauty;
SELECT * FROM beauty;
SELECT * FROM boys;

# 方式一：delete
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


## 方式二：truncate语句(清空)
+ truncate不支持条件筛选
```
TRUNCATE TABLE boys;
```
## 对比
|            | delete                                             | truncate                                    |
| ---------- | -------------------------------------------------- | ------------------------------------------- |
| 筛选条件   | where条件                                          | 不支持                                      |
| 效率       | 低一点                                             | 高一点                                      |
| 自增长的值 | 加入用delete删除后，再插入，自增长列的值从断点开始 | truncate删除后，再插入，自增长列的值从1开始 |
| 返回值     | 有返回值                                           | 没有返回值                                  |
| 回滚       | 可以回滚                                           | 不支持回滚                                  |
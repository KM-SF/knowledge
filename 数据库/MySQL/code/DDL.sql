/*
数据定义语言（库和表的管理）

一。库的管理
创建，修改，删除

二。表的管理
创建，修改，删除，复制

创建：create
修改：alter
删除：drop

*/

#一。库的管理

#1. 库的创建
# 语法：create database 【IF NOT EXISTS 】 库名;

# 创建库Books
CREATE DATABASE Books;

# 判断库存不存在
CREATE DATABASE IF NOT  EXISTS  Books;

#2. 库的修改

# 修改库名，已经不支持了
# RENAME DATABASE Books TO NewBooks;

# 更改库的字符集
ALTER DATABASE Books CHARACTER SET gbk;


#3. 库的删除
DROP DATABASE Books;
# 判断库存不存在
DROP DATABASE IF  EXISTS  Books;


# 建库一般流程：
/*
1. DROP DATABASE IF EXISTS 旧库名
2. CREATE DATABASE 新库名
*/


# 二。表的管理
/*
1. 表的创建
语法：
create table [IF NOT EXISTS] 表名 (
    列名 列的类型【（长度） 约束】,
    列名 列的类型【（长度） 约束】,
    ...
    列名 列的类型【（长度） 约束】,
)
*/

# 创建表Book
CREATE TABLE book(
    id INT, #编号
    bName VARCHAR(20), # 书名
    price DOUBLE , # 价格
    authorID INT , # 作者编号
    publishDate DATETIME  # 出版日期
);
DESC book;

# 创建表Book
CREATE TABLE author(
    id INT, #编号
    au_name VARCHAR(20), # 姓名
    nation VARCHAR(20)
);
DESC author;


/*
2. 表的修改

语法：ALTER TABLE 表名 CHANGE|MODIFY|ADD|DROP|RENAME TO [COLUMN] 列名 [列类型|约束];

支持：
    1. 修改列名 CHANGE
    2. 修改列的类型或者约束 MODIFY
    3. 添加新列 ADD
    4. 删除列 DROP
    5. 修改表名 RENAME TO
*/

# 修改列名
ALTER TABLE book CHANGE COLUMN publishDate pubDate DATETIME;

# 修改列的类型或者约束
ALTER TABLE book MODIFY COLUMN pubDate TIMESTAMP;

# 添加新列
ALTER TABLE author ADD COLUMN annual DOUBLE;

# 删除列名
ALTER TABLE author DROP COLUMN annual;

# 修改表名
ALTER TABLE author RENAME TO book_auther;


/*
3. 表的删除
*/
# 删除表
DROP TABLE book_auther;
# 判断表是否存在
DROP TABLE IF EXISTS book_auther;
SHOW TABLES;


# 建表一般流程：
/*
1. DROP TABLE IF EXISTS 旧表名;
2. CREATE TABLE 表名();
*/

/*
4. 表的复制

支持：
    1. 仅仅复制表的结构
    2. 复制表的结构+数据
    3. 只复制部分结构
    4. 只复制部分结构和部分数据。所写字段要一样
*/
INSERT INTO author VALUES
(1, '村上春树', '日本'),
(2, '莫言', '中国'),
(1, '金庸', '中国');

SELECT * FROM author;

# 仅仅复制表的结构
CREATE TABLE copy_author LIKE author;

# 复制表的结构+数据
CREATE TABLE copy_author_data
SELECT * FROM author;

# 只复制部分结构
CREATE TABLE copy_author_some
SELECT id, au_name
FROM author
WHERE 0; # 永远不成立，所以只会复制结构

# 只复制部分结构和部分数据。所写字段要一样
CREATE TABLE copy_author_some_data
SELECT id, au_name
FROM author
WHERE nation='中国';



#-----------------------------------------------

# 常见数据类型
/*
数值型：
    整型
    小数：
        定点数
        浮点数

字符型：
    较短的文本：char，varchar
    较长的文本：text，blob（二进制数据）

日期型：

所选择的类型越简单越好，能保存数值的类型越小越好

*/


# 一。整型
/*
分类：
    tinyint（1），smallint（2），mediumint（3），int（4），bigint（8）

特点：
    1. 如果不设置无符号还是有符号，默认是有符号
    2. 设置有符号需要添加UNSIGNED关键字
    3. 如果插入数值超出了最大范围会报错，无法插入
*/

# 如何设置无符号和有符号
DROP TABLE IF EXISTS tab_int;
CREATE TABLE tab_int (
    t1 INT, 
    t2 INT UNSIGNED 
);

DESC tab_int;
SELECT * FROM tab_int;

INSERT INTO  tab_int VALUES(1111, 2);
INSERT INTO  tab_int VALUES(1111, -11111111111);


# 二。小数
/*
分类：
    1. 浮点型
        float(M,D)
        double(M,D)
    2. 定点数
        dec(M,D)
        decimal(M,D)


特点：
    1. M代表整数部位+小数部位
    2. D代表小数部位
    3. 如果如果整数不为超过范围（M-D），则插入失败
    4. M和D可以省略
        如果decimal，则M默认为10，D默认为0
        如果是float和double，会根据插入的数值的精度来决定精度
    5. 定点型精度较高，如果要求插入的数值的精度较高：如货币运算等可以考虑使用
*/

DROP TABLE IF EXISTS tab_float;
CREATE TABLE tab_float(
    f1 FLOAT(5,2),
    f2 DOUBLE (5,2),
    f3 DECIMAL (5,2)
);

DROP TABLE IF EXISTS tab_float;
CREATE TABLE tab_float(
    f1 FLOAT,
    f2 DOUBLE,
    f3 DECIMAL
);
DESC tab_float;

SELECT * FROM tab_float;

INSERT INTO tab_float VALUES(123.4,123.4,123.4);
INSERT INTO tab_float VALUES(123.45,123.45,123.45);
INSERT INTO tab_float VALUES(123.456,123.456,123.456);
INSERT INTO tab_float VALUES(1111,11123.456,11123.456);


#三。字符型
/*
较短的文本：    写法                M的意思                         特点                空间的耗费      效率
char           char(M)          最大的字符数，可以省略，默认为1     固定长度的字符        比较耗费        高
varchar        varchar(M)       最大的字符数，不可以省略            可变长度的字符       比较节省        低

较长的文本：
text
blob（较大的二进制）

枚举（ENUM）：value的值只能取枚举里面的其中一个，不在枚举里面的会报错。不区分大小写

集合（SET）：value的值只能取枚举里面的多个，不在集合里面的会报错。不区分大小写

binary和varbinary用于保存较短的二进制
*/



# 枚举
DROP TABLE IF EXISTS tab_enum;
CREATE TABLE IF NOT EXISTS tab_enum(
    c1 ENUM('a','b','c','d','字符')
);

INSERT INTO tab_enum VALUES('a');
INSERT INTO tab_enum VALUES('b');
INSERT INTO tab_enum VALUES('m');
INSERT INTO tab_enum VALUES('A');
INSERT INTO tab_enum VALUES('字符');
SELECT * FROM tab_enum;


# 集合
DROP TABLE IF EXISTS tab_set;
CREATE TABLE IF NOT EXISTS tab_set(
    c1 SET ('a','b','c','d','字符')
);

INSERT INTO tab_set VALUES('a');
INSERT INTO tab_set VALUES('a,b');
INSERT INTO tab_set VALUES('m');
INSERT INTO tab_set VALUES('A');
INSERT INTO tab_set VALUES('字符');
SELECT * FROM tab_set;



# 日期型
/*
date：只保存日期
datetime：保存日期+时间。支持的时间范围较大。只能反映出插入时的当地时区
timestamp：保存日期+时间。支持的时间范围较小。和实际时区有关，能反映实际的日期
time：只保存时间
year：只保存年

            字节        范围        时区影响
datetime    8        1000-9999      受
timestamp   4        1970-2038      不受
*/

DROP TABLE IF EXISTS tab_date;
CREATE TABLE IF NOT EXISTS tab_date(
    t1 DATETIME ,
    t2 TIMESTAMP 
);

INSERT INTO tab_date VALUES(NOW(),NOW());

SELECT * FROM tab_date;

# 显示时区
SHOW VARIABLES LIKE 'time_zone';

SET time_zone='+9:00';



#------------------------------------------------
# 常见约束
/*
含义：一种限制，用于限制表中的数据，为了保证表中的数据的准确和可靠性

分类：六大约束
    NOT NULL：费控，用于保证该字段的值不能为空
        例如：姓名，学号等
    DEFAULT：默认，用于保证该字段有默认值
        例如：性别
    PRIMARY KEY ：主键，用于保证该字段的值具有唯一性，非空
        例如：学号
    UNIQUE：唯一，用于保证该字段的值具有唯一性，可以为空
        例如：座位号
    CHECK：检查约束【mysql中不支持】
        例如：年龄（检测多少岁到多少岁之间）
    FOREIGN KEY：外检，用于限制两个表的关系。用于保证该字段的值必须来源于主表的关联列的值。
                在从表中添加外键约束，用于引用主表中某列的值

添加约束的时间：
    1. 创建表时
    2. 修改表时

约束的添加分类：
    1. 列级约束：六大约束语法上都支持，但是外键约束没有效果，不能起约束名
    2. 表级约束：除了非空，默认，其他都支持，可以起约束名

允许一个字段有多个约束，以空格分开

主键和唯一的比较：
            保证唯一性      是否允许为空        一个表中可以有多少个        是否允许多个组合
主键            true        false                   1个                     允许，但是不推荐。联合主键（所有组合字段都相同才认为相同）
唯一            true        true                    多个                    允许，但是不推荐（所有组合字段都相同才认为相同）

外键：
    1. 要求在从表设置外键关系
    2. 从表的外键列的类型和主表的关联列类型要求一致或者兼容
    3. 主表的关联列必须是一个key（一般是主键或者唯一）
    4. 插入数据时，先插主表，再插从表
    5. 删除数据时，先删除从表，再删除主表
    
*/


# 一。创建表时添加约束
# 1. 添加列级约束
/*
语法：直接在字段名和类型后面追加约束类型即可
只支持：默认，非空，主键，唯一
*/

CREATE DATABASE students;
USE students;
CREATE TABLE stuinfo(
    id INT PRIMARY KEY , # 主键
    stdName VARCHAR (20) NOT NULL , # 非空
    gender CHAR (1) CHECK(gender='男' or gender='女'), # 检查。实际没效果
    seat INT UNIQUE , # 唯一
    age INT DEFAULT 18 , # 默认
    majorId INT REFERENCES major(id)  #外键。实际没效果
);
DESC stuinfo;

CREATE TABLE major(
    id INT PRIMARY KEY ,
    majorName VARCHAR (20)
);

# 查看所有索引，主键，外检，唯一
SHOW INDEX FROM stuinfo;


# 2. 添加表级约束
/*
语法：在各个字段的最下面
【CONSTRAINT 约束名】 约束类型（字段名）
*/
DROP TABLE IF EXISTS stuinfo;
CREATE TABLE stuinfo(
    id INT , 
    stdName VARCHAR (20) , 
    gender CHAR (1), 
    seat INT  , 
    age INT, 
    majorId INT ,

    CONSTRAINT pk PRIMARY KEY (id), # 主键
    CONSTRAINT uq UNIQUE (seat), # 唯一
    CONSTRAINT fk_stuinfo_major FOREIGN KEY (majorId) REFERENCES major(id) # 外键
);

# 通用写法
CREATE TABLE IF NOT EXISTS stuinfo(
    id INT PRIMARY KEY , # 主键
    stdName VARCHAR (20) NOT NULL , # 非空
    gender CHAR (1) CHECK(gender='男' or gender='女'), # 检查。实际没效果
    seat INT UNIQUE , # 唯一
    age INT DEFAULT 18 , # 默认
    majorId INT ,
    CONSTRAINT fk_stuinfo_major FOREIGN KEY (majorId) REFERENCES major(id) # 外键
);



# 二。修改表时添加约束
/*
1. 添加列级约束
ALTER TABLE 表名 MODIFY COLUMN 字段名 字段类型 约束 ;
2. 添加表级约束
ALTER TABLE 表名 ADD 【CONSTRAINT 约束名】 约束类型 (字段名) 【外键的引用】;

*/
DROP TABLE IF EXISTS stuinfo;
CREATE TABLE stuinfo(
    id INT , 
    stdName VARCHAR (20) , 
    gender CHAR (1), 
    seat INT  , 
    age INT, 
    majorId INT 
);

DESC stuinfo;

# 1. 添加非空约束
ALTER TABLE stuinfo MODIFY COLUMN stdName VARCHAR(20) NOT NULL ;

# 2. 添加默认约束
ALTER TABLE stuinfo MODIFY COLUMN  age INT DEFAULT 18;

# 3. 添加主键
# 列级约束
ALTER TABLE stuinfo MODIFY COLUMN id INT PRIMARY KEY ;
# 表级约束
ALTER TABLE stuinfo ADD PRIMARY KEY (id);

# 4. 添加唯一
# 列级约束
ALTER TABLE stuinfo MODIFY COLUMN seat INT UNIQUE  ;
# 表级约束
ALTER TABLE stuinfo ADD UNIQUE (seat);

# 5. 添加外键
ALTER TABLE stuinfo ADD CONSTRAINT fk_stuinfo_major FOREIGN KEY (majorId) REFERENCES major(id);


# 三。删除约束
# 1.删除非空约束
ALTER TABLE stuinfo MODIFY COLUMN stdName VARCHAR(20) NULL ;

# 2. 删除默认约束
ALTER TABLE stuinfo MODIFY COLUMN  age INT ;

# 3. 删除主键键
ALTER TABLE stuinfo DROP PRIMARY KEY ;

# 4. 删除唯一
ALTER TABLE stuinfo DROP INDEX  seat_2;

# 5. 删除外键
ALTER TABLE stuinfo DROP FOREIGN KEY fk_stuinfo_major;

# 查看所有索引，主键，外检，唯一
SHOW INDEX FROM stuinfo;

# 标识列
/*
又称为自增长列
含义：可以不用手动的插入值，系统提供默认的序列值
特点：
    1. 必须和一个key搭配
    2. 一个表中只能有一个标识列
    3. 类型只能是数值型
    4. auto_increment_increment：步长
    5. auto_increment_offset：起始值
    6. 可以用SET KEY = VALUE修改值
*/

# 一。创建表时设置标识列
DROP TABLE IF EXISTS tab_identity;
CREATE TABLE tab_identity(
    id INT PRIMARY KEY AUTO_INCREMENT ,
    name VARCHAR (20)
);

TRUNCATE TABLE tab_identity;
INSERT INTO tab_identity(name) VALUES('y');
INSERT INTO tab_identity(name) VALUES('s');
INSERT INTO tab_identity(name) VALUES('f');
SELECT * FROM tab_identity;

/*
auto_increment_increment：步长
auto_increment_offset：起始值
*/
SHOW VARIABLES LIKE '%auto_increment%';

# 修改步长
SET auto_increment_increment = 3;

# 二。修改表时设置标识列
DESC tab_identity;
ALTER TABLE tab_identity MODIFY COLUMN id INT AUTO_INCREMENT;

# 三。修改表时删除标识列
ALTER TABLE tab_identity MODIFY COLUMN id INT ;
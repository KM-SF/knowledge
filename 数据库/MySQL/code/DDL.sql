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


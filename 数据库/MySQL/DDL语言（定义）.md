# 库和表的管理
+ 数据定义语言（库和表的管理）
+ **！！！例子查看：[例子查看](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/code/DDL.sql)！！！**

## 库的管理
+ 创建：create
+ 修改：alter
+ 删除：drop

### 库的创建
+ 语法：create database 【IF NOT EXISTS 】 库名;
```
# 创建库Books
CREATE DATABASE Books;

# 判断库存不存在
CREATE DATABASE IF NOT  EXISTS  Books;
```

### 库的修改
+ 修改库名，已经不支持了
```
# RENAME DATABASE Books TO NewBooks;
```

+ 更改库的字符集
```
ALTER DATABASE Books CHARACTER SET gbk;
```

### 库的删除
+ 语法：DROP DATABASE 库名;
```
# 库不存在会报错
DROP DATABASE Books;
# 判断库存不存在
DROP DATABASE IF  EXISTS  Books;
```

### 建库一般流程
1. DROP DATABASE IF EXISTS 旧库名
2. CREATE DATABASE 新库名


## 表的管理
+ 创建：create
+ 修改：alter
+ 删除：drop
+ 复制：create copy

### 表的创建
+ 语法：
```
create table [IF NOT EXISTS] 表名 (   
    列名 列的类型【（长度） 约束】,    
    列名 列的类型【（长度） 约束】,     
    ...                               
    列名 列的类型【（长度） 约束】,      
)
```
+ 例子：
```
# 创建表Book
CREATE TABLE book(
    id INT, #编号
    bName VARCHAR(20), # 书名
    price DOUBLE , # 价格
    authorID INT , # 作者编号
    publishDate DATETIME  # 出版日期
);
DESC book;

# 创建表author
CREATE TABLE author(
    id INT, #编号
    au_name VARCHAR(20), # 姓名
    nation VARCHAR(20)
);
DESC author;
```

### 表的修改
+ 语法：ALTER TABLE 表名 CHANGE|MODIFY|ADD|DROP|(RENAME TO) [COLUMN] 列名 [列类型|约束];

+ 支持：
    1. 修改列名 CHANGE
    2. 修改列的类型或者约束 MODIFY
    3. 添加新列 ADD
    4. 删除列 DROP
    5. 修改表名 RENAME TO

+ 修改列名
```
ALTER TABLE book CHANGE COLUMN publishDate pubDate DATETIME;
```

+ 修改列的类型或者约束
```
ALTER TABLE book MODIFY COLUMN pubDate TIMESTAMP;
```

+ 添加新列
```
ALTER TABLE author ADD COLUMN annual DOUBLE;
```

+ 删除列名
```
ALTER TABLE author DROP COLUMN annual;
```

+ 修改表名
```
ALTER TABLE author RENAME TO book_auther;
```


### 表的删除
```
# 删除表
DROP TABLE book_auther;
# 判断表是否存在
DROP TABLE IF EXISTS book_auther;
SHOW TABLES;
```

### 建表一般流程：
1. DROP TABLE IF EXISTS 旧表名;
2. CREATE TABLE 表名();

## 表的复制
+ 支持：
    1. 仅仅复制表的结构
    2. 复制表的结构+数据
    3. 只复制部分结构
    4. 只复制部分结构和部分数据。所写字段要一样

+ 仅仅复制表的结构
```
CREATE TABLE copy_author LIKE author;
```

+ 复制表的结构+数据
```
CREATE TABLE copy_author_data
SELECT * FROM author;
```

+ 只复制部分结构
```
CREATE TABLE copy_author_some
SELECT id, au_name
FROM author
WHERE 0; # 永远不成立，所以只会复制结构
```

+ 只复制部分结构和部分数据。所写字段要一样
```
CREATE TABLE copy_author_some_data
SELECT id, au_name
FROM author
WHERE nation='中国';
```

# 常见数据类型介绍
+ 数值型：
  + 整型
  + 小数：定点数，浮点数
  + 字符型：
    + 较短的文本：char，varchar
    + 较长的文本：text，blob（二进制数据）
  + 日期型：

+ 所选择的类型越简单越好，能保存数值的类型越小越好


## 整型
+ 分类：tinyint（1），smallint（2），mediumint（3），int（4），bigint（8）
+ 特点：
  1. 如果不设置无符号还是有符号，默认是有符号
  2. 设置有符号需要添加UNSIGNED关键字
  3. 如果插入数值超出了最大范围会报错，无法插入
+ >  图解：![整型](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E6%95%B4%E5%9E%8B.png)

## 小数
+ 分类：
    1. 浮点型：float(M,D)，double(M,D)
    2. 定点数：dec(M,D)，decimal(M,D)
+ 特点：
    1. M代表整数部位+小数部位
    2. D代表小数部位
    3. 如果如果整数不为超过范围（M-D），则插入失败
    4. M和D可以省略
       + 如果decimal，则M默认为10，D默认为0
       + 如果是float和double，会根据插入的数值的精度来决定精度
    5. 定点型精度较高，如果要求插入的数值的精度较高：如货币运算等可以考虑使用

+  图解：![小数](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%B0%8F%E6%95%B0.png)

## 字符型
+ 较短的文本：

  |         | 语法       | M的意思                         | 特点           | 空间的耗费 | 效率 |
  | ------- | ---------- | ------------------------------- | -------------- | ---------- | ---- |
  | char    | char(M)    | 最大的字符数，可以省略，默认为1 | 固定长度的字符 | 比较耗费   | 高   |
  | varchar | varchar(M) | 最大的字符数，不可以省略        | 可变长度的字符 | 比较节省   | 低   |

+ 较长的文本：text，blob（较大的二进制）

+ 枚举（ENUM）：value的值只能取枚举里面的其中一个，不在枚举里面的会报错。不区分大小写

+ 集合（SET）：value的值只能取枚举里面的多个，不在集合里面的会报错。不区分大小写

+ binary和varbinary用于保存较短的二进制

+  图解：![字符型](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E5%AD%97%E7%AC%A6%E5%9E%8B.png)

# 日期型
+ date：只保存日期

+ datetime：保存日期+时间。支持的时间范围较大。只能反映出插入时的当地时区

+ timestamp：保存日期+时间。支持的时间范围较小。和实际时区有关，能反映实际的日期

+ time：只保存时间

+ year：只保存年

  |           | 字节 | 范围      | 时区影响 |
  | --------- | ---- | --------- | -------- |
  | datetime  | 8    | 1000-9999 | 受       |
  | timestamp | 4    | 1970-2038 | 不受     |

+ 显示时区：SHOW VARIABLES LIKE 'time_zone';

+ 设置时区：SET time_zone='+9:00';

+  图解：![日期型](https://github.com/594301947/knowledge/blob/master/%E6%95%B0%E6%8D%AE%E5%BA%93/MySQL/images/%E6%97%A5%E6%9C%9F%E5%9E%8B.png)

# 常见约束
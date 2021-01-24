# 常用数据库命令

#查看当前所有的数据库
SHOW databases;

# 打开执行数据库
use sys;

# 显示所有表
SHOW TABLES ;
SHOW tables FROM mysql;

# 创建数据库
CREATE database test;

# 查看当前所在数据库
select database();

# 创建表
use test;
CREATE TABLE stu_info(
    id INT ,
    name VARCHAR (20) 
);

# 查看表结构
DESC stu_info;
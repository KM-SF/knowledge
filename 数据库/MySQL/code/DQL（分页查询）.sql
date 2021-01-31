# ！！！例子使用的是myemployees.sql的库！！！
# ！！！例子使用的是girls.sql的库！！！

# 分页查询
/*
应用场景：当腰显示的数据，一页显示不全，需要分页提交sql请求
语法：
                                         执行顺序
    select 查询列表                         7
    from 表1 别名                           1
    【连接类型 join 表2 别名                 2
    on 连接条件                             3
    where 筛选条件                          4
    group by 分组字段                       5
    having 分组后的筛选                     6
    order by 排序字段】                     8
    limit offset, size;                    9
    offest：要显示条目的起始索引（起始索引从0开始）
    size：要显示的条目个数

特点：
    1. limit语句放在查询语句的最后
    2. 要显示的页数page，每页的条目数size，offset = (page-1) * size

*/

# 查询前5条员工信息
SELECT * FROM employees LIMIT 0, 5;

# 查询第11-25条
SELECT * FROM employees LIMIT 10,15;

# 查询有奖金的员工信息，并且工资较高的前10名
SELECT *
FROM employees
WHERE commission_pct IS NOT NULL 
ORDER BY salary DESC 
LIMIT 0, 10;
# 字符串String

+ string是redis最基本的类型，是二进制安全的。意味着redis的string可以包含任何数据。比如jpg图片或者序列化的对象
+ 一个redis中字符串value最多可以是512M

# 数据结构

+ string的数据结构是**简单动态字符串**。是可以修改的字符串，内部结构实现类似动态数据，采用预分配冗余空间的方式来减少内存的频繁分配
+ 字符串实际分配的空间capacity一般要高于实际字符串长度len。当字符串长度小于1M时，扩容都是加倍现有的空间，如果超过1M，扩容时一次只会多扩容1M空间。**需要注意的是字符串最大长度为512M**

![简单动态字符串](/数据库/Redis/image/简单动态字符串.png)

# 常用命令

+ set <key> <value>：设置键值对，会覆盖
+ get <key>：查询对应键值
+ append <key> <value>：再原来value基础上进行追加
+ strlen <key>：获得值得长度
+ setnx <key> <value>：只有在key不存在时，才设置value 
+ incr <key>：将key中存储的数字值增1.**只能对数字值操作，如果为空，新增为1**
+ decr <key>：将key中存储的数字值减1.**只能对数字值操作，如果为空，新增为-1**
+ incrby/decrby <key> <step> 将key的数值增加或者减少自定义步长  
+ mset <key1> <value1> <key2> <value2><key3> <value3>：同时设置多个键值对
+ mget <key1><key2><key3>：同时获取多个value
+ msetnx <key1> <value1> <key2> <value2><key3> <value3>：同事设置多个键值对。当且仅当所有key不存在时，才执行成功。原子性操作，有一个失败则都失败
+ getrange <key><start><end>：获取字符串中的子串[start, end]。下标从0开始，下标也可以是负数
+ setrange <key><start><value>：用value覆盖start起始位置的值。下标从0开始
+ setex <key><过期时间><value>：设置键值对的同事，设置过期时间，单位秒
+ getset <key><set>：以新换旧，设置新值同时获得旧值


# 哈希Hash

+ hash是一个键值对的集合
+ hash是一个string类型的field和value的映射表，hash特别适合用于存储对象。

# 数据结构

+ hash类型对应的数据结构有两个：ziplist和hashtable。
+ 当field-value长度较短且数量较少时，使用ziplist，否则使用hashtable

# 常用命令

+ hset <key><field><value>：给集合中的field键赋值value
+ hget <key><field>：从key集合field取出value
+ hmset <key><field><value> <field2><value2>：批量添加
+ hexists <key><filed>：判断key集合中是否有field
+ hkeys <key>：列出key集合所有field
+ hvals <key>：列出key集合所有value
+ hincrby <key><field><increment>：为key集合中的field增加步长
+ hsetnx <key><field><value>：将key集合中的field的值为value，当且仅当field不存在才设置 


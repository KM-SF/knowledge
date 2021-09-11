# 无序集合Set

+ set对外提供的功能与list类似是一个列表的功能。但是set可以**自动去重**。
+ set提供了判断某个成员在不在集合中的重要接口，list不能提供
+ set是string类型的无序集合。他底层其实是一个value为null的hash表。所以添加，删除，查找复杂度都为O(1)

# 数据结构

+ set数据结构是dict字典，字典是用hash表实现的

# 常用命令

+ sadd <key><value1><value2>：将多个member元素添加到集合中。已经存在的元素会忽略
+ smember <key>：取出该集合的所有值
+ sismember <key><value>：判断集合中是否包含该元素。有1，没有0
+ scard <key>：返回该集合的元素个数
+ srem <key><value1><value2><value3>：删除集合中元素
+ spop <key>：**随机从该集合中吐出一个值**
+ srandmember <key><n>：随机从集合从取出N个元素，不会从集合中删除
+ smove <source> <des> <value>：把一个集合中的一个值移动到另外一个集合中  
+ sinter <key1> <key2>：返回两个集合的交集元素
+ sunion <key1> <key2>：返回两个集合的并集元素
+ sdiff <key1><key2>：返回两个集合的差集（key1中，不包含key2）


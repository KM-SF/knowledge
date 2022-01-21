# 列表List

+ 单键多值
+ redis的列表是简单的字符串列表，按照插入的顺序排序。可以头插（左边）或则尾插（右边）
+ 他底层实际是一个双向链表，对双端的操作性能很高，通过索引下表操作中间节点性能较差

# 数据结构

+ List的数据结构为压缩列表（ziplist）和快速链表（quicklist）
+ 首先在列表元素较少的情况下会使用一块连续的内存存储，这个结构是压缩列表（ziplist）
+ 它将所有的元素挨着一起存储，分配的是一块连续的内存，当数据量比较多的时候才会变成快速列表（quicklist）
+ 因为普通的链表需要附带指针空间，会比较浪费空间。redis将链表和ziplist结合起来组成了quicklist。也就是将多个ziplist使用双指针串起来使用。这样满足了快速的插入删除性能，也不会出现太大的空间冗余

# 常用命令

+ lpush/rpush <key><value1><value2><value3>：从左边/右边插入元素
+ lpop/rpop <key> [count] 从左边/右边吐出一个值。值在健在，值光键亡
+  rpoplpush <key1><key2>：从<key1>列表右边吐出一个值，插到<key2>列表左边
+ lrange <key><start><end>：按照索引下表获取元素（从左到右）
+ lindex <key><index>：按照索引下标获得元素（从左到右）
+ llen <key>：获得列表长度
+ linsert <key> befor|after <value> <newvalue>：在<value>前面或者后面插入一个newvalue
+ lrem <key><n><value>：从删除n个value。n==0，删除全部。n>0，从左往右删除。n<0，从右往左删除
+ lset<key><index><value>：将列表key下标为index的值替换成value
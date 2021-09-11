# 有序集合Zset

+ 有序集合zset是一个无重复元素的字符串集合，且自动排序
+ 每个元素都关联了一个socre。这个score被用来按照从低到高排序
+ 集合的成员是唯一的，但是socre是可以重复的
+ 因为元素是有序的，所以可以根据score或者position来获取一个范围的元素
+ 访问有序集合的中间元素也非常快

# 数据结构

+ zset底层使用了两个数据结构
  + hash：作用就是关联元素value和权重score。保证元素value的唯一性，可以通过元素value找到响应的score值
  + 跳跃表：给元素value排序，根据socre的范围获取元素列表

# 常用命令

+ zadd <key><score1><value1><score2><value2>：将元素添加到有序集合中
+ zrang <key><start><end> [witchscores] ：返回有序集合中start到end的结果。带了withscores，则scores一起返回。
+ zrangebyscore <key> <min> <max> [withscores] [limit offset count]：返回有序集合key中，所有score值介于min-max之间的（包含）。 **按照小到大排序**
+ z**rev**rangebyscore <key> <min> <max> [withscores] [limit offset count]：跟上面一样。只是按照大到小排序
+ zincrby <key> <increment> <value>：为元素的score增加
+ zrem <key> <value>：删除该集合下，指定值得元素
+ zcount <key> <min> <max>：统计区间内的元素个数
+ zrank <key> <value>：查看排名，从0开始


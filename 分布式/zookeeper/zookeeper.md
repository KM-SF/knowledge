# Zookeeper

+ 他是一个分布式服务框架，是Apache Hadoop的一个子项目，它主要用来解决分布式应用中经常遇到的一些数据管理问题。如：集群管理，分布式应用配置项的管理
+ 他是一个数据库：（可以理解成数据库）
  + 拥有文件系统特点的数据库
  + **解决数据一致性问题的分布式数据库**
  + 具有发布和订阅功能的分布式数据库
+ Zookeeper其实是最终一致性：节点A在某一时刻读到的数据可以是旧的，但是后续会自动更新到最新值。

# ZAB协议

+ 领导：所有的请求都由一个leader提出
+ 过半机制：只有投票同意个数过半才能同意请求
+ 2PC：两阶段提交
  + prepare，预提交
  + 等待ack
  + commit
+ 同步信息：同步每个节点的信息一致

# 请求处理

+ 单主机处理请求过程：
  + 日志持久化磁盘（操作写到磁盘，只有事务性请求才需要）
  + 数据更新内存中的值（DateTree）
  + 数据持久化到磁盘
+ 集群处理请求过程：
  + leader节点将日志持久化
  + leader节点预提交（将日志持久化的操作发给其他节点）（2PC的预提交阶段）
  + 其他节点日志持久化成功后，回一个ack（2PC的ack阶段）
  + leader收到ack个数超过一半之后，提交commit给其他节点。（将数据更新到内存，数据持久化）（2PC的commit阶段）
  + leader收到ack个数超过一半之后，本主机执行commit。（将数据更新到内存，数据持久化）

+ 事务性请求：create,set,delete
+ 非事务性请求：get，exist
+ 日志持久化：有一个zxid表示当前日志的id。保存操作到磁盘

# 选举机制（投票）

+ 选举过程：
  1. 投票开始
  2. 先临时投给自己
  3. 跟别人进行交流
  4. 比较后，选出更厉害的人
  5. 将票投入到投票箱
  6. 统计下每个主机的投票个数（过半则票数有效）
  7. 投票结束

+ 选择更厉害的人的方法：
  + 通过日志持久化的zxid，判断每个主机的zxid的大小。选出最大的
  + 如果日志zxid相同的话，就再通过每个主机myid，再从myid中选择最大的

+ 选举时机：
  + 集群启动
  + leader挂了
  + follower挂掉后，leader发现已经没有过半的follower跟随自己了。不能对外提供服务（领导者选举）

# ZooKeeper分布式锁的优点和缺点

https://www.cnblogs.com/crazymakercircle/p/14504520.html

总结一下ZooKeeper分布式锁：

（1）优点：ZooKeeper分布式锁（如InterProcessMutex），能有效的解决分布式问题，不可重入问题，使用起来也较为简单。

（2）缺点：ZooKeeper实现的分布式锁，性能并不太高。为啥呢？
因为每次在创建锁和释放锁的过程中，都要动态创建、销毁瞬时节点来实现锁功能。大家知道，ZK中创建和删除节点只能通过Leader服务器来执行，然后Leader服务器还需要将数据同不到所有的Follower机器上，这样频繁的网络通信，性能的短板是非常突出的。

总之，在高性能，高并发的场景下，不建议使用ZooKeeper的分布式锁。而由于ZooKeeper的高可用特性，所以在并发量不是太高的场景，推荐使用ZooKeeper的分布式锁。

在目前分布式锁实现方案中，比较成熟、主流的方案有两种：

（1）基于Redis的分布式锁

（2）基于ZooKeeper的分布式锁

两种锁，分别适用的场景为：

（1）基于ZooKeeper的分布式锁，适用于高可靠（高可用）而并发量不是太大的场景；

（2）基于Redis的分布式锁，适用于并发量很大、性能要求很高的、而可靠性问题可以通过其他方案去弥补的场景。
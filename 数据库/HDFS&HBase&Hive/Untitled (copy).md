# 一. Hbase

**HBase是一个分布式的、面向列的开源数据库**，Hbase是Hadoop database即Hadoop数据库。HBase的数据通常存储在HDFS上。HDFS为HBase提供了高可靠性的底层存储支持。不过HBase 本身其实可以完全不要考虑 HDFS 的，你完全可以只把 HBase 当作是一个分布式高并发 k-v 存储系统，只不过它底层的文件系统是通过 HDFS 来支持的罢了。换做其他的分布式文件系统也是一样的，不影响 HBase 的本质。甚至如果你不考虑文件系统的分布式或稳定性等特性的话，完全可以用简单的本地文件系统，甚至内存文件系统来代替。Hbase非常适合用来进行大数据的实时查询。Facebook用Hbase进行消息和实时的分析。它也可以用来统计Facebook的连接数。

# 二. Hdfs

**HDFS是Hadoop分布式文件系统**。一个HDFS集群是由一个NameNode和若干个DataNode组成的。其中NameNode作为主服务器，管理文件系统的命名空间和客户端对文件的访问操作；集群中的DataNode管理存储的数据。

# 三. Hive

Hive是基于Hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张数据库表，并提供简单的sql查询功能，可以将sql语句转换为MapReduce任务进行运行。Hive帮助熟悉SQL的人运行MapReduce任务。因为它是JDBC兼容的，同时，它也能够和现存的SQL工具整合在一起。运行Hive查询会花费很长时间，因为它会默认遍历表中所有的数据。虽然有这样的缺点，一次遍历的数据量可以通过Hive的分区机制来控制，另外Hive目前不支持更新操作。Hive适合用来对一段时间内的数据进行分析查询，Hive不应该用来进行实时的查询。因为它需要很长时间才可以返回结果。hive可以用来进行统计查询，HBase可以用来进行实时查询，数据也可以从Hive写到Hbase，设置再从Hbase写回Hive。





原文链接：https://blog.csdn.net/weixin_43861118/article/details/106746952
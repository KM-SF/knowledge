# MVCC

+ 全称：Multi-Version-Concurrency Control，即多版本并发控制
+ 作用：为了解决并发情况下读写数据问题，提高数据库的并发性能
+ 同一行数据平时发生读写请求时，会加上锁阻塞，但是MVCC用更好的方式去处理读写请求，做到发生读写请求冲突时，不用加锁
+ 这个读是指快照读，而不是当前读，当前读是一种加锁操作，是悲观锁
+ MVCC是由：版本链和readview（读视图）组成。新数据的是否可见要看readview的创建时机

# 当前读/快照读

### 当前读

+ 它读取的数据库记录，都是当前最新版本，会对当前读取的数据进行加锁，防止其他事物修改数据，是一种悲观的操作
+ 以下操作都是当前读
  + select lock in share mode（共享锁）
  + select for update（排它锁）
  + update，insert，delete（排它锁）
  + 串行化事物隔离级别

### 快照读

+ 快照读的实现是基于MVCC实现的。所以快照读读到的数据不一定是当前最新的数据，有可能是之前历史版本的数据
+ 以下是快照读
  + 不加锁的select操作（注：事物级别不是串行化）

## 版本链

+ 版本连由事务ID（自增）+回滚指针组成。是同一行数据的不同时段的修改值（undo log）
+ 事务ID：创建或者最后一次修改记录的事务ID
+ 回滚指针指向的是：上一次被修改的数据的地址（上一个历史版本）

![MVCC](/数据库/MySQL/images/MVCC.png)

 ## ReadView（读视图）

+ ReadView作用：让你知道该行数据的版本链情况，让你知道可以选择哪个历史版本
+ ReadView数据结构
  + m_ids：表示生成ReadView时当前系统中**活跃（已经commit）**的读写事务的**事务id列表**
  + min_trx_id：表示在生成ReadView时当前系统中活跃（已经commit）的读写事务中**最小的事务id**，也就是m_ids中的最小值
  + max_trx_id：表示生成ReadView时系统中应该**分配给下一个事务的id值**
  + creator_trx_id：表示生成该ReadView的事务的事务id
+ 如何判断版本链中哪个版本可用
  + trx_id == creator_trx_id：可以访问这个版本。这个事务跟当前事务id一样
  + trx_id < min_trx_id：可以访问这个版本。小于min则之前的都是已经commit的事务
  + trx_id > max_trx_id：不可用访问这个版本。大于max则该事务还没存在
  + min_trx_id < trx_id < max_trx_id：如果trx_id在m_ids中是不可以访问的这个版本，反之亦然
+ ReadView生成的时机
  + 在RC（读已提交）：**每次**在进行**快照读**的时候都会生成新的ReadView
  + 在RR（可重复读）：只有在**第一次**进行的**快照读**的时候才会生成ReadView，之后的读操作都是会用第一次生成的ReadView。但是当执行了当前读时，会更新readview

# 事务和事务处理
+ **！！！例子查看：[例子查看](/数据库/MySQL/code/TCL.sql)！！！**

+ 事务：一个或一组sql语句组成的一个执行单元，这个执行单元要么全部执行，要么全部不执行

+ 特点：
    1. 整个单独单元作为一个不可分割的整体。
    2. 如果单元中某条sql语句一旦执行失败或者产生错误，那么整个单元会回滚。所有受到影响的数据将返回到事务最开始的状态
    3. 如果单元中的所有SQL语句执行成功，则事务被顺利执行
    
+ 在mysql中存储引擎有：innodb,myisam,memory等。**其中innodb支持事务**，而myisam，memory等不支持

+ 事务的ACID属性：
    1. 原子性（Atomicity）：指事务是不可分割的工作单元，事务中的操作要么都执行，要么都不执行
    2. 一致性（Consistency）：事务必须使数据库从一个一致性状态转换成另外一个一致性状态
    3. 隔离性（Isolation）：指一个事务的执行不能被其他事务干扰，即一个事务内部的操作及使用的数据对并发的其他事务是隔离的。并发执行的各个事务之间不能互相干扰
    4. 持久性（Durability）：指一个事务一旦被提交，他对数据库中数据的改变就是永久性的，接下来的其他操作和数据库故障都不应该对其有任何影响

+ 事务的创建：
    1. 隐式事务：事务没有明显的开启和结束的标记。比如：insert，update，delete语句
    2. 显示事务：事务具有明显的开启和结束的标记。
    
+ 语法：(显示事务)
    1. 必须先设置自动提交功能为禁止（因为这个默认开启，一条语句就是一个事务）：
        set autocommit=0;（只针对当前的事务）
    2. 开启事务的语句：
        start transaction;（可选）
    3. 编写事务的SQL语句（select，insert，update，delete）<br>
        语句1<br>
        语句2<br>
        。。。<br>
        语句n<br>
    4. 结束事务的语句：
        commit;（提交事务）
        rollback;（回滚事务）

+ 对于同时运行多个事务，当这个事务访问数据库中相同数据时，如果没有采取必要隔离机制，会导致各种并发问题
    1. 脏读：对于两个事务T1,T2。T1读取了已经被T2更新但是还没有提交的字段之后。若T2回滚，T1读取的内容就是临时且无效的
    2. 不可重复读：对于两个事务T1,T2。T1读取了一个字段，然后T2更新了该字段之后，T1再次读取同一个字段，值就不同了
    3. 幻读：对于两个事务T1,T2。T1从一个表中读取一个字段，然后T2在该表中插入了一些新的行之后。如果T1再次读取同一个表，会出现多了几行。

+ 数据库事务的隔离性：数据库系统必须具有隔离并发运行各个事务的能力，使他们不会互相影响，避免各种并发问题

+ 一个事务与其他事务隔离的程度称为隔离级别。数据库规定了多种事务隔离级别，不同隔离级别对应不同的干扰程度，隔离级别越高，数据一致性就越好，但是并发性越弱
    1. READ UNCOMMITTED（读未提交数据）：允许事务读取未被其他事务提交的变更。脏读，不可重复读和幻读的问题都会出现
    2. READ COMMITTED（读已提交数据）：只允许事务读取已经被其他事务提交的变更。可避免脏读，但是不可重复读和幻读问题仍然存在
    3. REPEATABLE READ（可重复读）：确保事务可以多次从一个字段中读取相同值。在这个事务持续期间，禁止其他事务对该字段进行更新。避免脏读和不可重复读。幻读还存在
    4. SERIALIZABLE（串行化）：确保事务可以从一个表中读取相同的行。在该事务持续期间，禁止其他事务对该表执行插入，更新和删除操作。并发问题都解决，但是性能低下

+ Oracle支持2中事务隔离级别：READ COMMITTED,SERIALIZABLE。默认是READ COMMITTED

+ Mysql支持4中事务隔离级别：默认是REPEATABLE READ

+ 语法：
  > + 必须先设置自动提交功能为禁止：set autocommit=0;（只针对当前的事务）
  > + 显示自动提交值：SHOW VARIABLES LIKE 'autocommit';
  > + 显示隔离级别：SELECT @@transaction_isolation;
  > + 设置隔离级别：SET SESSION TRANSACTION ISOLATION LEVEL 隔离级别;
  > + 设置数据库系统的全局隔离级别：SET GLOBAL TRANSACTION ISOLATION LEVEL 隔离级别;
  > + 设置回滚节点：SAVEPOINT 节点名;
  > + 显示存储引擎：SHOW ENGINES;
  
+ 隔离级别比较：

    |                                  | 脏读  | 不可重复读 | 幻读  |
    | -------------------------------- | ----- | ---------- | ----- |
    | READ UNCOMMITTED（读未提交数据） | true  | true       | true  |
    | READ COMMITTED（读已提交数据）   | false | true       | true  |
    | REPEATABLE READ（可重复读）      | false | false      | true  |
    | SERIALIZABLE（串行化）           | false | false      | false |

    


## 事务步骤：
```
#开启事务
SET AUTOCOMMIT=0;
START TRANSACTION;
# 编辑sql语句
UPDATE account SET balance=500 WHERE username='张无忌';
UPDATE account SET balance=1500 WHERE username='赵敏';
# 结束事务
COMMIT;
#ROLLBACK;

SELECT * FROM account;
```

## savepoint使用
```
SET AUTOCOMMIT=0;
START TRANSACTION;
DELETE FROM account WHERE id=1;
SAVEPOINT a;
DELETE FROM account WHERE id=2;
ROLLBACK TO a;
```

## 事务原理

+ **原子性：undo log实现**

+ **持久性：redo log实现**

+ **隔离性：加锁和MVCC**

+ **一致性：基于原子性，隔离性和持久性完成**

### 持久性（两阶段提交）

+ 两阶段提交（WAL write ahead log）：先写日志再写数据
+ mysql中的binlog（数据文件）和innodb中的redolog（日志文件），因为两个文件属于不同的组件，所以为了保证数据的一致性，要保证binlog和redolog一致性，所以有了两阶段提交

+ 因为随机读写的效率要低于顺序读写的效率。而写数据的是通过随机读写，写日志是顺序读写。所以为了保证数据的一致性，可以先将数据操作形式通过顺序读写写到日志文件中，然后再将数据写到对应的磁盘文件中。这个过程顺序的效率要远远高于随机的效率
+ 如果实际的数据没有写到磁盘（断电，故障等等），只要日志文件保存成功了，那么数据就不会丢失，可以根据日志来进行数据的回复
+ 数据更新流程
  1. 执行器先从引擎中找到数据，如果在内存中则直接返回，如果不再内存中，查询后返回
  2. 执行器拿到数据后，先修改数据，然后调用引擎接口重新写入数据
  3. 引擎将数据更新到内存，同是写数据到redo中，此时处于prepare阶段，并通知执行器执行完成，随时可以操作
  4. 执行器生成这个操作的binlog
  5. 执行器调用引擎的事务提交接口，引擎把刚刚写完的redo改成commit状态，更新完成

![两阶段提交](/数据库/MySQL/images/两阶段提交.png)
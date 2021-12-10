# 一. Kafka介绍

Kafka是最初由Linkedin公司开发，是⼀个分布式、⽀持分区的（partition）、多副本的（replica），基于zookeeper（最新版已经不需要）协调的分布式消息系统，它的最⼤的特性就是可以实时的处理⼤量数据以满⾜各种需求场景。

## Kafka的使用场景

1. 日志收集：可以用kafka收集各种服务的log。通过kafka以统一接口服务的方式开放给各种consumer。
2. 消息系统：解耦生产者和消费者，缓存消息等
3. 用户活动跟踪：kafka经常被用来记录web用户和app用户的各种活动，如浏览网页，搜索，点击等活动。这些活动信息被各种服务器发布到kafka的topic重。然后订阅者通过订阅这些topic来做实时的监控分析
4. 运营指标：kafka也经常用来记录运营监控数据。包括收集各种分布式应用数据，生产各种操作的集中反馈，例如：告警和报告

## Kafka基本概念

+ kafka是一个分布式的，分区的消息（官方称为commit log）服务。它提供一个消息系统应该具备的功能，但是确有独特的设计。
+ 基础的消息相关术语：

| 名称          | 解释                                                         |
| ------------- | ------------------------------------------------------------ |
| Broker        | 消息中间件处理阶节点，一个kafka节点就是一个broker，一个或者多个broker可以组成一个kafka集群 |
| Topic         | kafka根据topic对消息进行归类，发布到kafka集群的每条消息都需要指定一个topic |
| Producer      | 消息生产者，向Broker发送消息的客户端                         |
| Consumer      | 消息消费者，从Broker读取消息的客户端                         |
| ConsumerGroup | 每个consumer术语一个特定的ConsumerGroup，一个消息可以被多个不同的Consumer Group消费。但是一个Consumer Group只能有一个Consumer能够消费该消息 |
| partition     | 物理上的概念，一个topic可以分为多个partition，每个partition内部消息是有序的 |

+ 因此从更高层面上来看，producer通过网络发送消息到kafka集群，然后Consumer桶kafka集群获取消息进行消费
+ 服务端(brokers)和客户端(producer、consumer)之间通信通过TCP协议来完成

![架构图](\消息队列\images\架构图.png)

# 二. Kafka基本使用

### 1. 启动

+ 修改配置文件：/usr/local/kafka/kafka2.11-2.4/config/server.properties

  ```bash
  #broker.id属性在kafka集群中必须要是唯⼀
  broker.id=0
  #kafka部署的机器ip和提供服务的端⼝号
  listeners=PLAINTEXT://192.168.65.60:9092
  #kafka的消息存储⽂件
  log.dir=/usr/local/data/kafka-logs
  #kafka连接zookeeper的地址
  zookeeper.connect=192.168.65.60:2181
  ```

  

+ 进⼊到bin⽬录下。使⽤命令来启动

  ```bash
  ./kafka-server-start.sh -daemon ../config/server.properties
  ```

### 2. server.properties核⼼配置详解

| Property                   | Default                        | Description                                                  |
| -------------------------- | ------------------------------ | ------------------------------------------------------------ |
| broker.id                  | 0                              | 每个broker都可以⽤⼀个唯⼀的⾮负整数id进⾏标<br/>识；这个id可以作为broker的“名字”，你可以选择任<br/>意你喜欢的数字作为id，只要id是唯⼀的即可。 |
| log.dirs                   | /tmp/kafka-logs                | kafka存放数据的路径。这个路径并不是唯⼀的，可<br/>以是多个，路径之间只需要使⽤逗号分隔即可；每<br/>当创建新partition时，都会选择在包含最少<br/>partitions的路径下进⾏。 |
| listeners                  | PLAINTEXT://192.168.65.60:9092 | server接受客户端连接的端⼝，ip配置kafka本机ip<br/>即可       |
| zookeeper.connect          | localhost:2181                 | zooKeeper连接字符串的格式为：<br/>hostname:port，此处hostname和port分别是<br/>ZooKeeper集群中某个节点的host和port；<br/>zookeeper如果是集群，连接⽅式为<br/>hostname1:port1, hostname2:port2,<br/>hostname3:port3 |
| log.retention.hours        | 168                            | 每个⽇志⽂件删除之前保存的时间。默认数据保存<br/>时间对所有topic都⼀样。 |
| num.partitions             | 1                              | 创建topic的默认分区数                                        |
| default.replication.factor | 1                              | ⾃动创建topic的默认副本数量，建议设置为⼤于等<br/>于2        |

## 3. 创建主题topic

+ topic：可以实现消息的分类，不同消费者订阅不同的topic。

![topic](\消息队列\images\topic.png)

+ 执⾏以下命令创建名为“test”的topic，这个topic只有⼀个partition，并且备份因⼦也设置为1：

  ```bash
  ./kafka-topics.sh --create --zookeeper 172.16.253.35:2181 --replication-factor 1 --partitions 1 --topic test
  ```

+ 查看当前kafka内有哪些topic

  ```bash
  ./kafka-topics.sh --list --zookeeper 172.16.253.35:2181
  ```

## 4. 发送消息

+ kafka⾃带了⼀个producer命令客户端，可以从本地⽂件中读取内容，或者我们也可以以命令⾏中直接输⼊内容，并将这些内容以消息的形式发送到kafka集群中。在默认情况下，每⼀个⾏会被当做成⼀个独⽴的消息。使⽤kafka的发送消息的客户端，指定发送到的kafka服务器地址和topic

  ```bash
  # 启动客户端
  ./kafka-console-producer.sh --broker-list 172.16.253.38:9092 --topic test
  ```

## 5. 发送消息

+ 对于consumer，kafka同样也携带了⼀个命令⾏客户端，会将获取到内容在命令中进⾏输出，默认是消费最新的消息。使⽤kafka的消费者消息的客户端，从指定kafka服务器的指定topic中消费消息

  + ⽅式⼀：从最后⼀条消息的偏移量+1开始消费

  ```bash
  ./kafka-console-consumer.sh --bootstrap-server 172.16.253.38:9092 --topic test
  ```

  + 方法二：从头开始消费

  ```bash
  ./kafka-console-consumer.sh --bootstrap-server 172.16.253.38:9092 --from-beginning --topic test
  ```

+ 注意点：
  + 消息会被存储
  + 消息是顺序存储
  + 消息是有偏移量的
  + 消费时可以指明偏移量进⾏消费

# 三. Kafka中关键细节

## 1. 消息的顺序存储

消息的发送⽅会把消息发送到broker中，broker会存储消息，消息是按照发送的顺序进⾏存储。因此消费者在消费消息时可以指明主题中消息的偏移量。默认情况下，是从最后⼀个消息的下⼀个偏移量开始消费。

## 2. 单播消息的实现

单播消息：⼀个消费组⾥ 只会有⼀个消费者能消费到某⼀个topic中的消息。于是可以创建多个消费者，这些消费者在同⼀个消费组中。

```bash
./kafka-console-consumer.sh --bootstrap-server 10.31.167.10:9092 --consumer-property group.id=testGroup --topic test
```

## 3. 多播消息的实现

在⼀些业务场景中需要让⼀条消息被多个消费者消费，那么就可以使⽤多播模式。kafka实现多播，只需要让不同的消费者处于不同的消费组即可。

```bash
./kafka-console-consumer.sh --bootstrap-server 10.31.167.10:9092 --consumer-property group.id=testGroup1 --topic test
./kafka-console-consumer.sh --bootstrap-server 10.31.167.10:9092 --consumer-property group.id=testGroup2 --topic test
```

## 4. 查看消费组及信息

![消费组信息](\消息队列\images\消费组信息.png)

```bash
# 查看当前主题下有哪些消费组
./kafka-consumer-groups.sh --bootstrap-server 10.31.167.10:9092 --list
# 查看消费组中的具体信息：⽐如当前偏移量、最后⼀条消息的偏移量、堆积的消息数量
./kafka-consumer-groups.sh --bootstrap-server 172.16.253.38:9092 --describe --group testGroup
```

+ Currennt-offset: 当前消费组的已消费偏移量
+ Log-end-offset: 主题对应分区消息的结束偏移量(HW)
+ Lag: 当前消费组未消费的消息数

# 四. 主题，分区

## 1.主题Topic

主题Topic可以理解成是⼀个类别的名称，用来区分不同消息类型

## 2.partition分区

![partition](\消息队列\images\partition.png)

+ ⼀个主题中的消息量是⾮常⼤的，因此可以通过分区的设置，来分布式存储这些消息。⽐如⼀个topic创建了3个分区。那么topic中的消息就会分别存放在这三个分区中。

+ 为⼀个主题创建多个分区

  ```bash
  ./kafka-topics.sh --create --zookeeper localhost:2181 --partitions 2 --topic test1
  ```

+ 可以通过这样的命令查看topic的分区信息

  ```bash
  ./kafka-topics.sh --describe --zookeeper localhost:2181 --topic test1
  ```

+ 分区作用：

  + 可以分布式存储，可以解决统⼀存储⽂件过⼤的问题
  + 可以并⾏写
  + 提供了读写的吞吐量：读和写可以同时在多个分区中进⾏

+ 实际上是存在data/kafka-logs/test-0 和 test-1中的0000000.log⽂件中

+ 小细节：

  + 定期将⾃⼰消费分区的offset提交给kafka内部topic：__consumer_offsets，提交过去的
    时候，key是consumerGroupId+topic+分区号，value就是当前offset的值，kafka会定
    期清理topic⾥的消息，最后就保留最新的那条数据__
  + 因为consumer_offsets可能会接收⾼并发的请求，kafka默认给其分配50个分区(可以
    通过offsets.topic.num.partitions设置)，这样可以通过加机器的⽅式抗⼤并发。

# 五. kafka集群及副本

## 1. 搭建kafka集群，3个Broker

准备3个server.properties⽂件每个⽂件中的这些内容要调整

+ server.properties

  ```bash
  broker.id=0
  listeners=PLAINTEXT://192.168.65.60:9092
  log.dir=/usr/local/data/kafka-logs
  ```

+ server1.properties

  ```bash
  broker.id=1
  listeners=PLAINTEXT://192.168.65.60:9093
  log.dir=/usr/local/data/kafka-logs-1
  ```

+ server2.properties

  ```bash
  broker.id=2
  listeners=PLAINTEXT://192.168.65.60:9094
  log.dir=/usr/local/data/kafka-logs-2
  ```

+ 使⽤如下命令来启动3台服务器

  ```bash
  ./kafka-server-start.sh -daemon ../config/server0.properties
  ./kafka-server-start.sh -daemon ../config/server1.properties
  ./kafka-server-start.sh -daemon ../config/server2.properties
  ```

## 2. 副本

+ 副本是对分区的备份。在集群中，不同的副本会被部署在不同的broker上。下⾯例⼦：创建1个主题，2个分区、3个副本。

```bash
./kafka-topics.sh --create --zookeeper 172.16.253.35:2181 --replication-factor 3 --partitions 2 --topic my-replicated-topic
```

```bash
./kafka-topics.sh --describe --zookeeper 172.16.253.35:2181 --topic my-replicated-topic
```

![副本](\消息队列\images\副本.png)

+ replicas：当前副本存在的broker节点
+ leader：副本⾥的概念每个partition都有⼀个broker作为leader。**消息发送⽅要把消息发给哪个broker？就看副本的leader是在哪个broker上⾯。副本⾥的leader专⻔⽤来接收消息。接收到消息，其他follower通过poll的⽅式来同步数据。**

+ follower：leader处理所有针对这个partition的读写请求，**⽽follower被动复制leader，不提供读写（主要是为了保证多副本数据与消费的⼀致性），如果leader所在的broker挂掉，那么就会进⾏新leader的选举**
+ isr：可以同步的broker节点和已同步的broker节点，存放在isr集合中。

## 3. broker、主题、分区、副本

+ kafka集群中由多个broker组成
+ ⼀个broker中存放⼀个topic的不同partition——副本

![架构图](\消息队列\images\架构图.png)

## 4. kafka集群消息的发送

```bash
./kafka-console-producer.sh --broker-list 172.16.253.38:9092,172.16.253.38:9093,172.16.253.38:9094 --topic my-replicated-topic
```

## 5. kafka集群消息的消费

```bash
./kafka-console-consumer.sh --bootstrap-server 172.16.253.38:9092,172.16.253.38:9093,172.16.253.38:9094 --from-beginning --topic my-replicated-topic
```

## 6. 关于分区消费组消费者的细节

![消费组细节](\消息队列\images\消费组细节.png)

图中Kafka集群：

+ 有两个broker，每个broker中有多个partition。
+ ⼀个partition只能被⼀个消费组⾥的某⼀个消费者消费，从⽽保证消费顺序。
+ **Kafka只在partition的范围内保证消息消费的局部顺序性，不能在同⼀个topic中的多个partition中保证总的消费顺序性。**
+ ⼀个消费者可以消费多个partition。**消费组中消费者的数量不能⽐⼀个topic中的partition数量多，否则多出来的消费者消费不到消息。**

# 六. 生产者

## 1. 同步发送

如果⽣产者发送消息没有收到ack，⽣产者会阻塞，阻塞到3s的时间，如果还没有收到消息，会进⾏重试。重试的次数3次。

## 2. 异步发送

⽣产者发消息，发送完后不⽤等待broker给回复，直接执⾏下⾯的业务逻辑。可以提供callback，让broker异步的调⽤callback，告知⽣产者，消息发送的结果

## 3. 关于⽣产者的ack参数配置

在同步发消息的场景下：⽣产者发动broker上后，ack会有3种不同的选择：

1. **acks=0**： 表示producer不需要等待任何broker确认收到消息的回复，就可以继续发送下⼀条消息。**性能最⾼，但是最容易丢消息**。
2. **acks=1**： **⾄少要等待leader已经成功将数据写⼊本地log，但是不需要等待所有follower是否成功写⼊。**就可以继续发送下⼀条消息。这种情况下，如果follower没有成功备份数据，⽽此时leader⼜挂掉，则消息会丢失。
3. **acks=-1或all**： **需要等待 min.insync.replicas(默认为1，推荐配置⼤于等于2) **。这个参数配置的副本个数都成功写⼊⽇志，这种策略会保证只要有⼀个备份存活就不会丢失数据。这是最强的数据保证。⼀般除⾮是⾦融级别，或跟钱打交道的场景才会使⽤这种配置。

## 4. 消费发送缓冲区

![发送缓冲区](\消息队列\images\生产者发送缓冲区.png)

+ **发送的消息会先进⼊到本地缓冲区（32mb），kakfa会跑⼀个线程，该线程去缓冲区中取16k的数据，发送到kafka，如果到10毫秒数据没取满16k，也会发送⼀次。**

+ kafka默认会创建⼀个消息缓冲区，⽤来存放要发送的消息，缓冲区是32m

  ```java
  props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 33554432);
  ```

+ kafka本地线程会去缓冲区中⼀次拉16k的数据，发送到broker

  ```java
  props.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);
  ```

+ 如果线程拉不到16k的数据，间隔10ms也会将已拉到的数据发到broker

  ```java
  props.put(ProducerConfig.LINGER_MS_CONFIG, 10);
  ```

# 七. 消费者

## 1. offset

+ 消费者⽆论是⾃动提交还是⼿动提交，都需要把所属的消费组+消费的某个主题+消费的某个分区及消费的偏移量，这样的信息提交到集群_consumer_offsets主题⾥⾯。

+ 默认自动提交offset。****

  ```java
  // 是否⾃动提交offset，默认就是true
  props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");
  // ⾃动提交offset的间隔时间
  props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, "1000");
  ```

  消费者poll到消息后默认情况下，会⾃动向broker的_consumer_offsets主题提交当前主题-分区消费的偏移量。

+ **⾃动提交会丢消息**：因为如果消费者还没消费完poll下来的消息就⾃动提交了偏移量，那么此时消费者挂了，于是下⼀个消费者会从已提交的offset的下⼀个位置开始消费消息。之前未被消费的消息就丢失掉了。

+ 也可以设置手动提交（同步提交和异步提交）：
  + ⼿动同步提交offset，当前线程会阻塞直到offset提交成功
  + 异步提交offset，当前线程提交offset不会阻塞，可以继续处理后⾯的程序逻辑

## 2. 消费者poll消息的过程

+ 消费者建⽴了与broker之间的⻓连接，开始poll消息。

+ 默认⼀次poll500条消息

  ```java
  props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 500);
  ```

+ 可以根据消费速度的快慢来设置，**因为如果两次poll的时间如果超出了30s的时间间隔，kafka会认为其消费能⼒过弱，触发rebalance机制，将其踢出消费组。将分区分配给其他消费者。rebalance机制会造成性能开销**

  ```java
   props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 30 * 1000);
  ```

+ 如果每隔1s内没有poll到任何消息，则继续去poll消息，循环往复，直到poll到消息。如果超出了1s，则此次⻓轮询结束。

  ```java
  ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));
  ```

+ 消费者发送⼼跳的时间间隔

  ```java
  props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, 1000);
  ```

+ kafka如果超过10秒没有收到消费者的⼼跳，则会把消费者踢出消费组，进⾏rebalance，把分区分配给其他消费者。

  ```java
  props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 10 * 1000); 
  ```

## 3. 指定消费

+ 指定分区消费

  ```java
  consumer.assign(Arrays.asList(new TopicPartition(TOPIC_NAME, 0)));
  ```

+ 消息回溯消费

  ```java
  consumer.assign(Arrays.asList(new TopicPartition(TOPIC_NAME, 0)));
  consumer.seekToBeginning(Arrays.asList(new TopicPartition(TOPIC_NAME,0)));
  ```

+ 指定offset消费

  ```java
  consumer.assign(Arrays.asList(new TopicPartition(TOPIC_NAME, 0)));
  consumer.seek(new TopicPartition(TOPIC_NAME, 0), 10);
  ```

+ 新消费组的消费偏移量：当消费主题的是⼀个新的消费组，或者指定offset的消费⽅式，offset不存在，那么应该如何消费?

  + latest(默认) ：只消费⾃⼰启动之后发送到主题的消息

  + earliest：**第⼀次从头开始消费**，以后按照消费offset记录继续消费，这个需要区别于consumer.seekToBeginning(每次都从头开始消费)

    ```java
    props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); 
    ```

## 4. 消费者的健康状态检查

+ 消费者每隔1s向kafka集群发送⼼跳，集群发现如果有超过10s没有续约的消费者，将被踢出消费组，触发该消费组的rebalance机制，将该分区交给消费组⾥的其他消费者进⾏消费。

  ```java
  //consumer给broker发送⼼跳的间隔时间
  props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, 1000);
  //kafka如果超过10秒没有收到消费者的⼼跳，则会把消费者踢出消费组，进⾏rebalance，把分区分配给其他消费者。
  props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 10 * 1000);
  ```

  

# 八. Kafka集群Controller、Rebalance和HW
## 1. Controller

Kafka集群中的broker在zk中创建临时序号节点，序号最⼩的节点（最先创建的节点）将作为集群的controller，负责管理整个集群中的所有分区和副本的状态：

+ 当某个分区的leader副本出现故障时，由控制器负责为该分区选举新的leader副本。
+ 当检测到某个分区的ISR集合发⽣变化时，由控制器负责通知所有broker更新其元数据信息
+ 当使⽤kafka-topics.sh脚本为某个topic增加分区数量时，同样还是由控制器负责让新分区被其他节点感知到。

## 2.Rebalance机制

**前提是：消费者没有指明分区消费。当消费组⾥消费者和分区的关系发⽣变化，那么就会触发rebalance机制**

这个机制会重新调整消费者消费哪个分区。

在触发rebalance机制之前，消费者消费哪个分区有三种策略：

+ range：通过公示来计算某个消费者消费哪个分区
+ 轮询：⼤家轮着消费
+ sticky：在触发了rebalance后，在消费者消费的原分区不变的基础上进⾏调整。

## 3. HW和LEO

![HW&LEO](\消息队列\images\HW&LEO.png)

+ HW俗称⾼⽔位，HighWatermark的缩写，取⼀个partition对应的ISR中**最⼩的LEO(log-end-offset)作为HW，consumer最多只能消费到HW所在的位置**
+ 另外每个replica都有HW，leader和follower各⾃负责更新⾃⼰的HW的状态。**对于leader新写⼊的消息，consumer不能⽴刻消费，leader会等待该消息被所有ISR中的replicas同步后更新HW，此时消息才能被consumer消费。这样就保证了如果leader所在的broker失效，该消息仍然可以从新选举的leader中获取。**

# 九. kafka问题

## 1. 如何防止消息丢失

+ 发送⽅： ack是1 或者-1/all 可以防⽌消息丢失，如果要做到99.9999%，ack设成all，把min.insync.replicas配置成分区备份数
+ 消费⽅：把⾃动提交改为⼿动提交。

## 2. 如何防⽌消息的重复消费

⼀条消息被消费者消费多次。如果为了消息的不重复消费，⽽把⽣产端的重试机制关闭、消费端的⼿动提交改成⾃动提交，这样反⽽会出现消息丢失，那么可以直接在防治消息丢失的⼿段上再加上消费消息时的幂等性保证，就能解决消息的重复消费问题。
幂等性如何保证：

+ mysql 插⼊业务id作为主键，主键是唯⼀的，所以⼀次只能插⼊⼀条
+ 使⽤redis或zk的分布式锁（主流的⽅案）

## 3. 如何做到顺序消费

+ 发送⽅：在发送时将ack不能设置0，关闭重试，使⽤同步发送，等到发送成功再发送下⼀条。确保消息是顺序发送的。
+ 接收⽅：消息是发送到⼀个分区中，只能有⼀个消费组的消费者来接收消息。
+ kafka的顺序消费使⽤场景不多，因为牺牲掉了性能，但是⽐如rocketmq在这⼀块有专⻔的功能已设计好

## 4. 如何解决消息积压问题

### 消息积压问题的出现

消息的消费者的消费速度远赶不上⽣产者的⽣产消息的速度，导致kafka中有⼤量的数据没有被消费。随着没有被消费的数据堆积越多，消费者寻址的性能会越来越差，最后导致整个kafka对外提供的服务的性能很差，从⽽造成其他服务也访问速度变慢，造成服务雪崩。

### 消息积压的解决⽅案

## 4. 解决消息积压问题

⽣产端发消息过快，消费者消费消息过慢导致消息积压。消息积压会导致很多问题，⽐如磁盘被打满、kafka性能下降就容易出现服务雪崩，需要有相应的⼿段：

+ ⽅案⼀：在⼀个消费者中启动多个线程，让多个线程同时消费。——提升⼀个消费者的消费能⼒。
+ ⽅案⼆：如果⽅案⼀还不够的话，这个时候可以启动多个消费者，多个消费者部署在不同的服务器上。其实多个消费者部署在同⼀服务器上也可以提⾼消费能⼒——充分利⽤服务器的cpu资源。
+ ⽅案三：让⼀个消费者去把收到的消息往另外⼀个topic上发，另⼀个topic设置多个分区和多个消费者 ，进⾏具体的业务消费。

# 5. 延迟队列

![延迟队列](\消息队列\images\延迟队列.png)

延迟队列的应⽤场景：在订单创建成功后如果超过30分钟没有付款，则需要取消订单，此时可⽤延时队列来实现

+ 创建多个topic，每个topic表示延时的间隔
  + topic_5s: 延时5s执⾏的队列
  + topic_1m: 延时1分钟执⾏的队列
  + topic_30m: 延时30分钟执⾏的队列
+ 生产者发送消息到相应的topic，并带上消息的发送时间
+ 消费者订阅相应的topic，消费时轮询消费整个topic中的消息
  + 如果消息的发送时间，和消费的当前时间超过预设的值，⽐如30分钟，则消费该消息
  + 如果消息的发送时间，和消费的当前时间没有超过预设的值，则不消费当前的offset及之后的offset的所有消息都消费
  + 下次继续消费该offset处的消息，判断时间是否已满⾜预设值


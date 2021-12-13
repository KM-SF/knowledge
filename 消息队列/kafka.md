# 一. Kafka介绍



+ Kafka是最初由Linkedin公司开发，是⼀个分布式、⽀持分区的（partition）、多副本的（replica），基于zookeeper（最新版已经不需要）协调的分布式消息系统，它的最⼤的特性就是可以实时的处理⼤量数据以满⾜各种需求场景。

+ Kafka 是一款开源的消息引擎系统。常见的两种消息传输模型如下：

  + 点对点模型
  + 发布/订阅模型

+ 一个典型的 Kafka 体系架构包括若干 Producer、若干 Broker、若干 Consumer，以及一个ZooKeeper 集群，如下图所示。**其中 ZooKeeper 是 Kafka 用来负责集群元数据的管理、控制器的选举等操作的。Producer 将消息发送到 Broker，Broker 负责将收到的消息存储到磁盘中，而 Consumer 负责从 Broker 订阅并消费消息。**

  ![整体架构](\消息队列\images\整体架构.png)

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
| Producer      | 消息生产者，也就是发送消息的一方。生产者负责创建消息，然后将其投递到 Kafka中。 |
| Consumer      | 消息消费者，也就是接收消息的一方，从Broker读取消息的客户端。消费者连接到 Kafka 上并接收消息，进而进行相应的业务逻辑处理。 |
| ConsumerGroup | 每个consumer术语一个特定的ConsumerGroup，一个消息可以被多个不同的Consumer Group消费。但是一个Consumer Group只能有一个Consumer能够消费该消息 |
| partition     | 物理上的概念，一个topic可以分为多个partition，每个partition内部消息是有序的 |

+ 主题是一个逻辑上的概念，它还可以细分为多个分区，一个分区只属于单个主题，很多时候也会把分区称为主题分区（Topic-Partition）。同一主题下的不同分区包含的消息是不同的，分区在存储层面可以看作一个可追加的日志（Log）文件，消息在被追加到分区日志文件的时候都会分配一个特定的偏移量（offset）。
+ offset 是消息在分区中的唯一标识，是一个单调递增且不变的值。**Kafka 通过它来保证消息在分区内的顺序性，不过 offset 并不跨越分区，也就是说，Kafka 保证的是分区有序而不是主题有序。**![offset](\消息队列\images\offset.png)

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

+ 为⼀个主题创建多个分区

  ```bash
  ./kafka-topics.sh --create --zookeeper localhost:2181 --partitions 2 --topic test1
  ```

+ 可以通过这样的命令查看topic的分区信息

  ```bash
  ./kafka-topics.sh --describe --zookeeper localhost:2181 --topic test1
  ```

+ Kafka 中的分区机制指的是将每个主题划分成多个分区（Partition），每个分区是一组有序的消息日志。生产者生产的每条消息只会被发送到一个分区中。

+ ⼀个主题中的消息量是⾮常⼤的，因此可以通过分区的设置，来分布式存储这些消息。⽐如⼀个topic创建了3个分区。那么topic中的消息就会分别存放在这三个分区中。

+ 分区作用：

  + 可以分布式存储，可以解决统⼀存储⽂件过⼤的问题
  + 可以并⾏写
  + 提供了读写的吞吐量：读和写可以同时在多个分区中进⾏

+ 实际上是存在data/kafka-logs/test-0 和 test-1中的0000000.log⽂件中

+ Kafka 中的分区可以分布在不同的服务器（broker）上，也就是说，一个主题可以横跨多个 broker，以此来提供比单个 broker 更强大的性能。

+ **分区的作用：**就是提供负载均衡的能力，或者说对数据进行分区的主要原因，就是为了实现系统的高伸缩性（Scalability）。不同的分区能够被放置到不同节点的机器上，而数据的读写操作也都是针对分区这个粒度而进行的，这样每个节点的机器都能独立地执行各自分区的读写请求处理。并且，我们还可以通过添加新的节点机器来增加整体系统的吞吐量。

## 3. 分区策略

Kafka 生产者的分区策略是决定生产者将消息发送到哪个分区的算法。Kafka 提供默认的分区策略，同时它也支持自定义分区策略。常见的分区策略如下：

#### 3.1 轮询策略

Round-robin 策略，即顺序分配。比如一个主题下有 3 个分区，那么第一条消息被发送到分区 0，第二条被发送到分区 1，第三条被发送到分区 2，以此类推。当生产第 4 条消息时又会重新开始，即将其分配到分区 0。轮询策略有非常优秀的负载均衡表现，它总是能保证消息最大限度地被平均分配到所有分区上，故默认情况下它是最合理的分区策略，也是我们最常用的分区策略之一。

#### 3.2 随机策略

也称 Randomness 策略，所谓随机就是我们随意地将消息放置到任意一个分区上。本质上看随机策略也是力求将数据均匀地打散到各个分区，但从实际表现来看，它要逊于轮询策略，所以如果追求数据的均匀分布，还是使用轮询策略比较好

#### 3.3 按消息键保序策略

Kafka 允许为每条消息定义消息键，简称为 Key。这个 Key 的作用非常大，它可以是一个有着明确业务含义的字符串，比如客户代码、部门编号或是业务 ID 等；也可以用来表征消息元数据。一旦消息被定义了 Key，那么你就可以保证同一个 Key 的所有消息都进入到相同的分区里面，由于每个分区下的消息处理都是有顺序的，故这个策略被称为按消息键保序策略。Kafka 的主题会有多个分区，分区作为并行任务的最小单位，为消息选择分区要根据消息是否含有键来判断。

## 4. 小细节：

+ 每一条消息被发送到 broker 之前，会根据分区规则选择存储到哪个具体的分区。如果分区规则设定得合理，所有的消息都可以均匀地分配到不同的分区中。如果一个主题只对应一个文件，那么这个文件所在的机器 I/O 将会成为这个主题的性能瓶颈，而分区解决了这个问题。在创建主题的时候可以通过指定的参数来设置分区的个数，当然也可以在主题创建完成之后去修改分区的数量，通过增加分区的数量可以实现水平扩展。

+ 定期将⾃⼰消费分区的offset提交给kafka内部topic：__consumer_offsets，提交过去的时候，key是consumerGroupId+topic+分区号，value就是当前offset的值，kafka会定期清理topic⾥的消息，最后就保留最新的那条数据__
+ 因为consumer_offsets可能会接收⾼并发的请求，kafka默认给其分配50个分区(可以通过offsets.topic.num.partitions设置)，这样可以通过加机器的⽅式抗⼤并发。
+ 不考虑多副本的情况，一个分区对应一个日志（Log）。**为了防止 Log 过大，Kafka 又引入了日志分段（LogSegment）的概念，将 Log 切分为多个 LogSegment，相当于一个巨型文件被平均分配为多个相对较小的文件，这样也便于消息的维护和清理。**事实上，Log 和 LogSegment也不是纯粹物理意义上的概念，Log 在物理上只以文件夹的形式存储，而**每个 LogSegment 对应于磁盘上的一个日志文件和两个索引文件**，以及可能的其他文件（比如以“.txnindex”为后缀的事务索引文件）。下图描绘了主题、分区、副本、Log 以及 LogSegment 之间的关系。![主题-分区-Log-LogSegment](\消息队列\images\主题-分区-Log-LogSegment.png)

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

#### replica

+ 当前副本存在的broker节点，通过增加副本数量可以提升容灾能力。备份的思想，就是把相同的数据拷贝到多台机器上，而这些相同的数据拷贝在 Kafka 中被称为副本（Replica）。

+ 同一分区的不同副本中保存的是相同的消息（在同一时刻，副本之间并非完全一样），副本之间是“一主多从”的关系，**其中 leader 副本负责处理读写请求，follower 副本只负责与 leader 副本的消息同步。**
+ 副本处于不同的 broker 中，当**leader 副本出现故障时，从 follower 副本中重新选举新的 leader 副本对外提供服务**。Kafka 通过多副本机制实现了故障的自动转移，当Kafka 集群中某个 broker 失效时仍然能保证服务可用。

#### leader

+ leader：副本⾥的概念每个partition都有⼀个broker作为leader。
+ **消息发送⽅要把消息发给哪个broker？就看副本的leader是在哪个broker上⾯。副本⾥的leader专⻔⽤来接收消息。接收到消息，其他follower通过poll的⽅式来同步数据。**
+ 副本负责维护和跟踪 ISR 集合中所有 follower 副本的滞后状态，当 follower 副本落后太多或失效时，leader 副本会把它从 ISR 集合中剔除。
+ 如果 OSR 集合中有 follower 副本“追上”了 leader 副本，那么 leader 副本会把它从 OSR 集合转移至 ISR 集合。
+ 默认情况下，当leader 副本发生故障时，只有在 ISR 集合中的副本才有资格被选举为新的 leader，而在 OSR集合中的副本则没有任何机会（不过这个原则也可以通过修改相应的参数配置来改变）。

#### follower

+ leader处理所有针对这个partition的读写请求，**⽽follower被动复制leader，不提供读写（主要是为了保证多副本数据与消费的⼀致性），如果leader所在的broker挂掉，那么就会进⾏新leader的选举。**

#### isr和OSR

+ 分区中的所有副本统称为 AR（Assigned Replicas）。
+ 所有与 leader 副本保持一定程度同步的副本（包括 leader 副本在内）组成 ISR（In-Sync Replicas），ISR 集合是 AR 集合中的一个子集。消息会先发送到 leader 副本，然后 follower 副本才能从 leader 副本中拉取消息进行同步，同步期间内 follower 副本相对于 leader 副本而言会有一定程度的滞后。
+ leader 副本同步滞后过多的副本（不包括 leader 副本）组成 OSR（Out-of-Sync Replicas），由此可见，AR=ISR+OSR。在正常情况下，所有的 follower 副本都应该与 leader 副本保持一定程度的同步，即 AR=ISR，OSR 集合为空。
+ isr：可以同步的broker节点和已同步的broker节点，存放在isr集合中。

#### 那这里为什么 Kafka 不像 MySQL 和 Redis 那样允许 follwer 副本对外提供读服务呢？

1. 首先，**Redis 和 MySQL 都支持主从读写分离，这和它们的使用场景有关。对于那种读操作很多而写操作相对不频繁的负载类型而言，采用读写分离是非常不错的方案**——我们可以添加很多follower 横向扩展，提升读操作性能。反观 Kafka，它的主要场景还是在消息引擎而不是以数据存储的方式对外提供读服务，通常涉及频繁地生产消息和消费消息，这不属于典型的读多写少场景，因此读写分离方案在这个场景下并不太适合。
2. 第二，**Kafka 副本机制使用的是异步消息拉取，因此存在 leader 和 follower 之间的不一致性。**如果要采用读写分离，必然要处理副本 lag 引入的一致性问题，比如如何实现 read-your-writes、如何保证单调读（monotonic reads）以及处理消息因果顺序颠倒的问题。相反地，如果不采用读写分离，所有客户端读写请求都只在 Leader 上处理也就没有这些问题了——当然最后全局消息顺序颠倒的问题在 Kafka 中依然存在，常见的解决办法是使用单分区，其他的方案还有 version vector，但是目前 Kafka 没有提供。
3. 第三，**主写从读无非就是为了减轻 leader 节点的压力，将读请求的负载均衡到 follower 节点，如果 Kafka 的分区相对均匀地分散到各个 broker 上，同样可以达到负载均衡的效果，没必要刻意实现主写从读增加代码实现的复杂程度。**

![分区与副本](\消息队列\images\分区与副本.png)

如上图所示，Kafka 集群中有 4 个 broker，某个主题中有 3 个分区，且副本因子（即副本个数）也为 3，如此每个分区便有 1 个 leader 副本和 2 个 follower 副本。生产者和消费者只与leader 副本进行交互，而 follower 副本只负责消息的同步，很多时候 follower 副本中的消息相对 leader 副本而言会有一定的滞后。

## 3. broker、主题、分区、副本

+ kafka集群中由多个broker组成
+ ⼀个broker中存放⼀个topic的不同partition——副本
+ 副本是在分区这个层级定义的。每个分区下可以配置若干个副本，其中只能有 1 个领导者副本和 N-1 个追随者副本。生产者向分区写入消息，每条消息在分区中的位置信息由一个叫位移（Offset）的数据来表征。
+ **Kafka 的三层消息架构：**
  + 第一层是主题层，每个主题可以配置 M 个分区，而每个分区又可以配置 N 个副本。
  + 第二层是分区层，每个分区的 N 个副本中只能有一个充当领导者角色，对外提供服务；其他 N-1个副本是追随者副本，只是提供数据冗余之用。
  + 第三层是消息层，分区中包含若干条消息，每条消息的位移从 0 开始，依次递增。

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

## 4. 生产者发送缓冲区

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

## 5.  生产者与分区关系

分区是实现负载均衡以及高吞吐量的关键，故在生产者这一端就要仔细盘算合适的分区策略，避免造成消息数据的“倾斜”，使得某些分区成为性能瓶颈，这样极易引发下游数据消费的性能下降。

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


## 5. 消费者组

+ 消费者组是 Kafka 提供的可扩展且具有容错性的消费者机制。既然是一个组，那么组内必然可以有多个消费者或消费者实例（Consumer Instance），**它们共享一个公共的 ID，这个ID 被称为 Group ID**。组内的所有消费者协调在一起来消费订阅主题（Subscribed Topics）的所有分区（Partition）。当然，每个分区只能由同一个消费者组内的一个 Consumer 实例来消费。
+ 当 Consumer Group 订阅了多个主题后，组内的每个实例不要求一定要订阅主题的所有分区，它只会消费部分分区中的消息。ConsumerGroup 之间彼此独立，互不影响，它们能够订阅相同的一组主题而互不干涉。再加上 Broker 端的消息留存机制，Kafka 的 Consumer Group 完美地规避了上面提到的伸缩性差的问题。
+ 为什么要引入消费者组呢？**主要是为了提升消费者端的吞吐量。多个消费者实例同时消费，加速整个消费端的吞吐量（TPS）。**
+ 分区是以消费者级别被消费的，但分区的消费进度要保存成消费者组级别的
+ 理想情况下，Consumer 实例的数量应该等Group 订阅主题的分区总数。

## 6. 消费模型

消息由生产者发布到 Kafka 集群后，会被消费者消费。消息的消费模型有两种：**推送模型（push）和拉取模型（pull）。**

#### 6.1 推送模型

基于推送模型的消息系统，由 broker 记录消费者的消费状态。broker 在将消息推送到消费者后，标记这条消息为已消费，这种方式无法很好地保证消息的处理语义。比如，broker 把消息发送出去后，当消费进程挂掉或者由于网络原因没有收到这条消息时，就有可能造成消息丢失（因为消息代理已经把这条消息标记为消费了，但实际上这条消息并没有被实际处理） 。如果要保证消息的处理语义，broker 发送完消息后，要设置状态为“已发送”，只有收到消费者的确认请求后才更新为“已消费”，这就需要在消息代理中记录所有消息的消费状态，这种方式需要在客户端和服务端做一些复杂的状态一致性保证，比较复杂。

#### 6.2 拉取模型

因此，**kafka 采用拉取模型**，由消费者自己记录消费状态，每个消费者互相独立地顺序读取每个分区的消息。这种由消费者控制偏移量的优点是消费者可以按照任意的顺序消费消息，比如，消费者可以重置到旧的偏移量，重新处理之前已经消费过的消息；或者直接跳到最近的位置，从当前时刻开始消费。broker 是无状态的，它不需要标记哪些消息被消费者处理过，也不需要保证一条消息只会被一个消费者处理。而且，不同的消费者可以按照自己最大的处理能力来拉取数据，即使有时候某个消费者的处理速度稍微落后，它也不会影响其他的消费者，并且在这个消费者恢复处理速度后，仍然可以追赶之前落后的数据。

# 八. Kafka集群Controller、Rebalance和HW
## 1. Controller

Kafka集群中的broker在zk中创建临时序号节点，序号最⼩的节点（最先创建的节点）将作为集群的controller，负责管理整个集群中的所有分区和副本的状态：

+ 当某个分区的leader副本出现故障时，由控制器负责为该分区选举新的leader副本。
+ 当检测到某个分区的ISR集合发⽣变化时，由控制器负责通知所有broker更新其元数据信息
+ 当使⽤kafka-topics.sh脚本为某个topic增加分区数量时，同样还是由控制器负责让新分区被其他节点感知到。

## 2.Rebalance机制

+ Rebalance 就是让一个 Consumer Group 下所有的 Consumer 实例就如何消费订阅主题的所有分区达成共识的过程。在 Rebalance 过程中，所有 Consumer 实例共同参与，在协调者组件（Coordinator）的帮助下，完成订阅主题分区的分配。

#### 2.1 Rebalance触发条件

1. **组成员数发生变更。**比如有新的 Consumer 实例加入组或者离开组，抑或是有 Consumer实例崩溃被“踢出”组。
2. **订阅主题数发生变更。**Consumer Group 可以使用正则表达式的方式订阅主题，比如consumer.subscribe(Pattern.compile("t.*c")) 就表明该 Group 订阅所有以字母 t 开头、字母c 结尾的主题。在 Consumer Group 的运行过程中，你新创建了一个满足这样条件的主题，那么该 Group 就会发生 Rebalance。
3. **订阅主题的分区数发生变更。**Kafka 当前只能允许增加一个主题的分区数。当分区数增加时，就会触发订阅该主题的所有 Group 开启 Rebalance。
4. 消费者没有指明分区消费。当消费组⾥消费者和分区的关系发⽣变化，那么就会触发rebalance机制

#### 2.2 Rebalance缺点

1. Rebalance 过程对 Consumer Group 消费过程有极大的影响。如果你了解 JVM 的垃圾回收机制，你一定听过万物静止的收集方式，即著名的 stop the world，简称 STW。在 STW期间，所有应用线程都会停止工作，表现为整个应用程序僵在那边一动不动。Rebalance 过程也和这个类似，在 Rebalance 过程中，所有 Consumer 实例都会停止消费，等待 Rebalance 完成。这是 Rebalance 为人诟病的一个方面。
2. **目前 Rebalance 的设计是所有 Consumer 实例共同参与，全部重新分配所有分区。**其实更高效的做法是尽量减少分配方案的变动。例如实例 A 之前负责消费分区 1、2、3，那么Rebalance 之后，如果可能的话，最好还是让实例 A 继续消费分区 1、2、3，而不是被重新分配其他的分区。这样的话，实例 A 连接这些分区所在 Broker 的 TCP 连接就可以继续用，不用重新创建连接其他 Broker 的 Socket 资源。
3. Rebalance 实在是太慢了。

#### 2.3 避免非必要的Rebalance

1. 第一类非必要**Rebalance 是因为未能及时发送心跳，导致 Consumer 被“踢出”Group 而引发的**。因此，需要仔细地设置 session.timeout.ms
   （决定了 Consumer 存活性的时间间隔）和 heartbeat.interval.ms（控制发送心跳请求频率的参数） 的值。
2. 第二类非必要**Rebalance 是 Consumer 消费时间过长导致的**，Consumer 端还有一个参数，用于控制 Consumer 实际消费能力对 Rebalance 的影响，即
   max.poll.interval.ms 参数。**它限定了 Consumer 端应用程序两次调用 poll 方法的最大时间间隔。它的默认值是 5 分钟，表示你的 Consumer 程序如果在 5 分钟之内无法消费完 poll 方法返回的消息，那么 Consumer 会主动发起“离开组”的请求，Coordinator 也会开启新一轮Rebalance。**

#### 2.4 rebalance策略

+ 在触发rebalance机制之前，消费者消费哪个分区有三种策略：
  + range：通过公示来计算某个消费者消费哪个分区
  + 轮询：⼤家轮着消费
  + sticky：在触发了rebalance后，在消费者消费的原分区不变的基础上进⾏调整。

#### 2.5 消费者组重平衡流程

##### 1. 触发与通知

1. 重平衡过程通过消息者端的心跳线程（Heartbeat Thread）通知到其他消费者实例。
2. kafka Java 消费者需要定期地发送心跳请求到 Broker 端的协调者，以表明它还存活着。
3. 消费者端的参数 heartbeat.interval.ms，从字面上看，它就是设置了心跳的间隔时间，但这个参数的真正作用是控制重平衡通知的频率。

##### 2. 消费者组状态机

重平衡一旦开启，Broker 端的协调者组件就要开始忙了，主要涉及到控制消费者组的状态流转。Kafka 设计了一套消费者组状态机（State Machine），帮助协调者完成整个重平衡流程

+ Kafka 消费者组状态
  + Empty：组内没有任何成员，但消费者组可能存在已提交的位移数据，而且这些位移尚未过期。
  + Dead：组内没有任何成员，但组的元数据信息已经在协调者端被移除。协调者保存着当前向它注册过的所有组信息，所谓元数据就是类似于这些注册信息。
  + PreparingRebalance：消费者组准备开启重平衡，此时所有成员都要重新请求加消费者组
  + CompletingRebalance：消费者组下所有成员已经加入，各个成员正在等待分配方案。
  + stable：消费者组的稳定状态。该状态表明重平衡已经完成，组内成员能够正常消费数据了。
+ 状态机的各个状态流转图如下：![消费者组状态机](\消息队列\images\消费者组状态机.png)

一个消费者组最开始是 Empty 状态，当重平衡过程开启后，它会被置于 PreparingRebalance状态等待成员加入，之后变更到 CompletingRebalance 状态等待分配方案，最后流转到 Stable状态完成重平衡。当有新成员加入或已有成员退出时，消费者组的状态从 Stable 直接跳到PreparingRebalance 状态，此时，所有现存成员就必须重新申请加入组。当所有成员都退出组后，消费者组状态变更为 Empty。Kafka 定期自动删除过期位移的条件就是，组要处于 Empty 状态。如果消费者组停了很长时间（超过 7 天），那么 Kafka 很可能就把该组的位移数据删除了。

##### 3. 消费者端重平衡流程

重平衡的完整流程需要消费者端和协调者组件共同参与才能完成。在消费者端，重平衡分为以下两个步骤：

1) 加入组：JoinGroup 请求
2) 等待领导者消费者分配方案：SyncGroup 请求

具体如下：

1. **当组内成员加入组时，他会向协调者发送 JoinGroup 请求。在该请求中，每个成员都要将自己订阅的主题上报，这样协调者就能收集到所有成员的订阅信息。一旦收集了全部成员的 JoinGroup请求后，协调者会从这些成员中选择一个担任这个消费者组的领导者。**通常情况下，第一个发送JoinGroup 请求的成员自动成为领导者。注意区分这里的领导者和之前介绍的领导者副本，不是一个概念。**这里的领导者是具体的消费者实例，它既不是副本，也不是协调者。领导者消费者的任务是收集所有成员的订阅信息，然后根据这些信息，制定具体的分区消费分配方案。**
2. 选出领导者之后，协调者会把消费者组订阅信息封装进 JoinGroup 请求的响应中，然后发给领导者，由领导者统一做出分配方案后，进入下一步
3. 发送 SyncGroup 请求。在这一步中，领导者向协调者发送 SyncGroup 请求，将刚刚做出的分配方案发给协调者。值得注意的是，其他成员也会向协调者发送 SyncGroup 请求，只是请求体中并没有实际内容。这一步的目的是让协调者接收分配方案，然后统一以 SyncGroup 响应的方式发给所有成员，这样组内成员就都知道自己该消费哪些分区了。

+ 步骤1：加入组：JoinGroup 请求![步骤1](\消息队列\images\rebalance步骤1.png)

+ 步骤2：等待领导者消费者分配方案：SyncGroup 请求![步骤2](\消息队列\images\rebalance步骤2.png)

##### 4. Broker 端（协调者端）重平衡场景剖析

这几个场景分别是：**新成员加入组、组成员主动离组、组成员崩溃离组、组成员提交位移**。

> Case 1: 新成员入组
> 新成员入组是指组处于 Stable 状态后，有新成员加入。当协调者收到新的 JoinGroup 请求后，它会通过心跳请求响应的方式通知组内现有的所有成员，强制它们开启新一轮的重平衡。具体的过程和之前的客户端重平衡流程是一样的。

> Case 2: 组成员主动离组
> 主动离组就是指消费者实例所在线程或进程调用 close() 方法主动通知协调者它要退出。这个场景就涉及到了第三类请求：LeaveGroup 请求。协调者收到 LeaveGroup 请求后，依然会以心跳响应的方式通知其他成员。

> Case 3: 组成员崩溃离组
> 崩溃离组是指消费者实例出现严重故障，突然宕机导致的离组。它和主动离组是有区别的，后者是主动发起的离组，协调者能马上感知并处理。但崩溃离组是被动的，协调者通常需要等待一段时间才能感知到，这段时间一般是由消费者端参数 session.timeout.ms 控制的。也就是说，Kafka 一般不会超过 session.timeout.ms 就能感知到这个崩溃。当然，后面处理崩溃离组的流程与之前是一样的。

> Case 4: 重平衡时协调者对组内成员提交位移的处理
> 正常情况下，每个组内成员都会定期汇报位移给协调者。当重平衡开启时，协调者会给予成员一段缓冲时间，要求每个成员必须在这段时间内快速地上报自己的位移信息，然后在开启正常JoinGroup/SyncGroup 请求发送。

## 3. HW和LEO

![HW&LEO](\消息队列\images\HW&LEO.png)

+ HW俗称⾼⽔位，HighWatermark的缩写，取⼀个partition对应的ISR中**最⼩的LEO(log-end-offset)作为HW，consumer最多只能消费到HW所在的位置**
+ 每个replica都有HW，leader和follower各⾃负责更新⾃⼰的HW的状态。**对于leader新写⼊的消息，consumer不能⽴刻消费，leader会等待该消息被所有ISR中的replicas同步后更新HW，此时消息才能被consumer消费。这样就保证了如果leader所在的broker失效，该消息仍然可以从新选举的leader中获取。**
+ 它标识了一个特定的消息偏移量（offset），消费者只能拉取到这个 offset 之前的消息。

![HW&LEO-2](\消息队列\images\HW&LEO-2.png)

+ 如上图所示，它代表一个日志文件，这个日志文件中有 9 条消息，第一条消息的 offset（LogStartOffset）为 0，最后一条消息的 offset 为 8，offset 为 9 的消息用虚线框表示，代表下一条待写入的消息。日志文件的 HW 为 6，表示消费者只能拉取到 offset 在 0 至 5 之间的消息，而 offset 为 6 的消息对消费者而言是不可见的。
+ LEO 是 Log End Offset 的缩写，它标识当前日志文件中下一条待写入消息的 offset，上图中offset 为 9 的位置即为当前日志文件的 LEO，LEO 的大小相当于当前日志分区中最后一条消息的offset 值加 1。**分区 ISR 集合中的每个副本都会维护自身的 LEO，而 ISR 集合中最小的 LEO即为分区的 HW，对消费者而言只能消费 HW 之前的消息。**

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


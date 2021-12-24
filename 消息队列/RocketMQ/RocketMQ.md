# 一.整体介绍

## 1. 基础概念

### 1.1 消息（Message）

消息是指，消息系统所传输信息的物理载体，生产和消费数据的最小单位，每条消息必须属于一个主题。

### 1.2 主题（Topic）

Topic表示一类消息的集合，每个主题包含若干条消息，每条消息只能属于一个主题，是RocketMQ进行消息订阅的基本单位。

（topic:message 1:n）（message:topic 1:1）

一个生产者可以同时发送多种Topic的消息；而一个消费者只对某种特定的Topic感兴趣，即只可以订阅和消费一种Topic的消息。 

（producer:topic 1:n ）（consumer:topic 1:1）

### 1.3 标签（Tag） 

为消息设置的标签，用于同一主题下区分不同类型的消息。来自同一业务单元的消息，可以根据不同业务目的在同一主题下设置不同标签。标签能够有效地保持代码的清晰度和连贯性，并优化RocketMQ提供的查询系统。消费者可以根据Tag实现对不同子主题的不同消费逻辑，实现更好的扩展性。

**Topic是消息的一级分类，Tag是消息的二级分类。**

### 1.4 队列（Queue）

存储消息的物理实体。一个Topic中可以包含多个Queue，每个Queue中存放的就是该Topic的消息。一个Topic的Queue也被称为一个Topic中消息的分区（Partition）。

**一个Topic的Queue中的消息只能被一个消费者组中的一个消费者消费。一个Queue中的消息不允许同一个消费者组中的多个消费者同时消费。**

![](/消息队列/\RocketMQ/images/topic与queue关系.png)

### 1.5 消息标识（MessageId/Key）

RocketMQ中每个消息拥有**唯一的MessageId**，且可以携带**具有业务标识的Key**，以方便对消息的查询。

不过需要注意的是，MessageId有两个：

+ 在生产者send消息时会自动生成一个**MessageId（msgId)**
+ 当消息到达Broker后，Broker也会自动生成一个**MessageId(offsetMsgId)**。

msgId、offsetMsgId与key都称为消息标识：

+ msgId：**由producer端生成**，其生成规则为：producerIp + 进程pid + MessageClientIDSetter类的ClassLoader的hashCode +
  当前时间 + AutomicInteger自增计数器
+ offsetMsgId：**由broker端生成**，其生成规则为：brokerIp + 物理分区的offset（Queue中的偏移量）
+ key：由用户指定的业务相关的唯一标识

## 2. 系统架构

![](/消息队列/\RocketMQ/images/架构图.png)

RocketMQ架构上主要分为四部分构成：

### 2.1 Producer

消息生产者，负责生产消息。Producer通过**MQ的负载均衡模块选择相应的Broker集群队列进行消息投递，投递的过程支持快速失败并且低延迟。**

RocketMQ中的消息生产者都是以生产者组（Producer Group）的形式出现的。

生产者组是同一类生产者的集合，这类Producer发送相同Topic类型的消息。

**一个**生产者组可以同时发送**多个**主题的消息。

### 2.2 Consumer

消息消费者，负责消费消息。一个消息消费者会从Broker服务器中获取到消息，并对消息进行相关业务处理。

RocketMQ中的消息消费者都是以消费者组（Consumer Group）的形式出现的。

消费者组是**同一类消费者的集合**，这类Consumer消费的是**同一个Topic类型**的消息。

消费者组使得在消息消费方面，实现负载均衡（将一个Topic中的不同的Queue平均分配给同一个Consumer Group的不同的Consumer，注意，并不是将消息负载均衡）和容错（一个Consmer挂了，该Consumer Group中的其它Consumer可以接着消费原Consumer消费的Queue）的目标变得非常容易。

消费者组中Consumer的数量应该**小于等于**订阅Topic的Queue数量。如果超出Queue数量，则多出的Consumer将不能消费消息

一个Topic类型的消息可以被**多个消费者组**同时消费。

> 注意：
>
> + 消费者组只能消费一个Topic的消息，不能同时消费多个Topic消息
> + 一个消费者组中的消费者必须订阅完全相同的Topic

## 3. Name Server

### 3.1 功能介绍

NameServer是一个**Broker与Topic路由的注册中心，支持Broker的动态注册与发现。**

主要包括两个功能：

+ **Broker管理**：接受Broker集群的注册信息并且保存下来作为路由信息的基本数据；提供心跳检测机制，检查Broker是否还存活。
+ **路由信息管理**：每个NameServer中都保存着**Broker集群的整个路由信息**和**用于客户端查询的队列信息**。Producer和Conumser通过NameServer可以获取整个Broker集群的路由信息，从而进行消息的投递和消费

### 3.2 路由注册

NameServer通常也是以集群的方式部署，不过，NameServer是**无状态的**，即`NameServer集群中的各个节点间是无差异的，各节点间相互不进行信息通讯`。

那各节点中的数据是如何进行数据同步的呢？

+ 在Broker节点启动时，轮询NameServer列表，与每个NameServer节点建立长连接，发起注册请求。在NameServer内部维护着⼀个Broker列表，用来动态存储Broker的信息。  

Broker节点为了证明自己是活着的，为了维护与NameServer间的长连接，会将最新的信息以心跳包的方式上报给NameServer，每30秒发送一次心跳。心跳包中包含 BrokerId、Broker地址(IP+Port)、Broker名称、Broker所属集群名称等等。NameServer在接收到心跳包后，会更新心跳时间戳，记录这个Broker的最新存活时间。  

>  优点：NameServer集群搭建简单，扩容简单  
>
> 缺点：对于Broker，必须明确指出所有NameServer地址。否则未指出的将不会去注册。也正因为如此，NameServer并不能随便扩容。因为，若Broker不重新配置，新增的NameServer对于Broker来说是不可见的，其不会向这个NameServer进行注册  

### 3.3 路由剔除  

由于Broker关机、宕机或网络抖动等原因，NameServer没有收到Broker的心跳，NameServer可能会将其从Broker列表中剔除。  

NameServer中有⼀个定时任务，每隔10秒就会扫描⼀次Broker表，查看每一个Broker的最新心跳时间戳距离当前时间是否超过120秒，如果超过，则会判定Broker失效，然后将其从Broker列表中剔除。  

> 扩展：对于RocketMQ日常运维工作，例如Broker升级，需要停掉Broker的工作。OP需要怎么做？
>
> + OP需要将Broker的读写权限禁掉。一旦client(Consumer或Producer)向broker发送请求，都会收到broker的NO_PERMISSION响应，然后client会进行对其它Broker的重试。
> + 当OP观察到这个Broker没有流量后，再关闭它，实现Broker从NameServer的移除。
>   OP：运维工程师
>   SRE：Site Reliability Engineer，现场可靠性工程师  

### 3.4 路由发现  

RocketMQ的路由发现采用的是**Pull模型**。当Topic路由信息出现变化时，NameServer不会主动推送给客户端，而是客户端定时拉取主题最新的路由。默认客户端每30秒会拉取一次最新的路由。  

1. push模型：推送模型。其实时性较好，是一个`发布-订阅`模型，需要维护一个长连接。而长连接的维护是需要资源成本的。该模型适合于的场景：
   + 实时性要求较高
   + Client数量不多，Server数据变化较频繁
2. Pull模型：拉取模型。存在的问题是，实时性较差。
3. Long Polling模型：长轮询模型。其是对Push与Pull模型的整合，充分利用了这两种模型的优势，屏蔽了它们的劣势。  

### 3.5 客户端NameServer选择策略  

这里的客户端指的是Producer与Consumer 

客户端在配置时必须要写上NameServer集群的地址

客户端首先会生产一个随机数，然后再与NameServer节点数量取模，此时得到的就是所要连接的节点索引，然后就会进行连接。如果连接失败，则会采用round-robin策略，逐个尝试着去连接其它节点  

首先采用的是**随机策略**进行的选择，失败后采用的是**轮询策略**。

## 4 Broker  

### 4.1 功能介绍  

Broker充当着**消息中转角色，负责存储消息、转发消息**。

Broker在RocketMQ系统中负责**接收并存储从生产者发送来的消息**，同时为消费者的拉取请求作准备。

Broker同时也存储着消息相关的元数据，包括消费者组消费进度偏移offset、主题、队列等。  

### 4.2 模块构成  

![](/消息队列/RocketMQ/images/Broker Server.png)

+ **Remoting Module**：**整个Broker的实体**，负责处理来自clients端的请求。而这个Broker实体则由以下模块构成。
+ **Client Manager**：客户端管理器。负责接收、解析客户端(Producer/Consumer)请求，管理客户端。例如，维护Consumer的Topic订阅信息
+ **Store Service**：存储服务。提供方便简单的API接口，处理消息存储到物理硬盘和消息查询功能。
+ **HA Service**：高可用服务，提供Master Broker 和 Slave Broker之间的数据同步功能。
+ **Index Service**：索引服务。根据特定的Message key，对投递到Broker的消息进行索引服务，同时也提供根据Message Key对消息进行快速查询的功能。  

### 4.3 集群部署  

![](/消息队列/RocketMQ/images/集群架构.png)

为了增强Broker性能与吞吐量，Broker一般都是以集群形式出现的。各集群节点中可能存放着相同Topic的不同Queue。

如果某Broker节点宕机，如何保证数据不丢失呢。将每个Broker集群节点进行横向扩展，即将Broker节点再建为一个HA集群，解决单点问题。
Broker节点集群是一个主从集群，即集群中具有Master与Slave两种角色。

Master负责处理**读写操作请求**，Slave负责对Master中的数据进行备份。

当Master挂掉了，Slave则会自动切换为Master去工作。所以这个Broker集群是主备集群。一个Master可以包含多个Slave，但一个Slave只能隶属于一个Master。

Master与Slave 的对应关系是通过指定**相同的BrokerName、不同的BrokerId 来确定的**。BrokerId为0表示Master，非0表示Slave。每个Broker与NameServer集群中的所有节点建立长连接，定时注册Topic信息到所有NameServer。  

## 5 工作流程  

### 5.1 具体流程  

1. 启动NameServer，NameServer启动后开始监听端口，等待Broker、Producer、Consumer连接。
2. 启动Broker时，Broker会与所有的NameServer建立并保持长连接，然后每30秒向NameServer定时发送心跳包。
3. 发送消息前，可以先创建Topic，**创建Topic时需要指定该Topic要存储在哪些Broker上**，当然，在创建Topic时也会将Topic与Broker的关系写入到NameServer中。不过，这步是可选的，也可以在发送消息时自动创建Topic。
4. Producer发送消息，启动时先跟NameServer集群中的其中一台建立长连接，并从NameServer中获取路由信息，即当前发送的Topic消息的Queue与Broker的地址（IP+Port）的映射关系。然后根据算法策略从队选择一个Queue，与队列所在的Broker建立长连接从而向Broker发消息。当然，在获取到路由信息后，Producer会首先将路由信息缓存到本地，再每30秒从NameServer更新一次路由信息。
5. Consumer跟Producer类似，跟其中一台NameServer建立长连接，获取其所订阅Topic的路由信息，然后根据算法策略从路由信息中获取到其所要消费的Queue，然后直接跟Broker建立长连接，开始消费其中的消息。Consumer在获取到路由信息后，同样也会每30秒从NameServer更新一次路由信息。不过不同于Producer的是，Consumer还会向Broker发送心跳，以确保Broker的存活状态  

### 5.2 Topic的创建模式  

手动创建Topic时，有两种模式：

1. 集群模式：该模式下创建的Topic在该集群中，所有Broker中的Queue数量是相同的。
2. Broker模式：该模式下创建的Topic在该集群中，每个Broker中的Queue数量可以不同。  

自动创建Topic时，默认采用的是Broker模式，会为每个Broker默认创建4个Queue  

### 5.3 读/写队列  

从物理上来讲，读/写队列是同一个队列。所以，不存在读/写队列数据同步问题。读/写队列是逻辑上进行区分的概念。一般情况下，读/写队列数量是相同的。  

如果读/写队列数量不同，则只会生效的只会按照最少的来生效。

> 例如，创建Topic时设置的写队列数量为8，读队列数量为4，此时系统会创建8个Queue，分别是0 1 2 3 4 5 6 7。Producer会将消息写入到这8个队列，但Consumer只会消费0 1 2 3这4个队列中的消息，4 5 6 7中的消息是不会被消费到的。  
>
> 再如，创建Topic时设置的写队列数量为4，读队列数量为8，此时系统会创建8个Queue，分别是0 1 2 3 4 5 6 7。Producer会将消息写入到0 1 2 3 这4个队列，但Consumer只会消费0 1 2 3 4 5 6 7这8个队列中的消息，但是4 5 6 7中是没有消息的。此时假设Consumer Group中包含两个Consuer，Consumer1消费0 1 2 3，而Consumer2消费4 5 6 7。但实际情况是，Consumer2是没有消息可消费的。  

当读/写队列数量设置不同时，  目的是为了方便Topic的Queue的缩容  

> 例如，原来创建的Topic中包含16个Queue，如何能够使其Queue缩容为8个，还不会丢失消息？
>
> 可以动态修改写队列数量为8，读队列数量不变。此时新的消息只能写入到前8个队列，而消费都消费的却是16个队列中的数据。当发现后8个Queue中的消息消费完毕后，就可以再将读队列数量动态设置为8。整个缩容过程，没有丢失任何消息。  

perm用于设置对当前创建Topic的操作权限：2表示只写，4表示只读，6表示读写。  

# 二. 集群理论

## 1. 数据复制与刷盘策略  

![](/消息队列/RocketMQ/images/数据复制与刷盘策略.png)

### 1.1 复制策略  

复制策略是Broker的Master与Slave间的数据同步方式。分为同步复制与异步复制：  

+ **同步复制**：消息写入master后，master会等待slave同步数据成功后才向producer返回成功ACK
+ **异步复制**：消息写入master后，master立即向producer返回成功ACK，无需等待slave同步数据成功  

**异步复制策略会降低系统的写入延迟，RT变小，提高了系统的吞吐量**  

### 1.2 刷盘策略  

刷盘策略指的是broker中消息的落盘方式，即**消息发送到broker内存后消息持久化到磁盘的方式**。分为同步刷盘与异步刷盘：  

+ **同步刷盘**：当消息持久化到broker的磁盘后才算是消息写入成功。
+ **异步刷盘**：当消息写入到broker的内存后即表示消息写入成功，无需等待消息持久化到磁盘。  

**异步刷盘策略会降低系统的写入延迟，RT变小，提高了系统的吞吐量**

+ 消息写入到Broker的内存，一般是写入到了PageCache
+ 对于异步 刷盘策略，消息会写入到PageCache后立即返回成功ACK。但并不会立即做落盘操作，而是当PageCache到达一定量时会自动进行落盘。  

## 2 Broker集群模式  

### 2.1 单Master

只有一个broker（其本质上就不能称为集群）。这种方式也只能是在测试时使用，生产环境下不能使用，因为存在单点问题。  

### 2.2 多Master  

broker集群仅由多个master构成，不存在Slave。**同一Topic的各个Queue会平均分布在各个master节点上。**  

+ 优点：配置简单，单个Master宕机或重启维护对应用无影响，在磁盘配置为RAID10时，即使机器宕机不可恢复情况下，由于RAID10磁盘非常可靠，消息也不会丢（异步刷盘丢失少量消息，同步刷盘一条不丢），性能最高；如果没有配置RAID10磁盘，一旦出现某Master宕机，则会发生大量消息丢失的情况  
+ 缺点：单台机器宕机期间，这台机器上未被消费的消息在机器恢复之前不可订阅（不可消费），消息实时性会受到影响。  

### 2.3 多Master多Slave模式-异步复制  

broker集群由多个master构成，每个master又配置了多个slave（在配置了RAID磁盘阵列的情况下，一个master一般配置一个slave即可）。

master与slave的关系是主备关系，即**master负责处理消息的读写请求，而slave仅负责消息的备份与master宕机后的角色切换。**  

异步复制：复制策略中的异步复制策略，即消息写入master成功后，master立即向producer返回成功ACK，无需等待slave同步数据成功  

该模式的最大特点：**当master宕机后slave能够自动切换为master**。不过由于slave从master的同步具有短暂的延迟（毫秒级），所以当master宕机后，**这种异步复制方式可能会存在少量消息的丢失问题。**  

### 2.4 多Master多Slave模式-同步双写  

该模式：**多Master多Slave模式的同步复制实现**。

所谓同步双写，指的是消息写入master成功后，master会等待slave同步数据成功后才向producer返回成功ACK，**即master与slave都要写入成功后才会返回成功ACK，也即双写。**  

该模式与异步复制模式相比，优点是消息的**安全性更高，不存在消息丢失的情况**。但单个消息的RT略高，从而导致性能要略低（大约低10%）  

该模式存在一个大的问题：对于目前的版本，**Master宕机后，Slave不会自动切换到Master。**  

### 2.5 最佳实践  

一般会为Master配置RAID10磁盘阵列，然后再为其配置一个Slave。即利用了RAID10磁盘阵列的高效、安全性，又解决了可能会影响订阅的问题。  

# 三. 工作原理

## 1. 消息的生产

### 1.1 消息的生产过程

Producer可以将**消息写入到某Broker中的某Queue**中，其经历了如下过程：

1. Producer发送消息之前，会先向NameServer发出**获取消息Topic的路由信息**的请求
2. NameServer返回该**Topic的路由表**及**Broker列表**
3. Producer根据代码中指定的Queue选择策略，从Queue列表中选出一个队列，用于后续存储消息
4. Produer对消息做一些特殊处理，例如，消息本身超过4M，则会对其进行压缩
5. Producer向选择出的Queue所在的Broker发出RPC请求，将消息发送到选择出的Queue

**路由表**：实际是一个Map，key为Topic名称，value是一个QueueData实例列表。QueueData并不是一个Queue对应一个QueueData，而是一个Broker中该Topic的所有Queue对应一个QueueData。即，只要涉及到该Topic的Broker，一个Broker对应一个QueueData。QueueData中包含brokerName。简单来说，**路由表的key为Topic名称，value则为所有涉及该Topic的BrokerName列表。**

**Broker列表**：其实际也是一个Map。key为brokerName，value为BrokerData。一套brokerName名称相同的Master-Slave小集群对应一个BrokerData。BrokerData中包含brokerName及一个map。该map的key为brokerId，value为该broker对应的地址。brokerId为0表示该broker为Master，非0表示Slave。

### 1.2 Queue选择算法

对于无序消息，其Queue选择算法，也称为消息投递算法，常见的有两种：

#### <u>轮询算法</u>

默认选择算法。该算法保证了每个Queue中可以均匀的获取到消息

该算法存在一个问题：由于某些原因，在某些Broker上的Queue可能投递延迟较严重。从而导致Producer的缓存队列中出现较大的消息积压，影响消息的投递性能。

#### <u>最小投递延迟算法</u>

该算法会统计每次消息投递的时间延迟，然后根据统计出的结果将消息投递到时间延迟最小的Queue。如果延迟相同，则采用轮询算法投递。该算法可以有效提升消息的投递性能。

该算法也存在一个问题：消息在Queue上的分配不均匀。投递延迟小的Queue其可能会存在大量的消息。而对该Queue的消费者压力会增大，降低消息的消费能力，可能会导致MQ中消息的堆积。

## 2. 消息的存储

RocketMQ中的消息存储在本地文件系统中，这些相关文件默认在：**当前用户主目录下的store目录中**。

![](/消息队列/\RocketMQ/images/消息存储目录.png)

+ abort：该文件在Broker启动后会自动创建，正常关闭Broker，该文件会自动消失。若在没有启动Broker的情况下，发现这个文件是存在的，则说明之前Broker的关闭是非正常关闭。
+ checkpoint：其中存储着commitlog、consumequeue、index文件的最后刷盘时间戳
+ commitlog：其中存放着commitlog文件，而消息是写在commitlog文件中的
+ config：存放着Broker运行期间的一些配置数据
+ consumequeue：其中存放着consumequeue文件，队列就存放在这个目录中
+ index：其中存放着消息索引文件indexFile
+ lock：运行期间使用到的全局资源锁

### 2.1 commitlog文件

在很多资料中commitlog目录中的文件简单就称为commitlog文件。但在源码中，该文件被命名为mappedFile。

#### <u>目录与文件</u>

commitlog目录中存放着很多的mappedFile文件，**当前Broker中的所有消息都是落盘到这些mappedFile文件中的**。mappedFile文件大小为1G（小于等于1G），文件名由20位十进制数构成，表示**当前文件的第一条消息的起始位移偏移量**。

一个Broker中仅包含一个commitlog目录，所有的mappedFile文件都是存放在该目录中的。即无论当前Broker中存放着多少Topic的消息，这些消息都是被顺序写入到了mappedFile文件中的。**这些消息在Broker中存放时并没有被按照Topic进行分类存放。**

**mappedFile文件是顺序读写的文件，所有其访问效率很高**。无论是SSD磁盘还是SATA磁盘，通常情况下，顺序存取效率都会高于随机存取。

#### <u>消息单元</u>

![](/消息队列/\RocketMQ/images/消息单元.png)

mappedFile文件内容由一个个的消息单元构成。

每个消息单元中包含消息总长度MsgLen、消息的物理位置physicalOffset、消息体内容Body、消息体长度BodyLength、消息主题Topic、Topic长度TopicLength、消息生产者BornHost、消息发送时间戳BornTimestamp、消息所在的队列QueueId、消息在Queue中存储的偏移量QueueOffset等近20余项消息相关属性。

### 2.2 consumequeue

![](/消息队列/\RocketMQ/images/consumequeue.png)

#### <u>目录与文件</u>

![](/消息队列/\RocketMQ/images/commitlog与consumequeue.png)

为了提高效率，会为每个Topic在~/store/consumequeue中创建一个目录，目录名为Topic名称。**在该Topic目录下，会再为每个该Topic的Queue建立一个目录，目录名为queueId**。每个目录中存放着若干consumequeue文件，**consumequeue文件是commitlog的索引文件，可以根据consumequeue定位到具体的消息**

consumequeue文件名也由20位数字构成，表示当前文件的第一个索引条目的起始位移偏移量。与mappedFile文件名不同的是，其后续文件名是固定的。因为consumequeue文件大小是固定不变的。

#### <u>索引条目</u>

![](/消息队列/\RocketMQ/images/consumequeue索引条目.png)

每个consumequeue文件可以包含30w个索引条目，每个索引条目包含了三个消息重要属性：消息在mappedFile文件中的偏移量CommitLog Offset、消息长度、消息Tag的hashcode值。这三个属性占20个字节，所以每个文件的大小是固定的30w * 20字节。

一个consumequeue文件中所有消息的Topic一定是相同的。但每条消息的Tag可能是不同的。

### 2.3 对文件的读写

![](/消息队列/\RocketMQ/images/文件读写.png)

#### <u>消息写入</u>

一条消息进入到Broker后经历了以下几个过程才最终被持久化。

+ Broker根据queueId，获取到该消息对应索引条目要在consumequeue目录中的写入偏移量，即QueueOffset
+ 将queueId、queueOffset等数据，与消息一起封装为消息单元
+ 将消息单元写入到commitlog
+ 同时，形成消息索引条目
+ 将消息索引条目分发到相应的consumequeue

#### <u>消息拉取</u>

当Consumer来拉取消息时会经历以下几个步骤：

+ Consumer获取到其要消费消息所在Queue的**消费偏移量offset**，计算出其要消费消息的**消息offset**。

> 消费offset即消费进度，consumer对某个Queue的消费offset，即消费到了该Queue的第几条消息
> 消息offset = 消费offset + 1

+ Consumer向Broker发送拉取请求，其中会包含其要拉取消息的Queue、消息offset及消息Tag。
+ Broker计算在该consumequeue中的queueOffset。queueOffset = 消息offset * 20字节
+ 从该queueOffset处开始向后查找第一个指定Tag的索引条目。
+ 解析该索引条目的前8个字节，即可定位到该消息在commitlog中的commitlog offset
+ 从对应commitlog offset中读取消息单元，并发送给Consumer

#### 性能提升

1. RocketMQ对文件的读写操作是通过**mmap零拷贝**进行的，将对文件的操作转化为直接对内存地址进行操作，从而极大地提高了文件的读写效率。

2. **consumequeue中的数据是顺序存放的，还引入了PageCache的预读取机制**，使得对consumequeue文件的读取几乎接近于内存读取，即使在有消息堆积情况下也不会影响性能。

> + PageCache机制，页缓存机制，是OS对文件的缓存机制，用于加速对文件的读写操作。一般来说，程序对文件进行顺序读写的速度几乎接近于内存读写速度，主要原因是：**由于OS使用PageCache机制对读写访问操作进行性能优化，将一部分的内存用作PageCache。**
> + 写操作：OS会先将数据写入到PageCache中，随后会以**异步方式**由pdfush（page dirty fush）内核线程将Cache中的数据刷盘到物理磁盘
> + 读操作：若用户要读取数据，其首先会从PageCache中读取，若没有命中，则**OS在从物理磁盘上加载该数据到PageCache的同时，也会顺序对其相邻数据块中的数据进行预读取。**

3. RocketMQ中可能会影响性能的是对commitlog文件的读取。因为对commitlog文件来说，读取消息时会产生大量的随机访问，而随机访问会严重影响性能。不过，如果选择合适的系统IO调度算法，比如设置调度算法为Deadline（采用SSD固态硬盘的话），随机读的性能也会有所提升。

## 3. indexFile

除了通过通常的指定Topic进行消息消费外，**RocketMQ还提供了根据key进行消息查询的功能**。

该查询是通过store目录中的**index子目录中的indexFile**进行索引实现的快速查询。

当然，这个indexFile中的索引数据是在包含了key的消息被发送到Broker时写入的。如果消息中没有包含key，则不会写入。

### 3.1 索引条目结构

![](/消息队列/RocketMQ/images/indexFile.png)

每个Broker中会包含一组indexFile，每个indexFile都是以一个时间戳命名的（**这个indexFile被创建时的时间戳**）。

每个indexFile文件由三部分构成：indexHeader，slots槽位，indexes索引数据。

每个indexFile文件中包含**500w**个slot槽。而每个slot槽又可能会挂载很多的index索引单元。

---

![](/消息队列/\RocketMQ/images/indexHeader.png)

+ beginTimestamp：该indexFile中第一条消息的存储时间
+ endTimestamp：该indexFile中最后一条消息存储时间
+ beginPhyoffset：该indexFile中第一条消息在commitlog中的偏移量commitlog offset
+ endPhyoffset：该indexFile中最后一条消息在commitlog中的偏移量commitlog offset
+ hashSlotCount：已经填充有index的slot数量（并不是每个slot槽下都挂载有index索引单元，这里统计的是所有挂载了index索引单元的slot槽的数量）
+ indexCount：该indexFile中包含的索引单元个数（统计出当前indexFile中所有slot槽下挂载的所有index索引单元的数量之和）

#### <u>Slots与Indexes间的关系</u>  

indexFile中最复杂的是Slots与Indexes间的关系。在实际存储时，Indexes是在Slots后面的，但为了便于理解，将它们的关系展示为如下形式：  

![](/消息队列/RocketMQ/images/slots和indexes关系结构.png)

1. **key的hash值 % 500w的结果即为slot槽位**
2. 然后将该slot值修改为该index索引单元的indexNo，根据这个indexNo可以计算出该index单元在indexFile中的位置。
3. 不过，该取模结果的重复率是很高的（**哈希冲突**）
4. 使用了拉链法解决该问题。在每个index索引单元中增加了preIndexNo，用于指定该slot中当前index索引单元的前一个index索引单元。而slot中始终存放的是其下最新的index索引单元的indexNo，这样的话，只要找到了slot就可以找到其最新的index索引单元，而通过这个index索引单元就可以找到其之前的所有index索引单元。  

#### <u>index索引单元（indexData）</u>  

![](/消息队列/RocketMQ/images/index索引单元.png)

+ keyHash：消息中指定的业务key的hash值
+ phyOffset：当前key对应的消息在commitlog中的偏移量commitlog offset
+ timeDiff：当前key对应消息的存储时间与当前indexFile创建时间的时间差
+ preIndexNo：当前slot下当前index索引单元的前一个index索引单元的indexNo  

### 3.2 indexFile的创建  

indexFile的文件名为当前文件被创建时的时间戳。  

根据业务key进行查询时，查询条件除了key之外，还需要指定一个要查询的时间戳，表示要查询不大于该时间戳的最新的消息，即查询指定时间戳之前存储的最新消息。

这个时间戳文件名可以简化查询，提高查询效率。

创建的条件（时机）有两个：  

+ 当第一条带key的消息发送来后，系统发现没有indexFile，此时会创建第一个indexFile文件
+ 当一个indexFile中挂载的index索引单元数量超出2000w个时，会创建新的indexFile。当带key的消息发送到来后，系统会找到最新的indexFile，并从其indexHeader的最后4字节中读取到indexCount。若indexCount >= 2000w时，会创建新的indexFile。  

### 3.3 查询流程  

+ 计算指定消息key的slot槽位序号：  slot槽位序号 = key的hash % 500w  
+ 计算槽位序号为n的slot在indexFile中的起始位置：  slot(n)位置 = 40 + (n - 1) * 4
+ 计算indexNo为m的index在indexFile中的位置：  index(m)位置 = 40 + 500w * 4 + (m - 1) * 20  

> 40为indexFile中indexHeader的字节数
> 500w * 4 是所有slots所占的字节数  

具体查询流程如下：  

![](/消息队列/RocketMQ/images/根据key查询的流程.png)

## 4. 消息的消费  

消费者从Broker中获取消息的方式有两种：**pull拉取方式**和**push推动方式**。

消费者组对于消息消费的模式又分为两种：**集群消费Clustering**和**广播消费Broadcasting**。  

### 4.1 获取消费类型  

#### <u>拉取式消费(pull)</u> 

Consumer主动从Broker中拉取消息，**主动权由Consumer控制**。一旦获取了批量消息，就会启动消费过程。

该方式的**实时性较弱，即Broker中有了新的消息时消费者并不能及时发现并消费**  

由于拉取时间间隔是由用户指定的，所以在设置该间隔时需要注意平稳：间隔太短，空请求比例会增加；间隔太长，消息的实时性太差  

#### <u>推送式消费(push)</u>

该模式下Broker收到数据后会**主动推送给Consumer**。该获取方式**一般实时性较高**。

该获取方式是典型的**发布-订阅模式**，即Consumer向其关联的Queue注册了监听器，一旦发现有新的消息到来就会触发回调的执行，回调方法是Consumer去Queue中拉取消息。

这些都是基于Consumer与Broker间的长连接的。长连接的维护是需要消耗系统资源的。

#### <u>对比</u>

+ pull：需要应用去实现对关联Queue的遍历，**实时性差；但便于应用控制消息的拉取**
+ push：封装了对关联Queue的遍历，**实时性强，但会占用较多的系统资源**  

### 4.2 消费模式

#### <u>广播消费</u>

广播消费模式下，相同Consumer Group的每个Consumer实例都接收同一个Topic的全量消息。

每条消息都会被发送到Consumer Group中的**每个**Consumer  

![](/消息队列/RocketMQ/images/广播消费.png)



#### <u>集群消费</u>

集群消费模式下，相同Consumer Group的每个Consumer实例**平均分摊**同一个Topic的消息。

即每条消息只会被发送到Consumer Group中的**某个**Consumer。  

![](/消息队列/RocketMQ/images/集群消费.png)

#### <u>消息进度保存</u>  

+ **广播模式**：消费进度保存在**consumer端**。因为广播模式下consumer group中每个consumer都会消费所有消息，但它们的消费进度是不同。所以consumer各自保存各自的消费进度。
+ **集群模式**：消费进度保存在**broker**中。consumer group中的所有consumer共同消费同一个Topic中的消息，**同一条消息只会被消费一次**。消费进度会参与到了消费的负载均衡中，故消费进度是需要共享的

### 4.3 Rebalance机制

**Rebalance机制讨论的前提是：集群消费。**  

#### <u>什么是Rebalance</u>  

Rebalance即再均衡，指的是，将⼀个Topic下的多个Queue在同⼀个Consumer Group中的多个Consumer间进行**重新分配**的过程。  

Rebalance机制的本意是为了**提升消息的并行消费能力**。例如，⼀个Topic下5个队列，在只有1个消费者的情况下，这个消费者将负责消费这5个队列的消息。如果此时我们增加⼀个消费者，那么就可以给其中⼀个消费者分配2个队列，给另⼀个分配3个队列，从而提升消息的并行消费能力。  

#### <u>Rebalance限制</u>  

由于**⼀个队列最多分配给⼀个消费者**，因此当某个消费者组下的消费者实例数量大于队列的数量时，多余的消费者实例将分配不到任何队列。  

#### <u>Rebalance危害</u>  

**消费暂停**：在只有一个Consumer时，其负责消费所有队列；在新增了一个Consumer后会触发Rebalance的发生。此时原Consumer就需要`暂停部分队列的消费`，等到这些队列分配给新的Consumer后，这些暂停消费的队列才能继续被消费。  

**消费重复**：Consumer 在消费新分配给自己的队列时，必须接着之前Consumer 提交的消费进度的offset继续消费。然而默认情况下，offset是异步提交的，这个**异步提交导致提交到Broker的offset与Consumer实际消费的消息并不一致**。这个不一致的差值就是可能会重复消费的消息  

**消费突刺**：由于Rebalance可能导致重复消费，如果需要重复消费的消息过多，或者因为Rebalance暂停
时间过长从而导致积压了部分消息。那么有可能会导致在Rebalance结束之后`瞬间需要消费很多消息`。  

#### <u>Rebalance产生的原因</u>  

导致Rebalance产生的原因两个：

+ 消费者所订阅Topic的Queue数量发生变化

> Broker扩容或缩容
> Broker升级运维
> Broker与NameServer间的网络异常
> Queue扩容或缩容  

+ 消费者组中消费者的数量发生变化。  

> Consumer Group扩容或缩容
> Consumer升级运维
> Consumer与NameServer间网络异常  

#### <u>Rebalance过程</u>  

在Broker中维护着多个**Map集合**，这些集合中动态存放着当前Topic中Queue的信息、Consumer Group中Consumer实例的信息。

1. 一旦发现消费者所订阅的Queue数量发生变化，或消费者组中消费者的数量发生变化

2. 立即向Consumer Group中的`每个实例发出Rebalance通知`
3. Consumer实例在接收到通知后会采用Queue分配算法自己获取到相应的Queue，`即由Consumer实例自主进行Rebalance `

> TopicConågManager：key是topic名称，value是TopicConåg。TopicConåg中维护着该Topic中所有Queue的数据。
>
> ConsumerManager：key是Consumser Group Id，value是ConsumerGroupInfo。ConsumerGroupInfo中维护着该Group中所有Consumer实例数据。
>
> ConsumerOffsetManager：key为 Topic与订阅该Topic的Group的组合,即topic@group，value是一个内层Map。内层Map的key为QueueId，内层Map的value为该Queue的消费进度offset  

#### <u>与Kafka对比</u>

在Kafka中，一旦发现出现了Rebalance条件，Broker会调用`Group Coordinator`来完成Rebalance。

Coordinator是Broker中的一个进程。Coordinator会在Consumer Group中选出一个Group Leader。由
这个Leader根据自己本身组情况完成Partition分区的再分配。这个再分配结果会上报给Coordinator，并由Coordinator同步给Group中的所有Consumer实例  

Kafka中的Rebalance是由`Consumer Leader`完成的。而RocketMQ中的Rebalance是由`每个Consumer自
身完成`的，Group中不存在Leader。  

### 4.4 Queue分配算法  

一个Topic中的Queue只能由Consumer Group中的`一个Consumer进行消费`，而一个Consumer可以同时
`消费多个Queue中的消息`。

常见的有四种策略：**平均分配策略**，**环形平均策略**，**一致性hash策略**，**同机房策略**  

#### <u>平均分配策略</u>  

该算法是要根据avg = QueueCount / ConsumerCount 的计算结果进行分配的。如果能够整除，则按顺序将avg个Queue逐个分配Consumer；如果不能整除，则将多余出的Queue按照Consumer顺序逐个分配。  

先计算好每个Consumer应该分得几个Queue，然后再依次将这些数量的Queue逐个分配个Consumer。  

![](/消息队列/RocketMQ/images/平均分配策略.png)

#### <u>环形平均策略</u>  

环形平均算法是指，**根据消费者的顺序**，依次在由queue队列组成的环形图中**逐个分配**。  

![](/消息队列/RocketMQ/images/环形平均策略.png)

#### <u>一致性hash策略</u>  

该算法会将consumer的hash值作为Node节点存放到hash环上，然后将queue的hash值也放到hash环上，**通过顺时针方向，距离queue最近的那个consumer就是该queue要分配的consumer。**  

该算法存在的问题：分配不均。

解决方案：通过设置虚拟节点

![](/消息队列/RocketMQ/images/一致性hash.png)

#### <u>同机房策略</u>

该算法会根据queue的部署机房位置和consumer的位置，过滤出当前consumer相同机房的queue。然后按照平均分配策略或环形平均策略对同机房queue进行分配。如果没有同机房queue，则按照平均分配策略或环形平均策略对所有queue进行分配。  

![](/消息队列/RocketMQ/images/同机房策略.png)

### 4.5 至少一次原则

RocketMQ有一个原则：每条消息必须要被**成功消费一次**。  

**成功消费**：Consumer在消费完消息后会向其**消费进度记录器**提交其消费消息的offset，offset被成功记录到记录器中，那么这条消费就被成功消费了  

**消费进度记录器**：

+ 对于`广播消费模式`来说，`Consumer本身`就是消费进度记录器。
+ 对于`集群消费模式`来说，`Broker是消费`进度记录器。  

## 5. 订阅关系的一致性  

订阅关系的一致性指的是：**同一个消费者组**（Group ID相同）下**所有Consumer实例**所订阅的**Topic**与**Tag**及对消息的处理逻辑必须完全一致。否则，**消息消费的逻辑就会混乱，甚至导致消息丢失**  

### 5.1 正确订阅关系  

多个消费者组订阅了多个Topic，并且每个消费者组里的多个消费者实例的订阅关系保持了一致。  

![](/消息队列/RocketMQ/images/正确的订阅.png)

### 5.2 错误订阅关系  

一个消费者组订阅了**多个Topic**，但是该消费者组里的**多个Consumer实例的订阅关系并没有保持一致**。  

1. 订阅了不同Topic：同一个消费者组中的两个Consumer实例订阅了不同的Topic。  
2. 订阅了不同Tag：同一个消费者组中的两个Consumer订阅了相同Topic的不同Tag。
3. 订阅了不同数量的Topic：同一个消费者组中的两个Consumer订阅了不同数量的Topic  

![](/消息队列/RocketMQ/images/错误的订阅.png)

## 6. offset管理  

这里的offset指的是：Consumer的**消费进度**offset。

消费进度offset是：用来记录每个Queue的不同消费组的消费进度的。根据消费进度记录器的不同，可以分为两种模式：**本地模式**和**远程模式**。  

### 6.1 offset本地管理模式  

当消费模式为**广播消费**时，offset使用**本地模式存储**。因为每条消息会被所有的消费者消费，每个消费者管理自己的消费进度，各个消费者之间不存在消费进度的交集。

Consumer在广播消费模式下offset相关数据以json的形式持久化到Consumer本地磁盘文件中，默认文件路径为当前用户主目录下的：rocketmq_offsets/${clientId}/${group}/Offsets.json 。其中${clientId}为当前消费者id，默认为ip@DEFAULT；${group}为消费者组名称。  

### 6.2 offset远程管理模式  

当消费模式为**集群消费**时，offset使用远程模式管理。因为所有Cosnumer实例对消息采用的是均衡消费，**所有Consumer共享Queue的消费进度。**  

Consumer在集群消费模式下offset相关数据以json的形式持久化到**Broker磁盘文件中**，文件路径为当前用户主目录下的store/config/consumerOffset.json 。  

Broker启动时会加载这个文件，并写入到一个双层Map（ConsumerOffsetManager）。外层map的key为topic@group，value为内层map。内层map的key为queueId，value为offset。当发生Rebalance时，新的Consumer会从该Map中获取到相应的数据来继续消费。  

集群模式下offset采用远程管理模式，**主要是为了保证Rebalance机制**。  

### 6.3 offset用途  

消费者要消费的第一条消息的起始位置是用户自己通过consumer.setConsumeFromWhere()方法指定的。  

在Consumer启动后，其要消费的第一条消息的起始位置常用的有三种，这三种位置可以通过枚举类型常量设置。这个枚举类型为ConsumeFromWhere。  

+ CONSUME_FROM_LAST_OFFSET：从queue的当前最后一条消息开始消费
+ CONSUME_FROM_FIRST_OFFSET：从queue的第一条消息开始消费
+ CONSUME_FROM_TIMESTAMP：从指定的具体时间戳位置的消息开始消费。这个具体时间戳是通过另外一个语句指定的 。  consumer.setConsumeTimestamp(“20210701080000”) yyyyMMddHHmmss  

当消费完一批消息后：

1. Consumer会提交其消费进度offset给Broker
2. Broker在收到消费进度后会将其更新到那个双层Map（ConsumerOffsetManager）及consumerOffset.json文件中
3. 然后向该Consumer进行ACK，而ACK内容中包含三项数据：当前消费队列的最小offset（minOffset）、最大offset（maxOffset）、及下次消费的起始offset（nextBeginOffset）  

### 6.4 重试队列  

当rocketMQ对**消息的消费出现异常**时，会**将发生异常的消息的offset提交到Broker中的重试队列**。系统在发生消息消费异常时会为当前的topic@group创建一个重试队列，该队列以**%RETRY%**开头，到达重试时间后进行消费重试。  

![](/消息队列/RocketMQ/images/重试队列.png)

### 6.5 offset的同步提交与异步提交  

**集群消费模式**下，Consumer消费完消息后会向Broker提交消费进度offset，其提交方式分为两种：  

+ 同步提交：消费者在消费完一批消息后会向broker提交这些消息的offset，然后等待broker的成功响应。若在等待超时之前收到了成功响应，则继续读取下一批消息进行消费（从ACK中获取nextBeginOffset）。若没有收到响应，则会重新提交，直到获取到响应。而在这个等待过程中，消费者是阻塞的。其严重影响了消费者的吞吐量。  
+ 异步提交：消费者在消费完一批消息后向broker提交offset，但无需等待Broker的成功响应，可以继续读取并消费下一批消息。这种方式增加了消费者的吞吐量。但需要注意，broker在收到提交的offset后，还是会向消费者进行响应的。可能还没有收到ACK，此时Consumer会从Broker中直接获取nextBeginOffset。  

## 7. 消费幂等

### 7.1 什么是消费幂等

当出现消费者对某条消息重复消费的情况时，**重复消费的结果与消费一次的结果是相同的，并且多次消费并未对业务系统产生任何负面影响**，那么这个消费过程就是消费幂等的。  

幂等：若某操作**执行多次**与**执行一次**对系统产生的**影响是相同的**，则称该操作是幂等的。  

### 7.2 消息重复的场景分析  

#### 1）发送时消息重复

当一条消息已被成功发送到Broker并完成持久化，此时出现了网络闪断，**从而导致Broker对Producer应答失败**。 如果此时**Producer意识到消息发送失败并尝试再次发送消息**，**此时Broker中就可能会出现两条内容相同并且Message ID也相同的消息**，那么后续Consumer就一定会消费两次该消息。

#### 2）消费时消息重复  

消息已投递到Consumer并完成业务处理，当Consumer给Broker反馈应答时网络闪断，**Broker没有接收到消费成功响应**。**为了保证消息至少被消费一次的原则，Broker将在网络恢复后再次尝试投递之前已被处理过的消息**。此时消费者就会收到与之前处理过的**内容相同、Message ID也相同的消息**。  

#### 3）Rebalance时消息重复

当Consumer Group中的Consumer数量发生变化时，或其订阅的Topic的Queue数量发生变化时，会触发Rebalance，导致消费者提交offset给broker时，broker没有收到offset。此时Consumer可能会收到曾经被消费过的消息。

### 7.3 通用解决方案

#### 1）两要素

幂等解决方案的设计中涉及到两项要素：**幂等令牌**，与**唯一性处理**。

+ 幂等令牌：是生产者和消费者两者中的既定协议，通常指具备唯⼀业务标识的字符串。例如，订单号、流水号。一般由Producer随着消息一同发送来的。
+ 唯一性处理：服务端通过采用⼀定的算法策略，保证同⼀个业务逻辑不会被重复执行成功多次。例如，对同一笔订单的多次支付操作，只会成功一次  

#### 2）解决方案

1. 首先通过缓存去重。在缓存中如果已经存在了某幂等令牌，则说明本次操作是重复性操作；若缓存没有命中，则进入下一步。
2. 在唯一性处理之前，先在数据库中查询幂等令牌作为索引的数据是否存在。若存在，则说明本次操作为重复性操作；若不存在，则进入下一步。一般缓存中的数据是具有有效期的。缓存中数据的有效期一旦过期，就是发生缓存穿透，使请求直接就到达了DBMS。  所以需要先去数据库查过一次
3. 在同一事务中完成三项操作：唯一性处理后，将幂等令牌写入到缓存，并将幂等令牌作为唯一索引的数据写入到DB中。  

#### 3）解决方案举例

以支付场景为例：

1. 当支付请求到达后，首先在Redis缓存中却获取key为支付流水号的缓存value。若value不空，则说明本次支付是重复操作，业务系统直接返回调用侧重复支付标识；若value为空，则进入下一步操作
2. 到DBMS中根据支付流水号查询是否存在相应实例。若存在，则说明本次支付是重复操作，业务系统直接返回调用侧重复支付标识；若不存在，则说明本次操作是首次操作，进入下一步完成唯一性处理
3. 在分布式事务中完成三项操作：
   + 完成支付任务
   + 将当前支付流水号作为key，任意字符串作为value，通过set(key, value, expireTime)将数据写入到Redis缓存
   + 将当前支付流水号作为主键，与其它相关数据共同写入到DBMS  

### 7.4 消费幂等的实现  

消费幂等的解决方案很简单：**为消息指定不会重复的唯一标识**。

因为**Message ID有可能出现重复的情况**，所以真正安全的幂等处理，**不建议以Message ID作为处理依据**。

最好的方式是以业务唯一标识作为幂等处理的关键依据，而**业务的唯一标识可以通过消息Key设置**。

## 8. 消息堆积与消费延迟  

### 8.1 概念

**消息堆积**：消息处理流程中，如果Consumer的消费速度跟不上Producer的发送速度，MQ中未处理的消息会越来越多（进的多出的少）

消息堆积的出现进而会造成消息的**消费延迟**

以下场景需要重点关注消息堆积和消费延迟问题：

+ 业务系统上下游能力不匹配造成的持续堆积，且无法自行恢复。
+ 业务系统对消息的消费实时性要求较高，即使是短暂的堆积造成的消费延迟也无法接受。  

### 8.2 产生原因分析

Consumer使用长轮询Pull模式消费消息时，分为以下两个阶段：  

#### 1）消息拉取

Consumer通过长轮询Pull模式批量拉取的方式从服务端获取消息，将拉取到的消息缓存到本地缓冲队列中。对于拉取式消费，在内网环境下会有很高的吞吐量，**所以这一阶段一般不会成为消息堆积的瓶颈**  

#### 2）消息消费

Consumer将本地缓存的消息提交到消费线程中，使用业务消费逻辑对消息进行处理，处理完毕后获取到一个结果。这是真正的消息消费过程。

此时Consumer的消费能力就完全依赖于**消息的消费耗时和消费并发度**了。如果由于业务处理逻辑复杂等原因，导致处理单条消息的耗时较长，则整体的消息吞吐量肯定不会高，此时就会导致Consumer本地缓冲队列达到上限，停止从服务端拉取消息  

#### 3）结论  

消息堆积的主要瓶颈：在于**客户端的消费能力**，而**消费能力由消费耗时和消费并发度决定**。注意，消费耗时的优先级要高于消费并发度。即在保证了消费耗时的合理性前提下，再考虑消费并发度问题  

### 8.3 消费耗时

影响消息处理时长的主要因素是代码逻辑。而代码逻辑中可能会影响处理时长代码主要有两种类型：

+ **CPU内部计算型代码**
+ **外部I/O操作型代码**  

通常情况下代码中如果没有复杂的递归和循环的话，内部计算耗时相对外部I/O操作来说几乎可以忽略。所以**外部IO型代码是影响消息处理时长的主要症结所在。**  

外部IO操作型代码举例：

+ 读写外部数据库，例如对远程MySQL的访问
+ 读写外部缓存系统，例如对远程Redis的访问
+ 下游系统调用，例如Dubbo的RPC远程调用，Spring Cloud的对下游系统的Http接口调用  

### 8.4 消费并发度  

一般情况下，消费者端的**消费并发度**由**单节点线程数**和**节点数量**共同决定，其值为**单节点线程数*节点数量**。不过，通常需要优先调整单节点的线程数，若单机硬件资源达到了上限，则需要通过横向扩展来提高消费并发度。  

单节点线程数：即单个Consumer所包含的线程数量

节点数量：即Consumer Group所包含的Consumer数量  

对于**普通消息、延时消息及事务消息**，并发度计算都是 **单节点线程数 * 节点数量**。

但对于**顺序消息**则是不同的。**顺序消息的消费并发度等于 Topic的Queue分区数量**。  

> 全局顺序消息：该类型消息的Topic只有一个Queue分区。其可以保证该Topic的所有消息被顺序消费。为了保证这个全局顺序性，Consumer Group中在同一时刻只能有一个Consumer的一个线程进行消费。所以其并发度为1。
>
> 分区顺序消息：该类型消息的Topic有多个Queue分区。其仅可以保证该Topic的每个Queue分区中的消息被顺序消费，不能保证整个Topic中消息的顺序消费。为了保证这个分区顺序性，每个Queue分区中的消息在Consumer Group中的同一时刻只能有一个Consumer的一个线程进行消费。即，在同一时刻最多会出现多个Queue分别有多个Consumer的多个线程并行消费。所以其并发度为Topic的分区数量  

## 9. 消息的清理

消息被消费过后不会被清理掉

消息是被顺序存储在commitlog文件的，且消息大小不定长，所以消息的清理是不可能以消息为单位进行清理的，而是以**commitlog文件**为单位进行清理的。否则会急剧下降清理效率，并实现逻辑复杂  

commitlog文件存在一个过期时间，默认为72小时，即三天。除了用户手动清理外，在以下情况下也会被自动清理，无论文件中的消息是否被消费过：  

+ 文件过期，且到达清理时间点（默认为凌晨4点）后，自动清理过期文件
+ 文件过期，且磁盘空间占用率已达过期清理警戒线（默认75%）后，无论是否达到清理时间点，都会自动清理过期文件
+ 磁盘占用率达到清理警戒线（默认85%）后，开始按照设定好的规则清理文件，无论是否过期。默认会从最老的文件开始清理
+ 磁盘占用率达到系统危险警戒线（默认90%）后，Broker将拒绝消息写入  

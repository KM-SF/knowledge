# 一.整体介绍

## 1. 基础概念

#### 1.1 消息（Message）

消息是指，消息系统所传输信息的物理载体，生产和消费数据的最小单位，每条消息必须属于一个主题。

#### 1.2 主题（Topic）

Topic表示一类消息的集合，每个主题包含若干条消息，每条消息只能属于一个主题，是RocketMQ进行消息订阅的基本单位。

（topic:message 1:n）（message:topic 1:1）

一个生产者可以同时发送多种Topic的消息；而一个消费者只对某种特定的Topic感兴趣，即只可以订阅和消费一种Topic的消息。 

（producer:topic 1:n ）（consumer:topic 1:1）

#### 1.3 标签（Tag） 

为消息设置的标签，用于同一主题下区分不同类型的消息。来自同一业务单元的消息，可以根据不同业务目的在同一主题下设置不同标签。标签能够有效地保持代码的清晰度和连贯性，并优化RocketMQ提供的查询系统。消费者可以根据Tag实现对不同子主题的不同消费逻辑，实现更好的扩展性。

**Topic是消息的一级分类，Tag是消息的二级分类。**

#### 1.4 队列（Queue）

存储消息的物理实体。一个Topic中可以包含多个Queue，每个Queue中存放的就是该Topic的消息。一个Topic的Queue也被称为一个Topic中消息的分区（Partition）。

**一个Topic的Queue中的消息只能被一个消费者组中的一个消费者消费。一个Queue中的消息不允许同一个消费者组中的多个消费者同时消费。**

![](/消息队列/images/topic与queue关系.png)

#### 1.5 消息标识（MessageId/Key）

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

![](/消息队列/images/架构图.png)

RocketMQ架构上主要分为四部分构成：

#### 2.1 Producer

消息生产者，负责生产消息。Producer通过**MQ的负载均衡模块选择相应的Broker集群队列进行消息投递，投递的过程支持快速失败并且低延迟。**

RocketMQ中的消息生产者都是以生产者组（Producer Group）的形式出现的。

生产者组是同一类生产者的集合，这类Producer发送相同Topic类型的消息。

**一个**生产者组可以同时发送**多个**主题的消息。

#### 2.2 Consumer

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

#### 3.1 功能介绍

NameServer是一个**Broker与Topic路由的注册中心，支持Broker的动态注册与发现。**

主要包括两个功能：

+ **Broker管理**：接受Broker集群的注册信息并且保存下来作为路由信息的基本数据；提供心跳检测机制，检查Broker是否还存活。
+ **路由信息管理**：每个NameServer中都保存着**Broker集群的整个路由信息**和**用于客户端查询的队列信息**。Producer和Conumser通过NameServer可以获取整个Broker集群的路由信息，从而进行消息的投递和消费

#### 3.2 路由注册

NameServer通常也是以集群的方式部署，不过，NameServer是**无状态的**，即`NameServer集群中的各个节点间是无差异的，各节点间相互不进行信息通讯`。

那各节点中的数据是如何进行数据同步的呢？

+ 在Broker节点启动时，轮询NameServer列表，与每个NameServer节点建立长连接，发起注册请求。在NameServer内部维护着⼀个Broker列表，用来动态存储Broker的信息。  

Broker节点为了证明自己是活着的，为了维护与NameServer间的长连接，会将最新的信息以心跳包的方式上报给NameServer，每30秒发送一次心跳。心跳包中包含 BrokerId、Broker地址(IP+Port)、Broker名称、Broker所属集群名称等等。NameServer在接收到心跳包后，会更新心跳时间戳，记录这个Broker的最新存活时间。  

>  优点：NameServer集群搭建简单，扩容简单  
>
> 缺点：对于Broker，必须明确指出所有NameServer地址。否则未指出的将不会去注册。也正因为如此，NameServer并不能随便扩容。因为，若Broker不重新配置，新增的NameServer对于Broker来说是不可见的，其不会向这个NameServer进行注册  

#### 3.3 路由剔除  

由于Broker关机、宕机或网络抖动等原因，NameServer没有收到Broker的心跳，NameServer可能会将其从Broker列表中剔除。  

NameServer中有⼀个定时任务，每隔10秒就会扫描⼀次Broker表，查看每一个Broker的最新心跳时间戳距离当前时间是否超过120秒，如果超过，则会判定Broker失效，然后将其从Broker列表中剔除。  

> 扩展：对于RocketMQ日常运维工作，例如Broker升级，需要停掉Broker的工作。OP需要怎么做？
>
> + OP需要将Broker的读写权限禁掉。一旦client(Consumer或Producer)向broker发送请求，都会收到broker的NO_PERMISSION响应，然后client会进行对其它Broker的重试。
> + 当OP观察到这个Broker没有流量后，再关闭它，实现Broker从NameServer的移除。
>   OP：运维工程师
>   SRE：Site Reliability Engineer，现场可靠性工程师  

#### 3.4 路由发现  

RocketMQ的路由发现采用的是**Pull模型**。当Topic路由信息出现变化时，NameServer不会主动推送给客户端，而是客户端定时拉取主题最新的路由。默认客户端每30秒会拉取一次最新的路由。  

1. push模型：推送模型。其实时性较好，是一个`发布-订阅`模型，需要维护一个长连接。而长连接的维护是需要资源成本的。该模型适合于的场景：
   + 实时性要求较高
   + Client数量不多，Server数据变化较频繁
2. Pull模型：拉取模型。存在的问题是，实时性较差。
3. Long Polling模型：长轮询模型。其是对Push与Pull模型的整合，充分利用了这两种模型的优势，屏蔽了它们的劣势。  

#### 3.5 客户端NameServer选择策略  

这里的客户端指的是Producer与Consumer 

客户端在配置时必须要写上NameServer集群的地址

客户端首先会生产一个随机数，然后再与NameServer节点数量取模，此时得到的就是所要连接的节点索引，然后就会进行连接。如果连接失败，则会采用round-robin策略，逐个尝试着去连接其它节点  

首先采用的是**随机策略**进行的选择，失败后采用的是**轮询策略**。

## 4 Broker  

#### 4.1 功能介绍  

Broker充当着**消息中转角色，负责存储消息、转发消息**。

Broker在RocketMQ系统中负责**接收并存储从生产者发送来的消息**，同时为消费者的拉取请求作准备。

Broker同时也存储着消息相关的元数据，包括消费者组消费进度偏移offset、主题、队列等。  

#### 4.2 模块构成  

![](/消息队列/RocketMQ/images/Broker Server.png)

+ **Remoting Module**：**整个Broker的实体**，负责处理来自clients端的请求。而这个Broker实体则由以下模块构成。
+ **Client Manager**：客户端管理器。负责接收、解析客户端(Producer/Consumer)请求，管理客户端。例如，维护Consumer的Topic订阅信息
+ **Store Service**：存储服务。提供方便简单的API接口，处理消息存储到物理硬盘和消息查询功能。
+ **HA Service**：高可用服务，提供Master Broker 和 Slave Broker之间的数据同步功能。
+ **Index Service**：索引服务。根据特定的Message key，对投递到Broker的消息进行索引服务，同时也提供根据Message Key对消息进行快速查询的功能。  

#### 4.3 集群部署  

![](/消息队列/RocketMQ/images/集群架构.png)

为了增强Broker性能与吞吐量，Broker一般都是以集群形式出现的。各集群节点中可能存放着相同Topic的不同Queue。

如果某Broker节点宕机，如何保证数据不丢失呢。将每个Broker集群节点进行横向扩展，即将Broker节点再建为一个HA集群，解决单点问题。
Broker节点集群是一个主从集群，即集群中具有Master与Slave两种角色。

Master负责处理**读写操作请求**，Slave负责对Master中的数据进行备份。

当Master挂掉了，Slave则会自动切换为Master去工作。所以这个Broker集群是主备集群。一个Master可以包含多个Slave，但一个Slave只能隶属于一个Master。

Master与Slave 的对应关系是通过指定**相同的BrokerName、不同的BrokerId 来确定的**。BrokerId为0表示Master，非0表示Slave。每个Broker与NameServer集群中的所有节点建立长连接，定时注册Topic信息到所有NameServer。  

## 5 工作流程  

#### 5.1 具体流程  

1. 启动NameServer，NameServer启动后开始监听端口，等待Broker、Producer、Consumer连接。
2. 启动Broker时，Broker会与所有的NameServer建立并保持长连接，然后每30秒向NameServer定时发送心跳包。
3. 发送消息前，可以先创建Topic，**创建Topic时需要指定该Topic要存储在哪些Broker上**，当然，在创建Topic时也会将Topic与Broker的关系写入到NameServer中。不过，这步是可选的，也可以在发送消息时自动创建Topic。
4. Producer发送消息，启动时先跟NameServer集群中的其中一台建立长连接，并从NameServer中获取路由信息，即当前发送的Topic消息的Queue与Broker的地址（IP+Port）的映射关系。然后根据算法策略从队选择一个Queue，与队列所在的Broker建立长连接从而向Broker发消息。当然，在获取到路由信息后，Producer会首先将路由信息缓存到本地，再每30秒从NameServer更新一次路由信息。
5. Consumer跟Producer类似，跟其中一台NameServer建立长连接，获取其所订阅Topic的路由信息，然后根据算法策略从路由信息中获取到其所要消费的Queue，然后直接跟Broker建立长连接，开始消费其中的消息。Consumer在获取到路由信息后，同样也会每30秒从NameServer更新一次路由信息。不过不同于Producer的是，Consumer还会向Broker发送心跳，以确保Broker的存活状态  

#### 5.2 Topic的创建模式  

手动创建Topic时，有两种模式：

1. 集群模式：该模式下创建的Topic在该集群中，所有Broker中的Queue数量是相同的。
2. Broker模式：该模式下创建的Topic在该集群中，每个Broker中的Queue数量可以不同。  

自动创建Topic时，默认采用的是Broker模式，会为每个Broker默认创建4个Queue  

#### 5.3 读/写队列  

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

#### 1.1 复制策略  

复制策略是Broker的Master与Slave间的数据同步方式。分为同步复制与异步复制：  

+ **同步复制**：消息写入master后，master会等待slave同步数据成功后才向producer返回成功ACK
+ **异步复制**：消息写入master后，master立即向producer返回成功ACK，无需等待slave同步数据成功  

**异步复制策略会降低系统的写入延迟，RT变小，提高了系统的吞吐量**  

#### 1.2 刷盘策略  

刷盘策略指的是broker中消息的落盘方式，即**消息发送到broker内存后消息持久化到磁盘的方式**。分为同步刷盘与异步刷盘：  

+ **同步刷盘**：当消息持久化到broker的磁盘后才算是消息写入成功。
+ **异步刷盘**：当消息写入到broker的内存后即表示消息写入成功，无需等待消息持久化到磁盘。  

**异步刷盘策略会降低系统的写入延迟，RT变小，提高了系统的吞吐量**

+ 消息写入到Broker的内存，一般是写入到了PageCache
+ 对于异步 刷盘策略，消息会写入到PageCache后立即返回成功ACK。但并不会立即做落盘操作，而是当PageCache到达一定量时会自动进行落盘。  

## 2 Broker集群模式  

#### 2.1 单Master

只有一个broker（其本质上就不能称为集群）。这种方式也只能是在测试时使用，生产环境下不能使用，因为存在单点问题。  

#### 2.2 多Master  

broker集群仅由多个master构成，不存在Slave。**同一Topic的各个Queue会平均分布在各个master节点上。**  

+ 优点：配置简单，单个Master宕机或重启维护对应用无影响，在磁盘配置为RAID10时，即使机器宕机不可恢复情况下，由于RAID10磁盘非常可靠，消息也不会丢（异步刷盘丢失少量消息，同步刷盘一条不丢），性能最高；如果没有配置RAID10磁盘，一旦出现某Master宕机，则会发生大量消息丢失的情况  
+ 缺点：单台机器宕机期间，这台机器上未被消费的消息在机器恢复之前不可订阅（不可消费），消息实时性会受到影响。  

#### 2.3 多Master多Slave模式-异步复制  

broker集群由多个master构成，每个master又配置了多个slave（在配置了RAID磁盘阵列的情况下，一个master一般配置一个slave即可）。

master与slave的关系是主备关系，即**master负责处理消息的读写请求，而slave仅负责消息的备份与master宕机后的角色切换。**  

异步复制：复制策略中的异步复制策略，即消息写入master成功后，master立即向producer返回成功ACK，无需等待slave同步数据成功  

该模式的最大特点：**当master宕机后slave能够自动切换为master**。不过由于slave从master的同步具有短暂的延迟（毫秒级），所以当master宕机后，**这种异步复制方式可能会存在少量消息的丢失问题。**  

#### 2.4 多Master多Slave模式-同步双写  

该模式：**多Master多Slave模式的同步复制实现**。

所谓同步双写，指的是消息写入master成功后，master会等待slave同步数据成功后才向producer返回成功ACK，**即master与slave都要写入成功后才会返回成功ACK，也即双写。**  

该模式与异步复制模式相比，优点是消息的**安全性更高，不存在消息丢失的情况**。但单个消息的RT略高，从而导致性能要略低（大约低10%）  

该模式存在一个大的问题：对于目前的版本，**Master宕机后，Slave不会自动切换到Master。**  

#### 2.5 最佳实践  

一般会为Master配置RAID10磁盘阵列，然后再为其配置一个Slave。即利用了RAID10磁盘阵列的高效、安全性，又解决了可能会影响订阅的问题。  

# 三. 工作原理

## 1. 消息的生产

#### 1.1 消息的生产过程

Producer可以将**消息写入到某Broker中的某Queue**中，其经历了如下过程：

1. Producer发送消息之前，会先向NameServer发出**获取消息Topic的路由信息**的请求
2. NameServer返回该**Topic的路由表**及**Broker列表**
3. Producer根据代码中指定的Queue选择策略，从Queue列表中选出一个队列，用于后续存储消息
4. Produer对消息做一些特殊处理，例如，消息本身超过4M，则会对其进行压缩
5. Producer向选择出的Queue所在的Broker发出RPC请求，将消息发送到选择出的Queue

**路由表**：实际是一个Map，key为Topic名称，value是一个QueueData实例列表。QueueData并不是一个Queue对应一个QueueData，而是一个Broker中该Topic的所有Queue对应一个QueueData。即，只要涉及到该Topic的Broker，一个Broker对应一个QueueData。QueueData中包含brokerName。简单来说，**路由表的key为Topic名称，value则为所有涉及该Topic的BrokerName列表。**

**Broker列表**：其实际也是一个Map。key为brokerName，value为BrokerData。一套brokerName名称相同的Master-Slave小集群对应一个BrokerData。BrokerData中包含brokerName及一个map。该map的key为brokerId，value为该broker对应的地址。brokerId为0表示该broker为Master，非0表示Slave。

#### 1.2 Queue选择算法

对于无序消息，其Queue选择算法，也称为消息投递算法，常见的有两种：

##### <u>轮询算法</u>

默认选择算法。该算法保证了每个Queue中可以均匀的获取到消息

该算法存在一个问题：由于某些原因，在某些Broker上的Queue可能投递延迟较严重。从而导致Producer的缓存队列中出现较大的消息积压，影响消息的投递性能。

##### <u>最小投递延迟算法</u>

该算法会统计每次消息投递的时间延迟，然后根据统计出的结果将消息投递到时间延迟最小的Queue。如果延迟相同，则采用轮询算法投递。该算法可以有效提升消息的投递性能。

该算法也存在一个问题：消息在Queue上的分配不均匀。投递延迟小的Queue其可能会存在大量的消息。而对该Queue的消费者压力会增大，降低消息的消费能力，可能会导致MQ中消息的堆积。

## 2. 消息的存储

RocketMQ中的消息存储在本地文件系统中，这些相关文件默认在：**当前用户主目录下的store目录中**。

![](/消息队列/images/消息存储目录.png)

+ abort：该文件在Broker启动后会自动创建，正常关闭Broker，该文件会自动消失。若在没有启动Broker的情况下，发现这个文件是存在的，则说明之前Broker的关闭是非正常关闭。
+ checkpoint：其中存储着commitlog、consumequeue、index文件的最后刷盘时间戳
+ commitlog：其中存放着commitlog文件，而消息是写在commitlog文件中的
+ config：存放着Broker运行期间的一些配置数据
+ consumequeue：其中存放着consumequeue文件，队列就存放在这个目录中
+ index：其中存放着消息索引文件indexFile
+ lock：运行期间使用到的全局资源锁

#### 2.1 commitlog文件

在很多资料中commitlog目录中的文件简单就称为commitlog文件。但在源码中，该文件被命名为mappedFile。

##### <u>目录与文件</u>

commitlog目录中存放着很多的mappedFile文件，**当前Broker中的所有消息都是落盘到这些mappedFile文件中的**。mappedFile文件大小为1G（小于等于1G），文件名由20位十进制数构成，表示**当前文件的第一条消息的起始位移偏移量**。

一个Broker中仅包含一个commitlog目录，所有的mappedFile文件都是存放在该目录中的。即无论当前Broker中存放着多少Topic的消息，这些消息都是被顺序写入到了mappedFile文件中的。**这些消息在Broker中存放时并没有被按照Topic进行分类存放。**

**mappedFile文件是顺序读写的文件，所有其访问效率很高**。无论是SSD磁盘还是SATA磁盘，通常情况下，顺序存取效率都会高于随机存取。

##### <u>消息单元</u>

![](/消息队列/images/消息单元.png)

mappedFile文件内容由一个个的消息单元构成。

每个消息单元中包含消息总长度MsgLen、消息的物理位置physicalOffset、消息体内容Body、消息体长度BodyLength、消息主题Topic、Topic长度TopicLength、消息生产者BornHost、消息发送时间戳BornTimestamp、消息所在的队列QueueId、消息在Queue中存储的偏移量QueueOffset等近20余项消息相关属性。

#### 2.2 consumequeue

![](/消息队列/images/consumequeue.png)

##### <u>目录与文件</u>

![](/消息队列/images/commitlog与consumequeue.png)

为了提高效率，会为每个Topic在~/store/consumequeue中创建一个目录，目录名为Topic名称。**在该Topic目录下，会再为每个该Topic的Queue建立一个目录，目录名为queueId**。每个目录中存放着若干consumequeue文件，**consumequeue文件是commitlog的索引文件，可以根据consumequeue定位到具体的消息**

consumequeue文件名也由20位数字构成，表示当前文件的第一个索引条目的起始位移偏移量。与mappedFile文件名不同的是，其后续文件名是固定的。因为consumequeue文件大小是固定不变的。

##### <u>索引条目</u>

![](/消息队列/images/consumequeue索引条目.png)

每个consumequeue文件可以包含30w个索引条目，每个索引条目包含了三个消息重要属性：消息在mappedFile文件中的偏移量CommitLog Offset、消息长度、消息Tag的hashcode值。这三个属性占20个字节，所以每个文件的大小是固定的30w * 20字节。

一个consumequeue文件中所有消息的Topic一定是相同的。但每条消息的Tag可能是不同的。

#### 2.3 对文件的读写

![](/消息队列/images/文件读写.png)

##### <u>消息写入</u>

一条消息进入到Broker后经历了以下几个过程才最终被持久化。

+ Broker根据queueId，获取到该消息对应索引条目要在consumequeue目录中的写入偏移量，即QueueOffset
+ 将queueId、queueOffset等数据，与消息一起封装为消息单元
+ 将消息单元写入到commitlog
+ 同时，形成消息索引条目
+ 将消息索引条目分发到相应的consumequeue

##### <u>消息拉取</u>

当Consumer来拉取消息时会经历以下几个步骤：

+ Consumer获取到其要消费消息所在Queue的**消费偏移量offset**，计算出其要消费消息的**消息offset**。

> 消费offset即消费进度，consumer对某个Queue的消费offset，即消费到了该Queue的第几条消息
> 消息offset = 消费offset + 1

+ Consumer向Broker发送拉取请求，其中会包含其要拉取消息的Queue、消息offset及消息Tag。
+ Broker计算在该consumequeue中的queueOffset。queueOffset = 消息offset * 20字节
+ 从该queueOffset处开始向后查找第一个指定Tag的索引条目。
+ 解析该索引条目的前8个字节，即可定位到该消息在commitlog中的commitlog offset
+ 从对应commitlog offset中读取消息单元，并发送给Consumer

##### 性能提升

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

#### 3.1 索引条目结构

![](/消息队列/images/indexFile.png)

每个Broker中会包含一组indexFile，每个indexFile都是以一个时间戳命名的（**这个indexFile被创建时的时间戳**）。

每个indexFile文件由三部分构成：indexHeader，slots槽位，indexes索引数据。

每个indexFile文件中包含**500w**个slot槽。而每个slot槽又可能会挂载很多的index索引单元。

---

![](/消息队列/images/indexHeader.png)

+ beginTimestamp：该indexFile中第一条消息的存储时间
+ endTimestamp：该indexFile中最后一条消息存储时间
+ beginPhyoffset：该indexFile中第一条消息在commitlog中的偏移量commitlog offset
+ endPhyoffset：该indexFile中最后一条消息在commitlog中的偏移量commitlog offset
+ hashSlotCount：已经填充有index的slot数量（并不是每个slot槽下都挂载有index索引单元，这里统计的是所有挂载了index索引单元的slot槽的数量）
+ indexCount：该indexFile中包含的索引单元个数（统计出当前indexFile中所有slot槽下挂载的所有index索引单元的数量之和）

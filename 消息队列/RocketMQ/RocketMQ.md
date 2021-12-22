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
+ **路由信息管理**：每个NameServer中都保存着Broker集群的整个路由信息和用于客户端查询的队列信息。Producer和Conumser通过NameServer可以获取整个Broker集群的路由信息，从而进行消息的投递和消费

#### 3.2 路由注册


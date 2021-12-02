# Kafka的使用场景

1. 日志收集：可以用kafka收集各种服务的log。通过kafka以统一接口服务的方式开放给各种consumer。
2. 消息系统：解耦生产者和消费者，缓存消息等
3. 用户活动跟踪：kafka经常被用来记录web用户和app用户的各种活动，如浏览网页，搜索，点击等活动。这些活动信息被各种服务器发布到kafka的topic重。然后订阅者通过订阅这些topic来做实时的监控分析
4. 运营指标：kafka也经常用来记录运营监控数据。包括收集各种分布式应用数据，生产各种操作的集中反馈，例如：告警和报告

# Kafka基本概念

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


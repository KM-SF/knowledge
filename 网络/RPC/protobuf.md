Protocol buffers 是⼀种语⾔中⽴，平台⽆关，可扩展的序列化数据的格式，可⽤于通信协议，数据存储
等。
Protocol buffers 在序列化数据⽅⾯，它是灵活的，⾼效的。相⽐于 XML 来说，Protocol buffers 更加
⼩巧，更加快速，更加简单。⼀旦定义了要处理的数据的数据结构之后，就可以利⽤ Protocol buffers 的
代码⽣成⼯具⽣成相关的代码。甚⾄可以在⽆需重新部署程序的情况下更新数据结构。只需使⽤ Protobuf
对数据结构进⾏⼀次描述，即可利⽤各种不同语⾔或从各种不同数据流中对你的结构化数据轻松读写。
Protocol buffers 很适合做数据存储或 RPC 数据交换格式。可⽤于通讯协议、数据存储等领域的语⾔⽆
关、平台⽆关、可扩展的序列化结构数据格式。

protobuf进行编码是：会转化成二进制数（动态字节大小），然后只保存value值。通过标志位判断是第几个元素。



Service api

1. unary api（一元 普通模式）：一请求一响应
2. client stream api（客户端流模式）：客户端多次请求，服务端汇总一次响应
3. server stream api（服务端流模式）：客户端一次请求，服务端多次响应
4. bidirectional stream api（双端流）：客户端多请求，服务端多响应
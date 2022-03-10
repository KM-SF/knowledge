## gRPC是什么？

**所谓RPC(remote procedure call 远程过程调用)框架实际是提供了一套机制，使得应用程序之间可以进行通信，而且也遵从server/client模型。使用的时候客户端调用server端提供的接口就像是调用本地的函数一样。**

RPC 框架的目标就是让远程服务调用更加简单、透明，RPC 框架负责屏蔽底层的传输方式（TCP 或者 UDP）、序列化方式（XML/Json/ 二进制）和通信细节。服务调用者可以像调用本地接口一样调用远程的服务提供者，而不需要关心底层通信细节和调用过程。

gRPC 是一个高性能、开源和通用的 RPC 框架，面向服务端和移动端，基于 HTTP/2 设计。

如下图所示就是一个典型的RPC结构图。

![](/网络/images/grpc.webp)

## 基本概念概览

![](/网络/images/gRPC概念图.jpg)

**Service(定义)：**自定义对外暴露的服务（接口）

**RPC：**远程调用

Client：客户端

Stub：客户端实例，存放服务端的地址消息，再将客户端的请求参数打包成网络消息，然后通过网络远程发送给服务方。

Channel：提供一个与特定 gRPC server 的主机和端口建立的连接。

**Service：**需要实现对应的 RPC，所有的RPC组成了Service。接收客户端发送过来的消息，将消息解包，并调用本地的方法。

Server：**Server** 的创建需要一个 **Builder**，添加上监听的地址和端口，**注册**上该端口上绑定的服务，最后构建出 Server 并启动

**RPC 和 API 的区别**：RPC (Remote Procedure Call) 是一次远程过程调用的整个动作，而 API (Application Programming Interface) 是不同语言在实现 RPC 中的具体接口。一个 RPC 可能对应多种 API，比如同步的、异步的、回调的。一次 RPC 是对某个 API 的一次调用

## gRPC 特点

+ 语言中立，支持多种语言；
+ 基于 IDL （接口定义语言）文件定义服务，通过 proto3 工具生成指定语言的数据结构、服务端接口以及客户端 Stub；
+ 通信协议基于标准的 HTTP/2 设计，支持双向流、消息头压缩、单 TCP 的多路复用、服务端推送等特性，这些特性使得 gRPC 在移动端设备上更加省电和节省网络流量；
+ 序列化支持 PB（Protocol Buffer）和 JSON，PB 是一种语言无关的高性能序列化框架，基于 HTTP/2 + PB, 保障了 RPC 调用的高性能。
+ 支持双向流式的请求和响应，对批量处理，低延时场景友好
+ 超时，重试（退避算法），拦截器，命名解析，负载均衡，安全连接

## gRPC四种通信方式

1. unary api（一元 普通模式）：一请求一响应。有队头阻塞问题。
2. client stream api（客户端流模式）：客户端多次请求，服务端汇总一次响应
3. server stream api（服务端流模式）：客户端一次请求，服务端多次响应
4. bidirectional stream api（双端流）：客户端多请求，服务端多响应

## gRPC有什么好处以及在什么场景下需要用gRPC

既然是server/client模型，那么我们直接用restful api不是也可以满足吗，为什么还需要RPC呢？下面我们就来看看RPC到底有哪些优势

### gRPC vs. Restful API

gRPC和restful API都提供了一套通信机制，用于server/client模型通信，而且它们都使用http作为底层的传输协议(严格地说, gRPC使用的http2.0，而restful api则不一定)。不过gRPC还是有些特有的优势，如下：

- gRPC可以通过protobuf来定义接口，从而可以有更加严格的接口约束条件。关于protobuf可以参见笔者之前的小文[Google Protobuf简明教程](https://www.jianshu.com/p/b723053a86a6)
- 另外，通过protobuf可以将数据序列化为二进制编码，这会大幅减少需要传输的数据量，从而大幅提高性能。
- gRPC可以方便地支持流式通信(理论上通过http2.0就可以使用streaming模式, 但是通常web服务的restful api似乎很少这么用，通常的流式数据应用如视频流，一般都会使用专门的协议如HLS，RTMP等，这些就不是我们通常web服务了，而是有专门的服务器应用。）

总结：接口有更严格的约束。更安全。性能更好 。

### 使用场景

+ 需要对接口进行严格约束的情况，比如我们提供了一个公共的服务，很多人，甚至公司外部的人也可以访问这个服务，这时对于接口我们希望有更加严格的约束，我们不希望客户端给我们传递任意的数据，尤其是考虑到安全性的因素，我们通常需要对接口进行更加严格的约束。这时gRPC就可以通过protobuf来提供严格的接口约束。
+ 对于性能有更高的要求时。有时我们的服务需要传递大量的数据，而又希望不影响我们的性能，这个时候也可以考虑gRPC服务，因为通过protobuf我们可以将数据压缩编码转化为二进制格式，通常传递的数据量要小得多，而且通过http2我们可以实现异步的请求，从而大大提高了通信效率。

## 协议

### HTTP2.0

### 压缩

简述 gRPC 处理压缩的流程，以及具体到不同级别上的压缩设置方法。处理流程和是哪端（Client 还是 Server）没有关系，而是区分 Incoming 和 Outgoing：

压缩的目的是为了减少带宽。调用级或消息级的压缩设置可以防止 CRIME/BEAST 攻击

配置压缩算法的两种场景： 创建 Channel 的时候指定；Unary RPC 的 Context 和 Streaming RPC 的 Writer（只能禁用）

支持非对称的压缩算法，是指接收端可以选择不使用或使用不同的压缩算法。如果发出端使用某种压缩算法，而受到了带 `grpc-accept-encoding` 的 `UNIMPLEMENTED` 错误，可能是Server端不支持这种压缩算法。

压缩包括**等级**和**算法**，而等级范围取决于算法，比如 "low" 会映射到 "gzip -3"。

#### **流入** 

**流入** 的处理主要取决于 Incoming Msg，接收端处理流程相对简单：

是否有 `grpc-encoding` -> 是否是合法的压缩算法 -> 压缩算法是否被禁用 -> 是否在 `grpc-accept-encoding` -> 解压缩

其中 `accept-encoding` 是说客户端可以接受的编码方式，所以即使不一致也只是记录一下。

#### 流出

**流出** 的处理则取决于发出端自身的设置以及对端可以接受压缩算法，所以逻辑相对**流入**会更复杂一些

判断**消息级**是否打开 `GRPC_WRITE_NO_COMPRESS` 标志-> 判断 metadata 中是否有压缩算法 -> 判断是否为 ServerChannel && 是否有设置默认的**调用级**压缩 -> 是否有设置默认的**Channel级**压缩 -> 判断压缩等级 -> 压缩

如上所述，压缩有三个级别**Channel级**、**调用级**、**消息级**，前两个级别可以设置压缩**算法**和**等级**，而消息级只能禁用压缩。

### keepalive

gRPC 的 keepalive 是通过 [HTTP2 PING](https://datatracker.ietf.org/doc/html/rfc7540#section-6.7) 来检查当前 Channel 是否工作的一种机制。文档中介绍了 keepalive 使用时的相关参数。

4 个参数是 Client 和 Server端都会用到的

- GRPC_ARG_KEEPALIVE_TIME_MS
- GRPC_ARG_KEEPALIVE_TIMEOUT_MS
- GRPC_ARG_KEEPALIVE_PERMIT_WITHOUT_CALLS
- GRPC_ARG_HTTP2_MAX_PINGS_WITHOUT_DATA (不规范，计划弃用)

有两个是只有服务端会使用的：

- GRPC_ARG_HTTP2_MIN_RECV_PING_INTERVAL_WITHOUT_DATA_MS
- GRPC_ARG_HTTP2_MAX_PING_STRIKES

服务端的这两个参数是为了限制客户端过度的发送 PING 的：如果两次 PING 时间过短，第二次的 PING 会被视为恶意的 PING 并被记录到 PING strike 的计数器中。如果对端的 PIN strike 超过了最后一个参数，则会直接回复 携带 “too_many_pings”的信息 GOAWAY 帧。

## 连接

gRPC 中 Channel 的连接状态，包括状态语义、对 RPC 的影响、相关 API

只有 Client 中有 Channel 的概念，因此这里讨论的连接状态也是 Client 的概念。

连接状态在代码中对应枚举类型 `grpc_connectivity_state`，共 `IDLE`, `CONNECTING`, `READY`, `TRANSIENT_FAILURE`, `SHUTDOWN` 5 种状态。根据文档中的描述，通过状态图来描述它们的关系。

![](/网络/images/grpc连接状态.svg)

- 图中开始状态指向IDLE 的原因：
  - 类 ClientChannel 中维护着一个 `ConnectivityStateTracker state_tracker_` 成员变量，用来追踪 Channel 状态。ClientChannel 的构造函数中，将 state_tracker_ 的状态设置为了 `IDLE`
  - 初始状态没有任何 RPC 的时候，此时应该为 IDLE
- `TRANSIENT_FAILURE` 和 `CONNNECTING` 之间的转换，类似于 TCP SYN 重传，是重试时间是指数增加的。
- 所有的状态都会因为应用调用 `shutdown()` 来将 Channel 的状态转换成 `SHUTDOWN`
- `IDLE_TIMEOUT` 是控制转换到 `IDLE` 超时的变量，不是状态
- `GO_AWAY` 是 HTTP/2 的帧

TRANSIENT_FAILURE 会在一定的时间间隔之后，进行重连，会改变到 CONNECTING 状态。

Channel 处于 TRANSIENT_FAILURE、SHUTDOWN 状态会无法及时传输 RPC，默认的实现方式是的立马返回失败，曾被称之为 “fail fast”；Channel 处于 CONNECTING、READY、IDLE状态的时候，RPC 不应该失败。

## 服务发现

gRPC 使用 DNS 作为默认的名字系统，同时也提供 API 支持使用其他名字系统，不同语言的 Client 库以插件的机制来进行支持。

Resolver 插件介于权威解析服务和 Client 库之间，能够返回名字对应的**服务器列表**和**服务配置**，还可以携带与地址相关的 key-value 属性对集合。

服务配置是一种**允许服务提供者想所有 Client 端发布配置参数**的机制。服务配置与否个服务器名字关联，需要上边提到的 name resolver plugin 的配合，在接收到解析服务地址的同时，将服务配置一并下发给客户端。

## 负载均衡

gRPC 使用的负载均衡是基于调用的，而不是基于连接的。

负载均衡的方法：

- 代理模型：所有流量都经过一个代理。需要额外的资源、增加了RPC延迟，但是客户端实现会相对简单
- 客户端感知：造成了thicker-client，每种语言都需要在客户端实现许多复杂的负载均衡策略。客户端需要配置所有的服务列表。
- 扩展负载均衡服务：客户端只实现简单、可移植的负载均衡算法，复杂的负载均衡算法由额外的服务提供。客户端需要配置负载均衡的服务器列表。

gRPC 就是使用的最后一种策略，既扩展负载均衡：客户端中使用简单的负载均衡策略，由 `grpclb` 命名空间中的函数提供，其他的复杂负载均衡策略均应该在扩展负载均衡器中实现。

Client 跟 Load Balancer 之间的通信使用通过 `rpc BalanceLoad`进行通信的，返回是一个 Server 列表，Client 收到之后会建立所有跟下游的连接。协议详见 [load_balancer.proto](https://github.com/grpc/grpc/blob/master/src/proto/grpc/lb/v1/load_balancer.proto)

Server 端是主动向 Load Balancer 报告自己的负载情况的，通过 `rpc ReportLoad` 进行上报。

## 服务端反射

**gRPC 服务器反射** 可以提供服务器上可公开访问服务的相关信息，包括：

- 列举所有的服务名 list_services
- 列举指定服务中的所有 RPC 定义 -、
- 查询指定 RPC 的定义 |--- file_containing_symbol
- 查询指定消息 (Message) 的定义 -·
- 根据 .proto 文件名获取协议内容 file_by_filename
- TODO file_containing_extension 、all_extension_numbers_of_type 的作用

服务器的反射机制能够让 Client 在运行时构建 RPC 的请求和响应，而无需预编译服务信息。

管理 Client 与反射服务之间的通信和接收信息的存储，而在 Client 内部，可以将此作为本地的描述符数据库。**目前库不支持除了protobuf之外协议的反射**。

------

参考：

https://www.jianshu.com/p/9c947d98e192
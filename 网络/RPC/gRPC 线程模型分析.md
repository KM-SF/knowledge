# RPC 线程模型

## RPC 性能三原则

影响 RPC 框架性能的三个核心要素如下：

1. **I/O 模型：**用什么样的通道将数据发送给对方，BIO、NIO 或者 AIO，IO 模型在很大程度上决定了框架的性能；
2. **协议：**采用什么样的通信协议，Rest+ JSON 或者基于 TCP 的私有二进制协议，协议的选择不同，性能模型也不同，相比于公有协议，内部私有二进制协议的性能通常可以被设计的更优；
3. **线程：**数据报如何读取？读取之后的编解码在哪个线程进行，编解码后的消息如何派发，通信线程模型的不同，对性能的影响也非常大。

在以上三个要素中，线程模型对性能的影响非常大。随着硬件性能的提升，CPU 的核数越来越越多，很多服务器标配已经达到 32 或 64 核。

通过多线程并发编程，可以充分利用多核 CPU 的处理能力，提升系统的处理效率和并发性能。但是如果线程创建或者管理不当，频繁发生线程上下文切换或者锁竞争，反而会影响系统的性能。

线程模型的优劣直接影响了 RPC 框架的性能和并发能力，它也是大家选型时比较关心的技术细节之一。下面我们一起来分析和学习下 gRPC 的线程模型。

# gRPC 线程模型分析

gRPC 的线程模型主要包括服务端线程模型和客户端线程模型，其中服务端线程模型主要包括：

- 服务端监听和客户端接入线程（HTTP /2 Acceptor）
- 网络 I/O 读写线程
- 服务接口调用线程

客户端线程模型主要包括：

- 客户端连接线程（HTTP/2 Connector）
- 网络 I/O 读写线程
- 接口调用线程
- 响应回调通知线程

## 服务端线程模型

gRPC 服务端线程模型整体上可以分为两大类：

- 网络通信相关的线程模型，基于 Netty4.1 的线程模型实现
- 服务接口调用线程模型，基于 JDK 线程池实现

### 服务端线程模型概述

gRPC 服务端线程模型和交互图如下所示：

![](/网络/images/gRPC 服务端线程模型和交互图.png)

其中，HTTP/2 服务端创建、HTTP/2 请求消息的接入和响应发送都由 Netty 负责，gRPC 消息的序列化和反序列化、以及应用服务接口的调用由 gRPC 的 SerializingExecutor 线程池负责。

### I/O 通信线程模型

gRPC 的做法是服务端监听线程和 I/O 线程分离的 Reactor 多线程模型

![](/网络/images/gRPC-IO 通信线程模型.png)

流程如下：

**步骤 1：**业务线程发起创建服务端操作，在创建服务端的时候实例化了 2 个 EventLoopGroup，1 个 EventLoopGroup 实际就是一个 EventLoop 线程组，负责管理 EventLoop 的申请和释放。

EventLoopGroup 管理的线程数可以通过构造函数设置，如果没有设置，默认取 -Dio.netty.eventLoopThreads，如果该系统参数也没有指定，则为“可用的 CPU 内核 * 2”。

bossGroup 线程组实际就是 Acceptor 线程池，负责处理客户端的 TCP 连接请求，如果系统只有一个服务端端口需要监听，则建议 bossGroup 线程组线程数设置为 1。workerGroup 是真正负责 I/O 读写操作的线程组，通过 ServerBootstrap 的 group 方法进行设置，用于后续的 Channel 绑定。

**步骤 2：**服务端 Selector 轮询，监听客户端连接（NioEventLoop 类）

**步骤 3：**如果监听到客户端连接，则创建客户端 SocketChannel 连接，从 workerGroup 中随机选择一个 NioEventLoop 线程，将 SocketChannel 注册到该线程持有的 Selector，代码示例如下（NioServerSocketChannel 类）

**步骤 4：**通过调用 EventLoopGroup 的 next() 获取一个 EventLoop（NioEventLoop），用于处理网络 I/O 事件。

Netty 线程模型的核心是 NioEventLoop，它的职责如下：

1. 作为服务端 Acceptor 线程，负责处理客户端的请求接入
2. 作为 I/O 线程，监听网络读操作位，负责从 SocketChannel 中读取报文
3. 作为 I/O 线程，负责向 SocketChannel 写入报文发送给对方，如果发生写半包，会自动注册监听写事件，用于后续继续发送半包数据，直到数据全部发送完成
4. 作为定时任务线程，可以执行定时任务，例如链路空闲检测和发送心跳消息等
5. 作为线程执行器可以执行普通的任务线程（Runnable）NioEventLoop 处理网络 I/O 操作的

### 服务调度线程模型

gRPC 服务调度线程主要职责如下：

- 请求消息的反序列化，主要包括：HTTP/2 Header 的反序列化，以及将 PB(Body) 反序列化为请求对象；
- 服务接口的调用，method.invoke(非反射机制)；
- 将响应消息封装成 WriteQueue.QueuedCommand，写入到 Netty Channel 中，同时，对响应 Header 和 Body 对象做序列化
- 服务端调度的核心是 SerializingExecutor，它同时实现了 JDK 的 Executor 和 Runnable 接口，既是一个线程池，同时也是一个 Task。

当服务端接收到客户端 HTTP/2 请求消息时，由 Netty 的 NioEventLoop 线程切换到 gRPC 的 SerializingExecutor，进行消息的反序列化、以及服务接口的调用

![](/网络/images/Netty IO 线程和服务调度线程的运行分工界面.png)

事实上，在实际服务接口调用过程中，NIO 线程和服务调用线程切换次数远远超过 4 次，频繁的线程切换对 gRPC 的性能带来了一定的损耗。

## 客户端线程模型

gRPC 客户端的线程主要分为三类：

1. 业务调用线程
2. 客户端连接和 I/O 读写线程
3. 请求消息业务处理和响应回调线程

### 客户端线程模型概述

gRPC 客户端线程模型工作原理如下图所示（同步阻塞调用为例）：

![](/网络/images/gRPC 客户端线程模型.png)

客户端调用主要涉及的线程包括：

- 应用线程，负责调用 gRPC 服务端并获取响应，其中请求消息的序列化由该线程负责；
- 客户端负载均衡以及 Netty Client 创建，由 grpc-default-executor 线程池负责；
- HTTP/2 客户端链路创建、网络 I/O 数据的读写，由 Netty NioEventLoop 线程负责；
- 响应消息的反序列化由 SerializingExecutor 负责，与服务端不同的是，客户端使用的是 ThreadlessExecutor，并非 JDK 线程池；
- SerializingExecutor 通过调用 responseFuture 的 set(value)，唤醒阻塞的应用线程，完成一次 RPC 调用。

### I/O 通信线程模型

相比于服务端，客户端的线程模型简单一些，它的工作原理如下：

![](/网络/images/gRPC Client IO 通信线程模型.png)

第 1 步，由 grpc-default-executor 发起客户端连接。相比于服务端，客户端只需要创建一个 NioEventLoop，因为它不需要独立的线程去监听客户端连接，也没必要通过一个单独的客户端线程去连接服务端。

第 2 步，发起连接操作，判断连接结果，如果没有连接成功，则监听连接网络操作位 SelectionKey.OP_CONNECT。如果连接成功，则调用 pipeline().fireChannelActive() 将监听位修改为 READ。代码如下（NioSocketChannel 类）：

第 3 步，由 NioEventLoop 的多路复用器轮询连接操作结果，判断连接结果，如果或连接成功，重新设置监听位为 READ（AbstractNioChannel 类）：

第 4 步，由 NioEventLoop 线程负责 I/O 读写，同服务端。

### 客户端调用线程模型

![](/网络/images/gRPC 客户端调用线程模型.png)

------

参考：

[gRPC 线程模型分析](https://d.shikey.com/jike/%E6%9E%81%E5%AE%A2%E6%97%B6%E9%97%B4%E5%B7%B2%E5%AE%8C%E7%BB%93/14%20%E6%B7%B1%E5%85%A5%E6%B5%85%E5%87%BAgRPC-%E6%9D%8E%E6%9E%97%E5%B3%B0/180312-03%20_%20gRPC%20%E7%BA%BF%E7%A8%8B%E6%A8%A1%E5%9E%8B%E5%88%86%E6%9E%90.html)
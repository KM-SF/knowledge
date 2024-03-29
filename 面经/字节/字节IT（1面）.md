### 负载均衡的算法有什么

轮询算法，随机算法，随机轮询算法，平滑加权轮询算法，最少活跃数

### select和epoll的区别

|            | epoll            | select                                                       | poll                                                         |
| ---------- | ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 时间复杂度 | O(1)             | 当有 I/O 时间发生时，不能知道是哪个 fd 触发了，只能无差别的轮询所有 fd。 O(N) | 当有 I/O 时间发生时，不能知道是哪个 fd 触发了，只能无差别的轮询所有 fd。 O(N) |
| 底层实现   | 红黑树+就绪链表  | 数组（poll 与 select 没有本质上的区别， 但是它没有最大连接数的限制，原因是它是基于链表来存储的。） | 链表（poll 与 select 没有本质上的区别， 但是它没有最大连接数的限制，原因是它是基于链表来存储的。） |
| 缺点       | 消耗的资源比较多 | 最大连接数有上限<br>需要对fd集合进行轮询扫描<br>需要将fd集合从内核和用户空间来回拷贝 | 需要对fd集合进行轮询扫描<br/>需要将fd集合从内核和用户空间来回拷贝 |

### 你们远端磁盘支持linux的ls的命令吗

不支持，但是我们可以查看到一些基本信息。磁盘剩余容量，总容量和iops

### 假设要传输一个大文件，你们怎么保证这个大文件完整的落盘

这个跟tgtd项目没关系，tgtd只是负责转发数据到后端分布式存储。由分布式存储负责完整落盘

### 为什么要使用tcp呢

因为tcp协议是可靠的

### tcp是怎么保证可靠的

1. 序号/应答机制：数据传输的顺序行
2. 超时重传机制：发送数据后，启动计时器，在超时时间内没有收到ack确认序号，会重发数据包
3. 数据头部校验：TCP保证它的头部和数据的校验和，如果数据包有差错，就丢弃数据不进行ACK
4. 滑动窗口：告诉对方，我这里的缓冲区剩余大小是多少。防止对方发送的数据量大于我缓冲区剩下的大小
5. 拥塞控制：在一方面保证了TCP数据传送的可靠性。然而如果网络非常拥堵，此时再发送数据就会加重网络负担，那么发送的数据段很可能超过了最大生存时间也没有到达接收方，就会产生丢包问题。为此TCP引入慢启动机制，先发出少量数据，就像探路一样，先摸清当前的网络拥堵状态后，再决定按照多大的速度传送数据。
6. 最大报文长度：在建立TCP的时候，会约定数据包的最大长度，超过该长度会进行切分

### 超时重传在什么情况下触发，间隔有多少

超时重传指的是在发送数据报文段后开始计时，到等待确认应答到来的那个时间间隔。如果超过这个时间间隔，仍未收到确认应答，发送端将进行数据重传。这个等待时间称为RTO(Retransmission Time-Out，超时重传时间)。

指数退避方式

第一次发送数据后，设置的超时时间是1.5s，此后每次重传增加1倍，一直到64秒

一共重传12次，大约9分钟才放弃

### 滑动窗口的大小是怎么确定的

**本质上是描述接收方的TCP数据报缓冲区大小的数据**，发送方根据这个数据来计算自己最多能发送多长的数据，如果发送方收到接收方的窗口大小为0的TCP数据报，那么发送方将停止发送数据，等到接收方发送窗口大小不为0的数据报的到来

每次发送TCP数据报文的时候都会携带上滑动窗口的大小给接收方

### 你们的tgtd能使用redis的单线程模型？

tgtd原生的模型就是redis的单epoll反应堆模型，因为单epoll反应堆模型性能达不到预期我们才改造成多reator模型

### redis中的rehash的过程

```c
// 字典
struct dict {
	dictht ht[2];   // 2个哈希表: ht[0]正常情况下使用, ht[1]在rehash时使用
    int rehashidx;  // rehash索引 (没进行rehash时，该值为-1)
}
```

- 背景：哈希表中键值对的增加/减少，都可能导致rehash（为了使哈希表的 `负载因子` 维持在合理的范围内）：一般进行2倍扩充（算法导论中的平摊分析）

- rehash过程（渐进式rehash）

  - ht[1]分配空间，新建一个空的哈希表
  - rehash索引计数器（**rehash_index**），由-1变为0，表示rehash正式开始
  - 将ht[0]中的元素，rehash重新散列到ht[1]上
    - 每次一个(key,value)键值对rehash成功后，rehash索引计数器都+1
  - 当所有的ht[0]都rehash到ht[1]中后，ht[0]被清空，此时将ht[0],ht[1]**交换**，rehash结束，最后将rehash索引设为-1

+ 在rehash过程中，**新增加的(key,value)键值对**，怎么处理？
  - 答：会直接rehash到ht[1]上，这样做，会保证ht[0]只减不增

### redis用来做排行榜，用什么数据结构比较合适

用zset比较合适，因为他是去重排序的数据结构

### zset底层的数据结构是什么，为什么能帮我们做排序

底层的数据结构是：压缩链表和跳表。当数据量超过某个阈值时，则会用跳表

### 跳表的查询时间复杂度是多少

跳表的查询是模拟二分查找法的，时间复杂度为O(lgN)

### http协议的header，你知道有什么header

请求头里主要是客户端的一些基础信息，UA（user-agent）就是其中的一部分，而响应头里是响应数据的一些信息，以及服务器要求客户端如何处理这些响应数据的指令。请求头里面的关键信息如下：

#### 1) accept

表示当前浏览器可以接受的文件类型，假设这里有 image/webp，表示当前浏览器可以支持 webp 格式的图片，那么当服务器给当前浏览器下发 webp 的图片时，可以更省流量。

#### 2) accept-encoding

表示当前浏览器可以接受的数据编码，如果服务器吐出的数据不是浏览器可接受的编码，就会产生乱码。

#### 3) accept-language

表示当前使用的浏览语言。

#### 4) Cookie

很多和用户相关的信息都存在 Cookie 里，用户在向服务器发送请求数据时会带上。例如，用户在一个网站上登录了一次之后，下次访问时就不用再登录了，就是因为登录成功的 token 放在了 Cookie 中，而且随着每次请求发送给服务器，服务器就知道当前用户已登录。

#### 5) user-agent

表示浏览器的版本信息。当服务器收到浏览器的这个请求后，会经过一系列处理，返回一个数据包给浏览器，而响应头里就会描述这个数据包的基本信息。

响应头里的关键信息有：

#### 1) content-encoding

表示返回内容的压缩编码类型，如“Content-Encoding :gzip”表示这次回包是以 gzip 格式压缩编码的，这种压缩格式可以减少流量的消耗。

#### 2) content-length

表示这次回包的数据大小，如果数据大小不匹配，要当作异常处理。

#### 3) content-type

表示数据的格式，它是一个 HTML 页面，同时页面的编码格式是 UTF-8，按照这些信息，可以正常地解析出内容。content-type 为不同的值时，浏览器会做不同的操作，如果 content-type 是 application/octet-stream，表示数据是一个二进制流，此时浏览器会走下载文件的逻辑，而不是打开一个页面。

#### 4) set-cookie

服务器通知浏览器设置一个 Cookie；通过 HTTP 的 Header，可以识别出用户的一些详细信息，方便做更定制化的需求，如果大家想探索自己发出的请求中头里面有些什么，可以这样做：打开 Chrome 浏览器并按“F12”键，唤起 Chrome 开发者工具，选择 network 这个 Tab，浏览器发出的每个请求的详情都会在这里显示。

### 一个浏览器打开一个网页，整个过程中经过了哪些网络链路节点

### 操作系统的死锁产生必要条件有什么

死锁是指两个或两个以上进程在执行过程中，因争夺资源而造成的下相互等待的现象。死锁发生的四个必要条件如下：

+ 互斥条件：进程对所分配到的资源不允许其他进程访问，若其他进程访问该资源，只能等待，直至占有该资源的进程使用完成后释放该资源；
+ 请求和保持条件：进程获得一定的资源后，又对其他资源发出请求，但是该资源可能被其他进程占有，此时请求阻塞，但该进程不会释放自己已经占有的资源
+ 不可剥夺条件：进程已获得的资源，在未完成使用之前，不可被剥夺，只能在使用后自己释放
+ 环路等待条件：进程发生死锁后，必然存在一个进程-资源之间的环形链

### 避免死锁的办法

避免死锁的方法即破坏上述四个条件之一，主要方法如下：

+ 资源一次性分配，从而剥夺请求和保持条件
+ 可剥夺资源：即当进程新的资源未得到满足时，释放已占有的资源，从而破坏不可剥夺的条件
+ 资源有序分配法：系统给每类资源赋予一个序号，每个进程按编号递增的请求资源，释放则相反，从而破坏环路等待的条件

### 死锁已经发生了怎么恢复

https://blog.csdn.net/Zzh1110/article/details/123339558

解除死锁的主要方法有：

1. 资源剥夺法。挂起（暂时放到外存上）某些死锁进程，并抢占它的资源，将这些资源分配给其他的死锁进程。但是应防止被挂起的进程长时间得不到资源而饥饿。
2. 撤销进程法（或称终止进程法）。强制撤销部分、甚至全部死锁进程，并剥夺这些进程的资源。这种方式的优点是实现简单，但所付出的代价可能会很大。因为有些进程可能已经运行了很长时间，已经接近结束了，一旦被终止可谓功亏一篑，以后还得从头再来。
3. 进程回退法。让一个或多个死锁进程回退到足以避免死锁的地步。这就要求系统要记录进程的历史信息，设置还原点。

### 什么叫虚拟内存

+ 为了防止不同进程同一时刻在物理内存中运行而对物理内存的争夺和践踏，采用了虚拟内存。
+ 创建一个进程的时候，操作系统会为该进程分配一个4G大小的虚拟进程**地址空间**
+ **虚拟内存技术使得不同进程在运行过程中，它所看到的是自己独自占有了当前系统的4G内存。所有进程共享同一物理内存，每个进程只把自己目前需要的虚拟内存空间映射并存储到物理内存上。 事实上，在每个进程创建加载时，内核只是为进程“创建”了虚拟内存的布局，具体就是初始化进程控制表中内存相关的链表，实际上并不立即就把虚拟内存对应位置的程序数据和代码（比如.text .data段）拷贝到物理内存中，只是建立好虚拟内存和磁盘文件之间的映射就好（叫做存储器映射），等到运行到对应的程序时，才会通过缺页异常，来拷贝数据。**
+ **4G 指的是最大的寻址空间为4G。32位操作系统中，一个指针长度是4字节（32位），2^32个地址寻址能有4G容量大小。**
+ 进程运行过程中，要动态分配内存，比如malloc时，也只是分配了虚拟内存，即为这块虚拟内存对应的页表项做相应设置，当进程真正访问到此数据时，才引发缺页异常。
+ 请求分页系统、请求分段系统和请求段页式系统都是针对虚拟内存的，通过请求实现内存与外存的信息置换。
+ **虚拟内存的好处：**
1. 扩大地址空间；
  
2. 内存保护：每个进程运行在各自的虚拟内存地址空间，互相不能干扰对方。虚存还对特定的内存地址提供写保护，可以防止代码或数据被恶意篡改。
  
3. 公平内存分配。采用了虚存之后，每个进程都相当于有同样大小的虚存空间。
  
4. 当进程通信时，可采用虚存共享的方式实现。
  
5. 当不同的进程使用同样的代码时，比如库文件中的代码，物理内存中可以只存储一份这样的代码，不同的进程只需要把自己的虚拟内存映射过去就可以了，节省内存
  
6. 虚拟内存很适合在多道程序设计系统中使用，许多程序的片段同时保存在内存中。当一个程序等待它的一部分读入内存时，可以把CPU交给另一个进程使用。在内存中可以保留多个进程，系统并发度提高
  
7. 在程序需要分配连续的内存空间的时候，只需要在虚拟内存空间分配连续空间，而不需要实际物理内存的连续空间，可以利用碎片
+ 虚拟内存的代价：

  1. 虚存的管理需要建立很多数据结构，这些数据结构要占用额外的内存

  2. 虚拟地址到物理地址的转换，增加了指令的执行时间。

  3. 页面的换入换出需要磁盘I/O，这是很耗时的

  4. 如果一页中只有一部分数据，会浪费内存。

### golang的select的底层原理（为什么能选到最先触发的chan）

1. 每一个 case 对应的 channl 都会被封装到一个结构体中；
2. 当第一次执行到 select 时，会锁住所有的 channl 并且，打乱 case 结构体的顺序；
3. 按照打乱的顺序遍历，如果有就绪的信号（channel的等待队列和缓存区是否可读可写），就直接走对应 case 的代码段，之后跳出 select；
4. 如果没有就绪的代码段，但是有 default 字段，那就走 default 的代码段，之后跳出 select；
5. 如果没有 default，那就将当前 goroutine 加入所有 channl 的对应等待队列；
6. 当某一个等待队列就绪时，再次锁住所有的 channl，遍历一遍，将所有等待队列中的 goroutine 取出，之后执行就绪的代码段，跳出select。

### chan有消息触发的时候，那这个协程是卡在哪里了

卡在了从等待队列被唤醒

### 如果一个有缓存的chan，有1个生产者和3个消费者。那这个时候生产者生成的数据会存放到哪里。这个过程是怎么样的

消费者直接从读队列中被唤醒，并且将生产者的数据拷贝到消费者

+ 算法：子集

```
给你一个整数数组 nums ，数组中的元素 互不相同 。返回该数组所有可能的子集（幂集）。
解集 不能 包含重复的子集。你可以按 任意顺序 返回解集。

输入：nums = [1,2,3]
输出：[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]

输入：nums = [0]
输出：[[],[0]]
```




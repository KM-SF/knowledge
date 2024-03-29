# 知识点

* TCP：面向有链接的，双向全双工，可靠的数据包传输

* 特点：稳定（数据重传），效率低，速度慢

* 使用场景：大文件，重要文件

* TCP数据报：![TCP数据报](/网络/images/TCP数据报.jpg)

  > 1. 16位源端口
  > 2. 16位目的端口
  > 3. 32位序号（seq）
  > 4. 32位确认序号（ack）
  > 5. 4位首部长度
  > 6. 6个标记位：
  >    1. SYN：数据请求标记
  >    2. ACK：确认标记
  >    3. FIN：关闭请求标记
  >    4. URG
  >    5. PSH
  >    6. RST
  > 7. 16位窗口大小：65535
  
* **一对客户端/服务器socket通信有3个套接字：**

  > 1. 客户端一个：用于跟服务器通信
  > 2. 服务器一个：用于跟客户端通信
  > 3. 服务器还有一个：用于监听连接

* listen()函数：设置监听同时连接上限

* mss：最大报文长度，选项值为1024

* 滑动窗口：告诉发送端，接收端（自己）还能接收多少数据，缓冲区的大小。控制发送方发送数据的速度，防止发送端发送数据过快，保证数据丢失

* 查看网络状态：netstate anp | grep $port

* TIME_WAIT：只有主动发起断开一端才有这个状态

* TIME_WAIT状态存在的理由：

  * 让4次握手关闭流程更加可靠；4次握手的最后一个ACK是是由主动关闭方发送出去的，**若这个ACK丢失，被动关闭方会再次发一个FIN过来**。若主动关闭方能够保持一个2MSL的TIME_WAIT状态，则有更大的机会让丢失的ACK被再次发送出去。
  * 防止lost duplicate对后续新建正常链接的传输造成破坏。lost duplicate在实际的网络中非常常见，经常是由于路由器产生故障，路径无法收敛，导致一个packet在路由器A，B，C之间做类似死循环的跳转。IP头部有个TTL，限制了一个包在网络中的最大跳数，因此这个包有两种命运，要么最后TTL变为0，在网络中消失；要么TTL在变为0之前路由器路径收敛，它凭借剩余的TTL跳数终于到达目的地。但非常可惜的是TCP通过超时重传机制在早些时候发送了一个跟它一模一样的包，并先于它达到了目的地，因此它的命运也就注定被TCP协议栈抛弃。另外一个概念叫做incarnation connection，指跟上次的socket pair一摸一样的新连接，叫做incarnation of previous connection。lost duplicate加上incarnation connection，则会对我们的传输造成致命的错误。大家都知道TCP是流式的，所有包到达的顺序是不一致的，依靠序列号由TCP协议栈做顺序的拼接；假设一个incarnation connection这时收到的seq=1000, 来了一个lost duplicate为seq=1000,len=1000, 则tcp认为这个lost duplicate合法，并存放入了receive buffer，导致传输出现错误。通过一个2MSL TIME_WAIT状态，确保所有的lost duplicate都会消失掉，避免对新连接造成错误。
  
* 2MSL时长：保证**在2MSL时长内最后一个ACK**能被对端接收到。（等待期间，对端没有收到我发送的ACK，对端会再次发送FIN请求。）如果超过了2MSL时长，则不关对端是否收到我发送的ACK，都会关闭连接。

* RFC要求socket pair在处于TIME_WAIT时，不能再起一个incarnation connection。但绝大部分TCP实现，强加了更为严格的限制。在2MSL等待期间，socket中使用的本地端口在默认情况下不能再被使用。若A 10.234.5.5:1234和B 10.55.55.60:6666建立了连接，A主动关闭，那么在A端只要port为1234，无论对方的port和ip是什么，都不允许再起服务。显而易见这是比RFC更为严格的限制，RFC仅仅是要求socket pair不一致，而实现当中只要这个port处于TIME_WAIT，就不允许起连接。这个限制对主动打开方来说是无所谓的，因为一般用的是临时端口；但对于被动打开方，一般是server，就悲剧了，因为server一般是熟知端口。比如http，一般端口是80，不可能允许这个服务在2MSL内不能起来。解决方案是给服务器的socket设置SO_REUSEADDR选项，这样的话就算熟知端口处于
  TIME_WAIT状态，在这个端口上依旧可以将服务启动。当然，虽然有了SO_REUSEADDR选项，但sockt pair这个限制依旧存在。比如上面的例子，A通过SO_REUSEADDR选项依旧在1234端口上起了监听，但这时我们若是从B通过6666端口去连它，TCP协议会告诉我们连接失败，原因为**Address already in use.**

* close和shutdown的区别：

  > 1. shutdown 可以指定关闭哪个缓存区（读缓存，写缓存，读写缓存）
  > 2. 使用close终止一个连接，但是它只是减少描述符引用计数，并不直接关闭连接。只有当描述符的引用计数为0时才关闭连接
  > 3. shutdown不考虑描述符的引用计数，直接关闭描述符。
  > 4. 如果有多个进程共享一个套接字，close每被调用一次，计数-1。直到计数为0时，也就是所有进程都被调用close时，套接字才释放
  > 5. 在多进程中如果一个进程调用shutdown函数，其他进程也会受其影响，对应的缓存区无法使用。但是一个进程close（fd）将不会影响到其他进程。
  
  > 发送端：
  >
  > + shutdown(SHUT_WR)：发送一个FIN包，并且标记该socket为SEND_SHUTDOWN
  > + shutdown(SHUT_RD)不发送任何包，但是标记该socket为RCV_SHUTDOWN
  >
  > 接收端：
  >
  > + 收到FIN包标记该socket为RCV_SHUTDOWN
  > + 对于epoll而言，如果一个socket同时标记位SEND_SHUTDOWN和RCV_SHUTDOWN，那么epoll会返回EPOLLHUP
  > + 如果一个socket被标记位RCV_SHUTDOWN，则epoll会返回EPOLLRDHUP。（read == 0）

# 滑动窗口

+ TCP数据报格式中有一个窗口大小，这个大小就是指滑动窗口的大小
+ 滑动窗口作用：告诉发送端，接收端（自己）还能接收多少数据，缓冲区的大小。控制发送方发送数据的速度，防止发送端发送数据过快，保证数据丢失
+ 从下图还可以看出，发送端是一K一K地发送数据，而接收端的应用程序可以两K两K地提走数据，当然也有可能一次提走3K或6K数据，或者一次只提走几个字节的数据，也就是说，应用程序所看到的数据是一个整体，或说是一个流（stream），在底层通讯中这些数据可能被拆成很多数据包来发送，但是一个数据包有多少字节对应用程序是不可见的，因此TCP协议是面向流的协议。而UDP是面向消息的协议，每个UDP段都是一条消息，应用程序必须以消息为单位提取数据，不能一次提取任意字节的数据，这一点和TCP是很不同的。

> 滑动窗口：![滑动窗口](/网络/images/滑动窗口.png)

# SOCKET通信模型

![通信模型](/网络/images/SOCKET模型创建.png)

> server:
>
> 1. socket()：创建socket
> 2. bind()：绑定服务器地址结构
> 3. listen()：设置监听上限
> 4. accpet()：阻塞监听客户端连接
> 5. read()：读取客户端数据
> 6. write()：发送数据给客户端
> 7. close()：关闭连接

> client：
>
> 1. socket()：创建socket
> 2. connect()：与服务器建立连接
> 3. read()：读取客户端数据
> 4. write()：发送数据给客户端
> 5. close()：关闭连接

# 建立挥手三次握手

三次握手时序图：  

![3次握手](/网络/images/TCP三次握手.jpg)

过程：

1. 客户端向服务端发送连接请求报文（客户端进入**SYN-SEND**状态）。SYN标志位为1，seq序号为**n**。
2. 服务端收到客户端请求（服务端结束**LISTEN**状态）。发送应答报文（服务端进入**SYN-RCVD**状态）。SYN标记位为1，seq序号为**k**。ACK标记位为1，ack确认序号为**n+1**
3. 客户端收到应答报文，再发送一个应答报文给服务端。（客户端和服务端状态进入**ESTABLISHEN**）。ACK标记位为1，ack确认序号为**k+1**，seq序号为n+1。

# 断开连接四次挥手

四次挥手时序图：

![4次挥手](/网络/images/TCP四次挥手.jpg)

过程：

1. 客户端向服务器发送断开连接报文（客户端进入**FIN-WAIT-1**阶段），FIN标记位为1，seq为X（随机值）
2. 服务器收到客户端发来的断开连接报文后，发送确认报文（服务器结束**ESTABLISHEN**，进去**CLOSE-WAIT**阶段），ACK标记位位1，ack确认序号**X+1**，seq序号为Y随机值。客户端收到服务器回的的确认报文后，客户端进入**半关闭状态**（退出**FIN-WAIT-1**阶段，进入**FIN-WAIT-2**阶段）
3. 服务器发送断开连接报文（服务器退出**CLOSE-WAIT**阶段，进入**LAST-ACK**阶段）。FIN标记为为1，seq序号位为Z随机值。客户端收到服务器发送的断开连接报文后，客户端退出**FIN-WAIT-2**阶段，进入**TIME-WAIT**阶段
4. 客户端进入TIME-WAIT阶段时，会立即发送最后一个确认报文，ACK标记位为1，ack确认序号位**Z+1**。服务器收到客户端发送的确认报文后，退出**LAST-ACK**阶段，进入**CLOSED**阶段
5. 如果这个2MSL时间内服务器没有再一次发送FIN报文的话，那个2MSL时长 后，客户端退出TIME-WAIT阶段，进入**CLOSED**阶段

# 半关闭

+ 一个套接字内部由内核借助两个缓冲区实现（一个读缓存，一个写缓存），当处于半关闭状态的时候：**只关闭了写缓存，但是连接还是存在的，还能接收数据。**

+ 半关闭状态：主动发起关闭的一方不能再发送数据了，只能接受数据

+ 使用close中止一 个连接，但它只是减少描述符的参考数，并不直接关闭连接，只有当描述符的参考数为0时才关闭连接。 shutdown可直接关闭描述符，不考虑描述 符的参考数，可选择中止一个方向的连接。

+ 如果有多个进程共享一个套接字，close每被调用一次，计数减1，直到计数为0时，也就是所用进程都调用了close，套接字将被释放。

+ 在多进程中如果一个进程中shutdown(sfd, SHUT_RDWR)后其它的进程将无法进行通信. 如果一个进程close(sfd)将不会影响到其它进程

+ 设置半关闭函数：shutdown

  ```C
  #include <sys/socket.h>
  int shutdown(int sockfd, int how);
  sockfd: 需要关闭的socket的描述符
  how:允许为shutdown操作选择以下几种方式:
      SHUT_RD：关闭连接的读端。也就是该套接字不再接受数据，任何当前在套接字接受缓冲区的数据将被丢弃。进程将不能对该套接字发出任何读操作。对 TCP套接字该调用之后接受到的任何数据将被确认然后无声的丢弃掉。
      SHUT_WR:关闭连接的写端，进程不能在对此套接字发出写操作
      SHUT_RDWR:相当于调用shutdown两次：首先是以SHUT_RD,然后以SHUT_WR
  ```

> 半关闭：![半关闭](/网络/images/半关闭.png)

# 端口复用

+ 当服务器主动关闭时，处于TIME_WAIT状态的话，这个时候再去启动服务器会报失败。原因是：调用bind的时候，当前的端口还没释放绑定失败（Address already in use）。

+ 只有当服务器主动关闭后，等到2MSL时长后才会进入CLOSED状态，这个时候才能用原来的端口

+ 设置端口复用：

  ```C
  int opt = 1;
  setsockopt(listenfd, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt));
  ```

+ 两个进程（都用了同一个端口）的关系：

  > 服务器A和服务器B都是用TCP
  >
  > + 服务器A启动，然后关闭进入time_wait状态。服务器B再启动，服务器B（**没有设置端口复用**）会报：**Address already in use**
  >
  > + 服务器A启动，然后关闭进入time_wait状态。服务器B再启动，服务器B（**设置端口复用**）会报：**Address already in use**
  >
  > **结论：两个进程用同一个port，当有一个进程退出后进入time_wait状态，另外一个进程无法启动，不管有没有设置端口复用**

  > + 没有设置端口复用。服务器A启动了，再用另外个终端再开启服务器A。另外个开始失败，会报：**Address already in use**
  > + 设置端口复用。服务器A启动了，再用另外个终端再开启服务器A。另外个开启成功，但是只有一个能进行建立连接通信
  >
  > **结论：如果同个进程开启两次，设置了端口复用，那么都可以打开。如果没有设置端口复用则有一个会失败**

# TCP状态转换图

TCP状态转换图：![TCP状态转换图](/网络/images/TCP状态转换图.jpg)

过程：！！！黑体下划线为状态！！！

> **建立连接**：
>
> + 主动发起连接请求端：<u>**CLOSE**</u> --》 发送SYN --》 <u>**SEND_SYN**</u> --》 接收ACK，SYN --》 <u>**SEND_SYN**</u> --》 发送ACK --》<u>**ESTABLISHED**</u>（数据通信状态）
>
> + 被动接收连接请求端：<u>**CLOSE**</u> --》 <u>**LISTEN**</u> --》 接收SYN --》<u>**LISTEN**</u> --》 发送ACK，SYN --》SYN_RCVD --》接收ACK --》 <u>**ESTABLISHED**</u>（数据通信状态）

> **断开连接：**
>
> + 主动关闭连接请求端：<u>**ESTABLISHED**</u>（数据通信状态） --》 发送FIN --》 <u>**FIN_WAIT1**</u> --》 接收ACK --》<u>**FIN_WAIT2**</u>（半关闭）--》接收端发送FIN --》<u>**FIN_WAIT_2**</u>（半关闭）--》回发ACK --》<u>**TIME_WAIT**</u>（只有主动关闭连接方，才会有该状态）--》等待**2MSL**时长 --》<u>**CLOSE**</u>
> + 被动关闭连接请求端：<u>**ESTABLISHED**</u>（数据通信状态）--》接收FIN --》 <u>**ESTABLISHED**</u>（数据通信状态）--》发送ACK --》<u>**CLOSE_WAIT**</u> --》发送FIN --》<u>**LAST_ACK**</u> --》接收ACK --》<u>**CLOSE**</u>

> 状态解释：
>
> + CLOSED：这个没什么好说的了，表示初始状态。
> + LISTEN：这个也是非常容易理解的一个状态，表示服务器端的某个SOCKET处于监听状态，可以接受连接了。
> + SYN_RCVD：这个状态表示接受到了SYN报文，在正常情况下，这个状态是服务器端的SOCKET在建立TCP连接时的三次握手会话过程中的一个中间状态，很短暂，基本 上用netstat你是很难看到这种状态的，除非你特意写了一个客户端测试程序，故意将三次TCP握手过程中最后一个ACK报文不予发送。因此这种状态 时，当收到客户端的ACK报文后，它会进入到ESTABLISHED状态。
> + SYN_SENT：这个状态与SYN_RCVD呼应，当客户端SOCKET执行CONNECT连接时，它首先发送SYN报文，因此也随即它会进入到了SYN_SENT状 态，并等待服务端的发送三次握手中的第2个报文。SYN_SENT状态表示客户端已发送SYN报文。
> + ESTABLISHED：这个容易理解了，表示连接已经建立了。
> + FIN_WAIT_1：这个状态要好好解释一下，其实FIN_WAIT_1和FIN_WAIT_2状态的真正含义都是表示等待对方的FIN报文。而这两种状态的区别 是：FIN_WAIT_1状态实际上是当SOCKET在ESTABLISHED状态时，它想主动关闭连接，向对方发送了FIN报文，此时该SOCKET即 进入到FIN_WAIT_1状态。而当对方回应ACK报文后，则进入到FIN_WAIT_2状态，当然在实际的正常情况下，无论对方何种情况下，都应该马 上回应ACK报文，所以FIN_WAIT_1状态一般是比较难见到的，而FIN_WAIT_2状态还有时常常可以用netstat看到。
> + FIN_WAIT_2：上面已经详细解释了这种状态，实际上FIN_WAIT_2状态下的SOCKET，表示半连接，也即有一方要求close连接，但另外还告诉对方，我暂时还有点数据需要传送给你，稍后再关闭连接。
> + TIME_WAIT: 表示收到了对方的FIN报文，并发送出了ACK报文，就等2MSL后即可回到CLOSED可用状态了。如果FIN_WAIT_1状态下，收到了对方同时带 FIN标志和ACK标志的报文时，可以直接进入到TIME_WAIT状态，而无须经过FIN_WAIT_2状态。
> + **CLOSING**: 这种状态比较特殊，实际情况中应该是很少见，属于一种比较罕见的例外状态。正常情况下，当你发送FIN报文后，按理来说是应该先收到（或同时收到）对方的 ACK报文，再收到对方的FIN报文。但是CLOSING状态表示你发送FIN报文后，并没有收到对方的ACK报文，反而却也收到了对方的FIN报文。什 么情况下会出现此种情况呢？其实细想一下，也不难得出结论那就是如果双方几乎在同时close一个SOCKET的话，那么就出现了双方同时发送FIN报 文的情况，**也即会出现CLOSING状态，表示双方都正在关闭SOCKET连接。**
> + CLOSE_WAIT: 这种状态的含义其实是表示在等待关闭。怎么理解呢？当对方close一个SOCKET后发送FIN报文给自己，你系统毫无疑问地会回应一个ACK报文给对 方，此时则进入到CLOSE_WAIT状态。接下来呢，实际上你真正需要考虑的事情是察看你是否还有数据发送给对方，如果没有的话，那么你也就可以 close这个SOCKET，发送FIN报文给对方，也即关闭连接。所以你在CLOSE_WAIT状态下，需要完成的事情是等待你去关闭连接。
> + LAST_ACK: 这个状态还是比较容易好理解的，它是被动关闭一方在发送FIN报文后，最后等待对方的ACK报文。当收到ACK报文后，也即可以进入到CLOSED可用状态了。

# C/S模型-TCP

C/S模型-TCP：![C/S模型-TCP](/网络/images/CS模型（TCP）.png)

+ 服务器调用socket()、bind()、listen()完成初始化后，调用accept()阻塞等待，处于监听端口的状态客户端调用socket()初始化后，调用connect()发出SYN段并阻塞等待服务器应答，服务器应答一个SYN-ACK段，客户端收到后从connect()返回，同时应答一个ACK段，服务器收到后从accept()返回。
+ 数据传输的过程：
  建立连接后，TCP协议提供全双工的通信服务，但是一般的客户端/服务器程序的流程是由客户端主动发起请求，服务器被动处理请求，一问一答的方式。因此，服务器从accept()返回后立刻调用read()，读socket就像读管道一样，如果没有数据到达就阻塞等待，这时客户端调用write()发送请求给服务器，服务器收到后从read()返回，对客户端的请求进行处理，在此期间客户端调用read()阻塞等待服务器的应答，服务器调用write()将处理结果发回给客户端，再次调用read()阻塞等待下一条请求，客户端收到后从read()返回，发送下一条请求，如此循环下去。
+ 如果客户端没有更多的请求了，就调用close()关闭连接，就像写端关闭的管道一样，**服务器的read()返回0，这样服务器就知道客户端关闭了连接，也调用close()关闭连接。**注意，任何一方调用close()后，连接的两个传输方向都关闭，不能再发送数据了。如果一方调用shutdown()则连接处于半关闭状态，仍可接收对方发来的数据。

# 例子：

> + server.c的作用是从客户端读字符，然后将每个字符转换为大写并回送给客户端。[服务端代码](/网络/code/tcp/server.c)
> + client.c的作用是从命令行参数中获得一个字符串发给服务器，然后接收服务器返回的字符串并打印。[客户端端代码](/网络/code/tcp/client.c)

> 多线程服务器：主线程来监听客户端的连接，每当有一个客户端连接就新起一个线程去监听该客户端的发送消息。每个客户端一个线程监听read。主线程监听accpet。[服务端代码](/网络/code/tcp/thread_server.c)
>

> 多进程服务器：主进程先fork一个子进程去监听客户端登录，然后主进程去回收子进程资源。当有客户端登录时则再fork一个进程专门处理这个客户端的read和write。[服务端代码](/网络/code/tcp/process_server.c)

# 半连接队列和全连接队列

https://mp.weixin.qq.com/s?__biz=MzAwNDA2OTM1Ng==&mid=2453143470&idx=2&sn=70001ece183a7895a3775ea28a366f0f&scene=21#wechat_redirect

在 TCP 三次握手的时候，Linux 内核会维护两个队列，分别是：

- 半连接队列，也称 SYN 队列；
- 全连接队列，也称 accepet 队列；

服务端收到客户端发起的 SYN 请求后，**内核会把该连接存储到半连接队列**，并向客户端响应 SYN+ACK，接着客户端会返回 ACK，服务端收到第三次握手的 ACK 后，**内核会把连接从半连接队列移除，然后创建新的完全的连接，并将其添加到 accept 队列，等待进程调用 accept 函数时把连接取出来。**

不管是半连接队列还是全连接队列，都有最大长度限制，超过限制时，内核会直接丢弃，或返回 RST 包。

![](/网络/images/半连接和全连接.png)

## 全连接队列溢出

### 测试命令

在服务端可以使用 `ss` 命令，来查看 TCP 全连接队列的情况：

但需要注意的是 `ss` 命令获取的 `Recv-Q/Send-Q` 在「LISTEN 状态」和「非 LISTEN 状态」所表达的含义是不同的。从下面的内核代码可以看出区别：

> 在「LISTEN 状态」时，`Recv-Q/Send-Q` 表示的含义如下：
>
> - Recv-Q：当前全连接队列的大小，也就是当前已完成三次握手并等待服务端 `accept()` 的 TCP 连接个数；
> - Send-Q：当前全连接最大队列长度，上面的输出结果说明监听 8088 端口的 TCP 服务进程，最大全连接长度为 128；

> 在「非 LISTEN 状态」时，`Recv-Q/Send-Q` 表示的含义如下：
>
> - Recv-Q：已收到但未被应用进程读取的字节数；
> - Send-Q：已发送但未收到确认的字节数；

**当超过了 TCP 最大全连接队列，服务端则会丢掉后续进来的 TCP 连接**，丢掉的 TCP 连接的个数会被统计起来，我们可以使用 netstat -s 命令来查看：netstat -s |grep overflowed

**当服务端并发处理大量请求时，如果 TCP 全连接队列过小，就容易溢出。发生 TCP 全连接队溢出的时候，后续的请求就会被丢弃，这样就会出现服务端请求数量上不去的现象。**

### 溢出处理情况

**实际上，丢弃连接只是 Linux 的默认行为，我们还可以选择向客户端发送 RST 复位报文，告诉客户端连接已经建立失败。**

tcp_abort_on_overflow 共有两个值分别是 0 和 1，其分别表示：

```
cat /proc/sys/net/ipv4/tcp_abort_on_overflow
```

- 0 ：表示如果全连接队列满了，那么 server 扔掉 client  发过来的 ack ；
- 1 ：表示如果全连接队列满了，那么 server 发送一个 `reset` 包给 client，表示废掉这个握手过程和这个连接；

如果要想知道客户端连接不上服务端，是不是服务端 TCP 全连接队列满的原因，那么可以把 tcp_abort_on_overflow 设置为 1，这时如果在客户端异常中可以看到很多 `connection reset by peer` 的错误，那么就可以证明是由于服务端 TCP 全连接队列溢出的问题。

通常情况下，应当把 tcp_abort_on_overflow 设置为 0，因为这样更有利于应对突发流量。

举个例子，当 TCP 全连接队列满导致服务器丢掉了 ACK，与此同时，客户端的连接状态却是 ESTABLISHED，进程就在建立好的连接上发送请求。只要服务器没有为请求回复 ACK，请求就会被多次**重发**。如果服务器上的进程只是**短暂的繁忙造成 accept 队列满，那么当 TCP 全连接队列有空位时，再次接收到的请求报文由于含有 ACK，仍然会触发服务器端成功建立连接。**

所以，tcp_abort_on_overflow 设为 0 可以提高连接建立的成功率，只有你非常肯定 TCP 全连接队列会长期溢出时，才能设置为 1 以尽快通知客户端。

### 增大 TCP 全连接队列

**TCP 全连接队列足最大值取决于 somaxconn 和 backlog 之间的最小值，也就是 min(somaxconn, backlog)**。

- `somaxconn` 是 Linux 内核的参数，默认值是 128，可以通过 `/proc/sys/net/core/somaxconn` 来设置其值；
- `backlog` 是 `listen(int sockfd, int backlog)` 函数中的 backlog 大小，Nginx 默认值是 511，可以通过修改配置文件设置其长度；

## 半连接队列溢出

### 测试

很遗憾，TCP 半连接队列长度的长度，没有像全连接队列那样可以用 ss 命令查看。

但是我们可以抓住 TCP 半连接的特点，就是服务端处于 `SYN_RECV` 状态的 TCP 连接，就是在 TCP 半连接队列。

于是，我们可以使用如下命令计算当前 TCP 半连接队列长度：

模拟 TCP 半连接溢出场景不难，实际上就是对服务端一直发送 TCP SYN 包，但是不回第三次握手 ACK，这样就会使得服务端有大量的处于 `SYN_RECV` 状态的 TCP 连接。

这其实也就是所谓的 SYN 洪泛、SYN 攻击、DDos 攻击。

### 溢出处理情况

TCP 第一次握手（收到 SYN 包）时会被丢弃的三种条件：

1. 如果半连接队列满了，并且没有开启 tcp_syncookies，则会丢弃；
2. 若全连接队列满了，且没有重传 SYN+ACK 包的连接请求多于 1 个，则会丢弃；
3. **如果没有开启 tcp_syncookies，并且 max_syn_backlog 减去 当前半连接队列长度小于 (max_syn_backlog >> 2)，则会丢弃；**

**开启 syncookies 功能就可以在不使用 SYN 半连接队列的情况下成功建立连接**，在前面我们源码分析也可以看到这点，当开启了  syncookies 功能就不会丢弃连接。

syncookies 是这么做的：服务器根据当前状态计算出一个值，放在己方发出的 SYN+ACK 报文中发出，当客户端返回 ACK 报文时，取出该值验证，如果合法，就认为连接建立成功，如下图所示。

syncookies 参数主要有以下三个值：

- 0 值，表示关闭该功能；
- 1 值，表示仅当 SYN 半连接队列放不下时，再启用它；
- 2 值，表示无条件开启功能；

### 增大半连接队列

**每个 Linux 内核版本「理论」半连接最大值计算方式会不同。**

+ 如果「当前半连接队列」**没超过**「理论半连接队列最大值」，但是**超过** max_syn_backlog - (max_syn_backlog >> 2)，那么处于 SYN_RECV 状态的最大个数就是 max_syn_backlog - (max_syn_backlog >> 2)；

+ 如果「当前半连接队列」**超过**「理论半连接队列最大值」，那么处于 SYN_RECV 状态的最大个数就是「理论半连接队列最大值」；

### 如何防御 SYN 攻击？

这里给出几种防御 SYN 攻击的方法：

- 增大半连接队列；
- 开启 tcp_syncookies 功能
- 减少 SYN+ACK 重传次数

#### 增大半连接队列

**要想增大半连接队列，我们得知不能只单纯增大 tcp_max_syn_backlog 的值，还需一同增大 somaxconn 和 backlog，也就是增大全连接队列**。否则，只单纯增大 tcp_max_syn_backlog 是无效的。

增大 tcp_max_syn_backlog 和 somaxconn 的方法是修改 Linux 内核参数：

tcp_max_syn_backlog ：/proc/sys/net/ipv4/tpc_max_syn_backlog

somaxconn : /proc/sys/net/ipv4/core/somaxconn

backlog：这个就是listen时候的数值

#### 开启 tcp_syncookies 功能

开启 tcp_syncookies 功能的方式也很简单，修改 Linux 内核参数：

echo 1 > /proc/sys/net/ipv4/tpc_max_syn_backlog

#### 减少 SYN+ACK 重传次数

当服务端受到 SYN 攻击时，就会有大量处于 SYN_REVC 状态的 TCP 连接，处于这个状态的 TCP 会重传 SYN+ACK ，当重传超过次数达到上限后，就会断开连接。

那么针对 SYN 攻击的场景，我们可以减少 SYN+ACK 的重传次数，以加快处于 SYN_REVC 状态的 TCP 连接断开。

# 重传、滑动窗口、流量控制、拥塞控制

https://mp.weixin.qq.com/s?__biz=MzAwNDA2OTM1Ng==&mid=2453143215&idx=2&sn=e9e767ebcbd2fce4688ba71db4fbd32d&scene=21#wechat_redirect

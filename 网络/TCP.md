# 知识点

* TCP数据报：![TCP数据报](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/images/TCP%E6%95%B0%E6%8D%AE%E6%8A%A5.jpg)

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

* 2MSL时长：保证**在2MSL时长内最后一个ACK**能被对端接收到。（等待期间，对端没有收到我发送的ACK，对端会再次发送FIN请求。）如果超过了2MSL时长，则不关对端是否收到我发送的ACK，都会关闭连接。

* close和shutdown的区别：

  > 1. shutdown 可以指定关闭哪个缓存区（读缓存，写缓存，读写缓存）
  > 2. 使用close终止一个连接，但是它只是减少描述符引用计数，并不直接关闭连接。只有当描述符的引用计数为0时才关闭连接
  > 3. shutdown不考虑描述符的引用计数，直接关闭描述符。
  > 4. 如果有多个进程共享一个套接字，close每被调用一次，计数-1。直到计数为0时，也就是所有进程都被调用close时，套接字才释放
  > 5. 在多进程中如果一个进程调用shutdown函数，其他进程也会受其影响，对应的缓存区无法使用。但是一个进程close（fd）将不会影响到其他进程。

# SOCKET通信模型

![通信模型](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/images/SOCKET%E6%A8%A1%E5%9E%8B%E5%88%9B%E5%BB%BA.png)

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

![3次握手](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/images/TCP%E4%B8%89%E6%AC%A1%E6%8F%A1%E6%89%8B.jpg)

过程：

1. 客户端向服务端发送连接请求报文（客户端进入**SYN-SEND**状态）。SYN标志位为1，seq序号为**n**。
2. 服务端收到客户端请求（服务端结束**LISTEN**状态）。发送应答报文（服务端进入**SYN-RCVD**状态）。SYN标记位为1，seq序号为**k**。ACK标记位为1，ack确认序号为**n+1**
3. 客户端收到应答报文，再发送一个应答报文给服务端。（客户端和服务端状态进入**ESTABLISHEN**）。ACK标记位为1，ack确认序号为**k+1**，seq序号为n+1。

# 断开连接四次挥手

四次挥手时序图：

<img src="https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/images/TCP%E5%9B%9B%E6%AC%A1%E6%8C%A5%E6%89%8B.jpg" alt="四次挥手时序图" style="zoom:150%;" />

过程：

1. 客户端向服务器发送断开连接报文（客户端进入**FIN-WAIT-1**阶段），FIN标记位为1，seq为X（随机值）
2. 服务器收到客户端发来的断开连接报文后，发送确认报文（服务器结束**ESTABLISHEN**，进去**CLOSE-WAIT**阶段），ACK标记位位1，ack确认序号**X+1**，seq序号为Y随机值。客户端收到服务器回的的确认报文后，客户端进入**半关闭状态**（退出**FIN-WAIT-1**阶段，进入**FIN-WAIT-2**阶段）
3. 服务器发送断开连接报文（服务器退出**CLOSE-WAIT**阶段，进入**LAST-ACK**阶段）。FIN标记为为1，seq序号位为Z随机值。客户端收到服务器发送的断开连接报文后，客户端退出**FIN-WAIT-2**阶段，进入**TIME-WAIT**阶段
4. 客户端进入TIME-WAIT阶段时，会立即发送最后一个确认报文，ACK标记位为1，ack确认序号位**Z+1**。服务器收到客户端发送的确认报文后，退出**LAST-ACK**阶段，进入**CLOSED**阶段
5. 如果这个2MSL时间内服务器没有再一次发送FIN报文的话，那个2MSL时长 后，客户端退出TIME-WAIT阶段，进入**CLOSED**阶段

# 半关闭

![半关闭](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/images/%E5%8D%8A%E5%85%B3%E9%97%AD.png)

一个套接字内部由内核借助两个缓冲区实现（一个读缓存，一个写缓存），当处于半关闭状态的时候：**只关闭了写缓存，但是连接还是存在的，还能接收数据。**

# TCP状态转换图

TCP状态转换图：![TCP状态转换图](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/images/TCP%E7%8A%B6%E6%80%81%E8%BD%AC%E6%8D%A2%E5%9B%BE.jpg)

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
> + CLOSING: 这种状态比较特殊，实际情况中应该是很少见，属于一种比较罕见的例外状态。正常情况下，当你发送FIN报文后，按理来说是应该先收到（或同时收到）对方的 ACK报文，再收到对方的FIN报文。但是CLOSING状态表示你发送FIN报文后，并没有收到对方的ACK报文，反而却也收到了对方的FIN报文。什 么情况下会出现此种情况呢？其实细想一下，也不难得出结论那就是如果双方几乎在同时close一个SOCKET的话，那么就出现了双方同时发送FIN报 文的情况，也即会出现CLOSING状态，表示双方都正在关闭SOCKET连接。
> + CLOSE_WAIT: 这种状态的含义其实是表示在等待关闭。怎么理解呢？当对方close一个SOCKET后发送FIN报文给自己，你系统毫无疑问地会回应一个ACK报文给对 方，此时则进入到CLOSE_WAIT状态。接下来呢，实际上你真正需要考虑的事情是察看你是否还有数据发送给对方，如果没有的话，那么你也就可以 close这个SOCKET，发送FIN报文给对方，也即关闭连接。所以你在CLOSE_WAIT状态下，需要完成的事情是等待你去关闭连接。
> + LAST_ACK: 这个状态还是比较容易好理解的，它是被动关闭一方在发送FIN报文后，最后等待对方的ACK报文。当收到ACK报文后，也即可以进入到CLOSED可用状态了。

# C/S模型-TCP

C/S模型-TCP：![C/S模型-TCP](G:\knowledge\网络\images\CS模型（TCP）.png)

+ 服务器调用socket()、bind()、listen()完成初始化后，调用accept()阻塞等待，处于监听端口的状态客户端调用socket()初始化后，调用connect()发出SYN段并阻塞等待服务器应答，服务器应答一个SYN-ACK段，客户端收到后从connect()返回，同时应答一个ACK段，服务器收到后从accept()返回。
+ 数据传输的过程：
  建立连接后，TCP协议提供全双工的通信服务，但是一般的客户端/服务器程序的流程是由客户端主动发起请求，服务器被动处理请求，一问一答的方式。因此，服务器从accept()返回后立刻调用read()，读socket就像读管道一样，如果没有数据到达就阻塞等待，这时客户端调用write()发送请求给服务器，服务器收到后从read()返回，对客户端的请求进行处理，在此期间客户端调用read()阻塞等待服务器的应答，服务器调用write()将处理结果发回给客户端，再次调用read()阻塞等待下一条请求，客户端收到后从read()返回，发送下一条请求，如此循环下去。
+ 如果客户端没有更多的请求了，就调用close()关闭连接，就像写端关闭的管道一样，**服务器的read()返回0，这样服务器就知道客户端关闭了连接，也调用close()关闭连接。**注意，任何一方调用close()后，连接的两个传输方向都关闭，不能再发送数据了。如果一方
  调用shutdown()则连接处于半关闭状态，仍可接收对方发来的数据。

# 例子：

+ 简单例子：
  + server.c的作用是从客户端读字符，然后将每个字符转换为大写并回送给客户端。[服务端代码](https://github.com/594301947/knowledge/blob/master/%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F/%E6%96%87%E4%BB%B6/code/fork_fd.c )
  + client.c的作用是从命令行参数中获得一个字符串发给服务器，然后接收服务器返回的字符串并打印。[客户端端代码](https://github.com/594301947/knowledge/blob/master/%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F/%E6%96%87%E4%BB%B6/code/fork_fd.c )
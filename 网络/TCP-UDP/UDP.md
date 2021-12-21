# 知识点

+ UDP：无连接的，单向全双工，不可靠的的报文传递

+ 特点：效率高，速度快，开销小，不稳定（没有数据重传）

+ 使用场景：对实时性要求较高的

+ UDP自身就能实现并发，因为不存在所谓的连接。数据处理完就处理下一个。

+ UDP也有可能出现缓冲区被填满后，再接收数据包时丢包的情况，由于它没有TCP滑动窗口机制，通常有以下两种解决方法：

  + 服务器在应用层涉及流量控制，控制发送数据速度

  + 借助setsockopt函数改变接收缓冲区大小

    ```C
    int setsockopt(int sockfd, int level, int optname,const void *optval, socklen_t optlen);
    int size = 220 * 1024;//推荐值
    setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &size, sizeof(size));
    ```
  
+ 例子：

  + 服务端：[服务端代码](/网络/code/udp/server.c)
  + 客户端：[客户端代码](/网络/code/udp/client.c)


# C/S模型-UDP

C/S模型-UDP：![C/S模型-UDP](/网络/images/CS模型（UDP）.png)

+ 服务器：调用socket()、bind()、完成初始化后，调用recvfrom阻塞等待，等到某个客户端发送的数据。将数据处理完成后再发回给客户端。
+ 客户端：调用socket()完成初始化后（bind默认由系统执行），直接调用sendto发送给服务器，然后再调用recvfrom阻塞等待数据返回。

# 函数

> **recvfrom：接收客户端的数据**
>
> ```C
> #include <sys/types.h>
> #include <sys/socket.h>
> ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags, struct sockaddr *src_addr, socklen_t *addrlen);
> sockfd：自己的sock fd
> 
> buf：缓冲区
> len：缓冲区大小
>     
> flags：0
>     
> src_addr：传出参数，对端的地址结构
> addrlen：传出参数
>     
> 返回值：成功返回接收到数据字节数，失败返回-1设置error。
> ```

> #include <sys/types.h>
> #include <sys/socket.h>
> ssize_t sendto(int sockfd, const void *buf, size_t len, int flags, const struct sockaddr *dest_addr, socklen_t addrlen);
> sockfd：自己的sock fd
>
> buf：缓冲区
> len：缓冲区大小
>     
> flags：0
>     
> src_addr：传入参数，目标端的地址结构
> addrlen：传入参数
>     
> 返回值：成功返回发送的数据字节数，失败返回-1设置error。
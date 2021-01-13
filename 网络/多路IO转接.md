# 概念

+ 多路IO转接主要有三种模型：select，poll，epoll
+ 多路IO转接服务器也叫多任务IO服务器。主要思想是：不再由应用程序自己监视客户端连接，取而代之由内核替换应用程序监视文件

# select

+ 主要思路：
  + 设置需要监听的最大文件描述符fd
  + 将需要监听的fd添加到对应的读集合，写集合，异常集合。（根据自己想监听事件来添加）
  + 当所监视的事件被触发时，select函数会返回。返回值是触发事件的个数（包括所有事件，读事件，写事件，异常事件）。入参时的读集合，写集合，异常集合也会被当做出参重新赋值返回。重新赋值为：触发事件的fd集合
  + 当select返回时，我们可以通过出参中的事件集合，用fd跟这个集合调用FD_ISSET()，就知道这个fd有没有被触发对应事件。如果有的话，就可以进行操作处理。
+ 监听客户端连接的话，是监听listenfd的读事件
+ select能监听的文件描述符个数受限于FD_SETSIZE，一般为1024。单纯改变进程打开的文件描述符个数并不能改变select监听文件个数
+ 解决1024以下客户端时使用select是很合适的，但如果链接客户端过多，select采用的是轮询模型，会大大降低服务器响应效率，不应在select上投入更多精力。
+ 缺点：监听上限受限文件描述符限制（1024），编码难度较高
+ 优点：支持跨平台
+ 例子：[服务端代码](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/select_server.c)

```C
#include <sys/select.h>
/* According to earlier standards */
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
int select(int nfds, fd_set *readfds, fd_set *writefds,
fd_set *exceptfds, struct timeval *timeout);
nfds: 监控的文件描述符集里最大文件描述符加1，因为此参数会告诉内核检测前多少个文件描述符的状态
readfds：监控有读数据到达文件描述符集合，传入传出参数
    	传入：需要监听读事件的fd集合
    	传出：触发了读事件的fd集合
writefds：监控写数据到达文件描述符集合，传入传出参数
    	传入：需要监听写事件的fd集合
    	传出：触发了写事件的fd集合
exceptfds：监控异常发生达文件描述符集合,如带外数据到达异常，传入传出参数
    	传入：需要监听异常事件的fd集合
    	传出：触发了异常事件的fd集合
timeout：定时阻塞监控时间，3种情况
    1.NULL，永远等下去
    2.设置timeval，等待固定时间
    3.设置timeval里时间均为0，检查描述字后立即返回，轮询
    struct timeval {
        long tv_sec; /* seconds */
        long tv_usec; /* microseconds */
    };
返回值：已触发事件fd总数（包括读写异常事件）
```

```C
void FD_CLR(int fd, fd_set *set); 把文件描述符集合里fd清0
int FD_ISSET(int fd, fd_set *set); 测试文件描述符集合里fd是否置1
void FD_SET(int fd, fd_set *set); 把文件描述符集合里fd位置1
void FD_ZERO(fd_set *set); 把文件描述符集合里所有位清0
```

# poll

+ 主要思想：
  + 初始化一个待监听的pollfdfd数组，pollfd.fd值为-1
  + 使用数组中的一个元素作为监听fd，初始化其fd，监听的事件
  + 调用poll，返回触发了事件的个数
  + 遍历pollfd数组，可以通过每个元素中的revents&对应的事件，就知道该fd的该事件有没有被触发
+ 如果不再监控某个文件描述符时，可以把pollfd中，fd设置为-1，poll不再监控此pollfd，下次返回时，把revents设置为0。
+ 优点：可以将监听事件合集和触发事件合集分离。突破了文件描述符1024个的限制
+ 缺点：不能跨平台。无法直接定位满足事件的文件描述符，编码难度较大

```C
#include <poll.h>
int poll(struct pollfd *fds, nfds_t nfds, int timeout);
struct pollfd {
    int fd; /* 文件描述符 */
    short events; /* 监控的事件 */
    short revents; /* 监控事件中满足条件返回的事件 */
};
参数events可选范围：
    POLLIN普通或带外优先数据可读,即POLLRDNORM | POLLRDBAND
    POLLRDNORM-数据可读
    POLLRDBAND-优先级带数据可读
    POLLPRI 高优先级可读数据
    POLLOUT普通或带外数据可写
    POLLWRNORM-数据可写
    POLLWRBAND-优先级带数据可写
    POLLERR 发生错误
    POLLHUP 发生挂起
    POLLNVAL 描述字不是一个打开的文件
    
nfds 监控数组中有多少文件描述符需要被监控
    
timeout 毫秒级等待
    -1：阻塞等，#define INFTIM -1 Linux中没有定义此宏
    0：立即返回，不阻塞进程
    >0：等待指定毫秒数，如当前系统时间精度不够毫秒，向上取值
    
返回值：触发了事件的fd总数
```

# epoll

+ 底层实现的数据结构是红黑树

+ epoll是Linux下多路复用IO接口select/poll的增强版本，它能显著提高程序在大量并发连接中只有少量活跃的情况下的系统CPU利用率，因为它会复用文件描述符集合来传递结果而不用迫使开发者每次等待事件之前都必须重新准备要被侦听的文件描述符集合

+ 是获取事件的时候，它无须遍历整个被侦听的描述符集，只要遍历那些被内核IO事件异步唤醒而加入Ready队列的描述符集合就行了

+ 优点：高效，突破1024文件描述符。能直接返回触发事件的fd

+ 缺点：不能跨平台

+ 有两种模式：
  + 水平触发（LT模式，默认模式）：当缓冲区数据可读时，就会一直触发epoll_wait函数，直到缓冲区没有可读
  + 边沿触发（ET模式）：当有客户端发送数据时，不管缓冲区的数据有没有读完都只会触发一次epoll_wait函数。只支持非阻塞模式
  
+ 边沿触发（ET模式）：这就使得用户空间程序有可能缓存IO状态，减少epoll_wait/epoll_pwait的调用，提高应用程序效率

+ 主要思想：
  + 创建一个epoll句柄
  + 将设置需要监听的epoll_event事件（fd，对应的事件）
  + 将要监听的epoll_event事件添加到epoll句柄上
  + 等待触发事件epoll_wait
  + 当有事件触发时，则可以通过events事件数组得到哪些fd被触发了，就可以做对应的处理
  
+ 例子：

  > +  简单例子：创建epollfd->监听读事件->epoll_wait返回->执行read->处理对应的操作->write写回去->继续监听。[服务端代码](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/epoll_server.c)
  > + epoll反应堆：创建epollfd->监听读事件->epoll_wait返回->执行read（可读）->将读事件从树上摘下，将写事件重新挂到树上->epoll_wait返回->执行write（可写）->将写事件从树上摘下，将读事件重新挂到树上。。。（循环如此）。[epoll反应堆代码](https://github.com/594301947/knowledge/blob/master/%E7%BD%91%E7%BB%9C/code/epoll_reactor_server.c)

```C
头文件：#include <sys/epoll.h>
```

```C
创建一个epoll句柄，参数size用来告诉内核监听的文件描述符个数（推荐值），跟内存大小有关
int epoll_create(int size)
    
size：告诉内核监听的数目
```

```C
控制某个epoll监控的文件描述符上的事件：注册、修改、删除
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event)
    
epfd：为epoll_creat的句柄
    
op：表示动作，用3个宏来表示：
    EPOLL_CTL_ADD(注册新的fd到epfd)，
    EPOLL_CTL_MOD(修改已经注册的fd的监听事件)，
    EPOLL_CTL_DEL(从epfd删除一个fd)；
    
event：告诉内核需要监听的事件
    
struct epoll_event {
    __uint32_t events; /* Epoll events */
    epoll_data_t data; /* User data variable */
};
events取值：
    EPOLLIN ：表示对应的文件描述符可以读（包括对端SOCKET正常关闭），当缓冲区有数据达到水位线时会触发
    EPOLLOUT：表示对应的文件描述符可以写，当缓冲区的数据还没到达水位线，还有空间可写时
    EPOLLPRI：表示对应的文件描述符有紧急的数据可读（这里应该表示有带外数据到来）
    EPOLLERR：表示对应的文件描述符发生错误
    EPOLLHUP：表示对应的文件描述符被挂断；
    EPOLLET： 将EPOLL设为边缘触发(Edge Triggered)模式，这是相对于水平触发(Level Triggered)来说的
    EPOLLONESHOT：只监听一次事件，当监听完这次事件之后，如果还需要继续监听这个socket的话，需
    要再次把这个socket加入到EPOLL队列里
```

```C
等待所监控文件描述符上有事件的产生，类似于select()调用。
int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout)
    
events：用来从内核得到事件的集合，
    
maxevents：告之内核这个events有多大，这个maxevents的值不能大于创建epoll_create()时的size，
    
timeout：是超时时间
    -1：阻塞
    0：立即返回，非阻塞
    >0：指定微秒
    返回值：成功返回有多少文件描述符就绪，时间到时返回0，出错返回-1
```

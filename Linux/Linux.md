#  Linux工具教程：

https://linuxtools-rst.readthedocs.io/zh_CN/latest !!!

# top

+ top的信息摘抄于：[top linux下的任务管理器](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/top.html)

+ top命令是Linux下常用的性能分析工具，能够实时显示系统中各个进程的资源占用状况，类似于Windows的任务管理器。top是一个动态显示过程,即可以通过用户按键来不断刷新当前状态.如果在前台执行该命令,它将独占前台,直到用户终止该程序为止.比较准确的说,top命令提供了实时的对系统处理器的状态监视.它将显示系统中CPU最“敏感”的任务列表.该命令可以按CPU使用.内存使用和执行时间对任务进行排序；而且该命令的很多特性都可以通过交互式命令或者在个人定制文件中进行设定。
+ 我们常常用top命令来查看哪些进程CPU占用高，内存占用高
+ 在top基本视图中，按键盘数字“1”，可监控每个逻辑CPU的状况；

```
    top - 09:14:56 up 264 days, 20:56,  1 user,  load average: 0.02, 0.04, 0.00
    Tasks:  87 total,   1 running,  86 sleeping,   0 stopped,   0 zombie
    Cpu(s):  0.0%us,  0.2%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0.2%st
    Mem:    377672k total,   322332k used,    55340k free,    32592k buffers
    Swap:   397308k total,    67192k used,   330116k free,    71900k cached
    PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
    1 root      20   0  2856  656  388 S  0.0  0.2   0:49.40 init
    2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd
    3 root      20   0     0    0    0 S  0.0  0.0   7:15.20 ksoftirqd/0
    4 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0
```

+ 第一行：时间相关
  + 09:14:56 ： 系统当前时间
  + 264 days, 20:56 ： 系统开机到现在经过了多少时间
  + 1 users ： 当前2用户在线
  + load average: 0.02, 0.04, 0.00： 系统1分钟、5分钟、15分钟的CPU负载信息(数字/CPU核数 在0.00-1.00之间正常)正在运行的进程 + 准备好等待运行的进程  在特定时间内（1分钟，5分钟，10分钟）的平均进程数 

+ 第二行：进程数量相关
  + Tasks：任务;
  + 87 total：很好理解，就是当前有87个任务，也就是87个进程。
  + 1 running：1个进程正在运行
  + 86 sleeping：86个进程睡眠
  + 0 stopped：停止的进程数
  + 0 zombie：僵死的进程数
+ 第三行：CPU信息
  - Cpu(s)：表示这一行显示CPU总体信息
  - 0.0%us：用户态进程占用CPU时间百分比，不包含renice值为负的任务占用的CPU的时间。
  - 0.7%sy：内核占用CPU时间百分比
  - 0.0%ni：改变过优先级的进程占用CPU的百分比
  - 99.3%id：空闲CPU时间百分比
  - 0.0%wa：等待I/O的CPU时间百分比
  - 0.0%hi：CPU硬中断时间百分比
  - 0.0%si：CPU软中断时间百分比
  - 注：这里显示数据是所有cpu的平均值，如果想看每一个cpu的处理情况，按1即可；折叠，再次按1；

- 第四行
  - Men：内存的意思8175320kk 
  - total：物理内存总量8058868k 
  - used：使用的物理内存量116452k 
  - free：空闲的物理内存量283084k 
  - buffers：用作内核缓存的物理内存量
- 第五行：SWAP空间
  - Swap：交换空间
  - 6881272k total：交换区总量
  - 4010444k used：使用的交换区量
  - 2870828k free：空闲的交换区量
  - 4336992k cached：缓冲交换区总量
- 进程信息
  - 再下面就是进程信息：
  - PID：进程的ID
  - USER：进程所有者
  - PR：进程的优先级别，越小越优先被执行
  - NInice：值
  - VIRT：进程占用的虚拟内存
  - RES：进程占用的物理内存
  - SHR：进程使用的共享内存
  - S：进程的状态。S表示休眠，R表示正在运行，Z表示僵死状态，N表示该进程优先值为负数
  - %CPU：进程占用CPU的使用率
  - %MEM：进程使用的物理内存和总内存的百分比
  - TIME+：该进程启动后占用的总的CPU时间，即占用CPU使用时间的累加值。
  - COMMAND：进程启动命令名称

https://blog.csdn.net/zhangchenglikecc/article/details/52103737

# buffer和cache

## 1.buffer：

buffer就是写入到磁盘。buffer是为了提高内存和硬盘（或其他I/O设备）之间的数据交换的速度而设计的。buffer将数据缓冲下来，解决速度慢和快的交接问题；速度快的需要通过缓冲区将数据一点一点传给速度慢的区域。例如：从内存中将数据往硬盘中写入，并不是直接写入，而是缓冲到一定大小之后刷入硬盘中。

## 2.cache：

cache就是从磁盘读取数据然后存起来方便以后使用。cache实现数据的重复使用，速度慢的设备需要通过缓存将经常要用到的数据缓存起来，缓存下来的数据可以提供高速的传输速度给速度快的设备。例如：将硬盘中的数据读取出来放在内存的缓存区中，这样以后再次访问同一个资源，速度会快很多。

## 3.buffer和cache的特点

### 共性：

都属于内存，数据都是临时的，一旦关机数据都会丢失。

### 差异：(先理解前两点，后两点有兴趣可以了解)

1. buffer是要写入数据；cache是已读取数据。
2. buffer数据丢失会影响数据完整性，源数据不受影响；cache数据丢失不会影响数据完整性，但会影响性能。
3. 一般来说cache越大，性能越好，超过一定程度，导致命中率太低之后才会越大性能越低。buffer来说，空间越大性能影响不大，够用就行。cache过小，或者没有cache，不影响程序逻辑（高并发cache过小或者丢失导致系统忙死除外）。buffer过小有时候会影响程序逻辑，如导致网络丢包。
4. cache可以做到应用透明，编写应用的可以不用管是否有cache，可以在应用做好之后再上cache。当然开发者显式使用cache也行。buffer需要编写应用的人设计，是程序的一部分。

原文链接：https://blog.csdn.net/qq_27516841/article/details/99682823
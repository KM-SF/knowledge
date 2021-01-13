/*
 * @Descripttion: epoll反应堆
 * 创建epollfd->监听读事件->epoll_wait返回->执行read（可读）->将读事件从树上摘下，将写事件重新挂到树上->
 * epoll_wait返回->执行write（可写）->将写事件从树上摘下，将读事件重新挂到树上。。。（循环如此）
 * @Autor: km
 * @Date: 1970-01-01 08:00:00
 * @LastEditTime: 2021-01-13 23:08:51
 * @FilePath: /mnt/hgfs/code/C/tcp/epoll_reactor_server.c
 */
#include <stdlib.h>
#include <stdio.h>
#include <sys/epoll.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <ctype.h>
#include "err.h"

#define PORT 9612
#define EVENT_SIZE 1024

typedef struct
{
    int fd;                     // 监听的fd
    int epfd;                   // 红黑树 epoll fd
    void *arg;                  // 回调函数的参数
    void *buf;                  // 收发数据buf
    int buf_len;                // 收发数据的实际大小
    int max_buf_len;            // 收发数据的最大大小
    uint32_t events;            // 监听的事件
    void *(*func)(void *arg);   // 触发的回调函数

} event_data_t;

void *write_cbk(void *arg);

char *toupper_str(char *str)
{
    int index;
    for (index = 0; str[index] != '\0'; index++)
        str[index] = toupper(str[index]);
    return str;
}

int init_socket()
{
    int ret;
    int listenfd;
    int opt;
    struct sockaddr_in svr_addr;

    svr_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    svr_addr.sin_family = AF_INET;
    svr_addr.sin_port = htons(PORT);

    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    if (listenfd < 0)
        sys_err("listend socket failed", 1);

    opt = 1;
    ret = setsockopt(listenfd, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt));
    if (ret < 0)
        sys_err("set sock opt failed", 1);

    ret = bind(listenfd, (struct sockaddr *)&svr_addr, sizeof(svr_addr));
    if (ret < 0)
        sys_err("bind server failed", 1);

    ret = listen(listenfd, 128);
    if (ret < 0)
        sys_err("listen server failed", 1);
    return listenfd;
}

void init_event_data(int epfd, int fd, uint32_t events, void *(*func_cbk)(void *arg), event_data_t **evt_data)
{
    int ret;

    (*evt_data) = (event_data_t *)malloc(sizeof(event_data_t));
    memset((*evt_data), 0, sizeof(event_data_t));

    (*evt_data)->buf_len = 0;
    (*evt_data)->max_buf_len = BUFSIZ;
    (*evt_data)->buf = malloc((*evt_data)->max_buf_len);

    (*evt_data)->arg = (void *)(*evt_data);
    (*evt_data)->fd = fd;
    (*evt_data)->epfd = epfd;
    (*evt_data)->func = func_cbk;
    (*evt_data)->events = events;
}


void event_add(event_data_t *evt_data)
{
    int ret;
    struct epoll_event event;

    event.events = evt_data->events;
    event.data.ptr = (void *)evt_data;
    ret = epoll_ctl(evt_data->epfd, EPOLL_CTL_ADD, evt_data->fd, &event);
    if (ret < 0)
        sys_err("epoll ctl add failed", 1);
}

void event_del(event_data_t *evt_data)
{
    epoll_ctl(evt_data->epfd, EPOLL_CTL_DEL, evt_data->fd, NULL);
    free(evt_data->buf);
    free(evt_data);
}


/**
 * @description: 先从树上摘下，再重新挂上去。修改fd对应监听的事件和回调函数
 * @param {event_data_t} *evt_data：要改变的event_data
 * @param {int} events：要改成的监听事件
 * @param {void} *：要改成的回调函数
 * @return {*}
 * @author: km
 */
void event_mod(event_data_t *evt_data, int events, void *(*func_cbk)(void *arg))
{
    int ret;
    struct epoll_event event;

    ret = epoll_ctl(evt_data->epfd, EPOLL_CTL_DEL, evt_data->fd, NULL);
    if (ret < 0)
        sys_err("epoll ctl del failed", 1);

    evt_data->events = events;
    evt_data->func = func_cbk;

    event.events = evt_data->events;
    event.data.ptr = (void *)evt_data;
    ret = epoll_ctl(evt_data->epfd, EPOLL_CTL_ADD, evt_data->fd, &event);
    if (ret < 0)
        sys_err("epoll ctl del failed", 1);
}

void destory_socket(int listen_fd)
{
    close(listen_fd);
}

/**
 * @description: 当缓冲区可读时，从缓冲区中读取客户端发送的数据，并且将EPOLLIN事件修改为EPOLLOUT
 * @param {*}
 * @return {*}
 * @author: km
 */
void *read_cbk(void *arg)
{
    event_data_t *evt_data = (event_data_t *)arg;

    evt_data->buf_len = 0;
    memset(evt_data->buf, 0, evt_data->max_buf_len);
    evt_data->buf_len = read(evt_data->fd, evt_data->buf, evt_data->max_buf_len);
    if (evt_data->buf_len == 0)
    {
        printf("client fd:%d connect close\n", evt_data->fd);
        close(evt_data->fd);
        event_del(evt_data);
    }
    else
    {
        printf("read client fd:%d  read_buf:%s\n", evt_data->fd, (char *)evt_data->buf);
        toupper_str(evt_data->buf);
        event_mod(evt_data, EPOLLOUT, write_cbk);
    }
}

/**
 * @description: 当缓冲区可写时，发送数据给客户端，并且将EPOLLOUT事件修改为EPOLLIN
 * @param {*}
 * @return {*}
 * @author: km
 */
void *write_cbk(void *arg)
{
    event_data_t *evt_data = (event_data_t *)arg;
    int writen = 0;

    writen = write(evt_data->fd, evt_data->buf, evt_data->buf_len);
    if (writen < 0)
    {
        printf("client fd:%d exception will close\n", evt_data->fd);
        close(evt_data->fd);
        event_del(evt_data);
    }
    else
    {
        printf("send to client fd:%d buf:%s \n", evt_data->fd, (char *)evt_data->buf);
        event_mod(evt_data, EPOLLIN, read_cbk);
    }
}

/**
 * @description: 监听客户端的连接，收到连接后将cfd挂到epoll fd树上
 * @param {*}
 * @return {*}
 * @author: km
 */
void *listen_cbk(void *arg)
{
    event_data_t *evt_data = (event_data_t *)arg;

    int clt_fd = 0;
    struct sockaddr_in clt_addr;
    char clt_ip[INET_ADDRSTRLEN];
    socklen_t clt_len = sizeof(clt_addr);
    event_data_t *clt_data;

    clt_fd = accept(evt_data->fd, (struct sockaddr *)&clt_addr, &clt_len);
    if (clt_fd < 0)
        sys_err("accpet client failed", 1);

    printf("client fd:%d ip:%s port:%d connect success\n", clt_fd, inet_ntop(AF_INET, &clt_addr, clt_ip, sizeof(clt_ip)), ntohs(clt_addr.sin_port));

    init_event_data(evt_data->epfd, clt_fd, EPOLLIN, read_cbk, &clt_data);

    event_add(clt_data);
}

int main()
{
    int ret;
    int listen_fd;
    int epfd;
    int eventn;
    int index;
    event_data_t *listen_data;
    event_data_t evt_data;
    struct epoll_event listen_event;
    struct epoll_event event;
    struct epoll_event events[EVENT_SIZE];

    listen_fd = init_socket(listen_fd);
    epfd = epoll_create(EVENT_SIZE);
    if (epfd < 0)
        sys_err("epoll create fail", 1);

    init_event_data(epfd, listen_fd, EPOLLIN, listen_cbk, &listen_data);

    event_add(listen_data);

    while (1)
    {
        eventn = epoll_wait(epfd, events, EVENT_SIZE, -1);
        for (index = 0; index < eventn; index++)
        {
            event = events[index];
            if (event.events & EPOLLIN || event.events & EPOLLOUT)
            {
                evt_data = *((event_data_t *)event.data.ptr);
                evt_data.func(evt_data.arg);
            }
        }
    }

    event_del(listen_data);
    destory_socket(listen_fd);
    return 0;
}
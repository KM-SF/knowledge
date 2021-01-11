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
    int fd;
    int epfd;
    void *arg;
    uint32_t events;
    void *(*func)(void *arg);

} event_data_t;

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
    struct sockaddr_in svr_addr;

    svr_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    svr_addr.sin_family = AF_INET;
    svr_addr.sin_port = htons(PORT);

    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    if (listenfd < 0)
        sys_err("listend socket failed", 1);

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
        sys_err("epoll ctl failed", 1);
}

void event_del(event_data_t *evt_data)
{
    epoll_ctl(evt_data->epfd, EPOLL_CTL_DEL, evt_data->fd, NULL);
    free(evt_data);
}

void destory_socket(int listen_fd)
{
    close(listen_fd);
}

void *read_cbk(void *arg)
{
    event_data_t *evt_data = (event_data_t *)arg;
    int readn = 0;
    char read_buf[BUFSIZ];

    memset(read_buf, 0, sizeof(read_buf));
    readn = read(evt_data->fd, read_buf, BUFSIZ);
    if (readn == 0)
    {
        printf("client fd:%d connect close\n", evt_data->fd);
        close(evt_data->fd);
        event_del(evt_data);
    }
    else
    {
        printf("read client fd:%d  read_buf:%s\n", evt_data->fd, read_buf);
        toupper_str(read_buf);
        write(evt_data->fd, read_buf, readn);
    }
}

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
            if (event.events & EPOLLIN)
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
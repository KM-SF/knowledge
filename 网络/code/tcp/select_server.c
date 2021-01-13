#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <ctype.h>
#include "err.h"

#define PORT 9612
#define ARRAY_SIZE FD_SETSIZE
#define FD_INIT_VAL -1

typedef struct
{
    int cfd;
    struct sockaddr_in clt_addr;
    char clt_ip[INET_ADDRSTRLEN];
} client_info_t;

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
    int listen_fd;
    int opt;
    struct sockaddr_in srv_addr;

    srv_addr.sin_family = AF_INET;
    srv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    srv_addr.sin_port = htons(PORT);

    listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_fd < 0)
        sys_err("init socket failed", 1);

    opt = 1;
    ret = setsockopt(listen_fd, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt));
    if (ret < 0)
        sys_err("set sock opt failed", 1);

    ret = bind(listen_fd, (struct sockaddr *)&srv_addr, sizeof(srv_addr));
    if (ret < 0)
        sys_err("bind socket failed", 1);

    ret = listen(listen_fd, 128);
    if (ret < 0)
        sys_err("listen socket failed", 1);

    return listen_fd;
}

void destory_socket(int listen_fd)
{
    close(listen_fd);
}

void init_fd_arr(int *fd_arr)
{
    for (int i = 0; i < FD_SETSIZE; i++)
    {
        fd_arr[i] = FD_INIT_VAL;
    }
}

int find_max_index(int *fd_arr)
{
    int i = 0;
    int max_index = i;
    for (i = 0; i < FD_SETSIZE; i++)
    {
        if (fd_arr[i] != FD_INIT_VAL)
            max_index = i;
    }
    return max_index;
}

int find_max_fd(int *fd_arr)
{
    int i = 0;
    int max_fd = fd_arr[i];
    for (i = 0; i < FD_SETSIZE; i++)
    {
        if (fd_arr[i] == 0)
            break;
        max_fd = fd_arr[i] > max_fd ? fd_arr[i] : max_fd;
    }
    return max_fd;
}

void set_fd_arr(int fd, int *fd_arr)
{
    int i = 0;
    for (i = 0; i < FD_SETSIZE; i++)
    {
        if (fd_arr[i] == FD_INIT_VAL)
        {
            fd_arr[i] = fd;
            break;
        }
    }
}

void clear_fd_arr(int fd, int *fd_arr)
{
    int i = 0;
    for (i = 0; i < FD_SETSIZE; i++)
    {
        if (fd_arr[i] == fd)
        {
            fd_arr[i] = FD_INIT_VAL;
            break;
        }
    }
}

void do_accpet(int listen_fd, client_info_t *clt_info_arr, fd_set *listen_set, int *fd_arr, int *max_fd, int *max_index)
{
    int clt_fd = 0;
    struct sockaddr_in clt_addr;
    char clt_ip[INET_ADDRSTRLEN];
    socklen_t clt_len = sizeof(clt_addr);

    clt_fd = accept(listen_fd, (struct sockaddr *)&clt_addr, &clt_len);
    if (clt_fd < 0)
        sys_err("accpet client failed", 1);

    printf("client fd:%d ip:%s port:%d connect success\n", clt_fd, inet_ntop(AF_INET, &clt_addr, clt_ip, sizeof(clt_ip)), ntohs(clt_addr.sin_port));
    FD_SET(clt_fd, listen_set);
    if (clt_fd > *max_fd)
        *max_fd = clt_fd;
    set_fd_arr(clt_fd, fd_arr);
    *max_index = find_max_index(fd_arr);

    memset(&clt_info_arr[clt_fd], 0, sizeof(clt_info_arr[clt_fd]));
    clt_info_arr[clt_fd].cfd = clt_fd;
    memcpy(&clt_info_arr[clt_fd].clt_addr, &clt_addr, sizeof(clt_info_arr->clt_addr));
    strcpy(clt_info_arr[clt_fd].clt_ip, clt_ip);
}

void do_work(int clt_fd, client_info_t *clt_info_arr, fd_set *listen_set, int *fd_arr, int *max_fd, int *max_index)
{

    int readn = 0;
    char read_buf[BUFSIZ];
    client_info_t clt_info = clt_info_arr[clt_fd];

    memset(read_buf, 0, sizeof(read_buf));
    readn = read(clt_fd, read_buf, BUFSIZ);
    if (readn == 0)
    {
        printf("client fd:%d ip:%s port:%d connect close\n",clt_info.cfd, clt_info.clt_ip, ntohs(clt_info.clt_addr.sin_port));
        close(clt_fd);
        memset(&clt_info_arr[clt_fd], 0, sizeof(clt_info_arr[clt_fd]));
        FD_CLR(clt_fd, listen_set);
        clear_fd_arr(clt_fd, fd_arr);
        if (clt_fd == *max_fd)
        {
            *max_fd = find_max_fd(fd_arr);
            *max_index = find_max_index(fd_arr);
        }
    }
    else
    {
        printf("read client fd:%d ip:%s port:%d, read_buf:%s\n", clt_info.cfd, clt_info.clt_ip, ntohs(clt_info.clt_addr.sin_port), read_buf);
        toupper_str(read_buf);
        write(clt_info.cfd, read_buf, readn);
    }
}

int main()
{

    int listen_fd;
    int fd_arr[FD_SETSIZE];
    int max_index = 0;
    int max_fd = 0;
    int fd_events = 0;
    fd_set listen_set;
    client_info_t clt_info_arr[ARRAY_SIZE];

    listen_fd = init_socket(listen_fd);

    init_fd_arr(&fd_arr);

    set_fd_arr(listen_fd, &fd_arr);

    max_index = find_max_index(&fd_arr);
    max_fd = find_max_fd(&fd_arr);
    FD_SET(listen_fd, &listen_set);

    while (1)
    {
        fd_set read_set = listen_set;

        //printf("max fd:%d, max index:%d events:%d\n", max_fd, max_index, fd_events);
        
        fd_events = select(max_fd + 1, &read_set, NULL, NULL, NULL);
        if (fd_events < 0)
            sys_err("select failed", 1);
        if (FD_ISSET(listen_fd, &read_set))
        {
            do_accpet(listen_fd, clt_info_arr, &listen_set, fd_arr, &max_fd, &max_index);
            fd_events--;
        }

        for (int index = 0; index <= max_index && fd_events; index++)
        {
            int clt_fd = fd_arr[index];
            if (FD_ISSET(clt_fd, &read_set))
            {
                do_work(clt_fd, clt_info_arr, &listen_set, fd_arr, &max_fd, &max_index);
                fd_events--;
            }
        }
    }

    destory_socket(listen_fd);
    return 0;
}
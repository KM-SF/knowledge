#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <ctype.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "err.h"

#define PORT 9612
char *toupper_str(char *str)
{

    int index;
    for (index = 0; str[index] != '\0'; index++)
        str[index] = toupper(str[index]);
    return str;
}

void do_work(int cfd, struct sockaddr_in client_addr)
{
    int read_len;
    char read_buf[BUFSIZ];
    char client_ip[1024];

    printf("process:%d work start!!!\n", getpid());
    inet_ntop(AF_INET, &client_addr, client_ip, sizeof(client_ip));
    while (1)
    {
        read_len = read(cfd, read_buf, BUFSIZ);
        if (read_len == 0)
        {
            printf("client:%s port:%d has close\n", client_ip, ntohs(client_addr.sin_port));
            break;
        }
        printf("read client:%s port:%d, read len:%d buf:%s \n", client_ip, ntohs(client_addr.sin_port), read_len, read_buf);

        toupper_str(read_buf);
        write(cfd, read_buf, read_len);
        memset(read_buf, 0, read_len);
    }
    close(cfd);
    printf("process:%d finish!!!\n", getpid());
}

void server()
{
    pid_t pid;
    int ret = 0;
    int lfd = 0, cfd = 0;
    int read_len = 0;
    socklen_t client_len = 0;
    struct sockaddr_in client_addr;
    struct sockaddr_in server_addr;

    printf("process:%d server start!!!\n", getpid());

    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);

    lfd = socket(AF_INET, SOCK_STREAM, 0);
    if (lfd == -1)
        sys_err("socket error:", 1);

    ret = bind(lfd, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (ret < 0)
        sys_err("bind error:", 1);

    ret = listen(lfd, 128);
    if (ret < 0)
        sys_err("bind error:", 1);

    while (1)
    {
        client_len = sizeof(client_addr);
        cfd = accept(lfd, (struct sockaddr *)&client_addr, &client_len);
        if (cfd == -1)
            sys_err("accept clien failed:", 1);

        pid = fork();
        if (pid < 0)
        {
            sys_err("fork faild", 1);
        }
        else if (pid == 0)
        {
            /* child */
            do_work(cfd, client_addr);
            break;
        }
        else
        {
            /* parent */
            close(cfd);
        }
    }
    close(lfd);
}

void gc()
{
    pid_t pid;
    while ((pid = waitpid(-1, NULL, WNOHANG)) != -1 && pid != 0)
    {
        /* code */
        printf("child process:%d has gc\n", pid);
    }
}

int main()
{

    pid_t pid;
    pid = fork();
    if (pid < 0)
        sys_err("fork faild", 1);
    else if (pid == 0)
        /* child */
        server();
    else
        /* code */
        gc();
    return 0;
}
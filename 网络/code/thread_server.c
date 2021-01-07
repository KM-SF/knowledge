#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

#define PORT 9612

void sys_err(const char *str, int errno)
{
    perror(str);
    exit(errno);
}

char *toupper_str(char *str)
{

    int index;
    for (index = 0; str[index] != '\0'; index++)
        str[index] = toupper(str[index]);
    return str;
}

void *do_work(void *data)
{

    int client_fd = *((int *)data);
    char read_buf[BUFSIZ];
    int readn;

    while (1)
    {

        readn = read(client_fd, read_buf, sizeof(read_buf));
        if (readn == 0)
        {
            printf("close\n");
            break;
        }
        printf("read:%s\n",read_buf);
        toupper_str(read_buf);
        write(client_fd, read_buf, readn);
        memset(read_buf,0, readn);
    }

    close(client_fd);
}

int main()
{

    int ret;
    int listenfd;
    int clientfd;
    socklen_t clt_len = 0;
    struct sockaddr_in svr_add;
    struct sockaddr_in clt_add;
    pthread_attr_t attr;

    svr_add.sin_addr.s_addr = htonl(INADDR_ANY);
    svr_add.sin_family = AF_INET;
    svr_add.sin_port = htons(PORT);

    listenfd = socket(AF_INET, SOCK_STREAM, 0);
    if (listenfd < 0)
        sys_err("listend socket failed", 1);

    ret = bind(listenfd, (struct sockaddr *)&svr_add, sizeof(svr_add));
    if (ret < 0)
        sys_err("bind server failed", 1);

    ret = listen(listenfd, 128);
    if (ret < 0)
        sys_err("listen server failed", 1);

    ret = pthread_attr_init(&attr);
    if (ret) {
        printf("init thread attr failed:%s", strerror(ret));
        exit(1);
    }

    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (ret) {
        printf("init thread attr detach failed:%s", strerror(ret));
        exit(1);
    }

    while (1)
    {
        pthread_t pid;
        clt_len = sizeof(clt_add);
        clientfd = accept(listenfd, (struct sockaddr *)&clt_add, &clt_len);
        if (clientfd < 0)
        {
            sys_err("accept client failed", 1);
        }
        pthread_create(&pid, &attr, do_work, &clientfd);
    }

    pthread_attr_destroy(&attr);
    close(listenfd);
    return 0;
}
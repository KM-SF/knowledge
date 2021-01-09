#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

#define PORT 9612

typedef struct
{
    int cfd;
    struct sockaddr_in client_add;
} client_info_t;

void sys_err(const char *str, int errno)
{
    perror(str);
    exit(errno);
}

void thread_err(const char *str, int errno)
{
    printf("%s :%s", str, strerror(errno));
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
    client_info_t *client_info = (client_info_t *)data;
    char client_ip[1024];
    char read_buf[BUFSIZ];
    int readn;

    while (1)
    {
        readn = read(client_info->cfd, read_buf, sizeof(read_buf));
        if (readn == 0)
        {
            printf("read client add:%s port:%d, close\n", inet_ntop(AF_INET, &client_info->client_add, client_ip, sizeof(client_ip)), ntohs(client_info->client_add.sin_port));
            break;
        }
        printf("read client add:%s port:%d, buf:%s\n", inet_ntop(AF_INET, &client_info->client_add, client_ip, sizeof(client_ip)), ntohs(client_info->client_add.sin_port), read_buf);
        toupper_str(read_buf);
        write(client_info->cfd, read_buf, readn);
        memset(read_buf, 0, readn);
    }

    close(client_info->cfd);
    free(client_info);
}

int init_socket()
{
    int ret;
    int listenfd;
    struct sockaddr_in svr_add;

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
    return listenfd;
}

void init_thread_attr(pthread_attr_t *attr)
{
    int ret;
    ret = pthread_attr_init(attr);
    if (ret)
        thread_err("init thread attr failed", ret);

    ret = pthread_attr_setdetachstate(attr, PTHREAD_CREATE_DETACHED);
    if (ret)
        thread_err("set thread attr detach failed", ret);
}

int main()
{

    int ret;
    int listenfd;
    int clientfd;
    socklen_t clt_len = 0;

    struct sockaddr_in clt_add;
    pthread_attr_t attr;

    listenfd = init_socket();

    init_thread_attr(&attr);

    while (1)
    {

        pthread_t pid;
        clt_len = sizeof(clt_add);
        clientfd = accept(listenfd, (struct sockaddr *)&clt_add, &clt_len);
        if (clientfd < 0)
            sys_err("accept client failed", 1);

        client_info_t *client_info = (client_info_t *)malloc(sizeof(client_info_t));
        if (client_info == NULL)
            sys_err("malloc failed:", -1);

        memset(client_info, 0, sizeof(client_info_t));
        client_info->cfd = clientfd;
        memcpy(&client_info->client_add, &clt_add, sizeof(struct sockaddr_in));

        ret = pthread_create(&pid, &attr, do_work, client_info);
        if (ret)
            thread_err("create thread failed", ret);
    }

    pthread_attr_destroy(&attr);
    close(listenfd);
    return 0;
}
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <ctype.h>
#include <string.h>

#define PORT 9612

void sys_err(const char *str)
{
    perror(str);
    exit(1);
}

char *toupper_str(char *str)
{

    int index;
    for (index = 0; str[index] != '\0'; index++)
        str[index] = toupper(str[index]);
    return str;
}

int main()
{
    int ret = 0;
    int lfd = 0, cfd = 0;
    int read_len = 0;
    char read_buf[BUFSIZ];
    char *send_buf;
    char client_ip[1024];
    struct sockaddr_in server_addr;
    struct sockaddr_in client_addr;
    socklen_t client_len = 0;

    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);

    lfd = socket(AF_INET, SOCK_STREAM, 0);
    if (lfd == -1)
    {
        sys_err("socket error:");
        exit(1);
    }

    ret = bind(lfd, (struct sockaddr *)&server_addr, sizeof(server_addr));
    if (ret < 0)
    {
        sys_err("bind error:");
        exit(1);
    }

    ret = listen(lfd, 128);
    if (ret < 0)
    {
        sys_err("bind error:");
        exit(1);
    }

    client_len = sizeof(client_addr);
    cfd = accept(lfd, (struct sockaddr *)&client_addr, &client_len);
    if (cfd == -1)
    {
        sys_err("accept clien failed:");
        exit(1);
    }

    while (1)
    {
        read_len = read(cfd, read_buf, sizeof(read_buf));
        if (read_len == 0)
        {
            printf("client:%s port:%d has close\n", inet_ntop(AF_INET, &client_addr, client_ip, sizeof(client_ip)), ntohs(client_addr.sin_port));
            break;
        }
        printf("read client:%s port:%d, read buf:%s\n", inet_ntop(AF_INET, &client_addr, client_ip, sizeof(client_ip)), ntohs(client_addr.sin_port), read_buf);

        toupper_str(read_buf);
        write(cfd, read_buf, read_len);
        memset(read_buf, 0, read_len);
    }

    close(cfd);
    close(lfd);
    return 0;
}
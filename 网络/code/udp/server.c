/*
 * @Descripttion: udp服务端
 * @Autor: km
 * @Date: 1970-01-01 08:00:00
 * @LastEditTime: 2021-01-14 00:36:03
 * @FilePath: /mnt/hgfs/code/C/udp/server.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <ctype.h>

#define PORT 9612

char *toupper_str(char *str)
{
    int index;
    for (index = 0; str[index] != '\0'; index++)
        str[index] = toupper(str[index]);
    return str;
}

int main()
{
    int fd;
    char buf[BUFSIZ];
    int buf_len;
    char clnt_ip[INET_ADDRSTRLEN];
    socklen_t clnt_len;
    struct sockaddr_in srv_addr;
    struct sockaddr_in clnt_addr;

    fd = socket(AF_INET, SOCK_DGRAM, 0);

    memset(&srv_addr, 0, sizeof(struct sockaddr_in));
    srv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons(PORT);

    bind(fd, (struct sockaddr*)&srv_addr, sizeof(srv_addr));

    while (1)
    {
        memset(buf, 0, sizeof(buf));
        clnt_len = sizeof(clnt_addr);
        buf_len = recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr*)&clnt_addr, &clnt_len);
        printf("client:%s port:%d buf:%s\n", inet_ntop(AF_INET, &srv_addr, clnt_ip, sizeof(clnt_ip)), ntohs(srv_addr.sin_port), buf);

        toupper_str(buf);
        sendto(fd, buf, buf_len, 0, (struct sockaddr *)&clnt_addr, sizeof(clnt_addr));
    }
    close(fd);
    return 0;
}
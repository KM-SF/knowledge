/*
 * @Descripttion: 
 * @Autor: km
 * @Date: 1970-01-01 08:00:00
 * @LastEditTime: 2021-01-14 00:38:08
 * @FilePath: /mnt/hgfs/code/C/udp/client.c
 */
/*
 * @Descripttion: udp客户端
 * @Autor: km
 * @Date: 1970-01-01 08:00:00
 * @LastEditTime: 2021-01-14 00:27:08
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

int main()
{
    int fd;
    char buf[BUFSIZ];
    int buf_len;
    char clnt_ip[INET_ADDRSTRLEN];
    socklen_t clnt_len;
    struct sockaddr_in srv_addr;

    fd = socket(AF_INET, SOCK_DGRAM, 0);

    memset(&srv_addr, 0, sizeof(struct sockaddr_in));
    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons(PORT);
    inet_pton(AF_INET, "127.0.0.1", &srv_addr.sin_addr.s_addr);

    memset(buf, 0, sizeof(buf));

    while ( (buf_len = read(STDIN_FILENO, buf, sizeof(buf))) != EOF)
    {
        //printf("buf %s len %ld\n", send_buf, strlen(send_buf));
        sendto(fd, buf, buf_len, 0, (struct sockaddr*)&srv_addr, sizeof(srv_addr));
        
        memset(&buf, 0, sizeof(buf));
        buf_len = recvfrom(fd, buf, sizeof(buf), 0, NULL, NULL);
        printf("%s\n",buf);
        memset(buf, 0, sizeof(buf));
    }

    close(fd);
    return 0;
}
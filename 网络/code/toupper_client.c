#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

#define PORT 9612

void sys_err(const char *str)
{
    perror(str);
    exit(1);
}

int main() {

    int cfd;
    int read_len;
    int send_len;
    char send_buf[BUFSIZ];
    char read_buf[BUFSIZ];
    struct sockaddr_in server_addr;

    memset(send_buf, 0, sizeof(send_buf));

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    inet_pton(AF_INET, "127.0.0.1", &server_addr.sin_addr.s_addr);

    cfd = socket(AF_INET, SOCK_STREAM, 0);
    if (cfd == -1) {
        sys_err("socket failed");
    }
    
    int ret = connect(cfd, (struct sockaddr*)&server_addr,sizeof(server_addr) );
    if (ret != 0) {
        sys_err("connet err");
    }

    while ( (send_len = read(STDIN_FILENO, send_buf, sizeof(send_buf))) != EOF)
    {
        //printf("buf %s len %ld\n", send_buf, strlen(send_buf));
        write(cfd, send_buf, send_len);
        read_len = read(cfd, read_buf, sizeof(read_buf));
        write(STDOUT_FILENO, read_buf, read_len);
    }
    close(cfd);
    return 0;
}
// 目的：每个进程是否都是拥有自己的文件描述符表，互不影响
// 测试步骤：运行两个进程，查看打印出来的fd是否都一样
// 结论：两个进程都是从3号fd开始打印。两个进程都拥有自己的文件描述符表，互不影响

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main()
{

    char *file_name = "test_procee.txt";
    int fd = -1;


    fd = open(file_name, O_CREAT | O_RDWR, 0777);
    if (fd == -1) {
        perror("open fd false\n");
        exit(1);
    }

    printf("fd :%d\n", fd);
    while (1)
    {
        /* code */
    }
    
    close(fd);

    return 0;
}
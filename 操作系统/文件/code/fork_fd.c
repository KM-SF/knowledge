// 目的：父子进程是否都是拥有自己的文件描述符表，互不影响
// 测试步骤：运行进程，查看打印出来的fd是否都一样
// 结论：父子进程都是从3号fd开始打印。两个进程都拥有自己的文件描述符表，互不影响。
// 注意：父进程在fork之前创建出来的fd。再fork之后，虽然fd的值一样，fd所对应的文件指针指向的文件表项是同一个。父子进程操作该fd都会互相影响

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

void create_file(const char *file_name, const char *owner) {

    int fd = -1;
    fd = open(file_name, O_CREAT | O_RDWR, 0777);
    if (fd == -1) {
        perror("open fd false\n");
        exit(1);
    }
    printf("owner:%s file name:%s fd:%d\n",owner, file_name, fd);
    while (1) {}
    close(fd);

}

int main()
{

    char *file_name = "test_fork.txt";
    int fd = -1;
    pid_t pid = 0;

    fd = open(file_name, O_CREAT | O_RDWR, 0777);
    if (fd == -1) {
        perror("open fd false\n");
        exit(1);
    }

    pid = fork();
    if (pid == 0) {
        // 子进程
        printf("child fd :%d\n", fd);
        create_file("child file", "child");
    }
    else {
        // 父进程
        printf("parent fd :%d\n", fd);
        create_file("parent file", "parent");
    }
    
    while (1) {}
    close(fd);

    return 0;
}
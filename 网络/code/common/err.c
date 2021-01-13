#include "err.h"


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

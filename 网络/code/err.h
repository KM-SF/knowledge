#ifndef ERR
#define ERR
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

void sys_err(const char *str, int errno);

void thread_err(const char *str, int errno);

#endif
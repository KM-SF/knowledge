#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <time.h>
#include <unistd.h>


#define LL_ADD(item, list) do {         \
    item->next = list;                  \
    if ( list!=NULL ) list->prev = item;  \
    list = item;                        \
} while (0)

#define LL_REMOVE(item, list) do {      \
    if ( item->prev != NULL ) item->prev->next = item->next;    \
    if ( item->next != NULL ) item->next->prev = item->prev;    \
    if ( list == item ) list = item->next;                      \
    item->prev = item->next = NULL;                              \
} while (0)


typedef struct NJOB
{
    void (*job_func)(void *arg);
    void *arg;
    struct NJOB *next;
    struct NJOB *prev;

}job_t;

typedef struct NWORKER
{
    pthread_t thread_id;

    struct NMANAGER *pool;
    struct NWORKER *next;
    struct NWORKER *prev;

}worker_t;

typedef struct NMANAGER
{
    job_t *jobs;         // 任务队列的头结点
    worker_t * workers;  // 执行队列的头结点（线程集合）
    int terminate;       // 销毁线程池
    pthread_mutex_t mtx; // 加锁防止出现多个线程抢同一个任务的情况
    pthread_cond_t cond; // 等待任务队列不为空，唤醒线程执行队列

}thread_pool_t;


void *nThreadCallback(void *arg){

    worker_t * worker = (worker_t *)arg;
    while ( 1 )
    {
        // if task == NULL -> wait
        pthread_mutex_lock(&worker->pool->mtx);
        while ( worker->pool->jobs == NULL ) {
            // 所有任务都执行完成且有终止标记，退出线程
            if (worker->pool->terminate) {
                printf("terminate!!!\n");
                goto end;
            };
            
            pthread_cond_wait(&worker->pool->cond, &worker->pool->mtx);
        }
        
        // get task
        // remove task
        job_t *job = worker->pool->jobs;
        if (job != NULL) {
            LL_REMOVE(job, worker->pool->jobs);
        }
        pthread_mutex_unlock(&worker->pool->mtx);
        // task->func()
        if (job != NULL) {
            job->job_func(job);
            free(job->arg);
            free(job);
        }
    }
end:
    pthread_mutex_unlock(&worker->pool->mtx);

}

int nThreadPoolPushTask(thread_pool_t *pool, job_t *job){

    // ADD job -> pool->jobs
    pthread_mutex_lock(&pool->mtx);
    LL_ADD(job, pool->jobs);
    // notify
    
    pthread_mutex_unlock(&pool->mtx);
    pthread_cond_signal(&pool->cond);

}

int nThreadPoolCreate(thread_pool_t *pool, int worker_nums) {

    // check param
    if ( pool == NULL ) return -1;
    memset( pool, 0, sizeof(thread_pool_t) );

    if (worker_nums < 1 ) worker_nums = 1;

    // pool -> init
    pthread_mutex_init(&(pool->mtx), NULL);
    pthread_cond_init(&(pool->cond), NULL);

    int i = 0;
    for (i ; i < worker_nums; ++i) {
        
        // create worker    
        worker_t *worker = (worker_t *)malloc(sizeof(worker_t));
        if (worker == NULL) {
            perror("malloc");
            return -2;
        }

        memset(worker, 0, sizeof(worker_t));
        worker->pool = pool;

        // create thread. binb worker <-> thread_id
        int ret = pthread_create(&worker->thread_id, NULL, nThreadCallback, worker);
        if (ret){
            perror("pthread_create");
            free(worker);
            return -3;
        }
        // add worker -> pool->workers
        LL_ADD(worker, pool->workers);
    
    }

    return 0;
}

int nThreadPoolDestroy(thread_pool_t *pool) {

    // 防止多次调用释放资源
    if (pool->terminate)
        return 0;
    
    // 设置线程终止标记
    pool->terminate = 1;

    // 唤醒所有的线程，使线程看到销毁标志为1后，全部都退出
    pthread_cond_broadcast(&(pool->cond));

    // 等待线程全部执行完成
    worker_t *head = pool->workers;
    while (head)
    {
        pthread_join(head->thread_id, NULL);
        worker_t *temp = head;
        head = head->next; 
        LL_REMOVE(temp, pool->workers);
        if ( temp ){
            free(temp);
            temp = NULL;
        }
        
    }
            
    pthread_mutex_destroy(&pool->mtx);
    pthread_cond_destroy(&pool->cond);
    free(pool);
    pool = NULL;
    return 0;
}

#if 1
#define WORKER_NUMS 10
#define COUNTER_SIZE 1000

void jobCbk (void *arg) {

    job_t *job = (job_t *)arg;
    printf(" counter --> %d\n", *(int *)job->arg);
}

int main() {

    thread_pool_t *pool = (thread_pool_t*)malloc(sizeof(thread_pool_t));
    memset(pool, 0, sizeof(thread_pool_t));
    nThreadPoolCreate(pool, WORKER_NUMS);
    
    int i = 0;
    for ( i = 0; i < COUNTER_SIZE; i++) {
        job_t *job = (job_t *)malloc(sizeof(job_t)); 
        if (job == NULL) {
            perror("malloc");
            exit(1);
        }
        memset(job, 0, sizeof(job_t));

        job->job_func = jobCbk;
        job->arg = (int *)malloc(sizeof(int));
        memset(job->arg, 0, sizeof(int));
        *( (int *)job->arg ) = i;
        nThreadPoolPushTask(pool, job);
    }
    nThreadPoolDestroy(pool);
}

#endif
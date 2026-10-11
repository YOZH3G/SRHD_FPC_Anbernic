#include <switch.h>
#include <errno.h>
#include <malloc.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

/* The handler calls newlib formatting and filesystem code. libnx's default
 * 1 KiB stack cannot even hold fprintf's first nested frames. */
alignas(16) u8 __nx_exception_stack[16 * 1024];
u64 __nx_exception_stack_size = sizeof(__nx_exception_stack);
extern int fpc_nx_run(int argc, char **argv);
extern char _start[];

void __libnx_exception_handler(ThreadExceptionDump *ctx) {
    fprintf(stderr, "Switch fault %x: PC=%016lx LR=%016lx FAR=%016lx module=%p\n", ctx->error_desc,
            ctx->pc.x, ctx->lr.x, ctx->far.x, _start);
    for (int i = 0; i < 29; ++i)
        fprintf(stderr, "X%d=%016lx\n", i, ctx->cpu_gprs[i].x);
    fflush(stderr);
    fsync(fileno(stderr));
    svcExitProcess();
}

void sr_switch_memory_status(uint64_t *capacity, uint64_t *available) {
    extern char *fake_heap_start, *fake_heap_end;
    struct mallinfo info = mallinfo();
    *capacity = (uintptr_t)fake_heap_end - (uintptr_t)fake_heap_start;
    *available = *capacity > (uint64_t)info.uordblks ? *capacity - info.uordblks : 0;
}

int main(int argc, char **argv) {
    mkdir("sdmc:/switch", 0777);
    mkdir("sdmc:/switch/SpaceRangersHD", 0777);
    mkdir("sdmc:/switch/SpaceRangersHD/user", 0777);
    if (!freopen("sdmc:/switch/SpaceRangersHD/user/stderr.log", "w", stderr))
        return 1;
    if (!freopen("sdmc:/switch/SpaceRangersHD/user/stdout.log", "w", stdout)) {
        fprintf(stderr, "Cannot open stdout.log: %s\n", strerror(errno));
        return 1;
    }
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    if (chdir("sdmc:/switch/SpaceRangersHD/game") != 0) {
        fprintf(stderr, "Cannot open sdmc:/switch/SpaceRangersHD/game: %s\n", strerror(errno));
        return 1;
    }
    /* Keep the load address beside crash logs for offline ELF symbolization. */
    fprintf(stderr, "Space Rangers HD: module=%p\n", _start);
    fsync(fileno(stderr));
    return fpc_nx_run(argc, argv);
}

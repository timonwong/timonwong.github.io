---
title: 在 Go 中获取 stacktrace
date: 2014-07-21 21:30:12
tags: [Go]
---


``` go 打印 stacktrace
buf := make([]byte, 1<<16)
// 获取 **所有** goroutine 的 stacktrace
runtime.Stack(buf, true)
// 如果需要获取 **当前** goroutine 的 stacktrace, 第二个参数需要为 `false`
runtime.Stack(buf, true)
fmt.Println(string(buf))
```

太诡异了，居然要指定 buffer 的大小，用起来不方便。虽然可以给个“足够大” buffer 用来容纳
stacktrace，但是什么是“足够大”？

为了确认 `runtime.Stack()` 函数的 behavior，需要参考一下 Go 输出 stacktrace 的实现代码。该代码是使用 [GOC] 写成的。

[GOC]: https://code.google.com/p/go/source/browse/src/cmd/dist/goc2c.c

> A .goc file is a combination of a limited form of Go with C.

``` go mprof.goc https://code.google.com/p/go/source/browse/src/pkg/runtime/mprof.goc?name=release-branch.go1.3#382
func Stack(b Slice, all bool) (n int) {
    uintptr pc, sp;

    // Stack pointer
    sp = runtime·getcallersp(&b);
    // Programer pointer
    pc = (uintptr)runtime·getcallerpc(&b);

    // 如果选择输出所有 goroutine 的 traceback, 挂起所有goroutine,
    // 在本函数完成后恢复
    if(all) {
        runtime·semacquire(&runtime·worldsema, false);
        m->gcing = 1;
        runtime·stoptheworld();
    }

    if(b.len == 0)
        n = 0;
    else{
        // 重定向输出缓冲, 打印到 `b` 这个buffer里
        g->writebuf = (byte*)b.array;
        // buffer具有固定大小, 因此会截断
        g->writenbuf = b.len;
        // proc.c: runtime·goroutineheader
        runtime·goroutineheader(g);
        // traceback_${arch}.c
        runtime·traceback(pc, sp, 0, g);
        if(all)
            runtime·tracebackothers(g);
        n = b.len - g->writenbuf;
        g->writebuf = nil;
        g->writenbuf = 0;
    }

    if(all) {
        m->gcing = 0;
        runtime·semrelease(&runtime·worldsema);
        runtime·starttheworld();
    }
}
```

因为打印到buffer会截断过长的结果，因此可以写一个包装函数：


``` go
func StackTrace(all bool) string {
    // Reserve 10K buffer at first
    buf := make([]byte, 10240)

    for {
        size := runtime.Stack(buf, all)
        // The size of the buffer may be not enough to hold the stacktrace,
        // so double the buffer size
        if size == len(buf) {
            buf = make([]byte, len(buf)<<1)
            continue
        }
        break
    }

    return string(buf)
}

```

例子可以在这里看到：[Go Playground](http://play.golang.org/p/4ABrCVbH9g)

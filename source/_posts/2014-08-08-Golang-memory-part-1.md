title: "Golang 内存模型（一）"
date: 2014-08-08 08:39:44
categories: IT
tags: [Go, Golang]
---

## 开始之前

首先，这是一篇菜B写的文章，可能会有理解错误的地方，发现错误请斧正，谢谢。

为了治疗我的懒癌早期，我一次就不写得太多了，这个系列想写很久了，每次都是开了个头就没有再写。这次争取把写完，弄成一个系列。

## 此 nil 不等彼 nil

_先声明，这个标题有标题党的嫌疑。_

Go 的类型系统是比较奇葩的，`nil` 的含义跟其它语言有些差别，这里举个例子（可以直接进入 http://play.golang.org/p/ezFhXX0dnB 运行查看结果）：

``` go
package main

import "fmt"

type A struct {
}

func main() {
    var a *A = nil
    var ai interface{} = a
    var ei interface{} = nil

    fmt.Printf("ai == nil: %v\n", ai == nil)
    fmt.Printf("ai == ei: %v\n", ai == ei)
    fmt.Printf("ei == a: %v\n", a == ei)
    fmt.Printf("ei == nil: %v\n", ei == nil)
}

// -> 输出
// ai == nil: false
// ai == ei: false
// ei == a: false
// ei == nil: true
```

这里 `ai != nil`，对于没有用过 Go 的人来说比较费解，对我来说，这个算得上一门语言设计有歧义的地方（Golang FAQ 有对于此问题的描述，可以参考一下：[http://golang.org/doc/faq#nil_error](http://golang.org/doc/faq#nil_error)）。

简单的说就是 nil 代表 "zero value"（空值），**对于不同类型，它具体所代表的值不同**。比如上面的 `a` 为“`*A` 类型的空值”，而 `ai` 为“`interface{}` 类型的空值”。造成理解失误的最大问题在于，`struct pointer` 到 `interface` 有隐式转换（`var ai interface{] = a`，这里有个隐式转换），至于为什么对于 Go 这种在其它转换方面要求严格，而对于 `interface` 要除外呢，for convenience 吧，呵呵……

碰到了这个坑，我就开始好奇了，Go 的类型系统到底是什么样的？

<!-- more -->

## Go 内存模型 - interface

### 概述

为了读懂下面的内容，你需要：

- 了解 C、Go 语言
- Go 1.3 源代码 (https://go.googlecode.com/archive/go1.3.zip)

**PS:** 由于 Go 用到了 `Plan9 C` 这个小众的C编译器的扩展，比如在函数签名中使用 `·` 字符以区分 package/function（比如`runtime·panic`），这对理解不会产生什么影响。

**PSS:** 对于 Go runtime，可以参考`src/pkg/reflect`（`reflect`包）中的的代码，对类型系统的实现的理解有帮助。

Go 语言的类型定义可以在 `src/pkg/runtime/` 目录下找到，主要由以下几个文件构成：

- `runtime.h`
- `type.h`

对于 `interface` 类型，主要看下面几个结构体定义：

- `InterfaceType`
- `Itab`
- `Iface`
- `Eface`

它们的C语言定义如下 (可以在 `runtime.h` 中找到)：

**InterfaceType:**

代表了总的 interface 类型，其中：

- Type: 类型描述，所有的类型都有这个类型描述（比如 array, map, slice）
- mhdr 以及 m: interface 接口方法列表

``` c
struct InterfaceType
{
    Type;
    Slice mhdr;
    IMethod m[];
};
```

**Itab:**

类似于虚函数表，该表不会被GC回收，其中：

- inter: 指向具体的 interface 类型
- type: 具体实现类型, 也即 receiver type
- link: 指向下一个函数表，因为 interface 可以 embed 多个 interface，因此实现为一个链表形式
- bad: <略>
- unsued: <略>
- fun: 函数列表，每个元素是一个指向具体函数实现的指针

``` c
struct  Itab
{
    InterfaceType*  inter;
    Type*   type;
    Itab*   link;
    int32   bad;
    int32   unused;
    void    (*fun[])(void);
};
```

**Iface:**

该类型为一般的 `interface` 类型所对应的数据结构，其中：

- tab: 参见 `Itab` 的说明，尤其是 `Itab::link`
- data: 指向具体数据（比如指向struct，当然，如果一个数据不超过一个字长，那么这个data就可以直接存放，不需要指针再做以及跳转）

``` c
struct Iface
{
    Itab*   tab;
    void*   data;
};
```

**Eface:**

该类型为 `interface{}` (empty interface) 所对应的数据结构，其中：

- type: 具体实现类型, 也即 receiver type
- data: 同 `Iface`

``` c
struct Eface
{
    Type*   type;
    void*   data;
};
```

他们的依赖关系如下图所示：


![](http://theo-im.qiniudn.com/images/graph/20140808-interface-deps.png)


先到这里，下一篇将会举例子说明给一个 `interface{}` 类型的变量赋值后，其具体的内存结构是怎么样的。

打了几个小时，真费时间，争取这个系列不坑 (逃

---
title: 'RabbitMQ笔记（二）: 并发连接数'
date: 2014-05-13 16:16:21
categories: RabbitMQ
tags: RabbitMQ
---

## 概要

对于服务器来说，并发连接数一直是一个需要考量的问题，因此在这里做一个简单的测试。

这里的测试分几步进行：

1. 耗尽 rabbitmq 的 socket descriptors
2. TBD
3. TBD

<!-- more -->

## 测试

在测试前，需要准备一个客户端环境，本文的环境是:

- CentOS 6.3
- Python 2.7.6
  - kombu

[kombu]: http://kombu.readthedocs.org/

**NOTE:** 下文中的 IP 地址 `10.10.0.70` 为 RabbitMQ 服务器的 IP 地址

### 测试1: 耗尽 rabbitmq 的 socket descriptors

首先, 编写一个脚本:

``` python exhaust_socket_descriptors.py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import logging

import config

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)
LOG = logging.getLogger(os.path.basename(__file__))


def main():
    connections = []
    while True:
        LOG.info("Try to establish a new rabbit connection...")
        connection = config.get_connection()
        connection.connect()
        connections.append(connection)
        LOG.info("[%d] connections", len(connections))


if __name__ == '__main__':
    main()
```

在**客户端**执行`exhaust_socket_descriptors.py`, 会看到如下输出:

```
...
...
...
2014-05-13 10:45:17,464 - exhaust_socket_descriptors.py - INFO - [824] connections
2014-05-13 10:45:17,464 - exhaust_socket_descriptors.py - INFO - Try to establish a new rabbit connection...
2014-05-13 10:45:17,477 - exhaust_socket_descriptors.py - INFO - [825] connections
2014-05-13 10:45:17,477 - exhaust_socket_descriptors.py - INFO - Try to establish a new rabbit connection...
2014-05-13 10:45:17,489 - exhaust_socket_descriptors.py - INFO - [826] connections
2014-05-13 10:45:17,489 - exhaust_socket_descriptors.py - INFO - Try to establish a new rabbit connection...
2014-05-13 10:45:17,502 - exhaust_socket_descriptors.py - INFO - [827] connections
2014-05-13 10:45:17,502 - exhaust_socket_descriptors.py - INFO - Try to establish a new rabbit connection...
2014-05-13 10:45:17,516 - exhaust_socket_descriptors.py - INFO - [828] connections
2014-05-13 10:45:17,516 - exhaust_socket_descriptors.py - INFO - Try to establish a new rabbit connection...
2014-05-13 10:45:17,528 - exhaust_socket_descriptors.py - INFO - [829] connections
2014-05-13 10:45:17,529 - exhaust_socket_descriptors.py - INFO - Try to establish a new rabbit connection...
```

看到似乎是连接耗尽了，在**服务器端**上确认一下：

```
[root@localhost vagrant]# rabbitmqctl status | grep sockets_
      {sockets_limit,829},
      {sockets_used,829}]},
```

`sockets_used` 与 `sockets_limit` 相同，可以确认 socket descriptors 耗尽了，因此客户端成功新连接，卡在
`Try to establish a new rabbit connection...` 处。但是问题在于，**为什么不超时？**

在**客户端**中检查一下TCP连接个数:

```
[root@localhost ~]# netstat -atn | grep 10.10.0.70:5672 | wc -l
830
```

可以得出，socket连接数是830，大于服务器端的`sockets_limit`

继续，在**客户端**中，检查一下TCP连接状态：

```
[root@localhost ~]# netstat -atn | grep 10.10.0.70:5672  | awk '{print $6}' | uniq
ESTABLISHED
```

**全部都是ESTABLISHED状态**，因此服务器仅仅是阻塞了新连接，而不是拒绝新连接。




## 结论

## Workaround: 增加File Descriptors个数

通过官方(包括EPEL)的 `deb`, `rpm` 包安装的启动脚本，都会在`rabbitmq-server`
启动前 `source` 一次 `/etc/default/rabbitmq-server` 文件，因此我们可以在该文件中增加最大允许的 File Descriptors 个数。

``` bash
echo 'ulimit -n 102400' > /etc/default/rabbitmq-server
```
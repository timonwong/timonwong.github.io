---
title: 'RabbitMQ笔记（二）: 并发连接数'
date: 2014-05-13 16:16:21
categories: IT
tags: RabbitMQ
---

## 概要

对于服务器来说，并发连接数一直是一个需要考量的问题，因此在这里做一个简单的测试。

## 测试

在测试前，需要准备一个客户端环境，本文的环境是:

- CentOS 6.3
- Python 2.7.6
  - [Kombu]

[Kombu]: http://kombu.readthedocs.org/

**NOTE:** 下文中的 IP 地址 `10.10.0.70` 为 RabbitMQ 服务器的 IP 地址

### 测试: 耗尽 rabbitmq 的 socket descriptors

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
...前略...
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

**全部都是ESTABLISHED状态**，因此服务器仅仅是阻塞了新连接，而不是拒绝新连接。这样，就产生了一个问题：

如果是使用 [HAProxy] 等工具搭建的集群，由于**服务器依然会接受新连接**，因此 [HAProxy] 不会认为节点已Down，**最终会导致整个集群卡住**；

[HAProxy]: http://clusterlabs.org/

### Bug ###

当 RabbitMQ 的 `sockets_used` 达到 `sockets_limits` 时候（连接数耗尽时），最终即使是 Consumer
也会全部阻塞，只有在 `sockets_used < sockets_limit` 时（释放部分连接后），才会恢复。

参见以下连接获取更多信息: http://markmail.org/message/r4yhvqc7vgfljpao


## Workaround: 增加File/Socket Descriptors个数

通过官方(包括EPEL)的 `deb`, `rpm` 包安装的启动脚本，都会在`rabbitmq-server`
启动前 `source` 一次 `/etc/default/rabbitmq-server` 文件，因此我们可以在该文件中增加最大允许的
File/Socket Descriptors 个数。

``` bash
echo 'ulimit -n 102400' > /etc/default/rabbitmq-server
```

最后，重启 RabbitMQ 服务器以生效该设置：

``` bash
service rabbitmq-server restart
```

## Updated

### May 17, 2014

- 更新 Bug 说明 (RabbitMQ `bug26180`)

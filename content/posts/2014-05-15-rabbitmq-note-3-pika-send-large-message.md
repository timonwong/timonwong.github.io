---
title: 'RabbitMQ笔记（三）: Pika客户端（Python）发送大尺寸消息的问题'
tags: [RabbitMQ, Pika, Python]
date: 2014-05-15 10:27:25
---


## 问题描述

这个问题存在很久了，现象就是使用 [Pika] 库的客户端在发送大尺寸消息后，RabbitMQ
没有收到，Consumer 那里会认为消息已丢失。

**NOTE:** 即使在本文写时的最新版(v0.9.13)依然存在这个问题。

## 分析

因为网络状态很好，所以没有考虑网络的错误，直接考虑[Pika]库的问题。

那么第一步就是把 [Pika] 的代码拿来读一遍，主要看它是怎么发送消息的，经过一番探索，找到了
`pika/adapters/base_connection.py` 这个文件，来看看里面的内容：

``` python pika/adapters/base_connection.py https://github.com/pika/pika/blob/0.9.13/pika/adapters/base_connection.py#L329
    def _handle_write(self):
        """Handle any outbound buffer writes that need to take place."""
        total_written = 0
        if self.outbound_buffer:
            try:
                bytes_written = self.socket.send(self.outbound_buffer.popleft())
            except socket.timeout:
                raise
            except socket.error, error:
                return self._handle_error(error)
            total_written += bytes_written
        return total_written
```

看出问题了吗？

来看看`socket.send`的文档吧：

{% blockquote Python Docs https://docs.python.org/2/library/socket.html#socket.socket.send socket.send %}
Send data to the socket. The socket must be connected to a remote socket. The optional flags argument has the same meaning as for recv() above. Returns the number of bytes sent. Applications are responsible for checking that all data has been sent; if only some of the data was transmitted, the application needs to attempt delivery of the remaining data. For further information on this concept, consult the Socket Programming HOWTO.
{% endblockquote %}

问题就是，没有检查 `socket.send` 的返回值，由于 `socket.send` 返回实际发送的直接个数，可能会小于期望（在这里是
`self.outbound_buffer.popleft()`）。

由于 `socket.send` 可能没有将数据发送完成就返回了，造成了消息丢失的情况。


本来想自己修的，看了一眼 [Pika] 的 `master` 分支，已经修正了（一次保证将一个帧(Frame)发送完成）：

``` python pika/adapters/base_connection.py https://github.com/pika/pika/blob/master/pika/adapters/base_connection.py#L354
    def _handle_write(self):
        """Handle any outbound buffer writes that need to take place."""
        bytes_written = 0
        if self.outbound_buffer:
            frame = self.outbound_buffer.popleft()
            try:
                self.socket.sendall(frame)
                bytes_written = len(frame)
            except socket.timeout:
                raise
            except socket.error as error:
                return self._handle_error(error)
        return bytes_written
```

呵呵……


## 解决

1. 自行打补丁；
2. 使用 `git` 上的 Pika: `pip install git+https://github.com/pika/pika.git`；
3. 不用 [Pika], 换其它的，比如 [Kombu]。


我现在不用 [Pika] 了，用 [Kombu]。

**PS:** [Pika] 的发布也太不积极了，都怎么久了还不发新版本。

[Pika]: https://pypi.python.org/pypi/pika/
[Kombu]: http://kombu.readthedocs.org/

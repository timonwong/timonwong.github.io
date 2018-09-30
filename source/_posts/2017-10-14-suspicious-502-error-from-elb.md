---
title: 解决 AWS ELB 偶发的 502 Bad Gateway 错误
date: 2017-10-14 23:32:11
categories: IT
tags: [AWS]
---

## 问题描述

在使用了 [Prometheus] [blackbox_exporter] 做了 HTTP 协议的监控之后，[blackbox_exporter] 偶尔会报一些 ProbeDown 的报警，经过检查是 502 Bad Gateway 错误，但此时后端是正常的，只是在 AWS ELB 的监控指标中，看到了 ELB HTTP 5xx 相关错误，因此困扰了一段时间。

HTTP 数据流向如下：

```
[Client] --- [ELB] --- [nginx] --- [App Servers]
```

## 排查问题

<!-- more -->

最开始是怀疑是后端问题，但是查阅了 nginx 和 App servers 的日志，没有任何结果，只是在 ELB 日志里面找到了 502 Bad Gateway 的错误信息。无奈之下甚至怀疑 nginx 所在 EC2 instance 有问题，因此求助了 AWS 技术支持。根据建议，在 nginx 这端做了 tcpdump 抓包，最后终于在 AWS 技术支持的帮助下，定位并解决了问题 🎉。

先补充一个知识：如果后端支持的话，ELB 会使用保持连接（HTTP persistent/keep-alive connections）。来看看这一个保持连接的 TCP stream：

![](https://theo-im-1255089908.cos.ap-chengdu.myqcloud.com/images/2017-10-14-tcpdump.png)

其中，`10.100.2.186` 是 ELB 内部 IP，`10.100.250.22` 是 nginx 服务器内部 IP。这样，可以看到：

- 在 76.69 秒时候，连接被创建；
- 在 181.69 秒的时候，是最后一次有效请求；
- 在 256.69 秒的时候（No.7475），该连接被 nginx 关闭；
- 在 256.69 秒的时候，几乎在同时还有一个 HTTP GET 请求（No.7476）；
- 由于 nginx 已经关闭连接了，上面的这个请求当然会收到 TCP RST，ELB 无法访问后端服务器，就会返回 502 Bad Gateway 了。

刚刚过了 75 秒（256.69 - 181.69）连接就被 nginx 关闭了，是不是很眼熟：nginx [keepalive_timeout] 参数的默认值，恰好就是 75 秒。

很明显是遇到了 Keep-Alive timeout race 了，而这个问题其实在 HTTP/1.1 下，是不好解决的，只有靠微调降低出现的概率；禁用 Keep-Alive；或者靠 Client 上层处理。

## 解决问题

由于 ELB 并不受我们的控制，所以考虑对后端进行微调。根据不同的场景，可以：

- 增加后端服务器持久连接的保持时间，比如 nginx 增加 `keepalive_timeout` 参数
- 减少 ELB 的 idle timeout
- 禁用 HTTP 持久连接（不推荐）

根据[这篇解决 Google Cloud Platform 负载均衡器类似问题的文章](https://blog.percy.io/tuning-nginx-behind-google-cloud-platform-http-s-load-balancer-305982ddb340)，说明我不是一个人😂。

[Prometheus]: https://prometheus.io
[blackbox_exporter]: https://github.com/prometheus/blackbox_exporter
[keepalive_timeout]: http://nginx.org/en/docs/http/ngx_http_core_module.html#keepalive_timeout

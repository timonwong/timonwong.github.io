---
title: 将钉钉接入 Prometheus AlertManager WebHook
date: 2017-10-16T21:08:03
tags: [Prometheus]
---

## TL;DR

**Disclaimer**: Personally I dislike [DingTalk]\(a.k.a DingDing\) at all 😜.

Project Repo: [https://github.com/timonwong/prometheus-webhook-dingtalk](https://github.com/timonwong/prometheus-webhook-dingtalk)

<!--more-->

## Why

在敝人的「忽悠」下，敝厂在 2016 年中就全面使用了 [Prometheus] 作为监控系统，这个系统现在已经比较火了，这里就不再多加口舌阐述。后来，敝厂使用了钉钉作为公司内部的指定通（dă）讯（kă）软件，取代了 [Slack]。不得不说，比起 [Slack] 来，显示报警通知，钉钉不美观。

按照我个人的看法，一个合格的报警通知，应该包含如下内容：

- 报警级别
- 简短的报警名称
- 简要说明
- 详细说明
- 附加上下文信息
- 一个链接，点击后进入指标的 Graph

幸运的是，[Prometheus] [AlertManager] 已经包含了一个做得比较好的 [Slack] 报警模板，只需要从[这里](https://github.com/prometheus/docs/blob/db2a09a8a7e193d6e474f37055908a6d432b88b5/content/docs/alerting/configuration.md#webhook_config)开始就可以了。

## Routes

`prometheus-webhook-dingtalk` 默认监听在`8060`端口（可配置）上，提供了以下路由供 [AlertManager] 的 [webhook_configs](https://prometheus.io/docs/alerting/configuration/#<webhook_config>) 使用：

- `/dingtalk/<profile>/send`

注意这里的 `<profile>` 需要在 `-ding.profile` 中指定相应的名称（`<profile>`）以及钉钉的自定义机器人 WebHook URL（`<dingtalk-webhook-url>`）。

## Usage

首先，我个人不喜欢随处都是配置文件的现象，因此 `prometheus-webhook-dingtalk` 的所有配置通过命令行参数完成:

```
usage: prometheus-webhook-dingtalk --ding.profile=DING.PROFILE [<flags>]

Flags:
  -h, --help             Show context-sensitive help (also try --help-long and --help-man).
      --web.listen-address=":8060"
                         The address to listen on for web interface.
      --ding.profile=DING.PROFILE ...
                         Custom DingTalk profile (can specify multiple times, <profile>=<dingtalk-url>).
      --ding.timeout=5s  Timeout for invoking DingTalk webhook.
      --log.level=info   Only log messages with the given severity or above. One of: [debug, info, warn, error]
      --version          Show application version.
```

关于这里的 `-ding.profile` 参数：为了支持同时往多个钉钉自定义机器人发送报警消息，因此 `-ding.profile` 可以在命令行中指定多次，比如:

```bash
prometheus-webhook-dingtalk \
    --ding.profile="webhook1=https://oapi.dingtalk.com/robot/send?access_token=xxxxxxxxxxxx" \
    --ding.profile="webhook2=https://oapi.dingtalk.com/robot/send?access_token=yyyyyyyyyyy"
```

这里就定义了两个 WebHook，一个 `webhook1`，一个 `webhook2`，用来往不同的钉钉组发送报警消息。

然后在 [AlertManager] 的配置里面，加入相应的 `receiver`（注意下面的 `url`）即可：

```yaml
receivers:
- name: send_to_dingding_webhook1
  webhook_configs:
  - send_resolved: false
    url: http://localhost:8060/dingtalk/webhook1/send
- name: send_to_dingding_webhook2
  webhook_configs:
  - send_resolved: false
    url: http://localhost:8060/dingtalk/webhook2/send
```

### In Action

参见官方文章：[https://open-doc.dingtalk.com/docs/doc.htm?treeId=257&articleId=105735&docType=1](https://open-doc.dingtalk.com/docs/doc.htm?treeId=257&articleId=105735&docType=1)，然后将 webhook 地址拷贝下来，传给 `prometheus-webhook-dingtalk`。

最后，来个截图看看效果吧：

![](/images/2016-10-16-dingtalk-in-action.png)


[Slack]: https://slack.com
[Prometheus]: https://prometheus.io
[AlertManager]: https://github.com/prometheus/alertmanager
[DingTalk]: https://www.dingtalk.com

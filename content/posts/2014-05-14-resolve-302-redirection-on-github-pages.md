---
title: "解决GitHub Pages的302转向问题"
date: 2014-05-14 10:34:21
tags: [GitHub, DNS]
---

## 起因

**NOTE:** 如果给GitHub Pages使用的是子域名，按照[GitHub Pages文档]配置，不会出现该问题。

由于我在GitHub Pages上的搭的博客使用了`theo.im`这个根域名(Apex Domain)，在按照
[GitHub Pages文档]上提供的信息，对`theo.im`设置了**A记录**，但是通过执行命令：

``` bash
curl -I http://theo.im/sitemap.xml
```

发现得到的是302转向，不符合Sitemap协议的要求：

{% blockquote sitemaps.org http://www.sitemaps.org/protocol.html Sitemaps Protocol %}
A successful request will return an HTTP 200 response code; if you receive a different response, you should resubmit your request. The HTTP 200 response code only indicates that the search engine has received your Sitemap, not that the Sitemap itself or the URLs contained in it were valid.
{% endblockquote %}

[GitHub Pages文档]: https://help.github.com/articles/setting-up-a-custom-domain-with-github-pages

## 解决

通过搜索，我发现需要使用**ALIAS记录**解析根域名，但是由于我之前使用的是[DNSPod]
的服务，不支持**ALIAS记录**，因此决定换加DNS域名解析商。

经过一番搜寻，找到了两家支持**ALIAS记录**的DNS域名解析商：

1. [DNSimple]\: 全收费服务
2. [PointDNS]\: 有免费的开发者账户

本着能用收费不用免费的原则，因此我选择了 [DNSimple] 来解析我的域名 (゜o゜(☆○=(-_-)

![](https://theo-im-1255089908.cos.ap-chengdu.myqcloud.com/images/github-pages-dns-buybuybuy.jpg)

OK，万文不如一图：

![](https://theo-im-1255089908.cos.ap-chengdu.myqcloud.com/images/github-pages-dns-setup.png)

最后，运行 `dig theo.im +nostats +nocomments +nocmd` 检查DNS是否生效：

```
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.23.rc1.el6_5.1 <<>> theo.im +nostats +nocomments +nocmd
;; global options: +cmd
;theo.im.           IN  A
theo.im.        3600    IN  A   199.27.79.133
```

[DNSPod]: http://dnspod.cn
[DNSimple]: https://dnsimple.com/
[PointDNS]: https://pointhq.com/

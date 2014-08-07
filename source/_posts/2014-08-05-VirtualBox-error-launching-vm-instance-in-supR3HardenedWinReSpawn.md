title: "VirtualBox与杀毒软件冲突导致虚拟机无法启动: 错误 \"supR3HardenedWinReSpawn\""
date: 2014-08-05 13:29:44
categories: Miscellaneous
tags: [VirtualBox, Vagrant]
---

今天在公司机器上装了 VirtualBox (版本 4.3.14) 和 Vagrant, 在运行 `vagrant up` 后总是提示虚拟机不能启动的错误。打开 VirtualBox 然后手动启动虚拟机发现如下错误框：

![](http://theo-im.qiniudn.com/images/virtualbox-error.png)


```
---------------------------
VirtualBox - Error In supR3HardenedWinReSpawn
---------------------------
Error relaunching VirtualBox VM process: 5
Command line: '81954AF5-4D2F-31EB-A142-B7AF187A1C41-suplib-2ndchild --comment Work_default_1407215688716_8404 --startvm 93cdc421-ae20-49d6-8ca4-6c5570f809cd --no-startvm-errormsgbox' (rc=-104)/>
---------------------------
```

原因:

* 与 Symantec Endpoint Protection 冲突

临时解决办法：

* 使用 4.3.12 版本的 VirtualBox，[点击这里下载](https://www.virtualbox.org/wiki/Download_Old_Builds_4_3).

**NOTE** 降级 VirtualBox 后需要重新启动计算机

另外可以[参考VirtualBox 论坛的讨论](https://forums.virtualbox.org/viewtopic.php?f=6&t=62615)

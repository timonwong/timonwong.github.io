---
title: 删除 Intel HD Graphics 显卡工具的全局快捷键
date: 2014-08-07 10:44:43
categories: Miscellaneous
tags:
description: 防止 igfxHK.exe 劫持全局快捷键
---

Intel的内置显卡工具总是注册全局的快捷键，而且还是常用的（比如 `Sublime Text`, `PyCharm`等工具的默认按键绑定），如下：

* <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Up<kbd>
* <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Down</kbd>
* <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Left</kbd>
* <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Right</kbd>


这些快捷键都是由 `igfxHK.exe` 注册的，虽然可以在任务栏中点击禁用快捷键，但是由于快捷键是全局注册，其它应用程序仍然不能使用这些快捷键。

虽然使用 `taskkill /IM igfxHK.exe` 来强行终止其进程，释放全局快捷键也可以，但是每次重启都要重新做一次，无论是否自动化，都感觉太二逼了，经过一番瞎捣，发现可以通过该注册表，把快捷键定义全部删除掉，避免 `igfxHK.exe`
占有这些全局快捷键。

注册表文件如下，保存为一个 `.reg` 文件最后双击运行并导入到注册表即可。

```ini
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Intel\Display\igfxcui\HotKeys]
"3101"=-
"3105"=-
"3121"=-
"9530"=-
"3106"=-
"3107"=-
"3108"=-
"3109"=-
"3110"=-
"4528"=-
"10"=-
"11"=-
```

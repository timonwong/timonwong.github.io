---
title: "使用Hexo在GitHub Pages搭建博客"
tags: Hexo
---

## 安装

### 安装Node.js

访问 [Node.js] 官方网站，下载最新安装包并安装。或使用包管理工具比如`yum`、`apt-get`等安装。

[Node.js]: http://nodejs.org/

<!--more-->

### 安装Hexo

``` bash
npm install hexo -g
```

## 设置Hexo

Hexo 安装完成后，直接运行:

``` bash
hexo init <yourusername>.github.com
cd <yourusername>.github.com
```

然后，将该文件夹纳入`git`版本库管理:

``` bash
# 初始化Git仓库
git init
# 源文件放到source分支内
git checkout -b source
```

## 自定义Hexo

### `MathJax` 支持

首先，安装`hexo-math`包：

``` bash
npm install hexo-math --save
```

然后，运行以下命令进行初始化：

``` bash
hexo math install
```

之后再，编辑 `_config.yml` 文件，启用 `hexo-math` 插件：

``` yaml
plugins:
- hexo-math
```

详细使用方法，请查阅[文档](https://github.com/akfish/hexo-math)或[作者的Blog](http://catx.me/2014/03/09/hexo-mathjax-plugin/)


## 设置GitHub

修改`_config.yml`文件, 找到 `Deployment` 一节，更改如下

``` yaml
# Deployment
## Docs: http://hexo.io/docs/deployment.html
deploy:
  type: github
  # rep 这里填写仓库地址, hexo文档建议使用https, 但是每次都要输入帐号密码, 因此我这里写成了ssh方式
  repo: git@github.com:timonwong/timonwong.github.com.git
  # master 分支用于发布，注意这个与之前 source 分支不同
  branch: master
```

## 配置域名

在`source`文件夹下新建一个`CNAME`文件


## 部署

运行以下命令，生成静态文件并发布到GitHub Pages上:

``` bash
hexo d -g
```

这里，`d` 是 `deploy` 的简写；`g` 是 `generate` 的简写，全写为：

``` bash
hexo deploy --generate
```


## RTFM

- [Pro Git](http://git-scm.com/book/zh)
- [Hexo's Docs](http://hexo.io/docs/)

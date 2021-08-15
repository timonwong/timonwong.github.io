---
title: 'RabbitMQ笔记（一）: 通过Vagrant建立一个RabbitMQ服务器实验环境'
date: 2014-05-13 14:46:31
tags: [RabbitMQ, Vagrant]
---

## 安装Vagrant

在[官方网站]上，下载并安装Vagrant

[官方网站]:http://vagrantup.com

**NOTE**: Vagrant 1.6版本对`CentOS`的guest支持不好，不能正确设置网络连接，需要升级到最新版或打上下面这个补丁: [Fix issue reported at mitchellh#3649](https://github.com/cammoraton/vagrant/commit/1e4584cde51765972af41cd48fc0409756a8fd59)

## 下载并导入CentOS 6.3 Box

``` bash
vagrant box add --name centos63 'https://s3.amazonaws.com/itmat-public/centos-6.3-chef-10.14.2.box'
```

## 创建Vagrantfile

`Vagrantfile` 文件内容如下:

``` ruby Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos63"

  # 一个Host-Only的Network, IP地址可以自定义, 方便访问
  config.vm.network :private_network, ip: "10.10.0.70", netmask: "255.255.255.0"

  # config.vm.synced_folder "../", "/vagrant"

  config.vm.provider :virtualbox do |vb|
    # 调节虚拟机CPU个数
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    # 调节虚拟机内存大小
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
  end

  # 自动安装脚本
  config.vm.provision :shell, path: "provision.sh"
end
```

为了简化安装，提供一个用于自动安装的脚本`provision.sh`，文件内容如下：

``` bash
#!/usr/bin/env bash

# Disable yum fastestmirror plugin
sed -i.backup 's/^enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
# Change yum mirror (163)
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base-163.repo http://mirrors.163.com/.help/CentOS6-Base-163.repo
yum makecache
yum update

# Install EPEL repository
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

# Install and start rabbitmq-server
yum -y install rabbitmq-server

## Automatically start
chkconfig rabbitmq-server on

## Create a sample config and enable guest user remote access
echo > /etc/rabbitmq/rabbitmq.config <<EOF
[
  {rabbit, [
    {loopback_users, []}
  ]}
].
EOF

## Enable magement plugin
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management

## Start rabbitmq-server
service rabbitmq-server start

# Disable iptables
service iptables stop
chkconfig iptables off

```

## 启动虚拟机

``` bash
vagrant up
```

## 使用SSH连接到虚拟机

使用命令(如果支持的话):

``` bash
vagrant ssh
```

或使用SSH工具，例如 [XShell], [PuTTY] 等工具，连接到 `10.10.0.70:22` (IP在之前 `Vagrantfile` 中定义)

[XShell]: http://www.netsarang.com/products/xsh_overview.html
[PuTTY]: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html

## 停止虚拟机

``` bash
vagrant halt
```

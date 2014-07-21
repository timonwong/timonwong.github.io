---
title: '使用阿里云镜像服务器'
date: 2014-05-20 11:40:29
categories: IT
tags:
---

最近本机访问 `163.com` 的 `CentOS` 镜像比较不稳定，体现在 ping 很低，但是 HTTP
连接很慢，`yum` 的 `fastestmirror` 也不太理想，所以一般都禁用之。

发现阿里云的镜像服务器，立马换了，便秘立刻就通了。

## yum 镜像

### 官方源镜像

``` bash
# 禁用 fastestmirror 插件
sed -i.backup 's/^enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf
# 备份
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# 使用阿里云镜像
wget -O /etc/yum.repos.d/CentOS-Base-aliyun.repo http://mirrors.aliyun.com/repo/Centos-6.repo
```

### EPEL 镜像

``` bash
# 安装 EPEL 源
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
# 使用阿里云镜像
if [[ ! -f /etc/yum.repos.d/epel.repo.backup ]]; then
    mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup 2>/dev/null || :
fi

if [[ ! -f /etc/yum.repos.d/epel-testing.repo.backup ]]; then
    mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup 2>/dev/null || :
fi

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
```


## PyPi 镜像

``` bash
mkdir -p ~/.pip
touch ~/.pip/pip.conf

sed -i.backup -r \
    's/^index-url\s*=\s*.+$/index-url = http:\/\/mirrors.aliyun.com\/pypi\/simple\//' \
    ~/.pip/pip.conf

# If file not changed, write contents back to pip.conf
diff "~/.pip/pip.conf" "~/.pip/pip.conf.backup" &> /dev/null

if [ $? -eq 0 ]; then
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
EOF
fi

```

## RubyGems 镜像

``` bash
gem source -r https://rubygems.org/
gem source -a http://mirrors.aliyun.com/rubygems/
```

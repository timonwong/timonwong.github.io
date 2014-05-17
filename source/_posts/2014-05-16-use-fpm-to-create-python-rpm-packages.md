title: 使用 FPM 创建 Python 的 RPM 包
date: 2014-05-16 09:03:33
categories: IT
tags: [FPM, RPM, Python]
---

生成 RPM 包太麻烦了，最近知道了一个名为 [FPM] 的神器，在此记录一下。

## 安装 FPM

**NOTE:** 测试系统为 RedHat 系的 CentOS 6.3，编译 Python 2.7.6 的 RPM 包。

### 安装 Ruby

由于 [FPM] 使用 `Ruby` 写成，因此系统中需要安装 `Ruby` 的运行环境（这里 `gem` 的源改为了 taobao 的镜像）：

``` bash
# Install ruby dependencies
yum -y install ruby rubygems ruby-devel
# Use taobao repo for ruby gems
gem sources -a http://ruby.taobao.org/
# Remove origin repo from ruby gems
gem sources --remove http://rubygems.org/
```

### 通过 Gem 安装 FPM

在 `Ruby` 安装完成后，就可以使用 `gem` 安装 [FPM] 了：

``` bash
# Install fpm
gem install fpm
```

Good.

## 设置编译环境

在编译 Python 之前，需要安装开发工具和库:

``` bash
# Install EPEL repository
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

# Install build toolchain
yum -y groupinstall "Development tools"
yum -y install openssl-devel readline-devel bzip2-devel sqlite-devel zlib-devel ncurses-devel db4-devel expat-devel
```

## 编译并创建 Python 的 RPM 包

[FPM] 的使用比较简单，可以参考 [FPM] 的 [使用说明](https://github.com/jordansissel/fpm/wiki)。

首先，下载 Python-2.7.6 的源码包并解压：

``` bash
curl --progress-bar -LO http://mirrors.sohu.com/python/2.7.6/Python-2.7.6.tgz
tar xf Python-2.7.6.tgz
```

第二步，编译 Python-2.7.6

``` bash
cd Python-2.7.6.tgz

# Python2.7编译安装后会安装到这个目录，方便打包
export INTERMEDIATE_INSTALL_DIR=/tmp/installdir-Python-2.7.6
# RPM包安装后Python2.7的目录
export INSTALL_DIR=/usr/local

LDFLAGS="-Wl,-rpath=${INSTALL_DIR}/lib ${LDFLAGS}" \
            ./configure --prefix=${INSTALL_DIR} --enable-unicode=ucs4 \
                --enable-shared --enable-ipv6
make
make install DESTDIR=${INTERMEDIATE_INSTALL_DIR}
```

第三步，使用 [FPM] 创建 RPM 包：

``` bash
# 注意之前导出 INTERMEDIATE_INSTALL_DIR 和 INSTALL_DIR 这两个环境变量，这里还要使用
fpm -s dir -t -f rpm -n python27 -v '2.7.6' \
    -d 'openssl' \
    -d 'bzip2' \
    -d 'zlib' \
    -d 'expat' \
    -d 'db4' \
    -d 'sqlite' \
    -d 'ncurses' \
    -d 'readline' \
    --directories=${INSTALL_DIR}/lib/python2.7/ \
    --directories=${INSTALL_DIR}/include/python2.7/ \
    -C ${INTERMEDIATE_INSTALL_DIR} .
```


## Bonus Time

TO BE DONE

将会包含以下内容：

- 自动下载、编译、打包 Python RPM 包的 Makefile；
- 自动下载、编译、打包 virtualenv、pip、supervisor 等依赖于 Python 工具的 RPM 包。

[FPM]: https://github.com/jordansissel/fpm

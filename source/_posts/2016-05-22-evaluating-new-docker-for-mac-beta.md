---
title: 试用最新的 Docker for Mac Beta
date: 2016-05-22 21:47:02
categories: IT
tags: [Docker, OSX]
---

## 如何申请 Docker for Mac Beta

请访问这个地址申请，可能需要等几天：https://beta.docker.com/

Docker for Mac Beta，最大的好处就是不再依赖 VirtualBox VM 了，而是使用了更轻量化的 [xhyve] 作为其虚拟化方案（也即是说，仍然不是原生的，还是需要虚拟化一个 Linux 出来在上面运行 Docker Daemon）。

另外，这个版本的 Docker for Mac 使用了 [Alpine Linux] 发行版，作为一个更轻量化的发行版，与一般的发行版有不少区别，比如，使用 `ash` 替换 `bash` 等，具体请访问 [Alpine Linux] 网站获取更多信息。

## 使用 Docker Hub Registry Mirror

由于众所周知的原因，在国内访问 Docker Hub 的速度相当缓慢，因此需要设置一个 Docker Registry Mirror 来加速，这里使用 [USTC 的 Docker Hub Mirror](https://servers.ustclug.org/2015/05/new-docker-hub-registry-mirror/)。

就如同之前所说，[Alpine Linux] 发行版与一般发行版有巨大区别，因此调整 Docker Daemon 的启动参数也不大一样😂

### Quick Way

**NOTE:** 安装了 `jq` 命令行工具（可以通过 `brew install jq` 安装），可以直接执行一行命令行搞定，否则请参阅「Slow Way」一节：

```bash
pinata get daemon | jq -cm '."registry-mirrors" = ["https://docker.mirrors.ustc.edu.cn"]' | pinata set daemon -
```

### Slow Way

#### 1. 导出当前的设置

运行以下命令，将当前设置保存到 `docker-config.json` 文件中：

```bash
pinata get daemon > docker-config.json
## >> {"storage-driver":"aufs","debug":true}
```

#### 2. 使用文本编辑器编辑设置

使用任何一种文本编辑器，打开 `docker-config.json` 并按照 `JSON` 格式编辑为以下内容，然后保存并退出：

```json
{"storage-driver":"aufs","debug":true,"registry-mirrors":["https://docker.mirrors.ustc.edu.cn"]}
```

#### 3. 加载最新设置

最后，加载 `docker-config.json` 中的设置就可以了：

```json
pinata set daemon @docker-config.json
```

## 获取 Docker Guest 的 IP 地址

有时候，我们需要得到 Docker Guest 的 IP 地址，其实不大有比较快捷的方法，比如，先运行 `pinata get network`，居然返回这个？？WTF？！

```bash
hostnet
```

然后只有运行 `pinata list` 了：

    These are advanced configuration settings to customise Docker.app on MacOSX.
    You can set them via pinata set <key> <value> <options>.

    🐳  hostname = docker
       Hostname of the virtual machine endpoint, where container ports will be
       exposed if using nat networking. Access it via 'docker.local'.

    🐳  hypervisor = native (memory=2, ncpu=2)
       The Docker.app includes embedded hypervisors that run the virtual machines
       that power the containers. This setting allows you to control which the
       default one used for Linux is.

     ▸  native: a version of the xhyve hypervisor that uses the MacOSX
                  Hypervisor.framework to run container VMs. Parameters:
                  memory (VM memory in gigabytes), ncpu (vCPUs)


    🐳  network = hostnet (docker-ipv4=192.168.65.2, host-ipv4=192.168.65.1)
       Controls how local containers can access the external network via the
       MacOS X host. This includes outbound traffic as well as publishing ports
       for external access to the local containers.

     ▸ hostnet: a mode that helps if you are using a VPN that restricts
                  connectivity. Activating this mode will proxy container network
                  packets via the Docker.app process as host socket traffic.
                  Parameters: docker-ipv4 (docker node), host-ipv4 (host node)
     ▸     nat: a mode that uses the MacOS X vmnet.framework to route container
                  traffic to the host network via a NAT.

    🐳  filesystem = osxfs
       Controls the mode by which files from the MacOS X host and the container
       filesystem are shared with each other.

     ▸   osxfs: a FUSE-based filesystem that bidirectionally forwards OSX
                  filesystem events into the container.


    🐳  native/port-forwarding = true
       Expose container ports on the Mac, rather than the VM

     ▸    true: Container ports will be exposed on the Mac
     ▸   false: Container ports will be exposed on the VM

    🐳  daemon = run 'pinata get daemon' or 'pinata set daemon [@file|-]>
       JSON configuration of the local Docker daemon. Configure any custom
       options you need as documented in:
       https://docs.docker.com/engine/reference/commandline/daemon/. Set it
       directly, or a @file or - for stdin.

因此看起来使用 `pinata list | grep 'network ='` 才是合理的方式之一：

    *  network = hostnet (docker-ipv4=192.168.65.2, host-ipv4=192.168.65.1)

以上

[xhyve]: https://github.com/mist64/xhyve
[Alpine Linux]: http://alpinelinux.org/

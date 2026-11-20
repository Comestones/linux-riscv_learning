# Linux RDMA 用户态编程与通信

这个选修项目适合高速网络软件岗位。从用户程序发起的一次设备查询或收发出发，弄清 `libibverbs`、连接管理库 `librdmacm`、provider 与内核驱动的分工。当前保留上游源码，构建和通信结果待实测。

## 从源码到本地构建

源码子模块为 `linux-rdma/rdma-core/`，固定在 `04da5a0496764ce7f4c11d8f5b28d2d613f8902b`。Windows 可阅读代码，构建和设备测试在 Ubuntu 执行。以下命令从主仓库根目录开始，依赖取自该提交的上游 README。[上游构建说明](https://github.com/linux-rdma/rdma-core/blob/04da5a0496764ce7f4c11d8f5b28d2d613f8902b/README.md)

```bash
git submodule update --init -- linux-rdma/rdma-core
cd linux-rdma/rdma-core
sudo apt install build-essential cmake gcc libudev-dev libnl-3-dev libnl-route-3-dev \
  ninja-build pkg-config valgrind python3-dev cython3 python3-docutils pandoc
bash build.sh
./build/bin/ibv_devices
```

先核对 `build/bin/` 中的程序和 `build/lib/` 中的库，再记录 `ibv_devices` 的实际输出。设备列表为空也是一次可解释的查询结果。运行时同时记录内核版本、设备类型及 provider。

## 选一条通信路径跟踪

| 阶段 | 源码入口与实验 | 验收 |
| --- | --- | --- |
| 设备枚举 | 阅读 `libibverbs/examples/device_list.c`，跟踪一次用户态枚举，查清 provider 和 `/dev/infiniband/uverbs*` 的关系。 | 将程序输出中的设备和系统枚举结果对应起来。 |
| verbs 收发 | 在 `libibverbs/examples/rc_pingpong.c` 中认出内存注册、队列对、提交收发和完成队列轮询。 | 能按执行顺序解释哪些资源需先建立、哪一步确认传输完成。[RC ping-pong 源码](https://github.com/linux-rdma/rdma-core/blob/04da5a0496764ce7f4c11d8f5b28d2d613f8902b/libibverbs/examples/rc_pingpong.c) |
| 通信与故障 | 有两端可用设备和网络时运行配套示例，保存两端的命令、输出和一次配置错误的复测。软件路径可按上游说明单独使用 Soft-RoCE。 | 标明硬件网卡或软件 RDMA、端口与数据规模，分别报告构建、设备发现和端到端收发的结果。 |

若目标是了解连接建立，再读 `librdmacm/examples/rping.c`，沿事件通道串起地址解析、连接、收发和断开。[rping 源码](https://github.com/linux-rdma/rdma-core/blob/04da5a0496764ce7f4c11d8f5b28d2d613f8902b/librdmacm/examples/rping.c)

# RISC-V 系统与处理器验证

用“程序怎样进入内核、处理器怎样访问外设”串起两条实验。做系统软件或 Linux BSP 时，从 xv6 开始。做处理器验证时，从 Ibex Simple System 开始。两条实验各用各的工具链，可以按目标岗位选一条。

| 想回答的问题 | 学习步骤 | 验收与入口 |
| --- | --- | --- |
| 用户程序为什么会进入内核？ | 在 QEMU 启动 xv6，用 GDB 跟踪系统调用，再观察页表和异常。 | 从一条用户指令追到内核分发和返回，解释一次地址转换。见 [xv6 实验](xv6.md)。 |
| 裸机 C 怎样影响一个硬件定时器？ | 在 Ibex Simple System 跑程序，对照反汇编、指令跟踪和外设波形。需要时增加 co-simulation 或形式验证。 | 将一条 load/store 对应到寄存器地址和发生变化的信号。见 [Ibex 学习计划](ibex.md)。 |
| 怎样准备 Linux 板级软件？ | 主投 BSP 时，用 Buildroot 和 QEMU 构建 Linux 镜像，把一个 C 自测程序放入根文件系统。 | 保存交叉编译配置、串口启动日志和自测退出码。有目标板后再验证设备树与外设适配。见 [xv6 实验末尾的 BSP 分支](xv6.md#转向嵌入式-linuxbsp)。 |

**进度。** Ubuntu 上已于 2026-11-18 启动 xv6 并运行用户程序。GDB、MIT 实验、Ibex 和 Buildroot 均待做。xv6 源码位于 `xv6-riscv/` 子模块，Ibex 目前只有学习规划。[Ubuntu 学习机环境](ubuntu-setup.md)

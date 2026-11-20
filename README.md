# 嵌入式、FPGA 与 RISC-V 项目学习路线

每周合计投入约 5～7 小时。先用 Cardputer-Adv 做一台能查 FPGA 状态的串口终端，练好驱动、RTL 和自检，再读 ExaNIC X10 的 10G 以太网工程。RISC-V 系统与 Linux RDMA 按目标岗位选学。

同一个串口外设可以用于三种岗位准备。嵌入式方向交付 C 驱动和故障日志，FPGA 方向交付 RTL、时序报告与板上波形，数字 IC 验证方向交付能抓住边界错误的回归和覆盖记录。

| 顺序 | 做什么 | 具体从哪里开始 |
| --- | --- | --- |
| 1 · 串口与 FIFO | 让终端持续收数时仍能查询 FPGA 的版本、状态和计数，定位一次掉数发生在哪一层。 | 先看[共用接口和项目规划](uart-fifo-terminal/README.md)。写固件看 [FreeRTOS 六周实验](uart-fifo-terminal/learn-freertos.md)，实现外设看 [FPGA 设计与上板](uart-fifo-terminal/fpga-uart-fifo.md)，测边界和覆盖率看 [FIFO 验证](uart-fifo-terminal/fifo-verification.md)。 |
| 2 · 10G 以太网 | 在 X10 上跟踪一次 UDP 请求，解释为什么发回数据前会先发 ARP 请求。 | 按 [X10 项目规划](ethernet-x10/README.md)重建 [Vivado 工程](ethernet-x10/vivado.md)，再用 [UDP 回包与 cocotb 实验](ethernet-x10/udp-verification.md)验证数据通路。 |
| 选修 · RISC-V 系统 | 做内核或 BSP 时跟踪一次系统调用。做处理器验证时对照指令跟踪和定时器访问。 | 从 [RISC-V 项目规划](riscv-systems/README.md)选 [xv6 与 GDB](riscv-systems/xv6.md) 或 [Ibex 裸机与验证](riscv-systems/ibex.md)。 |
| 选修 · Linux RDMA | 读用户态 verbs 和连接管理代码，再用可用的 RDMA 设备验证一次通信。 | 按 [RDMA 源码、构建与通信实验](linux-rdma/README.md)推进。 |

**当前进度（2026-11-20 整理）。** Windows 已用 Vivado MCP 展开 X10 RTL。Ubuntu 已启动 xv6 并运行用户程序，XSim 最小用例也已通过。串口终端、独立计数器与 FIFO 实验待做，X10 原始 cocotb 用例也待取得运行结果。下一步先让 ADV 完成 UART 回环，再记录单任务接收 6000 行时的丢行数和按键延迟。

## 获取工程

```bash
git clone --recurse-submodules https://github.com/Comestones/linux-riscv_learning.git
cd linux-riscv_learning
git submodule status --recursive
```

已有工作副本更新主仓库后，运行 `git submodule sync --recursive` 和 `git submodule update --init --recursive`。三份上游源码各自固定提交，许可证见 [verilog-ethernet](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/COPYING)、[xv6](https://github.com/mit-pdos/xv6-riscv/blob/fa2ddcb7ca87a77af579380a6eafd5aff163b44f/LICENSE) 和 [rdma-core](https://github.com/linux-rdma/rdma-core/blob/04da5a0496764ce7f4c11d8f5b28d2d613f8902b/COPYING.md)。

Windows 与 Ubuntu 各用自己的工作副本，通过 Git 同步。同一次实验记录提交、工具版本、运行命令和结果。Vivado 构建目录、报告、波形和 Python 环境在本机生成。学习机已有的工具版本与跨机复现方式见 [Ubuntu 环境记录](riscv-systems/ubuntu-setup.md)。

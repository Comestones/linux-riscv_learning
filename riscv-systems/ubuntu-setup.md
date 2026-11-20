# Ubuntu 学习机环境与跨机复现

2026-11-18 记录的机器为 Ubuntu 24.04.4 LTS、x86_64、内核 `7.0.0-43-generic`。内存约 15 GiB，项目分区当时可用约 425 GiB。以下是个人机器的实测起点，安装另一台机器时先核对所用工具版本。

| 项目 | 已有记录 | 需要时再准备 |
| --- | --- | --- |
| xv6 | GCC 13.3.0、QEMU 8.2.2 和 GDB Multiarch 15.1 已能启动 xv6。 | [系统调用与 GDB](xv6.md)。 |
| Vivado | 2026-11-19 确认 Vivado ML Standard 2025.1 能找到 X10 器件，XSim 最小用例通过。 | [工程重建、locale 和器件清单记录](../ethernet-x10/vivado.md)。 |
| FIFO、X10 原始仿真 | 上次检查时终端未找到 Icarus、Verilator 或 GTKWave。 | 按实验安装 `iverilog`、`verilator`、`gtkwave`。X10 另用独立 Python 3.10 环境。[固定依赖与命令](../ethernet-x10/udp-verification.md) |
| Ibex、RDMA | 两项均按选修准备。 | Ibex 所需 RV32 工具见 [Simple System 计划](ibex.md)。RDMA 所需 CMake、Ninja 与开发库见 [Linux 构建步骤](../linux-rdma/README.md)。 |

## 多机如何复现同一次实验

Windows 和 Ubuntu 各自检出仓库，使用相同主仓库和子模块提交。每台机器保留独立的构建目录和虚拟环境。Linux 用 Git 检出目录符号链接和脚本权限。启动测试前记录提交、工具版本、工作区改动、命令与结果位置。两机可各自操作，需远程调用时再用 Remote-SSH，并确认 Python、扩展和 MCP 所在机器。[VS Code Remote-SSH](https://code.visualstudio.com/docs/remote/ssh)

## 将来重装时的参考

旧方案为 Windows 笔记本选 Ubuntu Desktop 24.04 LTS amd64，优先单独 SSD，空间紧张时先部署 xv6 与仿真。16 GB 内存可限制并行度，完整 Vivado 工作负载可考虑 32 GB。Vivado 可用性以所选版本与系统组合的官方支持表为准，以上 XSim 运行结果针对这台机器。[AMD 2025.1 系统支持表](https://docs.amd.com/r/2025.1-English/ug973-vivado-release-notes-install-license/Supported-Operating-Systems)

更换系统前备份项目和恢复密钥，核对 UEFI 与分区，先在 Try Ubuntu 检查设备，再决定单盘或双盘安装。遇到 RST 导致无法识别磁盘时先按官方步骤准备 Windows。双系统安装后分别启动两套系统验证。[Ubuntu 安装指南](https://ubuntu.com/desktop/docs/en/24.04/tutorial/install-ubuntu-desktop/) · [RST/AHCI 说明](https://ubuntu.com/desktop/docs/en/24.04/how-to/reconfigure-windows-to-use-ahci/)

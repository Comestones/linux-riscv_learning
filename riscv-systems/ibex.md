# Ibex Simple System 的裸机执行与验证

选修目标是把一段 C 代码、编译后的指令和一次可观察的硬件访问对起来。当前仅有规划。开始时选定上游提交，在该版本的 Simple System README 中核对 FuseSoC、Verilator 和 RV32 裸机工具链要求，记录版本和构建命令。[Ibex 示例工程](https://github.com/lowRISC/ibex/tree/master/examples/simple_system) · [系统要求](https://ibex-core.readthedocs.io/en/latest/02_user/system_requirements.html)

| 阶段 | 怎么做 | 做到什么程度 |
| --- | --- | --- |
| 裸机程序 | 按上游示例构建一个已知程序，先重现其输出，再改一行会访问外设的 C 代码，保存两次构建的 ELF 和反汇编片段。 | 能在反汇编中指出执行该访问的指令和目标地址。 |
| 指令与外设 | 在指令跟踪中找到对应 PC，查看访问有效、读写方向、地址和数据，沿 Simple System 的连接找到定时器或输出设备。 | 同一笔访问能在 C、指令跟踪及波形中对应起来。 |
| 处理器验证进阶 | 先用项目支持的 co-simulation 与参考指令集模型逐条比较，再选一项 RVFI 性质读形式验证检查。 | 对差异找出首个不一致的指令。对形式检查记下假设、性质和反例适用范围。[Ibex 示例说明](https://ibex-core.readthedocs.io/en/latest/02_user/examples.html) · [riscv-formal](https://github.com/YosysHQ/riscv-formal) |

与 xv6 对照时可选中断或内存映射这一主题。这里的 Ibex 是 RV32，仓库中的 xv6 使用 RV64、Sv39 和特定的中断与设备布局。若后续做 xv6 上 FPGA，需另选具备相应特权架构、MMU 和外设的平台，并适配内存映射与驱动。[xv6 平台布局](https://github.com/mit-pdos/xv6-riscv/blob/fa2ddcb7ca87a77af579380a6eafd5aff163b44f/kernel/memlayout.h)

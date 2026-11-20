# ExaNIC X10 的 10G 以太网 UDP 回显

这是串口与 FIFO 之后的第二个项目。用一笔发往 UDP 端口 1234 的事务读懂已有 FPGA 工程，再把观察到的握手、ARP 解析和实际回包对应起来。适合 FPGA 网络接口、技术应用和模块集成验证。

| 顺序 | 做什么 | 验收 |
| --- | --- | --- |
| 1 | 在 Windows 打开或重建 Vivado 工程，从顶层 `fpga` 找到业务核心 `fpga_core`、收发器、时钟和复位。 | 可指认源文件、器件、IP 和实际时钟连接。见 [Vivado 重建与实测记录](vivado.md)。 |
| 2 | 读一遍预期的 UDP → ARP → UDP 事务，在 Ubuntu 的同一上游提交上运行原始 pytest。 | 保存退出状态、实际断言和日志，再写下本次仿真覆盖的接口。见 [数据通路与 cocotb 验证](udp-verification.md)。 |
| 3 | 增加一个被过滤的端口用例，或用已知报文检查 MAC 帧计数。准备上板时再跑综合、布局布线和板级流量。 | 自动判断新增用例，解释第一次偏离的信号。板测另存时序报告、ILA 与实收发记录。 |

**进度。** 2026-11-11，Windows 上通过 Vivado MCP 创建并展开 RTL。11-19，Ubuntu 上的 XSim 最小仿真通过。11-20，用 Vivado 重新打开迁移后的工程，已逐一核对设计输入。X10 原始 `run_test`、实现时序及 SFP 板级收发仍待实测。

上游源码在本目录的 `verilog-ethernet/`，固定于 `77320a9471d19c7dd383914bc049e02d9f4f1ffb`。工作目录中的 [create_project.tcl](create_project.tcl) 和 [inspect_design.tcl](inspect_design.tcl) 用于创建工程和导出报告。上游已将后续开发转至 Taxi，本项目复现沿用上述提交。[固定版本的 X10 示例](https://github.com/alexforencich/verilog-ethernet/tree/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga)

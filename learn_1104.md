# 学习计划：Ross / Vivado MCP、xv6-riscv 与硬件验证

  

整理日期：2026-11-04

  

## 1. 学习目标与路线

  

原来的 Vivado MCP 入门计划与新增的 xv6-riscv 学习目标不冲突。保留原计划作为工具入门，将 xv6 和验证项目作为后续实践。

  

总体目标：通过 xv6 理解软件对硬件的需求，通过 RTL 验证理解硬件如何实现这些行为，用 Ross / Vivado 辅助执行和分析。

  

| 学习对象 | 主要内容 | 主要工具 |

| --- | --- | --- |

| xv6-riscv | 系统调用、页表、异常、中断、进程调度 | RISC-V 编译器、QEMU、GDB |

| RTL 与验证项目 | 时序逻辑、接口协议、测试用例、错误定位 | XSim、Verilator、cocotb 等 |

| Ross + Vivado MCP | 查询工程、运行仿真和综合、分析日志及报告 | Vivado、MCP、AMD 官方 Skills |

  

MIT 的 xv6 入门流程使用 QEMU；Ross 官方 Vivado Skills 覆盖 RTL 仿真、lint、时序方法学检查等。学习 xv6 时，以 MIT 源码和教材为依据；学习 Vivado 时，使用 AMD 文档和 Ross Skills。

  

“中断与外设”适合连接两条路线：先在 xv6 中看中断如何进入内核，再在小型 RTL 系统里观察定时器如何产生中断。

  

## 2. 先理解三个概念

  

- **Ross AI Assistant**：AMD 提供的 AI 辅助开发体系，包含工具连接、知识库、Skills 和示例。

- **Vivado MCP**：让 AI 调用 Vivado 的接口，基本链路为：AI 客户端 → MCP Server → Tcl → Vivado。

- **Skills**：指导 AI 完成仿真、时序分析等任务的操作流程，通常以 `SKILL.md` 文件描述。

  

### 当前起点

  

- 本次讨论中已打开 Vivado 2025.1。

- 此前打开 Vivado 使用的是桌面操作；本聊天当时暴露的工具列表中没有 Vivado MCP 工具，因此尚未验证 MCP 连接成功。

- 第一项验收应是：AI 实际调用 Vivado MCP，并获得 Vivado 返回的版本或工程信息。

- 官方文档以 Vivado 2026.1 为测试基线，并说明 MCP 基于标准 Tcl 接口、架构上兼容已发布版本。当前 2025.1 可先进行连接练习；具体 Skill 和示例仍需检查最低版本要求。

  

## 3. 六周入门计划

  

假设已有一些 C 和 Verilog 基础，每周投入约 5～7 小时。以下为建议节奏，不要求六周完成全部 MIT 实验；如果 C 指针、汇编或基本时序逻辑不熟悉，可先增加基础练习。

  

| 阶段 | 学习与实践 | Ross / AI 如何参与 | 完成标准 |

| --- | --- | --- | --- |

| 第 1 周：跑通两套环境 | 保留原计划的 MCP 连接、查询工程、计数器仿真；另外在 Linux / WSL2 中启动 xv6 | 调用 MCP 查询 Vivado 版本；辅助解释 xv6 编译和启动日志 | 得到真实 MCP 返回结果，并进入 xv6 shell |

| 第 2 周：系统调用 | 跟踪一次用户程序调用进入内核的过程；完成 MIT syscall 实验中的 trace | 根据源码解释调用链，提供调试提示 | 能用 GDB 跟踪一次系统调用，相关实验测试通过 |

| 第 3 周：页表与异常 | 阅读 vm.c、trap.c 和相关汇编；练习打印页表、观察异常寄存器 | 帮助对应源码、寄存器和运行现象 | 能解释虚拟地址转换，以及程序为何进入异常处理 |

| 第 4 周：模块级验证 | 实现小型同步 FIFO，测试复位、满/空、同时读写和数据顺序 | 用 Ross 驱动 XSim；辅助生成测试框架、定位失败波形 | 测试能发现人为加入的错误，修复后回归通过 |

| 第 5 周：RISC-V 硬件执行 | 跑通 Ibex Simple System 的裸机程序，观察指令跟踪和定时器行为 | AI 辅助分析构建脚本、反汇编和 RTL；使用项目原生仿真流程 | 能解释一段 C 程序如何变成指令并影响外设 |

| 第 6 周：小型综合练习 | 选择定时器或寄存器外设，写功能说明、RTL、测试；用 Vivado 综合并阅读报告 | Ross 辅助仿真、综合和报告分析 | 留下一套可重复运行的测试，以及修改前后的结果对比 |

  

### 第 1 周保留的原计划内容

  

1. 检查 Vivado 路径、扩展和 MCP 配置，列出实际可用工具。

2. 通过 MCP 查询版本、当前工程、顶层模块、目标器件和源文件。

3. 使用简单计数器和 testbench，运行行为仿真与综合。

4. 阅读 `vivado-simulate-rtl` 的 `SKILL.md`，理解检查环境、执行、读取日志、定位问题的过程。

5. 对一处小修改重新运行流程，比较代码、日志和报告。

  

### xv6 资料使用原则

  

固定使用同一学年的教材、实验说明和实验仓库，避免与最新主线混用。可以用 xv6-riscv 主仓库阅读源码；做 MIT 实验时，使用实验说明指定的仓库和分支。

  

本轮优先学习系统调用、页表和异常。进程调度、锁与文件系统可在完成上述练习后继续深入。

  

## 4. 推荐的验证项目

  

按以下顺序选择，先完成一个再增加。

  

### 4.1 Ross 官方 multi-violation 示例

  

**用途：** 延续当前 Ross / Vivado MCP 学习。

  

官方分别提供 RTL lint 和时序方法学检查示例。建议练习记录：问题 → 原因 → 修改 → 重新检查。

  

**验收：** 能指出原始报告中的问题、对应修改，以及重新检查后的变化。使用前检查示例对 Vivado 版本的要求。

  

入口：[Ross 官方 Vivado Skills 与示例](https://github.com/Xilinx/ross-ai-assistant#vivado)

  

### 4.2 cocotb 官方入门示例，再扩展到 FIFO

  

**用途：** 学习用 Python 编写输入激励和参考模型，并自动比较实际输出。

  

先运行官方入门示例，再将方法用到自己的小型 FIFO。建议搭配 Icarus Verilog 或 Verilator，按其原生流程运行。Vivado / XSim 的练习可以继续使用 SystemVerilog testbench。

  

**验收：** 有正常场景与边界场景；测试能发现一个故意引入的功能错误，修复后重新通过。

  

资料：[cocotb 入门](https://docs.cocotb.org/en/stable/first_steps.html)、[仿真器支持](https://docs.cocotb.org/en/stable/simulator_support.html)

  

### 4.3 Ibex Simple System

  

**用途：** 连接软件学习与硬件验证。

  

该示例提供 CPU、存储器、定时器和裸机软件框架，适合观察指令与外设行为。先运行裸机程序、阅读指令跟踪和波形，再尝试 co-simulation，通过参考指令集模拟器逐条检查执行结果。其简化 co-simulation 流程支持 Verilator。

  

**验收：** 能对应 C 代码、反汇编、指令跟踪和一个外设访问；进阶时完成一次参考模型对比。

  

资料：[Ibex 官方示例说明](https://ibex-core.readthedocs.io/en/latest/02_user/examples.html)、[Simple System README](https://github.com/lowRISC/ibex/blob/master/examples/simple_system/README.md)

  

### 4.4 riscv-formal：进阶选修

  

**用途：** 学习 RVFI 接口、指令性质和形式验证反例。

  

在能够读懂指令执行和普通仿真失败后再开始，先完成少量检查，再逐步扩大范围。记录检查的性质、假设和适用范围。

  

**验收：** 能解释一个检查验证了什么，以及失败反例展示了什么。

  

项目：[riscv-formal](https://github.com/YosysHQ/riscv-formal)

  

## 5. xv6 与 FPGA 的衔接边界

  

“把 xv6 放到 FPGA 上运行”应作为后续独立项目。

  

当前 xv6 使用 RV64、Sv39 页表，并依赖目标平台的中断和设备布局；Ibex 是 RV32 内核，不能直接承载原版 xv6。真正移植需要选择合适的处理器，检查所选 xv6 版本需要的特权架构、MMU、定时器等支持，并适配内存布局和设备驱动。

  

本轮先做到：

  

- 在 QEMU 中理解 xv6 的软件行为。

- 在 RTL 仿真中理解裸机程序、指令与外设行为。

- 对照学习异常、中断和内存映射等共同概念。

  

参考：[xv6 页表相关代码](https://github.com/mit-pdos/xv6-riscv/blob/riscv/kernel/riscv.h)、[xv6 平台布局](https://github.com/mit-pdos/xv6-riscv/blob/riscv/kernel/memlayout.h)、[Ibex 项目](https://github.com/lowRISC/ibex)

  

## 6. 建议的 AI 使用方式

  

学习时先预测结果，再借助 AI 定位源码和解释现象；每次修改后用实际执行结果验证。

  

通用提示词：

  

> 先让我预测结果，再提供源码定位和调试提示。修改后运行测试，展示日志、波形或报告中的证据，并说明这些测试还没有覆盖哪些情况。

  

检查 MCP 连接：

  

> 列出当前实际可调用的 Vivado MCP 工具。通过 MCP 查询 Vivado 版本和当前工程，并展示返回结果。

  

了解 RTL 工程：

  

> 查询当前工程的顶层模块、目标器件、源文件和约束文件，解释工程结构。这一步只查询。

  

学习 xv6：

  

> 根据当前仓库源码，带我跟踪一次系统调用。先指出关键文件和函数，让我预测下一步，再使用 GDB 验证。引用实际代码位置。

  

验证 FIFO：

  

> 根据 FIFO 功能说明列出测试场景，覆盖复位、满、空、同时读写和数据顺序。运行测试，并用失败用例和波形解释发现的问题。

  

## 7. 官方资料索引

  

### AMD Ross / Vivado

  

- [AMD Ross 官方介绍](https://www.amd.com/en/products/software/ross-agentic-ai.html)

- [AMD Ross 下载页面](https://www.amd.com/en/support/downloads/ross-agentic-ai.html)

- [Ross 官方仓库](https://github.com/Xilinx/ross-ai-assistant)

- [Ross Getting Started 与版本说明](https://github.com/Xilinx/ross-ai-assistant/blob/main/docs/getting-started/README.md)

- [Vivado MCP 官方入门指南](https://github.com/Xilinx/ross-ai-assistant/blob/main/docs/getting-started/vivado-mcp.md)

  

### MIT xv6

  

- [MIT xv6 项目介绍](https://pdos.csail.mit.edu/6.828/2025/xv6.html)

- [xv6-riscv 源码](https://github.com/mit-pdos/xv6-riscv)

- [xv6 教材仓库](https://github.com/mit-pdos/xv6-riscv-book)

- [MIT 2025 工具安装说明](https://pdos.csail.mit.edu/6.828/2025/tools.html)

- [MIT 2025 系统调用实验](https://pdos.csail.mit.edu/6.1810/2025/labs/syscall.html)

- [MIT 实验与调试建议](https://pdos.csail.mit.edu/6.1810/2025/labs/guidance.html)

  

## 8. 学习进度记录

  

- [ ] 通过 MCP 得到 Vivado 的真实返回结果。

- [ ] 完成计数器仿真和综合。

- [ ] 启动 xv6，进入 shell。

- [ ] 用 GDB 跟踪一次系统调用，完成 trace 练习。

- [ ] 理解一次页表转换和异常处理过程。

- [ ] 完成 FIFO 正常与边界场景测试。

- [ ] 用测试发现人为引入的错误，并完成修复回归。

- [ ] 跑通 Ibex Simple System 裸机程序。

- [ ] 完成一个小型外设的设计、验证和综合报告。

- [ ] 选修：尝试 Ibex co-simulation 或 riscv-formal。

  

## 9. 可复用的 RTL 工程学习流程（Vivado MCP + 源码 + 验证）

  

这套流程来自 `ROSS/vivado-mcp-demo/verilog-ethernet` 中 ExaNIC X10 示例的学习过程，适用于本项目的其他模块，也适用于新的 FPGA/RTL 工程。每轮围绕**一个具体功能或一次事务**学习，始终区分三种结论：源码推断、工具确认、实际验证。Vivado MCP 负责查询当前工程和设计；功能仿真、时序分析及上板测试分别提供更进一步的证据。

  

### 9.1 确定对象与学习范围

  

阅读仓库 README、示例目录、构建脚本，确认仓库版本、目标板卡、当前示例、顶层模块和要研究的功能。先写出一个具体问题，例如“收到一个 UDP 包后如何回包”，避免把仓库整体能力误当作当前示例已经实现的功能。

  

**产出：**项目/提交版本、顶层、目标功能、输入输出场景及本轮不研究的部分。

  

> 提问模板：阅读 `<仓库/示例>` 的 README、目录和构建入口，说明目标板卡、顶层及当前示例实际实现的功能。给出源码依据，并限定本轮要追踪的事务。

  

### 9.2 用 MCP 确认工程状态

  

列出 Vivado MCP 可用工具及会话，复用目标工程已打开的会话。查询当前工程、顶层模块、器件、工作目录、已打开设计及源文件/IP 状态。记录实际调用的工具名和返回值。执行长时间命令时，若调用超时，先查 `vivado_status`，确认是否仍在执行，再决定下一步。

  

**产出：**可复查的工程状态快照。MCP 调用成功只说明工具链可通信，不能证明 RTL 功能正确。

  

> 提问模板：使用 Vivado MCP 列出会话，选择已打开 `<工程>` 的会话；查询工程、顶层、器件、工作目录和已打开设计，展示实际工具名与返回结果。暂不修改 RTL。

  

### 9.3 建立顶层结构地图

  

如果已经有展开后的 RTL 设计则直接复用；否则展开一次并检查状态。从顶层端口、Hierarchy 和 Schematic 入手，先辨认板级引脚、时钟复位、PHY/收发器及业务核心。再查询业务核心的**直接子模块**，记录实例名、模块类型、主要接口和作用。第一轮不展开底层寄存器。

  

| 记录项 | 要回答的问题 |

| --- | --- |

| 顶层端口 | 哪些连接板卡、时钟、复位和数据通道？ |

| 业务实例 | 数据由哪个模块接收、处理和发送？ |

| 连接 | 实例之间实际连接了哪些信号？ |

| 源码 | 对应模块和实例位于哪个文件、哪一行？ |

  

**产出：**一张只覆盖主要业务模块的结构图和实例表。

  

> 提问模板：复用或展开当前 RTL，检查 `<顶层/实例>` 的直接子模块。列出实例名、模块类型、主要接口和作用；结合源码位置解释，先不展开所有底层寄存器。

  

### 9.4 沿具体事务追踪数据与控制

  

选择可预测输入和输出的事务，依次追踪入口、协议解析、筛选条件、输出头部生成、payload 缓冲和发送。每一步同时检查数据、`valid/ready` 握手、状态机和等待条件。出现等待时，分别排查地址解析、缓存、握手、FIFO 和状态机，不凭模块名猜测原因。

  

本次示例使用主机 `192.168.1.100:5678` 向 FPGA `192.168.1.128:1234` 发送 UDP 包。接收包的源 IP 决定回包目的 IP；发送 Ethernet 帧仍需要目的 MAC，因此可能先出现 ARP 请求。追踪时应分别写明“目的 IP 从哪里来”和“目的 MAC 如何获得”。

  

**产出：**带实际实例路径、信号名、握手条件和源码位置的数据流/控制流记录。

  

> 提问模板：以 `<输入事务>` 为例，结合源码和 MCP 连接查询，追踪入口、筛选、头部生成、缓冲及出口。给出真实信号名和源码位置；解释每个等待条件何时解除。

  

### 9.5 单独整理时钟、复位与跨时钟域

  

从顶层时钟源沿端口实际连接向下追踪，记录频率、来源、复位来源和所驱动模块。再检查每个 FIFO 两侧的时钟：异步 FIFO 模块具备跨域能力，但当前实例的两侧时钟也可能相同；普通 payload FIFO 也可能只在单时钟域内缓冲数据。

  

| 时钟域 | 来源/频率 | 驱动对象 | 复位 | 与其他域的连接/CDC |

| --- | --- | --- | --- | --- |

| `<域名>` | `<实际来源>` | `<实例>` | `<实际来源>` | `<FIFO 或同步器及方向>` |

  

**产出：**时钟复位表和真正发生 CDC 的连接清单。

  

> 提问模板：沿 `<顶层>` 和 `<相关 FIFO>` 的实际连接整理时钟、复位表。指出哪些实例真正跨时钟域，哪些只是使用了支持异步模式的模块；给出端口和源码依据。

  

### 9.6 阅读测试，区分预期与已验证结果

  

先找真正的测试入口和仿真器启动方式，再把每段激励、预期响应、断言与 RTL 模块对应起来。检查 DUT 边界：测试是在板级引脚、XGMII 还是 AXI Stream 注入；时钟和复位如何模拟；是否检查超时、错误输入、连续报文与背压。

  

| 阶段 | 输入激励 | 预期输出 | 对应 RTL | 实际断言 |

| --- | --- | --- | --- | --- |

| `<阶段>` | `<测试代码>` | `<预期行为>` | `<模块/实例>` | `<检查项>` |

  

本次 `test_fpga_core.py` 的 `run_test` 预期流程是：注入 UDP → 检查 FPGA 的 ARP 请求 → 返回 ARP 响应 → 检查 UDP 回包。它测试 `fpga_core` 的 XGMII 接口，不覆盖板级 GTH/SFP 物理链路。阅读测试代码只能确认**测试打算检查什么**；必须实际运行并保留结果，才能写“测试已通过”。

  

> 提问模板：逐段解释 `<测试函数>` 的激励和断言，映射到 RTL 模块。明确 DUT 边界、已覆盖和未覆盖的行为；区分测试预期与实际执行结果。

  

### 9.7 运行基线，再扩展验证

  

先检查 Python、依赖版本、仿真器、源文件路径及符号链接等环境条件。在不改业务 RTL 的前提下运行项目原有测试，记录命令、版本、日志、退出状态、断言和必要波形。基线通过后，按风险逐项扩展：数据长度边界、端口过滤、ARP 缓存命中/未命中与超时、连续报文、背压、时钟差异和复位。最后再做综合、CDC、时序及板级验证；每一步只声明该步骤实际覆盖的范围。

  

当前 ExaNIC X10 示例**尚未取得 `run_test` 的实际通过结果**。此前只完成了源码分析、Vivado RTL 展开、测试阅读和仿真环境检查。Windows 检出中的 `example/ExaNIC_X10/fpga/lib/eth` 是普通文本文件而非预期符号链接，运行原测试前需要处理源码路径。测试入口应通过 pytest/cocotb 启动仿真器，不能在 Vivado Tcl 窗口直接执行 Python `run_test`。

  

**产出：**按层次保存“源码推断 → MCP 确认 → 仿真结果 → 综合/时序结果 → 板级结果”；未执行的层次留空。

  

### 9.8 每个主题的学习记录模板

  

```text

学习主题与具体事务：

工程路径、仓库版本/提交、顶层、器件：

结构：顶层 → 关键实例 → 主要接口

数据流：入口 → 处理 → 缓冲 → 出口

控制流：筛选、握手、状态机、等待条件

时钟复位：各域、复位、实际 CDC 连接

源码依据：文件、行号、关键表达式

MCP 证据：工具名、命令、实际返回

验证证据：运行命令、日志、断言、波形/报告

结论等级：源码推断 / 工具确认 / 仿真验证 / 板级验证

尚未确认的问题与下一步：

```

  

新项目可以从这段总提示词开始：

  

> 按“工程确认 → 顶层结构 → 具体事务的数据与控制 → 时钟复位 → 测试映射 → 实际验证”的顺序，带我学习 `<工程/模块/功能>`。每轮只深入一层业务模块，结合源码和 Vivado MCP 给出实际实例、信号及源码位置。记录工具的真实返回，明确区分源码推断、工具确认和已运行的测试结果，并指出下一步最值得验证的问题。

  

## 10. Linux 学习机部署与多机协作建议

  

记录日期：2026-11-12。以下为部署方案，尚未在目标笔记本执行安装。目标机器目前运行 Windows 10；型号、CPU、内存、磁盘布局、剩余容量及是否保留 Windows 尚待确认，因此分区容量仅作为建议。

  

### 10.1 系统选择与学习需求

  

推荐 **Ubuntu Desktop 24.04 LTS，x86-64（amd64）版本**，原生安装在 SSD 上。综合考虑 xv6、RTL 仿真、Vivado 和 RDMA，而不只围绕一个工具选系统。

  

| 学习目录/方向 | 所需环境 | 说明 |

| --- | --- | --- |

| `ROSS/vivado-mcp-demo` | Vivado 2025.1、MCP、Icarus、Python/cocotb、波形工具 | Linux 重新检出源码，保留正确符号链接 |

| `ROSS/linux-rdma/rdma-core` | C/C++、CMake、Linux 系统开发库 | 构建用户态代码不等于完成硬件 RDMA 通信验证 |

| `XV6_RISCV/xv6-riscv` | RISC-V GCC、QEMU、GDB | 当前 Makefile 要求 QEMU ≥ 7.2 |

| `LBEX` / Ibex 学习计划 | Verilator、FuseSoC、RISC-V 裸机工具链 | 检查时 `LBEX` 为空；按笔记中的 Ibex Simple System 计划准备 |

  

Ubuntu 24.04 的软件包更适合直接满足当前 xv6 的 QEMU 要求，标准安全维护到 2029 年 5 月。Vivado 2025.1 官方支持列表包含 Ubuntu 24.04、24.04.1 及 22.04.2～22.04.5；**不能把所有后续 24.04 点版本与内核组合都视为已获 AMD 验证**。安装前核对所选镜像、内核及 Vivado 版本，安装后先做工程基线检查。

  

旧版 Ethernet 测试使用独立 Python 3.10 环境，以适配仓库固定的 cocotb 依赖，不替换系统 Python。暂不因发行版更新而直接升级到 Ubuntu 26.04，也不优先选滚动发行版。

  

### 10.2 硬件与安装方式

  

以下为学习工作负载的实用建议，不是 Vivado 官方最低配置：

  

| 资源 | 建议 |

| --- | --- |

| 8 GB RAM | 适合 xv6、源码阅读和小型仿真，完整 Vivado 工程可能吃力 |

| 16 GB RAM | 可以起步，控制并行任务和工程规模 |

| 32 GB RAM 或以上 | 更适合 Vivado、仿真器和编辑器同时运行 |

| SSD | 512 GB 可起步，完整学习机更建议 1 TB |

| Linux 空间 | 建议 250～400 GB 或更多；Vivado 实际需求以安装器所选组件为准 |

| 独立显卡 | 当前学习路线无需专门配置 |

  

优先顺序：有第二块 SSD 时单独安装 Linux；只有一块 SSD 且仍需要 Windows 时采用双系统；确认笔记本专用于 Linux 后，才考虑备份并改为单系统。双系统不能同时运行两个系统。空间紧张时先安装 xv6 和仿真环境，Vivado 继续使用现有 Windows 机器。

  

### 10.3 在 Windows 10 笔记本上部署

  

1. **确认机器与备份。** 在 `msinfo32` 查看型号、CPU、内存与 BIOS 模式，在“磁盘管理”查看磁盘和分区。备份数据、未提交代码；如有 BitLocker/设备加密，保存恢复密钥。准备至少 8 GB、建议 16 GB 的 U 盘，制作启动盘会清空它。

2. **准备安装介质。** 从 Ubuntu 官方获取 24.04 LTS amd64 镜像，核对 SHA256，用 Rufus 等工具写入 U 盘。UEFI 机器通常使用 GPT/UEFI；若 Windows 为 Legacy 启动，先明确启动方案，不直接套用 UEFI 双系统步骤。

3. **准备磁盘空间。** 同盘双系统先关闭 Windows 快速启动；涉及加密分区时按官方说明关闭 BitLocker并等待解密完成，再在 Windows 磁盘管理中压缩分区，留下未分配空间，不预先格式化为 NTFS。

4. **先试运行。** 从 UEFI USB 启动，选择 Try Ubuntu，检查网络、触控板、亮度、SSD、外接显示器及睡眠唤醒。Secure Boot 不必预先关闭，出现具体驱动签名问题时再处理。

5. **处理 RST 特殊情况。** 若安装器提示 Intel RST 或看不到 SSD，停止分区操作，按官方流程准备 Windows 后再切换 AHCI；不要直接在 BIOS 改控制器模式，否则 Windows 可能无法启动。

6. **安装并核对分区。** 安装器正确识别 Windows 时可选择共存安装。手动分区时，Linux 主空间使用 ext4 挂载 `/`，初学阶段不必单独分 `/home`；交换空间先采用系统默认配置，休眠另行规划。同盘 UEFI 双系统通常复用现有 EFI 分区，**不要格式化它**。第二块 SSD 可规划独立 EFI。提交前核对目标磁盘及所有将格式化的分区，双系统不要选择“清除磁盘”。

7. **更新与验收。** 安装后拔出 U 盘，进入 Ubuntu 更新系统，通过“附加驱动”检查驱动；双系统分别启动 Ubuntu 和 Windows 验证。

  

```bash

sudo apt update

sudo apt upgrade

sudo reboot

```

  

### 10.4 分批准备开发环境

  

以下命令在 Ubuntu 终端执行。源码建议位于 `~/Project/SELF/`，项目目录保持 `ROSS/`、`LBEX/`、`XV6_RISCV/` 的组织方式，构建在 Linux 本地 ext4 文件系统中完成。

  

**第一批：通用工具与 Git。**

  

```bash

sudo apt install \

  git build-essential cmake ninja-build pkg-config \

  curl wget unzip zip xz-utils \

  python3 python3-venv python3-pip python3-dev \

  gdb bc ripgrep tmux

  

git config --global user.name "你的名字"

git config --global user.email "你的提交邮箱"

git config --global core.autocrlf input

```

  

安装 VS Code，通过 Git 获取项目。不要把 Windows 的虚拟环境、构建目录和符号链接占位文件直接复制来使用；未提交文件单独备份和核对。跨平台换行优先通过仓库 `.gitattributes` 统一。

  

**第二批：xv6。**

  

```bash

sudo apt install \

  qemu-system-misc gcc-riscv64-linux-gnu \

  binutils-riscv64-linux-gnu gdb-multiarch

  

qemu-system-riscv64 --version

riscv64-linux-gnu-gcc --version

gdb-multiarch --version

  

# 检出工程后执行

cd ~/Project/SELF/XV6_RISCV/xv6-riscv

make qemu

```

  

验收：进入 xv6 shell 并运行 `ls`；退出 QEMU 通常依次按 Ctrl+A、X。课程实验继续遵循同一学年的仓库、教材和工具要求。

  

**第三批：RTL 仿真。**

  

```bash

sudo apt install iverilog verilator gtkwave

iverilog -V

verilator --version

gtkwave --version

```

  

给 Ethernet 测试创建单独环境，按照当前仓库 `tox.ini` 固定依赖，例如 `cocotb==1.7.2`、`cocotb-test==0.2.4`。不要直接安装全部最新版，不使用 `sudo pip install`。可以按 uv 官方文档安装 uv，再执行：

  

```bash

cd ~/Project/SELF/ROSS/vivado-mcp-demo

mkdir -p sim

uv python install 3.10

uv venv --python 3.10 sim/.venv

source sim/.venv/bin/activate

```

  

上述命令仅创建 Python 环境；仍需按仓库配置安装依赖、核对源码路径，再通过 pytest/cocotb 运行原始测试。日志、报告、波形和构建产物集中放在 `ROSS/vivado-mcp-demo/sim/`，首次以原始 `run_test` 的实际结果为基线。

  

**第四批：Vivado 与 MCP。**

  

先安装 Linux 版 Vivado 2025.1，与 Windows 工程版本保持一致。按安装器提示配置依赖，选择实际所需器件包；当前 ExaNIC X10 工程需支持 Kintex UltraScale 目标器件。安装路径按本机确定，以下为占位示例：

  

```bash

source /你的安装路径/Vivado/2025.1/settings64.sh

vivado -version

```

  

通过 Tcl 脚本在 Linux 重建工程，单独配置 Linux 侧 Vivado AI/MCP，不能沿用 Windows 的 `vivado.bat` 路径。再通过真实 MCP 工具执行 `version -short` 和 `expr {6 * 7}`，保存版本及 `42` 的返回证据。连接板卡时再安装 cable driver，检查器件/IP 许可。工具版本检查、MCP 检查和 RTL 功能验证分别验收。

  

**第五批：Ibex 与 RDMA。**

  

Ibex 先固定仓库提交，再按对应要求准备 FuseSoC、Verilator 和 RV32 裸机工具链，先运行 Simple System，再做 co-simulation。不要默认 xv6 使用的 RV64 Linux 工具链可满足全部 Ibex 构建需求。

  

RDMA 构建依赖以本地 `rdma-core/README.md` 为准，在通用工具之外补充：

  

```bash

sudo apt install \

  libudev-dev libnl-3-dev libnl-route-3-dev \

  valgrind cython3 python3-docutils pandoc

```

  

之后在仓库使用 `bash build.sh`。普通笔记本可以阅读和构建 RDMA 用户态代码；硬件 RDMA 通信需要兼容网卡与网络环境，Soft-RoCE 可后续单独学习，其性能与验证范围不同。

  

### 10.5 多台电脑的协作约定

  

**Git 是版本同步基础，SSH 是可选远程操作方式。** Windows 和 Linux 都具备完整环境时，可以分别直接操作，通过 Git 提交、推送、拉取同步；只有希望坐在 Windows 前控制 Linux 时，才需要 SSH、Remote-SSH 或远程桌面。Git 使用 SSH 传输与 SSH 远程执行测试是两件事，也可以用 HTTPS 同步 Git。

  

- 每台机器保留独立工作副本、依赖环境和构建目录，同一阶段明确主要修改位置。

- 使用 GitHub/GitLab 或局域网 Git 远端；上游 RTL 与学习脚本分仓管理，或用 submodule 固定源码版本，避免不明确的嵌套仓库。

- 提交 RTL、约束、测试、工程 Tcl、依赖清单和文档；通常忽略 `.Xil`、虚拟环境、大型波形及可再生成的构建产物。

- 通过 Git 重新检出源码，保留符号链接与脚本权限；脚本使用相对路径或根据脚本位置定位工程，避免写死 Windows/Linux 绝对路径。

- 每次测试记录 commit、工作区是否干净、工具版本、命令、结果和产物位置。Windows 未保存或未提交的修改不会自动成为 Linux 的测试对象。

- 使用 Remote-SSH 时区分 Windows 本地窗口与 Linux 远程窗口，确认扩展、Python、MCP 实际运行在哪台机器。

- SCP/SFTP/rsync 适合传输日志和波形；先跑通手动基线，再考虑脚本化和 CI。

  

### 10.6 部署验收与资料

  

- [ ] 确认笔记本配置、是否保留 Windows、安装磁盘与容量。

- [ ] 完成备份；Ubuntu 网络、磁盘和睡眠正常，保留的 Windows 可启动。

- [ ] Git 能获取工程并对应相同 commit。

- [ ] `make qemu` 进入 xv6 shell。

- [ ] Icarus、Verilator、波形工具可运行。

- [ ] 原始 `run_test` 有实际通过/失败记录。

- [ ] Linux Vivado 可启动，MCP 返回版本与 `42`。

- [ ] 当前 RTL 工程在 Linux 重建并展开成功。

- [ ] 按进度开展 Ibex、RDMA 与综合实现学习。

  

参考资料（部署时重新核对版本）：

  

- [Ubuntu 24.04 安装教程](https://ubuntu.com/desktop/docs/en/24.04/tutorial/install-ubuntu-desktop/)

- [Ubuntu RST/AHCI 调整指南](https://ubuntu.com/desktop/docs/en/24.04/how-to/reconfigure-windows-to-use-ahci/)

- [Ubuntu 生命周期](https://ubuntu.com/about/release-cycle)

- [Vivado 2025.1 支持的操作系统](https://docs.amd.com/r/2025.1-English/ug973-vivado-release-notes-install-license/Supported-Operating-Systems)

- [MIT 2025 xv6 工具说明](https://pdos.csail.mit.edu/6.828/2025/tools.html)

- [uv 管理 Python](https://docs.astral.sh/uv/guides/install-python/)

- [Ibex 系统要求](https://ibex-core.readthedocs.io/en/latest/02_user/system_requirements.html)

- [VS Code Remote-SSH](https://code.visualstudio.com/docs/remote/ssh)
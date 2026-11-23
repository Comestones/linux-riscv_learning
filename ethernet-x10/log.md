# ExaNIC X10 学习日志

每次学习在本页按日期追加一节，最近一次放在最上面。[工程框架](README.md#工程框架) · [仿真环境与固定依赖](udp-verification.md#在-ubuntu-运行原始-pytest)

## 2026-11-23 · 在 Ubuntu 上验证第一次 UDP 回显

**Ubuntu 基线已通过。** 今天只运行上游原始用例 `test_fpga_core.py::test_fpga_core`。目标是从仿真日志认出端口 1 上的四帧，并用断言确认最后一帧回给了谁、带回了哪些数据。整次实验在 Icarus 中运行，无需连接板卡。

### 1. 同步工程，准备环境

在 Ubuntu 的 Bash 中进入已有的 SELF 主仓库根目录，运行 `git pull --ff-only` 取回本计划。用 `command -v uv`、`command -v iverilog`、`command -v vvp` 检查工具。缺 Icarus 时用 `sudo apt install iverilog` 安装，缺 uv 时按其官方说明安装。[uv 安装说明](https://docs.astral.sh/uv/getting-started/installation/)

从主仓库根目录执行环境指南的第一段命令。它会初始化子模块、进入 `ethernet-x10/`、激活 Python 3.10 虚拟环境并安装固定版本的依赖。确认依赖安装成功、`iverilog -V` 能输出版本，且最后一行显示 `RTL OK`，然后留在同一个终端继续。若缺少 `RTL OK`，先检查测试所用的 `fpga/lib/eth` 是否为 Linux 工作副本中的目录符号链接。[Ubuntu 环境准备](udp-verification.md#在-ubuntu-运行原始-pytest)

### 2. 预测四帧，再运行一个用例

开跑前，写下 FPGA 收到第一个 UDP 请求后最先发出什么帧，以及这帧在查询哪个 IP。然后在 `ethernet-x10/` 中执行下面的命令。终端会实时显示 INFO 日志，`sim/x10-pytest.log` 保存本次完整输出。

```bash
git -C verilog-ethernet rev-parse --short HEAD
python --version
set -o pipefail
SIM=icarus python -m pytest -v -s --log-cli-level=INFO \
  verilog-ethernet/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py::test_fpga_core \
  2>&1 | tee sim/x10-pytest.log
run_status=$?
printf '退出码 %s\n' "$run_status"
```

### 3. 用日志与断言验收

```bash
grep -nE 'test UDP RX packet|receive ARP request|send ARP response|receive UDP packet|run_test.*(PASS|passed)|1 passed' sim/x10-pytest.log
```

| 依次寻找的日志标记 | 预期方向 | 要从报文或断言中核对的内容 |
| --- | --- | --- |
| `test UDP RX packet` | 主机 → FPGA | 请求从主机端口 `5678` 发往 FPGA 端口 `1234`。 |
| `receive ARP request` | FPGA → 主机 | FPGA 广播查询 `192.168.1.100` 的 MAC。 |
| `send ARP response` | 主机 → FPGA | 主机返回自己的 MAC `5a:51:52:53:54:55`。 |
| `receive UDP packet` | FPGA → 主机 | 回包从 `1234` 发往 `5678`，载荷仍是从 `00` 到 `ff` 的 256 字节。 |

四条 INFO 标记在相应收发操作**之前**打印。判断成功还要同时看到 cocotb 的 `run_test` 为 `PASS`、pytest 的 `1 passed` 和退出码 `0`。若停在某一阶段，记下最后一个标记和紧随其后的错误或断言行，方便下次从同一处继续。[ARP 断言](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py#L103-L123) · [UDP 回包断言](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py#L135-L151)

**Ubuntu 实测回填**

| 记录项 | 本次实际结果 |
| --- | --- |
| 子模块提交、Python 和 Icarus 版本 | `77320a9471d19c7dd383914bc049e02d9f4f1ffb`，Python `3.10.22`，Icarus Verilog `12.0 (stable)`。 |
| cocotb 汇总、pytest 汇总、退出码 | `run_test` 为 `PASS`（仿真时间 4390.40 ns，实际用时 2.68 s）。cocotb 汇总为 `TESTS=1 PASS=1 FAIL=0 SKIP=0`，pytest 显示 `1 passed in 3.57s`，终端确认退出码为 `0`。 |
| 测试台阶段标记（`sim/x10-pytest.log`） | 121.60 ns 依次打印第 96 行 `test UDP RX packet` 和第 97 行 `receive ARP request`。<br>3596.80 ns 依次打印第 105 行 `send ARP response` 和第 106 行 `receive UDP packet`。 |
| 实际帧序与预测是否一致，或首次失败位置 | 与预测一致。端口 1 依次出现 UDP 请求、ARP 请求、ARP 应答、UDP 回包。主机在 4377.60 ns 收到发往 `192.168.1.100:5678` 的回包，载荷仍是从 `00` 到 `ff` 的 256 字节。 |

## 2026-11-20 · ExaNIC X10 UDP 回显走读与首次试跑

今天从 `test_fpga_core.py` 的输入和断言出发，沿 RTL 追踪端口过滤、ARP 查询和载荷 FIFO。实验选用上游提交 `77320a9471d19c7dd383914bc049e02d9f4f1ffb`，被测模块是 `fpga_core`，输入和输出都在端口 1 的 XGMII 接口。

### 阅读时提出的问题

**前面的步骤都是代码阅读吗？为什么先看第 166 行？**

走读得到的是对仿真的预测。第 166 行的 `test_fpga_core(request)` 是 pytest 入口，在这里能确认被测顶层和参与编译的 RTL，第 211 行启动仿真器。文件前部依次导入组包与仿真工具、定义测试平台 `TB`，再用 `@cocotb.test()` 标记第 87 行的 `run_test(dut)`。真正要观察的发包、等待和断言都在这个协程中。[pytest 入口](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py#L157-L219) · [测试过程](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py#L86-L154)

**`__init__(self, dut)` 和 `async def init(self)` 各做什么？**

第 89 行 `tb = TB(dut)` 自动调用前者，保存 DUT、启动周期为 6.4 ns 的时钟，并把 XGMII 收发端连到端口。第 91 行 `await tb.init()` 显式调用后者，先让复位为 0，等 10 个上升沿后置 1，再等 10 个上升沿后释放。时钟继续运行，当前测试等复位流程结束才开始发包。[TB 的连接和复位](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py#L41-L91)

**Scapy 用 `eth / ip / udp / payload` 组包，有什么规范？**

`/` 是 Scapy 的协议层组合运算符，右边的内容成为左边一层的载荷。第 101 行的 `build()` 将报文序列化。在这个请求中，EtherType `0x0800` 表示 IPv4，IPv4 协议号 `17` 表示 UDP，8 字节 UDP 头后跟 256 字节数据。ARP 帧的外层 EtherType 是 `0x0806`，第 116 行的 `ARP.ptype == 0x0800` 指的是 ARP 正在解析 IPv4 地址。[Scapy 官方组包说明](https://scapy.readthedocs.io/en/stable/usage.html#stacking-layers) · [RFC 894](https://www.rfc-editor.org/rfc/rfc894.html) · [RFC 791 §3.1](https://www.rfc-editor.org/rfc/rfc791.html#section-3.1) · [RFC 768](https://www.rfc-editor.org/rfc/rfc768.html) · [RFC 826](https://www.rfc-editor.org/rfc/rfc826.html)

**四个动作分别是谁做的？**

测试程序扮演主机。`sfp_source[0]` 驱动 FPGA 端口 1 的接收接口，`sfp_sink[0]` 观察该端口的发送接口。以下顺序来自原测试的激励和断言。

| 测试行 | 方向 | 预期事件 |
| --- | --- | --- |
| 103 | 主机 → FPGA | 从 `192.168.1.100:5678` 发往 `192.168.1.128:1234`，UDP 载荷依次为 `00` 到 `ff`。 |
| 107 | FPGA → 主机 | 广播 ARP 请求，询问主机 IP `192.168.1.100` 对应的 MAC。 |
| 135 | 主机 → FPGA | 返回 ARP 应答，声明主机 MAC 为 `5a:51:52:53:54:55`。 |
| 139 | FPGA → 主机 | 将 UDP 载荷从端口 `1234` 回送到主机端口 `5678`。第 145～151 行核对 MAC、IP、端口和载荷。 |

**首帧已经有主机 MAC，为什么还会发 ARP？有了 IP 又为什么需要 MAC？**

首帧的 Ethernet 源 MAC 确实是主机地址。这份 RTL 将 IPv4 帧和 ARP 帧分流，ARP 缓存用收到的 ARP 报文里的发送者 IP/MAC 更新。发送侧把请求的源 IP 作为回包目的 IP，首次查询缓存未命中时发 ARP 请求。后续同一映射仍命中时就可以直接封装回包。[帧类型分流](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/rtl/ip_complete_64.v#L208-L209) · [缓存写入](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/rtl/arp.v#L295-L302)

IPv4 地址属于网络层（L3），标识最终目的地。以太网 MAC 地址属于数据链路层（L2），标识这一段链路的下一跳。本例两端同属一个 /24 子网，下一跳就是主机。发往其他子网时，本工程改查网关 `192.168.1.1` 的 MAC，IP 头仍保留最终目的 IP。[下一跳选择](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/rtl/arp.v#L386-L411)

**为什么在 `fpga_core.v` 里找不到单独的 `tvalid`、`tready`、`tlast`？**

信号名带有通路前缀。第 285 行用 `match_cond_reg` 控制送给 FIFO 的 `tvalid`，第 286 行把 FIFO 的 `tready` 传回匹配的 UDP 通路，第 287 行将上游 `tlast` 接到 FIFO 输入。上升沿上 `tvalid && tready` 表示接受一拍，若该拍 `tlast` 也为 1，就接受了包尾。例化的 `udp_payload_fifo` 使用普通 FIFO 模式，实际的写入条件在 `axis_fifo.v` 第 310 行，写 RAM 和指针加一在第 337～338 行。[通路连线](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/rtl/fpga_core.v#L283-L288) · [FIFO 写入](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/lib/axis/rtl/axis_fifo.v#L308-L340)

### 原始 run_test 在 Windows 上的首次试跑

今天在 Windows 的 `ethernet-x10/` 目录试跑了原始入口。

```powershell
python -B -m pytest -v -s verilog-ethernet/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py::test_fpga_core
```

Python 3.11.7 返回 `No module named pytest`，退出码为 1。测试在加载 pytest 时停止，`fpga_core` 尚未编译，四帧事务也尚未执行。

| 检查项 | 这次看到的结果 |
| --- | --- |
| Python 测试环境 | PowerShell 使用 MSYS2 的 Python，当前解释器也找不到 `cocotb`、`cocotb_test` 和 `scapy`。 |
| 仿真器 | 已安装 Vivado/XSim。这个 pytest 调用的 `cocotb-test 0.2.4` 默认用 Icarus Verilog，当前终端找不到编译器 `iverilog` 和运行器 `vvp`。 |
| RTL 路径 | Git 将示例下的 `fpga/lib/eth` 记录为目录符号链接。这份 Windows 副本将它检出为内容是 `../../../../` 的普通文件。实际的 `rtl/udp_64.v` 存在，测试第 163 行使用的 `lib/eth/rtl/` 路径却无法访问它。 |
| WSL | `wsl.exe --list --verbose` 报告此机尚未安装 WSL。 |

原生 Windows 可以配置这套工具。今天建议用已有的 Ubuntu 机器，在 Linux 文件系统里用 Git 检出工程可以保留目录链接，也能沿用项目记录的 Python 3.10 与 Icarus 流程。上次 Ubuntu 上通过的是 XSim 最小用例，Icarus 和 Python 测试依赖还需要在那台机器上核实。[cocotb-test 0.2.4 平台与仿真器说明](https://pypi.org/project/cocotb-test/0.2.4/) · [Ubuntu 工具记录](../riscv-systems/ubuntu-setup.md)

当时安排的下一步是换到 Ubuntu 运行同一用例，对照预测的四帧检查断言。具体命令与验收表已归入 11 月 23 日的实验计划。

**通过后再验证 ARP 缓存。** 在单独的实验用例中保持同一次仿真和同一主机地址，收到第一次回包后立即再发一帧 UDP。预测第二次从 FPGA 收到的第一帧就是 UDP 回包，再对比两次事务中出现的 ARP 帧数。重新启动 pytest 会重新执行复位，无法沿用第一笔事务建立的缓存。

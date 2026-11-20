# 跟踪一个 UDP 回包并运行 X10 基线

业务 RTL 在 `verilog-ethernet/example/ExaNIC_X10/fpga/rtl/`。原测试在同一示例的 `tb/fpga_core/test_fpga_core.py`，Python 入口是 pytest 的 `test_fpga_core`，由它启动仿真器并运行 cocotb 的 `run_test`。[业务核心源码](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/rtl/fpga_core.v) · [原始测试与断言](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py)

## 用一笔事务读 RTL

| 测试中的事件 | 在 RTL 或波形里找什么 |
| --- | --- |
| 主机从 `192.168.1.100:5678` 向 `192.168.1.128:1234` 发 UDP | 从端口 1 的 XGMII 输入追到 UDP 头。看 `rx_udp_dest_port` 如何产生 `match_cond`，再找报头和 payload 各自的握手。 |
| FPGA 发 ARP 请求，主机给出 ARP 应答 | 区分回包目的 IP 和对应 MAC 的来源。记录载荷暂存的位置，以及哪个条件让等待结束。 |
| FPGA 输出 UDP 回包 | 核对两端 MAC/IP、UDP 端口和 payload。沿 `valid/ready` 找到一次被接受的数据传输，标出帧尾。 |

原测试从 `fpga_core` 的 XGMII 收发，板级 GTH、SFP 和外部链路留给实板验证。背压适合放在可控制 `ready` 的内部流接口或 FIFO 模块测试。读源码时按“一笔事务、一个时钟域、一个检查点”逐层记录实际实例和信号。

## 在 Ubuntu 运行原始 pytest

2026-11-20 整理时仍待取得原用例的通过记录。用 Linux 的 Git 工作副本保留目录符号链接，按固定提交的 `tox.ini` 配置独立的 Python 3.10 环境。以下命令在 Ubuntu 的 Bash 中执行，从主仓库根目录开始。需要 `uv` 和 Icarus Verilog，`iverilog -V` 应能返回版本。[上游依赖清单](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/tox.ini) · [uv 的 Python 工具说明](https://docs.astral.sh/uv/guides/install-python/)

```bash
git submodule update --init --recursive -- ethernet-x10/verilog-ethernet
cd ethernet-x10
mkdir -p sim
uv python install 3.10
uv venv --python 3.10 sim/.venv
source sim/.venv/bin/activate
uv pip install pytest==7.2.1 pytest-xdist==3.1.0 pytest-split==0.8.0 \
  cocotb==1.7.2 cocotb-bus==0.2.1 cocotb-test==0.2.4 \
  cocotbext-axi==0.1.20 cocotbext-eth==0.1.22 scapy==2.5.0 jinja2==3.1.2
iverilog -V
test -f verilog-ethernet/example/ExaNIC_X10/fpga/lib/eth/rtl/udp_64.v
```

确认最后一条的退出码为 0，再在同一终端运行下列命令。日志在 `sim/`，上游测试脚本把仿真构建目录建在测试文件旁的 `sim_build/`。

```bash
set -o pipefail
python -m pytest -v -s verilog-ethernet/example/ExaNIC_X10/fpga/tb/fpga_core/test_fpga_core.py::test_fpga_core 2>&1 | tee sim/x10-pytest.log
echo $?
```

## 基线之后的两个小实验

1. **目的端口过滤。** 把输入目的端口改为 `1235`，在事先规定的观察窗口内检查没有匹配的 UDP 回包，随后再发一个合法请求检查仍能响应。保留种子或输入报文、窗口长度和波形。
2. **MAC 帧计数。** 若给端口 1 增加诊断计数，在 MAC 用户侧用 `tvalid && tready && tlast` 计一帧。相对测试前快照，原激励预期 RX 增 2（UDP 请求、ARP 应答），TX 增 2（ARP 请求、UDP 回包）。这是扩展检查的预期值，实测后再填结果。ADV 的串口查询可复用[终端工程](../uart-fifo-terminal/README.md)。

每次记录 Git 提交、平台和工具版本，再记输入、DUT 边界、断言、退出码及日志位置。失败时从第一处偏离的事务回查 RTL 或测试预期。

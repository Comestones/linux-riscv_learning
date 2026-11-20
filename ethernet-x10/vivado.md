# X10 的 Vivado 工程重建与实测记录

使用 Vivado 2025.1，顶层为 `fpga`，器件为 `xcku035-fbva676-2-e`。工程以当前目录里的上游 Makefile 为清单。脚本自己定位相邻的 `verilog-ethernet/`，兼容 Windows 将 `lib/eth` 检出为文本占位的情况，并调用上游 Tcl 生成两个收发器 IP。[创建脚本](create_project.tcl)

## 打开或重建

从仓库根目录启动时，将 Vivado MCP 的 `working_dir` 设为本仓库的 `ethernet-x10` 目录。以下 Tcl 从该目录的空 Vivado 会话执行。已有工程走打开分支，新工作副本走创建分支。

```tcl
if {[file exists build/exanic_x10/exanic_x10.xpr]} {
    open_project build/exanic_x10/exanic_x10.xpr
} else {
    source ./create_project.tcl
}
get_property PART [current_project]
get_property TOP [get_filesets sources_1]
get_ips
```

若已有展开的 RTL 直接使用。新打开的工程在 Tcl 中依次执行下列命令，或从 GUI 选择 **RTL Analysis → Open Elaborated Design**，再运行检查脚本。MCP 长调用超时时先查 `vivado_status`，等当前命令结束再决定是否重跑。

```tcl
synth_design -rtl -name rtl_1 -top fpga -part xcku035-fbva676-2-e
source ./inspect_design.tcl
```

脚本将层次、端口、IP、编译顺序写入本机的 `reports/`。保留旧报告原有的路径和日期，复现实验时另存需要对比的历史报告，再生成新报告。[报告脚本](inspect_design.tcl)

## 已取得的记录

| 日期与平台 | 实际结果 | 可以据此判断什么 |
| --- | --- | --- |
| 2026-11-11 · Windows | MCP 驱动 Vivado 2025.1 完成 RTL 展开，退出码 0，约 306 秒。43 个上游 RTL 文件、4 个约束文件、2 个 GT Wizard IP，26 个顶层端口位、28,882 个层次单元、0 个黑盒。 | 工程与源码清单可以展开。当次有 2,894 个 warning、0 个 critical warning、0 个 error，警告仍需按硬件用途审阅。 |
| 2026-11-19 · Ubuntu | 修复 `en_US.UTF-8` 并重新生成器件清单后确认 162 行，可查询该器件。XSim 2025.1（SW Build 6140274）运行 `xsim smoke_sim -runall`，输出 `XSIM_SMOKE_PASS`，在 1 ns 正常结束。 | Linux 仿真器可运行最小用例。X10 的 UDP 回包由单独的 pytest 验收。[运行步骤](udp-verification.md) |
| 2026-11-20 · Windows 目录迁移复核 | Vivado 2025.1 只读打开迁移后的 XPR，逐一匹配 Makefile 里的 43 个 RTL 文件和 4 个约束输入，确认 2 个 IP、顶层 `fpga` 和预期器件。 | 新目录中的工程能找到全部设计输入。该检查到工程打开和文件解析为止。 |

Linux 学习机可用 `source "$HOME/tools/Xilinx/2025.1/Vivado/settings64.sh"` 加载当时的安装环境。若选做跨平台 MCP 复现，独立配置 Linux 的 Vivado 可执行文件，先保存 `version -short` 和 `expr {6 * 7}` 的实际返回，再按本页在 Linux 重建工程。

## 下一步看哪些信号与报告

1. 从板级时钟和收发器沿实例端口向下走，记录每个时钟的来源、复位、驱动对象。业务时钟的来源可从顶层的 `clk_156mhz_int` 赋值追到端口 1 TX 时钟。对照每个 FIFO 两侧的实际连线判断是否跨时钟域。[固定版本的顶层 RTL](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/rtl/fpga.v)
2. 跑实现时，核对约束覆盖、CDC、关键路径、布局布线后的建立与保持余量及资源。在时序或 lint 报告出现明确问题时，可选用 Ross 的 multi-violation 例子练习“找到原因、修改、复查报告”。原笔记所用 Ross 资料以 2026.1 为基线，运行具体 Skill 前核对 2025.1 的适配情况。[Ross 官方 Vivado 示例](https://github.com/Xilinx/ross-ai-assistant#vivado)
3. 使用 X10 实板时，对照板卡的引脚和电平，把 ILA 信号与仿真中的同一笔事务对齐。UART 扩展的四条 GPIO 在原 XDC 中以 `LVCMOS18` 注释，接线前需查实板连接器电压。[固定版本的板级约束](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/fpga.xdc)

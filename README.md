# linux-riscv_learning

操作系统、RISC-V、RTL 与网络硬件的个人学习工作区。学习路线见 [学习路线与验证进度](learning-roadmap.md)。

## 获取完整工程

```bash
git clone --recurse-submodules https://github.com/Comestones/linux-riscv_learning.git
```

已经克隆时运行 `git submodule update --init --recursive`。上游源码以 submodule 固定到具体提交，不自动跟随最新版本。开始修改上游代码时，可使用自己的 fork，并更新对应 submodule URL 和提交。

| 目录 | 内容与来源 |
| --- | --- |
| `ROSS/vivado-mcp-demo` | Vivado MCP 学习脚本；[verilog-ethernet](https://github.com/alexforencich/verilog-ethernet) 的 ExaNIC X10 示例 |
| `ROSS/linux-rdma/rdma-core` | [linux-rdma/rdma-core](https://github.com/linux-rdma/rdma-core) 用户态 RDMA 源码 |
| `XV6_RISCV/xv6-riscv` | [MIT xv6-riscv](https://github.com/mit-pdos/xv6-riscv) 操作系统源码 |
| `LBEX` | 预留的 Ibex 学习目录，目前无源码 |

## 重建与验证

Vivado 示例使用 2025.1，顶层 `fpga`，器件 `xcku035-fbva676-2-e`。在空 Vivado 会话内，通过 MCP 执行 `source <本地工作区>/ROSS/vivado-mcp-demo/create_project.tcl` 创建工程。脚本拒绝覆盖已有工程。将 MCP 工作目录设置为 `ROSS/vivado-mcp-demo`；不要在工作区根目录生成测试文件。

`inspect_design.tcl` 用于 RTL 展开后的报告生成。构建工程、厂商生成的 IP 文件、缓存、会话日志及波形由各机器本地生成，不上传本仓库。子目录中的 Windows 绝对路径是原学习机器的示例路径，换机器时应替换。

历史记录：Windows Vivado 2025.1 中已完成 MCP 连通与 RTL 展开；尚未取得 cocotb `run_test` 通过结果，也未证明时序收敛或板级通信。Linux 环境建议和验收清单见学习笔记第 10 节。

Linux 应通过 Git 检出源码以保留符号链接；Windows 若未启用符号链接支持，上游 `lib/eth` 可能成为文本占位文件。工程创建脚本处理了这一情况，Python 仿真入口仍需单独核对路径。

## 来源与许可证

上游代码属于原作者，许可证保持在各 submodule 中：verilog-ethernet 的 `COPYING`、xv6 的 `LICENSE`，以及 rdma-core 的 `COPYING.md` 和各目录/文件声明。rdma-core 存在双许可及局部许可差异，以具体文件为准。本仓库不对第三方代码统一重新授权。个人笔记与辅助脚本不代表上游官方文档或功能保证。

## 多机协作

Windows 和 Linux 各自保留工作副本和工具环境，通过 Git 同步；SSH/Remote-SSH 按需使用。每次测试记录 commit、工作区状态、工具版本、命令和结果，避免混淆不同机器上的代码版本。

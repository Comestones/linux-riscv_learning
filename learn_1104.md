l| `<模块/实例>` | `<检查项>` |

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

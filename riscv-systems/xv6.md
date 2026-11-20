# xv6 的系统调用、页表与异常

当前 xv6 子模块固定在 `fa2ddcb7ca87a77af579380a6eafd5aff163b44f`。本地入口为 `riscv-systems/xv6-riscv/`，该版本 Makefile 要求 QEMU ≥ 7.2。2026-11-18 用 Ubuntu 的 RISC-V GCC 13.3.0、Binutils、QEMU 8.2.2 和 GDB Multiarch 15.1 完成首次启动。[固定版本的 Makefile](https://github.com/mit-pdos/xv6-riscv/blob/fa2ddcb7ca87a77af579380a6eafd5aff163b44f/Makefile)

## 重现已完成的启动

在 Ubuntu 进入主仓库根目录，运行下面三行命令。

```bash
git submodule update --init -- riscv-systems/xv6-riscv
cd riscv-systems/xv6-riscv
make qemu
```

看到 `init: starting sh` 和 `$` 后，依次输入 `ls`、`echo hello`、`cat README`。首次运行分别列出了镜像文件、输出了 `hello`、读出了 README。当时的临时日志位置为 `/tmp/xv6-first-boot-20261118.log`。退出时先按 **Ctrl+A**，松开后单按 **x**。回到 Ubuntu，打开 `user/echo.c` 对照输出。

## 用 GDB 跟踪一次系统调用

1. Ubuntu 终端一在 xv6 目录运行 `make qemu-gdb`。终端二进入同一目录运行 `gdb-multiarch -nx -x .gdbinit`，使用 Makefile 生成的端口和内核符号。
2. 在 `syscall` 设断点并继续运行。从断下的进程辨认系统调用号、trapframe 中的参数、分发表以及返回值写回的位置。选择一次 `write`，对照用户态的 `ecall`、内核入口、分发和返回用户态的顺序。[内核分发](https://github.com/mit-pdos/xv6-riscv/blob/fa2ddcb7ca87a77af579380a6eafd5aff163b44f/kernel/syscall.c)
3. 做 MIT 的 `trace` 实验时，按同一学年的说明另取实验仓库和指定分支。保存测试命令、结果和一次断点记录。固定子模块用于源码阅读和启动复现。[MIT 2025 系统调用实验](https://pdos.csail.mit.edu/6.1810/2025/labs/syscall.html) · [实验调试指南](https://pdos.csail.mit.edu/6.1810/2025/labs/guidance.html)

## 页表与异常

在 `kernel/vm.c` 中选一个用户虚拟地址，按 Sv39 逐级查 PTE，记录权限和页内偏移。再沿 `kernel/trap.c` 与 trampoline 汇编对照一次陷入，解释 `scause`、`sepc` 和 `stval` 对这次现象分别说明什么。能画出一次转换并从寄存器说明异常原因后，再按兴趣深入调度、锁或文件系统。主投 MCU 或 FPGA 时，一次完整的 GDB 跟踪即可作为这个分支的阶段成果。[MIT xv6 教材](https://github.com/mit-pdos/xv6-riscv-book)

## 转向嵌入式 Linux/BSP

选 Buildroot 的 `qemu_riscv64_virt_defconfig`，按该版本说明构建并启动 Linux。用生成的交叉工具链编译一段 C 自测程序，随根文件系统部署，在目标 shell 里用脚本运行并检查退出码。留存 defconfig、镜像版本、启动日志和测试结果。取得真实目标板后，按板卡设备树、驱动与外设的实际行为补一次板测。[Buildroot 配置](https://github.com/buildroot/buildroot/blob/master/configs/qemu_riscv64_virt_defconfig) · [配套 QEMU 启动说明](https://github.com/buildroot/buildroot/blob/master/board/qemu/riscv64-virt/readme.txt)

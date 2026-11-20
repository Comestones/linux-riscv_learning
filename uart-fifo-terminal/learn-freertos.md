# FreeRTOS 学习方案：用 Cardputer-Adv 做 FPGA 串口终端

2026-11-20 制定，实验均待执行。每周 5～7 小时由固件、RTL 和验证共用，可将下表的一周拆成多次实验。第 1～5 周先用串口模拟对端，第 6 周接入本项目的 FPGA 外设。模拟器、固件和 RTL 的命令格式见[共用接口规格](README.md#串口和寄存器约定)。

**结项目标**是在 ADV 持续接收带序号的串口数据时，仍能用键盘发命令、读回复。能从日志判断漏行发生在串口接收、任务队列还是屏幕显示阶段，并能解释一次优化前后的测量结果。

## 1. 每台设备负责什么

| 设备 | 负责的工作 | 交付给下一步的结果 |
| --- | --- | --- |
| Windows 开发机 | VS Code 编写 C/C++，ESP-IDF 构建并通过 USB-C 烧录 ADV、采集板端日志。第 2～5 周用第二个串口运行模拟 FPGA 的脚本。第 6 周用已有 Vivado 2025.1 / XSim 验证 UART RTL | 固件版本与启动记录、模拟器收发记录、RTL 断言与波形 |
| M5Stack Cardputer-Adv | ESP32-S3 运行 FreeRTOS。键盘输入命令，LCD 显示结果，扩展 UART 与对端通信。板上统计序号缺口、溢出次数和按键响应时间 | 可脱离电脑操作的终端，以及能与发送记录核对的接收统计 |
| 3.3 V USB-UART 转接器（手头有时使用） | USB 接 Windows，逻辑串口接 ADV，传输测试流量。ADV 自身的 USB-C 单独用于烧录和日志 | Windows 可分别观察“模拟 FPGA 发了什么”和“ADV 实际收到了什么”。若暂无转接器，第 2 周先短接回环，第 3～5 周用板内测试任务生成输入，并将物理串口压测留待有外部对端时补做 |
| Ubuntu 学习机 | 在同一 Git 提交上跑 FIFO 回归。进入第二个项目时再按 [X10 基线步骤](../ethernet-x10/udp-verification.md)跑 pytest/cocotb。选修 micro-ROS 时运行 Agent | 回归日志、失败种子，选修时另记 ROS 2 话题结果 |
| FPGA 目标板（有实板时） | FPGA 逻辑实现 UART 命令应答。普通开发板返回版本、FIFO 状态与样本计数，后续的 X10 实验可另接 SFP 状态和 MAC 帧计数。通过板卡原理图确认引脚和电平后接线 | 首次联调保存真实 bitstream 的版本回复、状态变化和样本计数。只有工程源码时，先交付 RTL 仿真结果 |

**接线。** ADV 的 EXT 14 针口 Pin 12 / GPIO13（TX）接对端 RX，Pin 14 / GPIO15（RX）接对端 TX，Pin 4 接公共地。两端分别供电，设置 115200、8N1、无流控。后续接 X10 时先查实板连接器和 I/O 电压。示例的四条 GPIO 约束均已注释，标注为 `LVCMOS18`。若实板为 1.8 V，两个收发方向分别使用支持推挽信号的 1.8 V ↔ 3.3 V 电平转换。[ADV 官方引脚表](https://docs.m5stack.com/zh_CN/core/Cardputer-Adv) · [X10 工程约束](https://github.com/alexforencich/verilog-ethernet/blob/77320a9471d19c7dd383914bc049e02d9f4f1ffb/example/ExaNIC_X10/fpga/fpga.xdc)

## 2. 六周实验与验收

| 学习周 | 动手顺序 | 验收与留存 |
| --- | --- | --- |
| 1 · 任务与周期 | Windows 配置 ESP-IDF，以 M5Stack 的 CardputerADV 示例指定的 v5.4.2 为起点。在学习固件的 `app_main()` 创建周期任务，每秒输出序号和板上时间戳，再让键盘与 LCD 显示按键 | 连续记录 60 次心跳，算出最短和最长间隔。能解释任务在两次心跳之间何时阻塞、何时就绪。保存版本、启动日志及一次按键记录 |
| 2 · UART 与单任务基线 | ADV 关闭本地回显，短接自身 TX/RX，发送 `abc123`。拆开短接再发一次。接 Windows 模拟器后，在同一应用循环中读串口、扫键、刷新 LCD，保存此版 | 自环时收到一次，断开后收到零次。运行本文第 4 节的递增序号实验，记录这版的漏行数和按键延迟，供第 3 周比较 |
| 3 · 阻塞与队列 | 将基线拆为串口、界面两个任务，用命令队列和结果队列传数据。串口使用有限等待，界面按周期刷新。用相同输入重跑基线 | 连查 `id` 100 次，核对 100 条有效回复。对照同负载下两版的序号缺口、按键延迟及队列积压，写明拆分任务解决了什么 |
| 4 · 优先级、缓冲与过载 | 保持输入速率，逐步增加绘屏耗时。再固定绘屏耗时，只改一个变量，如结果队列深度或串口任务优先级。记录 UART 溢出、队列投递失败和任务栈余量 | 找到一组稳定负载和一组能复现积压的负载。用计数器指出第一个瓶颈，在同负载下复测改动，保存前后数据 |
| 5 · 超时与恢复 | 模拟器支持正常回复、分段回复、未知命令和静默。ADV 每次只允许一条查询在途，超时后仍允许编辑和再次查询 | 分段回复只解析一次，未知命令显示 `ERR cmd`。停止模拟器后，500 ms 查询超时触发“未更新”。重新启动后手动查询成功，保存故障前后日志 |
| 6 · 与 FPGA 联调 | 先用自检 testbench 验证复位、`id` 和错误命令，再测 `stat`、`cnt`。取得合适实板后换下模拟器，用相同查询检查已知输入和超时恢复 | 分别记录模拟对端、RTL 仿真和实板的结果。实板首个里程碑是按键读出真实 build ID，再核对一次 FIFO 溢出状态和累计接收数 |

从 ESP-IDF 的 `hello_world` 学习工程开始，在已加载环境的 Windows 终端依次运行 `idf.py set-target esp32s3`、`idf.py build`、`idf.py -p COMx flash monitor`，将 `COMx` 替换为 ADV 的实际端口。屏幕和键盘初始化可参考厂商 ADV 分支。ESP-IDF 已启动调度器，在 `app_main()` 中创建应用任务即可。[M5Stack 出厂示例与工具链说明](https://github.com/m5stack/M5Cardputer-UserDemo/tree/CardputerADV) · [ESP-IDF FreeRTOS 指南](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/freertos.html)

## 3. 两个应用任务怎样分工

- **界面任务独占键盘和 LCD。** 按 `I`、`S`、`C` 分别投递 `id`、`stat`、`cnt`。按键采样可从 20 ms 起步，屏幕每 100 ms 合并刷新一次。命令入队失败时显示“忙”，并继续响应输入。
- **串口任务独占 UART。** 从命令队列取请求，写串口，读取驱动缓冲并按行解析。按项目规格识别 `SEQ` 日志与 `OK`、`ERR` 回复。每次有限等待后检查新请求和截止时间。先核对日志序号，再投递结果给界面，使屏幕来不及绘制时仍有接收证据。[ESP-IDF UART 驱动](https://docs.espressif.com/projects/esp-idf/en/v5.4.2/esp32s3/api-reference/peripherals/uart.html)
- **先用队列明确所有权。** 命令和回复按值传递，规定单行最大长度。超长行丢弃到下一换行并计数。界面只需最新的统计值时，可用长度为 1 的覆盖队列传快照。命令回复单独排队，避免刷新统计时覆盖用户正在等的回复。

## 4. 一项可以重复的验收实验

1. Windows 模拟器每秒发送 100 行，从 `SEQ 000000` 到 `SEQ 005999`，持续 60 秒，同时响应按键产生的 `id` 请求。结束时保存实际发送行数。没有外部对端时，板内发生器可验证解析、队列和界面，记录中标明注入位置。
2. 在 ADV 接收处记录有效日志行、首末序号、缺失与重复数、UART 溢出次数。在界面处另记队列投递失败数和最大积压。实验中按键至少 20 次，同一次按键从扫描识别到对应画面提交均用板上时钟计时。
3. 在单任务版与双任务版各跑一次。首轮目标为外部输入 6000 行、缺失 0、重复 0，按键到画面提交最大 150 ms。LCD 按周期合并显示。未达标时保留实测数字，调一个参数再跑。
4. `SEQ 000000` 加 LF 共 11 字节，8N1 每字节占 10 位。每秒 100 行的日志占单向 115200 bit/s 的约 9.5%。先测稳定负载，再固定绘屏耗时、逐档提高发送速率。分别记录硬件 FIFO 溢出（`UART_FIFO_OVF`）、驱动接收缓冲满（`UART_BUFFER_FULL`）和应用队列投递失败，注明第一个出现的事件与随后观测到的序号缺口。[ESP-IDF 5.4.2 UART 事件](https://docs.espressif.com/projects/esp-idf/en/v5.4.2/esp32s3/api-reference/peripherals/uart.html)

**每次留一行记录**，包含日期、Git 提交、对端类型、输入速率、刷新周期、发送/接收行数、序号缺口、最大积压、按键最大延迟与日志位置。第 4 周对照 [FPGA 侧 FIFO 的观测信号](fpga-uart-fifo.md)，说明 FPGA 的满标志和 ADV 驱动、任务队列的计数各由哪一端观察。

## 5. 按岗位补外设驱动或消息通信

**MCU 驱动。** 用 ADV 板上的 TCA8418 键盘控制器练一次手册到 C 接口的转换。参考芯片寄存器表和厂商实现，先通过 I²C 轮询读出待处理事件数及一次按下、释放，再让 GPIO 中断通知任务读取事件。给一个无应答地址发请求，记录错误码，随后恢复正确地址重测。有逻辑分析仪时，将总线地址和应答位与日志对齐。目标岗位明确要求 STM32 时，再在对应板型上用 USART 示例练轮询和中断。[TI 芯片手册](https://www.ti.com/lit/ds/symlink/tca8418.pdf) · [M5Stack 键盘驱动](https://github.com/m5stack/M5Cardputer/blob/master/src/utility/Keyboard/KeyboardReader/TCA8418.cpp) · [STM32CubeF4](https://github.com/STMicroelectronics/STM32CubeF4)

**机器人方向选修 micro-ROS。** 终端通过本地压测、X10 已接入 MAC 帧计数后，ADV 保留 UART 连接 FPGA，通过 Wi-Fi/UDP 向 Ubuntu 上的 Agent 发布 `/fpga/rx_frames`。用 `ros2 topic echo /fpga/rx_frames` 核对读数。停止 Agent 时，本地查询应继续可用，重启 Agent 后再验证话题恢复。[micro-ROS ESP-IDF 组件](https://github.com/micro-ROS/micro_ros_espidf_component)

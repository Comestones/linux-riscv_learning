ROSS AI / Vivado MCP test example: ExaNIC X10 10G Ethernet UDP echo

Test root: D:/Project/SELF/ROSS/vivado-mcp-demo
Purpose: a shared example for checking ROSS AI and Vivado MCP connectivity.
Completed checks below were performed through Codex -> Vivado MCP -> Vivado.
ROSS AI-specific calls have not been separately verified.

Start every new test session with vivado_start working_dir set to:
  D:/Project/SELF/ROSS/vivado-mcp-demo
This keeps .vivado-ai logs, .Xil caches and runtime files inside this folder.

Upstream: https://github.com/alexforencich/verilog-ethernet
Revision: 77320a9471d19c7dd383914bc049e02d9f4f1ffb
Example: example/ExaNIC_X10/fpga
License: upstream MIT; see verilog-ethernet/COPYING.
The upstream repository is deprecated in favor of fpganinja/taxi.

Target device: xcku035-fbva676-2-e (from the upstream Makefile).
Tool used: Vivado 2025.1.
Top module: fpga.
Function: Ethernet UDP echo server, default IP 192.168.1.128, UDP port 1234.

Open in Vivado:
  build/exanic_x10/exanic_x10.xpr
Then select RTL ANALYSIS > Open Elaborated Design to inspect hierarchy
and the RTL schematic. No FPGA board is needed for RTL inspection.

Recreate in an empty Vivado session when the build project does not exist:
  source D:/Project/SELF/ROSS/vivado-mcp-demo/create_project.tcl
The script refuses to overwrite an existing XPR or replace an open project.

MCP verification commands (execute sequentially with vivado_execute):
  synth_design -rtl -name rtl_1 -top fpga -part xcku035-fbva676-2-e
  source D:/Project/SELF/ROSS/vivado-mcp-demo/inspect_design.tcl

Windows adaptation:
  Source/constraint lists are read from the upstream Makefile.
  lib/eth directory symlink paths are resolved directly to the repository.
  The upstream GT Wizard Tcl generates the two transceiver IPs.
  GENERATE_SYNTH_CHECKPOINT=false uses generated IP RTL in the top design.
  Upstream source files are not modified.

Scope:
  This example checks MCP project creation, IP generation, RTL elaboration,
  hierarchy/port queries, and reports. It does not establish timing closure,
  a working bitstream, or successful hardware Ethernet traffic.
  Board pin constraints belong to ExaNIC X10, not an arbitrary FPGA board.

Verified on 2026-11-11 through Vivado MCP:
  43 upstream RTL files, 4 constraint files, 2 generated GT Wizard IPs.
  RTL elaboration succeeded (exit code 0), approximately 306 seconds.
  26 top-level port bits, 28,882 hierarchical cells, 0 black boxes.
  Elaboration reported 2,894 warnings, 0 critical warnings and 0 errors.
  Warnings have not all been reviewed for hardware readiness.
  Reports are in reports/mcp_inspection.txt, compile_order.rpt, ip_status.rpt.

Long MCP calls:
  This client's tools/call timed out after 300 seconds while RTL elaboration
  continued in Vivado. vivado_status subsequently confirmed completion with
  last_completed_code=0 and last_completed_elapsed=306.142.
  On a timeout, check vivado_status before retrying a command; do not queue
  another command on a session that is still executing.

Relocation:
  The test was moved under SELF/ROSS on 2026-11-11.
  Old logs and the initial compile_order.rpt retain original historical paths.
  compile_order_relocated.rpt and relocation_check.txt record the new paths.

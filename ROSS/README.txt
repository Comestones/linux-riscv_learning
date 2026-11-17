ROSS AI / Vivado MCP tests

Keep ROSS AI and Vivado MCP test files inside this directory.

vivado-mcp-demo/
  verilog-ethernet/     Upstream Git repository (unmodified)
  build/exanic_x10/     Generated Vivado project and IP files
  reports/             MCP verification results and reports
  .vivado-ai/           MCP session logs (including original test logs)
  .Xil/                Vivado cache
  create_project.tcl   Windows-compatible project creation script
  inspect_design.tcl   RTL hierarchy and IP report script
  README.txt           Setup, scope, and test results

Open:
  D:/Project/SELF/ROSS/vivado-mcp-demo/build/exanic_x10/exanic_x10.xpr

Use D:/Project/SELF/ROSS/vivado-mcp-demo as the working_dir for future
vivado_start calls. Do not use D:/Project/SELF as the test working directory.

Verified: Codex -> Vivado MCP -> Vivado 2025.1.
Reserved for further testing: ROSS AI-specific integration.

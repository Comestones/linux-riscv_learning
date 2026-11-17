# Run after opening the project and successfully elaborating RTL.
set demo_dir [file dirname [file normalize [info script]]]
set report_dir [file join $demo_dir reports]
file mkdir $report_dir
set report [open [file join $report_dir mcp_inspection.txt] w]
set details [list \
    "Vivado: [version -short]" \
    "Project: [current_project]" \
    "Part: [get_property PART [current_project]]" \
    "Top: [get_property TOP [get_filesets sources_1]]" \
    "Design: [current_design]" \
    "IP: [get_ips]" \
    "Constraints: [llength [get_files -of_objects [get_filesets constrs_1]]]" \
    "Port bits: [llength [get_ports]]" \
    "Hierarchical cells: [llength [get_cells -hierarchical]]" \
    "Black boxes: [llength [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]]" \
    "Ports: [get_ports]" \
    "Top-level cells: [get_cells]"]
foreach line $details {puts $report $line; puts $line}
close $report
report_compile_order -used_in synthesis -file [file join $report_dir compile_order.rpt]
report_ip_status -file [file join $report_dir ip_status.rpt]
puts "MCP_INSPECTION_SAVED: $report_dir"

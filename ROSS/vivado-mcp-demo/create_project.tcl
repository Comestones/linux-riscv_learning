# Recreate the upstream ExaNIC X10 example using native Vivado Tcl on Windows.
# Source manifest and device are taken from the upstream fpga/Makefile.
set demo_dir [file dirname [file normalize [info script]]]
cd $demo_dir
set repo_dir [file join $demo_dir verilog-ethernet]
set example_dir [file join $repo_dir example ExaNIC_X10 fpga]
set project_dir [file join $demo_dir build exanic_x10]
if {[llength [get_projects -quiet]] != 0} {
    error "An existing project is open; use an empty Vivado session."
}
if {[file exists [file join $project_dir exanic_x10.xpr]]} {
    error "Project already exists; open the existing XPR instead."
}
set fh [open [file join $example_dir fpga Makefile] r]
set manifest [read $fh]
close $fh
regexp -line {^FPGA_PART = (\S+)} $manifest -> part
create_project exanic_x10 $project_dir -part $part
set_property target_language Verilog [current_project]
set source_count 0
foreach line [split $manifest \n] {
    if {[regexp {^(SYN_FILES|XDC_FILES) \+?= (\S+)} $line -> kind rel]} {
        # Git's directory symlink lib/eth becomes a text file on Windows.
        # Point directly to its repository target without changing upstream files.
        if {[string match "lib/eth/*" $rel]} {
            set path [file join $repo_dir [string range $rel 8 end]]
        } else {
            set path [file join $example_dir $rel]
        }
        if {![file isfile $path]} {error "Missing upstream file: $path"}
        if {$kind eq "SYN_FILES"} {
            add_files -norecurse $path
            incr source_count
        } else {
            add_files -fileset constrs_1 -norecurse $path
        }
    }
}
set_property top fpga [get_filesets sources_1]
source [file join $example_dir ip eth_xcvr_gt.tcl]
# Use generated IP RTL in the top-level design, without requiring OOC DCPs.
set_property generate_synth_checkpoint false [get_files *.xci]
generate_target all [get_ips]
update_compile_order -fileset sources_1
puts "MCP_PROJECT_READY: part=$part rtl_files=$source_count ips=[get_ips]"

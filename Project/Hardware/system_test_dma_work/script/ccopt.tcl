update_constraint_mode -name CM -sdc_files ../script/APR_CTS.sdc
set_ccopt_property buffer_cells   { BUF1CK BUF2CK BUF3CK BUF4CK BUF6CK BUF8CK BUF12CK }
set_ccopt_property inverter_cells { INV1CK INV2CK INV3CK INV4CK INV6CK INV8CK INV12CK }
set_ccopt_property clock_gating_cells { GCKETN GCKETP GCKETT GCKETF }
set_ccopt_property use_inverters true
set_ccopt_property update_io_latency false
set_ccopt_property add_exclusion_drivers true
create_ccopt_clock_tree_spec
ccopt_design -cts


create_ip -name pcie3_ultrascale -vendor xilinx.com -library ip -module_name pcie3_ultrascale_0

set_property -dict [list \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
    CONFIG.AXISTEN_IF_RC_STRADDLE {true} \
    CONFIG.axisten_if_enable_client_tag {true} \
    CONFIG.axisten_if_width {256_bit} \
    CONFIG.extended_tag_field {true} \
    CONFIG.pf0_dev_cap_max_payload {1024_bytes} \
    CONFIG.axisten_freq {250} \
    CONFIG.PF0_CLASS_CODE {058000} \
    CONFIG.PF0_DEVICE_ID {0001} \
    CONFIG.PF0_SUBSYSTEM_ID {0003} \
    CONFIG.PF0_SUBSYSTEM_VENDOR_ID {1ce4} \
    CONFIG.pf0_bar0_64bit {true} \
    CONFIG.pf0_bar0_prefetchable {true} \
    CONFIG.pf0_bar0_scale {Megabytes} \
    CONFIG.pf0_bar0_size {16} \
    CONFIG.pf0_bar2_64bit {true} \
    CONFIG.pf0_bar2_prefetchable {true} \
    CONFIG.pf0_bar2_enabled {true} \
    CONFIG.pf0_bar2_type {Memory} \
    CONFIG.pf0_bar2_scale {Megabytes} \
    CONFIG.pf0_bar2_size {16} \
    CONFIG.pf0_bar4_64bit {true} \
    CONFIG.pf0_bar4_prefetchable {true} \
    CONFIG.pf0_bar4_enabled {true} \
    CONFIG.pf0_bar4_type {Memory} \
    CONFIG.pf0_bar4_scale {Kilobytes} \
    CONFIG.pf0_bar4_size {64} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.PF0_MSIX_CAP_TABLE_SIZE {01F} \
    CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_5:4} \
    CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00000000} \
    CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_5:4} \
    CONFIG.PF0_MSIX_CAP_PBA_OFFSET {00008000} \
    CONFIG.vendor_id {1234} \
] [get_ips pcie3_ultrascale_0]

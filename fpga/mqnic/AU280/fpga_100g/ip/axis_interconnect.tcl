create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_1
set_property -dict [list \
    CONFIG.Component_Name {axis_interconnect_1} \
    CONFIG.C_NUM_SI_SLOTS {2} \
    CONFIG.SWITCH_TDATA_NUM_BYTES {64} \
    CONFIG.HAS_TSTRB {false} \
    CONFIG.HAS_TID {false} \
    CONFIG.HAS_TDEST {false} \
    CONFIG.HAS_TUSER {true} \
    CONFIG.SWITCH_TUSER_BITS_PER_BYTE {16} \
    CONFIG.SWITCH_USE_ACLKEN {true} \
    CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {1} \
    CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} \
    CONFIG.M00_AXIS_TDATA_NUM_BYTES {64} \
    CONFIG.S00_AXIS_TDATA_NUM_BYTES {64} \
    CONFIG.S01_AXIS_TDATA_NUM_BYTES {64} \
    CONFIG.M00_S01_CONNECTIVITY {true}\
] [get_ips axis_interconnect_1]

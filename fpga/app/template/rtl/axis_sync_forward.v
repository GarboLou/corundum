`timescale 1ns / 1ps

/*
 * Versal PCIe CQ demultiplexer
 */
module axis_sync_forward #
(
    // Output count
    parameter M_COUNT = 2,
    parameter CL_M_COUNT = $clog2(M_COUNT),

    // PTP configuration
    parameter PTP_CLK_PERIOD_NS_NUM = 4,
    parameter PTP_CLK_PERIOD_NS_DENOM = 1,
    parameter PTP_TS_WIDTH = 96,
    parameter PTP_USE_SAMPLE_CLOCK = 0,
    parameter PTP_PORT_CDC_PIPELINE = 0,
    parameter PTP_PEROUT_ENABLE = 0,
    parameter PTP_PEROUT_COUNT = 1,

    // Interface configuration
    parameter PTP_TS_ENABLE = 1,
    parameter TX_TAG_WIDTH = 16,
    parameter MAX_TX_SIZE = 9214,
    parameter MAX_RX_SIZE = 9214,
    
    // Ethernet interface configuration (direct, async)
    parameter AXIS_DATA_WIDTH = 512,
    parameter AXIS_KEEP_WIDTH = AXIS_DATA_WIDTH/8,
    parameter AXIS_TX_USER_WIDTH = TX_TAG_WIDTH + 1,
    parameter AXIS_RX_USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1,
    parameter AXIS_RX_USE_READY = 0,

    // Ethernet interface configuration (direct, sync)
    parameter AXIS_SYNC_DATA_WIDTH = AXIS_DATA_WIDTH,
    parameter AXIS_SYNC_KEEP_WIDTH = AXIS_SYNC_DATA_WIDTH/8,
    parameter AXIS_SYNC_USER_WIDTH = 128,
    parameter AXIS_SYNC_TX_USER_WIDTH = AXIS_TX_USER_WIDTH,
    parameter AXIS_SYNC_RX_USER_WIDTH = AXIS_RX_USER_WIDTH
)
(
    input  wire                                       clk,
    input  wire                                       aresetn,

    /*
     * AXI input (sync)
     */
    input  wire [AXIS_SYNC_DATA_WIDTH-1:0]            s_axis_tdata,
    input  wire [AXIS_SYNC_KEEP_WIDTH-1:0]            s_axis_tkeep,
    input  wire                                       s_axis_tvalid,
    output wire                                       s_axis_tready,
    input  wire                                       s_axis_tlast,
    input  wire [AXIS_SYNC_USER_WIDTH-1:0]            s_axis_tuser,

    /*
     * AXI output (host)
     */
    output wire [AXIS_SYNC_DATA_WIDTH-1:0]    m_axis_tdata_host,
    output wire [AXIS_SYNC_KEEP_WIDTH-1:0]    m_axis_tkeep_host,
    output wire                               m_axis_tvalid_host,
    input  wire                               m_axis_tready_host,
    output wire                               m_axis_tlast_host,
    output wire [AXIS_SYNC_USER_WIDTH-1:0]    m_axis_tuser_host,

    /*
     * AXI output (forward)
     */
    output wire [AXIS_SYNC_DATA_WIDTH-1:0]    m_axis_tdata_fwd,
    output wire [AXIS_SYNC_KEEP_WIDTH-1:0]    m_axis_tkeep_fwd,
    output wire                               m_axis_tvalid_fwd,
    input  wire                               m_axis_tready_fwd,
    output wire                               m_axis_tlast_fwd,
    output wire [AXIS_SYNC_USER_WIDTH-1:0]    m_axis_tuser_fwd


    /*
     * Control
     */
    // input  wire [M_COUNT-1:0]                         select
);


reg [CL_M_COUNT-1:0] forward_reg = {CL_M_COUNT{1'b0}}, forward_ctl, forward_next;
reg frame_reg = 1'b0, frame_ctl, frame_next;

reg s_axis_tready_reg = 1'b0, s_axis_tready_next;


// internal datapath
reg  [AXIS_SYNC_DATA_WIDTH-1:0]     m_axis_tdata_int;
reg  [AXIS_SYNC_KEEP_WIDTH-1:0]     m_axis_tkeep_int;
reg  [M_COUNT-1:0]                  m_axis_tvalid_int;
reg                                 m_axis_tready_int_reg = 1'b0;
reg                                 m_axis_tlast_int;
reg  [AXIS_SYNC_USER_WIDTH-1:0]     m_axis_tuser_int;
wire                                m_axis_tready_int_early;

assign s_axis_tready = s_axis_tready_reg;

assign req_type =        s_axis_tdata[78:75];
assign target_function = s_axis_tdata[111:104];
assign bar_id =          s_axis_tdata[114:112];
assign msg_code =        s_axis_tdata[111:104];
assign msg_routing =     s_axis_tdata[114:112];

integer i;

always @* begin
    forward_next = forward_reg;
    forward_ctl = forward_reg;
    frame_next = frame_reg;
    frame_ctl = frame_reg;

    s_axis_tready_next = 1'b0;

    if (s_axis_tvalid && s_axis_tready) begin
        // end of frame detection
        if (s_axis_tlast) begin
            frame_next = 1'b0;
        end
    end

    if (!frame_reg && s_axis_tvalid && s_axis_tready) begin
        // start of frame, grab select value
        forward_ctl = 0;
        frame_ctl = 1'b1;

        // forward_ctl = 1 -> forward
        // forward_ctl = 0 -> to host
        if (s_axis_tdata[95:48] == 48'hea12d2f6ceb8) begin
            // dummy forwarding, sending back whatever packet from janux-06's MLNX BF-2
            forward_ctl = 1'b1;
        end
        else begin
            forward_ctl = 1'b0;
        end

        if (!(s_axis_tready && s_axis_tvalid && s_axis_tlast)) begin
            forward_next = forward_ctl;
            frame_next = 1'b1;
        end

    end

    s_axis_tready_next = m_axis_tready_int_early;

    // m_axis_tdata_int  = s_axis_tdata;
    m_axis_tdata_int  = (s_axis_tdata[95:48] == 48'hea12d2f6ceb8) ? {s_axis_tdata[511:336], 
                        s_axis_tdata[335:328] + 8'h2, 
                        s_axis_tdata[327:272], 
                        s_axis_tdata[239:208], 
                        s_axis_tdata[271:240], 
                        s_axis_tdata[207:200] + 8'h2, 
                        s_axis_tdata[199:96],
                        s_axis_tdata[47:0], 
                        s_axis_tdata[95:48]} : s_axis_tdata[511:0];
                        
    m_axis_tkeep_int  = s_axis_tkeep;
    m_axis_tvalid_int = (s_axis_tvalid && s_axis_tready && frame_ctl) << forward_ctl;
    m_axis_tlast_int  = s_axis_tlast;
    m_axis_tuser_int  = s_axis_tuser; 

end

always @(posedge clk) begin
    if (!aresetn) begin
        forward_reg <= 2'd0;
        frame_reg <= 1'b0;
        s_axis_tready_reg <= 1'b0;
    end else begin
        forward_reg <= forward_next;
        frame_reg <= frame_next;
        s_axis_tready_reg <= s_axis_tready_next;
    end
end

// output datapath logic
reg [AXIS_SYNC_DATA_WIDTH-1:0]    m_axis_tdata_reg  = {AXIS_SYNC_DATA_WIDTH{1'b0}};
reg [AXIS_SYNC_KEEP_WIDTH-1:0]    m_axis_tkeep_reg  = {AXIS_SYNC_KEEP_WIDTH{1'b0}};
reg [M_COUNT-1:0]                 m_axis_tvalid_reg = {M_COUNT{1'b0}}, m_axis_tvalid_next;
reg                               m_axis_tlast_reg  = 1'b0;
reg [AXIS_SYNC_USER_WIDTH-1:0] m_axis_tuser_reg  = {AXIS_SYNC_USER_WIDTH{1'b0}};

reg [AXIS_SYNC_DATA_WIDTH-1:0]    temp_m_axis_tdata_reg  = {AXIS_SYNC_DATA_WIDTH{1'b0}};
reg [AXIS_SYNC_KEEP_WIDTH-1:0]    temp_m_axis_tkeep_reg  = {AXIS_SYNC_KEEP_WIDTH{1'b0}};
reg [M_COUNT-1:0]                 temp_m_axis_tvalid_reg = {M_COUNT{1'b0}}, temp_m_axis_tvalid_next;
reg                               temp_m_axis_tlast_reg  = 1'b0;
reg [AXIS_SYNC_USER_WIDTH-1:0] temp_m_axis_tuser_reg  = {AXIS_SYNC_USER_WIDTH{1'b0}};

// datapath control
reg store_axis_int_to_output;
reg store_axis_int_to_temp;
reg store_axis_temp_to_output;

assign m_axis_tdata_host  = m_axis_tdata_reg;
assign m_axis_tkeep_host = m_axis_tkeep_reg;
assign m_axis_tvalid_host = m_axis_tvalid_reg[0];
assign m_axis_tlast_host  = m_axis_tlast_reg;
assign m_axis_tuser_host  = m_axis_tuser_reg;

assign m_axis_tdata_fwd  = m_axis_tdata_reg;
assign m_axis_tkeep_fwd = m_axis_tkeep_reg;
assign m_axis_tvalid_fwd = m_axis_tvalid_reg[1];
assign m_axis_tlast_fwd  = m_axis_tlast_reg;
assign m_axis_tuser_fwd  = m_axis_tuser_reg;

// enable ready input next cycle if output is ready or if both output registers are empty
assign m_axis_tready_int_early = ((m_axis_tready_fwd && m_axis_tvalid_fwd) || ( m_axis_tready_host && m_axis_tvalid_host)) || (!temp_m_axis_tvalid_reg && !m_axis_tvalid_reg);

always @* begin
    // transfer sink ready state to source
    m_axis_tvalid_next = m_axis_tvalid_reg;
    temp_m_axis_tvalid_next = temp_m_axis_tvalid_reg;

    store_axis_int_to_output = 1'b0;
    store_axis_int_to_temp = 1'b0;
    store_axis_temp_to_output = 1'b0;

    if (m_axis_tready_int_reg) begin
        // input is ready
        if (((m_axis_tready_fwd && m_axis_tvalid_fwd) || ( m_axis_tready_host && m_axis_tvalid_host)) || !(m_axis_tvalid_fwd || m_axis_tvalid_host)) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_output = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next = m_axis_tvalid_int;
            store_axis_int_to_temp = 1'b1;
        end
    end else if ((m_axis_tready_fwd && m_axis_tvalid_fwd) || ( m_axis_tready_host && m_axis_tvalid_host)) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next = temp_m_axis_tvalid_reg;
        temp_m_axis_tvalid_next = 1'b0;
        store_axis_temp_to_output = 1'b1;
    end
end

always @(posedge clk) begin
    m_axis_tvalid_reg <= m_axis_tvalid_next;
    m_axis_tready_int_reg <= m_axis_tready_int_early;
    temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;

    // datapath
    if (store_axis_int_to_output) begin
        m_axis_tdata_reg <= m_axis_tdata_int;
        m_axis_tkeep_reg <= m_axis_tkeep_int;
        m_axis_tlast_reg <= m_axis_tlast_int;
        m_axis_tuser_reg <= m_axis_tuser_int;
    end else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
    end

    if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= m_axis_tdata_int;
        temp_m_axis_tkeep_reg <= m_axis_tkeep_int;
        temp_m_axis_tlast_reg <= m_axis_tlast_int;
        temp_m_axis_tuser_reg <= m_axis_tuser_int;
    end

    if (!aresetn) begin
        m_axis_tvalid_reg <= {M_COUNT{1'b0}};
        m_axis_tready_int_reg <= 1'b0;
        temp_m_axis_tvalid_reg <= 1'b0;
    end
end

endmodule
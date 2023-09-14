/*

Copyright (c) 2014-2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FPGA top-level module
 */
module fpga (
    /*
     * Clock: 50MHz
     */
    input  wire       clk_50mhz,

    /*
     * Ethernet: SFP+
     */
    input  wire       sfp_1_rx_p,
    input  wire       sfp_1_rx_n,
    output wire       sfp_1_tx_p,
    output wire       sfp_1_tx_n,
    input  wire       sfp_mgt_refclk_p,
    input  wire       sfp_mgt_refclk_n,
    input  wire       sfp_1_los,
    output wire       sfp_1_tx_disable
);

// Clock and reset

wire clk_50mhz_ibufg;

// Internal 125 MHz clock
wire clk_125mhz_mmcm_out;
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 156.25 MHz clock
wire clk_156mhz_int;
wire rst_156mhz_int;

wire mmcm_rst = 1'b0;
wire mmcm_locked;
wire mmcm_clkfb;

IBUF clk_50mhz_ibuf_inst (
    .O    (clk_50mhz_ibufg),
    .I    (clk_50mhz)
);


// MMCM instance
// 50 MHz in, 125 MHz out
MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(8.000),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKFBOUT_MULT_F(20.000),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(20.000),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_50mhz_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_125mhz_mmcm_out),
    .CLKFBOUT(mmcm_clkfb),
    .LOCKED(mmcm_locked)
);

BUFG
clk_125mhz_bufg_inst (
    .I(clk_125mhz_mmcm_out),
    .O(clk_125mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~mmcm_locked),
    .out(rst_125mhz_int)
);

// XGMII 10G PHY

assign sfp_1_tx_disable = 1'b0;

wire        sfp_1_tx_clk_int = clk_156mhz_int;
wire        sfp_1_tx_rst_int = rst_156mhz_int;
wire [63:0] sfp_1_txd_int;
wire [7:0]  sfp_1_txc_int;
wire        sfp_1_rx_clk_int = clk_156mhz_int;
wire        sfp_1_rx_rst_int = rst_156mhz_int;
wire [63:0] sfp_1_rxd_int;
wire [7:0]  sfp_1_rxc_int;

wire sfp_reset_in;
wire sfp_txusrclk;
wire sfp_txusrclk2;
wire sfp_coreclk;
wire sfp_qplloutclk;
wire sfp_qplloutrefclk;
wire sfp_qplllock;
wire sfp_gttxreset;
wire sfp_gtrxreset;
wire sfp_txuserrdy;
wire sfp_areset_datapathclk;
wire sfp_resetdone;
wire sfp_reset_counter_done;

sync_reset #(
    .N(4)
)
sync_reset_sfp_inst (
    .clk(sfp_coreclk),
    .rst(rst_125mhz_int),
    .out(sfp_reset_in)
);

//assign sfp_reset_in = rst_125mhz_int || si5324_i2c_init_busy;

assign clk_156mhz_int = sfp_coreclk;

sync_reset #(
    .N(4)
)
sync_reset_156mhz_inst (
    .clk(clk_156mhz_int),
    .rst(!sfp_resetdone),
    .out(rst_156mhz_int)
);

wire [7:0] sfp_1_core_status;

wire [447:0] sfp_1_status_vector;

wire sfp_1_rx_block_lock = sfp_1_status_vector[256];


wire [535:0] sfp_config_vector;

assign sfp_config_vector[14:1]    = 0;
assign sfp_config_vector[79:17]   = 0;
assign sfp_config_vector[109:84]  = 0;
assign sfp_config_vector[175:170] = 0;
assign sfp_config_vector[239:234] = 0;
assign sfp_config_vector[269:246] = 0;
assign sfp_config_vector[511:272] = 0;
assign sfp_config_vector[515:513] = 0;
assign sfp_config_vector[517:517] = 0;
assign sfp_config_vector[0]       = 0; // pma_loopback;
assign sfp_config_vector[15]      = 0; // pma_reset;
assign sfp_config_vector[16]      = 0; // global_tx_disable;
assign sfp_config_vector[83:80]   = 0; // pma_vs_loopback;
assign sfp_config_vector[110]     = 0; // pcs_loopback;
assign sfp_config_vector[111]     = 0; // pcs_reset;
assign sfp_config_vector[169:112] = 0; // test_patt_a;
assign sfp_config_vector[233:176] = 0; // test_patt_b;
assign sfp_config_vector[240]     = 0; // data_patt_sel;
assign sfp_config_vector[241]     = 0; // test_patt_sel;
assign sfp_config_vector[242]     = 0; // rx_test_patt_en;
assign sfp_config_vector[243]     = 0; // tx_test_patt_en;
assign sfp_config_vector[244]     = 0; // prbs31_tx_en;
assign sfp_config_vector[245]     = 0; // prbs31_rx_en;
assign sfp_config_vector[271:270] = 0; // pcs_vs_loopback;
assign sfp_config_vector[512]     = 0; // set_pma_link_status;
assign sfp_config_vector[516]     = 0; // set_pcs_link_status;
assign sfp_config_vector[518]     = 0; // clear_pcs_status2;
assign sfp_config_vector[519]     = 0; // clear_test_patt_err_count;
assign sfp_config_vector[535:520] = 0;


ten_gig_eth_pcs_pma_0
sfp_1_pcs_pma_inst (
    .dclk(clk_125mhz_int),
    .rxrecclk_out(),
    .refclk_p(sfp_mgt_refclk_p),
    .refclk_n(sfp_mgt_refclk_n),
    .sim_speedup_control(1'b0),
    .coreclk_out(sfp_coreclk),
    .qplloutclk_out(sfp_qplloutclk),
    .qplloutrefclk_out(sfp_qplloutrefclk),
    .qplllock_out(sfp_qplllock),
    .txusrclk_out(sfp_txusrclk),
    .txusrclk2_out(sfp_txusrclk2),
    .areset_datapathclk_out(sfp_areset_datapathclk),
    .gttxreset_out(sfp_gttxreset),
    .gtrxreset_out(sfp_gtrxreset),
    .txuserrdy_out(sfp_txuserrdy),
    .reset_counter_done_out(sfp_reset_counter_done),
    .reset(sfp_reset_in),
    .xgmii_txd(sfp_1_txd_int),
    .xgmii_txc(sfp_1_txc_int),
    .xgmii_rxd(sfp_1_rxd_int),
    .xgmii_rxc(sfp_1_rxc_int),
    .txp(sfp_1_tx_p),
    .txn(sfp_1_tx_n),
    .rxp(sfp_1_rx_p),
    .rxn(sfp_1_rx_n),
    .configuration_vector(sfp_config_vector),
    .status_vector(sfp_1_status_vector),
    .core_status(sfp_1_core_status),
    .resetdone_out(sfp_resetdone),
    .signal_detect(1'b1),
    .tx_fault(1'b0),
    .drp_req(),
    .drp_gnt(1'b1),
    .drp_den_o(),
    .drp_dwe_o(),
    .drp_daddr_o(),
    .drp_di_o(),
    .drp_drdy_o(),
    .drp_drpdo_o(),
    .drp_den_i(1'b0),
    .drp_dwe_i(1'b0),
    .drp_daddr_i(16'd0),
    .drp_di_i(16'd0),
    .drp_drdy_i(1'b0),
    .drp_drpdo_i(16'd0),
    .pma_pmd_type(3'd0),
    .tx_disable()
);




fpga_core
core_inst (
    /*
     * Clock: 156.25 MHz
     * Synchronous reset
     */
    .clk(clk_156mhz_int),
    .rst(rst_156mhz_int),
    /*
     * Ethernet: SFP+
     */
    .sfp_1_tx_clk(sfp_1_tx_clk_int),
    .sfp_1_tx_rst(sfp_1_tx_rst_int),
    .sfp_1_txd(sfp_1_txd_int),
    .sfp_1_txc(sfp_1_txc_int),
    .sfp_1_rx_clk(sfp_1_rx_clk_int),
    .sfp_1_rx_rst(sfp_1_rx_rst_int),
    .sfp_1_rxd(sfp_1_rxd_int),
    .sfp_1_rxc(sfp_1_rxc_int)
);

/*
ila_0 ila_inst (
    .clk(sfp_coreclk),
    .probe0(sfp_1_core_status),
    .probe1({sfp_1_rx_rst_int, sfp_1_tx_rst_int, sfp_1_los, sfp_1_rx_block_lock, sfp_reset_counter_done}),
    .probe2({sfp_gttxreset, sfp_gtrxreset, rst_125mhz_int, mmcm_locked, sfp_resetdone, sfp_reset_in, sfp_qplllock, rst_156mhz_int})
);*/

endmodule

`resetall

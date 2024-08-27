module apb_interface(
input   clk,
input   rst_n,

input   pclk,
output  read_valid,
input   pwrite,
input   penable,
input   [31:0] paddr,
input   psel,
output  pready,
output  [31:0] prdata,

input   [31:0] prdata_valid,
input   read_done,
output  [23:0] paddr_valid

);

wire apb_negedge ;
wire apb_posedge ;

wire apb_last_clock ;

wire apb_addr_valid ;

assign apb_addr_valid = (paddr[31:24]==8'b0) ;

localparam IDLE = 2'b00 ;
localparam WAIT = 2'b01 ;
localparam BACK = 2'b10 ;
localparam KEEP = 2'b11 ;

wire [1:0] state ;
wire [1:0] next_state ;

assign next_state = (state==IDLE && read_valid && apb_addr_valid) ? WAIT :
                    (state==WAIT && read_done)  ? BACK :
                    (state==BACK && apb_posedge)? KEEP :
                    (state==KEEP && apb_negedge)? IDLE :
                    state ; 

Reg #(2,2'b00) inst_state (clk,rst_n,next_state,state,1'b1) ;

Reg #(1,1'b0) inst_apb_last_clock (clk,rst_n,pclk,apb_last_clock,1'b1) ;

assign apb_negedge = (apb_last_clock==1'b1) && (pclk==1'b0) ;

assign apb_posedge = (apb_last_clock==1'b0) && (pclk==1'b1) ;

assign read_valid  = apb_negedge && psel && !pwrite && penable && (state==IDLE) ;

Reg #(24,24'b0) inst_addr_valid (clk,rst_n,paddr[23:0],paddr_valid,read_valid) ;

Reg #(32,32'b0) inst_prdata (clk,rst_n,prdata_valid,prdata,read_done) ;

assign pready = (state==BACK) || (state==KEEP) ;

endmodule

module flash_interface #(DUMMY_NUMBER = 4'd15)(
input   clk,
input   rst_n,

input   flash_read_start,
input   [23:0]flash_addr,
output  [31:0] flash_data,
output  flash_read_end,

output  spi_clk,
output  spi_sel,
output  spi0,
input   spi1

);

localparam TX_COUNT_PUR = 5'd31 ;
localparam DUMMY_COUNT_PUR = DUMMY_NUMBER - 1'b1 ;
localparam DATA_COUNT_PUR = 5'd31 ;

wire [7:0]command ;

assign command = 8'h0b ;

wire spi_clk_next ;

assign spi_clk_next = (spi_sel == 1'b1) ? 1'b1 :
                        ~spi_clk ;

Reg #(1,1'b1) inst_spi_clk (clk,reset_n,spi_clk_next,spi_clk,1'b1) ;

assign spi_sel = (state == IDLE) ;

wire [4:0] cnt ;
wire [4:0] cnt_next ;

localparam IDLE = 2'b00 ; 
localparam TX   = 2'b01 ;
localparam DUMMY= 2'b10 ;
localparam DATA = 2'b11 ;

wire [1:0] state ;
wire [1:0] next_state ;

assign next_state = (state==IDLE && flash_read_start)   ? TX :
                    (state==TX   && cnt==TX_COUNT_PUR && spi_clk==1'b0)      ? DUMMY :
                    (state==DUMMY&& cnt==DUMMY_COUNT_PUR && spi_clk==1'b0)   ? DATA  :
                    (state==DATA && cnt==DATA_COUNT_PUR && spi_clk==1'b0)    ? IDLE  :
                    state ;

Reg #(2,2'b00) inst_state (clk,rst_n,next_state,state,1'b1) ;

assign cnt_next =   (state==DUMMY && cnt==DUMMY_COUNT_PUR) ? 5'b0 :
                    (state!=IDLE)       ?   cnt+1 :
                    cnt ;
                    

Reg #(5,5'b0) inst_cnt (clk,rst_n,cnt_next,cnt,spi_clk==1'b0) ;

wire [31:0] spi_tx ;

wire [31:0] spi_tx_next;

assign spi_tx_next =    (state==TX && cnt=='b0) ? {8'h0b,flash_addr} :
                        (state==TX) ? {spi_tx[30:0],1'b0} :
                        spi_tx ;


Reg #(32,32'b0) inst_spi_tx (clk,rst_n,spi_tx_next,spi_tx,spi_clk==1'b1) ;

assign spi0 = spi_tx[31] ;

Reg #(32,32'b0) inst_flash_data (clk,rst_n,{flash_data[30:0],spi1},flash_data,(state==DATA && spi_clk==1'b0)) ;

assign flash_read_end = ((state==DATA) && (next_state==IDLE)) ;

endmodule

module top{
input   clk,
input   rst_n,

input   pclk,
input   pwrite,
input   penable,
input   [31:0] paddr,
input   psel,
output  pready,
output  [31:0] prdata,

output  spi_clk,
output  spi_sel,
output  spi0,
input   spi1

};

wire read_valid ;

wire read_done ;

wire [23:0] flash_addr ;

wire [31:0] flash_data ;

apb_interface inst_apb_interface(
.clk            (clk),
.rst_n          (rst_n),

.pclk           (pclk),
.read_valid     (read_valid),
.pwrite         (pwrite),
.penable        (penable),
.paddr          (paddr),
.psel           (psel),
.pready         (pready),
.prdata         (prdata),

.prdata_valid   (flash_data),
.read_done      (read_done),
.paddr_valid    (flash_addr)

);


flash_interface inst_flash_interface(
.clk            (clk),
.rst_n          (rst_n),

.flash_read_start(read_valid),
.flash_addr     (flash_addr),
.flash_data     (flash_data),
.flash_read_end (read_done),

.spi_clk        (spi_clk),
.spi_sel        (spi_sel),
.spi0           (spi0),
.spi1           (spi1)

);

endmodule

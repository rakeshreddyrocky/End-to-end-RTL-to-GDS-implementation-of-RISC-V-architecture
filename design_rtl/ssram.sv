
module ssram #(
    parameter WIDTH = 32, ADDR_BITS = 16
  ) (
    input logic                  clk, rst,

    // input logic [ADDR_BITS-1:0]  address,
    input logic [31:0]           address,
    input logic [WIDTH-1:0]      write_data,
    input logic [(WIDTH/8)-1:0]  write_byte_enable,
    input logic                  write_enable,
    input logic                  read_enable,
    output logic [WIDTH-1:0]     read_data);

    logic [WIDTH-1:0] memory [1<<ADDR_BITS];

    genvar w;
  
    generate 
      for (w=0; w<WIDTH/8; w++) begin
        always @(posedge clk) begin
          if (rst) read_data[((w+1)*8-1)-:8] <= '0;
          else if (read_enable) read_data[((w+1)*8-1)-:8] <= memory[address][((w+1)*8-1)-:8];
        end

        always @(posedge clk) begin
          if (!rst & write_enable) begin
            if (write_byte_enable[w]) memory[address][((w+1)*8-1)-:8] <= write_data[((w+1)*8-1)-:8];
          end
        end
      end
    endgenerate
endmodule
    

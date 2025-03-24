
import opcodes::*;
import mem_oo_tb_pkg::*;

module top;

   parameter CLOCK_PERIOD = 4;
   parameter BROKEN       = 0;
   parameter TEST_NO      = 0;

   logic clk, rst;

   // DUT signals

   instruction_t instr;
   register_t    op1, op2, op3;
   register_t    result;
   logic         result_valid;

   logic [31:0]  address;
   logic         read_enable;
   logic [31:0]  read_data;
   logic         write_enable;
   logic [3:0]   byte_enables;
   logic [31:0]  write_data;
   logic         enable;

   initial begin
     clk = 1;
     forever clk = #(CLOCK_PERIOD/2) !clk;
   end

   initial begin
     rst = 0;
     rst = #(CLOCK_PERIOD/2) 1;
     rst = #(CLOCK_PERIOD*10) 0;
   end

   mem_if_i mem_if(clk, rst); 

   environment_c env = new(mem_if, .mem_test(TEST_NO));

   initial env.run();

   assign instr                = mem_if.instr;
   assign op1                  = mem_if.op1;
   assign op2                  = mem_if.op2;
   assign op3                  = mem_if.op3;
   assign enable               = mem_if.enable;
   assign mem_if.result        = result;
   assign mem_if.result_valid  = result_valid;

   assign mem_if.address       = address;
   assign mem_if.read_enable   = read_enable;
   assign mem_if.read_data     = read_data;
   assign mem_if.write_enable  = write_enable;
   assign mem_if.write_data    = write_data;
   assign mem_if.byte_enables  = byte_enables;

   always @(posedge clk) if (instr == EBREAK) $display("End of test signaled");
   memory_ctrl #(.random_errors(BROKEN))
    DUT(
     .clk                (clk),
     .rst                (rst),

     .instr              (instr),
     .op1                (op1),
     .op2                (op2),
     .op3                (op3),
     .enable             (enable),
     .result             (result),
     .result_valid       (result_valid),

     .address            (address),
     .read_enable        (read_enable),
     .read_data          (read_data),
     .read_ack           (1'b1),
     .write_enable       (write_enable),
     .write_byte_enable  (byte_enables),

     .write_data         (write_data),
     .write_ack          (1'b1));

  ssram MEM(
     .clk                (clk),
     .rst                (rst),

     .address            (address),
     .read_enable        (read_enable),
     .read_data          (read_data),
     .write_enable       (write_enable),
     .write_byte_enable  (byte_enables),
     .write_data         (write_data));

endmodule

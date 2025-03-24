
import opcodes::*;
import decoder_oo_tb_pkg::*;

module top;

   parameter CLOCK_PERIOD = 4;
   parameter BROKEN       = 0;
   parameter TEST_NO      = 0;

   logic clk, rst;

   // DUT signals

   instruction_t  instr;
   logic          enable;
   register_t     register_bank[32];

   register_t     op1, op2, op3;
   register_num_t rd;


   initial begin
     clk = 1;
     forever clk = #(CLOCK_PERIOD/2) !clk;
   end

   initial begin
     rst = 0;
     rst = #(CLOCK_PERIOD/2) 1;
     rst = #(CLOCK_PERIOD*10) 0;
   end

   decoder_if_i decoder_if(clk, rst); 

   environment_c env = new(decoder_if, .decoder_test(TEST_NO));

   genvar r;

   initial env.run();

   // inputs
   assign instr                = decoder_if.instr;
   assign enable               = decoder_if.enable;

   generate 
     for (r=0; r<32; r++) assign register_bank[r] = decoder_if.register_bank[r];
   endgenerate

   // outputs
   assign decoder_if.op1       = op1;
   assign decoder_if.op2       = op2;
   assign decoder_if.op3       = op3;
   assign decoder_if.rd        = rd;

   always @(posedge clk) if (instr == EBREAK) $display("End of test signaled");

   decoder #(.random_errors(BROKEN))
    DUT(
     .clk                (clk),
     .rst                (rst),

     .instr              (instr),
     .enable             (enable),
     .register_bank      (register_bank),
     .op1                (op1),
     .op2                (op2),
     .op3                (op3),
     .rd                 (rd));

endmodule

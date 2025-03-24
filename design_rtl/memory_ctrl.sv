
import opcodes::*;

module memory_ctrl #(
   parameter broken = "NONE"
 )(
   input logic          clk, rst,

   input wire instruction_t  instr,
   input register_t     op1, op2, op3,
   input logic          enable,
   output register_t    result,
   output logic         result_valid,

   output logic [31:0]  address,
   output logic         read_enable,
   input  logic [31:0]  read_data,
   input  logic         read_ack,
   output logic         write_enable,
   output logic [3:0]   write_byte_enable,
   output logic [31:0]  write_data,
   input  logic         write_ack);

   typedef enum logic[2:0] { ADDR_PHASE, DATA_PHASE, DONE } state_t;

   typedef logic unsigned [15:0]  unsigned_short;
   typedef logic signed   [15:0]  signed_short;
   typedef logic unsigned  [7:0]  unsigned_byte;
   typedef logic signed    [7:0]  signed_byte; 

   state_t state, next_state;
   logic read_op, write_op;
   logic read_instr, write_instr;
   logic sign_ex;
   logic [1:0] offset;
   logic [2:0] size;
   register_t wdata;
   register_t result_reg;

`ifndef SYNTHESIS
   function automatic register_t induce_errors(register_t data);
     if (broken == "MCU") begin
       if ($urandom_range(1,10)==7)   // 10% of the time flip a bit at random 
         return data ^ register_t'(32'h1 << $urandom_range(0,31));
     end 
     return(data);
   endfunction

   assign result = induce_errors(result_reg);
`else
   assign result = result_reg;
`endif

   always_ff @(posedge clk) 
     if (rst) state <= ADDR_PHASE; 
     else state <= next_state;

   always_comb begin
     case (state) 
       ADDR_PHASE : if (enable) next_state = DATA_PHASE; else next_state = ADDR_PHASE;
       DATA_PHASE : if ((read_op & read_ack) || (!read_op & write_ack)) next_state = DONE;
       DONE       : next_state = ADDR_PHASE;
     endcase
   end

   always_comb begin 
     if (rst) result_reg <= '0;
     else if ((state == DATA_PHASE) & (read_op & read_ack)) begin 
       if (sign_ex) begin
         if (size == 4) result_reg <= read_data;
         if (size == 2) result_reg <= signed_short'((read_data >> (8 * offset)) & 32'h0000FFFF);
         if (size == 1) result_reg <= signed_byte'((read_data >> (8 * offset)) & 32'h000000FF);
       end else begin
         if (size == 4) result_reg <= read_data;
         if (size == 2) result_reg <= unsigned_short'((read_data >> (8 * offset)) & 32'h0000FFFF);
         if (size == 1) result_reg <= unsigned_byte'((read_data >> (8 * offset)) & 32'h000000FF);
       end
     end
   end

   // assign result_valid = ((read_op & read_ack) || (write_op & write_ack)) & (state == DONE);
   assign result_valid = (read_op & read_ack) & (state == DATA_PHASE);
   assign read_enable = (read_op & (state == ADDR_PHASE));
   assign write_enable = (write_op & (state == ADDR_PHASE));
   assign write_byte_enable = (!write_op) ? '0 :
                              (size == 4) ? 4'hF :
                              (size == 2) ? 4'h3 << offset :
                              (size == 1) ? 4'h1 << offset : '0;


   assign write_data = (!write_op) ? '0 :
                       (size == 4) ? wdata :
                       (size == 2) ? (wdata & 32'h0000FFFF) << (offset * 8) :
                       (size == 1) ? (wdata & 32'h000000FF) << (offset * 8) : '0;

   always_comb begin
     if (rst) begin 
       size = '0;
       offset = '0;
       address = '0;
       read_op = 0;
       write_op = 0;
       wdata = '0;
     end else begin
       if (state == DONE) begin
         size = '0;
         offset = '0;
         address = '0;
         read_op = 0;
         write_op = 0;
         wdata = '0;
       end
       if (enable & is_memory_op(instr)) begin
       // $display("executing %s ", decode_instr(instr));
         address = (op1 + op2) >> 2;
         offset  = (op1 + op2) & 32'h00000003;
`ifndef SYNTHESIS
         wdata = induce_errors(op3);
`else
         wdata = op3;
`endif
         casez (instr) 
           M_LW   : begin  size = 4;  read_op  = 1; sign_ex = 0; end
           M_LH   : begin  size = 2;  read_op  = 1; sign_ex = 1; end
           M_LHU  : begin  size = 2;  read_op  = 1; sign_ex = 0; end
           M_LB   : begin  size = 1;  read_op  = 1; sign_ex = 1; end
           M_LBU  : begin  size = 1;  read_op  = 1; sign_ex = 0; end
           M_SW   : begin  size = 4;  write_op = 1; sign_ex = 0; end
           M_SH   : begin  size = 2;  write_op = 1; sign_ex = 0; end
           M_SB   : begin  size = 1;  write_op = 1; sign_ex = 0; end
         endcase
       end
     end
   end

   mnemonic_t opcode;
   assign opcode = opc_base(instr);

   covergroup mcu_cg @(posedge clk); 
     coverpoint opcode {
        bins instr[] = {LW, LH, LHU, LB, LBU, SW, SH, SB};
        // ignore_bins: others;
      }
      coverpoint result_reg {
        bins positive = { [1:$] };
        bins zero     = { 0 };
        bins negative = { [$:-1] };
      }
      cross opcode, result_reg;
   endgroup  

   covergroup mcu_halfword_cg @(posedge clk);
     coverpoint opcode {
        bins instr[] = {LH, LHU};
        //ignore_bins: others;
      }
      coverpoint result_reg {
        bins positive = { [1:$] };
        bins zero     = { 0 };
        bins negative = { [$:-1] };
      }
      coverpoint offset {
        bins offset[2] = {0, 2};
        ignore_bins misaligned = {1, 3};
      }
      cross opcode, result_reg, offset;
   endgroup  

   covergroup mcu_byte_cg @(posedge clk);
     coverpoint opcode {
        bins instr[] = {LB, LBU};
        //ignore_bins: others;
      }
      coverpoint result_reg {
        bins positive = { [1:$] };
        bins zero     = { 0 };
        bins negative = { [$:-1] };
      }
      coverpoint offset {
        bins offset[2] = {[0:3]};
      }
      cross opcode, result_reg, offset;
   endgroup  

   mcu_cg          mcu_cg_inst           = new();
   mcu_halfword_cg mcu_halfword_cg_inst  = new();
   mcu_byte_cg     mcu_byte_cg_inst      = new();

endmodule

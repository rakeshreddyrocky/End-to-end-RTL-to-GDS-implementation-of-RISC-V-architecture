import opcodes::*;

module riscv_rv32i #(
     parameter BROKEN="NONE"
  )(
   input  logic         clk, rst,

   // instruction memory interface

   output logic [31:0]  instruction_address,
   output logic         instruction_enable,
   input  var instruction_t instr,

   // data memory interface

   output logic [31:0]  data_address,
   output logic         data_read_enable,
   input  logic [31:0]  data_read_data,
   input  logic         data_read_rdy,
   output logic         data_write_enable,
   output logic [3:0]   data_write_byte_enable,
   output logic [31:0]  data_write_data,
   input  logic         data_write_rdy,
   
   // halt signal -- asserted on execution of EBREAK 

   output logic         halted);

   logic fetch, decode, execute, write_back;
   logic executed;

   typedef enum logic [2:0] {FETCH, DECODE, EXECUTE, WRITE_BACK, HALT} stage_t;

   stage_t state, next_state;

   register_t register_bank[32];
   register_t pc, op1, op2, op3;
   register_t alu_result, mcu_result, bcu_result, result;
   register_num_t rd;

   logic [5:0] i;

   assign instruction_address = pc;
   assign instruction_enable = fetch;
   assign halted = (execute & (instr == EBREAK)) ? 1 : 0;

   always_ff @(posedge clk) begin
     if (rst) state <= FETCH;
     else     state <= next_state;
   end

   always_comb begin
     case (state) 
       FETCH:    next_state = DECODE;
       DECODE:   next_state = EXECUTE;
       EXECUTE:  if (instr == EBREAK) next_state = HALT;
                 else                 next_state = WRITE_BACK;
       WRITE_BACK: if (data_read_rdy) next_state = FETCH;
       HALT:     next_state = HALT;
     endcase
   end

   assign fetch      = (state == FETCH)      ? 1 : 0;
   assign decode     = (state == DECODE)     ? 1 : 0;
   assign execute    = (state == EXECUTE)    ? 1 : 0;
   assign write_back = (state == WRITE_BACK) ? 1 : 0;

   decoder #(.broken(BROKEN)) u_decoder(
     .clk           (clk),
     .rst           (rst),
  
     .enable        (decode),
     .instr         (instr),
     .register_bank (register_bank),
     .op1           (op1),
     .op2           (op2),
     .op3           (op3),
     .rd            (rd)
   );

   alu #(.broken(BROKEN)) u_alu(
     .clk            (clk),
     .rst            (rst),
 
     .instr          (instr),
     .op1            (op1),
     .op2            (op2),
     .enable         (execute),
     .instr_exec     (executed),
     .result         (alu_result)
   );

   branch_unit #(.broken(BROKEN)) u_branch_unit(
     .clk            (clk),
     .rst            (rst),

     .instr          (instr),
     .op1            (op1),
     .op2            (op2),
     .op3            (op3),
     .enable         (execute),
     .pc_out         (pc),

     .ret_addr       (bcu_result)
   );
   
   memory_ctrl #(.broken(BROKEN)) u_memory_ctrl(
     .clk            (clk),
     .rst            (rst),

     .instr          (instr),
     .op1            (op1),
     .op2            (op2),
     .op3            (op3),
     .enable         (execute),
     .result         (mcu_result),
     .result_valid   (),

     .address        (data_address),
     .read_enable    (data_read_enable),
     .read_data      (data_read_data),
     .read_ack       (data_read_rdy),
     .write_enable   (data_write_enable),
     .write_byte_enable (data_write_byte_enable),
     .write_data     (data_write_data),
     .write_ack      (data_write_rdy)
   );

   always @(posedge clk) begin
     if (rst) begin
       for (i=0; i<32; i++) begin
         register_bank[i] <= '0;
       end
     end else begin
       if (write_back & (rd != 0)) begin
         register_bank[rd] <= result;
       end
     end
   end

   assign result = is_alu_op(instr)    ? alu_result :
                   is_memory_op(instr) ? mcu_result :
                   is_branch_op(instr) ? bcu_result : '0;

endmodule

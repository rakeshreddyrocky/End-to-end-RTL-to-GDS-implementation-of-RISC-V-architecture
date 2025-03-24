import opcodes::*;

module cpu_design #(parameter BROKEN = "NONE")
  (
    input logic clk, rst,
    output logic halted);

  logic [31:0] data_address;
  logic        data_write_enable;
  logic [3:0]  data_byte_enables;
  logic        data_write_ack = 1;
  logic [31:0] data_write_data;
  logic        data_read_enable;
  logic        data_read_ack = 1;
  logic [31:0] data_read_data;

  logic [31:0] code_address;
  logic        code_write_enable = 0;
  logic [3:0]  code_byte_enables = '0;
  logic        code_write_ack = 1;
  logic [31:0] code_write_data = '0;
  logic        code_read_enable;
  logic        code_read_ack = 1;
  logic [31:0] code_read_data;

  riscv_rv32i #(.BROKEN(BROKEN)) u_cpu(
    .clk         (clk),
    .rst         (rst),

    .instruction_address (code_address),
    .instruction_enable  (code_read_enable),
    .instr               (code_read_data),

    .data_address        (data_address),
    .data_read_enable    (data_read_enable),
    .data_read_data      (data_read_data),
    .data_read_rdy       (data_read_ack),
    .data_write_enable   (data_write_enable),
    .data_write_byte_enable (data_byte_enables),
    .data_write_data     (data_write_data),
    .data_write_rdy      (data_write_ack),
    .halted              (halted)
  );

  ssram u_code_memory(
    .clk                (clk),
    .rst                (rst),

    .address            (code_address >> 2),
    .write_data         (code_write_data),
    .write_byte_enable  (code_byte_enables),
    .write_enable       (code_write_enable),
    .read_enable        (code_read_enable),
    .read_data          (code_read_data)
  );

  ssram u_data_memory(
    .clk                (clk),
    .rst                (rst),

    .address            (data_address),
    .write_data         (data_write_data),
    .write_byte_enable  (data_byte_enables),
    .write_enable       (data_write_enable),
    .read_enable        (data_read_enable),
    .read_data          (data_read_data)
  );

endmodule

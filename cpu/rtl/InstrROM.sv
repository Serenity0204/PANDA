module InstrROM #(
    parameter ADDR_WIDTH  = 12,
    parameter INSTR_WIDTH = 9
) (
    input  logic [ ADDR_WIDTH-1:0] instr_addr,
    output logic [INSTR_WIDTH-1:0] instr_out
);

    // Depth = number of words in ROM
    localparam DEPTH = 1 << ADDR_WIDTH;
    // Declare ROM: DEPTH words, each INSTR_WIDTH bits wide
    logic [INSTR_WIDTH-1:0] inst_rom[0:DEPTH-1];

    // combinational read
    assign instr_out = inst_rom[instr_addr];

    // // load instruction from an external file(simulation)
    // initial begin
    //     $readmemb("machine_code.txt", inst_rom);
    // end
endmodule

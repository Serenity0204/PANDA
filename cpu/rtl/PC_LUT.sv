module PC_LUT #(
    parameter PC_WIDTH = 12
) (
    input logic [3:0] index,
    output logic [PC_WIDTH-1:0] next_pc
);
    localparam LUT_SIZE = 16;
    logic [PC_WIDTH-1:0] lut_mem[0:LUT_SIZE-1];

    // Combinational read
    assign next_pc = lut_mem[index];


    // // Initialize from external text file
    // initial begin
    //     // Each line in pc_lut.txt should contain one binary or hex value, e.g.:
    //     // 000000000011
    //     // 000000101100
    //     $readmemb("pc_lut.txt", lut_mem);
    // end
endmodule

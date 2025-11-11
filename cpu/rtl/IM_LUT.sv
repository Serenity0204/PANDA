module IM_LUT #(
    parameter DATA_PATH_WIDTH = 8
) (
    input  logic [                4:0] index,     // index from LOAD_IMM
    output logic [DATA_PATH_WIDTH-1:0] imm_value  // immediate value output
);

    localparam LUT_SIZE = 32;

    // 32-entry immediate lookup table
    logic [DATA_PATH_WIDTH-1:0] im_mem[0:LUT_SIZE-1];

    // Combinational read
    assign imm_value = im_mem[index];

    // Load from external file
    initial begin
        // File example (binary or hex): one immediate per line
        // 00001010  (10)
        // 11110000  (-16)
        $readmemb("im_lut.txt", im_mem);
    end

endmodule

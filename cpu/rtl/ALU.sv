import Definitions::*;

module ALU #(
    parameter DATA_PATH_WIDTH = 8
) (
    // Operands
    input logic [DATA_PATH_WIDTH-1:0] input_A,
    input logic [DATA_PATH_WIDTH-1:0] input_B,

    // Decoded control fields
    input logic [3:0] op,  // 4-bit opcode
    input logic shift_dir,  // 0 = left, 1 = right
    input logic shift_type,  // 0 = logical, 1 = arithmetic
    input logic is_dec,  // 0=INC, 1=DEC
    // Results / flags
    output logic [DATA_PATH_WIDTH-1:0] out,
    output logic LT,
    output logic GT,
    output logic EQ
);

    // For readable waveform labels
    op_mne_t op_mnemonic;

    // Signed internal operands
    logic signed [DATA_PATH_WIDTH-1:0] inA, inB;
    assign inA = $signed(input_A);
    assign inB = $signed(input_B);

    // ==========================================================
    // Main ALU logic
    // ==========================================================
    always_comb begin
        // Defaults
        out = '0;
        LT  = 1'b0;
        EQ  = 1'b0;
        GT  = 1'b0;

        case (op)

            // ==================================================
            // Arithmetic (signed 2’s complement)
            // ==================================================
            kADD: out = inA + inB;

            kINC_DEC: out = (is_dec) ? inA - 1 : inA + 1;
            kSUB: out = inA - inB;

            // ==================================================
            // Logical / Move
            // ==================================================
            kAND: out = inA & inB;
            kOR:  out = inA | inB;
            kXOR: out = inA ^ inB;
            kMOV: out = inB;

            // ==================================================
            // Compare (sets LT/EQ/GT)
            // ==================================================
            kCMP: begin
                if (inA == inB) EQ = 1'b1;
                else if (inA < inB) LT = 1'b1;
                else GT = 1'b1;
            end

            // ==================================================
            // SHIFT (4 variants: left/right × logical/arith)
            // ==================================================
            kSHIFT: begin
                if (shift_dir == kSHIFT_LEFT) begin
                    // ----- Left shift -----
                    // arithmetic and logical identical for left
                    out = {inA[DATA_PATH_WIDTH-2:0], 1'b0};
                end else begin
                    // ----- Right shift -----
                    if (shift_type == kARITHMETIC)
                        out = {
                            inA[DATA_PATH_WIDTH-1], inA[DATA_PATH_WIDTH-1:1]
                        };  // sign-extend
                    else out = {1'b0, inA[DATA_PATH_WIDTH-1:1]};  // logical
                end
            end

            // ==================================================
            // Default
            // ==================================================
            default: begin
                out = '0;
                LT  = 1'b0;
                EQ  = 1'b0;
                GT  = 1'b0;
            end
        endcase
    end

    // For readable waveform display
    always_comb op_mnemonic = op_mne_t'(op);

endmodule

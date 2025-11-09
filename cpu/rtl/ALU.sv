import Definitions::*;

module ALU #(
    parameter DATA_PATH_WIDTH = 8
) (
    // Operands
    input logic [DATA_PATH_WIDTH-1:0] input_A,
    input logic [DATA_PATH_WIDTH-1:0] input_B,
    // Decoded control fields
    input logic [3:0] op,  // 4-bit opcode
    input logic carry_in,  // carry flag or shift-in
    input logic shift_dir,  // 0 = left, 1 = right  (bit [7] of instruction)
    input logic shift_type,  // 0 = logical, 1 = arithmetic (bit [6] of instruction)
    // Results / flags
    output logic [DATA_PATH_WIDTH-1:0] out,
    output logic CARRY,
    output logic LT,
    output logic GT,
    output logic EQ
);

    // Readable waveform label
    op_mne_t op_mnemonic;

    // Temp variable with 1 extra bit for carry operations
    logic [DATA_PATH_WIDTH:0] temp;

    always_comb begin
        // Default values
        out   = '0;
        CARRY = 1'b0;
        LT    = 1'b0;
        EQ    = 1'b0;
        GT    = 1'b0;

        case (op)

            // ==========================================================
            // Arithmetic
            // ==========================================================
            kADD: begin
                temp  = input_A + input_B;
                out   = temp[DATA_PATH_WIDTH-1:0];
                CARRY = temp[DATA_PATH_WIDTH];  // carry-out
            end

            kADC: begin
                temp  = input_A + input_B + carry_in;
                out   = temp[DATA_PATH_WIDTH-1:0];
                CARRY = temp[DATA_PATH_WIDTH];  // carry-out (keep carry)
            end

            kSUB: begin
                temp = {1'b0, input_A} - {1'b0, input_B};
                out  = temp[DATA_PATH_WIDTH-1:0];
                // no CARRY update needed
            end

            // ==========================================================
            // Logical / Data-movement
            // ==========================================================
            kAND: out = input_A & input_B;
            kOR:  out = input_A | input_B;
            kXOR: out = input_A ^ input_B;
            kMOV: out = input_B;

            // ==========================================================
            // Comparison  (sets LT/EQ/GT flags only)
            // ==========================================================
            kCMP: begin
                if (input_A == input_B) EQ = 1'b1;
                else if (input_A < input_B) LT = 1'b1;
                else GT = 1'b1;
            end

            // ==========================================================
            // SHIFT  (handles all 4 variants)
            // ==========================================================
            kSHIFT: begin
                if (shift_dir == kSHIFT_LEFT) begin
                    // ---------- LEFT shift ----------
                    CARRY = input_A[DATA_PATH_WIDTH-1];  // bit shifted out
                    // left shift always logical in this ISA (arithmetic == logical)
                    out   = {input_A[DATA_PATH_WIDTH-2:0], carry_in};
                end else begin
                    // ---------- RIGHT shift ----------
                    CARRY = input_A[0];  // bit shifted out
                    if (shift_type == kARITHMETIC)
                        out = {
                            input_A[DATA_PATH_WIDTH-1],
                            input_A[DATA_PATH_WIDTH-1:1]
                        };  // arithmetic (sign-extend)
                    else out = {1'b0, input_A[DATA_PATH_WIDTH-1:1]};  // logical
                end
            end

            // ==========================================================
            // Default / unsupported opcodes
            // ==========================================================
            default: begin
                out   = '0;
                CARRY = 1'b0;
                LT    = 1'b0;
                EQ    = 1'b0;
                GT    = 1'b0;
            end
        endcase
    end

    // For symbolic waveform display
    always_comb op_mnemonic = op_mne_t'(op);

endmodule

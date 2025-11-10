import Definitions::*;

module Control (
    input  logic [8:0] instr_in,
    // --- Control signals ---
    output logic [3:0] alu_op,
    output logic       shift_dir,
    output logic       shift_type,
    output logic       is_dec,
    output logic       reg_wen,
    output logic       mem_wen,
    output logic       abs_branch_en,
    output logic       rel_branch_en,
    output logic [1:0] cond_sel,
    output logic [3:0] rel_branch_offset,
    output logic [3:0] abs_branch_LUT_index,
    output logic [4:0] imm_lut_index,
    output logic       load_imm_en,
    output logic       set_reg_en,
    output logic       halt_en,
    output logic       noop_en,
    output logic [1:0] rd_addr,
    output logic [1:0] rs_addr,
    output logic [1:0] dest_reg_idx,
    output logic [1:0] src_reg_idx,
    output logic       use_im_src
);

    logic [3:0] opcode;
    assign opcode = instr_in[8:5];


    always_comb begin
        // ---- defaults ----
        alu_op               = opcode;
        shift_dir            = 0;
        shift_type           = 0;
        reg_wen              = 0;
        mem_wen              = 0;
        abs_branch_en        = 0;
        rel_branch_en        = 0;
        cond_sel             = COND_NONE;
        rel_branch_offset    = 0;
        abs_branch_LUT_index = 0;
        load_imm_en          = 0;
        imm_lut_index        = 0;
        set_reg_en           = 0;
        halt_en              = 0;
        noop_en              = 0;
        rd_addr              = 0;
        rs_addr              = 0;
        use_im_src           = 0;
        is_dec               = 0;
        dest_reg_idx         = 0;
        src_reg_idx          = 0;

        unique case (opcode)
            // ---- R-type ----
            kADD, kSUB, kAND, kOR, kXOR, kMOV: begin
                reg_wen = 1;
                alu_op = opcode;
                rd_addr = instr_in[3:2];
                rs_addr = instr_in[1:0];
                use_im_src = instr_in[4];
            end

            kINC_DEC: begin
                reg_wen = 1;
                alu_op  = opcode;
                is_dec  = instr_in[4];
                rd_addr = instr_in[3:2];
            end
            // ---- CMP ----
            kCMP: begin
                reg_wen = 0;
                alu_op = opcode;
                rd_addr = instr_in[3:2];
                rs_addr = instr_in[1:0];
                use_im_src = instr_in[4];
            end

            // ---- SHIFT ----
            kSHIFT: begin
                reg_wen    = 1;
                alu_op     = kSHIFT;
                shift_dir  = instr_in[4];
                shift_type = instr_in[3];
                rd_addr    = instr_in[1:0];
            end

            // ---- Branches ----
            kBLT: begin
                cond_sel             = COND_LT;
                abs_branch_en        = (instr_in[4] == kABS_BRANCH);
                rel_branch_en        = (instr_in[4] == kREL_BRANCH);
                rel_branch_offset    = instr_in[3:0];
                abs_branch_LUT_index = instr_in[3:0];
            end
            kBGT: begin
                cond_sel             = COND_GT;
                abs_branch_en        = (instr_in[4] == kABS_BRANCH);
                rel_branch_en        = (instr_in[4] == kREL_BRANCH);
                rel_branch_offset    = instr_in[3:0];
                abs_branch_LUT_index = instr_in[3:0];
            end
            kBEQ: begin
                cond_sel             = COND_EQ;
                abs_branch_en        = (instr_in[4] == kABS_BRANCH);
                rel_branch_en        = (instr_in[4] == kREL_BRANCH);
                rel_branch_offset    = instr_in[3:0];
                abs_branch_LUT_index = instr_in[3:0];
            end

            // ---- MEM ----
            kLOAD: begin
                reg_wen = 1;
                alu_op = kLOAD;
                rd_addr = instr_in[3:2];
                rs_addr = instr_in[1:0];
                use_im_src = instr_in[4];
            end

            kSTORE: begin
                mem_wen = 1;
                alu_op = kSTORE;
                rd_addr = instr_in[3:2];
                rs_addr = instr_in[1:0];
                use_im_src = instr_in[4];
            end

            // ---- LOAD_IMM ----
            kLOAD_IMM: begin
                load_imm_en   = 1;
                imm_lut_index = instr_in[4:0];  // LOAD_IMM index field
            end

            // ---- FUNCTIONAL group ----
            kFUNC: begin
                if (instr_in[4] == 1'b0) begin
                    set_reg_en = 1;  // SET_REG
                    dest_reg_idx = instr_in[3:2];  // high 2 bits of 4-bit field
                    src_reg_idx = instr_in[1:0];  // low  2 bits of 4-bit field
                end else begin
                    // bit4 == 1 → HALT / NOOP detection
                    unique case (instr_in)
                        9'b1111_1_1111: halt_en = 1;
                        9'b1111_1_0000: noop_en = 1;
                    endcase
                end
            end

            default: ;
        endcase
    end

endmodule

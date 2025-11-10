import Definitions::*;

module Top (
    input  logic clk,
    input  logic reset,
    input  logic start,
    output logic done
);

    // ==============================================================
    // --- Parameters ------------------------------------------------
    // ==============================================================
    localparam DATA_PATH_WIDTH = 8;
    localparam ADDR_WIDTH = 8;
    localparam PC_WIDTH = 12;

    // ==============================================================
    // --- Special Registers for SET_REG ----------------------------
    // ==============================================================
    logic [1:0] SRC_REG_IDX;  // upper 2 bits of source register index
    logic [1:0] DEST_REG_IDX;  // upper 2 bits of destination register index
    logic [1:0] dest_reg_idx, src_reg_idx;
    logic [3:0] rd_final_addr;
    logic [3:0] rs_final_addr;

    assign rd_final_addr = {
        DEST_REG_IDX, rd_addr
    };  // DEST_REG_IDX * 4 + rd_addr
    assign rs_final_addr = {
        SRC_REG_IDX, rs_addr
    };  // SRC_REG_IDX  * 4 + rs_addr


    // ==============================================================
    // --- Internal Wires / Signals ---------------------------------
    // ==============================================================

    // Program counter
    logic [PC_WIDTH-1:0] current_pc;
    logic [PC_WIDTH-1:0] next_pc;

    // Instruction
    logic [8:0] instr;

    // Control signals
    logic [3:0] alu_op;
    logic shift_dir, shift_type, is_dec;
    logic reg_wen, mem_wen;
    logic abs_branch_en, rel_branch_en;
    logic [1:0] cond_sel;
    logic [3:0] rel_branch_offset, abs_branch_LUT_index;
    logic load_imm_en, set_reg_en, halt_en, noop_en;
    logic [1:0] rd_addr, rs_addr;
    logic use_im_src;

    // Datapath signals
    logic [DATA_PATH_WIDTH-1:0] regA, regB;
    logic [DATA_PATH_WIDTH-1:0] alu_out;
    logic [DATA_PATH_WIDTH-1:0] data_mem_read;

    // ===============================================
    // --- Flag Register (1-cycle latch for CMP flags)
    // ===============================================
    logic LT_reg, EQ_reg, GT_reg;
    logic LT, EQ, GT;



    // IM special register
    logic [DATA_PATH_WIDTH-1:0] IM;
    logic [DATA_PATH_WIDTH-1:0] imm_value;
    logic [                4:0] imm_lut_index;

    // Branch target (absolute)
    logic [       PC_WIDTH-1:0] LUT_target;

    // ==============================================================
    // --- Instruction Fetch ----------------------------------------
    // ==============================================================
    InstrROM #(
        .ADDR_WIDTH (PC_WIDTH),
        .INSTR_WIDTH(9)
    ) instr_rom (
        .instr_addr(current_pc),
        .instr_out (instr)
    );

    // ==============================================================
    // --- Control Decode -------------------------------------------
    // ==============================================================
    Control ctrl (
        .instr_in(instr),
        .alu_op(alu_op),
        .shift_dir(shift_dir),
        .shift_type(shift_type),
        .is_dec(is_dec),
        .reg_wen(reg_wen),
        .mem_wen(mem_wen),
        .abs_branch_en(abs_branch_en),
        .rel_branch_en(rel_branch_en),
        .cond_sel(cond_sel),
        .rel_branch_offset(rel_branch_offset),
        .abs_branch_LUT_index(abs_branch_LUT_index),
        .imm_lut_index(imm_lut_index),
        .load_imm_en(load_imm_en),
        .set_reg_en(set_reg_en),
        .halt_en(halt_en),
        .noop_en(noop_en),
        .rd_addr(rd_addr),
        .rs_addr(rs_addr),
        .dest_reg_idx(dest_reg_idx),
        .src_reg_idx(src_reg_idx),
        .use_im_src(use_im_src)
    );

    // ==============================================================
    // --- Immediate LUT --------------------------------------------
    // ==============================================================
    IM_LUT #(
        .DATA_PATH_WIDTH(DATA_PATH_WIDTH)
    ) imlut (
        .index(imm_lut_index),
        .imm_value(imm_value)
    );

    // ==============================================================
    // --- Register File --------------------------------------------
    // ==============================================================
    logic [DATA_PATH_WIDTH-1:0] wb_data;
    assign wb_data = (alu_op == kLOAD) ? data_mem_read : alu_out;

    RegFile #(
        .DATA_PATH_WIDTH(DATA_PATH_WIDTH),
        .ADDR_WIDTH(4)
    ) regfile (
        .clk(clk),
        .wen(reg_wen),
        .raddr_A(rd_final_addr),  // extended destination read
        .raddr_B(rs_final_addr),  // extended source read
        .waddr(rd_final_addr),  // extended destination write
        .data_in(wb_data),
        .data_out_A(regA),
        .data_out_B(regB)
    );


    // ==============================================================
    // --- Data Memory ----------------------------------------------
    // ==============================================================

    DataMem #(
        .DATA_PATH_WIDTH(DATA_PATH_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) datamem (
        .clk(clk),
        .wen(mem_wen),
        .read_addr(use_im_src ? IM[ADDR_WIDTH-1:0] : regB[ADDR_WIDTH-1:0]),
        .write_addr(regA),
        .data_mem_write(use_im_src ? IM : regB),
        .data_mem_read(data_mem_read)
    );

    // ==============================================================
    // --- ALU ------------------------------------------------------
    // ==============================================================
    ALU #(
        .DATA_PATH_WIDTH(DATA_PATH_WIDTH)
    ) alu (
        .input_A(regA),
        .input_B(use_im_src ? IM : regB),  // Distinguish IM vs RS
        .op(alu_op),
        .is_dec(is_dec),
        .shift_dir(shift_dir),
        .shift_type(shift_type),
        .out(alu_out),
        .LT(LT),
        .GT(GT),
        .EQ(EQ)
    );

    // ==============================================================
    // --- PC and Branching -----------------------------------------
    // ==============================================================
    PC #(
        .PC_WIDTH(PC_WIDTH)
    ) pc (
        .reset(reset),
        .start(start),
        .clk(clk),
        .EQ(EQ_reg),
        .LT(LT_reg),
        .GT(GT_reg),
        .cond_sel(cond_sel),
        .abs_branch_en(abs_branch_en),
        .rel_branch_en(rel_branch_en),
        .rel_branch_offset(rel_branch_offset),
        .next_pc(LUT_target),
        .current_pc(current_pc)
    );

    PC_LUT #(
        .PC_WIDTH(PC_WIDTH)
    ) pclut (
        .index  (abs_branch_LUT_index),
        .next_pc(LUT_target)
    );

    // ==============================================================
    // --- IM Register and Done Logic -------------------------------
    // ==============================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            IM <= '0;
            done <= 1'b0;
            LT_reg <= 1'b0;
            EQ_reg <= 1'b0;
            GT_reg <= 1'b0;
        end else if (halt_en) begin
            LT_reg <= 1'b0;
            EQ_reg <= 1'b0;
            GT_reg <= 1'b0;
            done   <= 1'b1;
        end else begin
            if (alu_op == kCMP) begin
                // Latch ALU flags when executing CMP
                LT_reg <= LT;
                EQ_reg <= EQ;
                GT_reg <= GT;
            end else begin
                // Auto-clear on the *next* instruction
                LT_reg <= 1'b0;
                EQ_reg <= 1'b0;
                GT_reg <= 1'b0;
            end

            // LOAD_IMMEDIATE
            if (load_imm_en) IM <= imm_value;
            // SET_REG
            if (set_reg_en) begin
                DEST_REG_IDX <= dest_reg_idx;  // high 2 bits of 4-bit field
                SRC_REG_IDX  <= src_reg_idx;  // low  2 bits of 4-bit field
            end else begin
                // Auto-clear after one instruction (spec requirement)
                DEST_REG_IDX <= 2'b00;
                SRC_REG_IDX  <= 2'b00;
            end
        end
    end

endmodule

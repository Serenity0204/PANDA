module PC #(
    parameter PC_WIDTH = 12
) (
    input logic reset,  // synchronbous reset, force PC to 0 
    input logic start, // begin next program in series (request issued by test bench)
    input logic clk,  // PC can change on pos edge only
    input logic EQ,  // EQ, LT, GT are registers set by the CMP 
    input logic LT,
    input logic GT,
    input logic [1:0] cond_sel,  // 00=don't branch, 01=EQ, 10=LT, 11=GT
    input logic abs_branch_en,
    input logic rel_branch_en,
    input logic [3:0] rel_branch_offset,  // it's a signed offset
    input logic [PC_WIDTH-1:0] next_pc,
    output logic [PC_WIDTH-1:0] current_pc
);
    logic do_branch;

    // Determine whether to branch based on condition code
    always_comb begin
        unique case (cond_sel)
            2'b01:   do_branch = EQ;  // branch if equal
            2'b10:   do_branch = LT;  // branch if less
            2'b11:   do_branch = GT;  // branch if greater
            default: do_branch = 1'b0;  // no branch
        endcase
    end

    // PC update logic
    always_ff @(posedge clk) begin
        if (reset) current_pc <= 0;
        else if (start)
            current_pc <= current_pc; // hold while start asserted; commence when released
        else if (do_branch && abs_branch_en)
            current_pc <= next_pc; // if can branch and abs mode, set PC to new addr
        else if (do_branch && rel_branch_en)
            current_pc <= current_pc + $signed(
                rel_branch_offset
            );  // if can branch and rel mode, PC = PC + offset
        else current_pc <= current_pc + 1;  // default increment
    end
endmodule

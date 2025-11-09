module RegFile #(
    parameter DATA_PATH_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (  // DATA_PATH_WIDTH = data path width (leave at 8); ADDR_WIDTH = address width(4 bits -> 16 registers)
    input logic clk,
    input logic wen,  // 1 = write, 0 = read-only
    input logic [ADDR_WIDTH-1:0] raddr_A,  // read address A
    input logic [ADDR_WIDTH-1:0] raddr_B,  // read address B
    input logic [ADDR_WIDTH-1:0] waddr,  // write address
    input logic signed [DATA_PATH_WIDTH-1:0] data_in,  // data to write
    output logic signed [DATA_PATH_WIDTH-1:0] data_out_A, // output from reading at address A
    output logic signed [DATA_PATH_WIDTH-1:0] data_out_B  // output from reading at address B
);

    // DATA_PATH_WIDTH bits wide for each register and 2**ADDR_WIDTH that many registers 	 
    logic signed [DATA_PATH_WIDTH-1:0] registers[2**ADDR_WIDTH];

    assign data_out_A = registers[raddr_A];
    assign data_out_B = registers[raddr_B];

    // sequential (clocked) writes 
    always_ff @(posedge clk) begin
        if (wen) begin
            registers[waddr] <= data_in;
        end
    end
endmodule

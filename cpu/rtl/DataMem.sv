module DataMem #(
    parameter DATA_PATH_WIDTH = 8,
    parameter ADDR_WIDTH = 8
) (
    input  logic                       clk,
    input  logic                       wen,      // 1 = write, 0 = read
    input  logic [     ADDR_WIDTH-1:0] addr,     // address to memory
    input  logic [DATA_PATH_WIDTH-1:0] data_in,  // data to write
    output logic [DATA_PATH_WIDTH-1:0] data_out  // data read
);

    // 256 x 8-bit memory (if ADDR_WIDTH = 8)
    logic [DATA_PATH_WIDTH-1:0] core[0:(2**ADDR_WIDTH)-1];

    // Asynchronous read
    assign data_out = core[addr];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (wen) core[addr] <= data_in;
    end

    // Optional preload
    // initial $readmemh("data_init.hex", core);

endmodule

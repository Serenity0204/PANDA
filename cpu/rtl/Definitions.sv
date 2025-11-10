package Definitions;

    // ==========================================================
    // 4-bit binary opcode constants
    // ==========================================================
    localparam logic [3:0] kADD = 4'b0000;
    localparam logic [3:0] kINC_DEC = 4'b0001;
    localparam logic [3:0] kSUB = 4'b0010;
    localparam logic [3:0] kAND = 4'b0011;
    localparam logic [3:0] kOR = 4'b0100;
    localparam logic [3:0] kXOR = 4'b0101;
    localparam logic [3:0] kMOV = 4'b0110;

    localparam logic [3:0] kBLT = 4'b0111;
    localparam logic [3:0] kBGT = 4'b1000;
    localparam logic [3:0] kBEQ = 4'b1001;

    localparam logic [3:0] kCMP = 4'b1010;
    localparam logic [3:0] kSHIFT = 4'b1011;

    localparam logic [3:0] kLOAD = 4'b1100;
    localparam logic [3:0] kSTORE = 4'b1101;
    localparam logic [3:0] kLOAD_IMM = 4'b1110;
    localparam logic [3:0] kFUNC = 4'b1111;


    // ==========================================================
    // Enumerated mnemonic type (readable + synthesizable)
    // ==========================================================
    typedef enum logic [3:0] {
        ADD = kADD,
        INC_DEC = kINC_DEC,
        SUB = kSUB,
        AND_ = kAND,
        OR_ = kOR,
        XOR_ = kXOR,
        MOV = kMOV,

        BLT = kBLT,
        BGT = kBGT,
        BEQ = kBEQ,

        CMP   = kCMP,
        SHIFT = kSHIFT,

        LOAD     = kLOAD,
        STORE    = kSTORE,
        LOAD_IMM = kLOAD_IMM,
        FUNC     = kFUNC
    } op_mne_t;


    // ==========================================================
    // Other control-bit definitions
    // ==========================================================
    // Branch mode bit
    const logic kREL_BRANCH = 1'b0;
    const logic kABS_BRANCH = 1'b1;

    // SHIFT control bits
    const logic kSHIFT_LEFT = 1'b0;
    const logic kSHIFT_RIGHT = 1'b1;
    const logic kLOGICAL = 1'b0;
    const logic kARITHMETIC = 1'b1;

    // Condition-select field (for PC, branch logic)
    typedef enum logic [1:0] {
        COND_NONE = 2'b00,  // no branch
        COND_EQ   = 2'b01,  // equal
        COND_LT   = 2'b10,  // less than
        COND_GT   = 2'b11   // greater than
    } cond_t;

endpackage : Definitions

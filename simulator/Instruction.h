#ifndef INSTRUCTION_H
#define INSTRUCTION_H

#include <stdint.h>
#define REG_FILE_SIZE 16
#define MEM_SIZE 256

typedef uint8_t Reg;

enum class OpCode : uint16_t
{
    ADD = 0,
    ADC,
    SUB,
    AND,
    OR,
    XOR,
    MOV,
    BLT,
    BGT,
    BEQ,
    CMP,
    SHIFT,
    LOAD,
    STORE,
    LOAD_IMMEDIATE,
    SET_REG,
};

enum class RegIndex
{
    R0 = 0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15,
};

struct Instruction
{
public:
    enum class Type
    {
        R = 0,
        B,
        CMP,
        SHIFT,
        MEM,
        IM,
        FUNCTIONAL
    };

    // tag to know which view is valid
    Type type;
    OpCode op;
    // R	4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs	ADD, ADC, SUB, AND, OR, XOR, MOV
    // B	4 bits opcode, 1 bit for choosing absolute branching or relative branching, 4 bit relative address/LUT index	BLT, BGT, BEQ
    // CMP	4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs.	CMP
    // SHIFT	4 bits opcode, 1 bit for choosing direction(left or right), 1 bit for choosing it's arithmetics or logical shift, 1 bit unused, 2 bit dest register	SHIFT
    // MEM	4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs	LOAD, STORE
    // IM	4 bits opcode, 5 bits for immediate	LOAD_IMMEDIATE
    // FUNCTIONAL	4 bits opcode, 1 bit unused, 2 bit for destination register indexing, 2 bit for source register indexing	SET_REG

    union
    {
        struct // R-format: ADD, SUB, etc.
        {
            uint16_t rs : 2;
            uint16_t rd : 2;
            uint16_t srcSel : 1; // 1 = use IM, 0 = use rs
            uint16_t opcode : 4;
        } R;

        struct // B-format: BLT, BEQ, etc.
        {
            uint16_t addr : 4;
            uint16_t absRel : 1;
            uint16_t opcode : 4;
        } B;

        struct // CMP-format
        {
            uint16_t rs : 2;
            uint16_t rd : 2;
            uint16_t srcSel : 1;
            uint16_t opcode : 4;
        } CMP;

        struct // SHIFT-format
        {
            uint16_t rd : 2;
            uint16_t unused : 1;
            uint16_t arith : 1;
            uint16_t dir : 1;
            uint16_t opcode : 4;
        } SHIFT;

        struct // MEM-format
        {
            uint16_t rs : 2;
            uint16_t rd : 2;
            uint16_t srcSel : 1;
            uint16_t opcode : 4;
        } MEM;

        struct // IM-format
        {
            uint16_t imm : 5;
            uint16_t opcode : 4;
        } IM;

        struct // FUNCTIONAL-format
        {
            uint16_t rs : 2;
            uint16_t rd : 2;
            uint16_t unused : 1;
            uint16_t opcode : 4;
        } FUNCTIONAL;

        uint16_t raw; // view the entire 9-bit word
    };
};

#endif

#include "Instruction.h"
#include "Simulator.h"
#include <bitset>
#include <iostream>

void printBinary(uint16_t value, int bits = 9)
{
    // print the lower 'bits' bits
    std::bitset<16> b(value);
    std::cout << b.to_string().substr(16 - bits) << std::endl;
}

int main()
{
    Instruction instr;

    // Example: ADD R1, R2
    instr.type = Instruction::Type::R;
    instr.R.opcode = static_cast<uint16_t>(OpCode::ADD);
    instr.R.rd = 1;
    instr.R.rs = 2;
    instr.R.srcSel = 0;

    std::cout << "R-format instruction in binary: ";
    printBinary(instr.raw);

    // Example: LOAD_IMMEDIATE with 5-bit immediate
    Instruction immInstr;
    immInstr.type = Instruction::Type::IM;
    immInstr.IM.opcode = static_cast<uint16_t>(OpCode::LOAD_IMMEDIATE);
    immInstr.IM.imm = 17; // 5-bit immediate

    std::cout << "IM-format instruction in binary: ";
    printBinary(immInstr.raw);

    return 0;
}

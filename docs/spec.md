# Spec

## Team Members

| Team Member | PID |
|-------------|-----|
| Yu-Heng Lin | A18502009 |
| Linfeng Zhang | A18519381 |

## Introduction
The name of this architecture is **PANDA**, stands for *pretty average, not-well designed architecture*. The main goal of this ISA is to provide a smooth and user-friendly programming experience when coding in the PANDA assembly. To achieve this, we designed a special encoding and instructions to provide a large number of registers, more than a typical program might require, to simplify register allocation for the programmer. Additionally, we introduced macro instructions that expand into lower-level instructions, improving usability and readability. The PANDA machine follows a load-store architecture, so users who are familiar with ARMS and MIPS can easily transition to PANDA.

## Architectural Overview
![Architecture Overview](img/architecture-overview.png)

## Machine Specification

### Instruction Formats
| TYPE | FORMAT | CORRESPONDING INSTRUCTIONS |
|------|--------|-----------------------------|
| RR/RI    | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs| ADD, ADDI, SUB, SUBI, AND, ANDI, XOR, XORI, MOV, MOVI |
| B    | 4 bits opcode, 1 bit for choosing absolute branching or relative branching, 4 bit address | blt, bgt, beq. |
| CMP    | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs. // CMP will compare the rd to rs/IM. If rd > rs/IM, then the | cmp |
| SHIFT  | 4 bits opcode, 1 bit for choosing direction(left or right), 1 bit for choosing it's arithmetics or logical shift, 1 bit unused, 2 bit dest register| shift |
| MEM    | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs| load, store|
| FUNCTIONAL  | 4 bits opcode,  5 bits for immediate/register indexing | load_immediate, set_reg |

### Operations
| NAME | TYPE | BIT BREAKDOWN | EXAMPLE | NOTES |
|------|------|---------------|---------|-------|
| and = logical and | R | 1 bit type (0), bits opcode (010), 1 bit funct (1), 1 bit operand register (X), 1 bit operand register (X), 2 bit destination register (XX) | `and R0, R1, R2 ⇔ 0_010_1_0_1_10` | After `and`, R2 holds result. Example only. |

## Internal Operands

| Register | Purpose | Notes |
|----------|---------|-------|
| R0       | General purpose | Example |
| R1       | General purpose | Example |
| ...      | ...             | ...     |

## Control Flow (Branches)
| Branch Type | Target Address Calculation | Max Distance | Notes |
|-------------|----------------------------|--------------|-------|
| beq         | PC-relative                | Example value | Example notes |
| bne         | PC-relative                | Example value | Example notes |
| jmp         | Absolute/PC-relative       | Example value | Handles long jumps |


## Addressing Modes
| Addressing Mode | Description | Example Instruction | Example Meaning |
|-----------------|-------------|----------------------|-----------------|
| Immediate       | Operand is given directly in the instruction | `addi R1, R0, #5` | Load constant 5 into R1 |
| Direct (Absolute) | Instruction specifies the memory address | `load R1, 100` | Load contents of memory[100] into R1 |
| Indirect        | Instruction specifies a register that holds the memory address | `load R1, (R2)` | Load contents of memory at address in R2 into R1 |
| Register        | Operand is in a register | `add R1, R2, R3` | R1 = R2 + R3 |
| Register Indirect + Offset | Uses base register plus offset | `load R1, 4(R2)` | R1 = memory[R2 + 4] |
| PC-relative     | Address is relative to current program counter (used in branches) | `beq R1, R2, label` | If R1==R2, branch to PC + offset(label) |

## Programmer’s Model [Lite]
| Concept | Description |
|---------|-------------|
| Programming Strategy | Describe how programmers should think about your machine. For example: "Load values into registers first, compute, then store results back to memory." |
| Memory Usage | Explain how often memory should be accessed vs. registers. Example: "Prefer registers for temporary values to reduce memory stalls." |
| Branching | Describe how programmers handle control flow. Example: "Use PC-relative branches for loops, and jump for function calls." |
| Instruction Set | Note if instructions are inspired by MIPS/ARM, or custom. |
| Restrictions | If you cannot directly copy MIPS/ARM ops, explain how you adapted. Example: "Instead of a dedicated `mul`, we provide a shift-and-add routine." |

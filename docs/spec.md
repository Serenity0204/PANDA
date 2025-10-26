# Spec

## Team Members

| Team Member | PID |
|-------------|-----|
| Yu-Heng Lin | A18502009 |
| Linfeng Zhang | A18519381 |

## Introduction
The name of this architecture is **PANDA**, stands for *pretty average, not-well designed architecture*. The main goal of this ISA is to provide a smooth and user-friendly programming experience when coding in the PANDA assembly. To achieve this, we designed a special encoding and instructions to provide a large number of registers(16 General Purpose Registers). Additionally, we introduced macro instructions that expand into lower-level instructions, improving usability and readability. The PANDA machine follows a load-store architecture, so users who are familiar with ARMS and MIPS can easily transition to PANDA.

## Architectural Overview
![Architecture Overview](img/architecture-overview.png)

## Machine Specification

### Instruction Formats
| TYPE | FORMAT | CORRESPONDING INSTRUCTIONS |
|------|--------|-----------------------------|
| R  | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs| ADD, ADC, SUB, AND, OR, XOR, MOV |
| B    | 4 bits opcode, 1 bit for choosing absolute branching or relative branching, 4 bit relative address/LUT index  | BLT, BGT, BEQ|
| CMP    |4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs. | CMP |
| SHIFT  | 4 bits opcode, 1 bit for choosing direction(left or right), 1 bit for choosing it's arithmetics or logical shift, 1 bit unused, 2 bit dest register| SHIFT |
| MEM    | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs| LOAD, STORE |
| IM  | 4 bits opcode,  5 bits for immediate| LOAD_IMMEDIATE|
| FUNCTIONAL  | 4 bits opcode,  1 bit unused, 2 bit for destination register indexing, 2 bit for source register indexing | SET_REG |

### Operations
|Instruction Number| NAME | TYPE | OP CODE | BIT BREAKDOWN | EXAMPLE | NOTES |
|------------------|------|------|---------|---------------|---------|-------|
|1| ADD = arithmetic add | R | 0000 | 4 bits opcode (0000), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx) | `ADD R0, R1 ⇔ 0000_0_00_01`, `ADD R0, IM ⇔ 0000_1_00_xx`| After `ADD`, `R0` holds result of `R0 + R1/R0 + IM` |
|2| ADC = arithmetic add with carry | R | 0001 | 4 bits opcode (0001), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx) | `ADC R0, R1 ⇔ 0001_0_00_01`, `ADC R0, IM ⇔ 0001_1_00_xx`| After `ADC`, `R0` holds result of `R0 + R1 + CARRY/R0 + IM + CARRY`|
|3| SUB = arithmetic sub | R | 0010 | 4 bits opcode (0010), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx) | `SUB R0, R1 ⇔ 0010_0_00_01`, `ADC R0, IM ⇔ 0010_1_00_xx`| After `SUB`, `R0` holds result of `R0 - R1/R0 - IM`|
|4| AND = logical and | R | 0011 | 4 bits opcode (0011), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx) | `AND R0, R1 ⇔ 0011_0_00_01`, `AND R0, IM ⇔ 0011_1_00_xx`| After `AND`, `R0` holds result of `R0 & R1/R0 & IM`|
|5| OR = logical or | R | 0100 | 4 bits opcode (0100), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx) | `OR R0, R1 ⇔ 0100_0_00_01`, `OR R0, IM ⇔ 0100_1_00_xx`| After `OR`, `R0` holds result of `R0 \| R1/R0 \| IM`|
|6| XOR = logical xor | R | 0101 | 4 bits opcode (0101), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx) | `XOR R0, R1 ⇔ 0101_0_00_01`, `OR R0, IM ⇔ 0100_1_00_xx`| After `XOR`, `R0` holds result of `R0 ^ R1/R0 ^ IM`|
|7| MOV = MOVE value from one reg to the other | R | 0110 | 4 bits opcode (0110), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx) | `MOV R0, R1 ⇔ 0110_0_00_01`, `MOV R0, IM ⇔ 0110_1_00_xx`| After `MOV`, `R0` holds result of `R1/IM`|
|8| BLT = branch if less than | B | 0111 | 4 bits opcode (0111), 1 bit for choosing relative branching(0) or absolute branching(1), 4 bits(xxxx) for the relative address/LUT index. If the LT register is set, the program counter(PC) will be set to either </br>1. relative branching: PC += instruction size * 2's comp of relative address</br> 2. absolute branching PC = LUT[index] | `BLT RELATIVE 4 ⇔ 0111_0_0100`, `BLT ABSOLUTE 12 ⇔ 0111_1_1100`| After `BLT`, `PC` will be updated to the value previously described|
|9| BGT = branch if greater than | B | 1000 | 4 bits opcode (1000), 1 bit for choosing relative branching(0) or absolute branching(1), 4 bits(xxxx) for the relative address/LUT index. If the GT register is set, the program counter(PC) will be set to either </br>1. relative branching: PC += instruction size * 2's comp of relative address</br> 2. absolute branching PC = LUT[index] | `BGT RELATIVE 4 ⇔ 1000_0_0100`, `BGT ABSOLUTE 12 ⇔ 1000_1_1100`| After `BGT`, `PC` will be updated to the value previously described|
|10| BEQ = branch if equal | B | 1001 | 4 bits opcode (1001), 1 bit for choosing relative branching(0) or absolute branching(1), 4 bits(xxxx) for the relative address/LUT index. If the EQ register is set, the program counter(PC) will be set to either </br>1. relative branching: PC += instruction size * 2's comp of relative address</br> 2. absolute branching PC = LUT[index] | `BEQ RELATIVE 4 ⇔ 1001_0_0100`, `BGT ABSOLUTE 12 ⇔ 1001_1_1100`| After `BEQ`, `PC` will be updated to the value previously described|
|11| CMP = compare | CMP | 1010 | 4 bits opcode (1010), 1 bit for choosing source register rs(0) or use the special register IM(1) as the source(rs will be ignored), 2 bit destination register rd(xx), 2 bit source register rs(xx). This instruction will compare the value of pairs (rd and rs) or (rd and IM) depending on the 5th bit, for simplification, we name the first operand A, and second operand B. There are 3 cases: </br> 1. A > B, then GT register will be set to 1 </br> 2. A < B, then LT register will be set to 1</br> 3. A == B, then EQ register will be set to 1| `CMP R0, R1 ⇔ 1010_0_00_01`, `ADD R0, IM ⇔ 1010_1_00_xx`| After `CMP`, At most one of the registers `LT`, `GT`, and `EQ` will be set to 1|


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


## Program Implementation
- Program 1 Pseudocode
```c
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint8_t max = 0;
uint8_t min = 0b11111111;

void hamming_distance()
{
    uint8_t num1 = 0b10101010;
    uint8_t num2 = 0b11111111;
    uint8_t num3 = 0b00000000;

    uint8_t arr[] = {num1, num2, num3};
    uint8_t size = 3;

    // find max
    for (int i = 0; i < size; i++)
    {
        for (int j = i + 1; j < size; j++)
        {
            uint8_t a = arr[i];
            uint8_t b = arr[j];

            uint8_t x = a ^ b;
            uint8_t distance = 0;

            while (1)
            {
                if (x == 0) break;
                distance = distance + (x & 1);
                x >>= 1;
            }
            if (distance > max) max = distance;
        }
    }

    // find min
    for (int i = 0; i < size; i++)
    {
        for (int j = i + 1; j < size; j++)
        {
            uint8_t a = arr[i];
            uint8_t b = arr[j];

            uint8_t x = a ^ b;
            uint8_t distance = 0;

            while (1)
            {
                if (x == 0) break;
                distance = distance + (x & 1);
                x >>= 1;
            }
            if (distance < min) min = distance;
        }
    }
}

int main()
{
    hamming_distance();
    printf("Hamming distance max is %u and Hamming distance min is %u", max, min);
    return 0;
}

```

- Program 2 Pseudocode
```c
#include <stdint.h>
#include <stdio.h>

typedef signed char int8;

void robertson_mul_2_num(int8 A, int8 B, int8* upper, int8* lower)
{
    int8 P = 0;   // accumulator (upper 8 bits)
    int8 Q = B;   // multiplier
    int8 Qm1 = 0; // Q-1, starts at 0

    for (int8 i = 0; i < 8; i++)
    {
        int8 Q0 = Q & 1; // current LSB of Q

        // Step 1: add/subtract depending on (Q0, Qm1)
        if (Q0 == 1 && Qm1 == 0)
        {
            // P = P - A
            P = P - A;
        }
        else if (Q0 == 0 && Qm1 == 1)
        {
            // P = P + A
            P = P + A;
        }

        // Step 2: arithmetic right shift of (P, Q, Qm1)
        int8 newQm1 = Q & 1; // save old Q0 before shift

        // Shift right Q, bring in P's LSB
        Q = (Q >> 1) & 0x7F; // logical shift for now
        if (P & 1)
        {
            Q |= 0x80; // bring P LSB into Q MSB if it was 1
        }

        // Arithmetic shift right P
        int8 signP = P & 0x80;
        P >>= 1;
        if (signP) P |= 0x80; // keep sign bit

        // Update Qm1
        Qm1 = newQm1;
    }

    *upper = P;
    *lower = Q;
}

int main()
{
    int8 a = -15;
    int8 b = -12;
    int8 hi, lo;
    robertson_mul_2_num(a, b, &hi, &lo);

    // Combine hi:lo into 16-bit just for display
    int16_t result = ((int16_t)hi << 8) | ((int8_t)lo);
    printf("%d * %d = %d (hi=%d, lo=%d)\n", a, b, result, hi, lo);

    return 0;
}

``` 

- Program 3 Pseudocode
```c
#include <stdint.h>
#include <stdio.h>

typedef signed char int8;

/*
 * Multiply signed A*B*C (each int8).
 * Result is 24-bit signed stored in (upper, mid, lower) all int8.
 *
 * Approach:
 * 1) m = A * B  using Booth 8x8 -> 16 bits (m_hi:m_lo)
 * 2) result = m * C using Booth with 16-bit multiplicand (m_hi:m_lo) and 8-bit multiplier C
 *    -> produce 24-bit result (p2:p1:p0)
 */
void mul3_signed_8x8x8(int8 A, int8 B, int8 C, int8* upper, int8* mid, int8* lower)
{
    // Step 1: A * B -> m_hi:m_lo (16-bit signed)
    int8 m_hi = 0, m_lo = 0;
    // Use Booth for 8x8 -> 16. We implement a compact version here directly:

    int8 P = 0;
    int8 Q = B;
    int8 Qm1 = 0;
    for (int i = 0; i < 8; i++)
    {
        int8 Q0 = Q & 1;
        if ((Q0 == 1) && (Qm1 == 0))
        {
            // P = P - A
            P = P - A;
        }
        else if ((Q0 == 0) && (Qm1 == 1))
        {
            // P = P + A
            P = P + A;
        }
        int8 newQm1 = Q & 1;
        // shift Q right, bring P LSB into Q MSB
        uint8_t qu = (uint8_t)Q;
        uint8_t pu = (uint8_t)P;
        qu = (qu >> 1) | ((pu & 1) ? 0x80 : 0x00);
        Q = (int8)qu;
        // arithmetic shift P right
        int8 signP = P & 0x80;
        P = (P >> 1);
        if (signP) P |= 0x80;
        Qm1 = newQm1;
    }
    m_hi = P;
    m_lo = Q;

    // Step 2: Multiply 16-bit (m_hi:m_lo) by C (8-bit) -> 24-bit (p2:p1:p0)
    // We'll perform Booth on multiplier C (8 iterations), with accumulator P = 16-bit (p_hi:p_lo)
    // The combined register layout is [P_hi(8) P_lo(8) Q(8) Q-1(1)] -> 25 bits; shifting is done across these bytes.
    int8 p_hi = 0; // top 8 bits of 24-bit accumulator (will become final upper)
    int8 p_lo = 0; // middle 8 bits of 24-bit accumulator
    Q = C;    // multiplier (low 8 bits of final product)
    Qm1 = 0;

    for (int i = 0; i < 8; i++)
    {
        int8 Q0 = Q & 1;
        if ((Q0 == 1) && (Qm1 == 0))
        {
            // P = P - M  (M is m_hi:m_lo)
            // Implement P = P - M as P + (~M + 1)
            // Step: compute ~M
            int8 inv_m_lo = ~m_lo;
            int8 inv_m_hi = ~m_hi;

            // add inv_m_lo + 1 to p_lo with carry propagation
            int sum_lo = (uint8_t)p_lo + (uint8_t)inv_m_lo + 1;
            p_lo = (int8)sum_lo;
            int carry = (sum_lo >> 8) & 1;

            int sum_hi = (uint8_t)p_hi + (uint8_t)inv_m_hi + carry;
            p_hi = (int8)sum_hi;
        }
        else if ((Q0 == 0) && (Qm1 == 1))
        {
            // P = P + M  (add m_lo into p_lo, m_hi into p_hi)
            int sum_lo = (uint8_t)p_lo + (uint8_t)m_lo;
            p_lo = (int8)sum_lo;
            int carry = (sum_lo >> 8) & 1;

            int sum_hi = (uint8_t)p_hi + (uint8_t)m_hi + carry;
            p_hi = (int8)sum_hi;
        }

        // Arithmetic right shift of (p_hi : p_lo : Q : Qm1)
        int8 newQm1 = Q & 1;

        // Shift Q right, bring p_lo LSB into Q MSB
        uint8_t qu = (uint8_t)Q;
        uint8_t plu = (uint8_t)p_lo;
        qu = (qu >> 1) | ((plu & 1) ? 0x80 : 0x00);
        Q = (int8)qu;

        // Shift p_lo right, bring p_hi LSB into p_lo MSB
        uint8_t phu = (uint8_t)p_hi;
        uint8_t new_p_lo = ((uint8_t)p_lo >> 1) | ((phu & 1) ? 0x80 : 0x00);
        p_lo = (int8)new_p_lo;

        // Arithmetic shift p_hi right (preserve sign)
        int8 signPH = p_hi & 0x80;
        p_hi = (p_hi >> 1);
        if (signPH) p_hi |= 0x80;

        Qm1 = newQm1;
    }

    // Final 24-bit product is (p_hi : p_lo : Q)
    *upper = p_hi;
    *mid = p_lo;
    *lower = Q;
}

/* small test harness (prints 24-bit signed result) */
int main(void)
{
    int8 A = -15;
    int8 B = 12;
    int8 C = -3;

    int8 up, mid, low;
    mul3_signed_8x8x8(A, B, C, &up, &mid, &low);

    // For printing combined signed 24-bit, do a manual combine into 32-bit int (only for display).
    int32_t signed24 = ((int32_t)(int8)up << 16) | ((uint32_t)(uint8_t)mid << 8) | (uint32_t)(uint8_t)low;
    // Sign-extend from 24 to 32 bits:
    if (signed24 & (1 << 23)) signed24 |= ~((1 << 24) - 1);

    printf("A=%d, B=%d, C=%d => product = %d (bytes: 0x%02X 0x%02X 0x%02X)\n",
           A, B, C, signed24, (uint8_t)up, (uint8_t)mid, (uint8_t)low);

    return 0;
}
```
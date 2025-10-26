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
| RR  | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs| ADD, ADC, SUB, AND, OR, XOR, MOV |
| B    | 4 bits opcode, 1 bit for choosing absolute branching or relative branching, 4 bit relative address/LUT index  | BLT, BGT, BEQ|
| CMP    | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs. | CMP |
| SHIFT  | 4 bits opcode, 1 bit for choosing direction(left or right), 1 bit for choosing it's arithmetics or logical shift, 1 bit unused, 2 bit dest register| SHIFT |
| MEM    | 4 bits opcode, 1 bit for choosing source register rs or use the special register IM as the source(rs will be ignored), 2 bit destination register rd, 2 bit source register rs| LOAD, STORE |
| IM  | 4 bits opcode,  5 bits for immediate| LOAD_IMMEDIATE|
| FUNCTIONAL  | 4 bits opcode,  1 bit unused, 2 bit for destination register indexing, 2 bit for source register indexing | SET_REG |

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
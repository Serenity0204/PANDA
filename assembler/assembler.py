import sys

OPCODE = {
    # --------------------------
    # R-TYPE (Arithmetic / Logic)
    # --------------------------
    "ADD": "0000",
    "INC": "0001",  # increment/decrement (mode bit decides INC vs DEC)
    "DEC": "0001",  # same opcode as INC
    "SUB": "0010",
    "AND": "0011",
    "OR": "0100",
    "XOR": "0101",
    "MOV": "0110",
    # --------------------------
    # BRANCH (B-TYPE)
    # --------------------------
    "BLT": "0111",
    "BGT": "1000",
    "BEQ": "1001",
    # --------------------------
    # CMP
    # --------------------------
    "CMP": "1010",
    # --------------------------
    # SHIFT
    # direction + logical/arith handled separately
    # --------------------------
    "SHIFT": "1011",
    # --------------------------
    # MEMORY OPS
    # --------------------------
    "LOAD": "1100",
    "STORE": "1101",
    # --------------------------
    # IMM / LUT
    # --------------------------
    "LOAD_IMMEDIATE": "1110",
    # --------------------------
    # FUNCTIONAL
    # --------------------------
    "SET_REG": "1111",
    "HALT": "1111",  # special full pattern, but opcode still 1111
    "NOOP": "1111",  # special full pattern, but opcode still 1111
}


def parse_immediate():
    pass


def parse_label():
    pass


def convert():
    pass


def main():
    print("PANDA Assembler🐼\n")


if __name__ == "__main__":
    main()

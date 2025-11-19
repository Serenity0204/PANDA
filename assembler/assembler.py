import sys
import re


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
    # BRANCH alias
    "BLT_RELATIVE": "0111",
    "BLT_ABSOLUTE": "0111",
    "BGT_RELATIVE": "1000",
    "BGT_ABSOLUTE": "1000",
    "BEQ_RELATIVE": "1001",
    "BEQ_ABSOLUTE": "1001",
    # --------------------------
    # CMP
    # --------------------------
    "CMP": "1010",
    # --------------------------
    # SHIFT
    # direction + logical/arith handled separately
    # --------------------------
    "SHIFT": "1011",
    # SHIFT alias
    "SHIFT_LEFT_LOGICAL": "1011",
    "SHIFT_RIGHT_LOGICAL": "1011",
    "SHIFT_LEFT_ARITHMETIC": "1011",
    "SHIFT_RIGHT_ARITHMETIC": "1011",
    # --------------------------
    # MEMORY OPS
    # --------------------------
    "LOAD": "1100",
    "STORE": "1101",
    # --------------------------
    # IMM
    # --------------------------
    "LOAD_IMMEDIATE": "1110",
    # --------------------------
    # FUNCTIONAL
    # --------------------------
    "SET_REG": "1111",
    "HALT": "1111",  # special full pattern, but opcode still 1111
    "NOOP": "1111",  # special full pattern, but opcode still 1111
}


def error(msg):
    print(f"\nERROR: {msg}\n")
    sys.exit(1)


# ============================================
# FIRST PASS — COLLECT LABELS
# ============================================


def collect_labels(lines):
    labels = {}
    pc = 0
    for line in lines:
        line = line.strip()
        # skipping the empty line
        if not line:
            continue
        # skipping comment
        is_comment = len(line) >= 1 and "#" in line and line[0:1] == "#"
        if is_comment:
            continue
        # skipping immediate
        is_immediate = len(line) >= 1 and "." in line and line[0:1] == "."
        if is_immediate:
            continue

        # check if it's label
        is_label = len(line) > 2 and ":" in line and line[0:2] == "@L"

        if is_label:
            name = line.split(":")[0].strip()
            labels[name] = pc
            continue
        # if valid instruction, increment PC
        if line:
            pc += 1
    return labels


def collect_immediates(lines):
    pattern = re.compile(r"(\.\w+)\s*->\s*(0x[0-9A-Fa-f]+)")

    # need 2 maps, one is index->immediate value, the other one is immediate name->index
    immediate_index_to_value = {}  # index->immediate value
    immediate_name_to_index = {}  # name->index
    index = 0
    for line in lines:
        line = line.strip()
        # skipping the empty line
        if not line:
            continue
        # skipping comment
        is_comment = len(line) >= 1 and "#" in line and line[0:1] == "#"
        if is_comment:
            continue

        # check if it's immediate
        is_immediate = len(line) >= 1 and "." in line and line[0:1] == "."
        if is_immediate:
            imm = pattern.search(line)
            if imm:
                name = imm.group(1)
                value = imm.group(2)
                int_value = int(value, 16)
                bin_value = format(int_value, "08b")
                immediate_name_to_index[name] = index
                immediate_index_to_value[index] = bin_value
                index += 1
    # first one is name->index, second one is index->value
    return immediate_name_to_index, immediate_index_to_value


# ============================================================
# Encoders (simple versions)
# ============================================================


def convert():
    pass


def main():
    print("PANDA Assembler🐼\n")


if __name__ == "__main__":
    main()

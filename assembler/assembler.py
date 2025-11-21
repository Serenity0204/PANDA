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

# Global Lookups
IMMEDIATE_INDEX_TO_VALUE = {}  # index->immediate value
IMMEDIATE_NAME_TO_INDEX = {}  # name->index
LABELS = {}  # labels


# ============================================
# HELPER FUNCTIONS
# ============================================
def error(msg):
    print(f"\nERROR: {msg}\n")
    sys.exit(1)


def reg_to_index(r):
    """Return 2-bit binary register index (R0-R3)."""
    r = r.upper()
    if r == "IM":
        return None
    if not r.startswith("R"):
        error(f"Invalid register + {r}")

    try:
        index = int(r[1:])
    except:
        error(f"Invalid register + {r}")

    if not (0 <= index <= 3):
        error(f"Register {r} out of range (R0-R3 only)")

    return f"{index:02b}"


# ============================================
# FIRST PASS — COLLECT LABELS and COLLECT IMMEDIATES
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


def encode_r_type(op, dest, src):
    opcode = OPCODE.get(op)
    if opcode is None:
        error(f"Invalid op:{op}")

    rd = reg_to_index(dest)
    if src.upper() == "IM":
        imm_bit = "1"
        rs = "00"
    else:
        imm_bit = "0"
        rs = reg_to_index(src)
    return opcode + imm_bit + rd + rs


def encode_inc_dec(op, dest):
    opcode = OPCODE.get(op)
    if opcode is None:
        error(f"Invalid op:{op}")

    rd = reg_to_index(dest)
    if op == "INC":
        mode = "0"
    else:
        mode = "1"
    return opcode + mode + rd + "00"


def encode_cmp(op, dest, src):
    opcode = OPCODE.get(op)
    if opcode is None:
        error(f"Invalid op:{op}")

    rd = reg_to_index(dest)
    if src.upper() == "IM":
        imm_bit = "1"
        rs = "00"
    else:
        imm_bit = "0"
        rs = reg_to_index(src)
    return opcode + imm_bit + rd + rs


def encode_shift(op, dest):
    opcode = OPCODE.get(op)
    if opcode is None:
        error(f"Invalid op:{op}")

    # op examples: SHIFT_LEFT_LOGICAL
    parts = op.split("_")
    direction = parts[1]
    mode = parts[2]
    dir_bit = "0" if direction.upper() == "LEFT" else "1"
    type_bit = "0" if mode.upper() == "LOGICAL" else "1"
    rd = reg_to_index(dest)
    unused = "0"
    return opcode + dir_bit + type_bit + unused + rd


def encode_branch(op, offset=None, label=None, LABELS=None):
    opcode = OPCODE.get(op)
    if opcode is None:
        error(f"Invalid op:{op}")

    # op examples: BLT_ABSOLUTE
    parts = op.split("_")
    mode = parts[1]
    mode_bit = "0" if mode.upper() == "RELATIVE" else "1"

    if mode.upper() == "RELATIVE":
        offset_int = int(offset)
        offset_bits = format(offset_int & 0b1111, "04b")
        return opcode + mode_bit + offset_bits
    else:
        if LABELS is None:
            error("Absolute branch missing label")
        # look up the label index
        index = LABELS.get(label)
        # convert index to 4 bits
        index_bits = format(index, "04b")
        return opcode + mode_bit + index_bits


def encode_load_imm(op, immediate, IMMEDIATE_NAME_TO_INDEX):
    opcode = OPCODE.get(op)
    if opcode is None:
        error(f"Invalid op:{op}")
    # look up the index of the immediate
    index = IMMEDIATE_NAME_TO_INDEX.get(immediate)
    if index is None:
        error(f"Invalid immediate:{immediate}")
    index_bits = format(index, "05b")
    return opcode + index_bits


def encode_functional(op, dest_ext=None, src_ext=None):
    opcode = OPCODE.get(op)
    if opcode.upper() is None:
        error(f"Invalid op:{op}")
    if op == "HALT":
        halt_suffix = "11111"
        return opcode + halt_suffix
    if op.upper() == "NOOP":
        noop_suffix = "10000"
        return opcode + noop_suffix

    if dest_ext is None or src_ext is None:
        error(f"SET_REG has not specified dest_ext and src_ext")

    dest_int = int(dest_ext)
    src_int = int(src_ext)
    dest_bits = format(dest_int, "02b")
    src_bits = format(src_int, "02b")
    choose_set_reg_bit = "0"
    return opcode + choose_set_reg_bit + dest_bits + src_bits


def convert():
    pass


1


def main():
    print("PANDA Assembler🐼\n")


if __name__ == "__main__":
    main()

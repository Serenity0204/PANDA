from assembler import (
    collect_labels,
    collect_immediates,
    encode_r_type,
    encode_inc_dec,
    encode_cmp,
    encode_shift,
    encode_branch,
    encode_load_imm,
    encode_functional,
)
import os

BASE_DIR = os.path.dirname(__file__)


def test_collect_labels1():
    # Test 1: single label
    lines = ["@Lstart:", "mov r0, r1"]
    assert collect_labels(lines) == {"@Lstart": 0}

    # Test 2: label with blank lines
    lines = ["", "@Lstart:", "", "add r0, r2"]
    assert collect_labels(lines) == {"@Lstart": 0}

    # Test 3: multiple labels
    lines = [
        "@Lone:",
        "mov r0, r1",
        "@Ltwo:",
        "add r1, r1",
        "sub r1, r1",
        "@Lthree:",
        "noop",
    ]
    expected = {
        "@Lone": 0,
        "@Ltwo": 1,
        "@Lthree": 3,
    }
    assert collect_labels(lines) == expected

    # Test 4: label and instruction on same line
    lines = ["@Lstart: mov r0, r1", "add r0, r0"]
    assert collect_labels(lines) == {"@Lstart": 0}

    # Test 5: no labels
    lines = [
        "MOV r0, r1",
        "ADD r0, r1",
        "SUB r1, r1",
    ]
    assert collect_labels(lines) == {}

    print("test_collect_labels1 passed")


def test_collect_labels2():
    filepath = os.path.join(BASE_DIR, "PANDA_ASM_MOCK", "collect_label.PANDA_ASM")
    # Read all lines from file
    with open(filepath, "r") as f:
        lines = f.readlines()

    result = collect_labels(lines)

    expected = {
        "@LStart": 0,
        "@LMid": 1,
        "@LEnd": 3,
        "@LDone": 5,
    }
    assert result == expected, f"Expected {expected}, got {result}"

    print("test_collect_labels2 passed")


def test_collect_immediates():
    filepath = os.path.join(BASE_DIR, "PANDA_ASM_MOCK", "collect_label.PANDA_ASM")
    # Read all lines from file
    with open(filepath, "r") as f:
        lines = f.readlines()

    # first one is name->index, second one is index->value
    res1, res2 = collect_immediates(lines)
    expected1 = {
        ".Zero": 0,
        ".One": 1,
        ".Two": 2,
        ".Three": 3,
        ".FF": 4,
    }
    expected2 = {
        0: "00000000",
        1: "00000001",
        2: "00000010",
        3: "00000011",
        4: "11111111",
    }
    assert res1 == expected1, f"Expected {expected1}, got {res1}"
    assert res2 == expected2, f"Expected {expected2}, got {res2}"
    print("test_collect_immediates passed")


def test_encode():
    ## R type
    # add
    assert encode_r_type("ADD", "R2", "R3") == "000001011"
    assert encode_r_type("ADD", "R0", "IM") == "000010000"
    # sub
    assert encode_r_type("SUB", "R2", "R3") == "001001011"
    assert encode_r_type("SUB", "R1", "IM") == "001010100"
    # and
    assert encode_r_type("AND", "R2", "R3") == "001101011"
    assert encode_r_type("AND", "R3", "IM") == "001111100"
    # or
    assert encode_r_type("OR", "R2", "R3") == "010001011"
    assert encode_r_type("OR", "R3", "IM") == "010011100"
    # xor
    assert encode_r_type("XOR", "R2", "R3") == "010101011"
    assert encode_r_type("XOR", "R3", "IM") == "010111100"
    # mov
    assert encode_r_type("MOV", "R2", "R3") == "011001011"
    assert encode_r_type("MOV", "R3", "IM") == "011011100"
    # inc/dec
    assert encode_inc_dec("INC", "R3") == "000101100"
    assert encode_inc_dec("DEC", "R3") == "000111100"
    ## CMP
    assert encode_cmp("CMP", "R0", "R1") == "101000001"
    assert encode_cmp("CMP", "R0", "IM") == "101010000"
    ## SHIFT
    assert encode_shift("SHIFT_LEFT_LOGICAL", "R2") == "101100010"
    assert encode_shift("SHIFT_RIGHT_LOGICAL", "R2") == "101110010"
    assert encode_shift("SHIFT_LEFT_ARITHMETIC", "R2") == "101101010"
    assert encode_shift("SHIFT_RIGHT_ARITHMETIC", "R2") == "101111010"
    ## BRANCH
    LABELS = {"@LPanda": 12}
    assert encode_branch("BLT_RELATIVE", offset=4) == "011100100"
    assert encode_branch("BLT_ABSOLUTE", label="@LPanda", LABELS=LABELS) == "011111100"
    ## LOAD_IMMEDIATE
    IMMEDIATE_NAME_TO_INDEX = {".IMM29": 29}
    assert (
        encode_load_imm(
            "LOAD_IMMEDIATE", ".IMM29", IMMEDIATE_NAME_TO_INDEX=IMMEDIATE_NAME_TO_INDEX
        )
        == "111011101"
    )
    ## FUNCTIONAL
    # set_reg
    assert encode_functional("SET_REG", "3", "2") == "111101110"
    # halt
    assert encode_functional("HALT") == "111111111"
    # noop
    assert encode_functional("NOOP") == "111110000"
    print("test_encode passed")


if __name__ == "__main__":
    test_collect_labels1()
    test_collect_labels2()
    test_collect_immediates()
    test_encode()
    print("Congrats! All Correct.")

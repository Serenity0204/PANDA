from assembler import collect_labels, collect_immediates
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


if __name__ == "__main__":
    test_collect_labels1()
    test_collect_labels2()
    test_collect_immediates()
    print("Congrats! All Correct.")

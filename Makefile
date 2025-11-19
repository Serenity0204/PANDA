PYTHON := python3

.PHONY: assemble

assemble:
	$(PYTHON) assembler/assembler.py $(ARGS)

test_assemble:
	$(PYTHON) assembler/assembler_test.py
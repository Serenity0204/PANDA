PYTHON := python3

.PHONY: assemble

assemble:
	$(PYTHON) assembler/assembler.py $(ARGS)

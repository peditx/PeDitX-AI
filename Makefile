.PHONY: install run

install:
	bash install.sh

run:
	PYTHONPATH=src python3 -m peditx_ai

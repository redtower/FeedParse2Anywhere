PREFIX=${HOME}/bin/fp2a

BINDIR=$(PREFIX)
RESOURCEDIR=$(PREFIX)

RESOURCES=README.md
BINARIES=fp2a.pl *.pm

all: help

help:
	@echo "Usage:"
	@echo
	@echo "make install                   # install to ${PREFIX}"
	@echo "make install PREFIX=~          # install to ~"
	@echo

install:
	install -d $(BINDIR) $(RESOURCEDIR)
	install -v $(BINARIES) $(BINDIR)
	install -v -m 644 $(RESOURCES) $(RESOURCEDIR)

.PHONY: all help install

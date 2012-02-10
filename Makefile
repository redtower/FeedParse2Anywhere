PREFIX=${HOME}/bin/fp2a

BINDIR=$(PREFIX)
RESOURCEDIR=$(PREFIX)

RESOURCES=README.md
BINARIES=fp2a.pl *.pm

VERSION=$(shell git describe 2>/dev/null || git rev-parse --short HEAD)
SEDVERSION=perl -pi -e 's/VERSION = 0/VERSION = "$(VERSION)"/' --

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
	$(SEDVERSION) $(BINDIR)/fp2a.pl

release:
	cp fp2a.pl fp2a.pl.tmp
	$(SEDVERSION) fp2a.pl.tmp
	tar --owner=0 --group=0 --transform 's!^!fp2a/!' --transform 's!fp2a.pl.tmp!fp2a.pl!' -zcf fp2a-$(VERSION).tar.gz fp2a.pl.tmp *.pm $(RESOURCES) Makefile
	$(RM) fp2a.pl.tmp

.PHONY: all help install release

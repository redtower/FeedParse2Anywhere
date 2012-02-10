TARGET=fp2a
PREFIX=${HOME}/bin/$(TARGET)

BINDIR=$(PREFIX)
RESOURCEDIR=$(PREFIX)

RESOURCES=README.md
BINARY=fp2a.pl
MODULES=*.pm
BINTMP=$(BINARY).tmp

VERSION=$(shell git describe 2>/dev/null || git rev-parse --short HEAD)
SEDVERSION=perl -pi -e 's/VERSION = 0/VERSION = "$(VERSION)"/' --

all: help

help:
	@echo "Usage:"
	@echo "     make install                   # install to ${PREFIX}"
	@echo "     make install PREFIX=~          # install to ~"
	@echo "     make release [VERSION=foo]     # make a release tarball"
	@echo "     make clean                     # rm tarball *.bak"
	@echo

install:
	install -d $(BINDIR) $(RESOURCEDIR)
	install -v $(BINARY) $(BINDIR)
	install -v $(MODULES) $(BINDIR)
	install -v -m 644 $(RESOURCES) $(RESOURCEDIR)
	$(SEDVERSION) $(BINDIR)/$(BINARY)

release:
	@cp $(BINARY) $(BINTMP)
	@$(SEDVERSION) $(BINTMP)
	@tar --owner=0 --group=0 --transform 's!^!$(TARGET)/!' --transform 's!$(BINTMP)!$(BINARY).pl!' -zcf $(TARGET)-$(VERSION).tar.gz $(BINTMP) $(MODULES) $(RESOURCES) Makefile
	@$(RM) $(BINTMP)

clean:
	$(RM) $(TARGET)-*.tar.gz *.bak

.PHONY: all help install release clean

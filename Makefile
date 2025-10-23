# Makefile for apt-mgr
PACKAGE=apt-mgr
VERSION=1.1.0
PREFIX=/usr
BINDIR=$(PREFIX)/bin
MANDIR=$(PREFIX)/share/man
DOCDIR=$(PREFIX)/share/doc/$(PACKAGE)
COMPLETIONDIR=$(PREFIX)/share/bash-completion/completions
ZSHCOMPLETIONDIR=$(PREFIX)/share/zsh/vendor-completions
ETCDIR=/etc
BUILDDIR=./build

all:
	@echo "Use 'make install' to install $(PACKAGE)"
	@echo "Use 'make deb' to build Debian package in $(BUILDDIR)/"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(MANDIR)/man1
	install -d $(DESTDIR)$(MANDIR)/man5
	install -d $(DESTDIR)$(COMPLETIONDIR)
	install -d $(DESTDIR)$(ZSHCOMPLETIONDIR)
	install -d $(DESTDIR)$(DOCDIR)
	install -d $(DESTDIR)$(ETCDIR)
	
	install -m 0755 apt-mgr $(DESTDIR)$(BINDIR)/
	install -m 0644 man/apt-mgr.1 $(DESTDIR)$(MANDIR)/man1/
	install -m 0644 man/apt-mgr.conf.5 $(DESTDIR)$(MANDIR)/man5/
	install -m 0644 completions/apt-mgr.bash $(DESTDIR)$(COMPLETIONDIR)/
	install -m 0644 completions/apt-mgr.zsh $(DESTDIR)$(ZSHCOMPLETIONDIR)/
	install -m 0644 etc/apt-mgr.conf $(DESTDIR)$(ETCDIR)/
	install -m 0644 LICENSE $(DESTDIR)$(DOCDIR)/
	install -m 0644 README.md $(DESTDIR)$(DOCDIR)/
	
	# Compress man pages
	gzip -9 $(DESTDIR)$(MANDIR)/man1/apt-mgr.1
	gzip -9 $(DESTDIR)$(MANDIR)/man5/apt-mgr.conf.5

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/apt-mgr
	rm -f $(DESTDIR)$(MANDIR)/man1/apt-mgr.1.gz
	rm -f $(DESTDIR)$(MANDIR)/man5/apt-mgr.conf.5.gz
	rm -f $(DESTDIR)$(COMPLETIONDIR)/apt-mgr.bash
	rm -f $(DESTDIR)$(ZSHCOMPLETIONDIR)/apt-mgr.zsh
	rm -f $(DESTDIR)$(ETCDIR)/apt-mgr.conf
	rm -rf $(DESTDIR)$(DOCDIR)/$(PACKAGE)

deb:
	@echo "Building Debian package in $(BUILDDIR)/..."
	mkdir -p $(BUILDDIR)
	dpkg-buildpackage -us -uc -b
	@echo "Moving build artifacts to $(BUILDDIR)/..."
	mv ../$(PACKAGE)_* $(BUILDDIR)/
	@echo "Build complete! Package files are in $(BUILDDIR)/"

clean:
	rm -rf $(BUILDDIR)
	dh_clean
	rm -f ../$(PACKAGE)_*

.PHONY: all install uninstall deb clean

# Makefile for pkgmgr
include project.conf

all:
	@echo "Use 'make install' to install $(PACKAGE_NAME)"
	@echo "Use 'make deb' to build Debian package in $(BUILDDIR)/"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(MANDIR)/man1
	install -d $(DESTDIR)$(MANDIR)/man5
	install -d $(DESTDIR)$(COMPLETIONDIR)
	install -d $(DESTDIR)$(ZSHCOMPLETIONDIR)
	install -d $(DESTDIR)$(DOCDIR)
	install -d $(DESTDIR)$(ETCDIR)
	
	install -m 0755 $(PACKAGE_NAME) $(DESTDIR)$(BINDIR)/
	install -m 0644 man/$(PACKAGE_NAME).1 $(DESTDIR)$(MANDIR)/man1/
	install -m 0644 man/$(PACKAGE_NAME).conf.5 $(DESTDIR)$(MANDIR)/man5/
	install -m 0644 completions/$(PACKAGE_NAME).bash $(DESTDIR)$(COMPLETIONDIR)/$(PACKAGE_NAME)
	install -m 0644 completions/$(PACKAGE_NAME).zsh $(DESTDIR)$(ZSHCOMPLETIONDIR)/_$(PACKAGE_NAME)
	install -m 0644 etc/$(PACKAGE_NAME).conf $(DESTDIR)$(ETCDIR)/
	install -m 0644 LICENSE $(DESTDIR)$(DOCDIR)/
	install -m 0644 README.md $(DESTDIR)$(DOCDIR)/
	
	# Compress man pages
	gzip -9 $(DESTDIR)$(MANDIR)/man1/$(PACKAGE_NAME).1
	gzip -9 $(DESTDIR)$(MANDIR)/man5/$(PACKAGE_NAME).conf.5

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(PACKAGE_NAME)
	rm -f $(DESTDIR)$(MANDIR)/man1/$(PACKAGE_NAME).1.gz
	rm -f $(DESTDIR)$(MANDIR)/man5/$(PACKAGE_NAME).conf.5.gz
	rm -f $(DESTDIR)$(COMPLETIONDIR)/$(PACKAGE_NAME)
	rm -f $(DESTDIR)$(ZSHCOMPLETIONDIR)/_$(PACKAGE_NAME)
	rm -f $(DESTDIR)$(ETCDIR)/$(PACKAGE_NAME).conf
	rm -rf $(DESTDIR)$(DOCDIR)/$(PACKAGE_NAME)

deb:
	@echo "Building Debian package $(PACKAGE_NAME)_$(PACKAGE_VERSION) in $(BUILDDIR)/..."
	mkdir -p $(BUILDDIR)
	dpkg-buildpackage -us -uc -b
	@echo "Moving build artifacts to $(BUILDDIR)/..."
	mv ../$(PACKAGE_NAME)_* $(BUILDDIR)/
	@echo "Build complete! Package files are in $(BUILDDIR)/"

clean:
	rm -rf $(BUILDDIR)
	dh_clean
	rm -f ../$(PACKAGE_NAME)_*

.PHONY: all install uninstall deb clean
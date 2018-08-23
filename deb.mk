# @package      hubzero-php
# @file         deb.mk
# @author       Nicholas J. Kisseberth <nkissebe@purdue.edu>
# @copyright    Copyright (c) 2010-2018 HUBzero Foundation, LLC.
# @license      http://opensource.org/licenses/MIT MIT
#
# Copyright (c) 2010-2018 HUBzero Foundation, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# HUBzero is a registered trademark of HUBzero Foundation, LLC.
#

DEB_MAJOR  := $(shell lsb_release -r -s | cut -d . -f 1)
PACKAGE    := $(shell dpkg-parsechangelog -lsource/debian/changelog | sed -n 's/^Source: //p')
VERSION    := $(shell dpkg-parsechangelog  -lsource/debian/changelog | sed -rne 's,^Version: ([0-9]+:)*([^-]+).*,\2,p')
DEBVERSION := $(shell dpkg-parsechangelog  -lsource/debian/changelog | sed -rne 's,^Version: ([0-9]+:)*(.*),\2,p')+deb$(DEB_MAJOR)
ARCH       := $(shell dpkg-architecture -qDEB_BUILD_ARCH)
MAKEFLAGS  := $(MAKEFLAGS) --no-print-directory

deb: $(PACKAGE)_$(VERSION).orig.tar.gz
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog
	sed -i -r -e "1s/\((.*)\)/(\1+deb$(DEB_MAJOR))/" source/debian/changelog
	m4 source/debian/control.m4 > source/debian/control
	(cd source; dpkg-buildpackage -i -sa -rfakeroot -kFF18CB2B)
	rm source/debian/control
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog
	lintian *$(DEBVERSION)*deb

debbin: $(PACKAGE)_$(VERSION).orig.tar.gz
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog
	sed -i -r -e "1s/\((.*)\)/(\1+deb$(DEB_MAJOR))/" source/debian/changelog
	m4 source/debian/control.m4 > source/debian/control
	(cd source; dpkg-buildpackage -i -B -rfakeroot -kFF18CB2B)
	rm source/debian/control
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog

debsrc: $(PACKAGE)_$(VERSION).orig.tar.gz
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog
	sed -i -r -e "1s/\((.*)\)/(\1+deb$(DEB_MAJOR))/" source/debian/changelog
	m4 source/debian/control.m4 > source/debian/control
	(cd source; dpkg-buildpackage -i -S -rfakeroot -kFF18CB2B)
	rm source/debian/control
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog

debclean:
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog
	sed -i -r -e "1s/\((.*)\)/(\1+deb$(DEB_MAJOR))/" source/debian/changelog
	m4 source/debian/control.m4 > source/debian/control
	(cd source; fakeroot debian/rules clean)
	rm source/debian/control
	sed -i -r -e "1s/\((.*)(\+deb(.*)\))/(\1)/" source/debian/changelog

debupload:
	dupload --nomail -f --to hubzero  $(PACKAGE)_$(DEBVERSION)_$(ARCH).changes

$(PACKAGE)_$(VERSION).orig.tar.gz:
	$(MAKE) debclean
	tar -zcvf $@ --exclude .git --exclude source/debian --exclude source/rpm --transform 's,^source,$(PACKAGE)-$(VERSION),' source
	chmod a-w $@

.PHONY: deb debbin debsrc debclean debupload

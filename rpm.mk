# @package      hubzero-php
# @file         rpm.mk
# @author       David R. Benham <dbenham@purdue.edu>
# @copyright    Copyright (c) 2013-2018 HUBzero Foundation, LLC.
# @license      http://opensource.org/licenses/MIT MIT
#
# Copyright (c) 2013-2018 HUBzero Foundation, LLC.
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

# Pass on commandline to make if needed ex "make rpmupload RPM=X"
# commandline args overwrite default below
RPM="rhel6/dev"

RPMDIR=/www/packages/rpm/$(RPM)
RPMNAME=$(shell basename $(RPMDIR))
RPMBASEPATH=$(shell dirname $(RPMDIR))
RPMREMOTEMACHINE=packages.hubzero.org
RPMDEST=$(RPMREMOTEMACHINE):$(RPMDIR)

# make sure there's only one spec file in this location
SPECFILE=$(shell ls source/rpm/rpmbuild/SPECS/*.spec)

PACKAGE=$(shell rpm -q --queryformat "%{NAME}" --specfile $(SPECFILE))
VERSION=$(shell rpm -q --queryformat "%{VERSION}" --specfile $(SPECFILE))
RELEASE=$(shell rpm -q --queryformat "%{RELEASE}" --specfile $(SPECFILE))
ARCH=$(shell rpm -q --queryformat "%{ARCH}" --specfile $(SPECFILE))
PWD=$(shell pwd)

default:
	@echo Package: $(PACKAGE)
	@echo Version: $(VERSION)
	@echo Release: $(RELEASE)
	@echo Arch: $(ARCH)
	@echo pwd: $(PWD)
	@echo Valid make targets are 'rpm', 'rpmupload', 'tarball'

	@echo
	@echo RPM info:
	@echo RPMDIR: $(RPMDIR)
	@echo RPMNAME: $(RPMNAME)
	@echo RPMBASEPATH: $(RPMBASEPATH)
	@echo RPMREMOTEMACHINE: $(RPMREMOTEMACHINE)
	@echo RPMDEST: $(RPMDEST)

rpmupload:
	rpm --addsign source/rpm/rpmbuild/RPMS/$(ARCH)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(ARCH).rpm
	scp source/rpm/rpmbuild/RPMS/$(ARCH)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(ARCH).rpm $(RPMDEST)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(ARCH).rpm
	ssh $(RPMREMOTEMACHINE) "cd $(RPMBASEPATH); createrepo $(RPMNAME); chmod 0755 $(RPMNAME)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(ARCH).rpm"

rpm: tarball
	rpmbuild -ba --define "_topdir $(PWD)/source/rpm/rpmbuild" $(PWD)/$(SPECFILE)

$(PACKAGE)-$(VERSION)-$(RELEASE).tar.gz:
	make clean
	tar -cvf $(PACKAGE)-$(VERSION)-$(RELEASE).tar --exclude=.git --exclude source/debian --exclude source/rpm --transform 's,^source,$(PACKAGE)-$(VERSION)-$(RELEASE),' source
	tar -rvf $(PACKAGE)-$(VERSION)-$(RELEASE).tar --transform 's,source/debian/copyright,$(PACKAGE)-$(VERSION)-$(RELEASE)/copyright,' source/debian/copyright
	gzip $(PACKAGE)-$(VERSION)-$(RELEASE).tar
	cp $(PACKAGE)-$(VERSION)-$(RELEASE).tar.gz source/rpm/rpmbuild/SOURCES

tarball: $(PACKAGE)-$(VERSION)-$(RELEASE).tar.gz

clean:
	rm -Rf source/rpm/rpmbuild/BUILD/*
	rm -Rf source/rpm/rpmbuild/BUILDROOT/*
	rm -Rf source/rpm/rpmbuild/RPMS/*
	rm -Rf source/rpm/rpmbuild/SOURCES/*
	rm -Rf source/rpm/rpmbuild/SRPMS/*
	rm -Rf source/rpm/rpmbuild/tmp/*
	rm -Rf *.tar.gz

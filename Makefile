XCODE = $(shell xcode-select -p)
VERSION = 2
LIBRARY_NAME = pam_touchid.so
DESTINATION = /usr/local/lib/pam
TARGET = x86_64-apple-macosx10.12

all:
	$(XCODE)/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc touchid-pam-extension.swift -o $(LIBRARY_NAME) -target $(TARGET) -emit-library -sdk $(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk

install: all
	mkdir -p $(DESTINATION)
	cp $(LIBRARY_NAME) $(DESTINATION)/$(LIBRARY_NAME).$(VERSION)
	chmod 444 $(DESTINATION)/$(LIBRARY_NAME).$(VERSION)
	chown root:wheel $(DESTINATION)/$(LIBRARY_NAME).$(VERSION)

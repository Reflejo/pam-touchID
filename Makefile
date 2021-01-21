VERSION = 2
LIBRARY_NAME = pam_touchid.so
DESTINATION = /usr/local/lib/pam
ARCH := $(shell uname -m)
ifeq ($(ARCH), arm64)
TARGET := arm64-apple-darwin20.1.0
else
TARGET := x86_64-apple-darwin20.1.0
endif

.PHONY: all

all: $(LIBRARY_NAME)

$(LIBRARY_NAME): touchid-pam-extension.swift
	swiftc touchid-pam-extension.swift -o $(LIBRARY_NAME) -target $(TARGET) -emit-library

install: $(LIBRARY_NAME)
	mkdir -p $(DESTINATION)
	install -b -o root -g wheel -m 444 $(LIBRARY_NAME) $(DESTINATION)/$(LIBRARY_NAME).$(VERSION)

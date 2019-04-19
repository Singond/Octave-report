SOURCES := $(shell find src -type f)
VERSION := 0.2.0
PKG_NAME := report

.PHONY: dist clean

dist: ${SOURCES} makefile
	mkdir -p build/pkg-tmp/${PKG_NAME}/inst
	cp -r src/octave/* build/pkg-tmp/${PKG_NAME}/inst
	cp -r src/meta/* build/pkg-tmp/${PKG_NAME}
	sed -i "s/VAR_VERSION/${VERSION}/" build/pkg-tmp/${PKG_NAME}/DESCRIPTION
	cd build && tar -C pkg-tmp -zcf ${PKG_NAME}-${VERSION}.tar.gz .

clean:
	rm -rf build/

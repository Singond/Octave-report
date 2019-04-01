SOURCES := $(shell find src -type f)
VERSION := 0.1.0
PKG_NAME := gnuplotter

.PHONY: dist clean

dist: ${SOURCES} makefile
	mkdir -p build/pkg-tmp/${PKG_NAME}/inst
	cp -r src/octave/* build/pkg-tmp/${PKG_NAME}/inst
	cp -r src/meta/* build/pkg-tmp/${PKG_NAME}
	cd build && tar -C pkg-tmp -zcvf ${PKG_NAME}-${VERSION}.tar.gz .

clean:
	rm -rf build/

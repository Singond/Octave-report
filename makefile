VERSION := 0.4.1
NAME := report

DIST_NAME   := ${NAME}-${VERSION}.tar.gz
DIST_TMPDIR := build/pkg/${NAME}

SOURCES := $(shell find src -type f)
FILES_OCTAVE := $(patsubst src/octave/%,${DIST_TMPDIR}/inst/%,$(shell find src/octave -type f))
FILES_META   := $(patsubst src/meta/%,${DIST_TMPDIR}/%,$(shell find src/meta -type f))

.PHONY: dist clean

dist: build/${DIST_NAME}

build/${DIST_NAME}: ${FILES_OCTAVE} ${FILES_META}
	@echo "Packaging for distribution..."
	cd build && tar -C pkg -zcf ${DIST_NAME} .

${FILES_OCTAVE}: ${DIST_TMPDIR}/inst/%: src/octave/%
	@mkdir -p $(dir $@)
	cp $< $@

$(filter-out %/DESCRIPTION,${FILES_META}): ${DIST_TMPDIR}/%: src/meta/%
	@mkdir -p $(dir $@)
	cp $< $@

${DIST_TMPDIR}/DESCRIPTION: src/meta/DESCRIPTION
	@mkdir -p $(dir $@)
	cp $< $@
	sed -i "s/VAR_VERSION/${VERSION}/" ${DIST_TMPDIR}/DESCRIPTION

clean:
	rm -rf build/

install: build/${DIST_NAME}
	@echo "Installing Octave package locally..."
	cd build && octave-cli --silent --eval 'pkg install "${DIST_NAME}"'


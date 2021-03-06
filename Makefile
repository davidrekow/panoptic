# panoptic makefile
# author: David Rekow <d@davidrekow.com>
# copyright: David Rekow 2014


SHELL := /bin/bash

# vars
THIS_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: build clean distclean test test-ci

all: build

build: test
	@echo "Building panoptic..."
	@mkdir -p $(THIS_DIR)/dist
	@echo "Compiling and minifying dist package with Closure Compiler..."
	@-java -jar $(THIS_DIR)/node_modules/closure-compiler-stream/lib/compiler.jar \
		--debug false \
		--warning_level VERBOSE \
		--summary_detail_level 3 \
		--language_in ECMASCRIPT5 \
		--js $(THIS_DIR)/src/index.js \
		--externs $(THIS_DIR)/externs.js \
		--compilation_level ADVANCED_OPTIMIZATIONS \
		--common_js_entry_module $(THIS_DIR)/src/index.js \
		--js_output_file $(THIS_DIR)/dist/panoptic.min.js \
		--output_wrapper '(function () {%output%}).call(this);' \
		--use_types_for_optimization
	@echo "Build complete."

clean:
	@echo "Cleaning built files..."
	@-rm -rf $(THIS_DIR)/dist
	@echo "Cleaning test reports..."
	@-rm -rf $(THIS_DIR)/test/reports

distclean: clean
	@echo "Cleaning downloaded dependencies..."
	@-rm -rf $(THIS_DIR)/node_modules

test: $(THIS_DIR)/node_modules
	@echo "Running panoptic package tests..."
	@multi="xunit=test/reports/xunit.xml spec=-" \
		$(THIS_DIR)/node_modules/.bin/istanbul cover $(THIS_DIR)/node_modules/.bin/_mocha -- -R mocha-multi

test-ci: test
	@echo "Reporting coverage to coveralls..."
	@cat $(THIS_DIR)/test/reports/coverage/lcov.info | $(THIS_DIR)/node_modules/.bin/coveralls

$(THIS_DIR)/node_modules:
	@echo "Installing NPM build dependencies..."
	@npm install

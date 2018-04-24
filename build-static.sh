#!/bin/bash

#
# AUTHOR: Andrew Turley
# DESCRIPTION:
#     This script will build libsodium and statically link aganst
#     musl to allow for bundling libsodium into a statically linked
#     sodiumoxide based rust program.
#

set -e

PROJECT_DIR=$(pwd)
STATIC_MUSL_LIBSODIUM_EXISTS=FALSE

export PKG_CONFIG_ALLOW_CROSS=1
export SODIUM_LIB_DIR=${PROJECT_DIR}/build-static/libsodium/lib
export SODIUM_STATIC=static

function print_header() {
	echo -e "\n-- [ $@ ]"
}

function check-build-deps() {
	print_header "Check for build deps"
	if ! command -v libtool; then
		echo "libtool...missing"
	fi

	if ! command -v musl-gcc; then
		echo "musl-gcc...missing"
	fi
}

function check-libsodium-musl-static() {
	print_header "Checking for static musl libsodium library"
	if ls ${PROJECT_DIR}/build-static/libsodium/lib/libsodium.a; then
		STATIC_MUSL_LIBSODIUM_EXISTS=TRUE
	fi
}

function build-libsodium-musl-static() {
	print_header "Make build-static/libsodium dir"
	mkdir -p build-static/libsodium && echo "...COMPLETE"

	print_header "Get libsodium source"
	cd ${PROJECT_DIR}/build-static/libsodium
	git clone https://github.com/jedisct1/libsodium.git src && \
	echo "...COMPLETE"

	print_header "Build libsodium against musl"
	cd ${PROJECT_DIR}/build-static/libsodium/src
	./autogen.sh
	CC=musl-gcc ./configure \
		--enable-shared=no \
		--prefix=${PROJECT_DIR}/build-static/libsodium
	make
	make install && echo "...COMPLETE"
}

check-build-deps
check-libsodium-musl-static
if [[ "${STATIC_MUSL_LIBSODIUM_EXISTS}" == "FALSE" ]]; then
	build-libsodium-musl-static
fi

print_header "Cargo build"
if [[ $# -ne 0 ]]; then
	echo "cargo build --target=x86_64-unknown-linux-musl $@"
	cargo build --target=x86_64-unknown-linux-musl $@
else
	echo "cargo build --target=x86_64-unknown-linux-musl"
	cargo build --target=x86_64-unknown-linux-musl
fi

echo # Just a little padding for readability at script end

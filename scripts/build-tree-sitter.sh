#!/usr/bin/env sh

set -euxo pipefail

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TMP_BUILD_DIR=$( mktemp -d )
mkdir $TMP_BUILD_DIR/build

COMMON_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.13"
TREE_SITTER_CFLAGS="${COMMON_FLAGS} -std=gnu99 -O3 -Wall -Wextra -I${TMP_BUILD_DIR}/tree-sitter/lib/include/"
TREE_SITTER_CXXFLAGS="${COMMON_FLAGS} -O3 -Wall -Wextra -I${TMP_BUILD_DIR}/tree-sitter/lib/include/"
TREE_SITTER_LDFLAGS="${COMMON_FLAGS} -L${TMP_BUILD_DIR}/tree-sitter"

pushd $TMP_BUILD_DIR

git clone https://github.com/tree-sitter/tree-sitter.git

pushd tree-sitter
git checkout v0.20.6
CFLAGS=$TREE_SITTER_CFLAGS \
CXXFLAGS=$TREE_SITTER_CXXFLAGS \
LDFLAGS=$TREE_SITTER_LDFLAGS \
PREFIX=$TMP_BUILD_DIR/build make install
popd

git clone https://github.com/alex-pinkus/tree-sitter-swift.git

pushd tree-sitter-swift
npm install
CFLAGS=$TREE_SITTER_CFLAGS \
CXXFLAGS=$TREE_SITTER_CXXFLAGS \
LDFLAGS=$TREE_SITTER_LDFLAGS \
PREFIX=$TMP_BUILD_DIR/build make install
popd

git clone https://github.com/tree-sitter/tree-sitter-go.git

pushd tree-sitter-go
npm install
CFLAGS=$TREE_SITTER_CFLAGS \
CXXFLAGS=$TREE_SITTER_CXXFLAGS \
LDFLAGS=$TREE_SITTER_LDFLAGS \
PREFIX=$TMP_BUILD_DIR/build make install
popd

git clone https://github.com/camdencheek/tree-sitter-go-mod.git

pushd tree-sitter-go-mod
npm install
CFLAGS=$TREE_SITTER_CFLAGS \
CXXFLAGS=$TREE_SITTER_CXXFLAGS \
LDFLAGS=$TREE_SITTER_LDFLAGS \
PREFIX=$TMP_BUILD_DIR/build make install
popd

git clone https://github.com/tree-sitter/tree-sitter-ruby.git

pushd tree-sitter-ruby
gh pr checkout 199
npm install
CFLAGS=$TREE_SITTER_CFLAGS \
CXXFLAGS=$TREE_SITTER_CXXFLAGS \
LDFLAGS=$TREE_SITTER_LDFLAGS \
PREFIX=$TMP_BUILD_DIR/build make install
popd

git clone https://github.com/tree-sitter/tree-sitter-json.git

pushd tree-sitter-json
gh pr checkout 19
npm install
CFLAGS=$TREE_SITTER_CFLAGS \
CXXFLAGS=$TREE_SITTER_CXXFLAGS \
LDFLAGS=$TREE_SITTER_LDFLAGS \
PREFIX=$TMP_BUILD_DIR/build make install
popd

libtool -static -o libtree-sitter.a \
    $TMP_BUILD_DIR/build/lib/libtree-sitter.a \
    $TMP_BUILD_DIR/build/lib/libtree-sitter-swift.a \
    $TMP_BUILD_DIR/build/lib/libtree-sitter-go.a \
    $TMP_BUILD_DIR/build/lib/libtree-sitter-gomod.a \
    $TMP_BUILD_DIR/build/lib/libtree-sitter-ruby.a \
    $TMP_BUILD_DIR/build/lib/libtree-sitter-json.a

mkdir -p tree_sitter.framework/Versions/A/{Headers,Modules,Resources}
cp -f libtree-sitter.a tree_sitter.framework/Versions/A/tree_sitter
cp $TMP_BUILD_DIR/build/include/tree_sitter/*.h tree_sitter.framework/Versions/A/Headers
cp $SCRIPT_DIR/../shim/tree_sitter.h tree_sitter.framework/Versions/A/Headers
cp $SCRIPT_DIR/../shim/Info.plist tree_sitter.framework/Versions/A/Resources
cp $SCRIPT_DIR/../shim/module.modulemap tree_sitter.framework/Versions/A/Modules

pushd tree_sitter.framework/Versions
ln -s A Current
popd

pushd tree_sitter.framework
ln -s Versions/Current/Headers Headers
ln -s Versions/Current/Modules Modules
ln -s Versions/Current/Resources Resources
ln -s Versions/Current/tree_sitter tree_sitter
popd

rm -rf $SCRIPT_DIR/../tree_sitter.xcframework

xcodebuild -create-xcframework \
    -framework $TMP_BUILD_DIR/tree_sitter.framework \
    -output $SCRIPT_DIR/../tree_sitter.xcframework

rm -rf $TMP_BUILD_DIR
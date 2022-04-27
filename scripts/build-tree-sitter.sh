#!/usr/bin/env sh

set -euxo pipefail

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
LANGUAGE_DATA_DIR="$SCRIPT_DIR/../Sources/tree_sitter_language_resources/LanguageResources"

TMP_BUILD_DIR=$( mktemp -d )
mkdir -p $TMP_BUILD_DIR/build/{macos,iphoneos,maccatalyst,iphonesimulator}

IPHONEOS_SYSROOT=$(xcrun --sdk iphoneos --show-sdk-path)
IPHONESIMULATOR_SYSROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

MACOS_COMMON_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.13"
IPHONEOS_COMMON_FLAGS="-arch arm64 -miphoneos-version-min=11.0 -fembed-bitcode -isysroot $IPHONEOS_SYSROOT"
MACCATALYST_COMMON_FLAGS="-arch arm64 -arch x86_64 -target x86_64-apple-ios-macabi -fembed-bitcode -miphoneos-version-min=13.0"
IPHONESIMULATOR_COMMON_FLAGS="-arch arm64 -arch x86_64 -miphonesimulator-version-min=11.0 -isysroot $IPHONESIMULATOR_SYSROOT"

pushd $TMP_BUILD_DIR

function build_parser () {
    pushd "tree-sitter-$1"

    PKG_CONFIG_PATH="$TMP_BUILD_DIR/build/macos/lib/pkgconfig"
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}:$(pkg-config --variable pc_path pkg-config)

    CFLAGS="${MACOS_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    CXXFLAGS="${MACOS_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    LDFLAGS="${MACOS_COMMON_FLAGS} $(pkg-config tree-sitter --libs)" \
    PREFIX=$TMP_BUILD_DIR/build/macos make install
    make clean

    PKG_CONFIG_PATH="$TMP_BUILD_DIR/build/iphoneos/lib/pkgconfig"
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}:$(pkg-config --variable pc_path pkg-config)

    CFLAGS="${IPHONEOS_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    CXXFLAGS="${IPHONEOS_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    LDFLAGS="${IPHONEOS_COMMON_FLAGS} $(pkg-config tree-sitter --libs)" \
    PREFIX=$TMP_BUILD_DIR/build/iphoneos make install
    make clean

    PKG_CONFIG_PATH="$TMP_BUILD_DIR/build/maccatalyst/lib/pkgconfig"
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}:$(pkg-config --variable pc_path pkg-config)

    CFLAGS="${MACCATALYST_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    CXXFLAGS="${MACCATALYST_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    LDFLAGS="${MACCATALYST_COMMON_FLAGS} $(pkg-config tree-sitter --libs)" \
    PREFIX=$TMP_BUILD_DIR/build/maccatalyst make install
    make clean

    PKG_CONFIG_PATH="$TMP_BUILD_DIR/build/iphonesimulator/lib/pkgconfig"
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}:$(pkg-config --variable pc_path pkg-config)

    CFLAGS="${IPHONESIMULATOR_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    CXXFLAGS="${IPHONESIMULATOR_COMMON_FLAGS} -O3 $(pkg-config tree-sitter --cflags)" \
    LDFLAGS="${IPHONESIMULATOR_COMMON_FLAGS} $(pkg-config tree-sitter --libs)" \
    PREFIX=$TMP_BUILD_DIR/build/iphonesimulator make install

    mkdir -p "$LANGUAGE_DATA_DIR/$1"
    if [ -d "queries" ]; then
        cp queries/* "$LANGUAGE_DATA_DIR/$1/"
    fi

    popd
}

git clone https://github.com/tree-sitter/tree-sitter.git

pushd tree-sitter
git checkout v0.20.6
CFLAGS="${MACOS_COMMON_FLAGS} -std=gnu99 -O3 -Wall -Wextra" \
CXXFLAGS="${MACOS_COMMON_FLAGS} -O3 -Wall -Wextra" \
LDFLAGS="${MACOS_COMMON_FLAGS}" \
PREFIX=$TMP_BUILD_DIR/build/macos make install
make clean

CFLAGS="${IPHONEOS_COMMON_FLAGS} -std=gnu99 -O3 -Wall -Wextra" \
CXXFLAGS="${IPHONEOS_COMMON_FLAGS} -O3 -Wall -Wextra" \
LDFLAGS="${IPHONEOS_COMMON_FLAGS}" \
PREFIX=$TMP_BUILD_DIR/build/iphoneos make install
make clean

CFLAGS="${MACCATALYST_COMMON_FLAGS} -std=gnu99 -O3 -Wall -Wextra" \
CXXFLAGS="${MACCATALYST_COMMON_FLAGS} -O3 -Wall -Wextra" \
LDFLAGS="${MACCATALYST_COMMON_FLAGS}" \
PREFIX=$TMP_BUILD_DIR/build/maccatalyst make install
make clean

CFLAGS="${IPHONESIMULATOR_COMMON_FLAGS} -std=gnu99 -O3 -Wall -Wextra" \
CXXFLAGS="${IPHONESIMULATOR_COMMON_FLAGS} -O3 -Wall -Wextra" \
LDFLAGS="${IPHONESIMULATOR_COMMON_FLAGS}" \
PREFIX=$TMP_BUILD_DIR/build/iphonesimulator make install
popd

git clone --depth 1 https://github.com/alex-pinkus/tree-sitter-swift.git
pushd tree-sitter-swift
npm install
popd
build_parser "swift"

git clone --depth 1 https://github.com/tree-sitter/tree-sitter-go.git
build_parser "go"

git clone --depth 1 https://github.com/camdencheek/tree-sitter-go-mod.git
mv tree-sitter-go-mod tree-sitter-gomod
build_parser "gomod"

git clone --depth 1 https://github.com/tree-sitter/tree-sitter-ruby.git
build_parser "ruby"

git clone --depth 1 https://github.com/tree-sitter/tree-sitter-json.git
pushd tree-sitter-json
gh pr checkout 19
popd
build_parser "json"

git clone --depth 1 https://github.com/tree-sitter/tree-sitter-php.git
pushd tree-sitter-php
popd
build_parser "php"

git clone --depth 1 https://github.com/ikatyang/tree-sitter-markdown.git
pushd tree-sitter-markdown
gh pr checkout 42
popd
build_parser "markdown"

git clone --depth 1 https://github.com/tree-sitter/tree-sitter-java.git
pushd tree-sitter-java
popd
build_parser "java"

# now, build the frameworks

pushd $TMP_BUILD_DIR/build/macos

libtool -static -o libtree-sitter.a \
    lib/libtree-sitter.a \
    lib/libtree-sitter-swift.a \
    lib/libtree-sitter-go.a \
    lib/libtree-sitter-gomod.a \
    lib/libtree-sitter-ruby.a \
    lib/libtree-sitter-json.a \
    lib/libtree-sitter-php.a \
    lib/libtree-sitter-markdown.a \
    lib/libtree-sitter-java.a

mkdir -p tree_sitter.framework/Versions/A/{Headers,Modules,Resources}
cp -f libtree-sitter.a tree_sitter.framework/Versions/A/tree_sitter
cp include/tree_sitter/*.h tree_sitter.framework/Versions/A/Headers
cp $SCRIPT_DIR/../shim/tree_sitter.h tree_sitter.framework/Versions/A/Headers
cp $SCRIPT_DIR/../shim/macos-Info.plist tree_sitter.framework/Versions/A/Resources/Info.plist
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

popd

pushd $TMP_BUILD_DIR/build/iphoneos

libtool -static -o libtree-sitter.a \
    lib/libtree-sitter.a \
    lib/libtree-sitter-swift.a \
    lib/libtree-sitter-go.a \
    lib/libtree-sitter-gomod.a \
    lib/libtree-sitter-ruby.a \
    lib/libtree-sitter-json.a \
    lib/libtree-sitter-php.a \
    lib/libtree-sitter-markdown.a \
    lib/libtree-sitter-java.a

mkdir -p tree_sitter.framework/{Headers,Modules}
cp -f libtree-sitter.a tree_sitter.framework/tree_sitter
cp include/tree_sitter/*.h tree_sitter.framework/Headers
cp $SCRIPT_DIR/../shim/tree_sitter.h tree_sitter.framework/Headers
cp $SCRIPT_DIR/../shim/iphoneos-Info.plist tree_sitter.framework/Info.plist
cp $SCRIPT_DIR/../shim/module.modulemap tree_sitter.framework/Modules

popd

pushd $TMP_BUILD_DIR/build/maccatalyst

libtool -static -o libtree-sitter.a \
    lib/libtree-sitter.a \
    lib/libtree-sitter-swift.a \
    lib/libtree-sitter-go.a \
    lib/libtree-sitter-gomod.a \
    lib/libtree-sitter-ruby.a \
    lib/libtree-sitter-json.a \
    lib/libtree-sitter-php.a \
    lib/libtree-sitter-markdown.a \
    lib/libtree-sitter-java.a

mkdir -p tree_sitter.framework/{Headers,Modules}
cp -f libtree-sitter.a tree_sitter.framework/tree_sitter
cp include/tree_sitter/*.h tree_sitter.framework/Headers
cp $SCRIPT_DIR/../shim/tree_sitter.h tree_sitter.framework/Headers
cp $SCRIPT_DIR/../shim/iphoneos-Info.plist tree_sitter.framework/Info.plist
cp $SCRIPT_DIR/../shim/module.modulemap tree_sitter.framework/Modules

popd

pushd $TMP_BUILD_DIR/build/iphonesimulator

libtool -static -o libtree-sitter.a \
    lib/libtree-sitter.a \
    lib/libtree-sitter-swift.a \
    lib/libtree-sitter-go.a \
    lib/libtree-sitter-gomod.a \
    lib/libtree-sitter-ruby.a \
    lib/libtree-sitter-json.a \
    lib/libtree-sitter-php.a \
    lib/libtree-sitter-markdown.a \
    lib/libtree-sitter-java.a

mkdir -p tree_sitter.framework/{Headers,Modules}
cp -f libtree-sitter.a tree_sitter.framework/tree_sitter
cp include/tree_sitter/*.h tree_sitter.framework/Headers
cp $SCRIPT_DIR/../shim/tree_sitter.h tree_sitter.framework/Headers
cp $SCRIPT_DIR/../shim/iphonesimulator-Info.plist tree_sitter.framework/Info.plist
cp $SCRIPT_DIR/../shim/module.modulemap tree_sitter.framework/Modules

popd

rm -rf $SCRIPT_DIR/../tree_sitter.xcframework

xcodebuild -create-xcframework \
    -framework $TMP_BUILD_DIR/build/macos/tree_sitter.framework \
    -framework $TMP_BUILD_DIR/build/iphoneos/tree_sitter.framework \
    -framework $TMP_BUILD_DIR/build/maccatalyst/tree_sitter.framework \
    -framework $TMP_BUILD_DIR/build/iphonesimulator/tree_sitter.framework \
    -output $SCRIPT_DIR/../tree_sitter.xcframework

rm -rf $TMP_BUILD_DIR
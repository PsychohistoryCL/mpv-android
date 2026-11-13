#!/bin/bash -e

. ./include/depinfo.sh

[ -z "$IN_CI" ] && IN_CI=0
[ -z "$WGET" ] && WGET=wget

# git clone with retries (CI runners occasionally fail mid-clone with exit 4)
gclone() {
	local dst="$1"; shift
	local i
	for i in 1 2 3 4 5; do
		git clone "$@" && return 0
		echo "git clone '$dst' failed (attempt $i), retrying..." >&2
		rm -rf "$dst"
		sleep $((i * 5))
	done
	return 1
}

mkdir -p deps && cd deps

# openssl
if [ ! -d openssl ]; then
	gclone openssl --recurse-submodules https://github.com/openssl/openssl.git -b openssl-$v_openssl
else
	cd openssl
	echo "Updating openssl"
	git fetch
	git checkout -f openssl-$v_openssl
	git describe --tags --always
	git submodule update --init --recursive --rebase
	cd ..
fi

# dav1d
if [ ! -d dav1d ]; then
	gclone dav1d https://github.com/videolan/dav1d
fi

# ffmpeg
if [ ! -d ffmpeg ]; then
	args=()
	[ $IN_CI -eq 1 ] && args+=(--depth=1 -b "$v_ci_ffmpeg")
	gclone ffmpeg https://github.com/FFmpeg/FFmpeg "${args[@]}"
fi

# freetype2
if [ ! -d freetype2 ]; then
	gclone freetype2 --recurse-submodules https://gitlab.freedesktop.org/freetype/freetype.git -b VER-${v_freetype//./-}
else
	cd freetype2
	echo "Updating freetype2"
	git fetch
	git checkout -f VER-${v_freetype//./-}
	git describe --tags --always
	git submodule update --init --recursive --rebase
	cd ..
fi

# fribidi
if [ ! -d fribidi ]; then
	mkdir fribidi
	if [ ! -f fribidi-$v_fribidi.tar.xz ]; then
		$WGET -q --show-progress https://github.com/fribidi/fribidi/releases/download/v$v_fribidi/fribidi-$v_fribidi.tar.xz
	fi
	echo "Extracting fribidi-$v_fribidi.tar.xz"
	tar -xJ -C fribidi --strip-components=1 -f fribidi-$v_fribidi.tar.xz
fi

# harfbuzz
if [ ! -d harfbuzz ]; then
	mkdir harfbuzz
	if [ ! -f harfbuzz-$v_harfbuzz.tar.xz ]; then
		$WGET -q --show-progress https://github.com/harfbuzz/harfbuzz/releases/download/$v_harfbuzz/harfbuzz-$v_harfbuzz.tar.xz
	fi
	echo "Extracting harfbuzz-$v_harfbuzz.tar.xz"
	tar -xJ -C harfbuzz --strip-components=1 -f harfbuzz-$v_harfbuzz.tar.xz
fi

# unibreak
if [ ! -d unibreak ]; then
	mkdir unibreak
	if [ ! -f libunibreak-${v_unibreak}.tar.gz ]; then
		$WGET -q --show-progress https://github.com/adah1972/libunibreak/releases/download/libunibreak_${v_unibreak//./_}/libunibreak-${v_unibreak}.tar.gz
	fi
	echo "Extracting libunibreak-${v_unibreak}.tar.gz"
	tar -xz -C unibreak --strip-components=1 -f libunibreak-${v_unibreak}.tar.gz
fi

# libxml2
if [ ! -d libxml2 ]; then
	mkdir libxml2
	if [ ! -f libxml2-v${v_libxml2}.tar.gz ]; then
		$WGET -q --show-progress https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${v_libxml2}/libxml2-v${v_libxml2}.tar.gz
	fi
	echo "Extracting libxml2-v${v_libxml2}.tar.gz"
	tar -xz -C libxml2 --strip-components=1 -f libxml2-v${v_libxml2}.tar.gz
fi

# fontconfig
if [ ! -d fontconfig ]; then
	mkdir fontconfig
	if [ ! -f fontconfig-${v_fontconfig}.tar.gz ]; then
		$WGET -q --show-progress https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/${v_fontconfig}/fontconfig-${v_fontconfig}.tar.gz
	fi
	echo "Extracting fontconfig-${v_fontconfig}.tar.gz"
	tar -xz -C fontconfig --strip-components=1 -f fontconfig-${v_fontconfig}.tar.gz
fi

# libass
if [ ! -d libass ]; then
	gclone libass https://github.com/libass/libass
fi

# lua
if [ ! -d lua ]; then
	mkdir lua
	if [ ! -f lua-$v_lua.tar.gz ]; then
		$WGET -q --show-progress https://www.lua.org/ftp/lua-$v_lua.tar.gz
	fi
	echo "Extracting lua-$v_lua.tar.gz"
	tar -xz -C lua --strip-components=1 -f lua-$v_lua.tar.gz
fi

# shaderc
mkdir -p shaderc
cat >shaderc/README <<'HEREDOC'
shaderc sources are provided by the NDK
see <ndk>/sources/third_party/shaderc
HEREDOC

# libplacebo
if [ ! -d libplacebo ]; then
	gclone libplacebo --recursive https://github.com/haasn/libplacebo
	cd libplacebo
	git checkout -f "$v_libplacebo"
	git submodule update --init --recursive
	cd ..
fi

# curl
if [ ! -d curl ]; then
	mkdir curl
	if [ ! -f curl-$v_curl.tar.gz ]; then
		$WGET -q --show-progress https://curl.se/download/curl-$v_curl.tar.gz
	fi
	echo "Extracting curl-$v_curl.tar.gz"
	tar -xz -C curl --strip-components=1 -f curl-$v_curl.tar.gz
fi

# mpv
if [ ! -d mpv ]; then
	gclone mpv https://github.com/mpv-player/mpv
	cd mpv
	git checkout -f "$v_mpv"
	cd ..
fi


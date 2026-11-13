#!/bin/bash -e

## Dependency versions
# Make sure to keep v_ndk and v_ndk_n in sync, both are listed on the NDK download page

v_sdk=11076708_latest
v_ndk=r30
v_ndk_n=30.0.16248370
v_sdk_platform=36
v_sdk_build_tools=36.0.0

v_lua=5.2.4
v_lua_sha256=b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b
v_unibreak=8.0
v_harfbuzz=15.0.0
v_fribidi=1.0.17
v_freetype=2.15.0
v_openssl=3.5.9
v_libxml2=2.15.4
v_fontconfig=2.18.3
v_curl=8.23.0
v_lcms2=2.20
v_lcms2_sha256=18ff5504fa9cc8a2b1f3591180d90ead16c8a2ea78e530523b46eab70e1ca6b9


## Dependency tree

dep_openssl=()
dep_dav1d=()
dep_libxml2=()
dep_ffmpeg=(openssl dav1d libxml2)
dep_freetype2=()
dep_fontconfig=(libxml2 freetype2)
dep_fribidi=()
dep_harfbuzz=()
dep_unibreak=()
dep_libass=(freetype2 fontconfig fribidi harfbuzz unibreak)
dep_lua=()
dep_shaderc=()
dep_lcms2=()
dep_libplacebo=(shaderc lcms2)
dep_curl=(openssl)
dep_mpv=(ffmpeg libass lua libplacebo lcms2 curl)
dep_mpv_android=(mpv)


## for CI workflow

# pinned ffmpeg revision
v_ci_ffmpeg=n9.0.2
v_mpv=v0.42.0
v_libplacebo=v7.387.0

# filename used to uniquely identify a build prefix
ci_tarball="prefix-n${v_ndk}-l${v_lua}-u${v_unibreak}-h${v_harfbuzz}-fr${v_fribidi}-ft${v_freetype}-x${v_libxml2}-fo${v_fontconfig}-o${v_openssl}-c${v_curl}-lc${v_lcms2}-ff${v_ci_ffmpeg}-pl${v_libplacebo}-mv${v_mpv}.tgz"

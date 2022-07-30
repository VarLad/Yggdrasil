# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "xkbcommon"
version = v"1.4.1"

# Collection of sources required to build xkbcommon
sources = [
    ArchiveSource("https://xkbcommon.org/download/libxkbcommon-$(version).tar.xz",
                  "3b86670dd91441708dedc32bc7f684a034232fd4a9bb209f53276c9783e9d40e"),
    DirectorySource("./bundled"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libxkbcommon-*/

# We need to run `wayland-scanner` on the host system
apk add wayland-dev

mkdir build && cd build
meson .. --cross-file="${MESON_TARGET_TOOLCHAIN}" \
    -Denable-docs=false \
    -Dnative-wayland-scanner="/usr/bin/wayland-scanner"
ninja -j${nproc}
ninja install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [p for p in supported_platforms() if Sys.islinux(p)]

# The products that we will ensure are always built
products = [
    LibraryProduct("libxkbcommon", :libxkbcommon),
    LibraryProduct("libxkbcommon-x11", :libxkbcommon_x11),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    BuildDependency("Xorg_xorgproto_jll"),
    Dependency("Xorg_xkeyboard_config_jll"),
    Dependency("Xorg_libxcb_jll"),
    Dependency("Wayland_jll"),
    Dependency("Wayland_protocols_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

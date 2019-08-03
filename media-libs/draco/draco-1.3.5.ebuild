# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# FIXME:
#  * add ccache and distcc options
#  * add support for GLTF? (blender-2.80 needs this option, so for now
#    we use it by default.
#  * check the function of BUILD_ANIMATION_ENCODING variable
#  * check the function of ENABLE_DECODER_ATTRIBUTE_DEDUPLICATION variable
#  * add testing support (might not be possible, due to draco expecting the
#    gtest source code in a side-directory)
#  * add debug support
#  * will we be able to add javascript support through emscripten library?
#    This library seems to be highly unfriendly to be installed system wide!

EAPI=7

inherit cmake-utils

DESCRIPTION="Library for compressing and decompressing 3D geometric objects"
HOMEPAGE="https://google.github.io/draco/"
SRC_URI="https://github.com/google/draco/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64"

#IUSE=""
#RESTRICT="strip"

#RDEPEND=""

#DEPEND="${RDEPEND}"

#BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-0001-CMakeLists.txt-respect-library-dirs.patch"
)

DOCS=( AUTHORS CONTRIBUTING.md README.md )

src_configure() {
	local mycmakeargs=(
		-DBUILD_ANIMATION_ENCODING=OFF # default (FIXME?)
		-DBUILD_FOR_GLTF=ON # needed by blender-2.80 (FIXME)
		-DBUILD_MAYA_PLUGIN=OFF # default
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_UNITY_PLUGIN=OFF # default (FIXME?)
		-DBUILD_USD_PLUGIN=OFF # default
		-DEMSCRIPTEN=OFF # explicitly forbid this (FIXME?)
		-DENABLE_BACKWARDS_COMPATIBILITY=ON # default
		-DENABLE_CCACHE=OFF # default (FIXME)
		-DENABLE_DECODER_ATTRIBUTE_DEDUPLICATION=OFF # default
		-DENABLE_DISTCC=OFF # default (FIXME)
		-DENABLE_EXTRA_SPEED=OFF # don't use -O3 optimization
		-DENABLE_EXTRA_WARNINGS=ON
		-DENABLE_GOMA=OFF # default (not availabe in gentoo)
		-DENABLE_JS_GLUE=OFF # needs emscripten which is not available in gentoo
		-DENABLE_MESH_COMPRESSION=ON # default
		-DENABLE_POINT_CLOUD_COMPRESSION=ON # default
		-DENABLE_PREDICTIVE_EDGEBREAKER=ON # default
		-DENABLE_STANDARD_EDGEBREAKER=ON # default
		-DENABLE_TESTS=OFF # default (FIXME)
		-DENABLE_WASM=OFF # default (FIXME?)
		-DENABLE_WERROR=OFF # default
		-DENABLE_WEXTRA=ON # add extra compiler warnings
		-DIGNORE_EMPTY_BUILD_TYPE=OFF # default (FIXME?)
	)

	cmake-utils_src_configure
}

#src_compile() {
#}

#src_install() {
#}

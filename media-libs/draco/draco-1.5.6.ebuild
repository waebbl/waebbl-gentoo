# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# FIXME:
#  * will we be able to add javascript support through emscripten library?
#    This library seems to be highly unfriendly to be installed system wide!
#  * add USD (Pixar's Universal Scene Description) support, see
#    https://github.com/PixarAnimationStudios/USD
#  * add support for Unity(3D) and Maya plugins?

# Notes:
# - We don't add USE flags for ccache and distcc, because the library builds
#   in minimal time (a few seconds)

EAPI=8

inherit cmake

DESCRIPTION="Library for compressing and decompressing 3D geometric objects"
HOMEPAGE="https://google.github.io/draco/"
SRC_URI="https://github.com/google/draco/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+compat cpu_flags_x86_sse4_1 +gltf"

# Testing needs the dev-cpp/gtest source code to be available in a
# side-directory of the draco sources, therefore we restrict test for now.
RESTRICT="test"

DOCS=( AUTHORS README.md )

src_configure() {
	local mycmakeargs=(
		# currently only used for javascript/emscripten build
#		-DDRACO_ANIMATION_ENCODING=OFF # default
		-DDRACO_BACKWARDS_COMPATIBILITY=$(usex compat)
		# currently only used for javascript/emscripten build and by default
		# set to on with C/C++ build
#		-DDRACO_DECODER_ATTRIBUTE_DEDUPLICATION=ON
		-DDRACO_ENABLE_SSE4_1=$(usex cpu_flags_x86_sse4_1)
		-DDRACO_GLTF_BITSTREAM=$(usex gltf)
#		-DDRACO_MAYA_PLUGIN=OFF # default
#		-DDRACO_MESH_COMPRESSION=ON # default
#		-DDRACO_POINT_CLOUD_COMPRESSION=ON # default
#		-DDRACO_PREDICTIVE_EDGEBREAKER=ON # default
#		-DDRACO_STANDARD_EDGEBREAKER=ON # default
#		-DDRACO_TESTS=OFF
#		-DDRACO_UNITY_PLUGIN=OFF # default (FIXME?)
#		-DDRACO_USD_PLUGIN=OFF # default
		-DDRACO_VERBOSE=1	# used for debugging the ebuild
#		-DEMSCRIPTEN=OFF # explicitly forbid this
	)

	cmake_src_configure
}

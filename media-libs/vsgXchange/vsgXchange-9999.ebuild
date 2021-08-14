# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="VulkanSceneGraph integration library"
HOMEPAGE="https://github.com/vsg-dev/vsgXchange/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgXchange.git"
fi

LICENSE="MIT"
SLOT="0"
IUSE="assimp curl freetype gdal openscenegraph"
# no testsuite available (yet)
RESTRICT="test"

RDEPEND="
	dev-util/glslang
	media-libs/vulkan-loader[X]
	media-libs/vsg
	x11-libs/libxcb:=
	assimp? ( media-libs/assimp )
	curl? ( net-misc/curl )
	freetype? ( media-libs/freetype )
	gdal? ( media-libs/vsgGIS )
	openscenegraph? ( dev-games/openscenegraph:= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-fix-assimp-library-variable.patch
)

src_prepare() {
	sed -e "s/DESTINATION lib/DESTINATION $(get_libdir)/" \
		-e 's|FILES "vsgXchangeConfig.cmake"|FILES "\${CMAKE_BINARY_DIR}/src/vsgXchangeConfig.cmake"|' \
		-i src/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DvsgXchange_assimp=$(usex assimp)
		-DvsgXchange_CURL=$(usex curl)
		-DvsgXchange_freetype=$(usex freetype)
		-DvsgXchange_GDAL=$(usex gdal)
		-DvsgXchange_OSG=$(usex openscenegraph)
	)

	cmake_src_configure
}

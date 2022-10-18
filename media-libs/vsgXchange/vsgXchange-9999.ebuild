# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="VulkanSceneGraph integration library"
HOMEPAGE="https://github.com/vsg-dev/vsgXchange/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgXchange.git"
fi

LICENSE="MIT"
SLOT="0"
IUSE="assimp curl freetype gdal openexr openscenegraph"
# no testsuite available (yet)
RESTRICT="test"

RDEPEND="
	dev-util/glslang
	dev-util/spirv-tools
	media-libs/shaderc
	media-libs/vulkan-loader[X]
	media-libs/vsg
	x11-libs/libxcb:=
	assimp? ( media-libs/assimp )
	curl? ( net-misc/curl )
	freetype? ( media-libs/freetype )
	gdal? ( sci-libs/gdal:= )
	openexr? ( media-libs/openexr:= )
	openscenegraph? ( media-libs/osg2vsg )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DvsgXchange_assimp=$(usex assimp)
		-DvsgXchange_CURL=$(usex curl)
		-DvsgXchange_freetype=$(usex freetype)
		-DvsgXchange_GDAL=$(usex gdal)
		-DvsgXchange_OpenEXR=$(usex openexr)
		-DvsgXchange_OSG=$(usex openscenegraph)
	)

	cmake_src_configure
}

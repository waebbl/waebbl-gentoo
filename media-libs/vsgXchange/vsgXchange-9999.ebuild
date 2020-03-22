# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake
DESCRIPTION="VulkanSceneGraph integration library"
HOMEPAGE="https://github.com/vsg-dev/vsgXchange/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgXchange.git"
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-util/glslang
	media-gfx/osg2vsg
	media-libs/vulkan-loader[X]
	media-libs/vsg
	x11-libs/libxcb
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	sed -e 's|DESTINATION lib|DESTINATION '$(get_libdir)'|' \
		-e 's|FILES "vsgXchangeConfig.cmake"|FILES "\${CMAKE_BINARY_DIR}/src/vsgXchangeConfig.cmake"|' \
		-i src/CMakeLists.txt || die

	cmake_src_prepare
}

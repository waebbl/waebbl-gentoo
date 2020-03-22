# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Convert OpenSceneGraph images into VulkanSceneGraph"
HOMEPAGE="https://github.com/vsg-dev/osg2vsg/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/osg2vsg.git"
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-games/openscenegraph:=[osgapps]
	dev-util/glslang
	media-libs/vsg
	media-libs/vulkan-loader[X]
	virtual/opengl
	x11-libs/libxcb
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}/${P}-0001-Install-binaries.patch" )

src_prepare() {
	sed -e 's|DESTINATION lib|DESTINATION '$(get_libdir)'|' \
		-i src/osg2vsg/CMakeLists.txt \
		-i src/osgPlugins/vsg/CMakeLists.txt || die

	cmake_src_prepare
}

src_install() {
	cmake_src_install

	# install shaders
	insinto /usr/share/${PN}
	doins -r "${S}"/data/*
}

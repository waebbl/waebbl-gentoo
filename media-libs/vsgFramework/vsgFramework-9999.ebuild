# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Meta package to pull in VulkanSceneGraph"
HOMEPAGE="https://github.com/vsg-dev/vsgFramework"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgFramework.git"
fi

LICENSE="MIT"
SLOT="0"
IUSE="assimp source"
RESTRICT="test"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-util/glslang
	dev-util/spirv-headers
	dev-util/spirv-tools
	media-gfx/vsgExamples[source?]
	media-libs/osg2vsg
	media-libs/vsg
	media-libs/vsgImGui
	media-libs/vsgQt
	media-libs/vsgXchange[assimp?,openscenegraph]
	media-libs/vulkan-loader[X]
	x11-libs/libxcb:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DBUILD_SPIRV_headers=OFF
		-DBUILD_SPIRV_tools=OFF
		-DBUILD_glslang=OFF
		-DBUILD_VulkanSceneGraph=OFF
		-DBUILD_osg2vsg=OFF
		-DBUILD_assimp=OFF
		-DBUILD_vsgXchange=OFF
		-DBUILD_vsgImGui=OFF
		-DBUILD_vsgQt=OFF
		-DBUILD_vsgExamples=OFF
	)

	cmake_src_configure
}

src_install() {
	einfo "Package installed"
}

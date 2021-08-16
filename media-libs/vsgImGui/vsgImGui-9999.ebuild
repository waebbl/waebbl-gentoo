# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Integration of VulkanSceneGraph with ImGui"
HOMEPAGE="https://github.com/vsg-dev/vsgImGui"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgImGui.git"
fi

LICENSE="MIT"
SLOT="0"
RESTRICT="test"

RDEPEND="
	dev-util/glslang
	media-libs/vsg
	media-libs/vsgXchange
	media-libs/vulkan-loader[X]
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	sed -e "s/DESTINATION lib/DESTINATION $(get_libdir)/" \
		-e 's/VSGIMGUI_MAJOR_VERSION/VSGIMGUI_VERSION_MAJOR/' \
		-e 's/VSGIMGUI_MINOR_VERSION/VSGIMGUI_VERSION_MINOR/' \
		-e 's/VSGIMGUI_PATCH_VERSION/VSGIMGUI_VERSION_PATCH/' \
		-i src/CMakeLists.txt || die

	cmake_src_prepare
}

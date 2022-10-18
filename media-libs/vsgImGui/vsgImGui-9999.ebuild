# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

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
	media-libs/shaderc
	media-libs/vsg
	media-libs/vsgXchange
	media-libs/vulkan-loader[X]
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

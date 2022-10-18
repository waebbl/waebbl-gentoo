# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Qt integration with VulkanSceneGraph"
HOMEPAGE="https://github.com/vsg-dev/vsgQt/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgQt.git"
fi
#S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
#IUSE="gnome X"
RESTRICT="test"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5[vulkan]
	dev-qt/qtwidgets:5
	dev-util/glslang
	media-libs/shaderc
	media-libs/vsg
	media-libs/vsgXchange
	media-libs/vulkan-loader[X]
	x11-libs/libxcb:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

#src_configure() {
#}

#src_compile() {
#}

#src_install() {
#}

# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Vulkan and C++-17 based Scene Graph Project"
HOMEPAGE="https://www.vulkanscenegraph.org/"

MY_PN=VulkanSceneGraph
MY_P=${MY_PN}-${PV}

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/${MY_PN}.git"
else
	SRC_URI="https://github.com/vsg-dev/${MY_PN}/archive/refs/tags/${MY_P}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${MY_PN}-${MY_P}"
fi

LICENSE="MIT"
SLOT="0"
IUSE="doc"
# no testsuite (yet), just static code analyzing tests using cppcheck
RESTRICT="test"

RDEPEND="
	dev-util/glslang
	media-libs/shaderc
	media-libs/vulkan-loader[X]
	x11-libs/libxcb:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen[dot] )
"

DOCS=( ROADMAP.md docs/. )

src_compile() {
	cmake_src_compile

	use doc && cmake_build docs
}

src_install() {
	use doc && HTML_DOCS=( "${BUILD_DIR}"/html/. )

	cmake_src_install
}

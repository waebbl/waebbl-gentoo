# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Vulkan and C++-17 based Scene Graph Project"
HOMEPAGE="https://www.vulkanscenegraph.org/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/VulkanSceneGraph.git"
	KEYWORDS=""
fi
#KEYWORDS="~amd64"

#S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
IUSE="doc"

#RESTRICT="strip"

RDEPEND="
	media-libs/vulkan-loader[X]
	x11-libs/libxcb
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"

src_prepare() {
	sed -e 's|DESTINATION lib|DESTINATION '$(get_libdir)'|' \
		-i src/vsg/CMakeLists.txt || die "failed to fix lib installation dir"

	cmake_src_prepare
}

src_compile() {
	cmake_src_compile

	if use doc; then
		pushd "${BUILD_DIR}" > /dev/null || die
		eninja docs
		popd || die
	fi
}

src_install() {
	cmake_src_install

	if use doc; then
		local DOCS=( INSTALL.md ROADMAP.md docs/. )
		local HTML_DOCS="${BUILD_DIR}/html/."
		einstalldocs
	fi
}

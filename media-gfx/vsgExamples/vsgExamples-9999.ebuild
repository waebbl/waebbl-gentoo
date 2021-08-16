# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Vsgviewer and vsgdraw example programs for VulkanSceneGraph"
HOMEPAGE="https://github.com/vsg-dev/vsgExamples/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgExamples.git"
fi

LICENSE="MIT"
SLOT="0"
IUSE="source"
RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/${P}-drop-buggy-examples.patch
)

RDEPEND="
	media-libs/vsg
	media-libs/vsgImGui
	media-libs/vsgXchange
	media-libs/vulkan-loader[X]
	x11-libs/libxcb:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_install() {
	cmake_src_install

	# install data files
	insinto /usr/share/${PN}/
	doins -r "${S}"/data

	# create and install env file to find needed data files
	newenvd - 99vsgExamples <<-EOF
		VSG_FILE_PATH=/usr/share/${PN}/data
	EOF

	if use source; then
		docompress -x /usr/share/doc/${PF}/examples
		dodoc -r "${S}"/examples
	fi
}

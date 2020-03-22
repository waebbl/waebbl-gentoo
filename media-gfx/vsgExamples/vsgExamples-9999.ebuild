# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="vsgviewer and vsgdraw example programs for VulkanSceneGraph"
HOMEPAGE="https://github.com/vsg-dev/vsgExamples/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgExamples.git"
	KEYWORDS=""
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

PATCHES=( "${FILESDIR}/${P}-0001-Install-vsgdraw-and-vsgviewer-binaries.patch" )

RDEPEND="
	media-libs/vsg
	media-libs/vsgXchange
	media-libs/vulkan-loader[X]
	x11-libs/libxcb
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_install() {
	cmake_src_install

	# install data files
	insinto /usr/share/${PN}/
	doins -r "${S}"/data

	# create and install env file to find needed data files
	cat <<- EOF > "${T}"/99vsgExamples
	VSG_FILE_PATH=/usr/share/${PN}/data
	EOF

	insinto /etc/env.d
	doins "${T}"/99vsgExamples
}

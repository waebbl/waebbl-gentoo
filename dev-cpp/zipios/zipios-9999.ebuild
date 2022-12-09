# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# FIXME: tests currently don't work. Repo isn't ready for Catch2 v3 and
# using catch:1 leads ot catch being not being due to missing cmake files
# and inferior FindCatch from upstream.

EAPI=7

inherit cmake

DESCRIPTION="C++ library for reading and writing zip files"
HOMEPAGE="https://snapwebsites.org/project/zipios"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Zipios/Zipios.git"
else
	SRC_URI="https://github.com/Zipios/Zipios/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/Zipios-${PV}"
fi

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="doc"

RESTRICT="test"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-doc/doxygen[dot] )"

PATCHES=(
	"${FILESDIR}"/${PN}-2.2.6-0005-install-missing-header-files.patch
	"${FILESDIR}"/${PN}-9999-fix-doc-installation-dir.patch
)

DOCS=( AUTHORS NEWS README.md )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_DOCUMENTATION=$(usex doc)
		-DBUILD_ZIPIOS_TESTS=OFF
		-DDOC_INSTALL_DIR=share/doc/${PF}
		-DRUN_TESTS=OFF
	)
	cmake_src_configure
}

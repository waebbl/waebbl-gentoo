# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="C++ library for reading and writing zip files"
HOMEPAGE="https://snapwebsites.org/project/zipios"
SRC_URI="https://github.com/Zipios/Zipios/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Zipios-${PV}"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RESTRICT="!test? ( test )"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"
BDEPEND="
	doc? ( app-doc/doxygen[dot] )
	test? (
		app-arch/zip
		dev-cpp/catch:1
	)
"

PATCHES=(
	"${FILESDIR}"/${P}-0001-search-catch-only-if-building-tests.patch
	"${FILESDIR}"/${P}-0002-remove-unprintable-char.patch
	"${FILESDIR}"/${P}-0003-fix-doc-installation-path.patch
	"${FILESDIR}"/${P}-0004-add-a-relocatable-config-file.patch
)

DOCS=( AUTHORS NEWS README.md TODO )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_DOCUMENTATION=$(usex doc)
		-DBUILD_ZIPIOS_TESTS=$(usex test)
		-DRUN_TESTS=$(usex test)
	)
	cmake_src_configure
}

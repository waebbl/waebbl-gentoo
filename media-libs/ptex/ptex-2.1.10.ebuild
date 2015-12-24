# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils cmake-utils

DESCRIPTION="Per-Face Texture Mapping library"

HOMEPAGE="http://ptex.us/index.html"

SRC_URI="https://github.com/wdas/ptex/archive/v${PV}.zip -> ${PN}-${PV}.zip"

LICENSE="Ptex"

SLOT="0"

KEYWORDS="~amd64"

CMAKE_MIN_VERSION="2.8"

RDEPEND=">=sys-libs/zlib-1.2.8-r1"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/ptex-2.1.10_utils-CMakeLists.txt.patch
	epatch "${FILESDIR}"/ptex-2.1.10_include-files-install.patch
	sed -i -e 's|CMAKE_CXX_FLAGS "-std=c++98 -Wall -Wextra -pedantic"|CMAKE_CXX_FLAGS "-std=c++98 -Wall -Wextra -pedantic ${CMAKE_C_FLAGS}"|' "${S}"/CMakeLists.txt
}

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	einfo "Moving docs into right place"
	mkdir -p "${ED}"usr/share/doc/${PF}/html
	mv "${ED}"usr/share/doc/ptex/* "${ED}"usr/share/doc/${PF}/html
	rmdir "${ED}"usr/share/doc/ptex
}

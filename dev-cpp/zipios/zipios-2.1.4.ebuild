# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="C++ library for reading and writing zip files"
HOMEPAGE="https://zipios.sourceforge.net"
# upstream does not provide releases
SRC_URI="https://github.com/Zipios/Zipios/archive/master.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="
	sys-libs/zlib:=
"

DEPEND="
	${RDEPEND}
	>=dev-util/cmake-2.8
	doc? ( app-doc/doxygen[dot] )
"

PATCHES=(
	"${FILESDIR}/${P}-fix-doc-installdir.patch"
)

S="${WORKDIR}/Zipios-master"

src_configure() {
	local mycmakeargs=( -DBUILD_DOCUMENTATION=$(usex doc) )
	cmake-utils_src_configure
}

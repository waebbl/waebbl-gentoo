# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Tool to generate different types of textures from a single image."
HOMEPAGE="https://github.com/kmkolasinski/AwesomeBump/"
SRC_URI="https://github.com/kmkolasinski/AwesomeBump/archive/Linuxv${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="${DEPEND}"
DEPEND=""

#S=${WORKDIR}/${P}

#src_configure() {
	#econf
	#./configure \
	#	--host=${CHOST} \
	#	--prefix=/usr \
	#	--infodir=/usr/share/info \
	#	--mandir=/usr/share/man || die
#}

#src_compile() {
	#emake
#}

#src_install() {
	#emake DESTDIR="${D}" install
	#emake \
	#	prefix="${D}"/usr \
	#	mandir="${D}"/usr/share/man \
	#	infodir="${D}"/usr/share/info \
	#	libdir="${D}"/usr/$(get_libdir) \
	#	install
#}

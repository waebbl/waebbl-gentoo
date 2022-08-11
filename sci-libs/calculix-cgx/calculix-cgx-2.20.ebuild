# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

MY_P=cgx_${PV}

DESCRIPTION="A Free Software Three-Dimensional Structural Finite Element Program"
HOMEPAGE="http://www.calculix.de/"
SRC_URI="http://www.dhondt.de/${MY_P}.all.tar.bz2
	doc? ( http://www.dhondt.de/${MY_P}.pdf )"
S=${WORKDIR}/CalculiX/${MY_P}/src/

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

RDEPEND="
	media-libs/mesa
	>=media-libs/freeglut-1.0
	virtual/opengl
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXt
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-0001-fix-Makefile-respect-FLAGS.patch
	"${FILESDIR}"/${P}-0002-fix-proper-menu-redrawing-with-glut.patch
)

src_unpack() {
	if use doc; then
		cp "${DISTDIR}/${MY_P}.pdf" "${WORKDIR}" || die
	fi
	default
}

src_configure () {
	# Does not compile without -lpthread
	export PTHREAD="-lpthread"
	export LFLAGS="-L/usr/$(get_libdir) ${LFLAGS} ${LDFLAGS}"
	export CC="$(tc-getCC)"
	export CXX="$(tc-getCXX)"
}

src_install () {
	dobin cgx

	if use doc; then
		dodoc "${WORKDIR}/${MY_P}.pdf"
	fi

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
		docinto examples
		dodoc -r "${S}"/../examples/*
	fi
}

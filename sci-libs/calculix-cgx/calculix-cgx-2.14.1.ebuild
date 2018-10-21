# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eapi7-ver

MY_PV=$(ver_cut 1-2)
MY_P=cgx_${MY_PV}

DESCRIPTION="A Three-Dimensional Structural Finite Element Program (GUI)"
HOMEPAGE="http://www.calculix.de/"
SRC_URI="http://www.dhondt.de/${MY_P}.all.tar.bz2
	doc? ( http://www.dhondt.de/${MY_P}.htm.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# nptl removed since I cannot work around it
IUSE="doc examples netgen"

#	media-libs/mesa:=[nptl]
# See src/cgx.c for the following:
# virtual/imagemagick-tools is needed for postscript hardcopies
# app-text/psutils and app-text/ghostscript-gpl are needed for
# multi-picture postscript hardcopies
# sci-visualization/gnuplot is needed for 2D plots
RDEPEND="
	app-text/psutils
	app-text/ghostscript-gpl
	>=media-libs/freeglut-1.0:=
	sci-visualization/gnuplot
	virtual/imagemagick-tools
	virtual/opengl
	x11-libs/libX11:=
	x11-libs/libXmu:=
	x11-libs/libXi:=
	x11-libs/libXext:=
	x11-libs/libXt:=
	x11-libs/libSM:=
	x11-libs/libICE:=
	netgen? ( sci-mathematics/netgen:= )
"
DEPEND="${RDEPEND}"

S=${WORKDIR}/CalculiX/cgx_${PV}

DOCS=( CHANGES INSTALL README )

PATCHES=(
	"${FILESDIR}"/${P}_Makefile-flags.patch
	"${FILESDIR}"/${P}_fix-externals.patch
)

#src_configure () {
	# Does not compile without -lpthread
#	export PTHREAD="-lpthread"
#	export LFLAGS="-L/usr/$(get_libdir) ${LFLAGS}"
#}

src_compile() {
	emake -C "${S}"/src
}

src_install () {
	dobin cgx

	if use doc; then
		# remove unneeded files from upstream creation
		rm -f "${S}"/doc/cgx/{WARNINGS,images.*,*.pl} || die "rm failed"
		# change wrong path for icons
		sed -i -e 's|/usr/share/latex2html|/usr/'$(get_libdir)'/latex2html|' "${S}"/doc/cgx/*.html || die "sed failed"
		local HTML_DOCS=( "${S}"/doc/cgx/. )
		einstalldocs
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/../examples/*
	fi
}

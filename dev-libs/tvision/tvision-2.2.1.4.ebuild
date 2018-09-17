# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Text User Interface that implements the well known CUA widgets"
HOMEPAGE="http://tvision.sourceforge.net/"
MY_PV=${PVR:0:5}-${PVR:6}
SRC_URI="mirror://sourceforge/tvision/rhtvision_${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+X debug gpm static-libs"

DOCS=( readme.txt THANKS TODO )
HTML_DOCS=( www-site/. )

S=${WORKDIR}/${PN}

# installed lib links to those
RDEPEND="sys-libs/ncurses:0
	X? ( x11-libs/libX11
		x11-libs/libXmu
		x11-libs/libxcb
		x11-libs/libXt
		x11-libs/libXext
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libSM
		x11-libs/libICE )
	dev-libs/libbsd
	sys-apps/util-linux
	gpm? ( sys-libs/gpm )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-fix-dot-INC.patch"
	"${FILESDIR}/${P}-ldconfig.patch"
	"${FILESDIR}/${P}-abs.patch"
	"${FILESDIR}/${P}-build-system.patch"
	"${FILESDIR}/${P}-flags.patch"
)

src_prepare() {
	default
}

src_configure() {
	./configure --fhs \
		--cflags="${CFLAGS} --std=c99" \
		--cxxflags="${CXXFLAGS} --std=c++98" \
		$(use_with debug debug) \
		$(usex static-libs "" --without-static) \
	|| die
}

src_install() {
	emake DESTDIR="${D}" install \
		prefix="\${DESTDIR}/usr" \
		libdir="\$(prefix)/$(get_libdir)" || die

	einstalldocs
	dosym rhtvision /usr/include/tvision

	# remove CVS directory which gets copied over
	rm -rf "${D}/usr/share/doc/${P}/html/CVS" || die

	# TODO: remove locales which are not needed, depending on current user
	# locale settings. How?
}

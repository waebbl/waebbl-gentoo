# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="OpenEXR Viewers"
HOMEPAGE="https://openexr.com/"
SRC_URI="https://github.com/AcademySoftwareFoundation/openexr/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="cg"

RDEPEND="
	~media-libs/ilmbase-${PV}:=
	~media-libs/openexr-${PV}:=
	virtual/opengl
	x11-libs/fltk:1[opengl]
	cg? (
		media-gfx/nvidia-cg-toolkit
		media-libs/freeglut
	)
"

DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/openexr-${PV}/OpenEXR_Viewers"

DOCS=( README.md doc/OpenEXRViewers.pdf )

src_prepare() {
	default
	sed -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' -i configure.ac || die "sed failed at configure.ac"
	sed -e 's:cg_prefix/lib:cg_prefix/'${get_libdir}':' -i m4/path.cb.m4 || die "sed failed at m4/path.cb.m4"
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-openexrctltest
		--with-fltk-config="/usr/bin/fltk-config"
	)

	if use cg; then
		myeconfargs+=(
			--with-cg-prefix="/opt/nvidia-cg-toolkit"
			--with-cg-libdir="/opt/nvidia-cg-toolkit/$(get_libdir)"
		)
		append-ldflags "$(no-as-needed)" # binary-only libCg is not properly linked
	fi

	econf "${myeconfargs[@]}"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		docdir=/usr/share/doc/${PF}/pdf \
		install

	einstalldocs
}

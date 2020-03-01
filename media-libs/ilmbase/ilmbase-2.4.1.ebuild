# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools multilib-minimal

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="https://openexr.com/"
SRC_URI="https://github.com/AcademySoftwareFoundation/openexr/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0/24" # based on SONAME
KEYWORDS="~amd64 -arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"
IUSE="static-libs"

RDEPEND="!media-libs/openexr-suite"
DEPEND="virtual/pkgconfig[${MULTILIB_USEDEP}]"

S="${WORKDIR}/openexr-${PV}/IlmBase"

MULTILIB_WRAPPED_HEADERS=( /usr/include/OpenEXR/IlmBaseConfigInternal.h )

src_prepare() {
	default

	# remove ${libsuffix} from LDFLAGS. There will be links with only the soname
	# getting installed
	sed -e 's|\${libsuffix}||g' -i IlmBase.pc.in || die "failed to run sed"

	eautoreconf
}

multilib_src_configure() {
	# Disable use of ucontext.h wrt #482890
	if use hppa || use ppc || use ppc64; then
		export ac_cv_header_ucontext_h=no
	fi

	ECONF_SOURCE=${S} econf "$(use_enable static-libs static)"
}

multilib_src_install_all() {
	einstalldocs

	# package provides pkg-config files
	find "${D}" -name '*.la' -delete || die
}

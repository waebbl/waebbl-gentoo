# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic toolchain-funcs multilib-minimal

DESCRIPTION="ILM's OpenEXR high dynamic-range image file format libraries"
HOMEPAGE="https://openexr.com/"
SRC_URI="https://github.com/AcademySoftwareFoundation/openexr/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0/24" # based on SONAME
KEYWORDS="~amd64 -arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"
IUSE="cpu_flags_x86_avx examples static-libs"

RDEPEND="
	!media-libs/openexr-suite
	~media-libs/ilmbase-${PV}:=[${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	>=sys-devel/autoconf-archive-2016.09.16
	virtual/pkgconfig[${MULTILIB_USEDEP}]
"

DOCS=( README.md PATENTS )
MULTILIB_WRAPPED_HEADERS=( /usr/include/OpenEXR/OpenEXRConfigInternal.h )

S="${WORKDIR}/${P}/OpenEXR"

src_prepare() {
	default

	# Fix path for testsuite
	sed -i -e "s:/var/tmp/:${T}:" IlmImfTest/tmpDir.h || die "failed to fix temp path"

	# remove ${libsuffix} from LDFLAGS. The package installs basename links
	sed -e 's|\${libsuffix}||g' -i OpenEXR.pc.in || die "failed to fix OpenEXR.pc.in"

	eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		--disable-imffuzztest
		--disable-imfhugetest
		--enable-threading
		$(use_enable cpu_flags_x86_avx avx)
		$(use_enable examples imfexamples)
		$(use_enable static-libs static)
	)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	einstalldocs

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
	else
		rm -rf "${ED}"/usr/share/doc/${PF}/examples || die "failed to remove example dir"
	fi

	# package provides .pc files
	find "${ED}" -name '*.la' -delete || die "failed to remove libtool *.la files"
}

# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_6 )

inherit autotools python-single-r1

DESCRIPTION="IlmBase Python bindings"
HOMEPAGE="https://www.openexr.com"
SRC_URI="https://github.com/AcademySoftwareFoundation/openexr/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+numpy"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	!media-libs/openexr-suite
	${PYTHON_DEPS}
	~media-libs/ilmbase-${PV}:=
	$(python_gen_cond_dep '
		>=dev-libs/boost-1.62.0-r1[python(+),${PYTHON_MULTI_USEDEP}]
		numpy? (
			|| (
				dev-python/numpy-python2[${PYTHON_MULTI_USEDEP}]
				>=dev-python/numpy-1.10.4[${PYTHON_MULTI_USEDEP}]
			)
		)
	')
"
DEPEND="${RDEPEND}"
BDEPEND=">=virtual/pkgconfig-0-r1"

S="${WORKDIR}/openexr-${PV}/PyIlmBase"

#PATCHES=(
#	"${FILESDIR}/${P}-link-pyimath.patch"
#	"${FILESDIR}/${P}-fix-build-system.patch"
#)

DOCS=( README.md )

src_prepare() {
	default

	# add multi-threaded to python library name
	sed -e 's|-lpython\$PYTHON_VERSION|-lpython\$PYTHON_VERSIONm|' \
		-i configure.ac || die "failed to patch configure.ac"

	eautoreconf
}

src_configure() {
	local boostpython_ver="${EPYTHON:6}"
	if has_version ">=dev-libs/boost-1.70.0"; then
		boostpython_ver="${boostpython_ver/./}"
	else
		boostpython_ver="-${boostpython_ver}"
	fi

	local myeconfargs=(
		--disable-boostpythontest
		--with-boost-include-dir="${EPREFIX}/usr/include/boost"
		--with-boost-lib-dir="${EPREFIX}/usr/$(get_libdir)"
		--with-boost-python-libname="boost_python${boostpython_ver}"
		$(use_with numpy)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	# Fails to install with multiple jobs
	emake DESTDIR="${D}" -j1 install

	einstalldocs

	# package provides pkg-config files
	find "${D}" -name '*.la' -delete || die
}

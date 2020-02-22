# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="emake" # ninja doesn't support fortran yet
FORTRAN_NEEDED="fortran"
FORTRAN_STANDARD="90 2003"

inherit cmake fortran-2

DESCRIPTION="CFD General Notation System standard library"
HOMEPAGE="http://www.cgns.org/"
SRC_URI="https://github.com/CGNS/CGNS/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0/3"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc examples fortran hdf5 legacy mpi static-libs szip test tools"

RDEPEND="hdf5? ( sci-libs/hdf5:=[mpi=,szip=] )
	tools? (
		dev-lang/tcl:=
		dev-lang/tk:=
		x11-libs/libXmu:=
		virtual/glu
		virtual/opengl
	)"
DEPEND="${RDEPEND}"

S="${WORKDIR}/CGNS-${PV}"

#	"${FILESDIR}"/${P}-fix-matherr.patch
PATCHES=(
	"${FILESDIR}"/${P}-fix-libdir.patch
)

pkg_setup() {
	use fortran && fortran-2_pkg_setup
}

src_prepare() {
	# dont hard code link
	sed -e '/link_directories/d' \
		-i src/tools/CMakeLists.txt src/cgnstools/*/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCGNS_BUILD_SHARED=ON
		-DCGNS_USED_SHARED=ON
		-DCGNS_BUILD_CGNSTOOLS="$(usex tools)"
		-DCGNS_ENABLE_FORTRAN="$(usex fortran)"
		-DCGNS_ENABLE_HDF5="$(usex hdf5)"
		-DCGNS_ENABLE_LEGACY="$(usex legacy)"
		-DCGNS_ENABLE_TESTS="$(usex test)"
		-DHDF5_NEED_MPI="$(usex mpi)"
		-DHDF5_NEED_SZIP="$(usex szip)"
		-DHDF5_NEED_ZLIB="$(usex szip)"
	)
	cmake_src_configure
}

src_compile() {
	# hack to allow parallel building by first producing fortran module
	use fortran && cd "${BUILD_DIR}"/src && emake cgns_f.o
	cmake_src_compile
}

src_install() {
	local DOCS=( README.md release_docs/changelog release_docs/Release.txt )
	use doc && DOCS+=( release_docs/*.pdf )

	cmake_src_install

	use static-libs || rm "${ED}"/usr/$(get_libdir)/libcgns.a

	insinto /usr/share/doc/${PF}
	use examples && doins -r src/examples
}

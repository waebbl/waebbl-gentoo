# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

FORTRAN_NEEDED=fortran
FORTRAN_NEED_OPENMP=1
# TODO: test other python implementations before adding them
PYTHON_COMPAT=( python3_6 )
CMAKE_MAKEFILE_GENERATOR="emake" # current ninja doesn't support building fortran

inherit cmake-utils fortran-2 python-single-r1

MY_P="med-${PV}"

DESCRIPTION="A library to store and exchange meshed data or computation results"
HOMEPAGE="https://www.salome-platform.org/"
SRC_URI="http://files.salome-platform.org/Salome/other/${MY_P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc fortran mpi python static-libs test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RDEPEND="
	!sci-libs/libmed
	>=sci-libs/hdf5-1.10.2:=[fortran=,mpi=]
	mpi? ( virtual/mpi[fortran=] )
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-2.0.9:0 )
"
CMAKE_BUILD_TYPE="Release"

PATCHES=(
	"${FILESDIR}/${P}-dont-bytecompile-python.patch"
	"${FILESDIR}/${P}-fix-binaries-symlink.patch"
	"${FILESDIR}/${P}-fix-install-doc.patch"
	"${FILESDIR}/${P}-fix-install-lib.patch"
	"${FILESDIR}/${P}-fix-mpi.patch"
	"${FILESDIR}/${P}-fix-h5set_fapl_mpio.patch"
)

S=${WORKDIR}/${MY_P}

DOCS=( AUTHORS ChangeLog INSTALL README TODO )

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use fortran && fortran-2_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH:BOOL=YES
		-DMEDFILE_BUILD_DOC=$(usex doc)
		-DMEDFILE_BUILD_FORTRAN=$(usex fortran)
		-DMEDFILE_BUILD_PYTHON=$(usex python)
		# static and shared libs can not be built together (see CMakeLists.txt)
		-DMEDFILE_BUILD_SHARED_LIBS=$(usex !static-libs)
		-DMEDFILE_BUILD_STATIC_LIBS=$(usex static-libs)
		-DMEDFILE_BUILD_TESTS=$(usex test)
		-DMEDFILE_INSTALL_DOC=$(usex !doc) # install pre-build docs
		-DMEDFILE_USE_MPI=$(usex mpi)
	)

	if use mpi; then
		export CC=mpicc
		export CXX=mpicxx
		export FC=mpif77
		export F77=mpif77
	fi

	cmake-utils_src_configure
}

src_test() {
	# override parallel mode for tests
	local myctestargs=( "-j 1" )
	cmake-utils_src_test
}

src_install() {
	local PYTHONDONTWRITEBYTECODE
	export PYTHONDONTWRITEBYTECODE

	DESTDIR="${ED}" cmake-utils_src_install

	use python && python_optimize

	dosym mdump3 usr/bin/mdump
	dosym xmdump3 /usr/bin/xmdump

	# prevent test executables being installed
	if use test; then
		rm -f "${ED}/usr/bin/"{test{c,f},usecases} || die
	fi
}

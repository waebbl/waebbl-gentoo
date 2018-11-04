# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

FORTRAN_NEEDED=fortran
FORTRAN_NEED_OPENMP=1
# TODO: test other python implementations before adding them
PYTHON_COMPAT=( python3_6 )

inherit cmake-utils fortran-2 python-single-r1

MY_P="med-${PV}"

DESCRIPTION="A library to store and exchange meshed data or computation results"
HOMEPAGE="https://www.salome-platform.org/"
SRC_URI="http://files.salome-platform.org/Salome/other/${MY_P}.tar.gz
	https://waebbl.github.io/libmed-3.3.1-hdf5-1.10-support.patch.gz
	https://waebbl.github.io/libmed-3.3.1-tests-python3.patch.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc fortran mpi python static-libs test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RDEPEND="
	sci-libs/hdf5[fortran=,mpi=]
	mpi? ( virtual/mpi[fortran=] )
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-2.0.9:0 )
"
CMAKE_BUILD_TYPE="Release"

# doesn't work
#	"${FILESDIR}/${P}-fix-python-import.patch"
PATCHES=(
	"${FILESDIR}/${P}-cmake-fortran.patch"
	"${FILESDIR}/${P}-cmake-swig.patch"
	"${FILESDIR}/${P}-cmake-python-compile.patch"
	"${FILESDIR}/${P}-cmake-fix-doc-installdir.patch"
	"${FILESDIR}/${P}-cmake-install-include-dir.patch"
	"${FILESDIR}/${P}-cmake-medimport-install-include-dir.patch"
	"${FILESDIR}/${P}-mpi.patch"
	"${FILESDIR}/${P}-cmakelist.patch"
)

S=${WORKDIR}/${MY_P}_SRC

DOCS=( AUTHORS ChangeLog INSTALL README TODO )

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use fortran && fortran-2_pkg_setup
}

src_prepare() {
	eapply "${WORKDIR}/${P}-hdf5-1.10-support.patch" || die
	eapply "${WORKDIR}/${P}-tests-python3.patch" || die
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DCMAKE_SKIP_RPATH:BOOL=YES
		-DMEDFILE_BUILD_FORTRAN=$(usex fortran)
		-DMEDFILE_BUILD_PYTHON=$(usex python)
		-DMEDFILE_BUILD_STATIC_LIBS=$(usex static-libs)
		-DMEDFILE_BUILD_TESTS=$(usex test)
		-DMEDFILE_INSTALL_DOC=$(usex doc)
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
	# workaround to fix 'import medenum' statement in installed python files
	if use python; then
		sed -i -e 's|import medenum|from . import medenum|' "${BUILD_DIR}"/python/med/*.py || die
	fi

	DESTDIR="${D}" cmake-utils_src_install

	dosym mdump3 usr/bin/mdump
	dosym xmdump3 /usr/bin/xmdump

	# prevent test executables being installed
	if use test; then
		rm -f "${D}/usr/bin/"{test{c,f},usecases} || die
	fi
}

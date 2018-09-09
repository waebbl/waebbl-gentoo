# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

FORTRAN_NEEDED=fortran
FORTRAN_NEED_OPENMP=1

PYTHON_COMPAT=( python{2_7,3_6} )

inherit cmake-utils fortran-2 python-single-r1

MY_P="med-${PV}"

DESCRIPTION="A library to store and exchange meshed data or computation results"
HOMEPAGE="http://www.salome-platform.org/"
SRC_URI="http://files.salome-platform.org/Salome/other/${MY_P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc fortran python static-libs test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RDEPEND="
	sci-libs/hdf5[fortran=]
	sys-cluster/openmpi[fortran=]
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-2.0.9:0 )
"
CMAKE_BUILD_TYPE="Release"

#	"${FILESDIR}/hdf5-1.10-support.patch"
PATCHES=(
	"${FILESDIR}/${P}-cmake-fortran.patch"
	"${FILESDIR}/${P}-cmake-swig.patch"
	"${FILESDIR}/${P}-cmake-no-python-compile.patch"
	"${FILESDIR}/${P}-cmake-fix-doc-installdir.patch"
	"${FILESDIR}/${P}-nosymlink.patch"
)

S=${WORKDIR}/${MY_P}_SRC

DOCS=( AUTHORS ChangeLog INSTALL README )

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use fortran && fortran-2_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DMEDFILE_BUILD_FORTRAN="$(usex fortran)"
		-DMEDFILE_BUILD_PYTHON="$(usex python)"
		-DMEDFILE_BUILD_STATIC_LIBS="$(usex static-libs)"
		-DMEDFILE_BUILD_TESTS="$(usex test)"
		-DMEDFILE_INSTALL_DOC="$(usex doc)"
	)

	cmake-utils_src_configure
}

src_install() {
	DESTDIR="${D}" cmake-utils_src_install

	dosym mdump3 usr/bin/mdump
	dosym xmdump3 /usr/bin/xmdump

#	python_optimize
}

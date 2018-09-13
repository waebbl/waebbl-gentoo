# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_6 )

inherit cmake-utils python-single-r1

DESCRIPTION="Automatic 3d tetrahedal mesh generator"
HOMEPAGE="https://ngsolve.org/"
SRC_URI="https://github.com/NGSolve/netgen/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="LGPL-2.1"

SLOT="0"
KEYWORDS="~amd64"

# opencascade not supported upstream?
IUSE="ffmpeg jpeg mpi opencascade +python"

COMMON_DEPEND="
	dev-lang/tcl:0
	dev-lang/tk:0
	dev-tcltk/tix
	dev-tcltk/togl:0
	sys-libs/zlib
	virtual/opengl
	x11-libs/libICE
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXmu
	ffmpeg? ( virtual/ffmpeg )
	jpeg? ( virtual/jpeg:0= )
	python? ( dev-util/pybind11 )
	mpi? (
		>=sci-libs/parmetis-4.0.3[mpi?]
		virtual/mpi[cxx,threads]
		opencascade? ( sci-libs/hdf5[mpi] )
	)
	opencascade? ( sci-libs/opencascade:7.3.0=[ffmpeg?] )
"

DEPEND="
	${PYTHON_DEPS}
	${COMMON_DEPEND}
	>=dev-util/cmake-3.9.6
"

RDEPEND="
	${PYTHON_DEPS}
	${COMMON_DEPEND}
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}"/${P}-cmake-fix-paths.patch
)

DOCS=( AUTHORS NEWS README.md TODO )

src_prepare() {
	cmake-utils_src_prepare

	cp "${S}"/doc/ng4.pdf "${S}"
}

src_configure() {
	mycmakeargs=(
		-DINSTALL_PROFILES=ON
		-DUSE_CCACHE=OFF
		-DUSE_GUI=ON
		-DUSE_JPEG=$(usex jpeg)
		-DUSE_MPEG=$(usex ffmpeg)
		-DUSE_MPI=$(usex mpi)
		-DUSE_OCC=$(usex opencascade)
		-DUSE_PYTHON=$(usex python)
		-DUSE_SUPERBUILD=OFF
	)

	if use opencascade; then
		mycmakeargs+=(
			-DOCC_INCLUDE_DIR="${CASROOT}"/include/opencascade
			-DOCC_LIBRARY="${CASROOT}"/lib
		)
	fi

	if use mpi; then
		export CC=mpicc
		export CXX=mpicxx
		export FC=mpif90
		export F90=mpif90
		export F77=mpif77
	fi

	# internal togl needs tkInt.h
	append-cppflags " \
		-I/usr/$(get_libdir)/tk8.6/include/generic \
		-I/usr/$(get_libdir)/tk8.6/include/unix \
	"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	dosym ../../${PN}/doc/ng4.pdf /usr/share/doc/${PF}/ng4.pdf
}

pkg_postinst() {
	einfo "Remember to run env-update && source /etc/profile"
	einfo "NOTE: opencascade is currently not tested!"
}

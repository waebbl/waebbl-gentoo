# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# FIXME: add java support (java? ( !mpi )
# FIXME: add test USE flag

FORTRAN_NEEDED=fortran

inherit cmake-utils fortran-2 multilib multiprocessing prefix toolchain-funcs

MAJOR_P=${PN}-$(ver_cut 1-2 ${PV})

DESCRIPTION="General purpose library and file format for storing scientific data"
HOMEPAGE="https://www.hdfgroup.org/HDF5/"
SRC_URI="https://support.hdfgroup.org/ftp/HDF5/releases/${MAJOR_P}/${P}/src/CMake-${P}.tar.gz -> ${P}.tar.gz"

LICENSE="NCSA-HDF"
SLOT="0/${PV%%_p*}"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="cxx debug examples fortran +hl mpi static-libs szip threads zlib"

REQUIRED_USE="
	cxx? ( !mpi ) mpi? ( !cxx )
	threads? ( !cxx !mpi !fortran !hl )"

RDEPEND="
	mpi? ( virtual/mpi[romio] )
	szip? ( virtual/szip )
	zlib? ( sys-libs/zlib:0= )"

DEPEND="${RDEPEND}
	>=dev-util/cmake-3.10.3"

S="${WORKDIR}/CMake-${P}/${P}"

pkg_setup() {
#	tc-export CXX CC AR # workaround for bug 285148
	use fortran && fortran-2_pkg_setup

	if use mpi; then
		if has_version 'sci-libs/hdf5[-mpi]'; then
			ewarn "Installing hdf5 with mpi enabled with a previous hdf5 with mpi disabled may fail."
			ewarn "Try to uninstall the current hdf5 prior to enabling mpi support."
		fi
		export CC=mpicc
		use fortran && export FC=mpif90
	elif has_version 'sci-libs/hdf5[mpi]'; then
		ewarn "Installing hdf5 with mpi disabled while having hdf5 installed with mpi enabled may fail."
		ewarn "Try to uninstall the current hdf5 prior to disabling mpi support."
	fi
}

src_prepare() {
	cp "${FILESDIR}"/HDF5options.cmake "${WORKDIR}/CMake-${P}" || die "Failed to copy options file"

	sed \
		-e 's|MAX_PROC_COUNT 8|MAX_PROC_COUNT '$(makeopts_jobs)'|' \
		-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die

	if use fortran; then
		sed \
			-e 's|-DHDF5_BUILD_FORTRAN:BOOL=OFF|-DHDF5_BUILD_FORTRAN:BOOL=ON|' \
			-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	if use prefix; then
		sed \
			-e 's|-DCMAKE_INSTALL_PREFIX:PATH=/usr|-DCMAKE_INSTALL_PREFIX:PATH='${EPREFIX}'/usr|' \
			-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	if use zlib; then
		sed \
			-e 's|-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=OFF|-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON|' \
			-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	if use szip; then
		sed \
			-e 's|-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=OFF|-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON|' \
			-e 's|-DHDF5_ENABLE_SZIP_ENCODING:BOOL=OFF|-DHDF5_ENABLE_SZIP_ENCODING:BOOL=ON|' \
			-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	if use mpi; then
		sed \
			-e 's|-DHDF5_ENABLE_PARALLEL:BOOL=OFF|-DHDF5_ENABLE_PARALLEL:BOOL=ON|' \
			-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	if use cxx; then
		sed \
			-e 's|-DHDF5_BUILD_CPP_LIB:BOOL:OFF|-DHDF5_BUILD_CPP_LIB:BOOL=ON|' \
			-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	if use threads; then
		sed \
			-e 's|-DHDF5_ENABLE_THREADSAFE:BOOL=OFF|-DHDF5_ENABLE_THREADSAFE:BOOL=ON|' \
			-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	if use static-libs; then
		echo 'set (ADD_BUILD_OPTIONS "${ADD_BUILD_OPTIONS}" -DBUILD_SHARED_LIBS:BOOL=OFF)' >> "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die
	fi

	sed \
		-e 's|/usr/lib|/usr/'$(get_libdir)'|' \
		-i "${WORKDIR}/CMake-${P}"/HDF5options.cmake || die

	cmake-utils_src_prepare
}

src_install() {
	local DOCS=( "${S}/release_docs/." )
	cmake-utils_src_install

	# hack as their cmake routines don't respect passed arguments
	mv "${ED}"/usr/lib "${ED}"/usr/$(get_libdir) || die

	use static-libs || (rm -f "${ED}"/usr/$(get_libdir)/*.a || die)

	# twice installed, they're already in /usr/share/doc/${PF}
	rm -f "${ED}"/usr/share/{COPYING,RELEASE.txt,USING_HDF5_CMake.txt} || die
}

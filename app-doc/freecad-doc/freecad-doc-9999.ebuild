# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="emake"
inherit check-reqs cmake git-r3

DESCRIPTION="QT based computer aided design application manuals"
HOMEPAGE="https://www.freecadweb.org/"

EGIT_REPO_URI="https://github.com/FreeCAD/FreeCAD.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="
	>=media-libs/coin-4.0.0:=[doc]
	>=sci-libs/med-4.0.0
	>=sci-libs/opencascade-7.3.0:=
	>=virtual/mpi-2.0-r4:=[cxx,threads]
"
DEPEND="
	>=app-doc/doxygen-1.8.14-r1[dot]
"

PATCHES=(
	"${FILESDIR}/${P}-find-libmed.patch"
	"${FILESDIR}/${P}-find-Coin.tag.patch"
)

CMAKE_BUILD_TYPE=Release
CHECKREQS_DISK_BUILD="10G"

pkg_setup() {
	check-reqs_pkg_setup
}

src_prepare() {
	# FIXME: improve this to handle MAKEOPTS vars which also contain
	# load values, i.e. MAKEOPTS="-j8 -l5"
	local mymakeopts=$(portageq envvar MAKEOPTS)
	mymakeopts=${mymakeopts##-j}
	sed -i -e 's|DOT_NUM_THREADS[ \t]*= 0|DOT_NUM_THREADS = '${mymakeopts}'|' "${S}/src/Doc/BuildDevDoc.cfg.in" || die
	# upstream provided FindCoin3D.cmake doesn't find coin, but cmake
	# provided one does, so delete the local file
	rm -f "${S}"/cMake/FindCoin3D.cmake || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_FEM:BOOL=YES
		-DBUILD_GUI:BOOL=YES
		-DBUILD_QT5=YES
		-DCMAKE_INSTALL_DOCDIR=/usr/share/doc/${PF}
		-DOCC_INCLUDE_DIR="${CASROOT}"/include/opencascade
		-DOCC_LIBRARY_DIR="${CASROOT}"/$(get_libdir)
		-DOPENMPI_INCLUDE_DIRS=/usr/include
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile DevDoc
}

src_install() {
	local DOCS=( "${BUILD_DIR}"/doc/freecad.{qhc,qch} )
	local HTML_DOCS=(
		"${BUILD_DIR}"/doc/ThirdPartyLibraries.html
		"${BUILD_DIR}"/doc/SourceDocu/html/.
	)
	einstalldocs
}

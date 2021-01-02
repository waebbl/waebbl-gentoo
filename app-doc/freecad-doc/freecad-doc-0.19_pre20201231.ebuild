# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit check-reqs cmake multiprocessing

DESCRIPTION="QT based computer aided design application manuals"
HOMEPAGE="https://www.freecadweb.org/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/FreeCAD/FreeCAD.git"
else
	COMMIT=82ec99dbc1f0f054748059ae8bb138eb44b43073
	SRC_URI="https://github.com/FreeCAD/FreeCAD/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="oce"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="
	app-doc/doxygen[dot]
	dev-libs/boost:=
	dev-libs/xerces-c
	dev-qt/designer:5
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsvg:5
	dev-qt/qtwebengine:5[widgets]
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	dev-qt/qtxmlpatterns:5
	media-libs/coin[doc]
	sci-libs/med
	oce? ( sci-libs/oce[vtk(+)] )
	!oce? ( sci-libs/opencascade:=[vtk(+)] )
"

S="${WORKDIR}/FreeCAD-${COMMIT}"

CHECKREQS_DISK_BUILD="13G"

pkg_setup() {
	check-reqs_pkg_setup
	if ! use oce; then
		[[ -z "${CASROOT}" ]] && die "\${CASROOT} is not set, please run eselect opencascade"
	fi
}

src_prepare() {
	# respect MAKEOPTS when using dot. The package builds 25k+ images,
	# and overheats my machine if run on all cores.
	sed -e 's|DOT_NUM_THREADS[ \t]*= 0|DOT_NUM_THREADS = '$(makeopts_jobs)'|' \
		-i "${S}/src/Doc/BuildDevDoc.cfg.in" || die
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
		-DOCCT_CMAKE_FALLBACK=ON
	)

	if use oce; then
		mycmakeargs+=(
			-DFREECAD_USE_OCC_VARIANT:STRING="Community Edition"
			-DOCC_INCLUDE_DIR=/usr/include/oce
			-DOCC_LIBRARY_DIR=/usr/$(get_libdir)
		)
	else
		mycmakeargs+=(
			-DFREECAD_USE_OCC_VARIANT:STRING="Official Version"
			-DOCC_INCLUDE_DIR="${CASROOT}"/include/opencascade
			-DOCC_LIBRARY_DIR="${CASROOT}"/$(get_libdir)
		)
	fi

	cmake_src_configure
}

src_compile() {
	einfo "Please be patient, the build can take a considerable amount of time"
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

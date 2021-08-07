# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit check-reqs cmake git-r3 multiprocessing

DESCRIPTION="QT based computer aided design application manuals"
HOMEPAGE="https://www.freecadweb.org/"

EGIT_REPO_URI="https://github.com/FreeCAD/FreeCAD.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="
	dev-libs/utfcpp
	dev-libs/xerces-c[icu]
	dev-qt/qtconcurrent:5
	dev-qt/designer:5
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsvg:5
	dev-qt/qtwebengine:5
	dev-qt/qtxml:5
	dev-qt/qtxmlpatterns:5
	>=media-libs/coin-4.0.0:=[doc]
	>=sci-libs/med-4.0.0
	sci-libs/opencascade:7.5=[vtk]
	sci-libs/vtk:=[boost,python,qt5,rendering]
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-doc/doxygen[dot]
	app-text/dos2unix
"

PATCHES=(
	"${FILESDIR}/${P}-find-libmed.patch"
	"${FILESDIR}/${P}-find-Coin.tag.patch"
)

CMAKE_BUILD_TYPE=Release
CHECKREQS_DISK_BUILD="13G"

pkg_setup() {
	check-reqs_pkg_setup
}

src_prepare() {
	sed -e 's|DOT_NUM_THREADS[ \t]*= 0|DOT_NUM_THREADS = '$(makeopts_jobs)'|' \
		-i "${S}"/src/Doc/BuildDevDoc.cfg.in || die "Failed to change DOT_NUM_THREADS"

	sed -e 's|doc/SourceDocu|doc|' \
		-i "${S}"/src/Doc/CMakeLists.txt || die "Failed to change output dir"

	# upstream provided FindCoin3D.cmake doesn't find coin, but cmake
	# provided one does, so delete the local file
	rm "${S}"/cMake/FindCoin3D.cmake || die "Removing FindCoin3D.cmake failed"

	# to allow patch to find Coin.tag to succeed, due to different line endings
	dos2unix "${S}"/cMake/FindCoin3DDoc.cmake || die "Can't convert FindCoind3DDoc.cmake"

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_FEM:BOOL=YES
		-DBUILD_GUI:BOOL=YES
		-DBUILD_QT5=YES
	)
	cmake_src_configure
}

src_compile() {
	cmake_build DevDoc
}

src_install() {
	local HTML_DOCS=( "${BUILD_DIR}"/doc/html/. )
	einstalldocs
}

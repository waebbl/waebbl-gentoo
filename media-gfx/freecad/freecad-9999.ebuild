# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# As of 2017-12-30 only python3_5 works (that is FreeCAD does not crash on startup)
PYTHON_COMPAT=( python3_6 )

inherit cmake-utils desktop eutils xdg-utils gnome2-utils python-single-r1 git-r3

DESCRIPTION="QT based Computer Aided Design application"
HOMEPAGE="http://www.freecadweb.org/"

EGIT_REPO_URI="https://github.com/FreeCAD/FreeCAD.git"
#EGIT_REPO_URI="file:///mnt/data/code/github/freecad/"
EGIT_BRANCH="master"
#EGIT_COMMIT="0258808"

LICENSE="GPL-2"
SLOT="0"

# TODO:
#   vr: needs a rift package: does this make sense? Currently they don't have
#		support for linux. The last linux package dates back to 2015!
#	netgen: sci-mathematics/netgen: doesn't compile -> upstream sci overlay
#	openscad: media-gfx/openscad
#	smesh: needs a salome-platform package
#	zipio++: needs a package
IUSE_FREECAD_MODULES="
	+freecad_modules_addonmgr
	+freecad_modules_arch
	freecad_modules_assembly
	+freecad_modules_complete
	+freecad_modules_draft
	+freecad_modules_drawing
	+freecad_modules_fem
	+freecad_modules_idf
	+freecad_modules_image
	+freecad_modules_import
	+freecad_modules_inspection
	freecad_modules_jtreader
	+freecad_modules_material
	+freecad_modules_mesh
	+freecad_modules_mesh_part
	freecad_modules_openscad
	+freecad_modules_part
	+freecad_modules_part_design
	+freecad_modules_path
	+freecad_modules_plot
	+freecad_modules_points
	+freecad_modules_raytracing
	+freecad_modules_reverseengineering
	+freecad_modules_robot
	freecad_modules_sandbox
	+freecad_modules_ship
	+freecad_modules_show
	+freecad_modules_sketcher
	freecad_modules_smesh
	+freecad_modules_spreadsheet
	+freecad_modules_start
	+freecad_modules_surface
	+freecad_modules_techdraw
	freecad_modules_template
	+freecad_modules_test
	+freecad_modules_tux
	+freecad_modules_web"
IUSE="eigen3 +freetype pcl +qt5 swig ${IUSE_FREECAD_MODULES}"

COMMON_DEPEND="
	${PYTHON_DEPS}
	dev-libs/boost:=[python,${PYTHON_USEDEP}]
	dev-libs/xerces-c[icu]
	sci-libs/libmed[fortran,python,${PYTHON_USEDEP}]
	sci-libs/orocos_kdl
	sci-libs/opencascade:7.3.0[vtk(+)]
	sys-cluster/openmpi
	sys-libs/zlib
	virtual/glu
	virtual/opengl
	eigen3? ( dev-cpp/eigen:3 )
	freecad_modules_draft? ( dev-python/pyside:2[svg,${PYTHON_USEDEP}] )
	freecad_modules_plot? ( dev-python/matplotlib[${PYTHON_USEDEP}] )
	freecad_modules_smesh? (
		sci-libs/hdf5
		sys-cluster/openmpi[cxx]
	)
	freetype? ( media-libs/freetype )
	pcl? ( >=sci-libs/pcl-1.8.1[qt5,vtk(+)] )
	qt5? (
		dev-libs/libspnav
		dev-python/pyside:2[concurrent,network,opengl,printsupport,svg,xmlpatterns,webkit,${PYTHON_USEDEP}]
		dev-python/shiboken:2[${PYTHON_USEDEP}]
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5
		dev-qt/qtopengl:5
		dev-qt/qtprintsupport:5
		dev-qt/qtsvg:5
		dev-qt/qtwebkit:5
		dev-qt/qtxml:5
		media-libs/coin
	)"
RDEPEND="${COMMON_DEPEND}
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pivy[${PYTHON_USEDEP}]"
DEPEND="${COMMON_DEPEND}
	qt5? ( dev-python/pyside-tools:2[${PYTHON_USEDEP}] )
	swig? ( dev-lang/swig:= )"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
CMAKE_BUILD_TYPE=Release

DOCS=( README.md ChangeLog.txt )

PATCHES=(
	"${FILESDIR}/smesh-pthread.patch"
	"${FILESDIR}/freecad-ModPath-find-boost_python.patch"
	)

enable_module() {
	local module=${1}
	local value=${2}

	if [ -z "${value}" ]; then
		value=$(use freecad_modules_${module} && echo ON || echo OFF)
	fi

	echo "-DBUILD_${module^^}=${value}"
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	# the upstream provided file doesn't find coin, but cmake ships
	# a working one, so we use this.
	rm -f "${S}/cMake/FindCoin3D.cmake"
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_FREETYPE="$(usex freetype)"
		-DBUILD_GUI="$(usex qt5)"
		-DBUILD_QT5="$(usex qt5)"
		-DCMAKE_INSTALL_DATADIR=/usr/share/${PN}
		-DCMAKE_INSTALL_DOCDIR=/usr/share/doc/${PF}
		-DCMAKE_INSTALL_INCLUDEDIR=/usr/include/${PN}
		-DCMAKE_INSTALL_PREFIX=/usr/$(get_libdir)/${PN}
		-DFREECAD_USE_EXTERNAL_SMESH=0
		-DFREECAD_USE_EXTERNAL_KDL="ON"
		-DFREECAD_USE_PCL=$(usex pcl)
		# opencascade-7.3.0 sets CASROOT in /etc/env.d/51opencascade
		-DOCC_INCLUDE_DIR=${CASROOT}/include/opencascade
		-DOCC_LIBRARY_DIR=${CASROOT}/lib
		-DOPENMPI_INCLUDE_DIRS=/usr/include/
		$(enable_module addonmgr)
		$(enable_module arch)
		$(enable_module assembly)
		$(enable_module complete)
		$(enable_module draft)
		$(enable_module drawing)
		$(enable_module fem)
		$(enable_module idf)
		$(enable_module image)
		$(enable_module import)
		$(enable_module inspection)
		$(enable_module jtreader)
		$(enable_module material)
		$(enable_module mesh)
		$(enable_module mesh_part)
		$(enable_module openscad)
		$(enable_module part)
		$(enable_module part_design)
		$(enable_module path)
		$(enable_module plot)
		$(enable_module points)
		$(enable_module raytracing)
		$(enable_module reverseengineering)
		$(enable_module robot)
		$(enable_module sandbox)
		$(enable_module ship)
		$(enable_module show)
		$(enable_module sketcher)
		$(enable_module smesh)
		$(enable_module spreadsheet)
		$(enable_module start)
		$(enable_module surface)
		$(enable_module techdraw)
		$(enable_module template)
		$(enable_module test)
		$(enable_module tux)
		$(enable_module web)
	)

	cmake-utils_src_configure
#	einfo "${P} will be built against opencascade version ${CASROOT}"
}

src_install() {
	cmake-utils_src_install

	dosym ../$(get_libdir)/${PN}/bin/FreeCAD /usr/bin/freecad
	dosym ../$(get_libdir)/${PN}/bin/FreeCADCmd /usr/bin/freecadcmd

	make_desktop_entry freecad "FreeCAD" "" "" "MimeType=application/x-extension-fcstd;"

	# install mimetype for FreeCAD files
	insinto /usr/share/mime/packages
	newins "${FILESDIR}"/${PN}.sharedmimeinfo "${PN}.xml"

	insinto /usr/share/pixmaps
	newins "${S}"/src/Gui/Icons/${PN}.xpm "${PN}.xpm"

	# install icons to correct place rather than /usr/share/freecad
	local size
	for size in 16 32 48 64; do
		newicon -s ${size} "${S}"/src/Gui/Icons/${PN}-icon-${size}.png ${PN}.png
	done
	doicon -s scalable "${S}"/src/Gui/Icons/${PN}.svg
	newicon -s 64 -c mimetypes "${S}"/src/Gui/Icons/${PN}-doc.png application-x-extension-fcstd.png

	rm "${ED}"/usr/share/${PN}/${PN}-{doc,icon-{16,32,48,64}}.png
	rm "${ED}"/usr/share/${PN}/${PN}.svg
	rm "${ED}"/usr/share/${PN}/${PN}.xpm

	python_optimize "${ED%/}"/usr/share/${PN}/Mod/ "${ED%/}"/usr/$(get_libdir)/${PN}{/Ext,/Mod}/
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# As of 2017-12-30 only python3_5 works (that is FreeCAD does not crash on startup)
PYTHON_COMPAT=( python3_6 )

inherit check-reqs cmake-utils desktop eutils xdg-utils gnome2-utils python-single-r1 git-r3

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
#	netgen: sci-mathematics/netgen: updated version, but FreeCAD doesn't compile
#		against it, probably due to a needed external smesh with netgen support
#	smesh: needs a salome-platform package
#	zipio++: FreeCAD uses quite outdated zipio and doesn't compile against.
#		new versions. Ebuild is available in overlay.

# looks like netgen needs external smesh compiled with netgen support
IUSE="eigen3 +freetype pcl +qt5 swig -system-smesh" # netgen

FREECAD_EXPERIMENTAL_MODULES="assembly inspection path reverseengineering"
FREECAD_DEBUG_MODULES="sandbox template test"
FREECAD_STABLE_MODULES="addonmgr arch complete draft drawing fem idf
	image import jtreader material mesh mesh_part flat_mesh openscad
	part part_design plot points raytracing robot ship show sketcher
	smesh spreadsheet start surface techdraw tux web"

FREECAD_DISABLED_MODULES="vr"
FREECAD_ALL_MODULES="${FREECAD_STABLE_MODULES}
	${FREECAD_EXPERIMENTAL_MODULES} ${FREECAD_DEBUG_MODULES}"

for module in ${FREECAD_ALL_MODULES}; do
	IUSE="${IUSE} freecad_modules_${module}"
done
unset module

#	netgen? ( >=sci-mathematics/netgen-6.2.1804:=[mpi,opencascade,${PYTHON_USEDEP}] )
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/boost:=[python,${PYTHON_USEDEP}]
	dev-libs/xerces-c[icu]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pivy:=[${PYTHON_USEDEP}]
	sci-libs/libmed:=[fortran,python,${PYTHON_USEDEP}]
	sci-libs/orocos_kdl:=
	sci-libs/opencascade:7.3.0=[vtk(+)]
	sys-libs/zlib
	virtual/glu
	virtual/mpi[cxx,fortran,threads]
	virtual/opengl
	eigen3? ( dev-cpp/eigen:3= )
	freecad_modules_draft? ( dev-python/pyside:2=[svg,${PYTHON_USEDEP}] )
	freecad_modules_plot? ( dev-python/matplotlib[${PYTHON_USEDEP}] )
	freecad_modules_openscad? ( media-gfx/openscad:= )
	freecad_modules_smesh? ( sci-libs/hdf5:= )
	freetype? ( media-libs/freetype )
	pcl? ( >=sci-libs/pcl-1.8.1:=[qt5,vtk(+)] )
	qt5? (
		dev-libs/libspnav
		dev-python/pyside:2=[gui,svg,${PYTHON_USEDEP}]
		dev-python/shiboken:2=[${PYTHON_USEDEP}]
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5
		dev-qt/qtopengl:5
		dev-qt/qtprintsupport:5
		dev-qt/qtsvg:5
		dev-qt/qtwebkit:5
		dev-qt/qtxml:5
		media-libs/coin:=[draggers(+),manipulators(+),nodekits(+),simage]
	)
"
DEPEND="
	${RDEPEND}
	qt5? ( dev-python/pyside-tools:2[${PYTHON_USEDEP}] )
	swig? ( dev-lang/swig )
"

# To get required dependencies: 'grep REQUIRED_MODS CMakeLists.txt'
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	freecad_modules_arch? ( freecad_modules_part freecad_modules_mesh freecad_modules_draft )
	freecad_modules_draft? ( freecad_modules_sketcher )
	freecad_modules_drawing? ( freecad_modules_part freecad_modules_spreadsheet )
	freecad_modules_fem? ( freecad_modules_part freecad_modules_smesh )
	freecad_modules_idf? ( freecad_modules_part )
	freecad_modules_import? ( freecad_modules_part )
	freecad_modules_inspection? ( freecad_modules_mesh freecad_modules_points freecad_modules_part )
	freecad_modules_jtreader? ( freecad_modules_mesh )
	freecad_modules_mesh_part? ( freecad_modules_part freecad_modules_mesh freecad_modules_smesh )
	freecad_modules_flat_mesh? ( freecad_modules_part )
	freecad_modules_openscad? ( freecad_modules_part freecad_modules_draft )
	freecad_modules_part_design? ( freecad_modules_sketcher )
	freecad_modules_path? ( freecad_modules_part freecad_modules_robot )
	freecad_modules_raytracing? ( freecad_modules_part )
	freecad_modules_reverseengineering? ( freecad_modules_part freecad_modules_mesh )
	freecad_modules_robot? ( freecad_modules_part )
	freecad_modules_sandbox? ( freecad_modules_part freecad_modules_mesh )
	freecad_modules_ship? ( freecad_modules_part freecad_modules_plot freecad_modules_image )
	freecad_modules_sketcher? ( freecad_modules_part )
	freecad_modules_spreadsheet? ( freecad_modules_draft )
	freecad_modules_start? ( freecad_modules_web )
	freecad_modules_techdraw? ( freecad_modules_part freecad_modules_spreadsheet freecad_modules_drawing )
"

CMAKE_BUILD_TYPE=Release

DOCS=( README.md ChangeLog.txt )

# FIXME: Check the find-Coin.tag patch after updates of media-libs/coin
PATCHES=(
	"${FILESDIR}/smesh-pthread.patch"
	"${FILESDIR}/freecad-ModPath-find-boost_python.patch"
	"${FILESDIR}/${P}-find-libmed.patch"
	"${FILESDIR}/${P}-find-Coin.tag.patch"
	)

CHECKREQS_DISK_BUILD="4G"

pkg_setup() {
	check-reqs_pkg_setup
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
#		-DBUILD_FEM_NETGEN="$(usex netgen)"
		-DBUILD_FREETYPE="$(usex freetype)"
		-DBUILD_GUI="$(usex qt5)"
		-DBUILD_QT5="$(usex qt5)"
		-DCMAKE_INSTALL_DATADIR=/usr/share/${PN}/data
		-DCMAKE_INSTALL_DOCDIR=/usr/share/doc/${PF}
		-DCMAKE_INSTALL_INCLUDEDIR=/usr/include/${PN}
		-DCMAKE_INSTALL_PREFIX=/usr/$(get_libdir)/${PN}
		-DFREECAD_USE_EXTERNAL_SMESH=0
		-DFREECAD_USE_EXTERNAL_KDL="ON"
		-DFREECAD_USE_PCL=$(usex pcl)
		# opencascade-7.3.0 sets CASROOT in /etc/env.d/51opencascade
		-DOCC_INCLUDE_DIR="${CASROOT}"/include/opencascade
		-DOCC_LIBRARY_DIR="${CASROOT}"/$(get_libdir)
		-DOPENMPI_INCLUDE_DIRS=/usr/include/
	)

	# disable vr module by default for now
	for module in ${FREECAD_DISABLED_MODULES}; do
		mycmakeargs+=( -DBUILD_${module}=OFF )
	done

	# enable all modules
	for module in ${FREECAD_ALL_MODULES}; do
		if has ${module} ${FREECAD_ALL_MODULES}; then
			mycmakeargs+=( -DBUILD_${module}=ON )
		fi
	done

# NOTE: using mpi wrappers currently produces insecure runpaths in smesh
#		libraries.
#	export CC=mpicc
#	export CXX=mpicxx
#	export FC=mpif77
#	export F77=mpif77

	cmake-utils_src_configure
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

	rm "${ED}"/usr/share/${PN}/data/${PN}-{doc,icon-{16,32,48,64}}.png || die
	rm "${ED}"/usr/share/${PN}/data/${PN}.svg || die
	rm "${ED}"/usr/share/${PN}/data/${PN}.xpm || die

	python_optimize "${ED%/}"/usr/share/${PN}/data/Mod/ "${ED%/}"/usr/$(get_libdir)/${PN}{/Ext,/Mod}/
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

# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# TODO:
# install the src files referenced in 51opencascade

EAPI=6

inherit check-reqs cmake-utils eapi7-ver eutils flag-o-matic java-pkg-opt-2 multilib

DESCRIPTION="Development platform for CAD/CAE, 3D surface/solid modeling and data exchange"
HOMEPAGE="http://www.opencascade.com/"
# convert version string x.x.x to x_x_x
MY_PV="$(ver_rs 1- '_')"
SRC_URI="https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=refs/tags/V${MY_PV};sf=tgz -> ${P}.tar.gz"

LICENSE="|| ( Open-CASCADE-LGPL-2.1-Exception-1.0 LGPL-2.1 )"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"
# TODO: test pch use flag
IUSE="debug doc examples ffmpeg freeimage gl2ps gles2 inspector java qt5 tbb test +vtk"

REQUIRED_USE="
	inspector? ( qt5 )
"

RDEPEND="app-eselect/eselect-opencascade
	dev-lang/tcl:0=
	dev-lang/tk:0=
	dev-tcltk/itcl
	dev-tcltk/itk
	dev-tcltk/tix
	media-libs/freetype:2
	media-libs/ftgl
	virtual/glu
	virtual/opengl
	x11-libs/libXmu
	ffmpeg? ( virtual/ffmpeg )
	freeimage? ( media-libs/freeimage )
	gl2ps? ( x11-libs/gl2ps )
	java? ( >=virtual/jdk-0:= )
	qt5? (
		dev-qt/qtcore
		dev-qt/qtgui
		dev-qt/qtquickcontrols2
		dev-qt/qtwidgets
		dev-qt/qtxml
	)
	tbb? ( dev-cpp/tbb )
	vtk? ( sci-libs/vtk[rendering] )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

# https://bugs.gentoo.org/show_bug.cgi?id=352435
# https://www.gentoo.org/foundation/en/minutes/2011/20110220_trustees.meeting_log.txt
RESTRICT="bindist"

CHECKREQS_MEMORY="256M"
CHECKREQS_DISK_BUILD="3584M"

CMAKE_BUILD_TYPE=Release

S="${WORKDIR}/occt-V${MY_PV}"

PATCHES=(
	"${FILESDIR}"/ffmpeg4.patch
	"${FILESDIR}"/fix-install-dir-references.patch
	"${FILESDIR}"/vtk7.patch
	"${FILESDIR}"/${P}-find-qt.patch
	)

pkg_setup() {
	check-reqs_pkg_setup
	use java && java-pkg-opt-2_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare
	use java && java-pkg-opt-2_src_prepare
}

src_configure() {
	local mycmakeargs=(
# 		-DBUILD_USE_PCH=$(usex pch)	# TODO: test pch use flag
		-DBUILD_DOC_Overview=$(usex doc)
		-DBUILD_Inspector=$(usex inspector)
		-DBUILD_WITH_DEBUG=$(usex debug)
		-DCMAKE_CONFIGURATION_TYPES="Gentoo"
		-DCMAKE_INSTALL_PREFIX="/usr/$(get_libdir)/${P}/ros"
		-DINSTALL_DIR_DOC="/usr/share/doc/${P}"
		-DINSTALL_DIR_CMAKE="/usr/$(get_libdir)/cmake"
		-DINSTALL_DOC_Overview=$(usex doc)
		-DINSTALL_SAMPLES=$(usex examples)
		-DINSTALL_TEST_CASES=$(usex test)
		-DUSE_D3D=no
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_FREEIMAGE=$(usex freeimage)
		-DUSE_GL2PS=$(usex gl2ps)
		-DUSE_GLES2=$(usex gles2)
		-DUSE_TBB=$(usex tbb)
		-DUSE_VTK=$(usex vtk)		
	)

	use examples && mycmakeargs += ( -DBUILD_SAMPLES_QT=$(usex qt5) )
	
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# make draw.sh and inspector.sh (if selected) non-world-writable
	chmod go-w "${D}/${EROOT}/usr/$(get_libdir)/${P}/ros/bin/draw.sh"
	use inspector && chmod go-w "${D}/${EROOT}/usr/$(get_libdir)/${P}/ros/bin/inspector.sh"
	
	# /etc/env.d
	sed -e "s|VAR_CASROOT|${EROOT}usr/$(get_libdir)/${P}/ros|g" < "${FILESDIR}/51${PN}" > "${S}/${PV}"
	# respect slotting
	insinto "/etc/env.d/${PN}"
	doins "${S}/${PV}"

	# remove examples
	if ! use examples; then
		rm -rf "${EROOT}/usr/$(get_libdir)/${P}/ros/share/${P}/samples" || die
	fi
}

pkg_postinst() {
	eselect ${PN} set ${PV}
	einfo "You can switch between available ${PN} implementations using eselect ${PN}"
}

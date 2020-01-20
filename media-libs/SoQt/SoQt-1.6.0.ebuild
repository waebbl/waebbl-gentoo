# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DATA_COMMIT="3ff6e9203fbb0cc08a2bdf209212b7ef4d78a1f2"
SOGUI_COMMIT="100612bf4016916dd686e2b6fecf8ac23d3db14d"

DESCRIPTION="The glue between Coin3D and Qt"
HOMEPAGE="https://github.com/coin3d/soqt"
SRC_URI="https://github.com/coin3d/soqt/archive/${P}.tar.gz
	https://github.com/coin3d/soanydata/archive/${DATA_COMMIT}.zip
	https://github.com/coin3d/sogui/archive/${SOGUI_COMMIT}.zip"
KEYWORDS="~amd64 ~x86"

LICENSE="BSD"
SLOT="0"
IUSE="+coin-iv-extensions doc man qthelp spacenav"

RDEPEND="
	~media-libs/coin-4.0.0
	virtual/opengl
	dev-qt/qtcore:5=
	dev-qt/qtgui:5=
	dev-qt/qtopengl:5=
	dev-qt/qtwidgets:5=
	qthelp? ( dev-qt/qthelp:5= )
	spacenav? ( >=dev-libs/libspnav-0.2.2:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"

REQUIRED_USE="
	man? ( doc )
	qthelp? ( doc )
"

PATCHES=(
	"${FILESDIR}/${P}-0001-CMakeLists.txt-disable-cpack.d.patch"
)

S="${WORKDIR}/soqt-${P}"

DOCS=( AUTHORS BUGS.txt ChangeLog FAQ HACKING INSTALL NEWS README RELEASE.txt )

src_unpack() {
	unpack ${A}
	pushd ${S} >/dev/null || die
	ln -sf "../soanydata-${DATA_COMMIT}" ./data || die "failed to link data"
	popd >/dev/null
	pushd "${S}/src/Inventor/Qt" >/dev/null || die
	ln -sf "../../../../sogui-${SOGUI_COMMIT}" ./common || die "failed to link common files"
	popd >/dev/null || die
}

#src_prepare() {
#	sed -i -e 's|@PROJECT_NAME_LOWER@|'${PF}'|' "${S}/SoQt.pc.cmake.in" || die

#	cmake_src_prepare
#}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
		-DCMAKE_INSTALL_MANDIR="${EPREFIX}/usr/share/man"
		-DCOIN_IV_EXTENSIONS=$(usex coin-iv-extensions)
		-DHAVE_SPACENAV_SUPPORT=$(usex spacenav)
		-DSOQT_BUILD_DOCUMENTATION=$(usex doc)
		-DSOQT_BUILD_DOC_CHM=OFF
		-DSOQT_BUILD_DOC_MAN=$(usex man)
		-DSOQT_BUILD_DOC_QTHELP=$(usex qthelp)
		-DSOQT_BUILD_INTERNAL_DOCUMENTATION=OFF
		-DSOQT_BUILD_SHARED_LIBS=ON
		-DSOQT_USE_QT5=ON
		-DSOQT_VERBOSE=OFF
	)

	cmake_src_configure
}

#src_install() {
#	cmake_src_install

#	sed -i -e 's|INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include;/usr/include;/usr/include"|\
#		INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"|' \
#		"${ED%/}/usr/$(get_libdir)/cmake/SoQt-1.6.0/soqt-export.cmake" || die
#}

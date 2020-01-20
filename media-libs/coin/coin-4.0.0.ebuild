# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_P=${P/c/C}

DESCRIPTION="A high-level 3D graphics toolkit, fully compatible with SGI Open Inventor 2.1"
HOMEPAGE="https://coin3d.github.io/"
SRC_URI="https://github.com/coin3d/coin/archive/${MY_P}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="+3ds debug doc +draggers +exceptions +javascript man +manipulators
	+nodekits +openal qthelp +simage static-libs test threads +vrml97"

RESTRICT="!test? ( test )"

# avi, guile, jpeg2000, pic, rgb, tga, xwd not added (did not find where the support is)
RDEPEND="
	app-arch/bzip2
	>=dev-libs/boost-1.65.0:=
	dev-libs/expat:=
	media-libs/fontconfig:=
	media-libs/freetype:2=
	sys-libs/zlib:=
	virtual/opengl
	virtual/glu
	x11-libs/libICE:=
	x11-libs/libSM:=
	x11-libs/libX11:=
	x11-libs/libXext:=
	javascript? ( dev-lang/spidermonkey:60= )
	openal? ( media-libs/openal:= )
	simage? ( media-libs/simage:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	x11-base/xorg-proto
	doc? (
		 app-doc/doxygen
		 qthelp? ( dev-qt/qthelp:5 )
	)
"

REQUIRED_USE="
	draggers? ( nodekits )
	javascript? ( vrml97 )
	man? ( doc )
	manipulators? ( nodekits )
	qthelp? ( doc )
"

S="${WORKDIR}/${PN}-${MY_P}"

PATCHES=(
	"${FILESDIR}/${P}-0001-CMakeLists.txt-enable-HAVE_GL_-variables.patch"
	"${FILESDIR}/${P}-0002-CMakeLists.txt-don-t-include-cpack.d.patch"
)

DOCS=(
	AUTHORS ChangeLog FAQ FAQ.legal NEWS README README.UNIX RELNOTES THANKS
	docs/{BUGS.txt,HACKING,README.VRML97,cointestsuite.pdf}
)

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
		-DCOIN_BUILD_DOCUMENTATION=$(usex doc)
		-DCOIN_BUILD_DOCUMENTATION_MAN=$(usex man)
		-DCOIN_BUILD_DOCUMENTATION_QTHELP=$(usex qthelp)
		-DCOIN_BUILD_SHARED_LIBS=ON
		-DCOIN_BUILD_SINGLE_LIB=ON
		-DCOIN_BUILD_TESTS=$(usex test)
		-DCOIN_HAVE_JAVASCRIPT=$(usex javascript)
		-DCOIN_THREADSAFE=$(usex threads)
		-DCOIN_VERBOSE=$(usex debug)
		-DHAVE_3DS_IMPORT_CAPABILITIES=$(usex 3ds)
		-DHAVE_DRAGGERS=$(usex draggers)
		-DHAVE_MANIPULATORS=$(usex manipulators)
		-DHAVE_MULTIPLE_VERSION=ON
		-DHAVE_NODEKITS=$(usex nodekits)
		-DHAVE_SOUND=$(usex openal)
		-DHAVE_VRML97=$(usex vrml97)
		-DFONTCONFIG_RUNTIME_LINKING=OFF
		-DFREETYPE_RUNTIME_LINKING=OFF
		-DGLU_RUNTIME_LINKING=OFF
		-DLIBBZIP2_RUNTIME_LINKING=OFF
		-DOPENAL_RUNTIME_LINKING=OFF
		-DSIMAGE_RUNTIME_LINKING=OFF
		-DSPIDERMONKEY_RUNTIME_LINKING=OFF
		-DZLIB_RUNTIME_LINKING=OFF
		-DUSE_EXCEPTIONS=$(usex exceptions)
		-DUSE_EXTERNAL_EXPAT=ON
	)

	cmake_src_configure
}

src_test() {
	pushd "${BUILD_DIR}/bin" > /dev/null || die
	./CoinTests -r detailed || die "Tests failed."
	popd > /dev/null || die
}

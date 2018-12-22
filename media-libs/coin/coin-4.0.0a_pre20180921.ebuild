# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils mercurial

MY_P=${P/c/C}

DESCRIPTION="A high-level 3D graphics toolkit, fully compatible with SGI Open Inventor 2.1"
HOMEPAGE="https://bitbucket.org/Coin3D/coin/wiki/Home"

COIN_REPO_URI="https://bitbucket.org/Coin3D/coin"
GENERALMSVCGENERATION_REPO_URI="https://bitbucket.org/Coin3D/generalmsvcgeneration"
BOOSTHEADERLIBSFULL_REPO_URI="https://bitbucket.org/Coin3D/boost-header-libs-full"

EHG_PROJECT="Coin3D"

LICENSE="|| ( GPL-2 PEL )"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="+3ds-import debug doc +draggers exceptions +javascript +manipulators +nodekits +openal qthelp +simage static-libs test threads +vrml97"

# TODO: verify this statment
# NOTE: expat is not really needed as --enable-system-expat is broken
# avi, guile, jpeg2000, pic, rgb, tga, xwd not added (did not find where the support is)
RDEPEND="
	app-arch/bzip2
	dev-libs/expat
	>=dev-libs/boost-1.65.0
	media-libs/fontconfig
	media-libs/freetype:2
	sys-libs/zlib
	virtual/opengl
	virtual/glu
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	javascript? ( dev-lang/spidermonkey:0 )
	openal? ( media-libs/openal )
	simage? ( media-libs/simage:= )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto
	doc? (
		 app-doc/doxygen
		 qthelp? ( dev-qt/qthelp:5 )
	)
"

REQUIRED_USE="
	draggers? ( nodekits )
	manipulators? ( nodekits )
"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${PN}-4.0.0a-gcc-7.patch
)

DOCS=(
	AUTHORS FAQ FAQ.legal NEWS README RELNOTES THANKS
	docs/{HACKING,oiki-launch.txt}
)

src_unpack() {
	EHG_REPO_URI=${GENERALMSVCGENERATION_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/generalmsvcgeneration"
	EHG_REVISION="d12bf6c"
	mercurial_fetch

	EHG_REPO_URI=${BOOSTHEADERLIBSFULL_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/boost-header-libs-full"
	EHG_REVISION="25bb778"
	mercurial_fetch

	EHG_REPO_URI=${COIN_REPO_URI}
	EHG_CHECKOUT_DIR="${S}"
	EHG_REVISION="cf2a467"
	mercurial_fetch
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${PF}"
		-DCOIN_BUILD_DOCUMENTATION=$(usex doc)
		-DCOIN_BUILD_SHARED_LIBS=ON
		-DCOIN_BUILD_SINGLE_LIB=ON
		-DCOIN_BUILD_TESTS=$(usex test)
		-DCOIN_HAVE_JAVASCRIPT=$(usex javascript ON OFF)
		-DCOIN_QT_HELP=$(usex qthelp)
		-DCOIN_THREADSAFE=$(usex threads ON OFF)
		-DCOIN_VERBOSE=$(usex debug)
		-DHAVE_3DS_IMPORT_CAPABILITIES=$(usex 3ds-import ON OFF)
		-DHAVE_DRAGGERS=$(usex draggers ON OFF)
		-DHAVE_MAN=$(usex doc ON OFF)
		-DHAVE_MANIPULATORS=$(usex manipulators ON OFF)
		-DHAVE_NODEKITS=$(usex nodekits ON OFF)
		-DHAVE_SOUND=$(usex openal ON OFF)
		-DHAVE_VRML97=$(usex vrml97 ON OFF)
		-DOPENAL_RUNTIME_LINKING=$(usex openal ON OFF)
		-DSIMAGE_RUNTIME_LINKING=$(usex simage ON OFF)
		-DSPIDERMONKEY_RUNTIME_LINKING=$(usex javascript ON OFF)
		-DUSE_EXCEPTIONS=$(usex exceptions ON OFF)
		-DUSE_EXTERNAL_EXPAT=ON
	)

	cmake-utils_src_configure
}

src_test() {
	pushd "${BUILD_DIR}/testsuite" > /dev/null || die
	./CoinTests || die "Tests failed."
	popd > /dev/null || die
}

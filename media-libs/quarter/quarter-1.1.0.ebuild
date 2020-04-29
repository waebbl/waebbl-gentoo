# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Coin GUI binding for Qt"
HOMEPAGE="https://github.com/coin3d/quarter"
SRC_URI="https://github.com/coin3d/quarter/archive/Quarter-${PV}.tar.gz"
RESTRICT="primaryuri"

LICENSE="|| ( GPL-2 PEL )"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="designer doc examples qthelp spacenav"

BDEPEND="doc? ( app-doc/doxygen )"

# Note: dev-qt/designer is needed regardless whether the USE flag is set.
RDEPEND="
	dev-qt/designer:5
	dev-qt/qtopengl:5
	>=media-libs/coin-4
	<media-libs/coin-4.0.0a_pre
	qthelp? ( dev-qt/qthelp:5 )
	spacenav? (
		dev-libs/libspnav[X]
		dev-qt/qtx11extras:5
	)
"

DEPEND="${RDEPEND}"

REQUIRED_USE="qthelp? ( doc )"

S="${WORKDIR}/${PN}-Quarter-${PV}"

PATCHES=(
	"${FILESDIR}/${P}-0001-Add-X11Extras-Qt5-component-if-spacenav-was-found.patch"
	"${FILESDIR}/${P}-0002-Fix-pkg-config-Quarter.pc.cmake.in-file.patch"
	"${FILESDIR}/${P}-0003-Fix-link-errors-in-examples.patch"
)

src_prepare() {
	sed -i '/# Fail early/a list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/SIMCMakeMacros")' CMakeLists.txt || die
	sed -i '/add_subdirectory(cpack.d)/d' CMakeLists.txt || die

	sed -e 's|LIB_DIR_SUFFIXES lib|LIB_DIR_SUFFIXES '$(get_libdir)'|' \
		-i SIMCMakeMacros/FindSpacenav.cmake || die
	sed -i "s|/lib\$|/$(get_libdir)|" Quarter.pc.cmake.in || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DQUARTER_BUILD_DOC_MAN=$(usex doc ON OFF)
		-DQUARTER_BUILD_DOC_QTHELP=$(usex qthelp ON OFF)
		-DQUARTER_BUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DQUARTER_BUILD_EXAMPLES=$(usex examples ON OFF)
		-DQUARTER_BUILD_PLUGIN=$(usex designer ON OFF)
	)

	if use spacenav; then
		mycmakeargs+=( -DSPACENAVDIR="${EPREFIX}/usr" )
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
		insinto /usr/share/doc/${PF}/examples
		doins "${S}"/src/examples/*
	fi
}

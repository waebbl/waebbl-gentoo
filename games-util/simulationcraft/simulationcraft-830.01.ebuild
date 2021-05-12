# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# The ebuild was copied over from the Drauthius overlay, slightly
# modified and moved to a sensible category.
# See https://anongit.gentoo.org/git/repo/user/Drauthius.git for the
# original ebuild.
# Thanks to Albert Diserholt for creating the original ebuild.

EAPI=7

inherit cmake

MY_PV=${PV/./-}
DESCRIPTION="SimulationCraft is a tool to explore combat mechanics in World of Warcraft."
HOMEPAGE="https://simulationcraft.org/"
SRC_URI="https://github.com/${PN}/simc/archive/release-${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/simc-release-${MY_PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
# FIXME: add clang support as alternative compiler
IUSE="doc +gui"

RDEPEND="
	dev-libs/openssl:=
	net-misc/curl
	gui? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwebengine:5
		dev-qt/qtwidgets:5
	)
"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-doc/doxygen )"

DOCS=( CONTRIBUTING.md README.md )

src_configure() {
	local mycmakeargs=(
		-DBUILD_GUI=$(usex gui)
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	use doc && (cd doc && doxygen Doxyfile) || die "Building documentation failed"
}

src_install() {
	exeinto /usr/bin
	doexe "${BUILD_DIR}"/simc
	use gui && doexe "${BUILD_DIR}"/qt/SimulationCraft

	exeinto /usr/$(get_libdir)
	dolib.so "${BUILD_DIR}"/engine/libengine.so

	insinto /usr/share/SimulationCraft
	doins -r "${S}"/profiles/.
	doins Welcome.html Error.html

	if use doc; then
		HTML_DOCS+=( doc/doxygen/html/. )
		einstalldocs
	fi
}

pkg_postinst() {
	elog "You will need to obtain an API key if you wish to import from the"
	elog "WoW armory."
	elog "Follow the instructions here:"
	elog "  https://github.com/simulationcraft/simc/wiki/BattleArmoryAPI"
}

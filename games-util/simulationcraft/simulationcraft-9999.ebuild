# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# The ebuild was copied over from the Drauthius overlay, slightly
# modified and moved to a sensible category.
# See https://anongit.gentoo.org/git/repo/user/Drauthius.git for the
# original ebuild.
# Thanks to Albert Diserholt for creating the original ebuild.

EAPI=7

inherit cmake-utils git-r3

# Putting long description into metadata.xml, as repoman restricts
# descriptions to max. 80 chars.
DESCRIPTION="SimulationCraft is a tool to explore combat mechanics in World of Warcraft."
HOMEPAGE="http://simulationcraft.org/"

EGIT_REPO_URI="https://github.com/simulationcraft/simc.git"
EGIT_BRANCH="bfa-dev" # update for new expansion

LICENSE="GPL-3"
SLOT="0"
IUSE="doc +gui"

RDEPEND="
	dev-libs/openssl:=
	gui? (
		dev-qt/qtchooser
		dev-qt/qtcore:5=
		dev-qt/qtgui:5=
		dev-qt/qtnetwork:5=
		dev-qt/qtwebengine:5=
		dev-qt/qtwidgets:5=
	)
"
DEPEND="
	${RDEPEND}
	sys-devel/clang:=
	doc? ( app-doc/doxygen )
"

src_configure() {
	local mycmakeargs=(
		-DBUILD_GUI=$(usex gui)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	use doc && (cd doc && doxygen Doxyfile) || die "Building documentation failed"
}

src_install() {
	exeinto /usr/bin
	doexe "${BUILD_DIR}"/simc
	use gui && doexe "${BUILD_DIR}"/qt/SimulationCraft

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

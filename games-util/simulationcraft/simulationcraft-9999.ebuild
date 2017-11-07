# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# The ebuild was copied over from the Drauthius overlay, slightly
# modified and moved to a sensible category.
# See https://anongit.gentoo.org/git/repo/user/Drauthius.git for the
# original ebuild.
# Thanks to Albert Diserholt for creating the original ebuild.

EAPI=6

# Putting long description into metadata.xml, as repoman restricts
# descriptions to max. 80 chars.
DESCRIPTION="SimulationCraft is a tool to explore combat mechanics in World of Warcraft."
HOMEPAGE="http://simulationcraft.org/"
LICENSE="GPL-3"
SLOT="0"

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/simulationcraft/simc.git"
	EGIT_BRANCH="legion-dev"
fi

IUSE="+gui"

RDEPEND="gui? ( dev-qt/qtchooser )"
DEPEND="
	${RDEPEND}
	dev-libs/openssl
	gui? ( dev-qt/qtwebkit:5 )
"

src_configure() {
	use gui && qtchooser -run-tool=qmake -qt=5 simcqt.pro PREFIX="${D}/usr" CONFIG+=openssl LIBS+="-lssl"
}

src_compile() {
	emake -C engine OPENSSL=1 optimized || die "Building engine failed"
	use gui && emake || die "Building GUI failed"
}

src_install() {
#	install -D -m755 engine/simc "${D}"/usr/bin/simc
	exeinto /usr/bin
	doexe "${S}"/engine/simc
	use gui && emake DESTDIR="${D}" install || die "Install failed"
}

pkg_postinst() {
	elog "You will need to obtain an API key if you wish to import from the"
	elog "WoW armory."
	elog "Follow the instructions here:"
	elog "  https://github.com/simulationcraft/simc/wiki/BattleArmoryAPI"
}

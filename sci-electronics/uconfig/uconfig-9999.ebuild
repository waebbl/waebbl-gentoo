# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 qmake-utils

DESCRIPTION="Datasheet pinout extractor from PDF and library Stylizer for Kicad."
HOMEPAGE="https://github.com/Robotips/uConfig"
EGIT_REPO_URI="https://github.com/Robotips/uConfig.git"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
	>=dev-qt/qtcore-5.2:5
	app-text/poppler
"
DEPEND="${RDEPEND}"

src_configure() {
	eqmake5 -r PREFIX="/usr" "${S}/src/uConfig.pro"
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	dolib.so bin/libkicad.so*
	dolib.so bin/libpdf_extract.so*
	dobin bin/uconfig
	dobin bin/uconfig_gui
}

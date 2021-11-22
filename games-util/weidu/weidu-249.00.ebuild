# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Develop, distribute and install mods for Infinity Engine games."
HOMEPAGE="https://www.weidu.org https://github.com/WeiDUorg/weidu"
SRC_URI="https://github.com/WeiDUorg/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

RDEPEND=""
DEPEND="
	>=dev-lang/ocaml-4.04.2[ocamlopt]
	<dev-lang/ocaml-4.12[ocamlopt]
	dev-util/elkhound
"
BDEPEND="
	doc? (
		>=dev-tex/hevea-2.29[ocamlopt]
		>=dev-lang/perl-5.24.3
	)
"

DOCS=( README-WeiDU-Changes.txt )
HTML_DOCS=( README-WeiDU.html )

src_prepare() {
	default
	cp "${S}/sample.Configuration" "${S}/Configuration"
}

src_compile() {
	# fails sometimes when using more than one cores
	emake -j1 weidu weinstall tolower
	use doc && emake doc
}

src_install() {
	# weidu's Makefiles don't have an install target
	exeinto /usr/bin
	newexe tolower.asm.exe tolower
	newexe weidu.asm.exe weidu
	newexe weinstall.asm.exe weinstall

	use doc && einstalldocs
}

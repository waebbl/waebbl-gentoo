# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Tool which merges mod zip files back into Infinity Engine games."
HOMEPAGE="https://github.com/ScottBrooks/modmerge"
EGIT_REPO_URI="https://github.com/ScottBrooks/modmerge"

LICENSE="IdeaSpark"
SLOT="0"

RESTRICT="strip test"

BDEPEND="dev-lang/go"

QA_FLAGS_IGNORED="/usr/bin/modmerge"

src_compile() {
	go build -x -o bin/${PN} *.go || die
}

src_install() {
	dobin bin/${PN}
}

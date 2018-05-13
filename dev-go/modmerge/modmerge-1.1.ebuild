# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN=github.com/ScottBrooks/modmerge/...
EGO_SRC=github.com/ScottBrooks/modmerge

DESCRIPTION="Tool which merges mod zip files back into Infinity Engine games."
HOMEPAGE="https://github.com/ScottBrooks/modmerge"

if [[ ${PV} = *9999* ]]; then
	inherit golang-vcs
else
	EGIT_COMMIT="63ff91f271facb509c8375b14a52059ada8242ae"
	SRC_URI="https://github.com/ScottBrooks/modmerge/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	inherit golang-vcs-snapshot
fi
inherit golang-build

LICENSE="IdeaSpark"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	golang-build_src_install
	dobin bin/*
}

# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_6 )

inherit distutils-r1 mercurial

DESCRIPTION="Coin3d bindings for Python"
HOMEPAGE="http://pivy.coin3d.org/"

PIVY_REPO_URI="https://bitbucket.org/Coin3D/pivy"

LICENSE="ISC"
SLOT="0"
IUSE=""

RDEPEND="
	~media-libs/coin-9999:=
	~media-libs/SoQt-9999:=
"
DEPEND="
	${RDEPEND}
	dev-lang/swig
"

S="${WORKDIR}/${PN}"

src_unpack() {
	EHG_REPO_URI=${PIVY_REPO_URI}
	EHG_CHECKOUT_DIR=${S}
	EHG_BRANCH="default"
	mercurial_fetch

	# Those fake headers are not provided
	touch "${S}"/fake_headers/{cstddef,cstdarg,cassert} || die "Failed to touch fake headers"
}

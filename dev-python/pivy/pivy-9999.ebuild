# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# does not yet compile against python-3.7
# pivy/coin_wrap.cpp:6342:40: error: invalid conversion from ‘const char*’ to ‘char*’
PYTHON_COMPAT=( python3_6 )

inherit distutils-r1

DESCRIPTION="Coin3d bindings for Python"
HOMEPAGE="http://pivy.coin3d.org/"

if [[ ${PV} == *9999 ]]; then
	inherit mercurial
	PIVY_REPO_URI="https://bitbucket.org/Coin3D/pivy"
else
	SRC_URI="https://github.com/FreeCAD/pivy/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="ISC"
SLOT="0"
IUSE=""

RDEPEND="
	>=media-libs/coin-4.0.0a_pre20180416:=
	>=media-libs/SoQt-1.6.0a_pre20180813:=
"
DEPEND="${RDEPEND}"
BDEPEND="dev-lang/swig"

PATCHES=( "${FILESDIR}/${PN}-0.6.4-find-SoQt.patch" )

src_unpack() {
	EHG_REPO_URI=${PIVY_REPO_URI}
	EHG_CHECKOUT_DIR=${S}
	EHG_BRANCH="default"
	mercurial_fetch

	# Those fake headers are not provided
	touch "${S}"/fake_headers/{cstddef,cstdarg,cassert} || die "Failed to touch fake headers"
}

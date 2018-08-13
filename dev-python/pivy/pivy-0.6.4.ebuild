# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_5 python3_6 )

inherit git-r3 distutils-r1

DESCRIPTION="Coin3d binding for Python"
HOMEPAGE="http://pivy.coin3d.org/"
EGIT_REPO_URI="https://github.com/FreeCAD/pivy.git"
EGIT_COMMIT="a2eab798"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=media-libs/coin-4.0.0-r1
	media-libs/SoQt"
DEPEND="${RDEPEND}
	dev-lang/swig"
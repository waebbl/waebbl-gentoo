# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_6 )

inherit distutils-r1 git-r3

DESCRIPTION="Coin3d bindings for Python"
HOMEPAGE="http://pivy.coin3d.org/"
EGIT_REPO_URI="https://bitbucket.org/Coin3D/pivy.git"
#EGIT_COMMIT="a2eab798"

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

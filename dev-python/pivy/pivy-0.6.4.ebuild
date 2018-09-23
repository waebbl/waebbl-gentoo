# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_6 )

inherit distutils-r1

DESCRIPTION="Coin3D bindings for Python"
HOMEPAGE="https://pivy.coin3d.org/"
SRC_URI="https://bitbucket.org/Coin3D/pivy/get/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/Coin3D-pivy-a84100beff22"

RDEPEND="
	~media-libs/coin-4.0.0a_pre20180921
	~media-libs/SoQt-1.6.0a_pre20180813
"
DEPEND="
	${RDEPEND}
	dev-lang/swig
"

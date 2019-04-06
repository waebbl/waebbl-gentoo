# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit cmake-utils python-single-r1

DESCRIPTION="Denoising filters for rendered images"
HOMEPAGE="https://www.openimagedenoise.org/"
SRC_URI="https://github.com/OpenImageDenoise/oidn/releases/download/v${PV}/${P}.src.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-cpp/tbb-2017.20161128:=
"
DEPEND="
	${RDEPEND}
	>=dev-util/cmake-3.1
"

pkg_setup() {
	python-single-r1_pkg_setup
}

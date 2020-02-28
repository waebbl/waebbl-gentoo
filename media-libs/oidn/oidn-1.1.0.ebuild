# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Denoising filters for rendered images"
HOMEPAGE="https://www.openimagedenoise.org/"
SRC_URI="https://github.com/OpenImageDenoise/oidn/releases/download/v${PV}/${P}.src.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-cpp/tbb
"
DEPEND="
	${RDEPEND}
	>=dev-util/cmake-3.1
"

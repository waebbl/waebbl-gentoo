# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )
inherit cmake python-any-r1

DESCRIPTION="Denoising filters for rendered images"
HOMEPAGE="https://www.openimagedenoise.org/"
SRC_URI="https://github.com/OpenImageDenoise/oidn/releases/download/v${PV}/${P}.src.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="openimageio test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-cpp/tbb
	openimageio? ( media-libs/openimageio:= )
"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
"
BDEPEND="dev-lang/ispc"

DOCS=( README.md readme.pdf )

pkg_setup() {
	python-any-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(	)
	if use openimageio; then
		mycmakeargs+=(
			-DOIDN_APPS_OPENIMAGEIO=ON
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# remove test program
	rm "${ED}"/usr/bin/oidnTest || die "failed to remove test program"
}

src_test() {
	"${BUILD_DIR}"/oidnTest
}

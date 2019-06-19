# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# boost lacks python-3.7 support
PYTHON_COMPAT=( python3_{5,6} )

inherit cmake-utils python-single-r1 toolchain-funcs

DESCRIPTION="C++ and Python library for 3D toolpaths"
HOMEPAGE="http://www.anderswallin.net/CAM" # no https!

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/aewallin/opencamlib.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/aewallin/opencamlib/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="LGPL-2.1"
SLOT="0"

IUSE="openmp python"

RDEPEND="
	dev-libs/boost:=[python?,${PYTHON_USEDEP}]
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use openmp && tc-check-openmp
}

src_prepare() {
	cmake-utils_src_prepare

	sed -e 's|lib/opencamlib|'$(get_libdir)'/opencamlib|' \
		-i "${S}"/src/cxxlib/cxxlib.cmake || die "sed failed"
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_CXX_LIB=ON
		-DBUILD_DOC=OFF # doesn't work
		-DBUILD_EMSCRIPTEN_LIB=OFF # needs nodejs
		-DBUILD_NODEJS_LIB=OFF	# net-libs/nodejs currently support only python-2.7
		-DBUILD_PY_LIB=$(usex python)
		-DUSE_OPENMP=$(usex openmp)
		-DUSE_PY_3=$(usex python)
	)

	cmake-utils_src_configure
}

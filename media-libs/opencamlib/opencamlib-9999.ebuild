# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )

inherit cmake python-single-r1 toolchain-funcs

DESCRIPTION="C++ and Python library for 3D toolpaths"
HOMEPAGE="https://www.anderswallin.net/CAM"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/aewallin/opencamlib.git"
else
	SRC_URI="https://github.com/aewallin/opencamlib/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="LGPL-2.1"
SLOT="0"

IUSE="openmp python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep 'dev-libs/boost:=[python?,${PYTHON_USEDEP}]')
	)
"
DEPEND="${RDEPEND}"

pkg_setup() {
	[[ ${MERGE_TYPE} != "binary" ]] && use openmp && tc-check-openmp
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	sed -e 's|lib/opencamlib|'$(get_libdir)'|' \
		-i "${S}"/src/cxxlib/cxxlib.cmake || die "sed failed"
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_CXX_LIB=ON
		-DBUILD_DOC=OFF # the doc target isn't working correctly
		-DBUILD_EMSCRIPTEN_LIB=OFF
		-DBUILD_NODEJS_LIB=OFF
		-DUSE_OPENMP=$(usex openmp)
	)

	if use python; then
		mycmakeargs+=(
			-DBUILD_PY_LIB=ON
			-DPython3_EXECUTABLE=${PYTHON}
			-DUSE_PY_3=ON
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install
	use python && python_optimize
}

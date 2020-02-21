# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit cmake python-single-r1 toolchain-funcs

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
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep \
			'dev-libs/boost:=[python?,${PYTHON_MULTI_USEDEP}]' python3_6
		)
	)
"
DEPEND="${RDEPEND}"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use openmp && tc-check-openmp
}

src_prepare() {
	cmake_src_prepare

	sed -e 's|lib/opencamlib|'$(get_libdir)'|' \
		-i "${S}"/src/cxxlib/cxxlib.cmake || die "sed failed"
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_CXX_LIB=ON
		-DBUILD_DOC=OFF # doesn't work
		-DBUILD_EMSCRIPTEN_LIB=OFF # needs nodejs
		-DBUILD_NODEJS_LIB=OFF	# net-libs/nodejs currently support only python-2.7
		-DUSE_OPENMP=$(usex openmp)
	)

	if use python; then
		python_export PYTHON_INCLUDEDIR PYTHON_LIBPATH
		mycmakeargs+=(
			-DBUILD_PY_LIB=ON
			-DPython3_EXECUTABLE="${PYTHON}"
			-DPython3_LIBRARY="${PYTHON_LIBPATH}"
			-DPython3_INCLUDE_DIR="${PYTHON_INCLUDEDIR}"
			-DUSE_PY_3=ON
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use python; then
		python_optimize
	fi
}

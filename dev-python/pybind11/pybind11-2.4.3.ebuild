# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# dev-libs/boost does not yet support py3.8
PYTHON_COMPAT=( python3_{6,7} )

inherit cmake distutils-r1

DESCRIPTION="Seamless operability between C++11 and Python"
HOMEPAGE="https://pybind11.readthedocs.io/en/stable/"
SRC_URI="https://github.com/pybind/pybind11/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"
RESTRICT="!test? ( test )"

# FIXME: dev-python/breathe only supports python 3.6 for now
DEPEND="
	${PYTHON_DEPS}
	doc? (
		$(python_gen_cond_dep 'dev-python/breathe[${PYTHON_USEDEP}]' 'python3_6')
		dev-python/sphinx[${PYTHON_USEDEP}]
	)
	test? (
		dev-cpp/catch:0
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
		sci-libs/scipy[${PYTHON_USEDEP}]
	)
"

RDEPEND="
	${PYTHON_DEPS}
	dev-cpp/eigen:3
"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	doc? ( $(python_gen_useflags 'python3_6') )
"

DOCS=( README.md CONTRIBUTING.md ISSUE_TEMPLATE.md )

pkg_setup() {
	use doc && DISTUTILS_ALL_SUBPHASE_IMPLS=( 'python3_6' )
}

python_prepare_all() {
	export PYBIND11_USE_CMAKE=1
	cmake_src_prepare
	distutils-r1_python_prepare_all
}

python_configure_all() {
	local mycmakeargs=(
		-DPYBIND11_INSTALL=ON
		-DPYBIND11_TEST=$(usex test)
	)

	cmake_src_configure
}

python_compile_all() {
	# No compilation has to be done by cmake

	# documentation is not covered by cmake, but has it's own makefile
	# using sphinx
	if use doc; then
		python_setup 'python3_6'
		pushd "${S}"/docs || die
		emake info man html
		popd || die
	fi
}

python_test_all() {
	# Tests are only copied for python-3.6, so let's restrict them
	if [ "${EPYTHON}" = "python3.6" ]; then
		pushd "${BUILD_DIR}" || die
		eninja check
		popd || die
	fi
}

python_install_all() {
	cmake_src_install
	if use doc; then
		python_setup
		local HTML_DOCS=( "${S}"/docs/.build/html/. )

		# install man and info pages
		doman "${S}"/docs/.build/man/pybind11.1
		doinfo "${S}"/docs/.build/texinfo/pybind11.info
	fi

	distutils-r1_python_install_all
}

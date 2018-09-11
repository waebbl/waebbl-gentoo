# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# according to upstream is compatible with 2.7, 3.4, 3.5, 3.6
PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )

inherit cmake-utils python-single-r1

DESCRIPTION="Seamless operability between C++11 and Python"
HOMEPAGE="https://pybind11.readthedocs.io/en/stable/"
SRC_URI="https://github.com/pybind/pybind11/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64"

IUSE="doc test"

DEPEND="
	${PYTHON_DEP}
	>=dev-util/cmake-3.9.6
	doc? (
		dev-python/breathe[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
	)
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )
"

RDEPEND="
	${PYTHON_DEP}
	dev-cpp/eigen:3
	sys-apps/texinfo
	sys-devel/gettext[cxx]
	virtual/man
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

#S=${WORKDIR}/${P}

DOCS=( README.md CONTRIBUTING.md ISSUE_TEMPLATE.md )
#HTML_DOCS=( "${S}"/docs/.build/html/* )

pkg_setup() {
	python-single-r1_pkg_setup
}

src_configure() {
	mycmakeargs=(
		-DPYBIND11_INSTALL=ON
		-DPYBIND11_TEST=$(usex test)
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	# documentation is not covered by cmake, but has it's own makefile
	# using sphinx
	pushd "${S}"/docs
	emake info man

	if use doc; then
		emake html
	fi
	popd
}

# TODO:
# figure out how test works. It just builds some libs
src_test() {
	cmake-utils_src_test
	pushd "${BUILD_DIR}"
	emake check
	popd
}

src_install() {
	cmake-utils_src_install

	# install man and info pages
	doman "${S}"/docs/.build/man/pybind11.1
	doinfo "${S}"/docs/.build/texinfo/pybind11.info

	if use doc; then
#		einstalldocs
		insinto /usr/share/doc/${PF}/html
		doins -r "${S}"/docs/.build/html/*
	fi
}

# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_ECLASS=cmake
PYTHON_COMPAT=( python3_{7..9} )

inherit cmake python-single-r1

DESCRIPTION="Imath basic math package"
HOMEPAGE="https://www.openexr.com"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/Imath.git"
else
	SRC_URI="https://github.com/AcademySoftwareFoundation/Imath/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
#KEYWORDS="~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x64-macos ~x86-solaris"
fi

LICENSE="BSD"
SLOT="3/26"
IUSE="large-stack python static-libs test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

# libImath.so conflicts with ilmbase
RDEPEND="
	!media-libs/ilmbase
	sys-libs/zlib
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-libs/boost:=[python?,${PYTHON_MULTI_USEDEP}]
			dev-python/numpy[${PYTHON_MULTI_USEDEP}]
		')
	)
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-0001-fix-link-file-name-for-libPyImath_Python.patch
)

DOCS=( CHANGES.md CODE_OF_CONDUCT.md CONTRIBUTING.md CONTRIBUTORS.md
	README.md SECURITY.md )

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DIMATH_BUILD_BOTH_STATIC_SHARED=$(usex static-libs)
		-DIMATH_ENABLE_LARGE_STACK=$(usex large-stack)
		-DIMATH_INSTALL_PKG_CONFIG=ON
		-DIMATH_USE_CLANG_TIDY=OFF
	)

	if use python; then
		mycmakeargs+=(
			-DCMAKE_DISABLE_FIND_PACKAGE_Python2=TRUE
			-DPYTHON=ON
			-DPython3_EXECUTABLE="${PYTHON}"
			-DPython3_INCLUDE_DIR=$(python_get_includedir)
			-DPython3_LIBRARY=$(python_get_library_path)
		)
	fi

	cmake_src_configure
}

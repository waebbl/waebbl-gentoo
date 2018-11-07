# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit cmake-utils flag-o-matic llvm python-any-r1 toolchain-funcs

DESCRIPTION="Intel SPMD Program Compiler"
HOMEPAGE="https://ispc.github.com/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ispc/ispc.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD BSD-2 UoI-NCSA"
SLOT="0"
# FIXME: add LLVM_TARGETS? The CMakeLists.txt specifically refers to
#	arm and nvptx targets and offers options for it.
IUSE="examples"

#[${PYTHON_USEDEP}] on clang throws repoman error invalid atom: invalid use dep: ''
RDEPEND="
	sys-devel/clang:5=[debug(+)]
	sys-devel/llvm:5=[debug(+)]
"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	sys-devel/bison
	sys-devel/flex
	sys-devel/m4
"

PATCHES=( "${FILESDIR}"/${P}-enum-type.patch )

DOCS=( README.rst )

LLVM_MAX_SLOT=5
CMAKE_BUILD_TYPE=Release

pkg_setup() {
	llvm_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DARM_ENABLED=OFF
		-DNVPTX_ENABLED=OFF
	)

	export CC=clang
	export CXX=clang++
	strip-flags
	filter-flags "-frecord-gcc-switches"
	cmake-utils_src_configure
}

src_compile() {
	# remove -Werror (ispc/ispc#1295)
	sed -e 's/-Werror//' -i CMakeLists.txt || die
	#emake LDFLAGS="${LDFLAGS}" OPT="${CXXFLAGS}" CXX="$(tc-getCXX)" CPP="$(tc-getCPP)"
	cmake-utils_src_compile
}

src_install() {
	#dobin ispc
	#dodoc README.rst

	cmake-utils_src_install

	if use examples; then
		insinto "/usr/share/doc/${PF}/examples"
		docompress -x "/usr/share/doc/${PF}/examples"
		doins -r examples/*
	fi
}

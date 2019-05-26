# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )

inherit cmake-utils python-any-r1

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

# FIXME:
# - add NVPTX support: fails to compile
# - re-add examples: fails to compile
IUSE="doc llvm_targets_AArch64 llvm_targets_ARM sanitize test"

# only one out of 10 tests passes
RESTRICT="test"

RDEPEND="
	sys-devel/clang:=[llvm_targets_AArch64=,llvm_targets_ARM=]
	sys-libs/ncurses:0=
	sys-libs/zlib:=
"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	doc? (
		app-doc/doxygen[dot(+)]
		media-fonts/freefont
	)
"
BDEPEND="
	sys-devel/bison
	sys-devel/flex
"

DOCS=( README.md "${S}"/docs/{ReleaseNotes.txt,faq.rst,ispc.rst,news.rst,perf.rst,perfguide.rst} )

src_prepare() {
	# drop -Werror
	sed -e 's/-Werror//' -i CMakeLists.txt || die

	# fix path for dot binary
	if use doc; then
		sed -e 's|/usr/local/bin/dot|/usr/bin/dot|' -i "${S}"/doxygen.cfg || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DARM_ENABLED=$(usex llvm_targets_AArch64 $(usex llvm_targets_ARM))
		-DNVPTX_ENABLED=OFF
		-DISPC_INCLUDE_EXAMPLES=OFF
		-DISPC_INCLUDE_TESTS=$(usex test)
		-DISPC_INCLUDE_UTILS=ON
		-DISPC_NO_DUMPS=OFF
		-DISPC_PREPARE_PACKAGE=OFF
		-DISPC_STATIC_STDCXX_LINK=OFF
		-DISPC_STATIC_LINK=OFF
		-DISPC_USE_ASAN=$(usex sanitize)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		pushd "${S}" >/dev/null || die
		doxygen -u doxygen.cfg || die "failed to update doxygen.cfg"
		doxygen doxygen.cfg || die "failed to build documentation"
		popd >/dev/null || die
	fi
}

src_install() {
	cmake-utils_src_install

	if use doc; then
		local HTML_DOCS=( docs/doxygen/html/. )
	fi
	einstalldocs

#	if use examples; then
#		insinto "/usr/share/doc/${PF}/examples"
#		docompress -x "/usr/share/doc/${PF}/examples"
#		doins -r examples/*
#	fi
}

src_test() {
	eninja check-all
}

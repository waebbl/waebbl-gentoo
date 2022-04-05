# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

MY_PN=OpenEXR
MY_PV=3
MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="ILM's OpenEXR high dynamic-range image file format libraries"
HOMEPAGE="https://www.openexr.com/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/openexr.git"
else
	SRC_URI="https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	# imath needs keywording: arm{,64}, hppa, ppc{,64}, sparc
	KEYWORDS="~amd64 ~ia64 ~x86 ~amd64-linux ~x86-linux x64-macos x86-solaris"
fi

LICENSE="BSD"
SLOT="3/29" # based on SONAME
IUSE="cpu_flags_x86_avx doc examples large-stack static-libs utils test threads"
RESTRICT="!test? ( test )"

RDEPEND="
	~dev-libs/imath-${PV}:3=
	sys-libs/zlib
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-0001-changes-needed-for-proper-slotting.patch
	"${FILESDIR}"/${P}-0002-add-version-to-binaries-for-slotting.patch
)
DOCS=( CHANGES.md GOVERNANCE.md PATENTS README.md SECURITY.md docs/SymbolVisibility.md )

pkg_pretend() {
	ewarn "WARNING: This package version is for testing purposes ONLY."
	ewarn "WARNING: It WILL break downstream packages!!!"
	ewarn "WARNING: Only use if you know exactly what you are doing."
}

src_prepare() {
	# Fix path for testsuite
	sed -e "s:/var/tmp/:${T}:" \
		-i "${S}"/src/test/${MY_PN}{,Fuzz,Util}Test/tmpDir.h || die "failed to set temp path for tests"

	cmake_src_prepare

	mv "${S}"/cmake/${MY_PN}.pc.in "${S}"/cmake/${MY_P}.pc.in || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex !static-libs)
		-DBUILD_TESTING=$(usex test)
		-DOPENEXR_ENABLE_LARGE_STACK=$(usex large-stack)
		-DOPENEXR_ENABLE_THREADING=$(usex threads)
		-DOPENEXR_INSTALL_EXAMPLES=$(usex examples)
		-DOPENEXR_INSTALL_PKG_CONFIG=ON
		-DOPENEXR_INSTALL_TOOLS=$(usex utils)
		-DOPENEXR_OUTPUT_SUBDIR="${MY_P}"
		-DOPENEXR_USE_CLANG_TIDY=OFF		# don't look for clang-tidy
	)

	use test && mycmakeargs+=( -DOPENEXR_RUN_FUZZ_TESTS=ON )

	cmake_src_configure
}

src_install() {
	if use doc; then
		DOCS+=( docs/*.pdf )
	fi
	use examples && docompress -x /usr/share/doc/${PF}/examples
	cmake_src_install

	cat > "${T}"/99${MY_P} <<-EOF || die
	LDPATH="/usr/$(get_libdir)/${MY_P}
	EOF
	doenvd "${T}"/99${MY_P}
}

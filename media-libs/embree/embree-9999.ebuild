# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic toolchain-funcs

DESCRIPTION="Collection of high-performance ray tracing kernels"
HOMEPAGE="https://github.com/embree/embree"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/embree/embree.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/embree/embree/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"

#X86_CPU_FLAGS=(
#	sse2:sse2 sse4_2:sse4_2 avx:avx avx2:avx2
#)
#CPU_FLAGS=( ${X86_CPU_FLAGS[@]/#/cpu_flags_x86_} )

IUSE="clang ispc +tbb tutorial" # ${CPU_FLAGS[@]%:*}

RDEPEND="
	>=media-libs/glfw-3.2.1:=
	virtual/opengl
	ispc? ( dev-lang/ispc:= )
	tbb? ( dev-cpp/tbb:= )
	tutorial? (
		>=media-libs/libpng-1.6.34:0=
		>=media-libs/openimageio-1.8.7:=
		virtual/jpeg:0
	)
"

DEPEND="
	${RDEPEND}
	>=dev-util/cmake-3.9.6
	virtual/pkgconfig
	clang? ( sys-devel/clang )
"

DOCS=( CHANGELOG.md README.md readme.pdf )

CMAKE_BUILD_TYPE=Release

src_prepare() {
	cmake-utils_src_prepare

	# disable RPM package building
	sed -e 's|CPACK_RPM_PACKAGE_RELEASE 1|CPACK_RPM_PACKAGE_RELEASE 0|' \
		-i CMakeLists.txt || die
	# change -O3 settings for various compilers
#	sed -e 's|-O3|-O2|' -i "${S}"/common/cmake/{clang,gnu,intel,ispc}.cmake || die
}

# FIXME: not used yet
#	EMBREE_STACK_PROTECTOR: off by default; should we use a USE flag to
#		enable this? Could have an impact on performance
#	EMBREE_STATIC_LIB: off by default; do we really want this?
#	EMBREE_IGNORE_IVALID_RAYS: off by default; make code robust against
#		the risk of full-tree traversals caused by invalid rays (e.g. rays
#		containing INF/NaN origins). Could have an impact on performance.
#
# Check the AVX512 options!
#	EMBREE_ISA_AVX512KNL: Enables AVX-512 for Xeon Phi
#	EMBREE_ISA_AVX512SKX: Enablex AVX-512 for Skylake
#
#	EMBREE_CURVE_SELF_INTERSECTION_AVOIDANCE_FACTOR: leave it at 2.0f for now
#		0.0f disables self intersection avoidance.
src_configure() {
	if use clang; then
		export CC=clang
		export CXX=clang++
		strip-flags
		filter-flags "-frecord-gcc-switches"
		filter-ldflags "-Wl,--as-needed"
		filter-ldflags "-Wl,-O1"
		filter-ldflags "-Wl,--defsym=__gentoo_check_ldflags__=0"
	fi

# FIXME: The build currently only works with their own C{,XX}FLAGS,
# not respecting user flags.
#		-DEMBREE_IGNORE_CMAKE_CXX_FLAGS=OFF
	local mycmakeargs=(
		-DBUILD_TESTING:BOOL=OFF
#		-DCMAKE_C_COMPILER=$(tc-getCC)
#		-DCMAKE_CXX_COMPILER=$(tc-getCXX)
		-DCMAKE_SKIP_INSTALL_RPATH:BOOL=ON
		-DEMBREE_ISA_AVX512KNL=OFF
		-DEMBREE_ISA_AVX512SKX=OFF
		-DEMBREE_ISPC_SUPPORT=$(usex ispc)
		-DEMBREE_TASKING_SYSTEM:STRING=$(usex tbb "TBB" "INTERNAL")
		-DEMBREE_TUTORIALS=$(usex tutorial)
	)

	if use tutorial; then
		mycmakeargs+=(
			-DEMBREE_ISPC_ADDRESSING:STRING="64"
			-DEMBREE_TUTORIALS_LIBJPEG=ON
			-DEMBREE_TUTORIALS_LIBPNG=ON
			-DEMBREE_TUTORIALS_OPENIMAGEIO=ON
		)
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -rf "${ED}"/usr/share/doc/embree3 || die

	# FIXME: solve this hack and patch the makefiles to do it
	mkdir -p "${ED}"/usr/share/${PN}3 || die
	mv "${ED}"/usr/bin/${PN}3/models "${ED}"/usr/share/${PN}3 || die

	doenvd "${FILESDIR}"/99${PN}
}

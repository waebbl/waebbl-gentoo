# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

MY_PV="$(ver_rs "1-3" '_')"
DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="https://graphics.pixar.com/opensubdiv/docs/intro.html"
SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenSubdiv-${MY_PV}"

# Modfied Apache-2.0 license, where section 6 has been replaced.
# See for example CMakeLists.txt for details.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="cuda examples opencl openmp ptex tbb test tutorials"
RESTRICT="!test? ( test )"

# need cuda-11.1 for gcc-11
RDEPEND="
	media-libs/glew:=
	media-libs/glfw:=
	x11-libs/libXinerama
	cuda? ( >=dev-util/nvidia-cuda-toolkit-11.1:= )
	opencl? ( virtual/opencl )
	ptex? ( media-libs/ptex )
"
DEPEND="
	${RDEPEND}
	tbb? ( <dev-cpp/tbb-2021.4.0:= )
"
BDEPEND="
	cuda? ( <sys-devel/gcc-12[cxx] )
"

PATCHES=(
	"${FILESDIR}/${PN}-3.3.0-use-gnuinstalldirs.patch"
	"${FILESDIR}/${PN}-3.4.3-add-cuda-11-compatibility.patch"
	"${FILESDIR}/${PN}-3.4.3-install-tutorials-into-bin.patch"
)

pkg_pretend() {
	if use cuda; then
		[[ $(gcc-major-version) -gt 11 ]] && \
		eerror "USE=cuda requires gcc < 12. Run gcc-config to switch your default compiler" && \
		die "Need gcc version earlier than 12."
	fi
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	# GLTESTS are disabled as portage is unable to open a display during test phase
	# TODO: virtx work?
	local mycmakeargs=(
		-DGLEW_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
		-DGLFW_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
		-DNO_CLEW=ON
		-DNO_CUDA=$(usex !cuda)
		# Docs needed Python 2 so disabled
		# bug #815172
		-DNO_DOC=ON
		-DNO_EXAMPLES=$(usex !examples)
		-DNO_GLTESTS=ON
		-DNO_OMP=$(usex !openmp)
		-DNO_OPENCL=$(usex !opencl)
		-DNO_PTEX=$(usex !ptex)
		-DNO_REGRESSION=$(usex !test)
		-DNO_TBB=$(usex !tbb)
		-DNO_TESTS=$(usex !test)
		-DNO_TUTORIALS=$(usex !tutorials)
	)

	# Fails with building cuda kernels when using multiple jobs
	use cuda && export MAKEOPTS="-j1"

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use test; then
		# don't install test binaries
		rm "${ED}"/usr/bin/{far,hbr,osd}_regression \
			"${ED}"/usr/bin/hbr_baseline \
			"${ED}"/usr/bin/far_perf || die
	fi

# TODO
# - better install tutorial source code into docdir for learning how to use OSD.
#	Might install the binaries into this location as well instead of polluting bindir.
# - same for examples, but some of the binaries might actually useful for general
#	purpose, check them first.
}

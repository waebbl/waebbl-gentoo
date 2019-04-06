# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_6 )
inherit cmake-utils python-single-r1 toolchain-funcs

MY_PV=$(ver_cut 1-2)$(ver_cut 3-4)
MY_P=${PN}_v${MY_PV}
DESCRIPTION="A physically correct, unbiased rendering engine."
HOMEPAGE="https://www.luxcorerender.org/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/LuxCoreRender/LuxCore"
	KEYWORDS=""
else
	SRC_URI="https://github.com/LuxCoreRender/LuxCore/archive/${MY_P}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="Apache-2.0"
SLOT="0"

X86_CPU_FLAGS=(
	sse:sse sse2:sse2 sse3:sse3 ssse3:ssse3
)
CPU_FLAGS=( ${X86_CPU_FLAGS[@]/#/cpu_flags_x86_} )

# TODO: add doc USE flag
IUSE="opencl +openmp +python ${CPU_FLAGS[@]%:*}"

#RESTRICT="strip"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-cpp/tbb-2017.20161128:=
	>=dev-libs/c-blosc-1.11.2:=
	>=dev-libs/boost-1.65.0:=[python?,${PYTHON_USEDEP},threads(+)]
	>=dev-python/numpy-1.14.5:=[${PYTHON_USEDEP}]
	>=media-libs/embree-3.2.4:=[ispc]
	>=media-libs/oidn-0.8.1:=
	>=media-libs/freetype-2.9.1-r1:=[X,bzip2]
	media-libs/libpng:0=[cpu_flags_x86_sse?]
	>=media-libs/openexr-2.3.0:=
	>=media-libs/openimageio-1.8.7:=[cpu_flags_x86_sse2?,cpu_flags_x86_sse3?,cpu_flags_x86_ssse3?,${PYTHON_USEDEP}]
	media-libs/tiff:0=
	virtual/jpeg:0
	x11-libs/gtk+:3=
	x11-libs/libICE:=
	x11-libs/libX11:=
	x11-libs/libXext:=
	opencl? ( virtual/opencl virtual/opengl )
	python? ( >=dev-python/pyside-5.11.1:=[${PYTHON_USEDEP}] )
"

DEPEND="
	${RDEPEND}
	>=dev-util/cmake-3.9.6
	>=sys-devel/bison-3.0.5-r1
	>=sys-devel/flex-2.6.4-r1
	>=virtual/pkgconfig-0-r1
	python? ( >=dev-python/pyside-tools-5.11.1[${PYTHON_USEDEP}] )

"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
"

PATCHES=( "${FILESDIR}/${PN}-find-boost.patch" )

CMAKE_BUILD_TYPE="Release"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	use openmp && tc-check-openmp
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLUXRAYS_DISABLE_OPENCL=$(usex !opencl)
	)
	cmake-utils_src_configure
}

src_install() {
	# Note: upstream currently doesn't provide an install target
	dobin "${BUILD_DIR}"/bin/*
	dolib.so "${BUILD_DIR}"/lib/pyluxcore.so

	insinto /usr/$(get_libdir)
	doins "${BUILD_DIR}"/lib/pyluxcoretools.zip

	insinto /usr/include
	doins -r "${S}"/include/lux{core,rays}

	insinto /usr/share/${PN}/scenes
	doins -r "${S}"/scenes/.

	local DOCS=( AUTHORS.txt README.md )
	einstalldocs
}

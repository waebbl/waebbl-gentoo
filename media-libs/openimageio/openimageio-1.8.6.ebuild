# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit cmake-utils vcs-snapshot python-single-r1

DESCRIPTION="A library for reading and writing images"
HOMEPAGE="https://sites.google.com/site/openimageio/ https://github.com/OpenImageIO"
SRC_URI="https://github.com/OpenImageIO/oiio/archive/Release-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc64 ~x86"

X86_CPU_FEATURES=(
	sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )

# dcmtk / dicom
# p4?
# hdf5
IUSE="colorio dicom doc ffmpeg field3d gif hdf5 jpeg jpeg2k opencv opengl ptex \
	python qt5 raw ssl +truetype ${CPU_FEATURES[@]%:*}"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RESTRICT="test" #431412

RDEPEND=">=dev-libs/boost-1.62:=
	dev-libs/pugixml:=
	>=media-libs/ilmbase-2.2.0-r1:=
	media-libs/libpng:0=
	>=media-libs/libwebp-0.2.1:=
	>=media-libs/openexr-2.2.0-r2:=
	media-libs/tiff:0=
	sys-libs/zlib:=
	virtual/jpeg:=
	colorio? ( media-libs/opencolorio:= )
	ffmpeg? ( media-video/ffmpeg:= )
	field3d? ( media-libs/Field3D:= )
	gif? ( media-libs/giflib:0= )
	jpeg2k? ( >=media-libs/openjpeg-1.5:0= )
	opencv? ( media-libs/opencv:= )
	opengl? (
		virtual/glu
		virtual/opengl
	)
	ptex? ( media-libs/ptex:= )
	python? (
		${PYTHON_DEPS}
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtwidgets:5
		media-libs/glew:=
	)
	raw? ( media-libs/libraw:= )
	ssl? ( dev-libs/openssl:0= )
	truetype? ( media-libs/freetype:2= )
	dicom? ( sci-libs/dcmtk:0= )
	hdf5? ( sci-libs/hdf5:0= )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen[latex] )"

#PATCHES=( "${FILESDIR}/${PN}-use-gnuinstalldirs.patch"
#	"${FILESDIR}/${PN}-make-python-and-boost-detection-more-generic.patch"
#)

DOCS=( CHANGES.md CREDITS.md README.md src/doc/${PN}.pdf )

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	# Build with SIMD support
	local cpufeature
	local mysimd=()
	for cpufeature in "${CPU_FEATURES[@]}"; do
		use "${cpufeature%:*}" && mysimd+=("${cpufeature#*:}")
	done

	# If no CPU SIMDs were used, completely disable them
	[[ -z ${mysimd} ]] && mysimd=("0")

	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DINSTALL_DOCS=$(usex doc)
		-DOIIO_BUILD_TESTS=OFF # as they are RESTRICTed
		-DSTOP_ON_WARNING=OFF
		-DUSE_CPP14=ON
		-DUSE_DICOM=$(usex dicom)
		-DUSE_EXTERNAL_PUGIXML=ON
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_FIELD3D=$(usex field3d)
		-DUSE_FREETYPE=$(usex truetype)
		-DUSE_GIF=$(usex gif)
		-DUSE_HDF5=$(usex hdf5)
		-DUSE_JPEGTURBO=ON
		-DUSE_LIBRAW=$(usex raw)
		-DUSE_NUKE=NO # Missing in Gentoo
		-DUSE_NUKE=OFF
		-DUSE_OCIO=$(usex colorio)
		-DUSE_OPENCV=$(usex opencv)
		-DUSE_OPENGL=$(usex opengl)
		-DUSE_OPENJPEG=$(usex jpeg2k)
		-DUSE_OPENSSL=$(usex ssl)
		-DUSE_PTEX=$(usex ptex)
		-DUSE_PYTHON=$(usex python)
		-DUSE_QT=$(usex qt5)
		-DUSE_SIMD="$(IFS=","; echo "${mysimd[*]}")"
	)

	cmake-utils_src_configure
}

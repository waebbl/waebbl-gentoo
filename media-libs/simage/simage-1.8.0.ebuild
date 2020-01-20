# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic

DESCRIPTION="Image and video texturing library"
HOMEPAGE="https://github.com/coin3d/simage/"
SRC_URI="https://github.com/coin3d/simage/archive/${P}.tar.gz"
KEYWORDS="~amd64"

LICENSE="BSD-1"
SLOT="0"
IUSE="debug gif jpeg png qt5 sndfile tiff vorbis"

RDEPEND="
	sys-libs/zlib:=
	gif? ( media-libs/giflib:= )
	jpeg? ( virtual/jpeg:0 )
	png? ( media-libs/libpng:0= )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
	)
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )
	vorbis? (
		media-libs/libogg
		media-libs/libvorbis
	)
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${P}"

PATCHES=(
	"${FILESDIR}/${P}-0001-CMakeLists.txt-comment-cpack.d-inclusion.patch"
)

DOCS=(AUTHORS ChangeLog NEWS README)

src_configure() {
	use debug && append-cppflags -DSIMAGE_DEBUG=1

	local mycmakeargs=(
		-DSIMAGE_BUILD_DOCUMENTATION=OFF
		-DSIMAGE_BUILD_SHARED_LIBS=ON
		-DSIMAGE_USE_QIMAGE=$(usex qt5)
		-DSIMAGE_USE_QT5=$(usex qt5)

		-DSIMAGE_AVIENC_SUPPORT=OFF # windows only
		-DSIMAGE_CGIMAGE_SUPPORT=OFF # osx only
		-DSIMAGE_GDIPLUS_SUPPORT=OFF # windows only
		-DSIMAGE_LIBSNDFILE_SUPPORT=ON
		-DSIMAGE_OGGVORBIS_SUPPORT=ON
		-DSIMAGE_QIMAGE_SUPPORT=ON
		-DSIMAGE_QUICKTIME_SUPPORT=OFF # osx only
		-DSIMAGE_EPS_SUPPORT=ON
		-DSIMAGE_MPEG2ENC_SUPPORT=ON
		-DSIMAGE_PIC_SUPPORT=ON
		-DSIMAGE_RGB_SUPPORT=ON
		-DSIMAGE_TGA_SUPPORT=ON
		-DSIMAGE_XWD_SUPPORT=ON
	)

	cmake_src_configure
}

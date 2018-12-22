# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic mercurial

DESCRIPTION="Image and video texturing library"
HOMEPAGE="https://bitbucket.org/Coin3D/simage"
SRC_URI=""

LICENSE="public-domain mpeg2enc"
SLOT="0"
IUSE="debug gif jpeg jpeg2k png qt5 sndfile tiff vorbis"

SIMAGE_REPO_URI="https://bitbucket.org/Coin3D/simage"
CPACK_D_REPO_URI="https://bitbucket.org/ggabbiani/cpack.d"
EHG_PROJECT="Coin3D"

RDEPEND="
	gif? ( media-libs/giflib )
	jpeg? ( virtual/jpeg:0= )
	jpeg2k? ( media-libs/jasper )
	png? ( media-libs/libpng:0= )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
	)
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0= )
	vorbis? (
		media-libs/libogg
		media-libs/libvorbis
	)
"
DEPEND="${RDEPEND}"

#S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/${PN}-1.7.1-cmake-automagic-deps.patch"
)

DOCS=(AUTHORS ChangeLog NEWS README)

src_unpack() {
	EHG_REPO_URI=${CPACK_D_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/cpack.d"
	EHG_REVISION="35e19a9"
	mercurial_fetch

	EHG_REPO_URI=${SIMAGE_REPO_URI}
	EHG_CHECKOUT_DIR=${S}
	EHG_REVISION="0d0c31d"
	mercurial_fetch
}

src_configure() {
	use debug && append-cppflags -DSIMAGE_DEBUG=1

	local mycmakeargs=(
		-DSIMAGE_BUILD_SHARED_LIBS=ON
		-DSIMAGE_EPS_SUPPORT=ON
		-DSIMAGE_MPEG2ENC_SUPPORT=ON
		-DSIMAGE_PIC_SUPPORT=ON
		-DSIMAGE_QIMAGE_SUPPORT=$(usex qt5)
		-DSIMAGE_RGB_SUPPORT=ON
		-DSIMAGE_TGA_SUPPORT=ON
		-DSIMAGE_XWD_SUPPORT=ON
		-DUSE_GIF=$(usex gif)
		-DUSE_JPEG=$(usex jpeg)
		-DUSE_JPEG2K=$(usex jpeg2k)
		-DUSE_OGGVORBIS=$(usex vorbis)
		-DUSE_PNG=$(usex png)
		-DUSE_QT5=ON
		-DUSE_SNDFILE=$(usex sndfile)
		-DUSE_TIFF=$(usex tiff)
	)

	cmake-utils_src_configure
}

# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils mercurial

DESCRIPTION="The glue between Coin3D and Qt"
HOMEPAGE="https://bitbucket.org/Coin3D/soqt"

SOQT_REPO_URI="https://bitbucket.org/Coin3D/soqt"
GENERALMSVCGENERATION_REPO_URI="https://bitbucket.org/Coin3D/generalmsvcgeneration"
BOOSTHEADERLIBSFULL_REPO_URI="https://bitbucket.org/Coin3D/boost-header-libs-full"
SOANYDATA_REPO_URI="https://bitbucket.org/Coin3D/soanydata"
SOGUI_REPO_URI="https://bitbucket.org/Coin3D/sogui"

EHG_PROJECT="Coin3D"

LICENSE="|| ( GPL-2 PEL )"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="+coin-iv-extensions spacenav"

RDEPEND="
	>=media-libs/coin-4.0.0-r1
	virtual/opengl
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtopengl:5
	dev-qt/qtwidgets:5
	spacenav? ( >=dev-libs/libspnav-0.2.2 )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-1.5.0-pkgconfig-partial.patch"
)

DOCS=(AUTHORS ChangeLog FAQ HACKING NEWS README)

src_unpack() {
	EHG_REPO_URI=${GENERALMSVCGENERATION_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/generalmsvcgeneration"
	EHG_REVISION="d12bf6c"
	mercurial_fetch

	EHG_REPO_URI=${BOOSTHEADERLIBSFULL_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/boost-header-libs-full"
	EHG_REVISION="25bb778"
	mercurial_fetch

	EHG_REPO_URI=${SOANYDATA_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/soanydata"
	EHG_REVISION="f8721d8"
	mercurial_fetch

	EHG_REPO_URI=${SOGUI_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/sogui"
	EHG_REVISION="1e2cb21"
	mercurial_fetch

	EHG_REPO_URI=${SOQT_REPO_URI}
	EHG_CHECKOUT_DIR="${S}"
	EHG_REVISION="6719cfe"
	mercurial_fetch
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="${EPREFIX%/}/usr/share/doc/${PF}"
		-DCMAKE_INSTALL_MANDIR="${EPREFIX%/}/usr/share"
		-DCOIN_IV_EXTENSIONS=$(usex coin-iv-extensions ON OFF)
		-DHAVE_SPACENAV_SUPPORT=$(usex spacenav ON OFF)
		-DUSE_QT5=ON
	)

	cmake-utils_src_configure
}

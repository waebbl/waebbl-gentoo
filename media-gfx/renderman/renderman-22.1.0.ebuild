# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO: add amd64 only multilib-support -> package provides no 32-bit

EAPI=7

MULTILIB_COMPAT=( abi_x86_64 )
inherit rpm multilib-minimal

DESCRIPTION="Renderman render engine"
HOMEPAGE="https://renderman.pixar.com/"
SRC_URI="RenderMan-InstallerNCR-${PV}_1891132-linuxRHEL7_gcc48icc170.x86_64.rpm"

LICENSE="RenderMan-TMPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE="video_cards_nvidia"

RESTRICT="bindist mirror fetch strip"

DEPEND=""

# list from ldd output of the RenderManInstaller
# Qt-5.6.1 is shipped with the installer
RDEPEND="
	app-arch/bzip2:=[${MULTILIB_USEDEP}]
	app-arch/lz4:=[${MULTILIB_USEDEP}]
	app-arch/xz-utils[${MULTILIB_USEDEP}]
	dev-libs/elfutils[${MULTILIB_USEDEP}]
	dev-libs/expat[${MULTILIB_USEDEP}]
	dev-libs/libbsd[${MULTILIB_USEDEP}]
	dev-libs/libgpg-error[${MULTILIB_USEDEP}]
	dev-libs/glib[${MULTILIB_USEDEP}]
	dev-libs/libgcrypt:0=[${MULTILIB_USEDEP}]
	dev-libs/libpcre[${MULTILIB_USEDEP}]
	media-gfx/graphite2[${MULTILIB_USEDEP}]
	media-libs/fontconfig[${MULTILIB_USEDEP}]
	media-libs/freetype[${MULTILIB_USEDEP}]
	media-libs/harfbuzz:=[${MULTILIB_USEDEP}]
	media-libs/libpng:0=[${MULTILIB_USEDEP}]
	media-libs/mesa[${MULTILIB_USEDEP}]
	sys-apps/dbus[${MULTILIB_USEDEP}]
	sys-apps/systemd:=[${MULTILIB_USEDEP}]
	sys-apps/util-linux[${MULTILIB_USEDEP}]
	sys-libs/libcap[${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
	virtual/libffi[${MULTILIB_USEDEP}]
	virtual/opengl[${MULTILIB_USEDEP}]
	x11-libs/libICE[${MULTILIB_USEDEP}]
	x11-libs/libSM[${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXau[${MULTILIB_USEDEP}]
	x11-libs/libXdmcp[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXi[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	x11-libs/libxcb:=[${MULTILIB_USEDEP}]
	video_cards_nvidia? ( x11-drivers/nvidia-drivers:=[${MULTILIB_USEDEP}] )
"

#S=${WORKDIR}/${P}

pkg_nofetch() {
	[[ -f "${DISTDIR}/${A}" ]] || {
		eerror
		ewarn "This package can only downloaded and installed if you receive a"
		ewarn "personal non-commercial license from Pixar Studios(tm)."
		eerror "To get such license, perform the following steps:"
		eerror "	1. Goto https://renderman.pixar.com/store and click the button"
		eerror "		under Non-commercial"
		eerror "	2. Register on their forums, or login if you are already registered."
		eerror "	3. Fill out the survey and follow the steps to download the linux"
		eerror "		rpm from"
		eerror "	https://renderman.pixar.com/forum/ncrdownload.php?platform=linux."
		eerror "		Save the file"
		eerror "	RenderMan-InstallerNCR-${PVR}_1891132-linuxRHEL7_gcc48icc170.x86_64.rpm"
		eerror "		in your ${DISTDIR}."
		eerror
		die "Need to manually download the package."
	}
}

src_unpack() {
	mkdir "${S}"
	cd "${S}"
	rpm_src_unpack ${A}
	cd "${WORKDIR}"
}

src_install() {
	# move anything to /opt
	mv "${S}"/opt "${D}"/opt || die

	insinto /etc/env.d
	newins "${FILESDIR}"/${P}-99renderman 99renderman
}

pkg_postinst() {
	ewarn
	ewarn "Remember to run env-update && . /etc/profile to update env vars."
	ewarn

	einfo
	einfo "You need to run"
	einfo "/opt/pixar/RenderMan-Installer-ncr-22.1/bin/RenderManInstaller"
	einfo "as root, and select the RenderMan Pro Server 22.1 option to"
	einfo "actually download and install RenderMan."
	ewarn "You need to have your Pixar forum login credentials ready!"
	einfo

	einfo
	einfo "NOTE: Pixar needs you to re-evaluate your license with them every"
	einfo "120 days."
	einfo "Keep this in mind if your renderman suddenly stops working."
	einfo
}

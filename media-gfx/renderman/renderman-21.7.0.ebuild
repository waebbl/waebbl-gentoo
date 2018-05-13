# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# TODO: add amd64 only multilib-support -> package provides no 32-bit

EAPI=6

inherit rpm

DESCRIPTION="Renderman render engine"
HOMEPAGE="https://renderman.pixar.com/"
SRC_URI="RenderMan-InstallerNCR-21.7.0_1837774-linuxRHEL6_gcc44icc150.x86_64.rpm"

LICENSE="RenderMan-TMPL"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RESTRICT="bindist mirror fetch strip"

DEPEND=""

# list from ldd output of the RenderManInstaller
# Qt-5.6.1 is shipped with the installer
RDEPEND="dev-libs/glib
	x11-libs/libXext
	x11-libs/libX11
	virtual/opengl
	sys-libs/zlib
	x11-libs/libXi
	x11-libs/libSM
	x11-libs/libICE
	sys-apps/dbus
	x11-libs/libxcb
	media-libs/fontconfig
	media-libs/freetype
	x11-libs/libXrender
	dev-libs/libffi
	dev-libs/libpcre
	sys-apps/util-linux
	dev-libs/libbsd
	sys-apps/systemd
	x11-libs/libXau
	x11-libs/libXdmcp
	dev-libs/expat
	app-arch/bzip2
	media-libs/libpng:0
	media-libs/harfbuzz
	sys-libs/libcap
	app-arch/xz-utils
	app-arch/lz4
	dev-libs/libgcrypt:0
	media-gfx/graphite2
	sys-apps/attr
	dev-libs/libgpg-error"

# Source directory; the dir where the sources can be found (automatically
# unpacked) inside ${WORKDIR}.  The default value for S is ${WORKDIR}/${P}
# If you don't need to change it, leave the S= line out of the ebuild
# to keep it tidy.
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
		eerror "	RenderMan-InstallerNCR-21.7.0_1837774-linuxRHEL6_gcc44icc150.x86_64.rpm"
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
	mv "${S}/opt" "${D}/opt" || die

	insinto /etc/env.d
	doins "${FILESDIR}"/99renderman
}

pkg_postinst() {
	ewarn
	ewarn "Remember to run env-update && . /etc/profile to update env vars."
	ewarn

	einfo
	einfo "You need to run"
	einfo "/opt/pixar/RenderMan-Installer-ncr-21.7/bin/RenderManInstaller"
	einfo "as root, and select the RenderMan Pro Server 21.7 option to"
	einfo "actually download and install RenderMan."
	ewarn "You need to have your Pixar forum login credentials ready!"
	einfo
}

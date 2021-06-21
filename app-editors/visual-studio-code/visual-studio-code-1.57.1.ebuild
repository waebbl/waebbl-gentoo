# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 desktop eapi8-dosym pax-utils

DESCRIPTION="Multiplatform Visual Studio Code from Microsoft"
HOMEPAGE="https://code.visualstudio.com"
BASE_URI="https://update.code.visualstudio.com/${PV}"
SRC_URI="${BASE_URI}/linux-x64/stable -> ${P}.tar.gz
	https://raw.githubusercontent.com/waebbl/waebbl-gentoo/master/patches/visual-studio-code.png.xz"
S="${WORKDIR}/VSCode-linux-x64"

RESTRICT="mirror strip bindist"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gnome-keyring"

DEPEND="
	gnome-base/gsettings-desktop-schemas
	media-libs/libpng:=
	x11-libs/cairo
	>=x11-libs/gtk+-2.24.31-r1:2
	x11-libs/libXtst
"
RDEPEND="
	${DEPEND}
	>=net-print/cups-2.1.4
	>=x11-libs/libnotify-0.7.7
	>=x11-libs/libXScrnSaver-1.2.2-r1
	dev-libs/nss
	gnome-keyring? ( app-crypt/libsecret[crypt] )
"

QA_PREBUILT="opt/${PN}/*"
QA_PRESTRIPPED="opt/${PN}/*"

src_install(){
	local DEST="/opt/${PN}"
	pax-mark m code
	insinto "${DEST}"
	doins -r *
	dosym8 -r "${DEST}/bin/code" "/usr/bin/${PN}"
	dosym8 -r "${DEST}/bin/code" "/usr/bin/vscode"
	make_desktop_entry "vscode" "Visual Studio Code" "${PN}" "Development;IDE"
	doicon "${WORKDIR}/${PN}.png"
	fperms +x "${DEST}/code"
	fperms +x "${DEST}/bin/code"
#	fperms +x "${DEST}/libnode.so"
	fperms +x "${DEST}/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/rg"
	fperms +x "${DEST}/resources/app/extensions/git/dist/askpass.sh"
	insinto "/usr/share/licenses/${PN}"
	for i in resources/app/LICEN*;
	do
		newins "${i}" "`basename ${i}`"
	done
	for i in resources/app/licenses/*;
	do
		newins "${i}" "`basename ${i}`"
	done

	dobashcomp resources/completions/bash/code
}

pkg_postinst(){
	einfo "You may install some additional utils, so check them in:"
	einfo "https://code.visualstudio.com/Docs/setup#_additional-tools"
}

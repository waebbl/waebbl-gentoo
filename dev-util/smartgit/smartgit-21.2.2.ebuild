# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop java-pkg-2 optfeature xdg

MY_PV="$(ver_rs 1- '_')"
MY_P="${PN}-linux-${MY_PV}"

DESCRIPTION="Git client with support for GitHub Pull Requests+Comments, SVN and Mercurial"
HOMEPAGE="https://www.syntevo.com/smartgit"
SRC_URI="https://www.syntevo.com/downloads/smartgit/${MY_P}.tar.gz"
S="${WORKDIR}"/${PN}

SLOT="0"
LICENSE="smartgit"
KEYWORDS="~amd64 ~x86"

RESTRICT="bindist fetch mirror"

RDEPEND=">=virtual/jre-1.8:1.8"
DEPEND="${RDEPEND}"

QA_FLAGS_IGNORED='.*'

pkg_nofetch(){
	einfo "Please download ${MY_P} from:"
	einfo "http://www.syntevo.com/smartgit/download"
	einfo "and move/copy it to your DISTDIR folder"
}

pkg_setup() {
	java-pkg-2_pkg_setup
}

src_install() {
	local rdir="/opt/${PN}" X
	insinto ${rdir}
	doins -r *
	chmod +x "${ED}"${rdir}/bin/smartgit.sh || die

	java-pkg_register-environment-variable SWT_GTK3 0
	java-pkg_regjar "${ED}"/${rdir}/lib/*.jar
#	java-pkg_dolauncher ${PN} --java_args "-Dsun.io.useCanonCaches=false -Xmx768m -Xverify:none -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:InitiatingHeapOccupancyPercent=25" --jar bootloader.jar

	for X in 32 48 64 128 256; do
		doicon -s ${X} "${ED}"${rdir}/bin/smartgit-${X}.png
	done
	doicon -s scalable "${ED}"${rdir}/bin/smartgit.svg
	make_desktop_entry "bash ${rdir}/bin/${PN}.sh" "SmartGIT" "/usr/share/icons/hicolor/scalable/apps/${PN}.svg" "Development;RevisionControl"

	# remove integrated git
	rm -r "${ED}"${rdir}/git || die
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "${PN} relies on external git executables to work."
	elog "To run SmartGIT run /opt/${PN}/bin/${PN}.sh"
	ewarn "Please note, the current version needs java-11 to work!"
	optfeature "Git support" dev-vcs/git
}

pkg_postrm() {
	xdg_pkg_postrm
}

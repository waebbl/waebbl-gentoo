# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit vcs-snapshot versionator

MY_PV="$(replace_all_version_separators '_')"
MY_PN="$(replace_all_version_separators '_' ${PN})"
BLENDER_MIN_PV="2.78"

DESCRIPTION="RenderMan addon for blender"
HOMEPAGE="https://github.com/prman-pixar/RenderManForBlender"
SRC_URI="https://github.com/prman-pixar/RenderManForBlender/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

DOCS=( README.md installation.txt changelog.txt )

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=media-gfx/blender-${BLENDER_MIN_PV}
	=media-gfx/renderman-${PV}"

src_install() {
	# TODO: improve this, will break on -rX releases!
	local blend_p="$(best_version media-gfx/blender)"
	local blend_pv="$(echo ${blend_p} | cut -d - -f 3)"
	local mypath="/usr/share/blender/${blend_pv}/scripts/addons/${MY_PN}"
	insinto ${mypath}
	doins -r "${S}"/*
	einstalldocs
	rm "${ED}/${mypath}"/LICENSE.txt \
		"${ED}/${mypath}"/README.md \
		"${ED}/${mypath}"/installation.txt \
		"${ED}/${mypath}"/changelog.txt
}

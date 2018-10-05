# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO: verify it will work with 'renderman-for-blender' instead of
#		'renderman_for_blender'

EAPI=6

inherit eapi7-ver

MY_PV=$(ver_rs 1- "_")
BLENDER_MIN_PV="2.78"

DESCRIPTION="RenderMan addon for blender"
HOMEPAGE="https://github.com/prman-pixar/RenderManForBlender"
SRC_URI="https://github.com/prman-pixar/RenderManForBlender/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

DOCS=( README.md installation.txt changelog.txt )

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/RenderManForBlender-${MY_PV}"

RDEPEND="
	>=media-gfx/blender-${BLENDER_MIN_PV}
	>=media-gfx/renderman-${PV}
"

src_install() {
	local blend_p="$(best_version media-gfx/blender)"
	local blend_pv="$(echo ${blend_p} | cut -d - -f 3)"
	blend_pv=$(ver_cut 1-2 "${blend_pv}")
	local mypath="/usr/share/blender/${blend_pv}/scripts/addons/${PN}"
	insinto ${mypath}
	doins -r "${S}"/*
	einstalldocs
	rm "${ED}/${mypath}"/LICENSE.txt \
		"${ED}/${mypath}"/README.md \
		"${ED}/${mypath}"/installation.txt \
		"${ED}/${mypath}"/changelog.txt
}

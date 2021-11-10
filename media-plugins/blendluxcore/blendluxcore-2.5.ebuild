# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_9 )
inherit python-single-r1

DESCRIPTION="A PBS rendering plugin for blender"
HOMEPAGE="https://luxcorerender.org"
SRC_URI="https://github.com/LuxCoreRender/BlendLuxCore/archive/${PN}_v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/BlendLuxCore-${PN}_v${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	media-gfx/blender:2.93[${PYTHON_SINGLE_USEDEP}]
"
DEPEND="${RDEPEND}"

DOCS=( readme.md )

pkg_setup() {
	python-single-r1_pkg_setup
}

src_install() {
	einstalldocs

	local blenpv
	blenpv=$(best_version media-gfx/blender)
	blenpv=${blenpv#media-gfx/blender-}
	blenpv="${blenpv:0:4}"
	blenpv="/usr/share/blender/${blenpv}/scripts/addons/${PN}"
	mkdir -p "${ED}/${blenpv}" || die
	cp -r "${S}"/* "${ED}/${blenpv}" || die
	python_optimize "${ED}/${blenpv}"
}

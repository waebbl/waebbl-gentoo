# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{3,4,5,6} )

inherit bash-completion-r1 distutils-r1

DESCRIPTION="A dockerized approach to test a Gentoo package within a clean stage3 container"
HOMEPAGE="http://ebuildtester.readthedocs.io/"

case ${PV} in
9999)
	EGIT_REPO_URI="https://github.com/nicolasbock/ebuildtester.git"
	inherit git-r3
esac

LICENSE="BSD"
SLOT="0"
IUSE="test"

PATCHES=( "${FILESDIR}/${PN}-${PV}-fix_docker.py.patch" )

RDEPEND="
	app-emulation/docker
"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
"

src_install() {
	distutils-r1_src_install
	newbashcomp "${FILESDIR}/${PN}.bash-completion" "${PN}"
}

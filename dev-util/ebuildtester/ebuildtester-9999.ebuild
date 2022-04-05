# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8,9} )

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
RESTRICT="!test? ( test )"

RDEPEND="app-containers/docker"
DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
"

src_install() {
	distutils-r1_src_install
	newbashcomp "${FILESDIR}/${PN}.bash-completion" "${PN}"
}

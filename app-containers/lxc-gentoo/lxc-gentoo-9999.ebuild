# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="LXC container creation script for gentoo containers"
HOMEPAGE="https://github.com/globalcitizen/lxc-gentoo"
EGIT_REPO_URI="https://github.com/globalcitizen/lxc-gentoo.git"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND="app-containers/lxc"
RDEPEND="${DEPEND}"

src_install() {
	dobin lxc-gentoo
}

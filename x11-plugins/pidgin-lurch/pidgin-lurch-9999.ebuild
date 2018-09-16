# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="XEP-0384: OMEMO Encryption for libpurple"
HOMEPAGE="https://github.com/gkdr/lurch"
EGIT_REPO_URI="https://github.com/gkdr/lurch.git"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="dev-db/sqlite
        dev-libs/libgcrypt:*
        dev-libs/libxml2
        dev-libs/mxml
        net-im/pidgin"
DEPEND="${RDEPEND}
        dev-util/cmake"

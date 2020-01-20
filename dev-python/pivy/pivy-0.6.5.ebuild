# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="Coin3D bindings for Python"
HOMEPAGE="https://github.com/coin3d/pivy"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	PIVY_REPO_URI="https://github.com/coin3d/pivy.git"
else
	SRC_URI="https://github.com/coin3d/pivy/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="ISC"
SLOT="0"
IUSE=""

# FIXME: change the deps to >= once the older versions are dropped
# for now we need to depend on exact version, because the older
# *a and *a_pre* versions are considered of higher version by portage
RDEPEND="
	~media-libs/coin-4.0.0
	~media-libs/SoQt-1.6.0
"
DEPEND="${RDEPEND}"
BDEPEND="dev-lang/swig"

PATCHES=( "${FILESDIR}/${PN}-0.6.4-find-SoQt.patch" )

DOCS=( AUTHORS HACKING NEWS README.md THANKS )

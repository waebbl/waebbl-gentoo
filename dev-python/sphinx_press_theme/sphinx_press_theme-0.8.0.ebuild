# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Theme for sphinx, based on VuePress"
HOMEPAGE="https://github.com/schettino72/sphinx_press_theme"
SRC_URI="https://github.com/schettino72/sphinx_press_theme/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# no tests available
RESTRICT="test"

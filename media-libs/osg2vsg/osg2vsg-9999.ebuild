# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Library and utilities between OSG and VSG"
HOMEPAGE="https://github.com/vsg-dev/osg2vsg/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/${PN}.git"
fi

LICENSE="MIT"
SLOT="0"

RESTRICT="test" # no testsuite yet

RDEPEND="
	dev-games/openscenegraph:=
	dev-util/glslang
	dev-util/spirv-tools
	media-libs/shaderc
	media-libs/vsg
	media-libs/vulkan-loader
	virtual/opengl
	x11-libs/libxcb:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=( "${FILESDIR}"/${PN}-9999-use-GNUInstallDirs-for-installation.patch )

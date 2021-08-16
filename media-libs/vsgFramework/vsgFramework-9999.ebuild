# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meta package to pull in VulkanSceneGraph libs"
HOMEPAGE="https://github.com/vsg-dev/vsgFramework"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgFramework.git"
fi

LICENSE="MIT"
SLOT="0"
IUSE="assimp curl freetype gdal openscenegraph source"
RESTRICT="test"

RDEPEND="
	dev-util/glslang
	media-gfx/vsgExamples[source?]
	media-libs/vsg
	media-libs/vsgGIS
	media-libs/vsgImGui
	media-libs/vsgXchange[assimp?,curl?,freetype?,gdal?,openscenegraph?]
	media-libs/vulkan-loader[X]
	x11-libs/libxcb:=
"
DEPEND="${RDEPEND}"

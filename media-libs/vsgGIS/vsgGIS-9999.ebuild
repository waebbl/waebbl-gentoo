# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Library providing GIS related functionality for VulkanSceneGraph"
HOMEPAGE="https://github.com/vsg-dev/vsgGIS"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/vsg-dev/vsgGIS.git"
fi

LICENSE="MIT"
SLOT="0"

RESTRICT="test"

RDEPEND="
	dev-util/glslang
	media-libs/vsg
	media-libs/vulkan-loader[X]
	sci-libs/gdal:=
	x11-libs/libxcb:=
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	sed -e "s/DESTINATION lib/DESTINATION $(get_libdir)/" \
		-e 's/VSGGIS_MAJOR_VERSION/VSGGIS_VERSION_MAJOR/' \
		-e 's/VSGGIS_MINOR_VERSION/VSGGIS_VERSION_MINOR/' \
		-e 's/VSGGIS_PATCH_VERSION/VSGGIS_VERSION_PATCH/' \
		-i src/vsgGIS/CMakeLists.txt || die

	cmake_src_prepare
}

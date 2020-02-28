# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7} )

inherit cmake python-single-r1

DESCRIPTION="Library for efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
SRC_URI="https://github.com/AcademySoftwareFoundation/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# Note: ABI 3 has been deprecated with 7.0.0
IUSE="cpu_flags_x86_avx cpu_flags_x86_sse4_2 doc numpy openvdb_abi_3 openvdb_abi_4 openvdb_abi_5 openvdb_abi_6 +openvdb_abi_7 python static-libs test utils"
REQUIRED_USE="
	|| ( openvdb_abi_3 openvdb_abi_4 openvdb_abi_5 openvdb_abi_6 openvdb_abi_7 )
	numpy? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )
"

# required dependencies: ilmbase, tbb, zlib, boost
# configurable dependencies: openexr, log4cplus, blosc, jemalloc, glfw / opengl
RDEPEND="
	>=dev-libs/c-blosc-1.5.0
	dev-libs/jemalloc
	dev-libs/log4cplus
	media-libs/glfw:=
	media-libs/openexr:=
	sys-libs/zlib:=
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-libs/boost-1.62:=[python?,${PYTHON_MULTI_USEDEP}]
			numpy? ( dev-python/numpy[${PYTHON_MULTI_USEDEP}] )
		')
	)"

DEPEND="${RDEPEND}
	>=dev-util/cmake-3.16.2-r1
	dev-cpp/tbb
	virtual/pkgconfig
	doc? ( app-doc/doxygen[latex] )
	test? ( dev-util/cppunit )"

PATCHES=(
	"${FILESDIR}/${P}-0001-Fix-multilib-header-source.patch"
	"${FILESDIR}/${P}-0002-Fix-doc-install-dir.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local myprefix="${EPREFIX}/usr/"
	local openvdb_version=7

	if use openvdb_abi_3; then
		openvdb_version=3
	elif use openvdb_abi_4; then
		openvdb_version=4
	elif use openvdb_abi_5; then
		openvdb_version=5
	elif use openvdb_abi_6; then
		openvdb_version=6
	elif use openvdb_abi_7; then
		openvdb_version=7
	else
		die "Openvdb ABI version not specified"
	fi

	# top-level available options=default value (dependant option)
	# OPENVDB_BUILD_CORE=ON
	# OPENVDB_BUILD_BINARIES=ON
	# OPENVDB_BUILD_PYTHON_MODULE=OFF
	# OPENVDB_BUILD_UNITTESTS=OFF
	# OPENVDB_BUILD_DOCS=OFF
	# OPENVDB_BUILD_HOUDINI_PLUGIN=OFF
	# OPENVDB_INSTALL_HOUDINI_PYTHONRC=OFF
	# OPENVDB_BUILD_MAYA_PLUGIN=OFF
	# OPENVDB_ENABLE_RPATH=ON
	# OPENVDB_CXX_STRICT=OFF
	# OPENVDB_CODE_COVERAGE=OFF
	# OPENVDB_INSTALL_CMAKE_MODULES=ON (OPENVDB_BUILD_CORE)
	# USE_HOUDINI=OFF
	# USE_MAYA=OFF
	# USE_BLOSC=ON
	# USE_LOG4CPLUS=OFF
	# USE_EXR=OFF
	# OPENVDB_DISABLE_BOOST_IMPLICIT_LINKING=ON (WIN32)
	# USE_CCACHE=ON
	# DISABLE_DEPENDENCY_VERSION_CHECKS=OFF
	# DISABLE_CMAKE_SEARCH_PATHS=OFF
	# OPENVDB_USE_DEPRECATED_ABI=OFF
	# OPENVDB_FUTURE_DEPRECATION=OFF
	# USE_COLORED_OUTPUT=OFF
	# deprecated: OPENVDB_BUILD_HOUDINI_SOPS=OFF
	# deprecated: OPENVDB_ENABLE_3_ABI_COMPATIBLE=OFF
	# deprecated: USE_SYSTEM_LIBRARY_PATHS=!DISABLE_CMAKE_SEARCH_PATHS
	# OPENVDB_BUILD_DOCS=OFF
	# OPENVDB_SIMD avx||sse42

	# openvdb subdir options=default value
	# OPENVDB_CORE_SHARED=ON
	# OPENVDB_CORE_STATIC=ON

	# openvdb/python options=default value
	# USE_NUMPY=OFF
	# OPENVDB_PYTHON_WRAP_ALL_GRID_TYPES=OFF

	# openvdb/cmd options=default value
	# OPENVDB_BUILD_VDB_PRINT=ON
	# OPENVDB_BUILD_VDB_LOD=OFF
	# OPENVDB_BUILD_VDB_RENDER=OFF
	# OPENVDB_BUILD_VDB_VIEW=OFF (opengl / glfw)
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}/"
		-DOPENVDB_ABI_VERSION_NUMBER="${openvdb_version}"
		-DOPENVDB_BUILD_DOCS=$(usex doc)
		-DOPENVDB_BUILD_PYTHON_MODULE=$(usex python)
		-DOPENVDB_BUILD_UNITTESTS=$(usex test)
		-DOPENVDB_CORE_SHARED=ON
		-DOPENVDB_CORE_STATIC=$(usex static-libs)
		-DOPENVDB_ENABLE_RPATH=OFF
		-DUSE_CCACHE=OFF # automagic dependency
		-DUSE_COLORED_OUTPUT=ON
		-DUSE_EXR=ON
		-DUSE_LOG4CPLUS=ON
		-DUSE_NUMPY=$(usex numpy)
		-DCHOST="${CHOST}"
	)

	if use cpu_flags_x86_avx; then
		mycmakeargs+=( -DOPENVDB_SIMD=AVX ) # includes sse4_2 support as well
	elif use cpu_flags_x86_sse4_2; then
		mycmakeargs+=( -DOPENVDB_SIMD=SSE42 )
	fi

	if use python; then
		mycmakeargs+=( -DPython_EXECUTABLE="${PYTHON}" )
	fi

	if use utils; then
		mycmakeargs+=(
			-DOPENVDB_BUILD_VDB_LOD=ON
			-DOPENVDB_BUILD_VDB_RENDER=ON
			-DOPENVDB_BUILD_VDB_VIEW=ON
		)
	fi

	cmake_src_configure
}

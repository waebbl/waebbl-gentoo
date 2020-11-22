# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

#PYTHON_COMPAT=( python3_{6..8} )

inherit cmake multiprocessing
#python-single-r1

DESCRIPTION="Open framework for storing and sharing scene data"
HOMEPAGE="https://www.alembic.io/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#python
IUSE="examples hdf5 prman test zlib"
RESTRICT="!test? ( test )"

# pyalembic python bindings need boost
#	${PYTHON_REQUIRED_USE}
REQUIRED_USE="
	hdf5? ( zlib )
"

#	$(python_gen_cond_dep '
#		boost? ( >=dev-libs/boost-1.65.0:=[python?,${PYTHON_MULTI_USEDEP}] )
#	')
#	${PYTHON_DEPS}
#	python? ( >=dev-python/pyilmbase-2.5.0[${PYTHON_SINGLE_USEDEP}] )
RDEPEND="
	>=media-libs/openexr-2.5.0:=
	hdf5? ( >=sci-libs/hdf5-1.10.2:=[zlib(+)] )
	zlib? ( >=sys-libs/zlib-1.2.11-r1 )
"
DEPEND="${RDEPEND}"
BDEPEND=""

DOCS=( "ACKNOWLEDGEMENTS.txt" "FEEDBACK.txt" "NEWS.txt" "README.txt" )

PATCHES=( "${FILESDIR}/${PN}-1.7.11-0005-Fix-install-locations.patch" )

src_configure() {
	local mycmakeargs=(
		-DALEMBIC_SHARED_LIBS=ON
		# C++-11 and thus {shared,unique,weak}_ptr are common nowadays, so these
		# are no longer needed and using boost fails.
		-DALEMBIC_LIB_USES_BOOST=OFF
		-DALEMBIC_LIB_USES_TR1=OFF
		-DUSE_ARNOLD=OFF
		-DUSE_BINARIES=ON
		-DUSE_EXAMPLES=$(usex examples)
		-DUSE_HDF5=$(usex hdf5)
		-DUSE_MAYA=OFF
		-DUSE_PRMAN=$(usex prman)
#		-DUSE_PYALEMBIC=$(usex python)
		-DUSE_PYALEMBIC=OFF
		-DUSE_TESTS=$(usex test)
	)

#	if use python; then
#		mycmakeargs+=(
#			-DPython_EXECUTABLE=${EPYTHON}
#			-DPython_LIBRARY=$(python_get_library_path)
#		)
#	fi

	cmake_src_configure
}

pkg_postinst() {
	if use prman; then
		einfo "If you're looking for an ebuild for renderman, you may want to"
		einfo "try the waebbl overlay: 'eselect repository enable waebbl'"
		einfo "followed by 'emerge renderman'"
	fi
}

# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit cmake multiprocessing python-single-r1

DESCRIPTION="Open framework for storing and sharing scene data"
HOMEPAGE="https://www.alembic.io/"

# WARNING: TEMPORARY EGIT_REPO_URI and EGIT_BRANCH used for testing
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/lamiller0/alembic.git"
	EGIT_BRANCH="python3_fixes"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
IUSE="examples hdf5 python test"
RESTRICT="!test? ( test )"

REQUIRED_USE="
	examples? ( python test? ( hdf5 ) )
	python? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	dev-libs/imath:=[${PYTHON_SINGLE_USEDEP}]
	hdf5? ( >=sci-libs/hdf5-1.10.2:=[zlib(+)] )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-libs/boost:=[python?,${PYTHON_MULTI_USEDEP}]
		')
	)
"
DEPEND="${RDEPEND}"
BDEPEND="python? ( ${PYTHON_DEPS} )"

DOCS=( ACKNOWLEDGEMENTS.txt FEEDBACK.txt NEWS.txt README.txt )

PATCHES=(
	"${FILESDIR}"/${P}-0001-fix-lib-install-dir.patch
)

pkg_pretend() {
	ewarn "WARNING: This package version is for testing purposes ONLY."
	ewarn "WARNING: It WILL break downstream packages!!!"
	ewarn "WARNING: Only install, if you know exactly what you are doing."
}

src_configure() {
	local mycmakeargs=(
		-DUSE_ARNOLD=OFF
		-DUSE_BINARIES=ON
		-DUSE_EXAMPLES=$(usex examples)
		-DUSE_HDF5=$(usex hdf5)
		-DUSE_MAYA=OFF
		-DUSE_PRMAN=OFF
		-DUSE_PYALEMBIC=$(usex python)
		-DUSE_TESTS=$(usex test)
	)

	if use python; then
		mycmakeargs+=(
			-DPython3_EXECUTABLE=${PYTHON}
			-DPython3_LIBRARY=$(python_get_library_path)
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
		docinto examples
		dodoc -r "${S}"/examples/AbcClients
	fi
}

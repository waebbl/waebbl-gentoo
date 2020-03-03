# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# boost-1.72.0-r1 is missing python 3.8 support
PYTHON_COMPAT=( python3_{6,7} )

inherit cmake flag-o-matic python-r1 toolchain-funcs multilib-minimal

DESCRIPTION="ILM's OpenEXR high dynamic-range image file format libraries"
HOMEPAGE="https://www.openexr.com/"
SRC_URI="https://github.com/AcademySoftwareFoundation/openexr/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0/24" # based on SONAME
#KEYWORDS="~amd64 -arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"
KEYWORDS="~amd64 ~x86"
IUSE="cpu_flags_x86_avx exceptions examples large-stack python static-libs utils viewers test"
RESTRICT="!test? ( test )"

MY_PN=${PN:0:7}
MY_P=${MY_PN}-${PV}
S="${WORKDIR}/${MY_P}"

RDEPEND="
	!media-libs/ilmbase
	!media-libs/openexr
	sys-libs/zlib[${MULTILIB_USEDEP}]
	python? (
		!dev-python/pyilmbase
		${PYTHON_DEPS}
		dev-libs/boost[${MULTILIB_USEDEP},${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
	)
	viewers? (
		!media-gfx/openexr_viewers
		media-gfx/nvidia-cg-toolkit[${MULTILIB_USEDEP}]
		media-libs/freeglut[${MULTILIB_USEDEP}]
		virtual/opengl[${MULTILIB_USEDEP}]
		x11-libs/fltk[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig[${MULTILIB_USEDEP}]"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	exceptions? ( python )
"

DOCS=( CHANGES.md CODEOWNERS CODE_OF_CONDUCT.md CONTRIBUTING.md
	CONTRIBUTORS.md GOVERNANCE.md INSTALL.md README.md SECURITY.md
	doc/MultiViewOpenEXR.odt doc/OpenEXRFileLayout.odt
	doc/ReadingAndWritingImageFiles.odt doc/TechnicalIntroduction.odt )

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/OpenEXR/IlmBaseConfigInternal.h
	/usr/include/OpenEXR/OpenEXRConfigInternal.h
)

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-python-2-specific-cmake-code.patch"
	"${FILESDIR}/${P}-0002-Add-option-to-install-PyIlmBase-pkg-config-file.patch"
)

python_bindings_needed() {
	multilib_is_native_abi && use python
}

src_prepare() {
	# Fix default path for Cg
	sed -e 's|Cg_ROOT "/usr" CACHE|Cg_ROOT "/opt/nvidia-cg-toolkit" CACHE|' \
		-i "${S}"/OpenEXR_Viewers/config/LocateCg.cmake || die "failed to set Cg path"

	# Fix include dir for Cg to not include the Cg subdir
	sed -e 's|\${Cg_INCLUDE_DIR}|\${Cg_INCLUDE_DIR}/..|' \
		-i "${S}"/OpenEXR_Viewers/config/LocateCg.cmake || die "failed to set Cg include dir"

	# Fix path for testsuite
	sed -i -e "s:/var/tmp/:${T}:" "${S}"/OpenEXR/IlmImfTest/tmpDir.h || die "failed to set temp path for tests"

	cmake_src_prepare
	multilib_copy_sources
}

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON						# default
		-DBUILD_TESTING=$(usex test)

		-DILMBASE_BUILD_BOTH_STATIC_SHARED=$(usex static-libs)
		-DILMBASE_ENABLE_LARGE_STACK=$(usex large-stack)
		-DILMBASE_INSTALL_PKG_CONFIG=ON				# default

		-DOPENEXR_BUILD_BOTH_STATIC_SHARED=$(usex static-libs)
		-DOPENEXR_BUILD_UTILS=$(usex utils)
		-DOPENEXR_INSTALL_PKG_CONFIG=ON				# default

		-DOPENEXR_VIEWERS_ENABLE=$(usex viewers)

		-DPYILMBASE_ENABLE=$(usex python)
	)

	cmake_src_configure

	if python_bindings_needed; then
		python_configure() {
			mycmakeargs+=(
				-DPYILMBASE_INSTALL_PKG_CONFIG=ON	# default
				-DPYIMATH_ENABLE_EXCEPTIONS=$(usex exceptions)
				-DPython3_EXECUTABLE="${EPREFIX}/${PYTHON}"
				-DPython3_INCLUDE_DIR=$(python_get_includedir)
				-DPython3_LIBRARY=$(python_get_library_path)
			)
			cmake_src_configure
		}
		python_foreach_impl python_configure
	fi
}

multilib_src_compile() {
	cmake_src_compile

	if python_bindings_needed; then
		python_foreach_impl cmake_src_compile
	fi
}

multilib_src_install_all() {
	einstalldocs

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
	else
		rm -rf "${ED%/}"/usr/share/doc/${PF}/examples || die
	fi

	# package provides .pc files
	find "${D}" -name '*.la' -delete || die
}

multilib_src_install() {
	cmake_src_install

	if python_bindings_needed; then
		python_foreach_impl cmake_src_install
	fi
}

multilib_src_test() {
	local tst=( HalfTest IexTest IlmImfTest IlmImfUtilTest ImathTest )
	pushd "${BUILD_DIR}/bin" >/dev/null || die
		for t in ${tst[@]}; do
			./${t} || die "Test ${t} failed"
		done
	popd >/dev/null || die
}

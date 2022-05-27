# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_STANDARD="77 90"
PYTHON_COMPAT=( python3_{8..11} )

inherit cmake cuda fortran-2 python-any-r1 toolchain-funcs

MY_PV=$(ver_rs 3 '-')

DESCRIPTION="Matrix Algebra on GPU and Multicore Architectures"
HOMEPAGE="
	https://icl.cs.utk.edu/magma/
	https://bitbucket.org/icl/magma
"
SRC_URI="https://icl.cs.utk.edu/projectsfiles/${PN}/downloads/${PN}-${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE_AMDGPU="
	amdgpu_gfx600 amdgpu_gfx601 amdgpu_gfx602
	amdgpu_gfx700 amdgpu_gfx701 amdgpu_gfx702 amdgpu_gfx703 amdgpu_gfx704 amdgpu_gfx705
	amdgpu_gfx801 amdgpu_gfx802 amdgpu_gfx803 amdgpu_gfx805 amdgpu_gfx810
	amdgpu_gfx900 amdgpu_gfx902 amdgpu_gfx904 amdgpu_gfx906 amdgpu_gfx908 amdgpu_gfx909 amdgpu_gfx90a amdgpu_gfx90c amdgpu_gfx940
	amdgpu_gfx1010 amdgpu_gfx1011 amdgpu_gfx1012 amdgpu_gfx1013 amdgpu_gfx1030 amdgpu_gfx1031 amdgpu_gfx1032 amdgpu_gfx1033 amdgpu_gfx1034 amdgpu_gfx1035 amdgpu_gfx1036
	amdgpu_gfx1100 amdgpu_gfx1101 amdgpu_gfx1102 amdgpu_gfx1103
"
#IUSE="doc openblas test ${IUSE_AMDGPU}"
IUSE="ampere doc cuda hip kepler maxwell openblas pascal test turing video_cards_nvidia volta ${IUSE_AMDGPU}"
#kepler maxwell pascal volta turing ampere

# TODO: do not enforce openblas
RDEPEND="
	openblas? ( sci-libs/openblas )
	!openblas? (
		virtual/blas
		virtual/lapack
	)
"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	cuda? ( dev-util/nvidia-cuda-toolkit[profiler] )
	hip? ( dev-util/hip )
"
#	dev-util/hip
BDEPEND="
	virtual/pkgconfig
	doc? ( >=app-doc/doxygen-1.8.14-r1[dot] )
"

REQUIRED_USE="
	^^ ( cuda hip )
	ampere? ( cuda )
	cuda? ( video_cards_nvidia || ( ampere kepler maxwell pascal turing volta ) )
	hip? ( || ( ${IUSE_AMDGPU/+/} ) )
	kepler? ( cuda )
	maxwell? ( cuda )
	pascal? ( cuda )
	turing? ( cuda )
	volta? ( cuda )
"
RESTRICT="!test? ( test )"

pkg_setup() {
	[[ MERGE_TYPE != binary ]] && tc-check-openmp || die "Need OpenMP to compile ${P}"
	fortran-2_pkg_setup
	python-any-r1_pkg_setup
}

src_prepare() {
#	set_cuda_gpu_target() {
#		if use ampere; then
#			GPU_TARGET=Ampere
#		elif use kepler; then
#			GPU_TARGET=Kepler
#		elif use maxwell; then
#			GPU_TARGET=Maxwell
#		elif use pascal; then
#			GPU_TARGET=Pascal
#		elif use turing; then
#			GPU_TARGET=Turing
#		elif use volta; then
#			GPU_TARGET=Volta
#		fi
#		export GPU_TARGET
#	}

# remove this if not needed for amdgpu targets
#	set_amd_gpu_target() {
#	}

	use cuda && cuda_src_prepare

# *must not* be removed, if we want to use make generate with CUDA
#	rm -r blas_fix || die
	# distributed pc file not so useful so replace it
	cat <<-EOF > ${PN}.pc
		prefix=${EPREFIX}/usr
		libdir=\${prefix}/$(get_libdir)
		includedir=\${prefix}/include/${PN}
		Name: ${PN}
		Description: ${DESCRIPTION}
		Version: ${PV}
		URL: ${HOMEPAGE}
		Libs: -L\${libdir} -lmagma
		Libs.private: -lm -lpthread -ldl
		Cflags: -I\${includedir}
		Requires: $(usex openblas "openblas" "blas lapack")
	EOF

# not necessary, according to README, only needed for live ebuilds
#	if use cuda; then
#		echo -e 'BACKEND = cuda' > make.inc
#		set_cuda_gpu_target
#	elif use hip; then
#		echo -e 'BACKEND = hip' > make.inc
#		set_amd_gpu_target
#	else
#		die "Need to select one the backends `cuda` or `hip`"
#	fi
#	echo -e 'FORT = true' >> make.inc
#	emake cleangen generate

	cmake_src_prepare
}

src_configure() {
	# other options: Intel10_64lp, Intel10_64lp_seq, Intel10_64ilp, Intel10_64ilp_seq, Intel10_32, FLAME, ACML, Apple, NAS
	local blasvendor="Generic"
	local gpu=""
	use openblas && blasvendor="OpenBLAS"

	if use cuda; then
#		ewarn "Cuda selection not fully implemented yet"
		if use ampere; then
			gpu="Ampere"
		elif use volta; then
			gpu="Volta"
		elif use turing; then
			gpu="Turing"
		elif use pascal; then
			gpu="Pascal"
		elif use maxwell; then
			gpu="Maxwell"
		elif use kepler; then
			gpu="Kepler"
		else
			die "No valid CUDA GPU selected. Set one of kepler, maxwell, pascal, turing, volta or ampere."
		fi
	elif use hip; then
#	if use hip ; then
		for u in ${IUSE_AMDGPU} ; do
			if use ${u} ; then
				gpu="${gpu},${u/amdgpu_/}"
			fi
		done
		# remove first character (,)
		gpu="${gpu:1}"
	fi

	local mycmakeargs=(
		-DBLA_VENDOR=${blasvendor}
		-DBUILD_SHARED_LIBS=ON
		-DGPU_TARGET=${gpu}
		-DMAGMA_ENABLE_CUDA=$(usex cuda)
		-DMAGMA_ENABLE_HIP=$(usex hip)
		-DUSE_FORTRAN=ON
#		-Dverbose=ON
	)

	#use fortran || mycmakeargs+=( "-DFORTRAN_CONVENTION=-DADD_"
	use hip && mycmakeargs+=( "-DCMAKE_CXX_COMPILER=hipcc" )

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	cmake_src_install

	insinto "/usr/include/${PN}"
	doins include/*.h

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${PN}.pc"

	local DOCS=( ReleaseNotes )
	use doc && local HTML_DOCS=( docs/html/. )
	einstalldocs
}

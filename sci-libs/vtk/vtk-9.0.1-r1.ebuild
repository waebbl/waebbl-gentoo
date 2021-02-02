# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# TODO:
# - add USE flag for remote modules? Those modules can be downloaded
#	properly before building.
# - fix cuda arch selection
#   meaningful arches: kepler maxwell pascal volta turing ampere
#	fermi omitted, as we don't have a cuda which is still supporting it

PYTHON_COMPAT=( python3_{7,8,9} )
WEBAPP_OPTIONAL=yes
WEBAPP_MANUAL_SLOT=yes

# qmake-utils
inherit check-reqs cmake cuda flag-o-matic java-pkg-opt-2 python-single-r1 toolchain-funcs virtualx webapp

# Short package version
SPV="$(ver_cut 1-2)"

# needed for testing
MISSING_TEST_FILES=(
	eaab2cdba68e8630f9a1f8a8e81cb097
	325acbb1a74ae27148d76399c2e7c7c5
	8e09d028a9fd114b4ceb8f924d8b466c
	7e7e6c5e28fa93b16fe0414881bdbbcd
)

DESCRIPTION="The Visualization Toolkit"
HOMEPAGE="https://www.vtk.org/"
SRC_URI="
	https://www.vtk.org/files/release/${SPV}/VTK-${PV}.tar.gz
	https://www.vtk.org/files/release/${SPV}/VTKData-${PV}.tar.gz
	doc? ( https://www.vtk.org/files/release/${SPV}/vtkDocHtml-${PV}.tar.gz )
	examples? ( https://www.vtk.org/files/release/${SPV}/VTKLargeData-${PV}.tar.gz )
	test? (
		https://www.vtk.org/files/ExternalData/MD5/eaab2cdba68e8630f9a1f8a8e81cb097
		https://www.vtk.org/files/ExternalData/MD5/325acbb1a74ae27148d76399c2e7c7c5
		https://www.vtk.org/files/ExternalData/MD5/8e09d028a9fd114b4ceb8f924d8b466c
		https://www.vtk.org/files/ExternalData/MD5/7e7e6c5e28fa93b16fe0414881bdbbcd
		https://www.vtk.org/files/release/${SPV}/VTKLargeData-${PV}.tar.gz
	)
"

LICENSE="BSD LGPL-2"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux" # ~arm
SLOT="0"
# New in 9.0?: sdl -> from which group / module is it coming?
# Note: external xdmf2 has no recognized targets
IUSE="+X all-modules boost cuda doc +eigen examples ffmpeg gdal imaging
	java +json kits mpi mysql odbc offscreen openmp pegtl postgres python
	qt5 +rendering tbb theora tk video_cards_nvidia views web"

# most tests don't work
RESTRICT="test"

REQUIRED_USE="
	all-modules? ( boost ffmpeg gdal mysql odbc postgres theora )
	cuda? ( X )
	python? ( ${PYTHON_REQUIRED_USE} )
	qt5? ( X rendering )
	tk? ( X rendering python )
	web? ( python )
"

RDEPEND="
	app-arch/lz4
	app-arch/xz-utils
	dev-db/sqlite
	dev-cpp/eigen[cuda?,openmp?]
	dev-libs/double-conversion:=
	dev-libs/expat
	dev-libs/icu:=
	dev-libs/libxml2:2
	dev-libs/pugixml
	dev-libs/utfcpp
	media-libs/libogg
	media-libs/libpng
	media-libs/libtheora
	media-libs/tiff
	sci-libs/hdf5:=[mpi=]
	sci-libs/netcdf:=[mpi=]
	sys-libs/zlib
	virtual/jpeg
	all-modules? ( sci-geosciences/liblas[gdal] )
	boost? ( dev-libs/boost:=[mpi?] )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	ffmpeg? ( media-video/ffmpeg:= )
	gdal? ( sci-libs/gdal:= )
	java? ( >=virtual/jdk-1.8:* )
	json? ( dev-libs/jsoncpp:= )
	mpi? (
		sci-libs/h5part
		sys-cluster/openmpi[cxx,romio]
		virtual/mpi[cxx,romio]
	)
	mysql? ( virtual/mysql )
	odbc? ( dev-db/unixODBC )
	offscreen? ( media-libs/mesa[osmesa] )
	pegtl? ( dev-libs/pegtl )
	postgres? ( dev-db/postgresql:= )
	python? ( ${PYTHON_DEPS} )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtsql:5
		dev-qt/qtwidgets:5
	)
	rendering? (
		media-libs/freeglut
		media-libs/glew:=
		sci-libs/proj:=
		virtual/opengl
		x11-libs/gl2ps
	)
	tbb? ( dev-cpp/tbb )
	tk? ( dev-lang/tk:= )
	video_cards_nvidia? ( x11-drivers/nvidia-drivers[tools,static-libs] )
	views? (
		x11-libs/libICE
		x11-libs/libXext
	)
	web? ( ${WEBAPP_DEPEND} )
	$(python_gen_cond_dep '
		python? (
			all-modules? ( dev-python/mpi4py[${PYTHON_MULTI_USEDEP}] )
			boost? ( dev-libs/boost:=[mpi?,python?,${PYTHON_MULTI_USEDEP}] )
			gdal? ( sci-libs/gdal:=[python?,${PYTHON_MULTI_USEDEP}] )
			mpi? ( dev-python/mpi4py[${PYTHON_MULTI_USEDEP}] )
		)
	')
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/jsoncpp:=
	dev-libs/pegtl
	mpi? ( app-admin/chrpath )
	openmp? (
		|| (
			sys-devel/gcc[openmp(+)]
			sys-devel/clang-runtime[openmp(+)]
		)
	)
"

PATCHES=(
	"${FILESDIR}"/${P}-0001-fix-kepler-compute_arch-if-CUDA-toolkit-11-is-used.patch
	"${FILESDIR}"/${P}-0002-use-cmake-internal-auto-search-for-cuda-devices.patch
)

S="${WORKDIR}"/VTK-${PV}

DOCS=( CONTRIBUTING.md README.md )

pkg_pretend() {
	if use cuda; then
		# NOTE: This should actually equal to (number of build jobs)*7G,
		# as any of the cuda compile tasks can take up 7G!
		# 10.2 GiB install directory, 6.4 GiB build directory with max. USE flags
		CHECKREQS_MEMORY="7G"
		CHECKREQS_DISK_BUILD="17G"
		check-reqs_pkg_setup
	fi
}

pkg_setup() {
	if use cuda; then
		CHECKREQS_MEMORY="7G"
		CHECKREQS_DISK_BUILD="17G"
		check-reqs_pkg_setup
	fi
	use java && java-pkg-opt-2_pkg_setup
	use python && python-single-r1_pkg_setup
	use web && webapp_pkg_setup
}

src_unpack() {
	default

	if use test; then
		ebegin "Copying extra test datafiles"
		mkdir -p "${S}/.ExternalData/MD5" || die
		for i in ${MISSING_TEST_FILES[@]}; do
			cp -i "${DISTDIR}/${i}" "${S}/.ExternalData/MD5" || die
		done
		unset i
		eend "$?"
	fi
}

src_prepare() {
	# all modules listed in ThirdParty based on 9.0.1 branch
	# diy2 doubleconversion eigen exodusII expat freetype gl2ps glew
	# h5part hdf5 jpeg jsoncpp kissfft libharu libproj libxml2 loguru
	# lz4 lzma mpi4py netcdf ogg pegtl png pugixml sqlite theora tiff
	# utf8 verdict vpic vtkm xdmf2 xdmf3 zfp zlib

	# If we have system libraries available use these and delete
	# the respecting files in ${S}/ThirdParty to save some space.
	# Note: freetype is omitted: vtk doesn't build with freetype-2.10.4
	# Note: libharu is omitted: vtk needs an updated version (2.4.0)
	# Note: no valid xdmf2 targets are found for system xdmf2
	# ToDo: diy2 exodusII freetype h5part kissfft libharu verdict vpic
	#	vtkm xdmf2 xdmf3 zfp
	local -a DROPS=( doubleconversion eigen expat gl2ps glew hdf5 jpeg
		jsoncpp libproj libxml2 lz4 lzma netcdf ogg png pugixml sqlite
		theora tiff utf8 zlib )
#	use mpi && DROPS+=( h5part mpi4py )
	use pegtl && DROPS+=( pegtl )
#	use xdmf2 && DROPS+=( xdmf2 )

	local x
	for x in ${DROPS[@]}; do
		ebegin "Dropping bundled ${x}"
		rm -r ThirdParty/${x}/vtk${x} || die
		eend $?
	done
	unset x

	if use doc; then
		einfo "Removing .md5 files from documents."
		rm -f "${WORKDIR}"/html/*.md5 || die "Failed to remove superfluous hashes"
		sed -e "s|\${VTK_BINARY_DIR}/Utilities/Doxygen/doc|${WORKDIR}|" \
			-i Utilities/Doxygen/CMakeLists.txt || die
	fi

	cmake_src_prepare

	if use cuda; then
		cuda_add_sandbox -w
		cuda_src_prepare
	fi

	if use test; then
		ebegin "Copying data files to ${BUILD_DIR}"
		mkdir -p "${BUILD_DIR}/ExternalData" || die
		pushd "${BUILD_DIR}/ExternalData" >/dev/null || die
		ln -sf "../../VTK-${PV}/.ExternalData/README.rst" . || die
		ln -sf "../../VTK-${PV}/.ExternalData/SHA512" . || die
		ln -sf "../../VTK-${PV}/.ExternalData/MD5" . || die
		popd >/dev/null || die
		eend "$?"
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON

# defaults for some variables to consider
#		-DVTK_ANDROID_BUILD=OFF
#		-DVTK_BUILD_COMPILE_TOOLS_ONLY=OFF
#		-DVTK_ENABLE_LOGGING=ON
#		-DVTK_ENABLE_REMOTE_MODULES=ON
#		-DVTK_INSTALL_SDK=ON
#		-DVTK_IOS_BUILD=OFF
#		-DVTK_LEGACY_REMOVE=OFF
#		-DVTK_LEGACY_SILENT=OFF
#		-DVTK_WHEEL_BUILD=OFF

		-DVTK_BUILD_ALL_MODULES=$(usex all-modules ON OFF)
		# we use the pre-built documentation and install these with USE=doc
		-DVTK_BUILD_DOCUMENTATION=OFF
		# FIXME: need to unmask examples first
#		-DVTK_BUILD_EXAMPLES=$(usex examples ON OFF)
		-DVTK_BUILD_EXAMPLES=ON

		-DVTK_ENABLE_KITS=$(usex kits ON OFF)
		# default to ON: USE flag for this?
		-DVTK_ENABLE_REMOTE_MODULES=OFF

		-DVTK_DATA_STORE="${S}/.ExternalData"

		# Use upstream default, where USE flags are not given.
		# Passing "DONT_WANT" will restrict building of modules from
		# those groups and will severly limit the built libraries.
		# Exceptions are MPI, where the default is "DONT_WANT" and
		# StandAlone using "WANT".
		-DVTK_GROUP_ENABLE_Imaging=$(usex imaging "WANT" "DEFAULT")
		-DVTK_GROUP_ENABLE_Qt=$(usex qt5 "WANT" "DEFAULT")
		-DVTK_GROUP_ENABLE_Rendering=$(usex rendering "WANT" "DEFAULT")
		-DVTK_GROUP_ENABLE_StandAlone="WANT"
		-DVTK_GROUP_ENABLE_Views=$(usex views "WANT" "DEFAULT")
		-DVTK_GROUP_ENABLE_Web=$(usex web "WANT" "DEFAULT")

		-DVTK_MODULE_ENABLE_VTK_vtkm="WANT"
		-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKm="WANT"

		# fails to build with external freetype
		-DVTK_MODULE_USE_EXTERNAL_VTK_freetype=OFF

		-DVTK_PYTHON_VERSION="3"
		-DVTK_RELOCATABLE_INSTALL=ON

		-DVTK_USE_CUDA=$(usex cuda ON OFF) # Fixme
		# use system libraries where possible
		-DVTK_USE_EXTERNAL=ON
		-DVTK_USE_LARGE_DATA=ON	# Fixme
		-DVTK_USE_MPI=$(usex mpi ON OFF)
		-DVTK_USE_TK=$(usex tk ON OFF)
		-DVTK_USE_X=$(usex X ON OFF)

		-DVTK_VERSIONED_INSTALL=ON

		-DVTK_WRAP_JAVA=$(usex java ON OFF)
		-DVTK_WRAP_PYTHON=$(usex python ON OFF)
	)

	# FIXME: fist unmask examples USE flag
	if use examples || use test; then
		mycmakeargs+=( -DVTK_USE_LARGE_DATA=ON )
	fi

	if ! use java && ! use python; then
		# defaults to ON
		mycmakeargs+=( -DVTK_ENABLE_WRAPPING=OFF )
	fi

	if use boost; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_InfovisBoost="WANT"
			-DVTK_MODULE_ENABLE_VTK_InfovisBoostGraphAlgorithms="WANT"
		)
	fi

	if use cuda; then
		mycmakeargs+=( -DVTKm_CUDA_Architecture="native" )
	fi

	if use ffmpeg; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOFFMPEG="WANT" )
	fi

	if use gdal; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_GeovisGDAL="WANT" )
	fi

	if use java; then
		mycmakeargs+=(
			-DCMAKE_INSTALL_JARDIR="share/${PN}"
			-DVTK_ENABLE_WRAPPING=ON
		)
	fi

	if use json; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOGeoJSON="WANT" )
	fi

	if use mpi; then
		mycmakeargs+=(
			-DVTK_GROUP_ENABLE_MPI="WANT"
			-DVTK_MODULE_ENABLE_VTK_IOH5part="WANT"
			-DVTK_MODULE_ENABLE_VTK_IOParallel="WANT"
			-DVTK_MODULE_ENABLE_VTK_IOParallelNetCDF="WANT"
			-DVTK_MODULE_ENABLE_VTK_IOParallelXML="WANT"
			-DVTK_MODULE_ENABLE_VTK_ParallelMPI="WANT"
			-DVTK_MODULE_ENABLE_VTK_RenderingParallel="WANT"
			-DVTK_MODULE_ENABLE_VTK_h5part="WANT"
			-DVTKm_ENABLE_MPI=ON
		)
		if use python; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_ParallelMPI4Py="WANT" )
		fi
	fi

	if use mysql; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_IOMySQL="WANT"
			-DVTK_MODULE_ENABLE_VTK_IOSQL="WANT"
		)
	fi

	if use odbc; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOODBC="WANT" )
	fi

	if use offscreen; then
		mycmakeargs+=(
			-DVTK_OPENGL_HAS_OSMESA=ON
			-DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=ON
		)
	fi

	if use openmp; then
		mycmakeargs+=(
			-DVTK_SMP_IMPLEMENTATION_TYPE="OpenMP"
			-DVTKm_ENABLE_OPENMP=ON
		)
	fi

	if use pegtl; then
		mycmakeargs+=( -DVTK_MODULE_USE_EXTERNAL_VTK_pegtl=ON )
	else
		mycmakeargs+=( -DVTK_MODULE_USE_EXTERNAL_VTK_pegtl=OFF )
	fi

	if use postgres; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_IOPostgreSQL="WANT"
			-DVTK_MODULE_ENABLE_VTK_IOSQL="WANT"
		)
	fi

	if use python; then
		mycmakeargs+=(
			-DVTK_ENABLE_WRAPPING=ON
			-DPython3_EXECUTABLE="${PYTHON}"
			-DVTK_PYTHON_SITE_PACKAGES_SUFFIX="lib/${EPYTHON}/site-packages"
		)
	fi

	if use qt5; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_GUISupportQt="WANT" )
		if use mysql || use postgres; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL="WANT" )
		fi
		if use rendering; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingQt="WANT" )
		fi
		if use views; then
			mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_ViewsQt="WANT" )
		fi
	fi

	if use rendering || use web || use all-modules; then
		# needs patched version
		mycmakeargs+=( -DVTK_MODULE_USE_EXTERNAL_VTK_libharu=OFF )
	fi

	if use rendering; then
		mycmakeargs+=(
			-DVTK_MODULE_ENABLE_VTK_IOExportGL2PS="WANT"
			-DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps=ON
			-DVTK_MODULE_USE_EXTERNAL_VTK_glew=ON
			-DVTK_MODULE_USE_EXTERNAL_VTK_libproj=ON
		)
	fi

	if use tbb; then
		mycmakeargs+=(
			-DVTK_SMP_IMPLEMENTATION_TYPE="TBB"
			-DVTKm_ENABLE_TBB=ON
		)
	fi

	if use test; then
		ewarn "Testing requires VTK_FORBID_DOWNLOADS=OFF by upstream."
		ewarn "Care has been taken to pre-download all required files."
		ewarn "In case you find missing files, please inform me."
		mycmakeargs+=(
			-DVTK_BUILD_TESTING=ON
			-DVTK_DATA_EXCLUDE_FROM_ALL=OFF
			-DVTK_FORBID_DOWNLOADS=OFF
		)
	else
		mycmakeargs+=(
			-DVTK_BUILD_TESTING=OFF
			-DVTK_FORBID_DOWNLOADS=ON
		)
	fi

	if use theora; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_IOOggTheora="WANT" )
	fi

	if use all-modules; then
		mycmakeargs+=(
			-DVTK_ENABLE_OSPRAY=OFF
			-DVTK_MODULE_ENABLE_VTK_DomainsMicroscopy="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_FiltersOpenTURNS="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_IOADIOS2="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_IOPDAL="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_MomentInvariants="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_PoissonReconstruction="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_Powercrust="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_RenderingOpenVR="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_SignedTensor="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_SplineDrivenImageSlicer="DONT_WANT"
			-DVTK_MODULE_ENABLE_VTK_vtkDICOM="DONT_WANT"
		)
	fi

	use java && export JAVA_HOME="${EPREFIX}/etc/java-config-2/current-system-vm"

	if use mpi; then
		export CC=mpicc
		export CXX=mpicxx
		export FC=mpif90
		export F90=mpif90
		export F77=mpif77
	fi

	cmake_src_configure
}

src_test() {
	nonfatal virtx cmake_src_test
}

src_install() {
	use web && webapp_src_preinst

	# Stop web page images from being compressed
	if use doc; then
#		docompress -x /usr/share/doc/${PF}/doxygen
		HTML_DOCS=( "${WORKDIR}/html/." )
	fi

	cmake_src_install

	use java && java-pkg_regjar "${ED}"/usr/$(get_libdir)/java/${PN}.jar

	# install examples
	if use examples; then
		einfo "Installing examples"
		mv -v {E,e}xamples || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples

		einfo "Installing datafiles"
		insinto /usr/share/${PN}/data
		doins -r "${S}/.ExternalData"
	fi

	# with MPI runpath's are not deleted properly
	if use mpi; then
		chrpath -d "${ED}"/usr/$(get_libdir)/*.so.${PV} || die
	fi

	use python && python_optimize

	# environment
	cat >> "${T}"/40${PN} <<- EOF || die
		VTK_DATA_ROOT=${EPREFIX}/usr/share/${PN}/data
		VTK_DIR=${EPREFIX}/usr/$(get_libdir)/${PN}
		VTKHOME=${EPREFIX}/usr
		EOF
	doenvd "${T}"/40${PN}

	use web && webapp_src_install
}

# webapp.eclass exports these but we want it optional #534036
pkg_postinst() {
	use web && webapp_pkg_postinst

	if use examples; then
		einfo "You can get more and updated examples at"
		einfo "https://kitware.github.io/vtk-examples/site/"
	fi
}

pkg_prerm() {
	use web && webapp_pkg_prerm
}

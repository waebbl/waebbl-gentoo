# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# inherit lists eclasses to inherit functions from. Almost all ebuilds should
# inherit eutils, as a large amount of important functionality has been
# moved there. For example, the epatch call mentioned below wont work
# without the following line:
inherit eutils cmake-utils

MY_PV=${PV/./_}

DESCRIPTION="Open Subdivision Surface library"

HOMEPAGE="https://github.com/PixarAnimationStudios/OpenSubdiv/"

SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="OpenSubDiv"

SLOT="0"

KEYWORDS="~amd64"

IUSE="cuda doc examples +glew +glfw +opencl +opengl openmp ptex tbb"

CMAKE_MIN_VERSION="2.8.6"

RDEPEND="glew? ( >=media-libs/glew-1.9.0 )
		 cuda? ( >=dev-util/nvidia-cuda-toolkit-6.5.14
				 >=dev-util/nvidia-cuda-sdk-6.5.14 )
		 tbb? ( >=dev-cpp/tbb-4.3.20150611 )
		 opencl? ( virtual/opencl )
		 glfw? ( >=media-libs/glfw-3.1.1 )
		 ptex? ( >=media-libs/ptex-2.1.10
				 >=sys-libs/zlib-1.2.8-r1 )
		 sys-devel/gcc:4.9[openmp?]
		 opengl? ( virtual/opengl )"

DEPEND="${RDEPEND}
		doc? ( >=dev-python/docutils-0.12
			   >=dev-python/pygments-2.0.2-r2
			   >=app-doc/doxygen-1.8.10-r1 )"

S="${WORKDIR}"/OpenSubdiv-3_0_3

src_prepare() {
	epatch "${FILESDIR}"/osd-3.0.3_ptex.patch
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_no examples NO_EXAMPLES)
		$(cmake-utils_use opencl NO_CLEW)
		$(cmake-utils_use_no opencl NO_OPENCL)
		$(cmake-utils_use_no opengl NO_OPENGL)
		$(cmake-utils_use_no ptex NO_PTEX)
		$(cmake-utils_use_no tbb NO_TBB)
		$(cmake-utils_use_no doc NO_DOC)
		$(cmake-utils_use_no doc NO_TUTORIAL)
		-DNO_DX=1
		-DNO_MAYA=1
		-DNO_TESTS=1
	)
	cmake-utils_src_configure
}

# The following src_compile function is implemented as default by portage, so
# you only need to call it, if you need different behaviour.
# For EAPI < 2 src_compile runs also commands currently present in
# src_configure. Thus, if you're using an older EAPI, you need to copy them
# to your src_compile and drop the src_configure function.
#src_compile() {
	# emake (previously known as pmake) is a script that calls the
	# standard GNU make with parallel building options for speedier
	# builds (especially on SMP systems).  Try emake first.  It might
	# not work for some packages, because some makefiles have bugs
	# related to parallelism, in these cases, use emake -j1 to limit
	# make to a single process.  The -j1 is a visual clue to others
	# that the makefiles have bugs that have been worked around.

	#emake
#}

# The following src_install function is implemented as default by portage, so
# you only need to call it, if you need different behaviour.
# For EAPI < 4 src_install is just returing true, so you need to always specify
# this function in older EAPIs.
#src_install() {
	# You must *personally verify* that this trick doesn't install
	# anything outside of DESTDIR; do this by reading and
	# understanding the install part of the Makefiles.
	# This is the preferred way to install.
	#emake DESTDIR="${D}" install

	# When you hit a failure with emake, do not just use make. It is
	# better to fix the Makefiles to allow proper parallelization.
	# If you fail with that, use "emake -j1", it's still better than make.

	# For Makefiles that don't make proper use of DESTDIR, setting
	# prefix is often an alternative.  However if you do this, then
	# you also need to specify mandir and infodir, since they were
	# passed to ./configure as absolute paths (overriding the prefix
	# setting).
	#emake \
	#	prefix="${D}"/usr \
	#	mandir="${D}"/usr/share/man \
	#	infodir="${D}"/usr/share/info \
	#	libdir="${D}"/usr/$(get_libdir) \
	#	install
	# Again, verify the Makefiles!  We don't want anything falling
	# outside of ${D}.

	# The portage shortcut to the above command is simply:
	#
	#einstall
#}

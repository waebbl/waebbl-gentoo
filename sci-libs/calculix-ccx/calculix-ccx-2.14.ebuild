# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic fortran-2 toolchain-funcs

MY_P=ccx_${PV/_/}

DESCRIPTION="A Three-Dimensional Structural Finite Element Program (Solver)"
HOMEPAGE="http://www.calculix.de/"
SRC_URI="
	http://www.dhondt.de/${MY_P}.src.tar.bz2
	doc? ( http://www.dhondt.de/${MY_P}.htm.tar.bz2 )
	examples? ( http://www.dhondt.de/${MY_P}.test.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="arpack doc examples openmp taucs threads"

RDEPEND="
	>=sci-libs/spooles-2.2:=[threads=]
	virtual/blas
	virtual/lapack
	arpack? ( >=sci-libs/arpack-3.1.3:= )
	taucs? (
		>=sci-libs/taucs-2.2:=[cilk(+)]
		|| ( sci-libs/parmetis[openmp=] sci-libs/metis[openmp=] )
	)
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/CalculiX/${MY_P}/src

PATCHES=(
	"${FILESDIR}/${P}_Makefile-custom-flags.patch"
)

DOCS=( BUGS LOGBOOK README.INSTALL TODO )

pkg_setup() {
	use openmp && tc-check-openmp
}

src_configure() {
	# Technically we currently only need this when arpack is not used.
	# Keeping things this way in case we change pkgconfig for arpack
	export LAPACK=$($(tc-getPKG_CONFIG) --libs lapack)

	append-cflags "-I/usr/include/spooles -DSPOOLES"
	if use threads; then
		append-cflags "-DUSE_MT"
	fi

	if use openmp; then
		append-fflags "-fopenmp"
		append-cflags "-fopenmp"
	fi

	if use arpack; then
		export ARPACKLIB=$($(tc-getPKG_CONFIG) --libs arpack)
		append-cflags "-DARPACK"
	fi

	if use taucs; then
		export TAUCSLIB="-ltaucs -lrefblas -lreflapack -lmetis"
		append-cflags "-DTAUCS"
	fi

	export CC="$(tc-getCC)"
	export FC="$(tc-getFC)"
}

src_install () {
	dobin ${MY_P}
	dosym ${MY_P} /usr/bin/ccx

	if use doc; then
		local HTML_DOCS=( "${S}"/../doc/ccx/. )
		einstalldocs
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/../test/*
	fi

	if use openmp && use threads; then
		insinto /etc/env.d
		doins "${FILESDIR}"/99${PF}
	fi
}

pkg_postinst() {
	if use openmp && use threads; then
		einfo "An environment file has been installed into"
		einfo "/etc/env.d/99calculix-ccx-2.14."
		einfo "Refer to the documentation for details on how to"
		einfo "tweak the variables defined in this file."
	fi
}

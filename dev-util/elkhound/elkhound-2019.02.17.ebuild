# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_PV=${PV//./-}

DESCRIPTION="Elkhound is a GLR parser generator"
HOMEPAGE="http://scottmcpeak.com/elkhound"
SRC_URI="https://github.com/WeiDUorg/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc test"
RESTRICT="!test? ( test )"

RDEPEND=">=dev-lang/ocaml-4.04.2-r1[ocamlopt]"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/bison
	sys-devel/flex
	doc? ( >=media-gfx/graphviz-2.38.0-r1[svg] )
"

S="${WORKDIR}/${PN}-${MY_PV}/src"

src_prepare() {
	sed -e 's|CMAKE_C_FLAGS \"-g3|CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS}|' \
		-e 's|CMAKE_CXX_FLAGS \"-g3|CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS}|' \
		-i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		# don't build extra parser (ON by default)
		-DEXTRAS=OFF
		# don't build ocaml example (ON by default)
		-DOCAML=OFF
	)

	cmake_src_configure
}

src_install() {
	# elkhound Makefile has no install target
	dobin "${BUILD_DIR}"/elkhound/elkhound
	dobin "${BUILD_DIR}"/ast/astgen
	dolib.a "${BUILD_DIR}"/smbase/libsmbase.a
	dolib.a "${BUILD_DIR}"/ast/libast.a
	dolib.a "${BUILD_DIR}"/elkhound/libelkhound.a

	# Note: Header files are just all installed. The original code does not
	# clearly making a difference between internal and exported header files.
	SMBASE_HEADERS=( array.h astlist.h autofile.h bflatten.h bit2d.h bitarray.h
		breaker.h ckheap.h crc.h cycles.h datablok.h exc.h flatten.h gprintf.h
		growbuf.h hashline.h hashtbl.h macros.h mysig.h nonport.h objlist.h
		objpool.h objstack.h ohashtbl.h okhasharr.h okhashtbl.h owner.h point.h
		ptrmap.h sm_flexlexer.h sobjlist.h sobjset.h sobjstack.h srcloc.h str.h
		strdict.h strhash.h stringset.h strobjdict.h strsobjdict.h strtokp.h
		strutil.h svdict.h syserr.h taillist.h test.h trace.h trdelete.h typ.h
		vdtllist.h voidlist.h vptrmap.h xassert.h xobjlist.h )
	insinto /usr/include/smbase
	for i in ${SMBASE_HEADERS[@]}; do
		doins "${S}"/smbase/${i}
	done

	AST_HEADERS=( agrampar.h ast.ast.h ast.hand.h asthelp.h ccsstr.h embedded.h
		fakelist.h fileloc.h gramlex.h locstr.h reporterr.h strtable.h xmlhelp.h )
	insinto /usr/include/ast
	for i in ${AST_HEADERS[@]}; do
		doins "${S}"/ast/${i}
	done

	ELKHOUND_HEADERS=( asockind.h cyctimer.h emitcode.h flatutil.h genml.h glr.h
		glrconfig.h gramanl.h grammar.h grampar.h lexerint.h mlsstr.h ownerspec.h
		parsetables.h ptreeact.h ptreenode.h rcptr.h ssxnode.h trivbison.h trivlex.h
		useract.h util.h )
	insinto /usr/include/elkhound
	for i in ${ELKHOUND_HEADERS[@]}; do
		doins "${S}"/elkhound/${i}
	done

	dodoc "${WORKDIR}"/${PN}-${MY_PV}/README.md

	if use doc; then
		local DOCS_SMBASE=( string.txt )
		docinto smbase
		for i in ${DOCS_SMBASE[@]}; do
			dodoc "${S}"/smbase/${i}
		done

		local HTML_DOCS_SMBASE=( index.html trace.html )
		docinto smbase/html
		for i in ${HTML_DOCS_SMBASE[@]}; do
			dodoc "${S}"/smbase/${i}
		done

		local DOCS_AST=( readme.txt )
		docinto ast
		for i in ${DOCS_AST[@]}; do
			dodoc "${S}"/ast/${i}
		done

		local HTML_DOCS_AST=( index.html manual.html )
		docinto ast/html
		for i in ${HTML_DOCS_AST[@]}; do
			dodoc "${S}"/ast/${i}
		done

		local DOCS_ELKHOUND=( grammar.txt parsgen.txt readme.txt )
		docinto elkhound
		for i in ${DOCS_ELKHOUND[@]}; do
			dodoc "${S}"/elkhound/${i}
		done

		local HTML_DOCS_ELKHOUND=( algorithm.html faq.html index.html manual.html tutorial.html )
		docinto elkhound/html
		for i in ${HTML_DOCS_ELKHOUND[@]}; do
			dodoc "${S}"/elkhound/${i}
		done
	fi
}

# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Elkhound is a GLR parser generator"
HOMEPAGE="http://scottmcpeak.com/elkhound"
SRC_URI=""
EGIT_REPO_URI="https://github.com/WeiDUorg/elkhound.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc"

DEPEND=">=dev-lang/perl-5.24.3
	sys-devel/flex
	virtual/yacc
	doc? ( >=media-gfx/graphviz-2.38.0-r1[svg] )"
RDEPEND=""

PATCHES=( "${FILESDIR}"/elkhound-ast-gramlex-fix-FLEX_STD.patch
	"${FILESDIR}"/elkhound-Makefile.in.patch )

DOCS=( src/elkhound/gendoc/elkhound_dep.svg src/elkhound/gendoc/glr.svg )
HTML_DOCS=( src/elkhound/algorithm.html src/elkhound/faq.html
	src/elkhound/index.html src/elkhound/manual.html
	src/elkhound/tutorial.html )

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	# elkhound does not use GNU autoconf, but a perl configure script
	pushd "${S}"/src
	./configure
	popd
}

src_compile() {
	einfo "Compiling static library smbase"
	pushd "${S}"/src/smbase
	emake
	popd

	einfo "Compiling AST programs"
	pushd "${S}"/src/ast
	emake
	popd

	einfo "Compiling elkhound"
	pushd "${S}"/src/elkhound
	emake elkhound libelkhound.a
	if use doc; then
		emake doc
	fi
	popd
}

src_install() {
	# elkhound Makefile has no install target
	exeinto /usr/bin
	doexe "${S}"/src/elkhound/elkhound
	doexe "${S}"/src/ast/astgen
	dolib.a "${S}"/src/smbase/libsmbase.a
	dolib.a "${S}"/src/ast/libast.a
	dolib.a "${S}"/src/elkhound/libelkhound.a

	# Note: Header files are just all installed. The original code does not
	# clearly making a difference between internal and exported header files.
	SMBASE_HEADERS=( array.h arraymap.h arrayqueue.h astlist.h autofile.h bflatten.h
		bit2d.h bitarray.h boxprint.h breaker.h ckheap.h crc.h cycles.h datablok.h
		exc.h flatten.h gprintf.h growbuf.h hashline.h hashtbl.h macros.h missing.h
		mypopen.h mysig.h nonport.h objlist.h objmap.h objpool.h objstack.h
		ohashtbl.h okhasharr.h okhashtbl.h oobjmap.h owner.h pair.h point.h pprint.h
		ptrmap.h sm_flexlexer.h smregexp.h sobjlist.h sobjset.h sobjstack.h srcloc.h
		str.h strdict.h strhash.h stringset.h strobjdict.h strsobjdict.h strtokp.h
		strutil.h svdict.h syserr.h taillist.h test.h thashtbl.h trace.h trdelete.h
		typ.h unixutil.h vdtllist.h voidlist.h vptrmap.h warn.h xassert.h xobjlist.h )
	insinto /usr/include/smbase
	for i in ${SMBASE_HEADERS[@]}; do
		doins "${S}"/src/smbase/${i}
	done

	AST_HEADERS=( agrampar.h ast.ast.h ast.hand.h asthelp.h ccsstr.h embedded.h
		fakelist.h fileloc.h gramlex.h locstr.h reporterr.h strtable.h xmlhelp.h )
	insinto /usr/include/ast
	for i in ${AST_HEADERS[@]}; do
		doins "${S}"/src/ast/${i}
	done

	ELKHOUND_HEADERS=( asockind.h cyctimer.h emitcode.h flatutil.h genml.h glr.h
		glrconfig.h gramanl.h gramast.h grammar.h grampar.h lexerint.h mlsstr.h
		ownerspec.h parsetables.h ptreeact.h ptreenode.h rcptr.h ssxnode.h useract.h
		util.h )
	insinto /usr/include/elkhound
	for i in ${ELKHOUND_HEADERS[@]}; do
		doins "${S}"/src/elkhound/${i}
	done

	if use doc; then
		docompress -x /usr/share/doc/${P}
		einstalldocs
	fi
}

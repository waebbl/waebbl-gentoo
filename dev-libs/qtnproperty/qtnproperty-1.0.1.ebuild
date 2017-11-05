# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils vcs-snapshot

DESCRIPTION="Tool to extend properties in the Qt5 framework."
HOMEPAGE="https://github.com/lexxmark/QtnProperty/wiki"
SRC_URI="https://github.com/lexxmark/QtnProperty/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="demo doc test"

#RESTRICT="test"

DEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtscript:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	sys-devel/flex
	sys-devel/bison
	virtual/opengl
	doc? ( app-doc/doxygen )"

RDEPEND="dev-qt/qtcore:5
	demo? ( dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtscript:5
		virtual/opengl )"

PATCHES=( "${FILESDIR}/${PN}_fix-Doxyfile.patch" )
DOCS=( AUTHORS README.md TODO )

src_prepare() {
	default
	eqmake5 Property.pro
	if use doc; then
		doxygen -u "${S}"/Docs/Doxyfile
	fi
}

src_compile() {
	emake || die
	if use doc; then
		( cd Docs && doxygen )
	fi
}

src_test() {
	"${S}"/bin/QtnPropertyTests
}

src_install() {
	emake DESTDIR="${D}" install || die
	exeinto /usr/bin
	doexe "${S}"/bin/QtnPEG

	if use demo; then
		exeinto /usr/share/QtnProperty
		doexe "${S}"/bin/QtnPropertyDemo
	fi

	if use test; then
		exeinto /usr/share/QtnProperty
		doexe "${S}"/bin/QtnPropertyTests
	fi

	dolib.so "${S}"/bin/libQtnPropertyCore.so.1.0.0
	dosym libQtnPropertyCore.so.1.0.0 /usr/$(get_libdir)/libQtnPropertyCore.so.1.0
	dosym libQtnPropertyCore.so.1.0 /usr/$(get_libdir)/libQtnPropertyCore.so.1
	dosym libQtnPropertyCore.so.1 /usr/$(get_libdir)/libQtnPropertyCore.so

	dolib.so "${S}"/bin/libQtnPropertyWidget.so.1.0.0
	dosym libQtnPropertyWidget.so.1.0.0 /usr/$(get_libdir)/libQtnPropertyWidget.so.1.0
	dosym libQtnPropertyWidget.so.1.0 /usr/$(get_libdir)/libQtnPropertyWidget.so.1
	dosym libQtnPropertyWidget.so.1 /usr/$(get_libdir)/libQtnPropertyWidget.so

	if use doc; then
		HTML_DOCS=( Docs/html/* )
	fi
	einstalldocs
}

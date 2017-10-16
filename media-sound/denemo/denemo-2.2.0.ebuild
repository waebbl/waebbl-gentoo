# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit xdg-utils

DESCRIPTION="A music notation editor"
HOMEPAGE="http://www.denemo.org/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# Features currently not used:
# --enable-debug(no) debug support
# --enable-mem(no) memory debugging
# --enable-gcov(no) coverage testing
# --enable-gtk-doc-pdf(no) doesn't work
IUSE="alsa +aubio +evince doc jack +fluidsynth gtk3 guile2 nls +portaudio \
	+portmidi +rubberband test"

RDEPEND="guile2? ( >=dev-scheme/guile-2:12
		>=media-sound/lilypond-2.19.54[guile2=] )
	!guile2? ( >=dev-scheme/guile-1.8:12
		<dev-scheme/guile-2:12
		>=media-sound/lilypond-2.18.2-r3[-guile2] )
	dev-libs/libxml2:2
	gnome-base/librsvg:2
	media-libs/fontconfig:1.0
	>=media-libs/libsndfile-1.0.28-r1
	>=media-libs/libsmf-1.3
	jack? ( virtual/jack )
	evince? ( >=app-text/evince-3.22.1-r1 )
	aubio? ( >=media-libs/aubio-0.4.1-r1 )
	gtk3? ( x11-libs/gtk+:3
		x11-libs/gtksourceview:3.0 )
	!gtk3? ( x11-libs/gtk+:2
		x11-libs/gtksourceview:2.0 )
	alsa? ( >=media-libs/alsa-lib-1.1.2 )
	fluidsynth? ( >=media-sound/fluidsynth-1.1.6-r1 )
	rubberband? ( >=media-libs/rubberband-1.8.1-r1 )
	portaudio? (
		>=media-libs/portaudio-19_pre20140130
		sci-libs/fftw:3.0
	)
	portmidi? ( >=media-libs/portmidi-217-r1 )
	doc? ( >=dev-util/gtk-doc-1.25-r1 )"

DEPEND="${RDEPEND}
	>=sys-devel/flex-2.6.1
	>=dev-util/intltool-0.51.0-r1
	virtual/pkgconfig
	virtual/yacc
	nls? ( >=sys-devel/gettext-0.19.8.1 )"

DOCS=( AUTHORS ChangeLog docs/{DESIGN{,.lilypond},GOALS,TODO} NEWS )
HTML_DOCS=( docs/denemo-manual.html docs/denemo.css )

# --enable-doc does nothing for itself
src_configure() {
	if use doc; then
		EXTRA_ECONF="\
			--enable-doc \
			--enable-gtk-doc \
			--enable-gtk-doc-html \
			--disable-gtk-doc-pdf"
	else
		EXTRA_ECONF="\
			--disable-doc \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf"
	fi
	econf \
		--disable-static \
		$(usex gtk3 --enable-gtk3 --enable-gtk2) \
		$(use_enable alsa) \
		$(use_enable aubio) \
		$(use_enable evince) \
		$(use_enable fluidsynth) \
		$(usex guile2 --enable-guile_2_0 --enable-guile_1_8) \
		$(use_enable jack) \
		$(use_enable nls) \
		$(use_enable portaudio) \
		$(use_enable portmidi) \
		$(use_enable rubberband) \
		--enable-x11 \
		--disable-mem \
		$(use_enable test always-build-tests) \
		--disable-installed-tests \
		--disable-gcov
}

pkg_postinst() { xdg_desktop_database_update; }
pkg_postrm() { xdg_desktop_database_update; }

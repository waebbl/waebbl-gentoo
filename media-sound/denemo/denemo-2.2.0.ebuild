# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils xdg-utils

DESCRIPTION="A music notation editor"
HOMEPAGE="http://www.denemo.org/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# Features currently not used:
# --enable-gtk2(no) I'm going for gtk3 support only for now
# --enable-guile_2_0(no) support for guile-2.0
# --enable-debug(no) debug support
# --enable-mem(no) memory debugging
# --enable-doc(no) build documentation
# --enable-gtk-doc(no) use gtk-doc to build documentation
# --enable-gtk-doc-html(yes) build documentation in html format
# --enable-gtk-doc-pdf(no) build documentation in pdf format
# --enable-installed-tests(no) install some test cases
# --enable-alway-build-tests(no) run test suite
# --enable-gcov(no) coverage testing
IUSE="alsa +aubio +evince jack +fluidsynth guile nls +portaudio +portmidi +rubberband"

COMMON_DEPEND="
	guile? ( >=dev-scheme/guile-1.8:12 )
	dev-libs/glib:2
	dev-libs/libxml2:2
	gnome-base/librsvg:2
	media-libs/fontconfig:1.0
	>=media-libs/libsndfile-1.0.28-r1
	>=media-libs/libsmf-1.3
	jack? ( >=media-sound/jack-audio-connection-kit-0.121.3-r1 )
	evince? ( >=app-text/evince-3.22.1-r1 )
	aubio? ( >=media-libs/aubio-0.4.1-r1 )
	x11-libs/gtk+:3
	x11-libs/gtksourceview:3.0
	alsa? ( >=media-libs/alsa-lib-1.1.2 )
	fluidsynth? ( >=media-sound/fluidsynth-1.1.6-r1 )
	rubberband? ( >=media-libs/rubberband-1.8.1-r1 )
	portaudio? (
		>=media-libs/portaudio-19_pre20140130
		sci-libs/fftw:3.0
	)
	portmidi? ( >=media-libs/portmidi-217-r1 )
	"
RDEPEND="${COMMON_DEPEND}
	>=media-sound/lilypond-2.18.2-r3"
DEPEND="${COMMON_DEPEND}
	>=sys-devel/flex-2.6.1
	>=dev-util/intltool-0.51.0-r1
	virtual/pkgconfig
	virtual/yacc
	nls? ( >=sys-devel/gettext-0.19.8.1 )"

DOCS=( AUTHORS ChangeLog docs/{DESIGN{,.lilypond},GOALS,TODO} NEWS )

src_prepare() {
	default_src_prepare
	sed -i 's/^\(Categories.*[^;]\)$/\1;/g' pixmaps/denemo.desktop
}

src_configure() {
	econf \
		--disable-static \
		--disable-gtk2 \
		--enable-gtk3 \
		$(use_enable alsa) \
		$(use_enable aubio ) \
		$(use_enable evince ) \
		$(use_enable fluidsynth) \
		$(use_enable guile guile_1_8) \
		$(use_enable jack) \
		$(use_enable nls) \
		$(use_enable portaudio) \
		$(use_enable portmidi) \
		$(use_enable rubberband) \
		--enable-x11 \
		--disable-mem \
		--disable-doc \
		--disable-gtk-doc \
		--disable-gtk-doc-html \
		--disable-gtk-doc-pdf \
		--disable-installed-tests \
		--disable-always-build-tests \
		--disable-gcov
}

pkg_postinst() { xdg_desktop_database_update; }
pkg_postrm() { xdg_desktop_database_update; }

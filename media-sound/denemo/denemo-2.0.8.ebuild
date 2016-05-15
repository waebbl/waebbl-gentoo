# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils fdo-mime

DESCRIPTION="A music notation editor"
HOMEPAGE="http://www.denemo.org/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa aubio jack +fluidsynth guile nls +portaudio +portmidi +rubberband"

COMMON_DEPEND="
	>=app-text/evince-3
	dev-libs/libxml2:2
	gnome-base/librsvg:2
	media-libs/fontconfig:1.0
	>=media-libs/libsmf-1.3
	media-libs/libsndfile
	x11-libs/gtk+:3
	x11-libs/gtksourceview:3.0
	alsa? ( media-libs/alsa-lib )
	aubio? ( media-libs/aubio )
	jack? ( >=media-sound/jack-audio-connection-kit-0.102 )
	fluidsynth? ( media-sound/fluidsynth )
	guile? ( >=dev-scheme/guile-1.8:12 )
	portaudio? (
		media-libs/portaudio
		sci-libs/fftw:3.0
	)
	portmidi? ( media-libs/portmidi )
	rubberband? ( media-libs/rubberband )"
RDEPEND="${COMMON_DEPEND}
	media-sound/lilypond"
DEPEND="${COMMON_DEPEND}
	sys-devel/flex
	dev-util/intltool
	virtual/pkgconfig
	virtual/yacc
	nls? ( sys-devel/gettext )"

DOCS=( AUTHORS ChangeLog docs/{DESIGN{,.lilypond},GOALS,TODO} NEWS )

src_prepare() {
	default_src_prepare
	sed -i 's/^\(Categories.*[^;]\)$/\1;/g' pixmaps/denemo.desktop
}

src_configure() {
	econf \
		--disable-static \
		--enable-gtk3 \
		$(use_enable alsa) \
		$(use_enable aubio aubio4 ) \
		$(use_enable fluidsynth) \
		$(use_enable guile guile_1_8) \
		$(use_enable jack) \
		$(use_enable nls) \
		$(use_enable portaudio) \
		$(use_enable portmidi) \
		$(use_enable rubberband) \
		--enable-x11
}

pkg_postinst() { fdo-mime_desktop_database_update; }
pkg_postrm() { fdo-mime_desktop_database_update; }

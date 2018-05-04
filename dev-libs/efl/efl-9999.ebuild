# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils xdg-utils
[ "${PV}" = 9999 ] && inherit git-r3 autotools

DESCRIPTION="Enlightenment Foundation Core Libraries"
HOMEPAGE="https://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"
[ "${PV}" = 9999 ] || SRC_URI="http://download.enlightenment.org/rel/libs/${PN}/${P/_/-}.tar.bz2"

LICENSE="BSD-2 GPL-2 LGPL-2.1 ZLIB"
[ "${PV}" = 9999 ] || KEYWORDS="~amd64 ~x86"
SLOT="0"

IUSE="+X avahi +bmp cxx-bindings debug doc drm +eet egl fbcon +fontconfig fribidi gif gles glib gnutls gstreamer harfbuzz +ico ibus jpeg2k libressl neon oldlua nls +opengl ssl physics pixman +png +ppm postscript psd pulseaudio rawphoto scim sdl sound static-libs +svg systemd test tga tiff tslib v4l2 vlc wayland webp xim xine xpm"

REQUIRED_USE="
	pulseaudio?	( sound )
	opengl?		( || ( X sdl wayland ) )
	gles?		( || ( X wayland ) )
	gles?		( !sdl )
	gles?		( egl )
	sdl?		( opengl )
	wayland?	( egl !opengl gles )
	xim?		( X )
"

COMMON_DEP="
	drm? (
		>=dev-libs/libinput-0.8
		media-libs/mesa[gbm]
		>=x11-libs/libdrm-2.4
		>=x11-libs/libxkbcommon-0.3.0
	)
	dev-lang/luajit:2
	sys-apps/dbus
	sys-libs/zlib
	virtual/jpeg:*
	virtual/udev
	X? (
		x11-libs/libX11
		x11-libs/libXScrnSaver
		x11-libs/libXcomposite
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libXtst
		gles? (
			media-libs/mesa[egl,gles2]
			x11-libs/libXrender
		)
		opengl? (
			virtual/opengl
			x11-libs/libXrender
		)
	)
	avahi? ( net-dns/avahi )
	debug? ( dev-util/valgrind )
	fontconfig? ( media-libs/fontconfig )
	fribidi? ( dev-libs/fribidi )
	gif? ( media-libs/giflib )
	glib? ( dev-libs/glib:* )
	gnutls? ( net-libs/gnutls )
	!gnutls? ( ssl? ( dev-libs/openssl:* ) )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	vlc? ( media-video/vlc )
	harfbuzz? ( media-libs/harfbuzz )
	ibus? ( app-i18n/ibus )
	jpeg2k? ( media-libs/openjpeg:0 )
	nls? ( sys-devel/gettext )
	!oldlua? ( >=dev-lang/luajit-2.0.0 )
	oldlua? ( dev-lang/lua:* )
	physics? ( sci-physics/bullet )
	pixman? ( x11-libs/pixman )
	postscript? ( app-text/libspectre:* )
	png? ( media-libs/libpng:0= )
	pulseaudio? (
		media-sound/pulseaudio
		media-libs/libsndfile
	)
	scim?	( app-i18n/scim )
	sdl? (
		>=media-libs/libsdl2-2.0.0:0[opengl?,gles?]
	)

	svg? ( gnome-base/librsvg )
	sound? ( media-libs/libsndfile )
	systemd? ( sys-apps/systemd )
	tiff? ( media-libs/tiff:0 )
	tslib? ( x11-libs/tslib )
	wayland? (
		>=dev-libs/wayland-1.3.0:0
		>=x11-libs/libxkbcommon-0.3.1
		egl? ( media-libs/mesa[egl,gles2] )
	)
	webp? ( media-libs/libwebp )
	vlc? ( media-video/vlc )
	xine? ( >=media-libs/xine-lib-1.1.1 )
	xpm? ( x11-libs/libXpm )"
RDEPEND="${COMMON_DEP}"
DEPEND="${COMMON_DEP}
	!!dev-libs/ecore
	!!dev-libs/edbus
	!!dev-libs/eet
	!!dev-libs/eeze
	!!dev-libs/efreet
	!!dev-libs/eina
	!!dev-libs/eio
	!!dev-libs/embryo
	!!dev-libs/eobj
	!!dev-libs/ephysics
	!!media-libs/edje
	!!media-libs/emotion
	!!media-libs/ethumb
	!!media-libs/evas
	doc? ( app-doc/doxygen )
	test? ( dev-libs/check )"

S="${WORKDIR}/${P/_/-}"

src_prepare() {
	[ ${PV} = 9999 ] && eautoreconf
}

src_configure() {
	local config=()

	# gnutls / openssl
	if use gnutls; then
		config+=( --with-crypto=gnutls )
		use ssl && \
			einfo "You enabled both USE=ssl and USE=gnutls, using gnutls"
	elif use ssl; then
		config+=( --with-crypto=openssl )
	else
		config+=( --with-crypto=none )
	fi

	# X
	config+=(
		$(use_with X x)
		$(use_with X x11 xlib)
	)
	if use opengl; then
		config+=( --with-opengl=full )
		use gles &&  \
			einfo "You enabled both USE=opengl and USE=gles, using opengl"
	elif use gles; then
		config+=( --with-opengl=es )
		if use sdl; then
			config+=( --with-opengl=none )
			ewarn "You enabled both USE=sdl and USE=gles which isn't currently supported."
			ewarn "Disabling gl for all backends."
		fi
	else
		config+=( --with-opengl=none )
	fi

	# Handle vlc
	if use vlc; then
		has_version '>=media-video/vlc-3.0.0' && config+=( --enable-libvlc )
		has_version '<media-video/vlc-3.0.0' && config+=( --with-generic_vlc )
	fi

	# wayland
	config+=(
		$(use_enable egl)
		$(use_enable wayland)
	)

	#if use drm && use systemd; then
		config+=(
			$(use_enable drm)
		)
	#else
	#	einfo "You cannot build DRM support without systemd support, disabling drm engine"
	#	config+=(
	#		--disable-drm
	#	)
	#fi
	config+=(
		$(use_enable avahi)
		$(use_enable bmp image-loader-bmp)
		$(use_enable bmp image-loader-wbmp)
		$(use_enable drm)
		$(use_enable cxx-bindings cxx-bindings)
		$(use_enable doc)
		$(use_enable eet image-loader-eet)
		$(use_enable egl)
		$(use_enable fbcon fb)
		$(use_enable fontconfig)
		$(use_enable fribidi)
		$(use_enable gif image-loader-gif)
		$(use_enable gstreamer gstreamer1)
		$(use_enable harfbuzz)
		$(use_enable ico image-loader-ico)
		$(use_enable jpeg2k image-loader-jp2k)
		$(use_enable neon)
		$(use_enable ibus)
		$(use_enable nls)
		$(use_enable oldlua lua-old)
		$(use_enable physics)
		$(use_enable pixman)
		$(use_enable pixman pixman-font)
		$(use_enable pixman pixman-rect)
		$(use_enable pixman pixman-line)
		$(use_enable pixman pixman-poly)
		$(use_enable pixman pixman-image)
		$(use_enable pixman pixman-image-scale-sample)
		$(use_enable png image-loader-png)
		$(use_enable ppm image-loader-pmaps)
		$(use_enable postscript spectre)
		$(use_enable psd image-loader-psd)

		$(use_enable pulseaudio)
		$(use_enable pulseaudio audio)
		$(use_enable rawphoto libraw)
		$(use_enable scim)
		$(use_enable sdl)
		$(use_enable static-libs static)
		$(use_enable systemd)
		$(use_enable tga image-loader-tga)
		$(use_enable tiff image-loader-tiff)
		$(use_enable tslib)
		$(use_enable v4l2)
		$(use_enable webp image-loader-webp)
		$(use_enable xpm image-loader-xpm)
		$(use_enable xim)
		$(use_enable xine)

		# image loders
		--enable-image-loader-generic
		--enable-image-loader-ico
		--enable-image-loader-jpeg # required by ethumb
		$(use_enable svg librsvg)
		--enable-image-loader-tga
		--enable-image-loader-wbmp

		--enable-cserve
		--enable-libmount
		--enable-threads
		--enable-xinput22

		--disable-gstreamer # using gstreamer1
		#--disable-lua-old
		--disable-multisense
		--disable-tizen
		--disable-gesture
		#--disable-xinput2
		#--enable-xinput2 # enable it
		--enable-elput
		--disable-xpresent

		# bug 501074. Is it still valid?
		#--disable-pixman
		#--disable-pixman-font
		#--disable-pixman-rect
		#--disable-pixman-line
		#--disable-pixman-poly
		#--disable-pixman-image
		#--disable-pixman-image-scale-sample

		--with-profile=$(usex debug debug release)
		--with-glib=$(usex glib yes no)
		--with-tests=$(usex test regular none)

#		--enable-i-really-know-what-i-am-doing-and-that-this-will-probably-break-things-and-i-will-fix-them-myself-and-send-patches-aba
		--enable-i-really-know-what-i-am-doing-and-that-this-will-probably-break-things-and-i-will-fix-them-myself-and-send-patches-abb
	)

	# Checking for with version of vlc is enabled and therefore use the right configure option
	if use vlc ; then
		einfo "You enabled USE=vlc. Checking vlc version..."
		if has_version ">media-video/vlc-3.0" ; then
			einfo "> 3.0 found. Enabling libvlc."
			E_ECONF+=($(use_enable vlc libvlc))
		else
			einfo "< 3.0 found. Enabling generic-vlc."
			E_ECONF+=($(use_with vlc generic-vlc))
		fi
	fi

	econf "${config[@]}"
}

src_test() {
	MAKEOPTS+=" -j1"
	default
}

src_install() {
	MAKEOPTS+=" -j1"
	default
	prune_libtool_files
}

pkg_postinst() {
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
}

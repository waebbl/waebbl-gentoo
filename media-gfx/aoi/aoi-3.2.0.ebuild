# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

JAVA_PKG_IUSE="doc"
PYTHON_COMPAT=( python3_{8,9,10} )
inherit desktop java-pkg-2 java-ant-2 python-any-r1 xdg

MY_PN="ArtOfIllusion"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A free, open-source 3D modelling and rendering studio"
HOMEPAGE="http://www.artofillusion.org" # no https
SRC_URI="https://github.com/${MY_PN}/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"

RDEPEND=">=virtual/jre-1.8:*"
DEPEND="
	${RDEPEND}
	>=virtual/jdk-1.8:*
"
BDEPEND="
	doc? (
		${PYTHON_DEPS}
		dev-python/sphinx
	)
"

RESTRICT="test"
DOCS=( docs/History.md )

python_check_deps() {
	use doc && has_version dev-python/sphinx[${PYTHON_USEDEP}]
}

pkg_setup() {
	use test && JAVA_PKG_FORCE_ANT_TASKS="ant-junit"
	java-pkg-2_pkg_setup
	use doc && python-any-r1_pkg_setup
}

src_compile() {
	EANT_BUILD_TARGET=dist
	EANT_DOC_TARGET=docs
	java-pkg-2_src_compile

	if use doc; then
		pushd "${S}"/docs/manual >/dev/null || die
		emake html
		popd >/dev/null || die
	fi
}

src_install() {
	einstalldocs
	if use doc ; then
		java-pkg_dojavadoc docs/Javadoc
		dodoc -r "${S}"/docs/manual/_build/html
	fi

	# main app
	java-pkg_dojar Live_Application/ArtOfIllusion.jar

	# run script
	java-pkg_dolauncher aoi \
		--jar ArtOfIllusion.jar \
		--java_args -Xmx128M

	mv "Live_Application/Textures and Materials" "${ED}"/usr/share/${PN}/lib || die
	keepdir "/usr/share/${PN}/lib/Textures and Materials"
	mv Live_Application/Plugins "${ED}"/usr/share/${PN}/lib || die
	mv Live_Application/Scripts "${ED}"/usr/share/${PN}/lib || die
	keepdir /usr/share/${PN}/lib/Scripts/{Objects,Startup,Tools}
	mv Live_Application/lib "${ED}"/usr/share/${PN}/lib || die

	for size in 32 48 64; do
		doicon -s ${size} InstallerSrc/utils/icons/${size}x${size}/${PN}.png
	done

	make_desktop_entry aoi "Art of Illusion" aoi "Graphics"

	insinto /usr/share/mime
	doins InstallerSrc/utils/aoi.xml
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_preinst() {
	xdg_pkg_preinst
}

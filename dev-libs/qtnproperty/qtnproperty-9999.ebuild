# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# TODO:
#	* install headers
#	* improve qmake files, add install targets

EAPI=6

inherit qmake-utils git-r3

DESCRIPTION="Tool to extend properties in the Qt5 framework."
HOMEPAGE="https://github.com/lexxmark/QtnProperty/wiki"
EGIT_REPO_URI="https://github.com/lexxmark/QtnProperty.git"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="demo doc static test"

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

PATCHES=( "${FILESDIR}"/${PN}_fix-Doxyfile.patch
	"${FILESDIR}"/${PN}_fix-staticlib.patch )
DOCS=( AUTHORS README.md TODO )

src_prepare() {
	if use doc; then
		eapply "${FILESDIR}"/${PN}_fix-Doxyfile.patch
	fi
	if ! use static; then
		eapply "${FILESDIR}"/${PN}_fix-staticlib.patch
	fi
	eapply_user

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
	if use static; then
		"${S}"/bin-linux/QtnPropertyTests
	else
		LD_LIBRARY_PATH="${S}/bin-linux" "${S}"/bin-linux/QtnPropertyTests
	fi
}

# TODO: most of this can probably go into the qmake files
src_install() {
	emake DESTDIR="${D}" install || die

	BASE_INC_DIR="/usr/include/QtnProperty"

	CORE_HEADERS=( CoreAPI.h \
		PropertyBase.h \
		Property.h \
		PropertySet.h \
		Enum.h \
		QObjectPropertySet.h \
		PropertyCore.h \
		PropertyGUI.h )
	insinto "${BASE_INC_DIR}"/Core
	for i in "${CORE_HEADERS[@]}"; do
		doins "${S}/Core/${i}"
	done
	unset i

	CORE_AUX_HEADERS=( Auxiliary/PropertyTemplates.h \
		Auxiliary/PropertyMacro.h \
		Auxiliary/PropertyAux.h )
	insinto "${BASE_INC_DIR}"/Core/Auxiliary
	for i in "${CORE_AUX_HEADERS[@]}"; do
		doins "${S}/Core/${i}"
	done
	unset i

	CORE_CORE_HEADERS=( Core/PropertyBool.h \
		Core/PropertyInt.h \
		Core/PropertyUInt.h \
		Core/PropertyFloat.h \
		Core/PropertyDouble.h \
		Core/PropertyQString.h \
		Core/PropertyQRect.h \
		Core/PropertyQRectF.h \
		Core/PropertyEnum.h \
		Core/PropertyEnumFlags.h \
		Core/PropertyQSize.h \
		Core/PropertyQSizeF.h \
		Core/PropertyQPoint.h \
		Core/PropertyQPointF.h )
	insinto "${BASE_INC_DIR}"/Core/Core
	for i in "${CORE_CORE_HEADERS[@]}"; do
		doins "${S}/Core/${i}"
	done
	unset i

	CORE_GUI_HEADERS=( GUI/PropertyQColor.h \
		GUI/PropertyQPen.h \
		GUI/PropertyQBrush.h \
		GUI/PropertyButton.h \
		GUI/PropertyQFont.h )
	insinto "${BASE_INC_DIR}"/Core/GUI
	for i in "${CORE_GUI_HEADERS[@]}"; do
		doins "${S}/Core/${i}"
	done
	unset i

	PROPERTY_WIDGET_HEADERS=( PropertyWidgetAPI.h \
		PropertyWidget.h \
		PropertyView.h )
	insinto "${BASE_INC_DIR}"/PropertyWidget
	for i in "${PROPERTY_WIDGET_HEADERS[@]}"; do
		doins "${S}/PropertyWidget/${i}"
	done
	unset i

	PROPERTY_WIDGET_UTILS_HEADERS=( Utils/InplaceEditing.h \
		Utils/AccessibilityProxy.h )
	insinto "${BASE_INC_DIR}"/PropertyWidget/Utils
	for i in "${PROPERTY_WIDGET_UTILS_HEADERS[@]}"; do
		doins "${S}/PropertyWidget/${i}"
	done
	unset i

	PROPERTY_WIDGET_DELEGATES_HEADERS=( Delegates/PropertyDelegate.h \
		Delegates/PropertyDelegateAux.h \
		Delegates/PropertyDelegateFactory.h )
	insinto "${BASE_INC_DIR}"/PropertyWidget/Delegates
	for i in "${PROPERTY_WIDGET_DELEGATES_HEADERS[@]}"; do
		doins "${S}/PropertyWidget/${i}"
	done
	unset i

	PROPERTY_WIDGET_DELEGATES_UTILS_HEADERS=(\
		Delegates/Utils/PropertyDelegatePropertySet.h \
		Delegates/Utils/PropertyDelegateSliderBox.h \
		Delegates/Utils/PropertyDelegateMisc.h \
		Delegates/Utils/PropertyEditorHandler.h \
		Delegates/Utils/PropertyEditorAux.h )
	insinto "${BASE_INC_DIR}"/PropertyWidget/Delegates/Utils
	for i in "${PROPERTY_WIDGET_DELEGATES_UTILS_HEADERS[@]}"; do
		doins "${S}/PropertyWidget/${i}"
	done
	unset i

	PROPERTY_WIDGET_DELEGATES_CORE_HEADERS=(\
		Delegates/Core/PropertyDelegateBool.h \
		Delegates/Core/PropertyDelegateInt.h \
		Delegates/Core/PropertyDelegateUInt.h \
		Delegates/Core/PropertyDelegateQString.h \
		Delegates/Core/PropertyDelegateFloat.h \
		Delegates/Core/PropertyDelegateDouble.h \
		Delegates/Core/PropertyDelegateEnum.h \
		Delegates/Core/PropertyDelegateQRect.h \
		Delegates/Core/PropertyDelegateQRectF.h \
		Delegates/Core/PropertyDelegateEnumFlags.h \
		Delegates/Core/PropertyDelegateQSize.h \
		Delegates/Core/PropertyDelegateQSizeF.h \
		Delegates/Core/PropertyDelegateQPoint.h \
		Delegates/Core/PropertyDelegateQPointF.h )
	insinto "${BASE_INC_DIR}"/PropertyWidget/Delegates/Core
	for i in "${PROPERTY_WIDGET_DELEGATES_CORE_HEADERS[@]}"; do
		doins "${S}/PropertyWidget/${i}"
	done
	unset i

	PROPERTY_WIDGET_DELEGATES_GUI_HEADERS=(\
		Delegates/GUI/PropertyDelegateQFont.h \
		Delegates/GUI/PropertyDelegateQPen.h \
		Delegates/GUI/PropertyDelegateQBrush.h \
		Delegates/GUI/PropertyDelegateQColor.h \
		Delegates/GUI/PropertyDelegateButton.h )
	insinto "${BASE_INC_DIR}"/PropertyWidget/Delegates/GUI
	for i in "${PROPERTY_WIDGET_DELEGATES_GUI_HEADERS[@]}"; do
		doins "${S}/PropertyWidget/${i}"
	done
	unset i

	exeinto /usr/bin
	doexe "${S}"/bin-linux/QtnPEG

	if use demo; then
		exeinto /usr/share/QtnProperty
		doexe "${S}"/bin-linux/QtnPropertyDemo
		insinto /usr/share/QtnProperty/Example
		doins "${S}"/Docs/Example/*
	fi

	if use test; then
		exeinto /usr/share/QtnProperty
		doexe "${S}"/bin-linux/QtnPropertyTests
	fi

	if use static; then
		dolib.a "${S}"/bin-linux/libQtnPropertyCore.a
		dolib.a "${S}"/bin-linux/libQtnPropertyWidget.a
	else
		dolib.so "${S}"/bin-linux/libQtnPropertyCore.so.1.0.0
		dosym libQtnPropertyCore.so.1.0.0 /usr/$(get_libdir)/libQtnPropertyCore.so.1.0
		dosym libQtnPropertyCore.so.1.0 /usr/$(get_libdir)/libQtnPropertyCore.so.1
		dosym libQtnPropertyCore.so.1 /usr/$(get_libdir)/libQtnPropertyCore.so

		dolib.so "${S}"/bin-linux/libQtnPropertyWidget.so.1.1.0
		dosym libQtnPropertyWidget.so.1.1.0 /usr/$(get_libdir)/libQtnPropertyWidget.so.1.1
		dosym libQtnPropertyWidget.so.1.1 /usr/$(get_libdir)/libQtnPropertyWidget.so.1
		dosym libQtnPropertyWidget.so.1 /usr/$(get_libdir)/libQtnPropertyWidget.so
	fi

	if use doc; then
		HTML_DOCS=( Docs/html/* )
	fi
	einstalldocs
}

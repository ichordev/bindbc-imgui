/+
+            Copyright 2023 – 2024 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui;

import bindbc.imgui.config;
import bindbc.imgui.codegen;

import core.vararg: va_list;
import core.stdc.string: memcpy, memset, memmove, memcmp, strcmp;

public import imgui.impl;
version(ImGui_Internal){
	public import imgui.internal;
}else{
	import imgui.internal;
}

enum IMGUI_VERSION        = "1.90.0";
enum IMGUI_VERSION_NUM    = 19000;

pragma(inline,true) bool IMGUI_CHECKVERSION() nothrow @nogc{
	return DebugCheckVersionAndDataLayout(
		IMGUI_VERSION,
		ImGuiIO.sizeof, ImGuiStyle.sizeof,
		ImVec2.sizeof, ImVec4.sizeof,
		ImDrawVert.sizeof, ImDrawIdx.sizeof
	);
}

struct ImDrawListSharedData;

struct ImFontBuilderIO;

struct ImGuiContext;

alias ImGuiKeyChord = int;

alias ImTextureID = void*;

version(ImGui_ImDrawIdx32){
	alias ImDrawIdx = uint;
}else{
	alias ImDrawIdx = ushort;
}

version(ImGui_WChar32){
	alias ImWchar = uint;
}else{
	alias ImWchar = ushort;
}

alias ImGuiID = uint;

alias ImGuiInputTextCallback = extern(C++) int function(ImGuiInputTextCallbackData* data);

alias ImGuiSizeCallback = extern(C++) void function(ImGuiSizeCallbackData* data);

alias ImGuiMemAllocFunc = extern(C++) void* function(size_t sz, void* userData);

alias ImGuiMemFreeFunc = extern(C++) void function(void* ptr, void* userData);

extern(C++) struct ImVec2{
	float x=0f, y=0f;
	
	nothrow @nogc pure @safe:
	float opIndex(size_t idx) const{
		switch(idx){
			case 0: return x;
			case 1: return y;
			default: assert(0);
		}
	}
	ImVec2 opBinary(string op)(const float rhs) const{
		mixin("return ImVec2(x "~op~" rhs, y "~op~" rhs);");
	}
	ImVec2 opBinary(string op)(const ImVec2 rhs) const{
		mixin("return ImVec2(x "~op~" rhs.x, y "~op~" rhs.y);");
	}
	ImVec2 opUnary(string op)() const{
		mixin("return ImVec2("~op~"x, "~op~"y);");
	}
	ref ImVec2 opOpAssign(string op)(const float rhs){
		mixin("x "~op~"= rhs; y "~op~"= rhs;"); return this;
	}
	ref ImVec2 opOpAssign(string op)(const ImVec2 rhs){
		mixin("x "~op~"= rhs.x; y "~op~"= rhs.y);"); return this;
	}
}

extern(C++) struct ImVec4{
	float x=0f, y=0f, z=0f, w=0f;
	
	nothrow @nogc pure @safe:
	ImVec4 opBinary(string op)(const float rhs) const{
		mixin("return ImVec4(x "~op~" rhs, y "~op~" rhs, z "~op~" rhs, w "~op~" rhs);");
	}
	ImVec4 opBinary(string op)(const ImVec4 rhs) const{
		mixin("return ImVec4(x "~op~" rhs.x, y "~op~" rhs.y, z "~op~" rhs.z, w "~op~" rhs.w);");
	}
	ImVec4 opUnary(string op)() const{
		mixin("return ImVec4("~op~"x, "~op~"y, "~op~"z, "~op~"w);");
	}
	ref ImVec4 opOpAssign(string op)(const float rhs){
		mixin("x "~op~"= rhs; y "~op~"= rhs; z "~op~"= rhs; w "~op~"= rhs;"); return this;
	}
	ref ImVec4 opOpAssign(string op)(const ImVec4 rhs){
		mixin("x "~op~"= rhs.x; y "~op~"= rhs.y; z "~op~"= rhs.z; w "~op~"= rhs.w);"); return this;
	}
}

alias ImGuiWindowFlags_ = int;
enum ImGuiWindowFlags: ImGuiWindowFlags_{
	none                   = 0,
	noTitleBar             = 1 << 0,
	noResize               = 1 << 1,
	noMove                 = 1 << 2,
	noScrollbar            = 1 << 3,
	noScrollWithMouse      = 1 << 4,
	noCollapse             = 1 << 5,
	alwaysAutoResize       = 1 << 6,
	noBackground           = 1 << 7,
	noSavedSettings        = 1 << 8,
	noMouseInputs          = 1 << 9,
	menuBar                = 1 << 10,
	horizontalScrollbar    = 1 << 11,
	noFocusOnAppearing     = 1 << 12,
	noBringToFrontOnFocus  = 1 << 13,
	alwaysVerticalScrollbar = 1 << 14,
	alwaysHorizontalScrollbar = 1 << 15,
	noNavInputs            = 1 << 16,
	noNavFocus             = 1 << 17,
	unsavedDocument        = 1 << 18,
	noNav                  = noNavInputs | noNavFocus,
	noDecoration           = noTitleBar | noResize | noScrollbar | noCollapse,
	noInputs               = noMouseInputs | noNavInputs | noNavFocus,
	navFlattened           = 1 << 23,
	childWindow            = 1 << 24,
	tooltip                = 1 << 25,
	popup                  = 1 << 26,
	modal                  = 1 << 27,
	childMenu              = 1 << 28,
}

alias ImGuiChildFlags_ = int;
enum ImGuiChildFlags: ImGuiChildFlags_{
	none                    = 0,
	border                  = 1 << 0,
	alwaysUseWindowPadding  = 1 << 1,
	resizeX                 = 1 << 2,
	resizeY                 = 1 << 3,
	autoResizeX             = 1 << 4,
	autoResizeY             = 1 << 5,
	alwaysAutoResize        = 1 << 6,
	frameStyle              = 1 << 7,
}

alias ImGuiInputTextFlags_ = int;
enum ImGuiInputTextFlags: ImGuiInputTextFlags_{
	none                 = 0,
	charsDecimal         = 1 << 0,
	charsHexadecimal     = 1 << 1,
	charsUppercase       = 1 << 2,
	charsNoBlank         = 1 << 3,
	autoSelectAll        = 1 << 4,
	enterReturnsTrue     = 1 << 5,
	callbackCompletion   = 1 << 6,
	callbackHistory      = 1 << 7,
	callbackAlways       = 1 << 8,
	callbackCharFilter   = 1 << 9,
	allowTabInput        = 1 << 10,
	ctrlEnterForNewLine  = 1 << 11,
	noHorizontalScroll   = 1 << 12,
	alwaysOverwrite      = 1 << 13,
	readOnly             = 1 << 14,
	password             = 1 << 15,
	noUndoRedo           = 1 << 16,
	charsScientific      = 1 << 17,
	callbackResize       = 1 << 18,
	callbackEdit         = 1 << 19,
	escapeClearsAll      = 1 << 20,
}

alias ImGuiTreeNodeFlags_ = int;
enum ImGuiTreeNodeFlags: ImGuiTreeNodeFlags_{
	none                  = 0,
	selected              = 1 << 0,
	framed                = 1 << 1,
	allowOverlap          = 1 << 2,
	noTreePushOnOpen      = 1 << 3,
	noAutoOpenOnLog       = 1 << 4,
	defaultOpen           = 1 << 5,
	openOnDoubleClick     = 1 << 6,
	openOnArrow           = 1 << 7,
	leaf                  = 1 << 8,
	bullet                = 1 << 9,
	framePadding          = 1 << 10,
	spanAvailWidth        = 1 << 11,
	spanFullWidth         = 1 << 12,
	spanAllColumns        = 1 << 13,
	navLeftJumpsBackHere  = 1 << 14,
	collapsingHeader      = framed | noTreePushOnOpen | noAutoOpenOnLog,
}

alias ImGuiPopupFlags_ = int;
enum ImGuiPopupFlags: ImGuiPopupFlags_{
	none                     = 0,
	mouseButtonLeft          = 0,
	mouseButtonRight         = 1,
	mouseButtonMiddle        = 2,
	mouseButtonMask_         = 0x1F,
	mouseButtonDefault_      = 1,
	noOpenOverExistingPopup  = 1 << 5,
	noOpenOverItems          = 1 << 6,
	anyPopupID               = 1 << 7,
	anyPopupLevel            = 1 << 8,
	anyPopup                 = anyPopupID | anyPopupLevel,
}

alias ImGuiSelectableFlags_ = int;
enum ImGuiSelectableFlags: ImGuiSelectableFlags_{
	none               = 0,
	dontClosePopups    = 1 << 0,
	spanAllColumns     = 1 << 1,
	allowDoubleClick   = 1 << 2,
	disabled           = 1 << 3,
	allowOverlap       = 1 << 4,
}

alias ImGuiComboFlags_ = int;
enum ImGuiComboFlags: ImGuiComboFlags_{
	none            = 0,
	popupAlignLeft  = 1 << 0,
	heightSmall     = 1 << 1,
	heightRegular   = 1 << 2,
	heightLarge     = 1 << 3,
	heightLargest   = 1 << 4,
	noArrowButton   = 1 << 5,
	noPreview       = 1 << 6,
	widthFitPreview = 1 << 7,
	heightMask_     = heightSmall | heightRegular | heightLarge | heightLargest,
}

alias ImGuiTabBarFlags_ = int;
enum ImGuiTabBarFlags: ImGuiTabBarFlags_{
	none                           = 0,
	reorderable                    = 1 << 0,
	autoSelectNewTabs              = 1 << 1,
	tabListPopupButton             = 1 << 2,
	noCloseWithMiddleMouseButton   = 1 << 3,
	noTabListScrollingButtons      = 1 << 4,
	noTooltip                      = 1 << 5,
	fittingPolicyResizeDown        = 1 << 6,
	fittingPolicyScroll            = 1 << 7,
	fittingPolicyMask_             = fittingPolicyResizeDown | fittingPolicyScroll,
	fittingPolicyDefault_          = fittingPolicyResizeDown,
}

alias ImGuiTabItemFlags_ = int;
enum ImGuiTabItemFlags: ImGuiTabItemFlags_{
	none                          = 0,
	unsavedDocument               = 1 << 0,
	setSelected                   = 1 << 1,
	noCloseWithMiddleMouseButton  = 1 << 2,
	noPushId                      = 1 << 3,
	noTooltip                     = 1 << 4,
	noReorder                     = 1 << 5,
	leading                       = 1 << 6,
	trailing                      = 1 << 7,
}

alias ImGuiTableFlags_ = int;
enum ImGuiTableFlags: ImGuiTableFlags_{
	none                  = 0,
	resizable             = 1 << 0,
	reorderable           = 1 << 1,
	hideable              = 1 << 2,
	sortable              = 1 << 3,
	nosavedsettings       = 1 << 4,
	contextmenuinbody     = 1 << 5,
	
	rowBg                 = 1 << 6,
	bordersInnerH         = 1 << 7,
	bordersOuterH         = 1 << 8,
	bordersInnerV         = 1 << 9,
	bordersOuterV         = 1 << 10,
	bordersH              = bordersInnerH | bordersOuterH,
	bordersV              = bordersInnerV | bordersOuterV,
	bordersInner          = bordersInnerV | bordersInnerH,
	bordersOuter          = bordersOuterV | bordersOuterH,
	borders               = bordersInner | bordersOuter,
	noBordersInBody       = 1 << 11,
	noBordersInBodyUntilResize = 1 << 12,
	
	sizingFixedFit        = 1 << 13,
	sizingFixedSame       = 2 << 13,
	sizingStretchProp     = 3 << 13,
	sizingStretchSame     = 4 << 13,
	
	noHostExtendX         = 1 << 16,
	noHostExtendY         = 1 << 17,
	noKeepColumnsVisible  = 1 << 18,
	preciseWidths         = 1 << 19,
	
	noClip                = 1 << 20,
	
	padOuterX             = 1 << 21,
	noPadOuterX           = 1 << 22,
	noPadInnerX           = 1 << 23,
	
	scrollX               = 1 << 24,
	scrollY               = 1 << 25,
	
	sortMulti             = 1 << 26,
	sortTristate          = 1 << 27,
	
	highlightHoveredColumn = 1 << 28,
	
	sizingMask_           = sizingFixedFit | sizingFixedSame | sizingStretchProp | sizingStretchSame,
}

alias ImGuiTableColumnFlags_ = int;
enum ImGuiTableColumnFlags: ImGuiTableColumnFlags_{
	none                  = 0,
	disabled              = 1 << 0,
	defaultHide           = 1 << 1,
	defaultSort           = 1 << 2,
	widthStretch          = 1 << 3,
	widthFixed            = 1 << 4,
	noResize              = 1 << 5,
	noReorder             = 1 << 6,
	noHide                = 1 << 7,
	noClip                = 1 << 8,
	noSort                = 1 << 9,
	noSortAscending       = 1 << 10,
	noSortDescending      = 1 << 11,
	noHeaderLabel         = 1 << 12,
	noHeaderWidth         = 1 << 13,
	preferSortAscending   = 1 << 14,
	preferSortDescending  = 1 << 15,
	indentEnable          = 1 << 16,
	indentDisable         = 1 << 17,
	angledHeader          = 1 << 17,
	
	isEnabled             = 1 << 24,
	isVisible             = 1 << 25,
	isSorted              = 1 << 26,
	isHovered             = 1 << 27,
	
	widthMask_            = widthStretch | widthFixed,
	indentMask_           = indentEnable | indentDisable,
	statusMask_           = isEnabled | isVisible | isSorted | isHovered,
	noDirectResize_       = 1 << 30,
}

alias ImGuiTableRowFlags_ = int;
enum ImGuiTableRowFlags: ImGuiTableRowFlags_{
	none                     = 0,
	headers                  = 1 << 0,
}

alias ImGuiTableBgTarget_ = int;
enum ImGuiTableBgTarget: ImGuiTableBgTarget_{
	none    = 0,
	rowBg0  = 1,
	rowBg1  = 2,
	cellBg  = 3,
}

alias ImGuiFocusedFlags_ = int;
enum ImGuiFocusedFlags: ImGuiFocusedFlags_{
	none                 = 0,
	childWindows         = 1 << 0,
	rootWindow           = 1 << 1,
	anyWindow            = 1 << 2,
	noPopupHierarchy     = 1 << 3,
	dockHierarchy        = 1 << 4,
	rootAndChildWindows  = rootWindow | childWindows,
}

alias ImGuiHoveredFlags_ = int;
enum ImGuiHoveredFlags: ImGuiHoveredFlags_{
	none                          = 0,
	childWindows                  = 1 << 0,
	rootWindow                    = 1 << 1,
	anyWindow                     = 1 << 2,
	noPopupHierarchy              = 1 << 3,
	dockHierarchy                 = 1 << 4,
	allowWhenBlockedByPopup       = 1 << 5,
	allowWhenBlockedByModal       = 1 << 6,
	allowWhenBlockedByActiveItem  = 1 << 7,
	allowWhenOverlappedByItem     = 1 << 8,
	allowWhenOverlappedByWindow   = 1 << 9,
	allowWhenDisabled             = 1 << 10,
	noNavOverride                 = 1 << 11,
	allowWhenOverlapped           = allowWhenOverlappedByItem | allowWhenOverlappedByWindow,
	rectOnly                      = allowWhenBlockedByPopup | allowWhenBlockedByActiveItem | allowWhenOverlappedByItem,
	rootAndChildWindows           = rootWindow | childWindows,
	
	forTooltip                    = 1 << 12,
	
	stationary                    = 1 << 13,
	delayNone                     = 1 << 14,
	delayShort                    = 1 << 15,
	delayNormal                   = 1 << 16,
	noSharedDelay                 = 1 << 17,
}

alias ImGuiDragDropFlags_ = int;
enum ImGuiDragDropFlags: ImGuiDragDropFlags_{
	none                      = 0,
	
	sourceNoPreviewTooltip    = 1 << 0,
	sourceNoDisableHover      = 1 << 1,
	sourceNoHoldToOpenOthers  = 1 << 2,
	sourceAllowNullID         = 1 << 3,
	sourceExtern              = 1 << 4,
	sourceAutoExpirePayload   = 1 << 5,
	
	acceptBeforeDelivery      = 1 << 10,
	acceptNoDrawDefaultRect   = 1 << 11,
	acceptNoPreviewTooltip    = 1 << 12,
	acceptPeekOnly            = acceptBeforeDelivery | acceptNoDrawDefaultRect,
}

enum IMGUI_PAYLOAD_TYPE_COLOR_3F = "_COL3F";
enum IMGUI_PAYLOAD_TYPE_COLOR_4F = "_COL4F";

alias ImGuiDataType_ = int;
enum ImGuiDataType: ImGuiDataType_{
	s8,
	u8,
	s16,
	u16,
	s32,
	u32,
	s64,
	u64,
	float_,
	double_,
	COUNT,
}

alias ImGuiDir_ = int;
enum ImGuiDir: ImGuiDir_{
	none   = -1,
	left   = 0,
	right  = 1,
	up     = 2,
	down   = 3,
	COUNT,
}

alias ImGuiSortDirection_ = int;
enum ImGuiSortDirection: ImGuiSortDirection_{
	none        = 0,
	ascending   = 1,
	descending  = 2
}

enum ImGuiKey: int{
	none = 0,
	tab = 512,
	leftArrow, rightArrow, upArrow, downArrow,
	pageUp, pageDown,
	home, end,
	insert, delete_,
	backspace,
	space,
	enter,
	escape,
	leftCtrl, leftShift, leftAlt, leftSuper,
	rightCtrl, rightShift, rightAlt, rightSuper,
	menu,
	_0, _1, _2, _3, _4, _5, _6, _7, _8, _9,
	a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,
	f1, F2, f3, f4, f5, f6, f7, F8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24,
	apostrophe,
	comma,
	minus,
	period,
	slash,
	semicolon,
	equal,
	leftBracket,
	backslash,
	rightBracket,
	graveAccent,
	capsLock,
	scrollLock,
	numLock,
	printScreen,
	pause,
	keypad0, keypad1, keypad2, keypad3, keypad4,
	keypad5, keypad6, keypad7, keypad8, keypad9,
	keypadDecimal,
	keypadDivide,
	keypadMultiply,
	keypadSubtract,
	keypadAdd,
	keypadEnter,
	keypadEqual,
	appBack,
	appForward,
	
	gamepadStart,
	gamepadBack,
	gamepadFaceLeft,
	gamepadFaceRight,
	gamepadFaceUp,
	gamepadFaceDown,
	gamepadDpadLeft,
	gamepadDpadRight,
	gamepadDpadUp,
	gamepadDpadDown,
	gamepadL1,
	gamepadR1,
	gamepadL2,
	gamepadR2,
	gamepadL3,
	gamepadR3,
	gamepadLStickLeft,
	gamepadLStickRight,
	gamepadLStickUp,
	gamepadLStickDown,
	gamepadRStickLeft,
	gamepadRStickRight,
	gamepadRStickUp,
	gamepadRStickDown,
	
	mouseLeft, mouseRight, mouseMiddle, mouseX1, mouseX2, mouseWheelX, mouseWheelY,
	
	reservedForModCtrl, reservedForModShift, reservedForModAlt, reservedForModSuper,
	COUNT,
	
	namedKey_BEGIN         = 512,
	namedKey_END           = COUNT,
	namedKey_COUNT         = namedKey_END - namedKey_BEGIN,
	keysData_SIZE          = COUNT,
	keysData_OFFSET        = 0,
	modCtrl = ImGuiMod.ctrl, modShift = ImGuiMod.shift, modAlt = ImGuiMod.alt, modSuper = ImGuiMod.super_,
	keyPadEnter = keypadEnter,
}
enum ImGuiMod: ImGuiKey_{
	none                   = 0,
	ctrl                   = 1 << 12,
	shift                  = 1 << 13,
	alt                    = 1 << 14,
	super_                 = 1 << 15,
	shortcut               = 1 << 11,
	mask_                  = 0xF800,
}

alias ImGuiConfigFlags_ = int;
enum ImGuiConfigFlags: ImGuiConfigFlags_{
	none                  = 0,
	navEnableKeyboard     = 1 << 0,
	navEnableGamepad      = 1 << 1,
	navEnableSetMousePos  = 1 << 2,
	navNoCaptureKeyboard  = 1 << 3,
	noMouse               = 1 << 4,
	noMouseCursorChange   = 1 << 5,
	
	isSRGB                = 1 << 20,
	isTouchScreen         = 1 << 21,
}

alias ImGuiBackendFlags_ = int;
enum ImGuiBackendFlags: ImGuiBackendFlags_{
	none                  = 0,
	hasGamepad            = 1 << 0,
	hasMouseCursors       = 1 << 1,
	hasSetMousePos        = 1 << 2,
	rendererHasVtxOffset  = 1 << 3,
}

alias ImGuiCol_ = int;
enum ImGuiCol: ImGuiCol_{
	text,
	textDisabled,
	windowBg,
	childBg,
	popupBg,
	border,
	borderShadow,
	frameBg,
	frameBgHovered,
	frameBgActive,
	titleBg,
	titleBgActive,
	titleBgCollapsed,
	menuBarBg,
	scrollbarBg,
	scrollbarGrab,
	scrollbarGrabHovered,
	scrollbarGrabActive,
	checkMark,
	sliderGrab,
	sliderGrabActive,
	button,
	buttonHovered,
	buttonActive,
	header,
	headerHovered,
	headerActive,
	separator,
	separatorHovered,
	separatorActive,
	resizeGrip,
	resizeGripHovered,
	resizeGripActive,
	tab,
	tabHovered,
	tabActive,
	tabUnfocused,
	tabUnfocusedActive,
	plotLines,
	plotLinesHovered,
	plotHistogram,
	plotHistogramHovered,
	tableHeaderBg,
	tableBorderStrong,
	tableBorderLight,
	tableRowBg,
	tableRowBgAlt,
	textSelectedBg,
	dragDropTarget,
	navHighlight,
	navWindowingHighlight,
	navWindowingDimBg,
	modalWindowDimBg,
	COUNT,
}

alias ImGuiStyleVar_ = int;
enum ImGuiStyleVar: ImGuiStyleVar_{
	alpha,
	disabledAlpha,
	windowPadding,
	windowRounding,
	windowBorderSize,
	windowMinSize,
	windowTitleAlign,
	childRounding,
	childBorderSize,
	popupRounding,
	popupBorderSize,
	framePadding,
	frameRounding,
	frameBorderSize,
	itemSpacing,
	itemInnerSpacing,
	indentSpacing,
	cellPadding,
	scrollbarSize,
	scrollbarRounding,
	grabMinSize,
	grabRounding,
	tabRounding,
	tabBarBorderSize,
	buttonTextAlign,
	selectableTextAlign,
	separatorTextBorderSize,
	separatorTextAlign,
	separatorTextPadding,
	COUNT,
}

alias ImGuiButtonFlags_ = int;
enum ImGuiButtonFlags: ImGuiButtonFlags_{
	none                   = 0,
	mouseButtonLeft        = 1 << 0,
	mouseButtonRight       = 1 << 1,
	mouseButtonMiddle      = 1 << 2,
	
	mouseButtonMask_       = mouseButtonLeft | mouseButtonRight | mouseButtonMiddle,
	mouseButtonDefault_    = mouseButtonLeft,
}

alias ImGuiColorEditFlags_ = int;
alias ImGuiColourEditFlags_ = ImGuiColorEditFlags_;
enum ImGuiColorEditFlags: ImGuiColorEditFlags_{
	none              = 0,
	noAlpha           = 1 << 1,
	noPicker          = 1 << 2,
	noOptions         = 1 << 3,
	noSmallPreview    = 1 << 4,
	noInputs          = 1 << 5,
	noTooltip         = 1 << 6,
	noLabel           = 1 << 7,
	noSidePreview     = 1 << 8,
	noDragDrop        = 1 << 9,
	noBorder          = 1 << 10,
	
	alphaBar          = 1 << 16,
	alphaPreview      = 1 << 17,
	alphaPreviewHalf  = 1 << 18,
	hdr               = 1 << 19,
	displayRGB        = 1 << 20,
	displayHSV        = 1 << 21,
	displayHex        = 1 << 22,
	uint8             = 1 << 23,
	float_            = 1 << 24,
	pickerHueBar      = 1 << 25,
	pickerHueWheel    = 1 << 26,
	inputRGB          = 1 << 27,
	inputHSV          = 1 << 28,
	
	defaultOptions_   = uint8 | displayRGB | inputRGB | pickerHueBar,
	
	displayMask_      = displayRGB | displayHSV | displayHex,
	dataTypeMask_     = uint8 | float_,
	pickerMask_       = pickerHueWheel | pickerHueBar,
	inputMask_        = inputRGB | inputHSV,
}
alias ImGuiColourEditFlags = ImGuiColorEditFlags;

alias ImGuiSliderFlags_ = int;
enum ImGuiSliderFlags: ImGuiSliderFlags_{
	none               = 0,
	alwaysClamp        = 1 << 4,
	logarithmic        = 1 << 5,
	noRoundToFormat    = 1 << 6,
	noInput            = 1 << 7,
	invalidMask_       = 0x7000000F,
}

alias ImGuiMouseButton_ = int;
enum ImGuiMouseButton: ImGuiMouseButton_{
	left    = 0,
	right   = 1,
	middle  = 2,
	COUNT   = 5,
}

alias ImGuiMouseCursor_ = int;
enum ImGuiMouseCursor: ImGuiMouseCursor_{
	none = -1,
	arrow = 0,
	textInput,
	resizeAll,
	resizeNS,
	resizeEW,
	resizeNESW,
	resizeNWSE,
	hand,
	notAllowed,
	COUNT,
}

alias ImGuiMouseSource_ = int;
enum ImGuiMouseSource: ImGuiMouseSource_{
	mouse = 0,
	touchScreen,
	pen,
	COUNT
}

alias ImGuiCond_ = int;
enum ImGuiCond: ImGuiCond_{
	none          = 0,
	always        = 1 << 0,
	once          = 1 << 1,
	firstUseEver  = 1 << 2,
	appearing     = 1 << 3,
}

extern(C++) struct ImVector(T){
	int size = 0;
	int capacity = 0;
	T* data = null;
	
	alias valueType = T;
	alias iterator = valueType*;
	alias constIterator = const(valueType)*;
	
	nothrow @nogc:
	this(const typeof(this) src) pure @safe{
		this = src;
	}
	ImVector!T opAssign(const typeof(this) src){
		clear();
		resize(src.size);
		if(src.data !is null) memcpy(data, src.data, cast(size_t)size * T.sizeof);
		return this;
	}
	~this(){
		if(data) MemFree(data);
	}
	
	void clear(){
		if(data){
			size = capacity = 0;
			MemFree(data);
			data = null;
		}
	}
	static if(__traits(hasMember, T, "__dtor__")){
		void clearDelete(){
			for(int n = 0; n < size; n++) IM_DELETE(Data[n]);
			clear();
		}
		void clearDestruct(){
			for(int n = 0; n < Size; n++) data[n].__dtor__();
			clear();
		}
	}
	
	@property bool empty() const pure @safe => size == 0;
	@property int dataEnd() const pure @safe => data + size;
	int sizeInBytes() const pure @safe => size * cast(int)T.sizeof;
	int maxSize() const pure @safe => 0x7FFFFFFF / cast(int)T.sizeof;
	ref T opIndex(int i) pure @safe
	in(i >= 0 && i < size){
		return data[i];
	}
	ref const(T) opIndex(int i) const pure @safe
	in(i >= 0 && i < size){
		return data[i];
	}
	
	inout(T)* begin() inout pure @safe => data;
	inout(T)* end() inout pure @safe => data + size;
	ref inout(T) front() inout pure @safe in(size > 0) => data[0];
	ref inout(T) back() inout pure @safe in(size > 0) => data[Size - 1];
	void swap(ref ImVector!T rhs){
		int rhsSize = rhs.size;
		rhs.size = size;
		size = rhsSize;
		int rhsCap = rhs.capacity;
		rhs.capacity = capacity;
		capacity = rhsCap;
		T* rhsData = rhs.data;
		rhs.data = data;
		data = rhsData;
	}
	
	int _growCapacity(int sz) const pure @safe{
		int newCapacity = capacity ? (capacity + capacity / 2) : 8;
		return newCapacity > sz ? newCapacity : sz;
	}
	void resize(int newSize) pure{
		if(newSize > capacity) reserve(_growCapacity(newSize));
		size = newSize;
	}
	void resize(int newSize, const T v) pure{
		if(newSize > capacity) reserve(_growCapacity(newSize));
		if(newSize > size){
			for(int n = size; n < newSize; n++) memcpy(&data[n], &v, v.sizeof);
		}
		size = newSize;
	}
	void shrink(int newSize) pure @safe
	in(newSize <= size){
		size = newSize;
	}
	void reserve(int newCapacity) pure{
		if(newCapacity <= capacity) return;
		T* newData = cast(T*)MemAlloc(cast(size_t)newCapacity * T.sizeof);
		if(data){
			memcpy(newData, data, cast(size_t)size * T.sizeof);
			MemFree(data);
		}
		data = newData;
		capacity = newCapacity;
	}
	void reserveDiscard(int newCapacity) pure @safe{
		if(newCapacity <= capacity) return;
		if(data) MemFree(Data);
		data = cast(T*)MemAlloc(cast(size_t)newCapacity * T.sizeof);
		capacity = newCapacity;
	}
	
	void pushBack(const T v) pure @safe{
		if(size == capacity) reserve(_growCapacity(size + 1));
		memcpy(&data[size], &v, v.sizeof);
		size++;
	}
	void popBack() pure @safe
	in(size > 0){
		size--;
	}
	void pushFront(const T v) pure{
		if(size == 0) pushBack(v);
		else insert(data, v);
	}
	T* erase(const(T)* it) pure
	in (it >= data && it < dataEnd){
		const ptrdiff_t off = it - data;
		memmove(data + off, data + off + 1, (cast(size_t)size - cast(size_t)off - 1) * T.sizeof);
		size--;
		return data + off;
	}
	T* erase(const(T)* it, const(T)* itLast) pure
	in(it >= data && it < data + size && itLast >= it && itLast <= data + size){
		const ptrdiff_t count = itLast - it;
		const ptrdiff_t off = it - data;
		memmove(data + off, data + off + count, (cast(size_t)size - cast(size_t)off - cast(size_t)count) * T.sizeof);
		size -= cast(int)count;
		return data + off;
	}
	T* eraseUnsorted(const(T)* it) pure
	in(it >= data && it < data + size){
		const ptrdiff_t off = it - data;
		if(it < data + size - 1) memcpy(data + off, data + size - 1, T.sizeof);
		size--;
		return data + off;
	}
	T* insert(const(T)* it, const T v) pure
	in(it >= data && it <= data + size){
		const ptrdiff_t off = it - data;
		if(size == capacity) reserve(_growCapacity(size + 1));
		if(off < cast(int)size) memmove(data + off + 1, data + off, (cast(size_t)size - cast(size_t)off) * T.sizeof);
		memcpy(&data[off], &v, v.sizeof);
		size++;
		return data + off;
	}
	bool contains(const T v) const pure{
		const(T)* data = this.data;
		while(data < dataEnd){
			if(*(data++) == v) return true;
		}
		return false;
	}
	inout(T)* find(const T v) inout pure{
		inout(T)* data = this.data;
		while(data < dataEnd){
			if(*data == v) break;
			else ++data;
		}
		return data;
	}
	int findIndex(const T v) const pure{
		const T* it = find(v);
		if(it == dataEnd) return -1;
		const ptrdiff_t off = it - data;
		return cast(int)off;
	}
	bool findErase(const T v) pure{
		const(T)* it = find(v);
		if(it < data + size){
			erase(it);
			return true;
		}
		return false;
	}
	bool findEraseUnsorted(const T v) pure{
		const(T)* it = find(v);
		if(it < data + size){
			eraseUnsorted(it);
			return true;
		}
		return false;
	}
	int indexFromPtr(const(T)* it) const pure @safe
	in(it >= data && it < data + size){
		const ptrdiff_t off = it - data;
		return cast(int)off;
	}
}

extern(C++) struct ImGuiStyle{
	float alpha = 1f;
	float disabledAlpha = 0.6f;
	ImVec2 windowPadding = ImVec2(8, 8);
	float windowRounding = 0f;
	float windowBorderSize = 1f;
	ImVec2 windowMinSize = ImVec2(32, 32);
	ImVec2 windowTitleAlign = ImVec2(0f, 0.5f);
	ImGuiDir_ windowMenuButtonPosition = ImGuiDir.left;
	float childRounding = 0f;
	float childBorderSize = 1f;
	float popupRounding = 0f;
	float popupBorderSize = 1f;
	ImVec2 framePadding = ImVec2(4, 3);
	float frameRounding = 0f;
	float frameBorderSize = 0f;
	ImVec2 itemSpacing = ImVec2(8, 4);
	ImVec2 itemInnerSpacing = ImVec2(4, 4);
	ImVec2 cellPadding = ImVec2(4, 2);
	ImVec2 touchExtraPadding = ImVec2(0, 0);
	float indentSpacing = 21f;
	float columnsMinSpacing = 6f;
	float scrollbarSize = 14f;
	float scrollbarRounding = 9f;
	float grabMinSize = 12f;
	float grabRounding = 0f;
	float logSliderDeadzone = 4f;
	float tabRounding = 4f;
	float tabBorderSize = 0f;
	float tabMinWidthForCloseButton = 0f;
	float tabBarBorderSize = 1f;
	float tableAngledHeadersAngle = 35.0f * (IM_PI / 180.0f);
	ImGuiDir_ colorButtonPosition = ImGuiDir.right;
	alias colourButtonPosition = colorButtonPosition;
	ImVec2 buttonTextAlign = ImVec2(0.5f, 0.5f);
	ImVec2 SelectableTextAlign = ImVec2(0f, 0f);
	float separatorTextBorderSize = 3f;
	ImVec2 separatorTextAlign = ImVec2(0f, 0.5f);
	ImVec2 separatorTextPadding = ImVec2(20f, 3f);
	ImVec2 displayWindowPadding = ImVec2(19, 19);
	ImVec2 displaySafeAreaPadding = ImVec2(3, 3);
	float mouseCursorScale = 1f;
	bool antiAliasedLines = true;
	bool antiAliasedLinesUseTex = true;
	bool antiAliasedFill = true;
	float curveTessellationTol = 1.25f;
	float circleTessellationMaxError = 0.3f;
	ImVec4[ImGuiCol.COUNT] colors;
	alias colours = colors;
	
	float hoverStationaryDelay = 0.15f;
	float hoverDelayShort = 0.15f;
	float hoverDelayNormal = 0.4f;
	ImGuiHoveredFlags_ hoverFlagsForTooltipMouse = ImGuiHoveredFlags.stationary | ImGuiHoveredFlags.delayShort | ImGuiHoveredFlags.allowWhenDisabled;
	ImGuiHoveredFlags_ hoverFlagsForTooltipNav = ImGuiHoveredFlags.noSharedDelay | ImGuiHoveredFlags.delayNormal | ImGuiHoveredFlags.allowWhenDisabled;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{this}, q{}, ext: `C++`},
			{q{void}, q{ScaleAllSizes}, q{float scaleFactor}, ext: `C++`, pubIden: "scaleAllSizes"},
		];
		return ret;
	}()));
}

extern(C++) struct ImGuiKeyData{
	bool down;
	float downDuration;
	float downDurationPrev;
	float analogValue;
}

extern(C++) struct ImGuiIO{
	ImGuiConfigFlags_ configFlags = 0;
	ImGuiBackendFlags_ backendFlags = 0;
	ImVec2 displaySize = ImVec2(-1.0f, -1.0f);
	float deltaTime = 1f/60f;
	float iniSavingRate = 5f;
	const(char)* iniFilename = "imgui.ini";
	const(char)* logFilename = "imgui_log.txt";
	void* userData = null;
	
	ImFontAtlas* fonts = null;
	float fontGlobalScale = 1f;
	bool fontAllowUserScaling = false;
	ImFont* fontDefault = null;
	ImVec2 displayFramebufferScale = ImVec2(1f, 1f);
	
	bool mouseDrawCursor = false;
	bool configMacOSXBehaviors = (){ version(OSX) return true; else return false; }();
	bool configInputTrickleEventQueue = true;
	bool configInputTextCursorBlink = true;
	bool configInputTextEnterKeepActive = false;
	bool configDragClickToInputText = false;
	bool configWindowsResizeFromEdges = true;
	bool configWindowsMoveFromTitleBarOnly;
	float configMemoryCompactTimer = 60f;
	
	float mouseDoubleClickTime = 0.3f;
	float mouseDoubleClickMaxDist = 6f;
	float mouseDragThreshold = 6f;
	float keyRepeatDelay = 0.275f;
	float keyRepeatRate = 0.05f;
	
	bool configDebugBeginReturnValueOnce = false;
	bool configDebugBeginReturnValueLoop = false;
	
	bool configDebugIgnoreFocusLoss = false;
	bool configDebugIniSettings = false;
	
	const(char)* backendPlatformName = null;
	const(char)* backendRendererName = null;
	void* backendPlatformUserData = null;
	void* backendRendererUserData = null;
	void* backendLanguageUserData = null;
	
	extern(C++) const(char)* function(void* userData) getClipboardTextFn;
	extern(C++) void function(void* userData, const(char)* text) setClipboardTextFn;
	void* clipboardUserData;
	
	extern(C++) void function(ImGuiViewport* viewport, ImGuiPlatformImeData* data) setPlatformIMEDataFn;
	
	ImWchar platformLocaleDecimalPoint = '.';
	
	bool wantCaptureMouse;
	bool wantCaptureKeyboard;
	bool wantTextInput;
	bool wantSetMousePos;
	bool wantSaveIniSettings;
	bool navActive;
	bool navVisible;
	float framerate;
	int metricsRenderVertices;
	int metricsRenderIndices;
	int metricsRenderWindows;
	int metricsActiveWindows;
	ImVec2 mouseDelta;
	
	ImGuiContext* ctx;
	
	ImVec2 mousePos = ImVec2(float.max, -float.max);
	bool[5] mouseDown;
	float mouseWheel;
	float mouseWheelH;
	ImGuiMouseSource_ mouseSource;
	bool keyCtrl;
	bool keyShift;
	bool keyAlt;
	bool keySuper;
	
	ImGuiKeyChord keyMods;
	ImGuiKeyData[ImGuiKey.keysData_SIZE] keysData;
	bool wantCaptureMouseUnlessPopupClose;
	ImVec2 mousePosPrev = ImVec2(float.max, -float.max);
	ImVec2[5] mouseClickedPos;
	double[5] mouseClickedTime;
	bool[5] mouseClicked;
	bool[5] mouseDoubleClicked;
	ushort[5] mouseClickedCount;
	ushort[5] mouseClickedLastCount;
	bool[5] mouseReleased;
	bool[5] mouseDownOwned;
	bool[5] mouseDownOwnedUnlessPopupClose;
	bool mouseWheelRequestAxisSwap;
	float[5] mouseDownDuration;
	float[5] mouseDownDurationPrev;
	float[5] mouseDragMaxDistanceSqr;
	float penPressure;
	bool appFocusLost;
	bool appAcceptingEvents = true;
	byte backendUsingLegacyKeyArrays = cast(byte)-1;
	bool backendUsingLegacyNavInputArray = true;
	wchar inputQueueSurrogate;
	ImVector!ImWchar inputQueueCharacters;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{this}, q{}, ext: `C++`},
			{q{void}, q{ScaleAllSizes}, q{float scaleFactor}, ext: `C++`, pubIden: "scaleAllSizes"},
			{q{void}, q{AddKeyEvent}, q{ImGuiKey_ key, bool down}, ext: `C++`, pubIden: "addKeyEvent"},
			{q{void}, q{AddKeyAnalogEvent}, q{ImGuiKey_ key, bool down, float v}, ext: `C++`, pubIden: "addKeyAnalogEvent"},
			{q{void}, q{AddMousePosEvent}, q{float x, float y}, ext: `C++`, pubIden: "addMousePosEvent"},
			{q{void}, q{AddMouseButtonEvent}, q{int button, bool down}, ext: `C++`, pubIden: "addMouseButtonEvent"},
			{q{void}, q{AddMouseWheelEvent}, q{float wheelX, float wheelY}, ext: `C++`, pubIden: "addMouseWheelEvent"},
			{q{void}, q{AddMouseSourceEvent}, q{ImGuiMouseSource_ source}, ext: `C++`, pubIden: "addMouseSourceEvent"},
			{q{void}, q{AddFocusEvent}, q{bool focused}, ext: `C++`, pubIden: "addFocusEvent"},
			{q{void}, q{AddInputCharacter}, q{uint c}, ext: `C++`, pubIden: "addInputCharacter"},
			{q{void}, q{AddInputCharacterUTF16}, q{wchar c}, ext: `C++`, pubIden: "addInputCharacterUTF16"},
			{q{void}, q{AddInputCharactersUTF8}, q{const(char)* str}, ext: `C++`, pubIden: "addInputCharactersUTF8"},
			
			{q{void}, q{SetKeyEventNativeData}, q{ImGuiKey_ key, int nativeKeycode, int nativeScancode, int nativeLegacyIndex=-1}, ext: `C++`, pubIden: "setKeyEventNativeData"},
			{q{void}, q{SetAppAcceptingEvents}, q{bool acceptingEvents}, ext: `C++`, pubIden: "setAppAcceptingEvents"},
			{q{void}, q{ClearEventsQueue}, q{}, ext: `C++`, pubIden: "clearEventsQueue"},
			{q{void}, q{ClearInputKeys}, q{}, ext: `C++`, pubIden: "clearInputKeys"},
		];
		return ret;
	}()));
}

extern(C++) struct ImGuiInputTextCallbackData{
	ImGuiContext* ctx = null;
	ImGuiInputTextFlags_ eventFlag = 0;
	ImGuiInputTextFlags_ flags = 0;
	void* userData = null;
	
	ImWchar eventChar = 0;
	ImGuiKey_ eventKey = 0;
	char* buf = null;
	int bufTextLen = 0;
	int bufSize = 0;
	bool bufDirty = false;
	int cursorPos = 0;
	int selectionStart = 0;
	int selectionEnd = 0;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{this}, q{}, ext: `C++`},
			{q{void}, q{ScaleAllSizes}, q{float scaleFactor}, ext: `C++`, pubIden: "scaleAllSizes"},
			{q{void}, q{DeleteChars}, q{int pos, int bytesCount}, ext: `C++`, pubIden: "deleteChars"},
			{q{void}, q{InsertChars}, q{int pos, const(char)* text, const(char)* textEnd=null}, ext: `C++`, pubIden: "insertChars"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	void selectAll() pure @safe{
		selectionStart = 0;
		selectionEnd = bufTextLen;
	}
	void clearSelection() pure @safe{ selectionStart = selectionEnd = bufTextLen; }
	bool hasSelection() const pure @safe => selectionStart != selectionEnd;
}

extern(C++) struct ImGuiSizeCallbackData{
	void* userData;
	ImVec2 pos;
	ImVec2 currentSize;
	ImVec2 desiredSize;
}

extern(C++) struct ImGuiPayload{
	void* data = null;
	int dataSize = 0;
	
	ImGuiID sourceID = 0;
	ImGuiID sourceParentID = 0;
	int dataFrameCount = -1;
	char[32 + 1] dataType;
	bool preview = false;
	bool delivery = false;
	
	nothrow @nogc:
	this(int _) pure{ clear(); }
	void clear() pure{
		sourceID = sourceParentID = 0;
		data = null;
		dataSize = 0;
		memset(cast(void*)dataType.ptr, 0, dataType.sizeof);
		dataFrameCount = -1;
		preview = delivery = false;
	}
	bool isDataType(const(char)* type) const pure => dataFrameCount != -1 && strcmp(type, dataType.ptr) == 0;
	bool isPreview() const pure @safe => preview;
	bool isDelivery() const pure @safe => delivery;
}

extern(C++) struct ImGuiTableColumnSortSpecs{
	ImGuiID columnUserID = 0;
	short columnIndex = 0;
	short sortOrder = 0;
	ImGuiSortDirection_ sortDirection = 0; //NOTE: 8 bit-field
}
static assert(ImGuiTableColumnSortSpecs.sizeof == 12);

extern(C++) struct ImGuiTableSortSpecs{
	const(ImGuiTableColumnSortSpecs)* specs = null;
	int specsCount = 0;
	bool specsDirty = 0;
}

enum IM_UNICODE_CODEPOINT_INVALID = 0xFFFD;
version(ImGui_WChar32){
	enum IM_UNICODE_CODEPOINT_MAX = 0x10FFFF;
}else{
	enum IM_UNICODE_CODEPOINT_MAX = 0xFFFF;
}

extern(C++) struct ImGuiOnceUponAFrame{
	int refFrame = -1; //NOTE: originally delcared as `mutable`
	
	nothrow @nogc:
	T opCast(T: bool)() const{
		int currentFrame = GetFrameCount();
		if(refFrame == currentFrame) return false;
		refFrame = currentFrame;
		return true;
	}
}

extern(C++) struct ImGuiTextFilter{
	extern(C++) struct ImGuiTextRange{
		const(char)* b = null;
		const(char)* e = null;
		
		extern(D) mixin(joinFnBinds((){
			FnBind[] ret = [
				{q{void}, q{this}, q{}, ext: `C++`},
				{q{void}, q{Split}, q{char separator, ImVector!(ImGuiTextRange)* out_}, ext: `C++`, memAttr: q{const}, pubIden: "split"},
			];
			return ret;
		}()));
		
		nothrow @nogc:
		bool empty() const pure @safe => b == e;
	}
	ImGuiTextRange range;
	char[256] inputBuf;
	ImVector!ImGuiTextRange filters;
	int countGrep;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{this}, q{const(char)* defaultFilter}, ext: `C++`},
			{q{bool}, q{Draw}, q{const(char)* label="Filter (inc,-exc)", float width=0f}, ext: `C++`, pubIden: "draw"},
			{q{bool}, q{PassFilter}, q{const(char)* text, const(char)* textEnd=null}, ext: `C++`, memAttr: q{const}, pubIden: "passFilter"},
			{q{void}, q{Build}, q{}, ext: `C++`, pubIden: "build"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	void clear(){
		inputBuf[0] = 0;
		build();
	}
	bool isActive() const pure @safe => !filters.empty();
}

extern(C++) struct ImGuiTextBuffer{
	ImVector!char buf;
	extern static __gshared char[1] emptyString;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{append}, q{const(char)* str, const(char)* strEnd=null}, ext: `C++`},
			{q{void}, q{appendf}, q{const(char)* fmt, ...}, ext: `C++`},
			{q{void}, q{appendfv}, q{const(char)* fmt, va_list args}, ext: `C++`},
		];
		return ret;
	}()));

	nothrow @nogc:
	char opIndex(int i) const pure @safe in(buf.data !is null) => buf.data[i];
	const(char)* begin() const pure @safe => buf.data ? &buf.front() : emptyString.ptr;
	const(char)* end() const pure @safe => buf.data ? &buf.back() : emptyString.ptr;
	int size() const pure @safe => buf.size ? buf.size - 1 : 0;
	bool empty() const pure @safe => buf.size <= 1;
	void clear(){ buf.clear(); }
	void reserve(int capacity){ buf.reserve(capacity); }
	const(char)* cStr() const pure @safe => buf.data ? buf.data : emptyString.ptr;
}

extern(C++) struct ImGuiStorage{
	extern(C++) struct ImGuiStoragePair{
		ImGuiID key;
		union _Val{
			int i;
			float f;
			void* p;
		}
		_Val val;
		
		nothrow @nogc:
		this(ImGuiID _key, int _val) pure @safe{
			key = _key;
			val.i = _val;
		}
		this(ImGuiID _key, float _val) pure @safe{
			key = _key;
			val.f = _val;
		}
		this(ImGuiID _key, void* _val) pure @safe{
			key = _key;
			val.p = _val;
		}
	}
	ImVector!ImGuiStoragePair data;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{int}, q{GetInt}, q{ImGuiID key, int defaultVal=0}, ext: `C++`, memAttr: q{const}, pubIden: "getInt"},
			{q{void}, q{SetInt}, q{ImGuiID key, int val}, ext: `C++`, pubIden: "setInt"},
			{q{bool}, q{GetBool}, q{ImGuiID key, bool defaultVal=false}, ext: `C++`, memAttr: q{const}, pubIden: "getBool"},
			{q{void}, q{SetBool}, q{ImGuiID key, bool val}, ext: `C++`, pubIden: "setBool"},
			{q{float}, q{GetFloat}, q{ImGuiID key, float defaultVal=0f}, ext: `C++`, memAttr: q{const}, pubIden: "getFloat"},
			{q{void}, q{SetFloat}, q{ImGuiID key, float val}, ext: `C++`, pubIden: "setFloat"},
			{q{void*}, q{GetVoidPtr}, q{ImGuiID key}, ext: `C++`, memAttr: q{const}, pubIden: "getVoidPtr"},
			{q{void}, q{SetVoidPtr}, q{ImGuiID key, void* val}, ext: `C++`, pubIden: "setVoidPtr"},
			
			{q{int*}, q{GetIntRef}, q{ImGuiID key, int defaultVal=0}, ext: `C++`, pubIden: "getIntRef"},
			{q{bool*}, q{GetBoolRef}, q{ImGuiID key, bool defaultVal=false}, ext: `C++`, pubIden: "getBoolRef"},
			{q{float*}, q{GetFloatRef}, q{ImGuiID key, float defaultVal=0f}, ext: `C++`, pubIden: "getFloatRef"},
			{q{void**}, q{GetVoidPtrRef}, q{ImGuiID key, void* defaultVal=null}, ext: `C++`, pubIden: "getVoidPtrRef"},
			
			{q{void}, q{BuildSortByKey}, q{}, ext: `C++`, pubIden: "buildSortByKey"},
			{q{void}, q{SetAllInt}, q{int val}, ext: `C++`, pubIden: "setAllInt"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	void clear(){ data.clear(); }
}

extern(C++) struct ImGuiListClipper{
	ImGuiContext* ctx;
	int displayStart;
	int displayEnd;
	int itemsCount;
	float itemsHeight;
	float startPosY;
	void* tempData;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{this}, q{}, ext: `C++`},
			{q{void}, q{~this}, q{}, ext: `C++`},
			{q{void}, q{Begin}, q{int itemsCount, float itemsHeight=-1f}, ext: `C++`, pubIden: "begin"},
			{q{void}, q{End}, q{}, ext: `C++`, pubIden: "end"},
			{q{bool}, q{Step}, q{}, ext: `C++`, pubIden: "step"},
			
			{q{void}, q{IncludeItemsByIndex}, q{int itemBegin, int itemEnd}, ext: `C++`, pubIden: "includeItemsByIndex"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	void includeItemByIndex(int itemIndex){ includeItemsByIndex(itemIndex, itemIndex + 1); }
}

version(ImGui_BGRAPackedCol)
enum{
	IM_COL32_A_SHIFT = 24,
	IM_COL32_G_SHIFT = 8,
	IM_COL32_B_SHIFT = 0,
}
else
enum{
	IM_COL32_R_SHIFT = 0,
	IM_COL32_G_SHIFT = 8,
	IM_COL32_B_SHIFT = 16,
}
enum{
	IM_COL32_A_SHIFT = 24,
	IM_COL32_A_MASK = 0xFF000000,
}
uint IM_COL32(uint r, uint g, uint b, uint a) nothrow @nogc pure @safe{
	return (cast(uint)(a)<<IM_COL32_A_SHIFT) | (cast(uint)(b)<<IM_COL32_B_SHIFT) | (cast(uint)(g)<<IM_COL32_G_SHIFT) | (cast(uint)(r)<<IM_COL32_R_SHIFT);
}
enum IM_COL32_WHITE = IM_COL32(255,255,255,255);
enum IM_COL32_BLACK = IM_COL32(0,0,0,255);
enum IM_COL32_BLACK_TRANS = IM_COL32(0,0,0,0);

extern(C++) struct ImColor{
	ImVec4 value;
	
	nothrow @nogc:
	this(float r, float g, float b, float a=1f) pure @safe{ value = ImVec4(r, g, b, a); }
	this(const ImVec4 col) pure @safe{ value = col; }
	this(int r, int g, int b, int a=255) pure @safe{
		value = ImVec4(
			cast(float)r * (1f / 255f),
			cast(float)g * (1f / 255f),
			cast(float)b * (1f / 255f),
			cast(float)a * (1f / 255f)
		);
	}
	this(uint rgba) pure @safe{
		value = ImVec4(
			cast(float)((rgba >> IM_COL32_R_SHIFT) & 0xFF) * (1f / 255f),
			cast(float)((rgba >> IM_COL32_G_SHIFT) & 0xFF) * (1f / 255f),
			cast(float)((rgba >> IM_COL32_B_SHIFT) & 0xFF) * (1f / 255f),
			cast(float)((rgba >> IM_COL32_A_SHIFT) & 0xFF) * (1f / 255f),
		);
	}
	uint opCast(T: uint)() const => ColorConvertFloat4ToU32(value);
	ImVec4 opCast(T: ImVec4)() const pure @safe => value;
	void setHSV(float h, float s, float v, float a=1f){
		ColorConvertHSVtoRGB(h, s, v, value.x, value.y, value.z);
		value.w = a;
	}
	static ImColor HSV(float h, float s, float v, float a=1f){
		float r, g, b;
		ColorConvertHSVtoRGB(h, s, v, r, g, b);
		return ImColor(r, g, b, a);
	}
}
alias ImColour = ImColor;

enum IM_DRAWLIST_TEX_LINES_WIDTH_MAX = 63;

alias ImDrawCallback = extern(C++) void function(const(ImDrawList)* parentList, const(ImDrawCmd)* cmd);

enum ImDrawCallback ImDrawCallback_ResetRenderState = cast(ImDrawCallback)-8;

extern(C++) struct ImDrawCmd{
	ImVec4 clipRect = ImVec4(0, 0, 0, 0);
	ImTextureID textureID = null;
	uint vtxOffset = 0;
	uint idxOffset = 0;
	uint elemCount = 0;
	ImDrawCallback userCallback = null;
	void* userCallbackData = null;
	
	nothrow @nogc:
	ImTextureID getTexID() const pure @safe => cast(ImTextureID)textureID;
}

extern(C++) struct ImDrawVert{
	ImVec2 pos;
	ImVec2 uv;
	uint col;
}

extern(C++) struct ImDrawCmdHeader{
	ImVec4 clipRect;
	ImTextureID textureID;
	uint vtxOffset;
}

extern(C++) struct ImDrawChannel{
	ImVector!ImDrawCmd _cmdBuffer;
	ImVector!ImDrawIdx _idxBuffer;
}

extern(C++) struct ImDrawListSplitter{
	int _current = 0;
	int _count = 0;
	ImVector!ImDrawChannel _channels;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ClearFreeMemory}, q{}, pubIden: "clearFreeMemory"},
			{q{void}, q{Split}, q{ImDrawList* drawList, int count}, pubIden: "split"},
			{q{void}, q{Merge}, q{ImDrawList* drawList}, pubIden: "merge"},
			{q{void}, q{SetCurrentChannel}, q{ImDrawList* drawList, int channelIdx}, pubIden: "setCurrentChannel"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	~this(){ clearFreeMemory(); }
	void clear() pure @safe{
		_current = 0;
		_count = 1;
	}
}

alias ImDrawFlags_ = int;
enum ImDrawFlags: ImDrawFlags_{
	none                     = 0,
	closed                   = 1 << 0,
	roundCornersTopLeft      = 1 << 4,
	roundCornersTopRight     = 1 << 5,
	roundCornersBottomLeft   = 1 << 6,
	roundCornersBottomRight  = 1 << 7,
	roundCornersNone         = 1 << 8,
	roundCornersTop          = roundCornersTopLeft | roundCornersTopRight,
	roundCornersBottom       = roundCornersBottomLeft | roundCornersBottomRight,
	roundCornersLeft         = roundCornersBottomLeft | roundCornersTopLeft,
	roundCornersRight        = roundCornersBottomRight | roundCornersTopRight,
	roundCornersAll          = roundCornersTopLeft | roundCornersTopRight | roundCornersBottomLeft | roundCornersBottomRight,
	roundCornersDefault      = roundCornersAll,
	roundCornersMask         = roundCornersAll | roundCornersNone,
}

alias ImDrawListFlags_ = int;
enum ImDrawListFlags: ImDrawListFlags_{
	none                    = 0,
	antiAliasedLines        = 1 << 0,
	antiAliasedLinesUseTex  = 1 << 1,
	antiAliasedFill         = 1 << 2,
	allowVtxOffset          = 1 << 3,
}

extern(C++) struct ImDrawList{
	ImVector!ImDrawCmd cmdBuffer;
	ImVector!ImDrawIdx idxBuffer;
	ImVector!ImDrawVert vtxBuffer;
	ImDrawListFlags_ flags = 0;
	
	uint _vtxCurrentIdx = 0;
	ImDrawListSharedData* _data = null;
	const(char)* _ownerName = null;
	ImDrawVert* _vtxWritePtr = null;
	ImDrawIdx* _idxWritePtr = null;
	ImVector!ImVec4 _clipRectStack;
	ImVector!ImTextureID _textureIDStack;
	ImVector!ImVec2 _path;
	ImDrawCmdHeader _cmdHeader = {clipRect: ImVec4(0,0,0,0), textureID: null, vtxOffset: 0};
	ImDrawListSplitter _splitter;
	float _fringeScale = 0;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{PushClipRect}, q{in ImVec2 clipRectMin, in ImVec2 clipRectMax, bool intersectWithCurrentClipRect=false}, ext: `C++`, pubIden: "pushClipRect"},
			{q{void}, q{PushClipRectFullScreen}, q{}, ext: `C++`, pubIden: "pushClipRectFullScreen"},
			{q{void}, q{PopClipRect}, q{}, ext: `C++`, pubIden: "popClipRect"},
			{q{void}, q{PushTextureID}, q{ImTextureID textureID}, ext: `C++`, pubIden: "pushTextureID"},
			{q{void}, q{PopTextureID}, q{}, ext: `C++`, pubIden: "popTextureID"},
			
			{q{void}, q{AddLine}, q{in ImVec2 p1, in ImVec2 p2, uint col, float thickness=1f}, ext: `C++`, pubIden: "addLine"},
			{q{void}, q{AddRect}, q{in ImVec2 pMin, in ImVec2 pMax, uint col, float rounding=0f, ImDrawFlags_ flags=0, float thickness=1f}, ext: `C++`, pubIden: "addRect"},
			{q{void}, q{AddRectFilled}, q{in ImVec2 pMin, in ImVec2 pMax, uint col, float rounding=0f, ImDrawFlags_ flags=0}, ext: `C++`, pubIden: "addRectFilled"},
			{q{void}, q{AddRectFilledMultiColor}, q{in ImVec2 pMin, in ImVec2 pMax, uint colUprLeft, uint colUprRight, uint colBotRight, uint coklBotLeft}, ext: `C++`, pubIden: "addRectFilledMultiColor", aliases: ["addRectFilledMultiColour"]},
			{q{void}, q{AddQuad}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, uint col, float thickness=1f}, ext: `C++`, pubIden: "addQuad"},
			{q{void}, q{AddQuadFilled}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, uint col}, ext: `C++`, pubIden: "addQuadFilled"},
			{q{void}, q{AddTriangle}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, uint col, float thickness=1f}, ext: `C++`, pubIden: "addTriangle"},
			{q{void}, q{AddTriangleFilled}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, uint col}, ext: `C++`, pubIden: "addTriangleFilled"},
			{q{void}, q{AddCircle}, q{in ImVec2 centre, float radius, uint col, int numSegments=0, float thickness=1f}, ext: `C++`, pubIden: "addCircle"},
			{q{void}, q{AddCircleFilled}, q{in ImVec2 centre, float radius, uint col, int numSegments=0}, ext: `C++`, pubIden: "addCircleFilled"},
			{q{void}, q{AddNgon}, q{in ImVec2 centre, float radius, uint col, int numSegments, float thickness=1f}, ext: `C++`, pubIden: "addNgon"},
			{q{void}, q{AddNgonFilled}, q{in ImVec2 centre, float radius, uint col, int numSegments}, ext: `C++`, pubIden: "addNgonFilled"},
			{q{void}, q{AddEllipse}, q{in ImVec2 centre, float radiusX, float radiusY, uint col, float rot=0f, int numSegments = 0, float thickness=1f}, ext: `C++`, pubIden: "addEllipse"},
			{q{void}, q{AddEllipseFilled}, q{in ImVec2 centre, float radiusX, float radiusY, uint col, float rot=0f, int numSegments = 0}, ext: `C++`, pubIden: "addEllipseFilled"},
			{q{void}, q{AddText}, q{in ImVec2 pos, uint col, const(char)* textBegin, const(char)* textEnd=null}, ext: `C++`, pubIden: "addText"},
			{q{void}, q{AddText}, q{const(ImFont)* font, float fontSize, in ImVec2 pos, uint col, const(char)* textBegin, const(char)* textEnd=null, float wrapWidth=0f, const(ImVec4)* cpuFineClipRect=null}, ext: `C++`, pubIden: "addText"},
			{q{void}, q{AddPolyline}, q{const(ImVec2)* points, int numPoints, uint col, ImDrawFlags_ flags, float thickness}, ext: `C++`, pubIden: "addPolyline"},
			{q{void}, q{AddConvexPolyFilled}, q{const(ImVec2)* points, int numPoints, uint col}, ext: `C++`, pubIden: "addConvexPolyFilled"},
			{q{void}, q{AddBezierCubic}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, uint col, float thickness, int numSegments=0}, ext: `C++`, pubIden: "addBezierCubic"},
			{q{void}, q{AddBezierQuadratic}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, uint col, float thickness, int numSegments=0}, ext: `C++`, pubIden: "addBezierQuadratic"},
			
			{q{void}, q{AddImage}, q{ImTextureID userTextureID, in ImVec2 pMin, in ImVec2 pMax, in ImVec2 uvMin=ImVec2(0,0), in ImVec2 uvMax=ImVec2(1,1), uint col=IM_COL32_WHITE}, ext: `C++`, pubIden: "addImage"},
			{q{void}, q{AddImageQuad}, q{ImTextureID userTextureID, in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, in ImVec2 uv1=ImVec2(0,0), in ImVec2 uv2=ImVec2(1,0), in ImVec2 uv3=ImVec2(1,1), in ImVec2 uv4=ImVec2(0,1), uint col=IM_COL32_WHITE}, ext: `C++`, pubIden: "addImageQuad"},
			{q{void}, q{AddImageRounded}, q{ImTextureID userTextureID, in ImVec2 pMin, in ImVec2 pMax, in ImVec2 uvMin, in ImVec2 uvMax, uint col, float rounding, ImDrawFlags_ flags=0}, ext: `C++`, pubIden: "addImageRounded"},
			
			{q{void}, q{PathArcTo}, q{in ImVec2 centre, float radius, float aMin, float aMax, int num_segments=0}, ext: `C++`, pubIden: "pathArcTo"},
			{q{void}, q{PathArcToFast}, q{in ImVec2 centre, float radius, int aMinOf12, int aMaxOf12}, ext: `C++`, pubIden: "pathArcToFast"},
			{q{void}, q{PathEllipticalArcTo}, q{in ImVec2 centre, float radiusX, float radiusY, float rot, float aMin, float aMax, int numSegments=0}, ext: `C++`, pubIden: "pathEllipticalArcTo"},
			{q{void}, q{PathBezierCubicCurveTo}, q{in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, int numSegments=0}, ext: `C++`, pubIden: "pathBezierCubicCurveTo"},
			{q{void}, q{PathBezierQuadraticCurveTo}, q{in ImVec2 p2, in ImVec2 p3, int numSegments=0}, ext: `C++`, pubIden: "pathBezierQuadraticCurveTo"},
			{q{void}, q{PathRect}, q{in ImVec2 rectMin, in ImVec2 rectMax, float rounding=0f, ImDrawFlags_ flags=0}, ext: `C++`, pubIden: "pathRect"},
			
			{q{void}, q{AddCallback}, q{ImDrawCallback callback, void* callbackData}, ext: `C++`, pubIden: "addCallback"},
			{q{void}, q{AddDrawCmd}, q{}, ext: `C++`, pubIden: "addDrawCmd"},
			{q{ImDrawList*}, q{CloneOutput}, q{}, ext: `C++`, memAttr: q{const}, pubIden: "cloneOutput"},
			
			{q{void}, q{PrimReserve}, q{int idxCount, int vtxCount}, ext: `C++`, pubIden: "primReserve"},
			{q{void}, q{PrimUnreserve}, q{int idxCount, int vtxCount}, ext: `C++`, pubIden: "primUnreserve"},
			{q{void}, q{PrimRect}, q{in ImVec2 a, in ImVec2 b, uint col}, ext: `C++`, pubIden: "primRect"},
			{q{void}, q{PrimRectUV}, q{in ImVec2 a, in ImVec2 b, in ImVec2 uvA, in ImVec2 uvB, uint col}, ext: `C++`, pubIden: "primRectUV"},
			{q{void}, q{PrimQuadUV}, q{in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 d, in ImVec2 uvA, in ImVec2 uvB, in ImVec2 uvC, in ImVec2 uvD, uint col}, ext: `C++`, pubIden: "primQuadUV"},
			
			{q{void}, q{_ResetForNewFrame}, q{}, ext: `C++`, pubIden: "ResetForNewFrame"},
			{q{void}, q{_ClearFreeMemory}, q{}, ext: `C++`, pubIden: "ClearFreeMemory"},
			{q{void}, q{_PopUnusedDrawCmd}, q{}, ext: `C++`, pubIden: "PopUnusedDrawCmd"},
			{q{void}, q{_TryMergeDrawCmds}, q{}, ext: `C++`, pubIden: "TryMergeDrawCmds"},
			{q{void}, q{_OnChangedClipRect}, q{}, ext: `C++`, pubIden: "OnChangedClipRect"},
			{q{void}, q{_OnChangedTextureID}, q{}, ext: `C++`, pubIden: "OnChangedTextureID"},
			{q{void}, q{_OnChangedVtxOffset}, q{}, ext: `C++`, pubIden: "OnChangedVtxOffset"},
			{q{int}, q{_CalcCircleAutoSegmentCount}, q{float radius}, ext: `C++`, memAttr: q{const}, pubIden: "CalcCircleAutoSegmentCount"},
			{q{void}, q{_PathArcToFastEx}, q{in ImVec2 centre, float radius, int aMinSample, int aMaxSample, int aStep}, ext: `C++`, pubIden: "PathArcToFastEx"},
			{q{void}, q{_PathArcToN}, q{in ImVec2 centre, float radius, float aMin, float aMax, int numSegments}, ext: `C++`, pubIden: "PathArcToN"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	this(ImDrawListSharedData* sharedData){ _data = sharedData; }
	~this(){ _clearFreeMemory(); }
	
	ImVec2 getClipRectMin() const{
		const(ImVec4)* cr = &_clipRectStack.back();
		return ImVec2(cr.x, cr.y);
	}
	ImVec2 getClipRectMax() const{
		const(ImVec4)* cr = &_clipRectStack.back();
		return ImVec2(cr.z, cr.w);
	}
	
	void pathClear() pure @safe{ _path.size = 0; }
	void pathLineTo(const ImVec2 pos){ _path.pushBack(pos); }
	void pathLineToMergeDuplicate(const ImVec2 pos){
		if(_path.size == 0 || memcmp(&_path.data[_path.size - 1], &pos, 8) != 0){
			_path.pushBack(pos);
		}
	}
	void pathFillConvex(uint col){
		addConvexPolyFilled(_path.data, _path.size, col);
		_path.size = 0;
	}
	void pathStroke(uint col, ImDrawFlags_ flags=0, float thickness=1f){
		addPolyline(_path.data, _path.size, col, flags, thickness);
		_path.size = 0;
	}
	
	void channelsSplit(int count){ _splitter.split(&this, count); }
	void channelsMerge(){ _splitter.merge(&this); }
	void channelsSetCurrent(int n){ _splitter.setCurrentChannel(&this, n); }
	
	void primWriteVtx(const ImVec2 pos, const ImVec2 uv, uint col){
		_vtxWritePtr.pos = pos;
		_vtxWritePtr.uv = uv;
		_vtxWritePtr.col = col;
		_vtxWritePtr++;
		_vtxCurrentIdx++;
	}
	void primWriteIdx(ImDrawIdx idx){
		*_idxWritePtr = idx;
		_idxWritePtr++;
	}
	void primVtx(const ImVec2 pos, const ImVec2 uv, uint col){
		primWriteIdx(cast(ImDrawIdx)_vtxCurrentIdx);
		primWriteVtx(pos, uv, col);
	}
}

extern(C++) struct ImDrawData{
	bool valid = false;
	int cmdListsCount = 0;
	int totalIdxCount = 0;
	int totalVtxCount = 0;
	ImDrawList** cmdLists = null;
	ImVec2 displayPos = ImVec2(0,0);
	ImVec2 displaySize = ImVec2(0,0);
	ImVec2 framebufferScale = ImVec2(0,0);
	ImGuiViewport* ownerViewport;
	
	this(int _){ clear(); }
	
	void Clear();
    void AddDrawList(ImDrawList* drawList);
	void DeIndexAllBuffers();
	void ScaleClipRects(in ImVec2 fbScale);
}

extern(C++) struct ImFontConfig{
	void* fontData = null;
	int fontDataSize;
	bool fontDataOwnedByAtlas = true;
	int fontNo = 0;
	float sizePixels = 0f;
	int oversampleH = 3;
	int oversampleV = 1;
	bool pixelSnapH = false;
	ImVec2 glyphExtraSpacing;
	ImVec2 glyphOffset;
	const(ImWchar)* glyphRanges = null;
	float glyphMinAdvanceX = 0f;
	float glyphMaxAdvanceX = float.max;
	bool mergeMode = false;
	uint fontBuilderFlags = 0;
	float rasterizerMultiply = 1f;
	alias rasteriserMultiply = rasterizerMultiply;
	float rasterizerDensity = 1f;
	alias rasteriserDensity = rasterizerDensity;
	ImWchar ellipsisChar = cast(ImWchar)-1;
	
	char[40] name;
	ImFont* dstFont = null;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{this}, q{}, ext: `C++`},
		];
		return ret;
	}()));;
}

extern(C++) struct ImFontGlyph{
	uint data; //NOTE: this was originally 3 bitfields (2,2,30). Bit-ordering in bitfields isn't standard.
	float advanceX;
	float x0, y0, x1, y1;
	float u0, v0, u1, v1;
}

extern(C++) struct ImFontGlyphRangesBuilder{
	ImVector!uint usedChars;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{AddText}, q{const(char)* text, const(char)* textEnd=null}, ext: `C++`, pubIden: "addText"},
			{q{void}, q{AddRanges}, q{const(ImWchar)* ranges}, ext: `C++`, pubIden: "addRanges"},
			{q{void}, q{BuildRanges}, q{ImVector!(ImWchar)* outRanges}, ext: `C++`, pubIden: "buildRanges"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	this(int _){ clear(); }
	
	void clear(){
		int sizeInBytes = (IM_UNICODE_CODEPOINT_MAX + 1) / 8;
		usedChars.resize(sizeInBytes / cast(int)uint.sizeof);
		memset(UsedChars.Data, 0, cast(size_t)sizeInBytes);
	}
	bool getBit(size_t n) const pure @safe{
		int off = cast(int)(n >> 5);
		uint mask = 1U << (n & 31);
		return (usedChars[off] & mask) != 0;
	}
	void setBit(size_t n) pure @safe{
		int off = cast(int)(n >> 5);
		uint mask = 1U << (n & 31);
		usedChars[off] |= mask;
	}
	void addChar(ImWchar c) pure @safe{ setBit(c); }
}

extern(C++) struct ImFontAtlasCustomRect{
	ushort width = 0, height = 0;
	ushort x = 0xFFFF, y = 0xFFFF;
	uint glyphID = 0;
	float glyphAdvanceX = 0f;
	ImVec2 glyphOffset = ImVec2(0, 0);
	ImFont* font = null;
	
	nothrow @nogc:
	bool isPacked() const pure @safe => x != 0xFFFF;
}

alias ImFontAtlasFlags_ = int;
enum ImFontAtlasFlags: ImFontAtlasFlags_{
	none                = 0,
	noPowerOfTwoHeight  = 1 << 0,
	noMouseCursors      = 1 << 1,
	noBakedLines        = 1 << 2,
}

extern(C++) struct ImFontAtlas{
	ImFontAtlasFlags_ flags;
	ImTextureID texID;
	int texDesiredWidth;
	int texGlyphPadding;
	bool locked;
	void* userData;
	
	bool texReady;
	bool texPixelsUseColors;
	alias texPixelsUseColours = texPixelsUseColors;
	ubyte* texPixelsAlpha8;
	uint* texPixelsRGBA32;
	int texWidth;
	int texHeight;
	ImVec2 texUVScale;
	ImVec2 TexUVWhitepixel;
	ImVector!(ImFont*) fonts;
	ImVector!ImFontAtlasCustomRect customRects;
	ImVector!ImFontConfig configData;
	ImVec4[IM_DRAWLIST_TEX_LINES_WIDTH_MAX + 1] texUVLines;
	
	const(ImFontBuilderIO)* fontBuilderIO;
	uint fontBuilderFlags;
	
	int packIDMouseCursors;
	int packIDLines;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{this}, q{}, ext: `C++`},
			{q{void}, q{~this}, q{}, ext: `C++`},
			{q{ImFont*}, q{AddFont}, q{const(ImFontConfig)* fontCfg}, ext: `C++`, pubIden: "addFont"},
			{q{ImFont*}, q{AddFontDefault}, q{const(ImFontConfig)* fontCfg=null}, ext: `C++`, pubIden: "addFontDefault"},
			{q{ImFont*}, q{AddFontFromFileTTF}, q{const(char)* filename, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWchar)* glyphRanges=null}, ext: `C++`, pubIden: "addFontFromFileTTF"},
			{q{ImFont*}, q{AddFontFromMemoryTTF}, q{void* font_data, int fontDataSize, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWchar)* glyphRanges=null}, ext: `C++`, pubIden: "addFontFromMemoryTTF"},
			{q{ImFont*}, q{AddFontFromMemoryCompressedTTF}, q{const(void)* compressedFontData, int compressedFontDataSize, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWchar)* glyphRanges=null}, ext: `C++`, pubIden: "addFontFromMemoryCompressedTTF"},
			{q{ImFont*}, q{AddFontFromMemoryCompressedBase85TTF}, q{const(char)* compressedFontDataBase85, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWchar)* glyphRanges=null}, ext: `C++`, pubIden: "addFontFromMemoryCompressedBase85TTF"},
			{q{void}, q{ClearInputData}, q{}, ext: `C++`, pubIden: "clearInputData"},
			{q{void}, q{ClearTexData}, q{}, ext: `C++`, pubIden: "clearTexData"},
			{q{void}, q{ClearFonts}, q{}, ext: `C++`, pubIden: "clearFonts"},
			{q{void}, q{Clear}, q{}, ext: `C++`, pubIden: "clear"},
			
			{q{bool}, q{Build}, q{}, ext: `C++`, pubIden: "build"},
			{q{void}, q{GetTexDataAsAlpha8}, q{ubyte** outPixels, int* outWidth, int* outHeight, int* outBytesPerPixel=null}, ext: `C++`, pubIden: "getTexDataAsAlpha8"},
			{q{void}, q{GetTexDataAsRGBA32}, q{ubyte** outPixels, int* outWidth, int* outHeight, int* outBytesPerPixel=null}, ext: `C++`, pubIden: "getTexDataAsRGBA32"},
			
			{q{const(ImWchar)*}, q{GetGlyphRangesDefault}, q{}, ext: `C++`, pubIden: "getGlyphRangesDefault"},
			{q{const(ImWchar)*}, q{GetGlyphRangesGreek}, q{}, ext: `C++`, pubIden: "getGlyphRangesGreek"},
			{q{const(ImWchar)*}, q{GetGlyphRangesKorean}, q{}, ext: `C++`, pubIden: "getGlyphRangesKorean"},
			{q{const(ImWchar)*}, q{GetGlyphRangesJapanese}, q{}, ext: `C++`, pubIden: "getGlyphRangesJapanese"},
			{q{const(ImWchar)*}, q{GetGlyphRangesChineseFull}, q{}, ext: `C++`, pubIden: "getGlyphRangesChineseFull"},
			{q{const(ImWchar)*}, q{GetGlyphRangesChineseSimplifiedCommon}, q{}, ext: `C++`, pubIden: "getGlyphRangesChineseSimplifiedCommon"},
			{q{const(ImWchar)*}, q{GetGlyphRangesCyrillic}, q{}, ext: `C++`, pubIden: "getGlyphRangesCyrillic"},
			{q{const(ImWchar)*}, q{GetGlyphRangesThai}, q{}, ext: `C++`, pubIden: "getGlyphRangesThai"},
			{q{const(ImWchar)*}, q{GetGlyphRangesVietnamese}, q{}, ext: `C++`, pubIden: "getGlyphRangesVietnamese"},
			
			{q{int}, q{AddCustomRectRegular}, q{int width, int height}, ext: `C++`, pubIden: "addCustomRectRegular"},
			{q{int}, q{AddCustomRectFontGlyph}, q{ImFont* font, ImWchar id, int width, int height, float advanceX, in ImVec2 offset=ImVec2(0,0)}, ext: `C++`, pubIden: "addCustomRectFontGlyph"},
			
			{q{void}, q{CalcCustomRectUV}, q{const(ImFontAtlasCustomRect)* rect, ImVec2* outUvMin, ImVec2* outUvMax}, ext: `C++`, memAttr: q{const}, pubIden: "calcCustomRectUV"},
			{q{bool}, q{GetMouseCursorTexData}, q{ImGuiMouseCursor cursor, ImVec2* outOffset, ImVec2* outSize, ImVec2* outUvBorder, ImVec2* outUvFill}, ext: `C++`, pubIden: "getMouseCursorTexData"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	bool isBuilt() const => fonts.size > 0 && texReady;
	void setTexID(ImTextureID id){ texID = id; }
	ImFontAtlasCustomRect* GetCustomRectByIndex(int index) in(index >= 0) => &customRects[index];
}

extern(C++) struct ImFont{
	ImVector!float indexAdvanceX;
	float fallbackAdvanceX;
	float fontSize;
	
	ImVector!ImWchar indexLookup;
	ImVector!ImFontGlyph glyphs;
	const(ImFontGlyph)* fallbackGlyph;
	
	ImFontAtlas* containerAtlas;
	const(ImFontConfig)* configData;
	short configDataCount;
	ImWchar fallbackChar;
	ImWchar ellipsisChar;
	short ellipsisCharCount;
	float ellipsisWidth;
	float ellipsisCharStep;
	bool dirtyLookupTables;
	float scale;
	float ascent, descent;
	int metricsTotalSurface;
	ubyte[(IM_UNICODE_CODEPOINT_MAX + 1) / 4096 / 8] used4kPagesMap;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ScaleAllSizes}, q{float scaleFactor}, ext: `C++`, pubIden: "scaleAllSizes"},
			
			{q{void}, q{this}, q{}, ext: `C++`},
			{q{void}, q{~this}, q{}, ext: `C++`},
			{q{const(ImFontGlyph)*}, q{FindGlyph}, q{ImWchar c}, ext: `C++`, memAttr: q{const}, pubIden: "findGlyph"},
			{q{const(ImFontGlyph)*}, q{FindGlyphNoFallback}, q{ImWchar c}, ext: `C++`, memAttr: q{const}, pubIden: "findGlyphNoFallback"},
			
			{q{ImVec2}, q{CalcTextSizeA}, q{float size, float maxWidth, float wrapWidth, const(char)* textBegin, const(char)* textEnd=null, const(char)** remaining=null}, ext: `C++`, memAttr: q{const}, pubIden: "calcTextSizeA"},
			{q{const(char)*}, q{CalcWordWrapPositionA}, q{float scale, const(char)* text, const(char)* textEnd, float wrapWidth}, ext: `C++`, memAttr: q{const}, pubIden: "calcWordWrapPositionA"},
			{q{void}, q{RenderChar}, q{ImDrawList* drawList, float size, in ImVec2 pos, uint col, ImWchar c}, ext: `C++`, memAttr: q{const}, pubIden: "renderChar"},
			{q{void}, q{RenderText}, q{ImDrawList* drawList, float size, in ImVec2 pos, uint col, in ImVec4 clipRect, const(char)* textBegin, const(char)* textEnd, float wrapWidth=0f, bool cpuFineClip=false}, ext: `C++`, memAttr: q{const}, pubIden: "renderText"},
			
			{q{void}, q{BuildLookupTable}, q{}, ext: `C++`, pubIden: "buildLookupTable"},
			{q{void}, q{ClearOutputData}, q{}, ext: `C++`, pubIden: "clearOutputData"},
			{q{void}, q{GrowIndex}, q{int newSize}, ext: `C++`, pubIden: "growIndex"},
			{q{void}, q{AddGlyph}, q{const(ImFontConfig)* srcCfg, ImWchar c, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1, float advanceX}, ext: `C++`, pubIden: "addGlyph"},
			{q{void}, q{AddRemapChar}, q{ImWchar dst, ImWchar src, bool overwriteDst=true}, ext: `C++`, pubIden: "addRemapChar"},
			{q{void}, q{SetGlyphVisible}, q{ImWchar c, bool visible}, ext: `C++`, pubIden: "setGlyphVisible"},
			{q{bool}, q{IsGlyphRangeUnused}, q{uint cBegin, uint cLast}, ext: `C++`, pubIden: "isGlyphRangeUnused"},
		];
		return ret;
	}()));
	
	nothrow @nogc:
	float GetCharAdvance(ImWchar c) const pure @safe => (cast(int)c < indexAdvanceX.size) ? indexAdvanceX[cast(int)c] : fallbackAdvanceX;
	bool isLoaded() const pure @safe => containerAtlas !is null;
	const(char)* getDebugName() const pure @safe => configData ? configData.name.ptr : "<unknown>";
}

alias ImGuiViewportFlags_ = int;
enum ImGuiViewportFlags: ImGuiViewportFlags_{
	none                     = 0,
	isPlatformWindow         = 1 << 0,
	isPlatformMonitor        = 1 << 1,
	ownedByApp               = 1 << 2,
}

extern(C++) struct ImGuiViewport{
	ImGuiViewportFlags_ flags = 0;
	ImVec2 pos = ImVec2(0, 0);
	ImVec2 size = ImVec2(0, 0);
	ImVec2 workPos = ImVec2(0, 0);
	ImVec2 workSize = ImVec2(0, 0);
	
	void* platformHandleRaw = null;
	
	nothrow @nogc:
	ImVec2 getCenter() const pure @safe => ImVec2(pos.x + size.x * 0.5f, pos.y + size.y * 0.5f);
	alias getCentre = getCenter;
	ImVec2 getWorkCenter() const pure @safe => ImVec2(workPos.x + workSize.x * 0.5f, workPos.y + workSize.y * 0.5f);
	alias getWorkCentre = getWorkCenter;
}

private extern(C++) struct ImGuiPlatformImeData{
	bool wantVisible = false;
	ImVec2 inputPos = ImVec2(0, 0);
	float inputLineHeight = 0;
}
alias ImGuiPlatformIMEData = ImGuiPlatformImeData;

version(ImGui_DisableObsoleteFunctions){
}else{
	pragma(inline,true) nothrow @nogc{
	}
}

private alias ItemsGetterFn = extern(C++) const(char)* function(void* userData, int idx);
private alias ValuesGetterFn = extern(C++) float function(void* data, int idx);

mixin(joinFnBinds((){
	FnBind[] ret = [
		{q{ImGuiContext*}, q{CreateContext}, q{ImFontAtlas* sharedFontAtlas=null}, ext: `C++, "ImGui"`},
		{q{void}, q{DestroyContext}, q{ImGuiContext* ctx=null}, ext: `C++, "ImGui"`},
		{q{ImGuiContext*}, q{GetCurrentContext}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetCurrentContext}, q{ImGuiContext* ctx}, ext: `C++, "ImGui"`},
		
		{q{ImGuiIO*}, q{GetIO}, q{}, ext: `C++, "ImGui"`},
		{q{ImGuiStyle*}, q{GetStyle}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{NewFrame}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{EndFrame}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{Render}, q{}, ext: `C++, "ImGui"`},
		{q{ImDrawData*}, q{GetDrawData}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{ShowDemoWindow}, q{bool* pOpen=null}, ext: `C++, "ImGui"`},
		{q{void}, q{ShowMetricsWindow}, q{bool* pOpen=null}, ext: `C++, "ImGui"`},
		{q{void}, q{ShowDebugLogWindow}, q{bool* pOpen=null}, ext: `C++, "ImGui"`},
		{q{void}, q{ShowIDStackToolWindow}, q{bool* pOpen=null}, ext: `C++, "ImGui"`},
		{q{void}, q{ShowAboutWindow}, q{bool* pOpen=null}, ext: `C++, "ImGui"`},
		{q{void}, q{ShowStyleEditor}, q{ImGuiStyle* ref_=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{ShowStyleSelector}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{void}, q{ShowFontSelector}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{void}, q{ShowUserGuide}, q{}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{GetVersion}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{StyleColorsDark}, q{ImGuiStyle* dst=null}, ext: `C++, "ImGui"`, aliases: ["StyleColoursDark"]},
		{q{void}, q{StyleColorsLight}, q{ImGuiStyle* dst=null}, ext: `C++, "ImGui"`, aliases: ["StyleColoursLight"]},
		{q{void}, q{StyleColorsClassic}, q{ImGuiStyle* dst=null}, ext: `C++, "ImGui"`, aliases: ["StyleColoursClassic"]},
		
		{q{bool}, q{Begin}, q{const(char)* name, bool* pOpen=null, ImGuiWindowFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{End}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginChild}, q{const(char)* strID, in ImVec2 size=ImVec2(0,0), ImGuiChildFlags_ childFlags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginChild}, q{ImGuiID id, in ImVec2 size=ImVec2(0,0), ImGuiChildFlags_ childFlags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndChild}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{IsWindowAppearing}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsWindowCollapsed}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsWindowFocused}, q{ImGuiFocusedFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsWindowHovered}, q{ImGuiHoveredFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{ImDrawList*}, q{GetWindowDrawList}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetWindowPos}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetWindowSize}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetWindowWidth}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetWindowHeight}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{SetNextWindowPos}, q{in ImVec2 pos, ImGuiCond_ cond=0, in ImVec2 pivot=ImVec2(0,0)}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowSize}, q{in ImVec2 size, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowSizeConstraints}, q{in ImVec2 sizeMin, in ImVec2 size_max, ImGuiSizeCallback customCallback=null, void* customCallbackData=null}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowContentSize}, q{in ImVec2 size}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowCollapsed}, q{bool collapsed, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowFocus}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowScroll}, q{in ImVec2 scroll}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowBgAlpha}, q{float alpha}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowPos}, q{in ImVec2 pos, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowSize}, q{in ImVec2 size, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowCollapsed}, q{bool collapsed, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowFocus}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowFontScale}, q{float scale}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowPos}, q{const(char)* name, in ImVec2 pos, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowSize}, q{const(char)* name, in ImVec2 size, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowCollapsed}, q{const(char)* name, bool collapsed, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetWindowFocus}, q{const(char)* name}, ext: `C++, "ImGui"`},
		
		{q{ImVec2}, q{GetContentRegionAvail}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetContentRegionMax}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetWindowContentRegionMin}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetWindowContentRegionMax}, q{}, ext: `C++, "ImGui"`},
		
		{q{float}, q{GetScrollX}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetScrollY}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetScrollX}, q{float scrollX}, ext: `C++, "ImGui"`},
		{q{void}, q{SetScrollY}, q{float scrollY}, ext: `C++, "ImGui"`},
		{q{float}, q{GetScrollMaxX}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetScrollMaxY}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetScrollHereX}, q{float centreXRatio=0.5f}, ext: `C++, "ImGui"`},
		{q{void}, q{SetScrollHereY}, q{float centreYRatio=0.5f}, ext: `C++, "ImGui"`},
		{q{void}, q{SetScrollFromPosX}, q{float localX, float centreXRatio=0.5f}, ext: `C++, "ImGui"`},
		{q{void}, q{SetScrollFromPosY}, q{float localY, float centreYRatio=0.5f}, ext: `C++, "ImGui"`},
		{q{void}, q{PushFont}, q{ImFont* font}, ext: `C++, "ImGui"`},
		{q{void}, q{PopFont}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{PushStyleColor}, q{ImGuiCol_ idx, uint col}, ext: `C++, "ImGui"`, aliases: ["PushStyleColour"]},
		{q{void}, q{PushStyleColor}, q{ImGuiCol_ idx, in ImVec4 col}, ext: `C++, "ImGui"`, aliases: ["PushStyleColour"]},
		{q{void}, q{PopStyleColor}, q{int count=1}, ext: `C++, "ImGui"`, aliases: ["PopStyleColour"]},
		{q{void}, q{PushStyleVar}, q{ImGuiStyleVar_ idx, float val}, ext: `C++, "ImGui"`},
		{q{void}, q{PushStyleVar}, q{ImGuiStyleVar_ idx, in ImVec2 val}, ext: `C++, "ImGui"`},
		{q{void}, q{PopStyleVar}, q{int count=1}, ext: `C++, "ImGui"`},
		{q{void}, q{PushTabStop}, q{bool tabStop}, ext: `C++, "ImGui"`},
		{q{void}, q{PopTabStop}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{PushButtonRepeat}, q{bool repeat}, ext: `C++, "ImGui"`},
		{q{void}, q{PopButtonRepeat}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{PushItemWidth}, q{float itemWidth}, ext: `C++, "ImGui"`},
		{q{void}, q{PopItemWidth}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextItemWidth}, q{float itemWidth}, ext: `C++, "ImGui"`},
		{q{float}, q{CalcItemWidth}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{PushTextWrapPos}, q{float wrapLocalPosX=0f}, ext: `C++, "ImGui"`},
		{q{void}, q{PopTextWrapPos}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImFont*}, q{GetFont}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetFontSize}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetFontTexUvWhitePixel}, q{}, ext: `C++, "ImGui"`},
		{q{uint}, q{GetColorU32}, q{ImGuiCol_ idx, float alphaMul=1f}, ext: `C++, "ImGui"`, aliases: ["GetColourU32"]},
		{q{uint}, q{GetColorU32}, q{in ImVec4 col}, ext: `C++, "ImGui"`, aliases: ["GetColourU32"]},
		{q{uint}, q{GetColorU32}, q{uint col}, ext: `C++, "ImGui"`, aliases: ["GetColourU32"]},
		{q{const(ImVec4)*}, q{GetStyleColorVec4}, q{ImGuiCol_ idx}, ext: `C++, "ImGui"`, aliases: ["GetStyleColourVec4"]},
		
		{q{ImVec2}, q{GetCursorScreenPos}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetCursorScreenPos}, q{in ImVec2 pos}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetCursorPos}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetCursorPosX}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetCursorPosY}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetCursorPos}, q{in ImVec2 localPos}, ext: `C++, "ImGui"`},
		{q{void}, q{SetCursorPosX}, q{float localX}, ext: `C++, "ImGui"`},
		{q{void}, q{SetCursorPosY}, q{float localY}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetCursorStartPos}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{Separator}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SameLine}, q{float offsetFromStartX=0f, float spacing=-1f}, ext: `C++, "ImGui"`},
		{q{void}, q{NewLine}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{Spacing}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{Dummy}, q{in ImVec2 size}, ext: `C++, "ImGui"`},
		{q{void}, q{Indent}, q{float indentW=0f}, ext: `C++, "ImGui"`},
		{q{void}, q{Unindent}, q{float indentW=0f}, ext: `C++, "ImGui"`},
		{q{void}, q{BeginGroup}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{EndGroup}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{AlignTextToFramePadding}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetTextLineHeight}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetTextLineHeightWithSpacing}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetFrameHeight}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetFrameHeightWithSpacing}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{PushID}, q{const(char)* strID}, ext: `C++, "ImGui"`},
		{q{void}, q{PushID}, q{const(char)* strIDBegin, const(char)* strIDEnd}, ext: `C++, "ImGui"`},
		{q{void}, q{PushID}, q{const(void)* ptrID}, ext: `C++, "ImGui"`},
		{q{void}, q{PushID}, q{int intID}, ext: `C++, "ImGui"`},
		{q{void}, q{PopID}, q{}, ext: `C++, "ImGui"`},
		{q{ImGuiID}, q{GetID}, q{const(char)* strID}, ext: `C++, "ImGui"`},
		{q{ImGuiID}, q{GetID}, q{const(char)* strIDBegin, const(char)* strIDEnd}, ext: `C++, "ImGui"`},
		{q{ImGuiID}, q{GetID}, q{const(void)* ptrID}, ext: `C++, "ImGui"`},
		
		{q{void}, q{TextUnformatted}, q{const(char)* text, const(char)* textEnd=null}, ext: `C++, "ImGui"`},
		{q{void}, q{Text}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{TextV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{TextColored}, q{in ImVec4 col, const(char)* fmt, ...}, ext: `C++, "ImGui"`, aliases: ["TextColoured"]},
		{q{void}, q{TextColoredV}, q{in ImVec4 col, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`, aliases: ["TextColouredV"]},
		{q{void}, q{TextDisabled}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{TextDisabledV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{TextWrapped}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{TextWrappedV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{LabelText}, q{const(char)* label, const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{LabelTextV}, q{const(char)* label, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{BulletText}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{BulletTextV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{SeparatorText}, q{const(char)* label}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{Button}, q{const(char)* label, in ImVec2 size=ImVec2(0,0)}, ext: `C++, "ImGui"`},
		{q{bool}, q{SmallButton}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{bool}, q{InvisibleButton}, q{const(char)* strID, in ImVec2 size, ImGuiButtonFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{ArrowButton}, q{const(char)* strID, ImGuiDir_ dir}, ext: `C++, "ImGui"`},
		{q{bool}, q{Checkbox}, q{const(char)* label, bool* v}, ext: `C++, "ImGui"`},
		{q{bool}, q{CheckboxFlags}, q{const(char)* label, int* flags, int flagsValue}, ext: `C++, "ImGui"`},
		{q{bool}, q{CheckboxFlags}, q{const(char)* label, uint* flags, uint flagsValue}, ext: `C++, "ImGui"`},
		{q{bool}, q{RadioButton}, q{const(char)* label, bool active}, ext: `C++, "ImGui"`},
		{q{bool}, q{RadioButton}, q{const(char)* label, int* v, int vButton}, ext: `C++, "ImGui"`},
		{q{void}, q{ProgressBar}, q{float fraction, in ImVec2 sizeArg=ImVec2(-float.min_normal, 0), const(char)* overlay=null}, ext: `C++, "ImGui"`},
		{q{void}, q{Bullet}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{Image}, q{ImTextureID userTextureID, in ImVec2 size, in ImVec2 uv0=ImVec2(0,0), in ImVec2 uv1=ImVec2(1,1), in ImVec4 tint_col=ImVec4(1,1,1,1), in ImVec4 borderCol=ImVec4(0,0,0,0)}, ext: `C++, "ImGui"`},
		{q{bool}, q{ImageButton}, q{const(char)* str_id, ImTextureID userTextureID, in ImVec2 imageSize, in ImVec2 uv0=ImVec2(0,0), in ImVec2 uv1=ImVec2(1,1), in ImVec4 bgCol=ImVec4(0,0,0,0), in ImVec4 tintCol=ImVec4(1,1,1,1)}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginCombo}, q{const(char)* label, const(char)* previewValue, ImGuiComboFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndCombo}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{Combo}, q{const(char)* label, int* currentItem, const(char*)* items, int itemsCount, int popupMaxHeightInItems=-1}, ext: `C++, "ImGui"`},
		{q{bool}, q{Combo}, q{const(char)* label, int* currentItem, const(char)* itemsSeparatedByZeros, int popupMaxHeightInItems=-1}, ext: `C++, "ImGui"`},
		{q{bool}, q{Combo}, q{const(char)* label, int* currentItem, ItemsGetterFn getter, void* userData, int itemsCount, int popupMaxHeightInItems=-1}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{DragFloat}, q{const(char)* label, float* v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloat2}, q{const(char)* label, float* v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloat3}, q{const(char)* label, float* v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloat4}, q{const(char)* label, float* v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloatRange2}, q{const(char)* label, float* vCurrentMin, float* vCurrentMax, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", const(char)* formatMax=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt}, q{const(char)* label, int* v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt2}, q{const(char)* label, int* v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt3}, q{const(char)* label, int* v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt4}, q{const(char)* label, int* v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragIntRange2}, q{const(char)* label, int* vCurrentMin, int* vCurrentMax, float vSpeed=1f, int v_min=0, int v_max=0, const(char)* format="%d", const(char)* formatMax=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragScalar}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, float vSpeed=1f, const(void)* pMin=null, const(void)* pMax=null, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragScalarN}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, int components, float vSpeed=1f, const(void)* pMin=null, const(void)* pMax=null, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{SliderFloat}, q{const(char)* label, float* v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderFloat2}, q{const(char)* label, float* v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderFloat3}, q{const(char)* label, float* v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderFloat4}, q{const(char)* label, float* v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderAngle}, q{const(char)* label, float* vRad, float vDegreesMin=-360f, float vDegreesMax=+360f, const(char)* format="%.0f deg", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt}, q{const(char)* label, int* v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt2}, q{const(char)* label, int* v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt3}, q{const(char)* label, int* v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt4}, q{const(char)* label, int* v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderScalar}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, const(void)* pMin, const(void)* pMax, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderScalarN}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, int components, const(void)* pMin, const(void)* pMax, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{VSliderFloat}, q{const(char)* label, in ImVec2 size, float* v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{VSliderInt}, q{const(char)* label, in ImVec2 size, int* v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{VSliderScalar}, q{const(char)* label, in ImVec2 size, ImGuiDataType_ dataType, void* pData, const(void)* pMin, const(void)* pMax, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{InputText}, q{const(char)* label, char* buf, size_t bufSize, ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* userData=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputTextMultiline}, q{const(char)* label, char* buf, size_t bufSize, in ImVec2 size=ImVec2(0,0), ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* userData=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputTextWithHint}, q{const(char)* label, const(char)* hint, char* buf, size_t bufSize, ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* userData=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat}, q{const(char)* label, float* v, float step=0f, float stepFast=0f, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat2}, q{const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat3}, q{const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat4}, q{const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt}, q{const(char)* label, int* v, int step=1, int stepFast=100, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt2}, q{const(char)* label, int* v, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt3}, q{const(char)* label, int* v, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt4}, q{const(char)* label, int* v, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputDouble}, q{const(char)* label, double* v, double step=0.0, double stepFast=0.0, const(char)* format="%.6f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputScalar}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, const(void)* pStep=null, const(void)* pStepFast=null, const(char)* format=null, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputScalarN}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, int components, const(void)* pStep=null, const(void)* pStepFast=null, const(char)* format=null, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{ColorEdit3}, q{const(char)* label, float* col, ImGuiColorEditFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: ["ColourEdit3"]},
		{q{bool}, q{ColorEdit4}, q{const(char)* label, float* col, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: ["ColourEdit4"]},
		{q{bool}, q{ColorPicker3}, q{const(char)* label, float* col, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: ["ColourPicker3"]},
		{q{bool}, q{ColorPicker4}, q{const(char)* label, float* col, ImGuiInputTextFlags_ flags=0, const(float)* refCol=null}, ext: `C++, "ImGui"`, aliases: ["ColourPicker4"]},
		{q{bool}, q{ColorButton}, q{const(char)* descID, in ImVec4 col, ImGuiInputTextFlags_ flags=0, in ImVec2 size=ImVec2(0,0)}, ext: `C++, "ImGui"`, aliases: ["ColourButton"]},
		{q{void}, q{SetColorEditOptions}, q{ImGuiColorEditFlags_ flags}, ext: `C++, "ImGui"`, aliases: ["SetColourEditOptions"]},
		
		{q{bool}, q{TreeNode}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNode}, q{const(char)* strID, const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNode}, q{const(void)* ptrID, const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNodeV}, q{const(char)* strID, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNodeV}, q{const(void)* ptrID, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNodeEx}, q{const(char)* label, ImGuiTreeNodeFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNodeEx}, q{const(char)* strID, ImGuiTreeNodeFlags_ flags, const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNodeEx}, q{const(void)* ptrID, ImGuiTreeNodeFlags_ flags, const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNodeExV}, q{const(char)* strID, ImGuiTreeNodeFlags_ flags, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{bool}, q{TreeNodeExV}, q{const(void)* ptrID, ImGuiTreeNodeFlags_ flags, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{TreePush}, q{const(char)* strID}, ext: `C++, "ImGui"`},
		{q{void}, q{TreePush}, q{const(void)* ptrID}, ext: `C++, "ImGui"`},
		{q{void}, q{TreePop}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetTreeNodeToLabelSpacing}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{CollapsingHeader}, q{const(char)* label, ImGuiTreeNodeFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{CollapsingHeader}, q{const(char)* label, bool* p_visible, ImGuiTreeNodeFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextItemOpen}, q{bool is_open, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{Selectable}, q{const(char)* label, bool selected=false, ImGuiSelectableFlags_ flags=0, in ImVec2 size=ImVec2(0,0)}, ext: `C++, "ImGui"`},
		{q{bool}, q{Selectable}, q{const(char)* label, bool* p_selected, ImGuiSelectableFlags_ flags=0, in ImVec2 size=ImVec2(0,0)}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginListBox}, q{const(char)* label, in ImVec2 size=ImVec2(0,0)}, ext: `C++, "ImGui"`},
		{q{void}, q{EndListBox}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{ListBox}, q{const(char)* label, int* currentItem, const(char*)* items, int itemsCount, int heightInItems=-1}, ext: `C++, "ImGui"`},
		{q{bool}, q{ListBox}, q{const(char)* label, int* currentItem, ItemsGetterFn itemsGetter, void* userData, int itemsCount, int heightInItems=-1}, ext: `C++, "ImGui"`},
		
		{q{void}, q{PlotLines}, q{const(char)* label, const(float)* values, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0,0), int stride=float.sizeof}, ext: `C++, "ImGui"`},
		{q{void}, q{PlotLines}, q{const(char)* label, ValuesGetterFn valuesGetter, void* data, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0,0)}, ext: `C++, "ImGui"`},
		{q{void}, q{PlotHistogram}, q{const(char)* label, const(float)* values, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0,0), int stride=float.sizeof}, ext: `C++, "ImGui"`},
		{q{void}, q{PlotHistogram}, q{const(char)* label, ValuesGetterFn valuesGetter, void* data, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0,0)}, ext: `C++, "ImGui"`},
		
		{q{void}, q{Value}, q{const(char)* prefix, bool b}, ext: `C++, "ImGui"`},
		{q{void}, q{Value}, q{const(char)* prefix, int v}, ext: `C++, "ImGui"`},
		{q{void}, q{Value}, q{const(char)* prefix, uint v}, ext: `C++, "ImGui"`},
		{q{void}, q{Value}, q{const(char)* prefix, float v, const(char)* float_format=null}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginMenuBar}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{EndMenuBar}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginMainMenuBar}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{EndMainMenuBar}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginMenu}, q{const(char)* label, bool enabled=true}, ext: `C++, "ImGui"`},
		{q{void}, q{EndMenu}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{MenuItem}, q{const(char)* label, const(char)* shortcut=null, bool selected=false, bool enabled=true}, ext: `C++, "ImGui"`},
		{q{bool}, q{MenuItem}, q{const(char)* label, const(char)* shortcut, bool* pSelected, bool enabled=true}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginTooltip}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{EndTooltip}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetTooltip}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{SetTooltipV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginItemTooltip}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetItemTooltip}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{SetItemTooltipV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginPopup}, q{const(char)* str_id, ImGuiWindowFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginPopupModal}, q{const(char)* name, bool* pOpen=null, ImGuiWindowFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndPopup}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{OpenPopup}, q{const(char)* str_id, ImGuiPopupFlags_ popupFlags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{OpenPopup}, q{ImGuiID id, ImGuiPopupFlags_ popupFlags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{OpenPopupOnItemClick}, q{const(char)* str_id=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		{q{void}, q{CloseCurrentPopup}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginPopupContextItem}, q{const(char)* str_id=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginPopupContextWindow}, q{const(char)* str_id=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginPopupContextVoid}, q{const(char)* str_id=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsPopupOpen}, q{const(char)* str_id, ImGuiPopupFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginTable}, q{const(char)* str_id, int column, ImGuiTableFlags_ flags=0, in ImVec2 outerSize=ImVec2(0,0), float innerWidth=0f}, ext: `C++, "ImGui"`},
		{q{void}, q{EndTable}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{TableNextRow}, q{ImGuiTableRowFlags_ rowFlags=0, float minRowHeight=0f}, ext: `C++, "ImGui"`},
		{q{bool}, q{TableNextColumn}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{TableSetColumnIndex}, q{int column_n}, ext: `C++, "ImGui"`},
		
		{q{void}, q{TableSetupColumn}, q{const(char)* label, ImGuiTableColumnFlags_ flags=0, float initWidthOrWeight=0f, ImGuiID userID=0}, ext: `C++, "ImGui"`},
		{q{void}, q{TableSetupScrollFreeze}, q{int cols, int rows}, ext: `C++, "ImGui"`},
		{q{void}, q{TableHeader}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{void}, q{TableHeadersRow}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{TableAngledHeadersRow}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImGuiTableSortSpecs*}, q{TableGetSortSpecs}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{TableGetColumnCount}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{TableGetColumnIndex}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{TableGetRowIndex}, q{}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{TableGetColumnName}, q{int columnN=-1}, ext: `C++, "ImGui"`},
		{q{ImGuiTableColumnFlags}, q{TableGetColumnFlags}, q{int columnN=-1}, ext: `C++, "ImGui"`},
		{q{void}, q{TableSetColumnEnabled}, q{int columnN, bool v}, ext: `C++, "ImGui"`},
		{q{void}, q{TableSetBgColor}, q{ImGuiTableBgTarget_ target, uint color, int columnN=-1}, ext: `C++, "ImGui"`, aliases: ["TableSetBgColour"]},
		{q{void}, q{Columns}, q{int count=1, const(char)* id=null, bool border=true}, ext: `C++, "ImGui"`},
		{q{void}, q{NextColumn}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{GetColumnIndex}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetColumnWidth}, q{int columnIndex=-1}, ext: `C++, "ImGui"`},
		{q{void}, q{SetColumnWidth}, q{int columnIndex, float width}, ext: `C++, "ImGui"`},
		{q{float}, q{GetColumnOffset}, q{int columnIndex=-1}, ext: `C++, "ImGui"`},
		{q{void}, q{SetColumnOffset}, q{int columnIndex, float offsetX}, ext: `C++, "ImGui"`},
		{q{int}, q{GetColumnsCount}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginTabBar}, q{const(char)* strID, ImGuiTabBarFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndTabBar}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginTabItem}, q{const(char)* label, bool* pOpen=null, ImGuiTabItemFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndTabItem}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{TabItemButton}, q{const(char)* label, ImGuiTabItemFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetTabItemClosed}, q{const(char)* tabOrDockedWindowLabel}, ext: `C++, "ImGui"`},
		
		{q{void}, q{LogToTTY}, q{int auto_open_depth=-1}, ext: `C++, "ImGui"`},
		{q{void}, q{LogToFile}, q{int auto_open_depth=-1, const(char)* filename=null}, ext: `C++, "ImGui"`},
		{q{void}, q{LogToClipboard}, q{int autoOpenDepth=-1}, ext: `C++, "ImGui"`},
		{q{void}, q{LogFinish}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{LogButtons}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{LogText}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{LogTextV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginDragDropSource}, q{ImGuiDragDropFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SetDragDropPayload}, q{const(char)* type, const(void)* data, size_t sz, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndDragDropSource}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginDragDropTarget}, q{}, ext: `C++, "ImGui"`},
		{q{const(ImGuiPayload)*}, q{AcceptDragDropPayload}, q{const(char)* type, ImGuiDragDropFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndDragDropTarget}, q{}, ext: `C++, "ImGui"`},
		{q{const(ImGuiPayload)*}, q{GetDragDropPayload}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{BeginDisabled}, q{bool disabled=true}, ext: `C++, "ImGui"`},
		{q{void}, q{EndDisabled}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{PushClipRect}, q{in ImVec2 clipRectMin, in ImVec2 clipRectMax, bool intersectWithCurrentClipRect}, ext: `C++, "ImGui"`},
		{q{void}, q{PopClipRect}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{SetItemDefaultFocus}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetKeyboardFocusHere}, q{int offset=0}, ext: `C++, "ImGui"`},
		
		{q{void}, q{SetNextItemAllowOverlap}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{IsItemHovered}, q{ImGuiHoveredFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemActive}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemFocused}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemClicked}, q{ImGuiMouseButton_ mouseButton=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemVisible}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemEdited}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemActivated}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemDeactivated}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemDeactivatedAfterEdit}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemToggledOpen}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsAnyItemHovered}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsAnyItemActive}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsAnyItemFocused}, q{}, ext: `C++, "ImGui"`},
		{q{ImGuiID}, q{GetItemID}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetItemRectMin}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetItemRectMax}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetItemRectSize}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImGuiViewport*}, q{GetMainViewport}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImDrawList*}, q{GetBackgroundDrawList}, q{}, ext: `C++, "ImGui"`},
		{q{ImDrawList*}, q{GetForegroundDrawList}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{IsRectVisible}, q{in ImVec2 size}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsRectVisible}, q{in ImVec2 rectMin, in ImVec2 rectMax}, ext: `C++, "ImGui"`},
		{q{double}, q{GetTime}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{GetFrameCount}, q{}, ext: `C++, "ImGui"`},
		{q{ImDrawListSharedData*}, q{GetDrawListSharedData}, q{}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{GetStyleColorName}, q{ImGuiCol_ idx}, ext: `C++, "ImGui"`, aliases: ["GetStyleColourName"]},
		{q{void}, q{SetStateStorage}, q{ImGuiStorage* storage}, ext: `C++, "ImGui"`},
		{q{ImGuiStorage*}, q{GetStateStorage}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImVec2}, q{CalcTextSize}, q{const(char)* text, const(char)* textEnd=null, bool hideTextAfterDoubleHash=false, float wrapWidth=-1f}, ext: `C++, "ImGui"`},
		
		{q{ImVec4}, q{ColorConvertU32ToFloat4}, q{uint in_}, ext: `C++, "ImGui"`, aliases: ["ColourConvertU32ToFloat4"]},
		{q{uint}, q{ColorConvertFloat4ToU32}, q{in ImVec4 inP}, ext: `C++, "ImGui"`, aliases: ["ColourConvertFloat4ToU32"]},
		{q{void}, q{ColorConvertRGBtoHSV}, q{float r, float g, float b, ref float outH, ref float outS, ref float outV}, ext: `C++, "ImGui"`, aliases: ["ColourConvertRGBtoHSV"]},
		{q{void}, q{ColorConvertHSVtoRGB}, q{float h, float s, float v, ref float outR, ref float outG, ref float outB}, ext: `C++, "ImGui"`, aliases: ["ColourConvertHSVtoRGB"]},
		
		{q{bool}, q{IsKeyDown}, q{ImGuiKey_ key}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsKeyPressed}, q{ImGuiKey_ key, bool repeat=true}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsKeyReleased}, q{ImGuiKey_ key}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsKeyChordPressed}, q{ImGuiKeyChord keyChord}, ext: `C++, "ImGui"`},
		{q{int}, q{GetKeyPressedAmount}, q{ImGuiKey_ key, float repeatDelay, float rate}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{GetKeyName}, q{ImGuiKey_ key}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextFrameWantCaptureKeyboard}, q{bool wantCaptureKeyboard}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{IsMouseDown}, q{ImGuiMouseButton_ button}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsMouseClicked}, q{ImGuiMouseButton_ button, bool repeat=false}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsMouseReleased}, q{ImGuiMouseButton_ button}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsMouseDoubleClicked}, q{ImGuiMouseButton_ button}, ext: `C++, "ImGui"`},
		{q{int}, q{GetMouseClickedCount}, q{ImGuiMouseButton_ button}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsMouseHoveringRect}, q{in ImVec2 rMin, in ImVec2 rMax, bool clip=true}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsMousePosValid}, q{const(ImVec2)* mousePos=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsAnyMouseDown}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetMousePos}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetMousePosOnOpeningCurrentPopup}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsMouseDragging}, q{ImGuiMouseButton_ button, float lockThreshold=-1f}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetMouseDragDelta}, q{ImGuiMouseButton_ button=0, float lockThreshold=-1f}, ext: `C++, "ImGui"`},
		{q{void}, q{ResetMouseDragDelta}, q{ImGuiMouseButton_ button=0}, ext: `C++, "ImGui"`},
		{q{ImGuiMouseCursor}, q{GetMouseCursor}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetMouseCursor}, q{ImGuiMouseCursor cursorType}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextFrameWantCaptureMouse}, q{bool wantCaptureMouse}, ext: `C++, "ImGui"`},
		
		{q{const(char)*}, q{GetClipboardText}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetClipboardText}, q{const(char)* text}, ext: `C++, "ImGui"`},
		
		{q{void}, q{LoadIniSettingsFromDisk}, q{const(char)* iniFilename}, ext: `C++, "ImGui"`},
		{q{void}, q{LoadIniSettingsFromMemory}, q{const(char)* iniData, size_t ini_size=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SaveIniSettingsToDisk}, q{const(char)* iniFilename}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{SaveIniSettingsToMemory}, q{size_t* outIniSize=null}, ext: `C++, "ImGui"`},
		
		{q{void}, q{DebugTextEncoding}, q{const(char)* text}, ext: `C++, "ImGui"`},
		{q{bool}, q{DebugCheckVersionAndDataLayout}, q{const(char)* versionStr, size_t szIo, size_t szStyle, size_t szVec2, size_t szVec4, size_t szDrawvert, size_t szDrawidx}, ext: `C++, "ImGui"`},
		{q{void}, q{SetAllocatorFunctions}, q{ImGuiMemAllocFunc allocFunc, ImGuiMemFreeFunc freeFunc, void* user_data=null}, ext: `C++, "ImGui"`},
		{q{void}, q{GetAllocatorFunctions}, q{ImGuiMemAllocFunc* pAllocFunc, ImGuiMemFreeFunc* pFreeFunc, void** p_user_data}, ext: `C++, "ImGui"`},
		{q{void*}, q{MemAlloc}, q{size_t size}, ext: `C++, "ImGui"`},
		{q{void}, q{MemFree}, q{void* ptr}, ext: `C++, "ImGui"`},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{
		FnBind[] add = [
			{q{bool}, q{ImageButton}, q{ImTextureID userTextureID, in ImVec2 size, in ImVec2 uv0=ImVec2(0,0), in ImVec2 uv1=ImVec2(1,1), int framePadding=-1, in ImVec4 bgCol=ImVec4(0,0,0,0), in ImVec4 tintCol=ImVec4(1,1,1,1)}, ext: `C++, "ImGui"`},
			
			{q{void}, q{CalcListClipping}, q{int itemsCount, float itemsHeight, int* outItemsDisplayStart, int* outItemsDisplayEnd}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}
	return ret;
}(), "ImGuiStyle, ImGuiIO, ImGuiInputTextCallbackData, ImGuiTextFilter, ImGuiTextFilter.ImGuiTextRange, ImGuiTextBuffer, ImGuiStorage, ImGuiListClipper, ImDrawListSplitter, ImFontConfig, ImFontGlyphRangesBuilder, ImFontAtlas, ImFont"));

pragma(inline,true) nothrow @nogc{
	T IM_NEW(T, A...)(A args){
		auto ret = cast(T*)MemAlloc(T.sizeof);
		import core.lifetime;
		static if(__traits(hasMember, T, "__ctor__")) ret.__ctor__(forward!args);
		return ret;
	}
	void IM_DELETE(T)(T* p){
		static if(__traits(hasMember, T, "__dtor__")) p.__dtor__();
		MemFree(cast(void*)p);
	}
}

static if(!staticBinding):
import bindbc.loader;

mixin(makeDynloadFns("ImGui", makeLibPaths(["imgui"]), [
	__MODULE__,
	"imgui.impl",
	"imgui.internal"
]));

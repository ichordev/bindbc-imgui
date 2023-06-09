/+
+                Copyright 2023 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui;

import bindbc.imgui.config;
import bindbc.imgui.codegen;

import core.vararg: va_list;
import core.stdc.string: memcpy, memset, memmove, memcmp, strcmp;

public import
	imgui.impl,
	imgui.internal;

enum IMGUI_VERSION        = "1.89.6";
enum IMGUI_VERSION_NUM    = 18960;

pragma(inline,true) bool IMGUI_CHECKVERSION() nothrow @nogc{
	return DebugCheckVersionAndDataLayout(IMGUI_VERSION,
		ImGuiIO.sizeof, ImGuiStyle.sizeof, ImVec2.sizeof, ImVec4.sizeof, ImDrawVert.sizeof, ImDrawIdx.sizeof
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

alias ImGuiMemAllocFunc = extern(C++) void* function(size_t sz, void* user_data);

alias ImGuiMemFreeFunc = extern(C++) void function(void* ptr, void* user_data);

extern(C++) struct ImVec2{
	float x=0f, y=0f;
	
	nothrow @nogc:
	ref float opIndex(size_t idx){
		assert(idx == 0 || idx == 1);
		return (cast(float*)cast(void*)cast(char*)this)[idx];
	}
	float opIndex(size_t idx) const{
		assert(idx == 0 || idx == 1);
		return (cast(const(float)*)cast(const(void)*)cast(const(char)*)this)[idx];
	}
	
	pragma(inline,true){
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
}

extern(C++) struct ImVec4{
	float x=0f, y=0f, z=0f, w=0f;
	
	nothrow @nogc:
	pragma(inline,true){
		ImVec4 opBinary(string op)(const ImVec4 rhs) const{
			mixin("return ImVec4(x "~op~" rhs.x, y "~op~" rhs.y, z "~op~" rhs.z, w "~op~" rhs.w);");
		}
	}
}

immutable{
	auto Vec2_0_0 = ImVec2(0,0);
	auto Vec2_0_1 = ImVec2(0,1);
	auto Vec2_1_0 = ImVec2(1,0);
	auto Vec2_1_1 = ImVec2(1,1);
	auto Vec2_negfltmin_0 = ImVec2(-float.min_normal, 0);
	auto Vec4_1_1_1_1 = ImVec4(1,1,1,1);
	auto Vec4_0_0_0_0 = ImVec4(0,0,0,0);
}

private alias ItemsGetterFn = extern(C++) bool function(void* data, int idx, const(char)** out_text);
private alias ValuesGetterFn = extern(C++) float function(void* data, int idx);

alias ImGuiWindowFlags_ = int;
enum ImGuiWindowFlags: ImGuiWindowFlags_{
	None                   = 0,
	NoTitleBar             = 1 << 0,
	NoResize               = 1 << 1,
	NoMove                 = 1 << 2,
	NoScrollbar            = 1 << 3,
	NoScrollWithMouse      = 1 << 4,
	NoCollapse             = 1 << 5,
	AlwaysAutoResize       = 1 << 6,
	NoBackground           = 1 << 7,
	NoSavedSettings        = 1 << 8,
	NoMouseInputs          = 1 << 9,
	MenuBar                = 1 << 10,
	HorizontalScrollbar    = 1 << 11,
	NoFocusOnAppearing     = 1 << 12,
	NoBringToFrontOnFocus  = 1 << 13,
	AlwaysVerticalScrollbar = 1 << 14,
	AlwaysHorizontalScrollbar = 1 << 15,
	AlwaysUseWindowPadding = 1 << 16,
	NoNavInputs            = 1 << 18,
	NoNavFocus             = 1 << 19,
	UnsavedDocument        = 1 << 20,
	NoNav                  = ImGuiWindowFlags.NoNavInputs | ImGuiWindowFlags.NoNavFocus,
	NoDecoration           = ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoCollapse,
	NoInputs               = ImGuiWindowFlags.NoMouseInputs | ImGuiWindowFlags.NoNavInputs | ImGuiWindowFlags.NoNavFocus,
	NavFlattened           = 1 << 23,
	ChildWindow            = 1 << 24,
	Tooltip                = 1 << 25,
	Popup                  = 1 << 26,
	Modal                  = 1 << 27,
	ChildMenu              = 1 << 28,
}

alias ImGuiInputTextFlags_ = int;
enum ImGuiInputTextFlags: ImGuiInputTextFlags_{
	None                 = 0,
	CharsDecimal         = 1 << 0,
	CharsHexadecimal     = 1 << 1,
	CharsUppercase       = 1 << 2,
	CharsNoBlank         = 1 << 3,
	AutoSelectAll        = 1 << 4,
	EnterReturnsTrue     = 1 << 5,
	CallbackCompletion   = 1 << 6,
	CallbackHistory      = 1 << 7,
	CallbackAlways       = 1 << 8,
	CallbackCharFilter   = 1 << 9,
	AllowTabInput        = 1 << 10,
	CtrlEnterForNewLine  = 1 << 11,
	NoHorizontalScroll   = 1 << 12,
	AlwaysOverwrite      = 1 << 13,
	ReadOnly             = 1 << 14,
	Password             = 1 << 15,
	NoUndoRedo           = 1 << 16,
	CharsScientific      = 1 << 17,
	CallbackResize       = 1 << 18,
	CallbackEdit         = 1 << 19,
	EscapeClearsAll      = 1 << 20,
}

alias ImGuiTreeNodeFlags_ = int;
enum ImGuiTreeNodeFlags: ImGuiTreeNodeFlags_{
	None                  = 0,
	Selected              = 1 << 0,
	Framed                = 1 << 1,
	AllowItemOverlap      = 1 << 2,
	NoTreePushOnOpen      = 1 << 3,
	NoAutoOpenOnLog       = 1 << 4,
	DefaultOpen           = 1 << 5,
	OpenOnDoubleClick     = 1 << 6,
	OpenOnArrow           = 1 << 7,
	Leaf                  = 1 << 8,
	Bullet                = 1 << 9,
	FramePadding          = 1 << 10,
	SpanAvailWidth        = 1 << 11,
	SpanFullWidth         = 1 << 12,
	NavLeftJumpsBackHere  = 1 << 13,
	CollapsingHeader      = ImGuiTreeNodeFlags.Framed | ImGuiTreeNodeFlags.NoTreePushOnOpen | ImGuiTreeNodeFlags.NoAutoOpenOnLog,
}

alias ImGuiPopupFlags_ = int;
enum ImGuiPopupFlags: ImGuiPopupFlags_{
	None                     = 0,
	MouseButtonLeft          = 0,
	MouseButtonRight         = 1,
	MouseButtonMiddle        = 2,
	MouseButtonMask_         = 0x1F,
	MouseButtonDefault_      = 1,
	NoOpenOverExistingPopup  = 1 << 5,
	NoOpenOverItems          = 1 << 6,
	AnyPopupId               = 1 << 7,
	AnyPopupLevel            = 1 << 8,
	AnyPopup                 = ImGuiPopupFlags.AnyPopupId | ImGuiPopupFlags.AnyPopupLevel,
}

alias ImGuiSelectableFlags_ = int;
enum ImGuiSelectableFlags: ImGuiSelectableFlags_{
	None               = 0,
	DontClosePopups    = 1 << 0,
	SpanAllColumns     = 1 << 1,
	AllowDoubleClick   = 1 << 2,
	Disabled           = 1 << 3,
	AllowItemOverlap   = 1 << 4,
}

alias ImGuiComboFlags_ = int;
enum ImGuiComboFlags: ImGuiComboFlags_{
	None            = 0,
	PopupAlignLeft  = 1 << 0,
	HeightSmall     = 1 << 1,
	HeightRegular   = 1 << 2,
	HeightLarge     = 1 << 3,
	HeightLargest   = 1 << 4,
	NoArrowButton   = 1 << 5,
	NoPreview       = 1 << 6,
	HeightMask_     = ImGuiComboFlags.HeightSmall | ImGuiComboFlags.HeightRegular | ImGuiComboFlags.HeightLarge | ImGuiComboFlags.HeightLargest,
}

alias ImGuiTabBarFlags_ = int;
enum ImGuiTabBarFlags: ImGuiTabBarFlags_{
	None                           = 0,
	Reorderable                    = 1 << 0,
	AutoSelectNewTabs              = 1 << 1,
	TabListPopupButton             = 1 << 2,
	NoCloseWithMiddleMouseButton   = 1 << 3,
	NoTabListScrollingButtons      = 1 << 4,
	NoTooltip                      = 1 << 5,
	FittingPolicyResizeDown        = 1 << 6,
	FittingPolicyScroll            = 1 << 7,
	FittingPolicyMask_             = ImGuiTabBarFlags.FittingPolicyResizeDown | ImGuiTabBarFlags.FittingPolicyScroll,
	FittingPolicyDefault_          = ImGuiTabBarFlags.FittingPolicyResizeDown,
}

alias ImGuiTabItemFlags_ = int;
enum ImGuiTabItemFlags: ImGuiTabItemFlags_{
	None                          = 0,
	UnsavedDocument               = 1 << 0,
	SetSelected                   = 1 << 1,
	NoCloseWithMiddleMouseButton  = 1 << 2,
	NoPushId                      = 1 << 3,
	NoTooltip                     = 1 << 4,
	NoReorder                     = 1 << 5,
	Leading                       = 1 << 6,
	Trailing                      = 1 << 7,
}

alias ImGuiTableFlags_ = int;
enum ImGuiTableFlags: ImGuiTableFlags_{
	None                  = 0,
	Resizable             = 1 << 0,
	Reorderable           = 1 << 1,
	Hideable              = 1 << 2,
	Sortable              = 1 << 3,
	NoSavedSettings       = 1 << 4,
	ContextMenuInBody     = 1 << 5,
	
	RowBg                 = 1 << 6,
	BordersInnerH         = 1 << 7,
	BordersOuterH         = 1 << 8,
	BordersInnerV         = 1 << 9,
	BordersOuterV         = 1 << 10,
	BordersH              = ImGuiTableFlags.BordersInnerH | ImGuiTableFlags.BordersOuterH,
	BordersV              = ImGuiTableFlags.BordersInnerV | ImGuiTableFlags.BordersOuterV,
	BordersInner          = ImGuiTableFlags.BordersInnerV | ImGuiTableFlags.BordersInnerH,
	BordersOuter          = ImGuiTableFlags.BordersOuterV | ImGuiTableFlags.BordersOuterH,
	Borders               = ImGuiTableFlags.BordersInner | ImGuiTableFlags.BordersOuter,
	NoBordersInBody       = 1 << 11,
	NoBordersInBodyUntilResize = 1 << 12,
	
	SizingFixedFit        = 1 << 13,
	SizingFixedSame       = 2 << 13,
	SizingStretchProp     = 3 << 13,
	SizingStretchSame     = 4 << 13,
	
	NoHostExtendX         = 1 << 16,
	NoHostExtendY         = 1 << 17,
	NoKeepColumnsVisible  = 1 << 18,
	PreciseWidths         = 1 << 19,
	
	NoClip                = 1 << 20,
	
	PadOuterX             = 1 << 21,
	NoPadOuterX           = 1 << 22,
	NoPadInnerX           = 1 << 23,
	
	ScrollX               = 1 << 24,
	ScrollY               = 1 << 25,
	
	SortMulti             = 1 << 26,
	SortTristate          = 1 << 27,
	
	SizingMask_           = ImGuiTableFlags.SizingFixedFit | ImGuiTableFlags.SizingFixedSame | ImGuiTableFlags.SizingStretchProp | ImGuiTableFlags.SizingStretchSame,
}

alias ImGuiTableColumnFlags_ = int;
enum ImGuiTableColumnFlags: ImGuiTableColumnFlags_{
	None                  = 0,
	Disabled              = 1 << 0,
	DefaultHide           = 1 << 1,
	DefaultSort           = 1 << 2,
	WidthStretch          = 1 << 3,
	WidthFixed            = 1 << 4,
	NoResize              = 1 << 5,
	NoReorder             = 1 << 6,
	NoHide                = 1 << 7,
	NoClip                = 1 << 8,
	NoSort                = 1 << 9,
	NoSortAscending       = 1 << 10,
	NoSortDescending      = 1 << 11,
	NoHeaderLabel         = 1 << 12,
	NoHeaderWidth         = 1 << 13,
	PreferSortAscending   = 1 << 14,
	PreferSortDescending  = 1 << 15,
	IndentEnable          = 1 << 16,
	IndentDisable         = 1 << 17,
	
	IsEnabled             = 1 << 24,
	IsVisible             = 1 << 25,
	IsSorted              = 1 << 26,
	IsHovered             = 1 << 27,
	
	WidthMask_            = ImGuiTableColumnFlags.WidthStretch | ImGuiTableColumnFlags.WidthFixed,
	IndentMask_           = ImGuiTableColumnFlags.IndentEnable | ImGuiTableColumnFlags.IndentDisable,
	StatusMask_           = ImGuiTableColumnFlags.IsEnabled | ImGuiTableColumnFlags.IsVisible | ImGuiTableColumnFlags.IsSorted | ImGuiTableColumnFlags.IsHovered,
	NoDirectResize_       = 1 << 30,
}

alias ImGuiTableRowFlags_ = int;
enum ImGuiTableRowFlags: ImGuiTableRowFlags_{
	None                     = 0,
	Headers                  = 1 << 0,
}

alias ImGuiTableBgTarget_ = int;
enum ImGuiTableBgTarget: ImGuiTableBgTarget_{
	None    = 0,
	RowBg0  = 1,
	RowBg1  = 2,
	CellBg  = 3,
}

alias ImGuiFocusedFlags_ = int;
enum ImGuiFocusedFlags: ImGuiFocusedFlags_{
	None                 = 0,
	ChildWindows         = 1 << 0,
	RootWindow           = 1 << 1,
	AnyWindow            = 1 << 2,
	NoPopupHierarchy     = 1 << 3,
	s_DockHierarchy      = 1 << 4,
	RootAndChildWindows  = ImGuiFocusedFlags.RootWindow | ImGuiFocusedFlags.ChildWindows,
}

alias ImGuiHoveredFlags_ = int;
enum ImGuiHoveredFlags: ImGuiHoveredFlags_{
	None                          = 0,
	ChildWindows                  = 1 << 0,
	RootWindow                    = 1 << 1,
	AnyWindow                     = 1 << 2,
	NoPopupHierarchy              = 1 << 3,
	s_DockHierarchy               = 1 << 4,
	AllowWhenBlockedByPopup       = 1 << 5,
	s_AllowWhenBlockedByModal     = 1 << 6,
	AllowWhenBlockedByActiveItem  = 1 << 7,
	AllowWhenOverlapped           = 1 << 8,
	AllowWhenDisabled             = 1 << 9,
	NoNavOverride                 = 1 << 10,
	RectOnly                      = ImGuiHoveredFlags.AllowWhenBlockedByPopup | ImGuiHoveredFlags.AllowWhenBlockedByActiveItem | ImGuiHoveredFlags.AllowWhenOverlapped,
	RootAndChildWindows           = ImGuiHoveredFlags.RootWindow | ImGuiHoveredFlags.ChildWindows,
	
	DelayNormal                   = 1 << 11,
	DelayShort                    = 1 << 12,
	NoSharedDelay                 = 1 << 13,
}

alias ImGuiDragDropFlags_ = int;
enum ImGuiDragDropFlags: ImGuiDragDropFlags_{
	None                      = 0,
	
	SourceNoPreviewTooltip    = 1 << 0,
	SourceNoDisableHover      = 1 << 1,
	SourceNoHoldToOpenOthers  = 1 << 2,
	SourceAllowNullID         = 1 << 3,
	SourceExtern              = 1 << 4,
	SourceAutoExpirePayload   = 1 << 5,
	
	AcceptBeforeDelivery      = 1 << 10,
	AcceptNoDrawDefaultRect   = 1 << 11,
	AcceptNoPreviewTooltip    = 1 << 12,
	AcceptPeekOnly            = ImGuiDragDropFlags.AcceptBeforeDelivery | ImGuiDragDropFlags.AcceptNoDrawDefaultRect,
}

enum IMGUI_PAYLOAD_TYPE_COLOR_3F = "_COL3F";
enum IMGUI_PAYLOAD_TYPE_COLOR_4F = "_COL4F";

alias ImGuiDataType_ = int;
enum ImGuiDataType: ImGuiDataType_{
	S8,
	U8,
	S16,
	U16,
	S32,
	U32,
	S64,
	U64,
	Float,
	Double,
	COUNT,
}

alias ImGuiDir_ = int;
enum ImGuiDir: ImGuiDir_{
	None   = -1,
	Left   = 0,
	Right  = 1,
	Up     = 2,
	Down   = 3,
	COUNT,
}

alias ImGuiSortDirection_ = int;
enum ImGuiSortDirection: ImGuiSortDirection_{
	None        = 0,
	Ascending   = 1,
	Descending  = 2
}

alias ImGuiKey_ = int;
enum ImGuiKey: ImGuiKey_{
	None = 0,
	Tab = 512,
	LeftArrow,
	RightArrow,
	UpArrow,
	DownArrow,
	PageUp,
	PageDown,
	Home,
	End,
	Insert,
	Delete,
	Backspace,
	Space,
	Enter,
	Escape,
	LeftCtrl, LeftShift, LeftAlt, LeftSuper,
	RightCtrl, RightShift, RightAlt, RightSuper,
	Menu,
	_0, _1, _2, _3, _4, _5, _6, _7, _8, _9,
	A, B, C, D, E, F, G, H, I, J,
	K, L, M, N, O, P, Q, R, S, T,
	U, V, W, X, Y, Z,
	F1, F2, F3, F4, F5, F6,
	F7, F8, F9, F10, F11, F12,
	Apostrophe,
	Comma,
	Minus,
	Period,
	Slash,
	Semicolon,
	Equal,
	LeftBracket,
	Backslash,
	RightBracket,
	GraveAccent,
	CapsLock,
	ScrollLock,
	NumLock,
	PrintScreen,
	Pause,
	Keypad0, Keypad1, Keypad2, Keypad3, Keypad4,
	Keypad5, Keypad6, Keypad7, Keypad8, Keypad9,
	KeypadDecimal,
	KeypadDivide,
	KeypadMultiply,
	KeypadSubtract,
	KeypadAdd,
	KeypadEnter,
	KeypadEqual,
	
	GamepadStart,
	GamepadBack,
	GamepadFaceLeft,
	GamepadFaceRight,
	GamepadFaceUp,
	GamepadFaceDown,
	GamepadDpadLeft,
	GamepadDpadRight,
	GamepadDpadUp,
	GamepadDpadDown,
	GamepadL1,
	GamepadR1,
	GamepadL2,
	GamepadR2,
	GamepadL3,
	GamepadR3,
	GamepadLStickLeft,
	GamepadLStickRight,
	GamepadLStickUp,
	GamepadLStickDown,
	GamepadRStickLeft,
	GamepadRStickRight,
	GamepadRStickUp,
	GamepadRStickDown,
	
	MouseLeft, MouseRight, MouseMiddle, MouseX1, MouseX2, MouseWheelX, MouseWheelY,
	
	ReservedForModCtrl, ReservedForModShift, ReservedForModAlt, ReservedForModSuper,
	COUNT,
	
	NamedKey_BEGIN         = 512,
	NamedKey_END           = ImGuiKey.COUNT,
	NamedKey_COUNT         = ImGuiKey.NamedKey_END - ImGuiKey.NamedKey_BEGIN,
	KeysData_SIZE          = ImGuiKey.COUNT,
	KeysData_OFFSET        = 0,
	ModCtrl = ImGuiMod.Ctrl, ModShift = ImGuiMod.Shift, ModAlt = ImGuiMod.Alt, ModSuper = ImGuiMod.Super,
	KeyPadEnter = ImGuiKey.KeypadEnter,
}
enum ImGuiMod: ImGuiKey_{
	None                   = 0,
	Ctrl                   = 1 << 12,
	Shift                  = 1 << 13,
	Alt                    = 1 << 14,
	Super                  = 1 << 15,
	Shortcut               = 1 << 11,
	Mask_                  = 0xF800,
}

alias ImGuiConfigFlags_ = int;
enum ImGuiConfigFlags: ImGuiConfigFlags_{
	None                  = 0,
	NavEnableKeyboard     = 1 << 0,
	NavEnableGamepad      = 1 << 1,
	NavEnableSetMousePos  = 1 << 2,
	NavNoCaptureKeyboard  = 1 << 3,
	NoMouse               = 1 << 4,
	NoMouseCursorChange   = 1 << 5,
	
	IsSRGB                = 1 << 20,
	IsTouchScreen         = 1 << 21,
}

alias ImGuiBackendFlags_ = int;
enum ImGuiBackendFlags: ImGuiBackendFlags_{
	None                  = 0,
	HasGamepad            = 1 << 0,
	HasMouseCursors       = 1 << 1,
	HasSetMousePos        = 1 << 2,
	RendererHasVtxOffset  = 1 << 3,
}

alias ImGuiCol_ = int;
enum ImGuiCol: ImGuiCol_{
	Text,
	TextDisabled,
	WindowBg,
	ChildBg,
	PopupBg,
	Border,
	BorderShadow,
	FrameBg,
	FrameBgHovered,
	FrameBgActive,
	TitleBg,
	TitleBgActive,
	TitleBgCollapsed,
	MenuBarBg,
	ScrollbarBg,
	ScrollbarGrab,
	ScrollbarGrabHovered,
	ScrollbarGrabActive,
	CheckMark,
	SliderGrab,
	SliderGrabActive,
	Button,
	ButtonHovered,
	ButtonActive,
	Header,
	HeaderHovered,
	HeaderActive,
	Separator,
	SeparatorHovered,
	SeparatorActive,
	ResizeGrip,
	ResizeGripHovered,
	ResizeGripActive,
	Tab,
	TabHovered,
	TabActive,
	TabUnfocused,
	TabUnfocusedActive,
	PlotLines,
	PlotLinesHovered,
	PlotHistogram,
	PlotHistogramHovered,
	TableHeaderBg,
	TableBorderStrong,
	TableBorderLight,
	TableRowBg,
	TableRowBgAlt,
	TextSelectedBg,
	DragDropTarget,
	NavHighlight,
	NavWindowingHighlight,
	NavWindowingDimBg,
	ModalWindowDimBg,
	COUNT,
}

alias ImGuiStyleVar_ = int;
enum ImGuiStyleVar: ImGuiStyleVar_{
	Alpha,
	DisabledAlpha,
	WindowPadding,
	WindowRounding,
	WindowBorderSize,
	WindowMinSize,
	WindowTitleAlign,
	ChildRounding,
	ChildBorderSize,
	PopupRounding,
	PopupBorderSize,
	FramePadding,
	FrameRounding,
	FrameBorderSize,
	ItemSpacing,
	ItemInnerSpacing,
	IndentSpacing,
	CellPadding,
	ScrollbarSize,
	ScrollbarRounding,
	GrabMinSize,
	GrabRounding,
	TabRounding,
	ButtonTextAlign,
	SelectableTextAlign,
	SeparatorTextBorderSize,
	SeparatorTextAlign,
	SeparatorTextPadding,
	COUNT,
}

alias ImGuiButtonFlags_ = int;
enum ImGuiButtonFlags: ImGuiButtonFlags_{
	None                   = 0,
	MouseButtonLeft        = 1 << 0,
	MouseButtonRight       = 1 << 1,
	MouseButtonMiddle      = 1 << 2,
	
	MouseButtonMask_       = ImGuiButtonFlags.MouseButtonLeft | ImGuiButtonFlags.MouseButtonRight | ImGuiButtonFlags.MouseButtonMiddle,
	MouseButtonDefault_    = ImGuiButtonFlags.MouseButtonLeft,
}

alias ImGuiColorEditFlags_ = int;
alias ImGuiColourEditFlags_ = ImGuiColorEditFlags_;
enum ImGuiColorEditFlags: ImGuiColorEditFlags_{
	None              = 0,
	NoAlpha           = 1 << 1,
	NoPicker          = 1 << 2,
	NoOptions         = 1 << 3,
	NoSmallPreview    = 1 << 4,
	NoInputs          = 1 << 5,
	NoTooltip         = 1 << 6,
	NoLabel           = 1 << 7,
	NoSidePreview     = 1 << 8,
	NoDragDrop        = 1 << 9,
	NoBorder          = 1 << 10,
	
	AlphaBar          = 1 << 16,
	AlphaPreview      = 1 << 17,
	AlphaPreviewHalf  = 1 << 18,
	HDR               = 1 << 19,
	DisplayRGB        = 1 << 20,
	DisplayHSV        = 1 << 21,
	DisplayHex        = 1 << 22,
	Uint8             = 1 << 23,
	Float             = 1 << 24,
	PickerHueBar      = 1 << 25,
	PickerHueWheel    = 1 << 26,
	InputRGB          = 1 << 27,
	InputHSV          = 1 << 28,
	
	DefaultOptions_   = ImGuiColorEditFlags.Uint8 | ImGuiColorEditFlags.DisplayRGB | ImGuiColorEditFlags.InputRGB | ImGuiColorEditFlags.PickerHueBar,
	
	DisplayMask_      = ImGuiColorEditFlags.DisplayRGB | ImGuiColorEditFlags.DisplayHSV | ImGuiColorEditFlags.DisplayHex,
	DataTypeMask_     = ImGuiColorEditFlags.Uint8 | ImGuiColorEditFlags.Float,
	PickerMask_       = ImGuiColorEditFlags.PickerHueWheel | ImGuiColorEditFlags.PickerHueBar,
	InputMask_        = ImGuiColorEditFlags.InputRGB | ImGuiColorEditFlags.InputHSV,
}
alias ImGuiColourEditFlags = ImGuiColorEditFlags;

alias ImGuiSliderFlags_ = int;
enum ImGuiSliderFlags: ImGuiSliderFlags_{
	None               = 0,
	AlwaysClamp        = 1 << 4,
	Logarithmic        = 1 << 5,
	NoRoundToFormat    = 1 << 6,
	NoInput            = 1 << 7,
	InvalidMask_       = 0x7000000F,
}

alias ImGuiMouseButton_ = int;
enum ImGuiMouseButton: ImGuiMouseButton_{
	Left    = 0,
	Right   = 1,
	Middle  = 2,
	COUNT   = 5,
}

alias ImGuiMouseCursor_ = int;
enum ImGuiMouseCursor: ImGuiMouseCursor_{
	None = -1,
	Arrow = 0,
	TextInput,
	ResizeAll,
	ResizeNS,
	ResizeEW,
	ResizeNESW,
	ResizeNWSE,
	Hand,
	NotAllowed,
	COUNT,
}

alias ImGuiMouseSource_ = int;
enum ImGuiMouseSource: ImGuiMouseSource_{
	Mouse = 0,
	TouchScreen,
	Pen,
	COUNT,
};

alias ImGuiCond_ = int;
enum ImGuiCond: ImGuiCond_{
	None          = 0,
	Always        = 1 << 0,
	Once          = 1 << 1,
	FirstUseEver  = 1 << 2,
	Appearing     = 1 << 3,
}

extern(C++) struct ImVector(T){
	int Size = 0;
	int Capacity = 0;
	T* Data = null;
	
	alias value_type = T;
	alias iterator = value_type*;
	alias const_iterator = const(value_type)*;
	
	nothrow @nogc:
	pragma(inline,true){
		this(const ImVector!T src){ this = src; }
		ImVector!T opAssign(const ImVector!T src){
			clear();
			resize(src.Size);
			if(src.Data !is null) memcpy(Data, src.Data, cast(size_t)Size * T.sizeof);
			return this;
		}
		~this(){
			if(Data) IM_FREE(Data);
		}
		
		void clear(){
			if(Data){
				Size = Capacity = 0;
				IM_FREE(Data);
				Data = null;
			}
		}
		static if(__traits(hasMember, T, "__dtor__")){
			void clear_delete(){
				for(int n = 0; n < Size; n++) IM_DELETE(Data[n]);
				clear();
			}
			void clear_destruct(){
				for(int n = 0; n < Size; n++) Data[n].__dtor__();
				clear();
			}
		}
		
		bool empty() const{ return Size == 0; }
		int size() const{ return Size; }
		int size_in_bytes() const{ return Size * cast(int)T.sizeof; }
		int max_size() const{ return 0x7FFFFFFF / cast(int)T.sizeof; }
		int capacity() const{ return Capacity; }
		ref T opIndex(int i) {
			assert(i >= 0 && i < Size);
			return Data[i];
		}
		ref const(T) opIndex(int i) const{
			assert(i >= 0 && i < Size);
			return Data[i];
		}
		
		inout(T)* begin() inout{ return Data; }
		inout(T)* end() inout{ return Data + Size; }
		ref inout(T) front() inout{
			assert(Size > 0);
			return Data[0];
		}
		ref inout(T) back() inout{
			assert(Size > 0);
			return Data[Size - 1];
		}
		void swap(ref ImVector!T rhs){
			int rhs_size = rhs.Size;
			rhs.Size = Size;
			Size = rhs_size;
			int rhs_cap = rhs.Capacity;
			rhs.Capacity = Capacity;
			Capacity = rhs_cap;
			T* rhs_data = rhs.Data;
			rhs.Data = Data;
			Data = rhs_data;
		}
		
		int _grow_capacity(int sz) const{
			int new_capacity = Capacity ? (Capacity + Capacity / 2) : 8;
			return new_capacity > sz ? new_capacity : sz;
		}
		void resize(int new_size){
			if(new_size > Capacity) reserve(_grow_capacity(new_size));
			Size = new_size;
		}
		void resize(int new_size, const T v){
			if(new_size > Capacity) reserve(_grow_capacity(new_size));
			if(new_size > Size){
				for(int n = Size; n < new_size; n++) memcpy(&Data[n], &v, v.sizeof);
			}
			Size = new_size;
		}
		void shrink(int new_size){
			assert(new_size <= Size);
			Size = new_size;
		}
		void reserve(int new_capacity){
			if(new_capacity <= Capacity) return;
			T* new_data = cast(T*)IM_ALLOC(cast(size_t)new_capacity * T.sizeof);
			if(Data){
				memcpy(new_data, Data, cast(size_t)Size * T.sizeof);
				IM_FREE(Data);
			}
			Data = new_data;
			Capacity = new_capacity;
		}
		void reserve_discard(int new_capacity){
			if(new_capacity <= Capacity) return;
			if(Data) IM_FREE(Data);
			Data = cast(T*)IM_ALLOC(cast(size_t)new_capacity * T.sizeof);
			Capacity = new_capacity;
		}
		
		void push_back(const T v){
			if(Size == Capacity) reserve(_grow_capacity(Size + 1));
			memcpy(&Data[Size], &v, v.sizeof);
			Size++;
		}
		void pop_back(){
			assert(Size > 0);
			Size--;
		}
		void push_front(const T v){
			if(Size == 0) push_back(v);
			else insert(Data, v);
		}
		T* erase(const(T)* it){
			assert(it >= Data && it < Data + Size);
			const ptrdiff_t off = it - Data;
			memmove(Data + off, Data + off + 1, (cast(size_t)Size - cast(size_t)off - 1) * T.sizeof);
			Size--;
			return Data + off;
		}
		T* erase(const(T)* it, const(T)* it_last){
			assert(it >= Data && it < Data + Size && it_last >= it && it_last <= Data + Size);
			const ptrdiff_t count = it_last - it;
			const ptrdiff_t off = it - Data;
			memmove(Data + off, Data + off + count, (cast(size_t)Size - cast(size_t)off - cast(size_t)count) * T.sizeof);
			Size -= cast(int)count;
			return Data + off;
		}
		T* erase_unsorted(const(T)* it){
			assert(it >= Data && it < Data + Size);
			const ptrdiff_t off = it - Data;
			if(it < Data + Size - 1) memcpy(Data + off, Data + Size - 1, T.sizeof);
			Size--;
			return Data + off;
		}
		T* insert(const(T)* it, const T v){
			assert(it >= Data && it <= Data + Size);
			const ptrdiff_t off = it - Data;
			if(Size == Capacity) reserve(_grow_capacity(Size + 1));
			if(off < cast(int)Size) memmove(Data + off + 1, Data + off, (cast(size_t)Size - cast(size_t)off) * T.sizeof);
			memcpy(&Data[off], &v, v.sizeof);
			Size++;
			return Data + off;
		}
		bool contains(const T v) const{
			const(T)* data = Data;
			const(T)* data_end = Data + Size;
			while(data < data_end){
				if(*(data++) == v) return true;
			}
			return false;
		}
		inout(T)* find(const T v) inout{
			inout(T)* data = Data;
			const(T)* data_end = Data + Size;
			while(data < data_end){
				if(*data == v) break;
				else ++data;
			}
			return data;
		}
		bool find_erase(const T v){
			const(T)* it = find(v);
			if(it < Data + Size){
				erase(it);
				return true;
			}
			return false;
		}
		bool find_erase_unsorted(const T v){
			const(T)* it = find(v);
			if(it < Data + Size){
				erase_unsorted(it);
				return true;
			}
			return false;
		}
		int index_from_ptr(const(T)* it) const{
			assert(it >= Data && it < Data + Size);
			const ptrdiff_t off = it - Data;
			return cast(int)off;
		}
	}
}

extern(C++) struct ImGuiStyle{
	float Alpha = 1f;
	float DisabledAlpha = 0.6f;
	ImVec2 WindowPadding = ImVec2(8, 8);
	float WindowRounding = 0f;
	float WindowBorderSize = 1f;
	ImVec2 WindowMinSize = ImVec2(32, 32);
	ImVec2 WindowTitleAlign = ImVec2(0f, 0.5f);
	ImGuiDir_ WindowMenuButtonPosition = ImGuiDir.Left;
	float ChildRounding = 0f;
	float ChildBorderSize = 1f;
	float PopupRounding = 0f;
	float PopupBorderSize = 1f;
	ImVec2 FramePadding = ImVec2(4, 3);
	float FrameRounding = 0f;
	float FrameBorderSize = 0f;
	ImVec2 ItemSpacing = ImVec2(8, 4);
	ImVec2 ItemInnerSpacing = ImVec2(4, 4);
	ImVec2 CellPadding = ImVec2(4, 2);
	ImVec2 TouchExtraPadding = ImVec2(0, 0);
	float IndentSpacing = 21f;
	float ColumnsMinSpacing = 6f;
	float ScrollbarSize = 14f;
	float ScrollbarRounding = 9f;
	float GrabMinSize = 12f;
	float GrabRounding = 0f;
	float LogSliderDeadzone = 4f;
	float TabRounding = 4f;
	float TabBorderSize = 0f;
	float TabMinWidthForCloseButton = 0f;
	ImGuiDir_ ColorButtonPosition = ImGuiDir.Right;
	alias ColourButtonPosition = ColorButtonPosition;
	ImVec2 ButtonTextAlign = ImVec2(0.5f, 0.5f);
	ImVec2 SelectableTextAlign = ImVec2(0f, 0f);
	float SeparatorTextBorderSize = 3f;
	ImVec2 SeparatorTextAlign = ImVec2(0f, 0.5f);
	ImVec2 SeparatorTextPadding = ImVec2(20f, 3f);
	ImVec2 DisplayWindowPadding = ImVec2(19, 19);
	ImVec2 DisplaySafeAreaPadding = ImVec2(3, 3);
	float MouseCursorScale = 1f;
	bool AntiAliasedLines = true;
	bool AntiAliasedLinesUseTex = true;
	bool AntiAliasedFill = true;
	float CurveTessellationTol = 1.25f;
	float CircleTessellationMaxError = 0.3f;
	ImVec4[ImGuiCol.COUNT] Colors;
	alias Colours = Colors;
	
	nothrow @nogc:
	pragma(mangle, [__traits(identifier, typeof(this))].mangleofCppDefaultCtor()) this(int _);
	void ScaleAllSizes(float scale_factor);
}

extern(C++) struct ImGuiKeyData{
	bool Down;
	float DownDuration;
	float DownDurationPrev;
	float AnalogValue;
}

extern(C++) struct ImGuiIO{
	ImGuiConfigFlags_ ConfigFlags = 0;
	ImGuiBackendFlags_ BackendFlags = 0;
	ImVec2 DisplaySize = ImVec2(-1.0f, -1.0f);
	float DeltaTime = 1f/60f;
	float IniSavingRate = 5f;
	const(char)* IniFilename = "imgui.ini";
	const(char)* LogFilename = "imgui_log.txt";
	float MouseDoubleClickTime = 0.3f;
	float MouseDoubleClickMaxDist = 6f;
	float MouseDragThreshold = 6f;
	float KeyRepeatDelay = 0.275f;
	float KeyRepeatRate = 0.05f;
	float HoverDelayNormal = 0.3f;
	float HoverDelayShort = 0.1f;
	void* UserData = null;
	
	ImFontAtlas* Fonts = null;
	float FontGlobalScale = 1f;
	bool FontAllowUserScaling = false;
	ImFont* FontDefault = null;
	ImVec2 DisplayFramebufferScale = ImVec2(1f, 1f);
	
	bool MouseDrawCursor = false;
	bool ConfigMacOSXBehaviors = (){ version(OSX) return true; else return false; }();
	bool ConfigInputTrickleEventQueue = true;
	bool ConfigInputTextCursorBlink = true;
	bool ConfigInputTextEnterKeepActive = false;
	bool ConfigDragClickToInputText = false;
	bool ConfigWindowsResizeFromEdges = true;
	bool ConfigWindowsMoveFromTitleBarOnly;
	float ConfigMemoryCompactTimer = 60f;
	
	bool ConfigDebugBeginReturnValueOnce = false;
	bool ConfigDebugBeginReturnValueLoop = false;
	bool ConfigDebugIgnoreFocusLoss = false;
	
	const(char)* BackendPlatformName = null;
	const(char)* BackendRendererName = null;
	void* BackendPlatformUserData = null;
	void* BackendRendererUserData = null;
	void* BackendLanguageUserData = null;
	
	extern(C++) const(char)* function(void* user_data) GetClipboardTextFn;
	extern(C++) void function(void* user_data, const(char)* text) SetClipboardTextFn;
	void* ClipboardUserData;
	
	extern(C++) void function(ImGuiViewport* viewport, ImGuiPlatformImeData* data) SetPlatformImeDataFn;
version(ImGui_DisableObsoleteFunctions){
	void* ImeWindowHandle;
}else{
	void* _UnusedPadding;
}
	
	bool WantCaptureMouse;
	bool WantCaptureKeyboard;
	bool WantTextInput;
	bool WantSetMousePos;
	bool WantSaveIniSettings;
	bool NavActive;
	bool NavVisible;
	float Framerate;
	int MetricsRenderVertices;
	int MetricsRenderIndices;
	int MetricsRenderWindows;
	int MetricsActiveWindows;
	int MetricsActiveAllocations;
	ImVec2 MouseDelta;
	
	ImGuiContext* Ctx;
	
	ImVec2 MousePos = ImVec2(float.max, -float.max);
	bool[5] MouseDown;
	float MouseWheel;
	float MouseWheelH;
	ImGuiMouseSource_ MouseSource;
	bool KeyCtrl;
	bool KeyShift;
	bool KeyAlt;
	bool KeySuper;
	
	ImGuiKeyChord KeyMods;
	ImGuiKeyData[ImGuiKey.KeysData_SIZE] KeysData;
	bool WantCaptureMouseUnlessPopupClose;
	ImVec2 MousePosPrev = ImVec2(float.max, -float.max);
	ImVec2[5] MouseClickedPos;
	double[5] MouseClickedTime;
	bool[5] MouseClicked;
	bool[5] MouseDoubleClicked;
	ushort[5] MouseClickedCount;
	ushort[5] MouseClickedLastCount;
	bool[5] MouseReleased;
	bool[5] MouseDownOwned;
	bool[5] MouseDownOwnedUnlessPopupClose;
	bool MouseWheelRequestAxisSwap;
	float[5] MouseDownDuration;
	float[5] MouseDownDurationPrev;
	float[5] MouseDragMaxDistanceSqr;
	float PenPressure;
	bool AppFocusLost;
	bool AppAcceptingEvents = true;
	byte BackendUsingLegacyKeyArrays = cast(byte)-1;
	bool BackendUsingLegacyNavInputArray = true;
	wchar InputQueueSurrogate;
	ImVector!ImWchar InputQueueCharacters;
	
	nothrow @nogc:
	void AddKeyEvent(ImGuiKey_ key, bool down);
	void AddKeyAnalogEvent(ImGuiKey_ key, bool down, float v);
	void AddMousePosEvent(float x, float y);
	void AddMouseButtonEvent(int button, bool down);
	void AddMouseWheelEvent(float wheel_x, float wheel_y);
	void AddMouseSourceEvent(ImGuiMouseSource_ source);
	void AddFocusEvent(bool focused);
	void AddInputCharacter(uint c);
	void AddInputCharacterUTF16(wchar c);
	void AddInputCharactersUTF8(const(char)* str);
	
	void SetKeyEventNativeData(ImGuiKey_ key, int native_keycode, int native_scancode, int native_legacy_index=-1);
	void SetAppAcceptingEvents(bool accepting_events);
	void ClearInputCharacters();
	void ClearInputKeys();
	
	pragma(mangle, [__traits(identifier, typeof(this))].mangleofCppDefaultCtor()) this(int _);
}

extern(C++) struct ImGuiInputTextCallbackData{
	ImGuiContext* Ctx = null;
	ImGuiInputTextFlags_ EventFlag = 0;
	ImGuiInputTextFlags_ Flags = 0;
	void* UserData = null;
	
	ImWchar EventChar = 0;
	ImGuiKey_ EventKey = 0;
	char* Buf = null;
	int BufTextLen = 0;
	int BufSize = 0;
	bool BufDirty = false;
	int CursorPos = 0;
	int SelectionStart = 0;
	int SelectionEnd = 0;
	
	nothrow @nogc:
	pragma(mangle, [__traits(identifier, typeof(this))].mangleofCppDefaultCtor()) this(int _);
	void DeleteChars(int pos, int bytes_count);
	void InsertChars(int pos, const(char)* text, const(char)* text_end=null);
	void SelectAll(){ SelectionStart = 0; SelectionEnd = BufTextLen; }
	void ClearSelection(){ SelectionStart = SelectionEnd = BufTextLen; }
	bool HasSelection() const{ return SelectionStart != SelectionEnd; }
}

extern(C++) struct ImGuiSizeCallbackData{
	void* UserData;
	ImVec2 Pos;
	ImVec2 CurrentSize;
	ImVec2 DesiredSize;
}

extern(C++) struct ImGuiPayload{
	void* Data = null;
	int DataSize = 0;
	
	ImGuiID SourceId = 0;
	ImGuiID SourceParentId = 0;
	int DataFrameCount = -1;
	char[32 + 1] DataType;
	bool Preview = false;
	bool Delivery = false;
	
	nothrow @nogc:
	this(int _){ Clear(); }
	void Clear(){
		SourceId = SourceParentId = 0;
		Data = null;
		DataSize = 0;
		memset(cast(void*)DataType.ptr, 0, DataType.sizeof);
		DataFrameCount = -1;
		Preview = Delivery = false;
	}
	bool IsDataType(const(char)* type) const{ return DataFrameCount != -1 && strcmp(type, DataType.ptr) == 0; }
	bool IsPreview() const{ return Preview; }
	bool IsDelivery() const{ return Delivery; }
}

extern(C++) struct ImGuiTableColumnSortSpecs{
	ImGuiID ColumnUserID = 0;
	short ColumnIndex = 0;
	short SortOrder = 0;
	ImGuiSortDirection_ SortDirection = 0; //NOTE: 8 bit-field
}
static assert(ImGuiTableColumnSortSpecs.sizeof == 12);

extern(C++) struct ImGuiTableSortSpecs{
	const(ImGuiTableColumnSortSpecs)* Specs = null;
	int SpecsCount = 0;
	bool SpecsDirty = 0;
}

enum IM_UNICODE_CODEPOINT_INVALID = 0xFFFD;
version(ImGui_WChar32){
	enum IM_UNICODE_CODEPOINT_MAX = 0x10FFFF;
}else{
	enum IM_UNICODE_CODEPOINT_MAX = 0xFFFF;
}

extern(C++) struct ImGuiOnceUponAFrame{
	int RefFrame = -1; //NOTE: originally delcared as `mutable`
	
	nothrow @nogc:
	T opCast(T: bool)() const{
		int current_frame = GetFrameCount();
		if(RefFrame == current_frame) return false;
		RefFrame = current_frame;
		return true;
	}
}

extern(C++) struct ImGuiTextFilter{
	extern(C++) struct ImGuiTextRange{
		const(char)* b = null;
		const(char)* e = null;
		
		nothrow @nogc:
		bool empty() const{ return b == e; }
		void split(char separator, ImVector!(ImGuiTextRange)* out_) const;
	}
	ImGuiTextRange range;
	char[256] InputBuf;
	ImVector!ImGuiTextRange Filters;
	int CountGrep;

	nothrow @nogc:
	this(const(char)* default_filter);
	bool Draw(const(char)* label="Filter (inc,-exc)", float width=0f);
	bool PassFilter(const(char)* text, const(char)* text_end=null) const;
	void Build();
	void Clear(){
		InputBuf[0] = 0;
		Build();
	}
	bool IsActive() const{ return !Filters.empty(); }
}

extern(C++) struct ImGuiTextBuffer{
	ImVector!char Buf;
	extern static __gshared char[1] EmptyString;

	nothrow @nogc:
	pragma(inline,true) char opIndex(int i) const{ assert(Buf.Data != null); return Buf.Data[i]; }
	const(char)* begin() const{ return Buf.Data ? &Buf.front() : EmptyString.ptr; }
	const(char)* end() const{ return Buf.Data ? &Buf.back() : EmptyString.ptr; }
	int size() const{ return Buf.Size ? Buf.Size - 1 : 0; }
	bool empty() const{ return Buf.Size <= 1; }
	void clear(){ Buf.clear(); }
	void reserve(int capacity){ Buf.reserve(capacity); }
	const(char)* c_str() const{ return Buf.Data ? Buf.Data : EmptyString.ptr; }
	void append(const(char)* str, const(char)* str_end=null);
	void appendf(const(char)* fmt, ...);
	void appendfv(const(char)* fmt, va_list args);
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
		this(ImGuiID _key, int _val_i){
			key = _key;
			val.i = _val_i;
		}
		this(ImGuiID _key, float _val_f){
			key = _key;
			val.f = _val_f;
		}
		this(ImGuiID _key, void* _val_p){
			key = _key;
			val.p = _val_p;
		}
	}
	ImVector!ImGuiStoragePair Data;
	
	nothrow @nogc:
	void Clear(){ Data.clear(); }
	int GetInt(ImGuiID key, int default_val=0) const;
	void SetInt(ImGuiID key, int val);
	bool GetBool(ImGuiID key, bool default_val=false) const;
	void SetBool(ImGuiID key, bool val);
	float GetFloat(ImGuiID key, float default_val=0f) const;
	void SetFloat(ImGuiID key, float val);
	void* GetVoidPtr(ImGuiID key) const;
	void SetVoidPtr(ImGuiID key, void* val);
	
	int* GetIntRef(ImGuiID key, int default_val=0);
	bool* GetBoolRef(ImGuiID key, bool default_val=false);
	float* GetFloatRef(ImGuiID key, float default_val=0f);
	void** GetVoidPtrRef(ImGuiID key, void* default_val=null);
	
	void SetAllInt(int val);
	
	void BuildSortByKey();
}

extern(C++) struct ImGuiListClipper{
	ImGuiContext* Ctx;
	int DisplayStart;
	int DisplayEnd;
	int ItemsCount;
	float ItemsHeight;
	float StartPosY;
	void* TempData;

	nothrow @nogc:
	pragma(mangle, [__traits(identifier, typeof(this))].mangleofCppDefaultCtor()) this(int _);
	~this();
	void Begin(int items_count, float items_height=-1f);
	void End();
	bool Step();
	
	void IncludeRangeByIndices(int item_begin, int item_end);
	
	version(ImGui_DisableObsoleteFunctions){
	}else{
		pragma(inline,true) void ForceDisplayRangeByIndices(int item_begin, int item_end){ IncludeRangeByIndices(item_begin, item_end); }
	}
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
uint IM_COL32(uint R, uint G, uint B, uint A){
	return (cast(uint)(A)<<IM_COL32_A_SHIFT) | (cast(uint)(B)<<IM_COL32_B_SHIFT) | (cast(uint)(G)<<IM_COL32_G_SHIFT) | (cast(uint)(R)<<IM_COL32_R_SHIFT);
}
enum IM_COL32_WHITE = IM_COL32(255,255,255,255);
enum IM_COL32_BLACK = IM_COL32(0,0,0,255);
enum IM_COL32_BLACK_TRANS = IM_COL32(0,0,0,0);

extern(C++) struct ImColor{
	ImVec4 Value;
	
	nothrow @nogc:
	this(float r, float g, float b, float a=1f){ Value = ImVec4(r, g, b, a); }
	this(const ImVec4 col){ Value = col; }
	this(int r, int g, int b, int a=255){
		float sc = 1f / 255f;
		Value.x = cast(float)r * sc;
		Value.y = cast(float)g * sc;
		Value.z = cast(float)b * sc;
		Value.w = cast(float)a * sc;
	}
	this(uint rgba){
		float sc = 1f / 255f;
		Value.x = cast(float)((rgba >> IM_COL32_R_SHIFT) & 0xFF) * sc;
		Value.y = cast(float)((rgba >> IM_COL32_G_SHIFT) & 0xFF) * sc;
		Value.z = cast(float)((rgba >> IM_COL32_B_SHIFT) & 0xFF) * sc;
		Value.w = cast(float)((rgba >> IM_COL32_A_SHIFT) & 0xFF) * sc;
	}
	pragma(inline,true){
		uint opCast(T: uint)() const{ return ColorConvertFloat4ToU32(Value); }
		ImVec4 opCast(T: ImVec4)() const{ return Value; }
		
		void SetHSV(float h, float s, float v, float a=1f){
			ColorConvertHSVtoRGB(h, s, v, Value.x, Value.y, Value.z);
			Value.w = a;
		}
	}
	static ImColor HSV(float h, float s, float v, float a=1f){
		float r, g, b;
		ColorConvertHSVtoRGB(h, s, v, r, g, b);
		return ImColor(r, g, b, a);
	}
}
alias ImColour = ImColor;

enum IM_DRAWLIST_TEX_LINES_WIDTH_MAX = 63;

alias ImDrawCallback = extern(C++) void function(const(ImDrawList)* parent_list, const(ImDrawCmd)* cmd);

enum ImDrawCallback ImDrawCallback_ResetRenderState = cast(ImDrawCallback)-1;

extern(C++) struct ImDrawCmd{
	ImVec4 ClipRect = ImVec4(0, 0, 0, 0);
	ImTextureID TextureId = null;
	uint VtxOffset = 0;
	uint IdxOffset = 0;
	uint ElemCount = 0;
	ImDrawCallback UserCallback = null;
	void* UserCallbackData = null;

	nothrow @nogc:
	pragma(inline,true) ImTextureID GetTexID() const{ return cast(ImTextureID)TextureId; }
}

extern(C++) struct ImDrawVert{
	ImVec2 pos;
	ImVec2 uv;
	uint col;
}

extern(C++) struct ImDrawCmdHeader{
	ImVec4 ClipRect;
	ImTextureID TextureId;
	uint VtxOffset;
}

extern(C++) struct ImDrawChannel{
	ImVector!ImDrawCmd _CmdBuffer;
	ImVector!ImDrawIdx _IdxBuffer;
}

extern(C++) struct ImDrawListSplitter{
	int _Current = 0;
	int _Count = 0;
	ImVector!ImDrawChannel _Channels;

	nothrow @nogc:
	pragma(inline,true){
		~this(){ ClearFreeMemory(); }
		void Clear(){
			_Current = 0;
			_Count = 1;
		}
	}
	void ClearFreeMemory();
	void Split(ImDrawList* draw_list, int count);
	void Merge(ImDrawList* draw_list);
	void SetCurrentChannel(ImDrawList* draw_list, int channel_idx);
}

alias ImDrawFlags_ = int;
enum ImDrawFlags: ImDrawFlags_{
	None                     = 0,
	Closed                   = 1 << 0,
	RoundCornersTopLeft      = 1 << 4,
	RoundCornersTopRight     = 1 << 5,
	RoundCornersBottomLeft   = 1 << 6,
	RoundCornersBottomRight  = 1 << 7,
	RoundCornersNone         = 1 << 8,
	RoundCornersTop          = ImDrawFlags.RoundCornersTopLeft | ImDrawFlags.RoundCornersTopRight,
	RoundCornersBottom       = ImDrawFlags.RoundCornersBottomLeft | ImDrawFlags.RoundCornersBottomRight,
	RoundCornersLeft         = ImDrawFlags.RoundCornersBottomLeft | ImDrawFlags.RoundCornersTopLeft,
	RoundCornersRight        = ImDrawFlags.RoundCornersBottomRight | ImDrawFlags.RoundCornersTopRight,
	RoundCornersAll          = ImDrawFlags.RoundCornersTopLeft | ImDrawFlags.RoundCornersTopRight | ImDrawFlags.RoundCornersBottomLeft | ImDrawFlags.RoundCornersBottomRight,
	RoundCornersDefault_     = ImDrawFlags.RoundCornersAll,
	RoundCornersMask_        = ImDrawFlags.RoundCornersAll | ImDrawFlags.RoundCornersNone,
}

alias ImDrawListFlags_ = int;
enum ImDrawListFlags: ImDrawListFlags_{
	None                    = 0,
	AntiAliasedLines        = 1 << 0,
	AntiAliasedLinesUseTex  = 1 << 1,
	AntiAliasedFill         = 1 << 2,
	AllowVtxOffset          = 1 << 3,
}

extern(C++) struct ImDrawList{
	ImVector!ImDrawCmd CmdBuffer;
	ImVector!ImDrawIdx IdxBuffer;
	ImVector!ImDrawVert VtxBuffer;
	ImDrawListFlags_ Flags = 0;
	
	uint _VtxCurrentIdx = 0;
	ImDrawListSharedData* _Data = null;
	const(char)* _OwnerName = null;
	ImDrawVert* _VtxWritePtr = null;
	ImDrawIdx* _IdxWritePtr = null;
	ImVector!ImVec4 _ClipRectStack;
	ImVector!ImTextureID _TextureIdStack;
	ImVector!ImVec2 _Path;
	ImDrawCmdHeader _CmdHeader = { ClipRect: ImVec4(0,0,0,0), TextureId: null, VtxOffset: 0 };
	ImDrawListSplitter _Splitter;
	float _FringeScale = 0;

	nothrow @nogc:
	this(ImDrawListSharedData* shared_data){ _Data = shared_data; }
	
	~this(){ _ClearFreeMemory(); }
	void PushClipRect(ref const ImVec2 clip_rect_min, ref const ImVec2 clip_rect_max, bool intersect_with_current_clip_rect=false);
	void PushClipRectFullScreen();
	void PopClipRect();
	void PushTextureID(ImTextureID texture_id);
	void PopTextureID();
	pragma(inline,true){
		ImVec2 GetClipRectMin() const{
			const(ImVec4)* cr = &_ClipRectStack.back();
			return ImVec2(cr.x, cr.y);
		}
		ImVec2 GetClipRectMax() const{
			const(ImVec4)* cr = &_ClipRectStack.back();
			return ImVec2(cr.z, cr.w);
		}
	}
	
	void AddLine(ref const ImVec2 p1, ref const ImVec2 p2, uint col, float thickness=1f);
	void AddRect(ref const ImVec2 p_min, ref const ImVec2 p_max, uint col, float rounding=0f, ImDrawFlags_ flags=0, float thickness=1f);
	void AddRectFilled(ref const ImVec2 p_min, ref const ImVec2 p_max, uint col, float rounding=0f, ImDrawFlags_ flags=0);
	void AddRectFilledMultiColor(ref const ImVec2 p_min, ref const ImVec2 p_max, uint col_upr_left, uint col_upr_right, uint col_bot_right, uint col_bot_left);
	void AddQuad(ref const ImVec2 p1, ref const ImVec2 p2, ref const ImVec2 p3, ref const ImVec2 p4, uint col, float thickness=1f);
	void AddQuadFilled(ref const ImVec2 p1, ref const ImVec2 p2, ref const ImVec2 p3, ref const ImVec2 p4, uint col);
	void AddTriangle(ref const ImVec2 p1, ref const ImVec2 p2, ref const ImVec2 p3, uint col, float thickness=1f);
	void AddTriangleFilled(ref const ImVec2 p1, ref const ImVec2 p2, ref const ImVec2 p3, uint col);
	void AddCircle(ref const ImVec2 center, float radius, uint col, int num_segments=0, float thickness=1f);
	void AddCircleFilled(ref const ImVec2 center, float radius, uint col, int num_segments=0);
	void AddNgon(ref const ImVec2 center, float radius, uint col, int num_segments, float thickness=1f);
	void AddNgonFilled(ref const ImVec2 center, float radius, uint col, int num_segments);
	void AddText(ref const ImVec2 pos, uint col, const(char)* text_begin, const(char)* text_end=null);
	void AddText(const(ImFont)* font, float font_size, ref const ImVec2 pos, uint col, const(char)* text_begin, const(char)* text_end=null, float wrap_width=0f, const(ImVec4)* cpu_fine_clip_rect=null);
	void AddPolyline(const(ImVec2)* points, int num_points, uint col, ImDrawFlags_ flags, float thickness);
	void AddConvexPolyFilled(const(ImVec2)* points, int num_points, uint col);
	void AddBezierCubic(ref const ImVec2 p1, ref const ImVec2 p2, ref const ImVec2 p3, ref const ImVec2 p4, uint col, float thickness, int num_segments=0);
	void AddBezierQuadratic(ref const ImVec2 p1, ref const ImVec2 p2, ref const ImVec2 p3, uint col, float thickness, int num_segments=0);
	
	void AddImage(ImTextureID user_texture_id, ref const ImVec2 p_min, ref const ImVec2 p_max, ref const ImVec2 uv_min=Vec2_0_0, ref const ImVec2 uv_max=Vec2_1_1, uint col=IM_COL32_WHITE);
	void AddImageQuad(ImTextureID user_texture_id, ref const ImVec2 p1, ref const ImVec2 p2, ref const ImVec2 p3, ref const ImVec2 p4, ref const ImVec2 uv1=Vec2_0_0, ref const ImVec2 uv2=Vec2_1_0, ref const ImVec2 uv3=Vec2_1_1, ref const ImVec2 uv4=Vec2_0_1, uint col=IM_COL32_WHITE);
	void AddImageRounded(ImTextureID user_texture_id, ref const ImVec2 p_min, ref const ImVec2 p_max, ref const ImVec2 uv_min, ref const ImVec2 uv_max, uint col, float rounding, ImDrawFlags_ flags=0);
	
	pragma(inline,true){
		void PathClear(){ _Path.Size = 0; }
		void PathLineTo(const ImVec2 pos){ _Path.push_back(pos); }
		void PathLineToMergeDuplicate(const ImVec2 pos){
			if(_Path.Size == 0 || memcmp(&_Path.Data[_Path.Size - 1], &pos, 8) != 0){
				_Path.push_back(pos);
			}
		}
		void PathFillConvex(uint col){
			AddConvexPolyFilled(_Path.Data, _Path.Size, col);
			_Path.Size = 0;
		}
		void PathStroke(uint col, ImDrawFlags_ flags=0, float thickness=1f){
			AddPolyline(_Path.Data, _Path.Size, col, flags, thickness);
			_Path.Size = 0;
		}
	}
	void PathArcTo(ref const ImVec2 center, float radius, float a_min, float a_max, int num_segments=0);
	void PathArcToFast(ref const ImVec2 center, float radius, int a_min_of_12, int a_max_of_12);
	void PathBezierCubicCurveTo(ref const ImVec2 p2, ref const ImVec2 p3, ref const ImVec2 p4, int num_segments=0);
	void PathBezierQuadraticCurveTo(ref const ImVec2 p2, ref const ImVec2 p3, int num_segments=0);
	void PathRect(ref const ImVec2 rect_min, ref const ImVec2 rect_max, float rounding=0f, ImDrawFlags_ flags=0);
	
	void AddCallback(ImDrawCallback callback, void* callback_data);
	void AddDrawCmd();
	ImDrawList* CloneOutput() const;
	
	pragma(inline,true){
		void ChannelsSplit(int count){ _Splitter.Split(&this, count); }
		void ChannelsMerge(){ _Splitter.Merge(&this); }
		void ChannelsSetCurrent(int n){ _Splitter.SetCurrentChannel(&this, n); }
	}
	
	void PrimReserve(int idx_count, int vtx_count);
	void PrimUnreserve(int idx_count, int vtx_count);
	void PrimRect(ref const ImVec2 a, ref const ImVec2 b, uint col);
	void PrimRectUV(ref const ImVec2 a, ref const ImVec2 b, ref const ImVec2 uv_a, ref const ImVec2 uv_b, uint col);
	void PrimQuadUV(ref const ImVec2 a, ref const ImVec2 b, ref const ImVec2 c, ref const ImVec2 d, ref const ImVec2 uv_a, ref const ImVec2 uv_b, ref const ImVec2 uv_c, ref const ImVec2 uv_d, uint col);
	pragma(inline,true){
		void PrimWriteVtx(const ImVec2 pos, const ImVec2 uv, uint col){
			_VtxWritePtr.pos = pos;
			_VtxWritePtr.uv = uv;
			_VtxWritePtr.col = col;
			_VtxWritePtr++;
			_VtxCurrentIdx++;
		}
		void PrimWriteIdx(ImDrawIdx idx){
			*_IdxWritePtr = idx;
			_IdxWritePtr++;
		}
		void PrimVtx(const ImVec2 pos, const ImVec2 uv, uint col){
			PrimWriteIdx(cast(ImDrawIdx)_VtxCurrentIdx);
			PrimWriteVtx(pos, uv, col);
		}
	}
	
	void _ResetForNewFrame();
	void _ClearFreeMemory();
	void _PopUnusedDrawCmd();
	void _TryMergeDrawCmds();
	void _OnChangedClipRect();
	void _OnChangedTextureID();
	void _OnChangedVtxOffset();
	int _CalcCircleAutoSegmentCount(float radius) const;
	void _PathArcToFastEx(ref const ImVec2 center, float radius, int a_min_sample, int a_max_sample, int a_step);
	void _PathArcToN(ref const ImVec2 center, float radius, float a_min, float a_max, int num_segments);
}

extern(C++) struct ImDrawData{
	bool Valid = false;
	int CmdListsCount = 0;
	int TotalIdxCount = 0;
	int TotalVtxCount = 0;
	ImDrawList** CmdLists = null;
	ImVec2 DisplayPos = ImVec2(0,0);
	ImVec2 DisplaySize = ImVec2(0,0);
	ImVec2 FramebufferScale = ImVec2(0,0);

	nothrow @nogc:
	this(int _){ Clear(); }
	void Clear(){ memset(cast(void*)&this, 0, this.sizeof); }
	void DeIndexAllBuffers();
	void ScaleClipRects(ref const ImVec2 fb_scale);
}

extern(C++) struct ImFontConfig{
	void* FontData = null;
	int FontDataSize;
	bool FontDataOwnedByAtlas = true;
	int FontNo = 0;
	float SizePixels = 0f;
	int OversampleH = 3;
	int OversampleV = 1;
	bool PixelSnapH = false;
	ImVec2 GlyphExtraSpacing;
	ImVec2 GlyphOffset;
	const(ImWchar)* GlyphRanges = null;
	float GlyphMinAdvanceX = 0f;
	float GlyphMaxAdvanceX = float.max;
	bool MergeMode = false;
	uint FontBuilderFlags = 0;
	float RasterizerMultiply = 1f;
	alias RasteriserMultiply = RasterizerMultiply;
	ImWchar EllipsisChar = cast(ImWchar)-1;
	
	char[40] Name;
	ImFont* DstFont = null;
	
	nothrow @nogc:
	pragma(mangle, [__traits(identifier, typeof(this))].mangleofCppDefaultCtor()) this(int _);
}

extern(C++) struct ImFontGlyph{
	uint Data; //NOTE: this was originally 3 bitfields (2,2,30). Bit-ordering in bitfields isn't standard.
	float AdvanceX;
	float X0, Y0, X1, Y1;
	float U0, V0, U1, V1;
}

extern(C++) struct ImFontGlyphRangesBuilder{
	ImVector!uint UsedChars;
	
	nothrow @nogc:
	this(int _){ Clear(); }
	pragma(inline,true){
		void Clear(){
			int size_in_bytes = (IM_UNICODE_CODEPOINT_MAX + 1) / 8;
			UsedChars.resize(size_in_bytes / cast(int)uint.sizeof);
			memset(UsedChars.Data, 0, cast(size_t)size_in_bytes);
		}
		bool GetBit(size_t n) const{
			int off = cast(int)(n >> 5);
			uint mask = 1U << (n & 31);
			return (UsedChars[off] & mask) != 0;
		}
		void SetBit(size_t n){
			int off = cast(int)(n >> 5);
			uint mask = 1U << (n & 31);
			UsedChars[off] |= mask;
		}
		void AddChar(ImWchar c){ SetBit(c); }
	}
	void AddText(const(char)* text, const(char)* text_end=null);
	void AddRanges(const(ImWchar)* ranges);
	void BuildRanges(ImVector!(ImWchar)* out_ranges);
}

extern(C++) struct ImFontAtlasCustomRect{
	ushort Width = 0, Height = 0;
	ushort X = 0xFFFF, Y = 0xFFFF;
	uint GlyphID = 0;
	float GlyphAdvanceX = 0f;
	ImVec2 GlyphOffset = ImVec2(0, 0);
	ImFont* Font = null;
	
	nothrow @nogc:
	bool IsPacked() const{ return X != 0xFFFF; }
}

alias ImFontAtlasFlags_ = int;
enum ImFontAtlasFlags: ImFontAtlasFlags_{
	None                = 0,
	NoPowerOfTwoHeight  = 1 << 0,
	NoMouseCursors      = 1 << 1,
	NoBakedLines        = 1 << 2,
}

extern(C++) struct ImFontAtlas{
	ImFontAtlasFlags_ Flags;
	ImTextureID TexID;
	int TexDesiredWidth;
	int TexGlyphPadding;
	bool Locked;
	void* UserData;
	
	bool TexReady;
	bool TexPixelsUseColors;
	ubyte* TexPixelsAlpha8;
	uint* TexPixelsRGBA32;
	int TexWidth;
	int TexHeight;
	ImVec2 TexUvScale;
	ImVec2 TexUvWhitePixel;
	ImVector!(ImFont*) Fonts;
	ImVector!ImFontAtlasCustomRect CustomRects;
	ImVector!ImFontConfig ConfigData;
	ImVec4[IM_DRAWLIST_TEX_LINES_WIDTH_MAX + 1] TexUvLines;
	
	const(ImFontBuilderIO)* FontBuilderIO;
	uint FontBuilderFlags;
	
	int PackIdMouseCursors;
	int PackIdLines;
	
	nothrow @nogc:
	pragma(mangle, [__traits(identifier, typeof(this))].mangleofCppDefaultCtor()) this(int _);
	~this();
	ImFont* AddFont(const(ImFontConfig)* font_cfg);
	ImFont* AddFontDefault(const(ImFontConfig)* font_cfg=null);
	ImFont* AddFontFromFileTTF(const(char)* filename, float size_pixels, const(ImFontConfig)* font_cfg=null, const(ImWchar)* glyph_ranges=null);
	ImFont* AddFontFromMemoryTTF(void* font_data, int font_size, float size_pixels, const(ImFontConfig)* font_cfg=null, const(ImWchar)* glyph_ranges=null);
	ImFont* AddFontFromMemoryCompressedTTF(const(void)* compressed_font_data, int compressed_font_size, float size_pixels, const(ImFontConfig)* font_cfg=null, const(ImWchar)* glyph_ranges=null);
	ImFont* AddFontFromMemoryCompressedBase85TTF(const(char)* compressed_font_data_base85, float size_pixels, const(ImFontConfig)* font_cfg=null, const(ImWchar)* glyph_ranges=null);
	void ClearInputData();
	void ClearTexData();
	void ClearFonts();
	void Clear();
	
	bool Build();
	void GetTexDataAsAlpha8(ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel=null);
	void GetTexDataAsRGBA32(ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel=null);
	bool IsBuilt() const{ return Fonts.Size > 0 && TexReady; }
	void SetTexID(ImTextureID id){ TexID = id; }
	
	const(ImWchar)* GetGlyphRangesDefault();
	const(ImWchar)* GetGlyphRangesGreek();
	const(ImWchar)* GetGlyphRangesKorean();
	const(ImWchar)* GetGlyphRangesJapanese();
	const(ImWchar)* GetGlyphRangesChineseFull();
	const(ImWchar)* GetGlyphRangesChineseSimplifiedCommon();
	const(ImWchar)* GetGlyphRangesCyrillic();
	const(ImWchar)* GetGlyphRangesThai();
	const(ImWchar)* GetGlyphRangesVietnamese();
	
	int AddCustomRectRegular(int width, int height);
	int AddCustomRectFontGlyph(ImFont* font, ImWchar id, int width, int height, float advance_x, ref const ImVec2 offset=Vec2_0_0);
	ImFontAtlasCustomRect* GetCustomRectByIndex(int index){
		assert(index >= 0);
		return &CustomRects[index];
	}
	
	void CalcCustomRectUV(const(ImFontAtlasCustomRect)* rect, ImVec2* out_uv_min, ImVec2* out_uv_max) const;
	bool GetMouseCursorTexData(ImGuiMouseCursor cursor, ImVec2* out_offset, ImVec2* out_size, ImVec2* out_uv_border, ImVec2* out_uv_fill);
}

extern(C++) struct ImFont{
	ImVector!float IndexAdvanceX;
	float FallbackAdvanceX;
	float FontSize;
	
	ImVector!ImWchar IndexLookup;
	ImVector!ImFontGlyph Glyphs;
	const(ImFontGlyph)* FallbackGlyph;
	
	ImFontAtlas* ContainerAtlas;
	const(ImFontConfig)* ConfigData;
	short ConfigDataCount;
	ImWchar FallbackChar;
	ImWchar EllipsisChar;
	short EllipsisCharCount;
	float EllipsisWidth;
	float EllipsisCharStep;
	bool DirtyLookupTables;
	float Scale;
	float Ascent, Descent;
	int MetricsTotalSurface;
	ubyte[(IM_UNICODE_CODEPOINT_MAX + 1) / 4096 / 8] Used4kPagesMap;
	
	nothrow @nogc:
	pragma(mangle, [__traits(identifier, typeof(this))].mangleofCppDefaultCtor()) this(int _);
	~this();
	const(ImFontGlyph)* FindGlyph(ImWchar c) const;
	const(ImFontGlyph)* FindGlyphNoFallback(ImWchar c) const;
	float GetCharAdvance(ImWchar c) const{ return (cast(int)c < IndexAdvanceX.Size) ? IndexAdvanceX[cast(int)c] : FallbackAdvanceX; }
	bool IsLoaded() const{ return ContainerAtlas != null; }
	const(char)* GetDebugName() const{ return ConfigData ? ConfigData.Name.ptr : "<unknown>"; }
	
	ImVec2 CalcTextSizeA(float size, float max_width, float wrap_width, const(char)* text_begin, const(char)* text_end=null, const(char)** remaining=null) const;
	const(char)* CalcWordWrapPositionA(float scale, const(char)* text, const(char)* text_end, float wrap_width) const;
	void RenderChar(ImDrawList* draw_list, float size, ref const ImVec2 pos, uint col, ImWchar c) const;
	void RenderText(ImDrawList* draw_list, float size, ref const ImVec2 pos, uint col, ref const ImVec4 clip_rect, const(char)* text_begin, const(char)* text_end, float wrap_width=0f, bool cpu_fine_clip=false) const;
	
	void BuildLookupTable();
	void ClearOutputData();
	void GrowIndex(int new_size);
	void AddGlyph(const(ImFontConfig)* src_cfg, ImWchar c, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1, float advance_x);
	void AddRemapChar(ImWchar dst, ImWchar src, bool overwrite_dst=true);
	void SetGlyphVisible(ImWchar c, bool visible);
	bool IsGlyphRangeUnused(uint c_begin, uint c_last);
}

alias ImGuiViewportFlags_ = int;
enum ImGuiViewportFlags: ImGuiViewportFlags_{
	None                     = 0,
	IsPlatformWindow         = 1 << 0,
	IsPlatformMonitor        = 1 << 1,
	OwnedByApp               = 1 << 2,
}

extern(C++) struct ImGuiViewport{
	ImGuiViewportFlags_  Flags = 0;
	ImVec2 Pos = ImVec2(0, 0);
	ImVec2 Size = ImVec2(0, 0);
	ImVec2 WorkPos = ImVec2(0, 0);
	ImVec2 WorkSize = ImVec2(0, 0);
	
	void* PlatformHandleRaw = null;
	
	nothrow @nogc:
	ImVec2 GetCenter() const{ return ImVec2(Pos.x + Size.x * 0.5f, Pos.y + Size.y * 0.5f); }
	alias GetCentre = GetCenter;
	ImVec2 GetWorkCenter() const{ return ImVec2(WorkPos.x + WorkSize.x * 0.5f, WorkPos.y + WorkSize.y * 0.5f); }
	alias GetWorkCentre = GetWorkCenter;
}

extern(C++) struct ImGuiPlatformImeData{
	bool WantVisible = false;
	ImVec2 InputPos = ImVec2(0, 0);
	float InputLineHeight = 0;
}

version(ImGui_DisableObsoleteFunctions){
}else{
	pragma(inline,true) nothrow @nogc{
		void PushAllowKeyboardFocus(bool tab_stop){ PushTabStop(tab_stop); }
		void PopAllowKeyboardFocus(){ PopTabStop(); }
		
		void CaptureKeyboardFromApp(bool want_capture_keyboard=true){ SetNextFrameWantCaptureKeyboard(want_capture_keyboard); }
		void CaptureMouseFromApp(bool want_capture_mouse=true){ SetNextFrameWantCaptureMouse(want_capture_mouse); }
		
		float GetWindowContentRegionWidth(){ return GetWindowContentRegionMax().x - GetWindowContentRegionMin().x; }
	}
	
	alias ImDrawCornerFlags_ = ImDrawFlags;
	enum ImDrawCornerFlags: ImDrawCornerFlags_{
		None      = ImDrawFlags.RoundCornersNone,
		TopLeft   = ImDrawFlags.RoundCornersTopLeft,
		TopRight  = ImDrawFlags.RoundCornersTopRight,
		BotLeft   = ImDrawFlags.RoundCornersBottomLeft,
		BotRight  = ImDrawFlags.RoundCornersBottomRight,
		All       = ImDrawFlags.RoundCornersAll,
		Top       = ImDrawCornerFlags.TopLeft | ImDrawCornerFlags.TopRight,
		Bot       = ImDrawCornerFlags.BotLeft | ImDrawCornerFlags.BotRight,
		Left      = ImDrawCornerFlags.TopLeft | ImDrawCornerFlags.BotLeft,
		Right     = ImDrawCornerFlags.TopRight | ImDrawCornerFlags.BotRight,
	}
	
	alias ImGuiModFlags_ = ImGuiKeyChord;
	enum ImGuiModFlags: ImGuiModFlags_{
		None = 0,
		Ctrl = ImGuiMod.Ctrl,
		Shift = ImGuiMod.Shift,
		Alt = ImGuiMod.Alt,
		Super = ImGuiMod.Super,
	}
}

mixin(joinFnBinds((){
	string[][] ret;
	ret ~= makeFnBinds([
		[q{ImGuiContext*}, q{CreateContext}, q{ImFontAtlas* shared_font_atlas=null}, `C++, "ImGui"`],
		[q{void}, q{DestroyContext}, q{ImGuiContext* ctx=null}, `C++, "ImGui"`],
		[q{ImGuiContext*}, q{GetCurrentContext}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetCurrentContext}, q{ImGuiContext* ctx}, `C++, "ImGui"`],
		
		[q{ImGuiIO*}, q{GetIO}, q{}, `C++, "ImGui"`],
		[q{ImGuiStyle*}, q{GetStyle}, q{}, `C++, "ImGui"`],
		[q{void}, q{NewFrame}, q{}, `C++, "ImGui"`],
		[q{void}, q{EndFrame}, q{}, `C++, "ImGui"`],
		[q{void}, q{Render}, q{}, `C++, "ImGui"`],
		[q{ImDrawData*}, q{GetDrawData}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{ShowDemoWindow}, q{bool* p_open=null}, `C++, "ImGui"`],
		[q{void}, q{ShowMetricsWindow}, q{bool* p_open=null}, `C++, "ImGui"`],
		[q{void}, q{ShowDebugLogWindow}, q{bool* p_open=null}, `C++, "ImGui"`],
		[q{void}, q{ShowStackToolWindow}, q{bool* p_open=null}, `C++, "ImGui"`],
		[q{void}, q{ShowAboutWindow}, q{bool* p_open=null}, `C++, "ImGui"`],
		[q{void}, q{ShowStyleEditor}, q{ImGuiStyle* ref_=null}, `C++, "ImGui"`],
		[q{bool}, q{ShowStyleSelector}, q{const(char)* label}, `C++, "ImGui"`],
		[q{void}, q{ShowFontSelector}, q{const(char)* label}, `C++, "ImGui"`],
		[q{void}, q{ShowUserGuide}, q{}, `C++, "ImGui"`],
		[q{const(char)*}, q{GetVersion}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{StyleColorsDark}, q{ImGuiStyle* dst=null}, `C++, "ImGui"`],
		[q{void}, q{StyleColorsLight}, q{ImGuiStyle* dst=null}, `C++, "ImGui"`],
		[q{void}, q{StyleColorsClassic}, q{ImGuiStyle* dst=null}, `C++, "ImGui"`],
		
		[q{bool}, q{Begin}, q{const(char)* name, bool* p_open=null, ImGuiWindowFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{End}, q{}, `C++, "ImGui"`],
		
		[q{bool}, q{BeginChild}, q{const(char)* str_id, ref const ImVec2 size=Vec2_0_0, bool border=false, ImGuiWindowFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{BeginChild}, q{ImGuiID id, ref const ImVec2 size=Vec2_0_0, bool border=false, ImGuiWindowFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{EndChild}, q{}, `C++, "ImGui"`],
		
		[q{bool}, q{IsWindowAppearing}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsWindowCollapsed}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsWindowFocused}, q{ImGuiFocusedFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{IsWindowHovered}, q{ImGuiHoveredFlags_ flags=0}, `C++, "ImGui"`],
		[q{ImDrawList*}, q{GetWindowDrawList}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetWindowPos}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetWindowSize}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetWindowWidth}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetWindowHeight}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{SetNextWindowPos}, q{ref const ImVec2 pos, ImGuiCond_ cond=0, ref const ImVec2 pivot=Vec2_0_0}, `C++, "ImGui"`],
		[q{void}, q{SetNextWindowSize}, q{ref const ImVec2 size, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetNextWindowSizeConstraints}, q{ref const ImVec2 size_min, ref const ImVec2 size_max, ImGuiSizeCallback custom_callback=null, void* custom_callback_data=null}, `C++, "ImGui"`],
		[q{void}, q{SetNextWindowContentSize}, q{ref const ImVec2 size}, `C++, "ImGui"`],
		[q{void}, q{SetNextWindowCollapsed}, q{bool collapsed, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetNextWindowFocus}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetNextWindowScroll}, q{ref const ImVec2 scroll}, `C++, "ImGui"`],
		[q{void}, q{SetNextWindowBgAlpha}, q{float alpha}, `C++, "ImGui"`],
		[q{void}, q{SetWindowPos}, q{ref const ImVec2 pos, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetWindowSize}, q{ref const ImVec2 size, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetWindowCollapsed}, q{bool collapsed, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetWindowFocus}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetWindowFontScale}, q{float scale}, `C++, "ImGui"`],
		[q{void}, q{SetWindowPos}, q{const(char)* name, ref const ImVec2 pos, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetWindowSize}, q{const(char)* name, ref const ImVec2 size, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetWindowCollapsed}, q{const(char)* name, bool collapsed, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{SetWindowFocus}, q{const(char)* name}, `C++, "ImGui"`],
		
		[q{ImVec2}, q{GetContentRegionAvail}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetContentRegionMax}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetWindowContentRegionMin}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetWindowContentRegionMax}, q{}, `C++, "ImGui"`],
		
		[q{float}, q{GetScrollX}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetScrollY}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetScrollX}, q{float scroll_x}, `C++, "ImGui"`],
		[q{void}, q{SetScrollY}, q{float scroll_y}, `C++, "ImGui"`],
		[q{float}, q{GetScrollMaxX}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetScrollMaxY}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetScrollHereX}, q{float center_x_ratio=0.5f}, `C++, "ImGui"`],
		[q{void}, q{SetScrollHereY}, q{float center_y_ratio=0.5f}, `C++, "ImGui"`],
		[q{void}, q{SetScrollFromPosX}, q{float local_x, float center_x_ratio=0.5f}, `C++, "ImGui"`],
		[q{void}, q{SetScrollFromPosY}, q{float local_y, float center_y_ratio=0.5f}, `C++, "ImGui"`],
		[q{void}, q{PushFont}, q{ImFont* font}, `C++, "ImGui"`],
		[q{void}, q{PopFont}, q{}, `C++, "ImGui"`],
		[q{void}, q{PushStyleColor}, q{ImGuiCol_ idx, uint col}, `C++, "ImGui"`],
		[q{void}, q{PushStyleColor}, q{ImGuiCol_ idx, ref const ImVec4 col}, `C++, "ImGui"`],
		[q{void}, q{PopStyleColor}, q{int count=1}, `C++, "ImGui"`],
		[q{void}, q{PushStyleVar}, q{ImGuiStyleVar_ idx, float val}, `C++, "ImGui"`],
		[q{void}, q{PushStyleVar}, q{ImGuiStyleVar_ idx, ref const ImVec2 val}, `C++, "ImGui"`],
		[q{void}, q{PopStyleVar}, q{int count=1}, `C++, "ImGui"`],
		[q{void}, q{PushTabStop}, q{bool tab_stop}, `C++, "ImGui"`],
		[q{void}, q{PopTabStop}, q{}, `C++, "ImGui"`],
		[q{void}, q{PushButtonRepeat}, q{bool repeat}, `C++, "ImGui"`],
		[q{void}, q{PopButtonRepeat}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{PushItemWidth}, q{float item_width}, `C++, "ImGui"`],
		[q{void}, q{PopItemWidth}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetNextItemWidth}, q{float item_width}, `C++, "ImGui"`],
		[q{float}, q{CalcItemWidth}, q{}, `C++, "ImGui"`],
		[q{void}, q{PushTextWrapPos}, q{float wrap_local_pos_x=0f}, `C++, "ImGui"`],
		[q{void}, q{PopTextWrapPos}, q{}, `C++, "ImGui"`],
		
		[q{ImFont*}, q{GetFont}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetFontSize}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetFontTexUvWhitePixel}, q{}, `C++, "ImGui"`],
		[q{uint}, q{GetColorU32}, q{ImGuiCol_ idx, float alpha_mul=1f}, `C++, "ImGui"`],
		[q{uint}, q{GetColorU32}, q{ref const ImVec4 col}, `C++, "ImGui"`],
		[q{uint}, q{GetColorU32}, q{uint col}, `C++, "ImGui"`],
		[q{const(ImVec4)*}, q{GetStyleColorVec4}, q{ImGuiCol_ idx}, `C++, "ImGui"`],
		
		[q{void}, q{Separator}, q{}, `C++, "ImGui"`],
		[q{void}, q{SameLine}, q{float offset_from_start_x=0f, float spacing=-1f}, `C++, "ImGui"`],
		[q{void}, q{NewLine}, q{}, `C++, "ImGui"`],
		[q{void}, q{Spacing}, q{}, `C++, "ImGui"`],
		[q{void}, q{Dummy}, q{ref const ImVec2 size}, `C++, "ImGui"`],
		[q{void}, q{Indent}, q{float indent_w=0f}, `C++, "ImGui"`],
		[q{void}, q{Unindent}, q{float indent_w=0f}, `C++, "ImGui"`],
		[q{void}, q{BeginGroup}, q{}, `C++, "ImGui"`],
		[q{void}, q{EndGroup}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetCursorPos}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetCursorPosX}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetCursorPosY}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetCursorPos}, q{ref const ImVec2 local_pos}, `C++, "ImGui"`],
		[q{void}, q{SetCursorPosX}, q{float local_x}, `C++, "ImGui"`],
		[q{void}, q{SetCursorPosY}, q{float local_y}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetCursorStartPos}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetCursorScreenPos}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetCursorScreenPos}, q{ref const ImVec2 pos}, `C++, "ImGui"`],
		[q{void}, q{AlignTextToFramePadding}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetTextLineHeight}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetTextLineHeightWithSpacing}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetFrameHeight}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetFrameHeightWithSpacing}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{PushID}, q{const(char)* str_id}, `C++, "ImGui"`],
		[q{void}, q{PushID}, q{const(char)* str_id_begin, const(char)* str_id_end}, `C++, "ImGui"`],
		[q{void}, q{PushID}, q{const(void)* ptr_id}, `C++, "ImGui"`],
		[q{void}, q{PushID}, q{int int_id}, `C++, "ImGui"`],
		[q{void}, q{PopID}, q{}, `C++, "ImGui"`],
		[q{ImGuiID}, q{GetID}, q{const(char)* str_id}, `C++, "ImGui"`],
		[q{ImGuiID}, q{GetID}, q{const(char)* str_id_begin, const(char)* str_id_end}, `C++, "ImGui"`],
		[q{ImGuiID}, q{GetID}, q{const(void)* ptr_id}, `C++, "ImGui"`],
		
		[q{void}, q{TextUnformatted}, q{const(char)* text, const(char)* text_end=null}, `C++, "ImGui"`],
		[q{void}, q{Text}, q{const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{TextV}, q{const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{void}, q{TextColored}, q{ref const ImVec4 col, const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{TextColoredV}, q{ref const ImVec4 col, const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{void}, q{TextDisabled}, q{const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{TextDisabledV}, q{const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{void}, q{TextWrapped}, q{const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{TextWrappedV}, q{const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{void}, q{LabelText}, q{const(char)* label, const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{LabelTextV}, q{const(char)* label, const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{void}, q{BulletText}, q{const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{BulletTextV}, q{const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{void}, q{SeparatorText}, q{const(char)* label}, `C++, "ImGui"`],
		
		[q{bool}, q{Button}, q{const(char)* label, ref const ImVec2 size=Vec2_0_0}, `C++, "ImGui"`],
		[q{bool}, q{SmallButton}, q{const(char)* label}, `C++, "ImGui"`],
		[q{bool}, q{InvisibleButton}, q{const(char)* str_id, ref const ImVec2 size, ImGuiButtonFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{ArrowButton}, q{const(char)* str_id, ImGuiDir_ dir}, `C++, "ImGui"`],
		[q{bool}, q{Checkbox}, q{const(char)* label, bool* v}, `C++, "ImGui"`],
		[q{bool}, q{CheckboxFlags}, q{const(char)* label, int* flags, int flags_value}, `C++, "ImGui"`],
		[q{bool}, q{CheckboxFlags}, q{const(char)* label, uint* flags, uint flags_value}, `C++, "ImGui"`],
		[q{bool}, q{RadioButton}, q{const(char)* label, bool active}, `C++, "ImGui"`],
		[q{bool}, q{RadioButton}, q{const(char)* label, int* v, int v_button}, `C++, "ImGui"`],
		[q{void}, q{ProgressBar}, q{float fraction, ref const ImVec2 size_arg=Vec2_negfltmin_0, const(char)* overlay=null}, `C++, "ImGui"`],
		[q{void}, q{Bullet}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{Image}, q{ImTextureID user_texture_id, ref const ImVec2 size, ref const ImVec2 uv0=Vec2_0_0, ref const ImVec2 uv1=Vec2_1_1, ref const ImVec4 tint_col=Vec4_1_1_1_1, ref const ImVec4 border_col=Vec4_0_0_0_0}, `C++, "ImGui"`],
		[q{bool}, q{ImageButton}, q{const(char)* str_id, ImTextureID user_texture_id, ref const ImVec2 size, ref const ImVec2 uv0=Vec2_0_0, ref const ImVec2 uv1=Vec2_1_1, ref const ImVec4 bg_col=Vec4_0_0_0_0, ref const ImVec4 tint_col=Vec4_1_1_1_1}, `C++, "ImGui"`],
		
		[q{bool}, q{BeginCombo}, q{const(char)* label, const(char)* preview_value, ImGuiComboFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{EndCombo}, q{}, `C++, "ImGui"`],
		[q{bool}, q{Combo}, q{const(char)* label, int* current_item, const(char*)* items, int items_count, int popup_max_height_in_items=-1}, `C++, "ImGui"`],
		[q{bool}, q{Combo}, q{const(char)* label, int* current_item, const(char)* items_separated_by_zeros, int popup_max_height_in_items=-1}, `C++, "ImGui"`],
		[q{bool}, q{Combo}, q{const(char)* label, int* current_item, ItemsGetterFn items_getter, void* data, int items_count, int popup_max_height_in_items=-1}, `C++, "ImGui"`],
		
		[q{bool}, q{DragFloat}, q{const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragFloat2}, q{const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragFloat3}, q{const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragFloat4}, q{const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragFloatRange2}, q{const(char)* label, float* v_current_min, float* v_current_max, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", const(char)* format_max=null, ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragInt}, q{const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragInt2}, q{const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragInt3}, q{const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragInt4}, q{const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragIntRange2}, q{const(char)* label, int* v_current_min, int* v_current_max, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", const(char)* format_max=null, ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragScalar}, q{const(char)* label, ImGuiDataType data_type, void* p_data, float v_speed=1f, const(void)* p_min=null, const(void)* p_max=null, const(char)* format=null, ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{DragScalarN}, q{const(char)* label, ImGuiDataType data_type, void* p_data, int components, float v_speed=1f, const(void)* p_min=null, const(void)* p_max=null, const(char)* format=null, ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		
		[q{bool}, q{SliderFloat}, q{const(char)* label, float* v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderFloat2}, q{const(char)* label, float* v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderFloat3}, q{const(char)* label, float* v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderFloat4}, q{const(char)* label, float* v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderAngle}, q{const(char)* label, float* v_rad, float v_degrees_min=-360f, float v_degrees_max=+360f, const(char)* format="%.0f deg", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderInt}, q{const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderInt2}, q{const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderInt3}, q{const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderInt4}, q{const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderScalar}, q{const(char)* label, ImGuiDataType_ data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format=null, ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SliderScalarN}, q{const(char)* label, ImGuiDataType_ data_type, void* p_data, int components, const(void)* p_min, const(void)* p_max, const(char)* format=null, ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{VSliderFloat}, q{const(char)* label, ref const ImVec2 size, float* v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{VSliderInt}, q{const(char)* label, ref const ImVec2 size, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{VSliderScalar}, q{const(char)* label, ref const ImVec2 size, ImGuiDataType_ data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format=null, ImGuiSliderFlags_ flags=0}, `C++, "ImGui"`],
		
		[q{bool}, q{InputText}, q{const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* user_data=null}, `C++, "ImGui"`],
		[q{bool}, q{InputTextMultiline}, q{const(char)* label, char* buf, size_t buf_size, ref const ImVec2 size=Vec2_0_0, ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* user_data=null}, `C++, "ImGui"`],
		[q{bool}, q{InputTextWithHint}, q{const(char)* label, const(char)* hint, char* buf, size_t buf_size, ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* user_data=null}, `C++, "ImGui"`],
		[q{bool}, q{InputFloat}, q{const(char)* label, float* v, float step=0f, float step_fast=0f, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputFloat2}, q{const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputFloat3}, q{const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputFloat4}, q{const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputInt}, q{const(char)* label, int* v, int step=1, int step_fast=100, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputInt2}, q{const(char)* label, int* v, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputInt3}, q{const(char)* label, int* v, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputInt4}, q{const(char)* label, int* v, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputDouble}, q{const(char)* label, double* v, double step=0.0, double step_fast=0.0, const(char)* format="%.6f", ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputScalar}, q{const(char)* label, ImGuiDataType_ data_type, void* p_data, const(void)* p_step=null, const(void)* p_step_fast=null, const(char)* format=null, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{InputScalarN}, q{const(char)* label, ImGuiDataType_ data_type, void* p_data, int components, const(void)* p_step=null, const(void)* p_step_fast=null, const(char)* format=null, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		
		[q{bool}, q{ColorEdit3}, q{const(char)* label, float* col, ImGuiColorEditFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{ColorEdit4}, q{const(char)* label, float* col, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{ColorPicker3}, q{const(char)* label, float* col, ImGuiInputTextFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{ColorPicker4}, q{const(char)* label, float* col, ImGuiInputTextFlags_ flags=0, const(float)* ref_col=null}, `C++, "ImGui"`],
		[q{bool}, q{ColorButton}, q{const(char)* desc_id, ref const ImVec4 col, ImGuiInputTextFlags_ flags=0, ref const ImVec2 size=Vec2_0_0}, `C++, "ImGui"`],
		[q{void}, q{SetColorEditOptions}, q{ImGuiColorEditFlags_ flags}, `C++, "ImGui"`],
		
		[q{bool}, q{TreeNode}, q{const(char)* label}, `C++, "ImGui"`],
		[q{bool}, q{TreeNode}, q{const(char)* str_id, const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{bool}, q{TreeNode}, q{const(void)* ptr_id, const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{bool}, q{TreeNodeV}, q{const(char)* str_id, const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{bool}, q{TreeNodeV}, q{const(void)* ptr_id, const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{bool}, q{TreeNodeEx}, q{const(char)* label, ImGuiTreeNodeFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{TreeNodeEx}, q{const(char)* str_id, ImGuiTreeNodeFlags_ flags, const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{bool}, q{TreeNodeEx}, q{const(void)* ptr_id, ImGuiTreeNodeFlags_ flags, const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{bool}, q{TreeNodeExV}, q{const(char)* str_id, ImGuiTreeNodeFlags_ flags, const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{bool}, q{TreeNodeExV}, q{const(void)* ptr_id, ImGuiTreeNodeFlags_ flags, const(char)* fmt, va_list args}, `C++, "ImGui"`],
		[q{void}, q{TreePush}, q{const(char)* str_id}, `C++, "ImGui"`],
		[q{void}, q{TreePush}, q{const(void)* ptr_id}, `C++, "ImGui"`],
		[q{void}, q{TreePop}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetTreeNodeToLabelSpacing}, q{}, `C++, "ImGui"`],
		[q{bool}, q{CollapsingHeader}, q{const(char)* label, ImGuiTreeNodeFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{CollapsingHeader}, q{const(char)* label, bool* p_visible, ImGuiTreeNodeFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{SetNextItemOpen}, q{bool is_open, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{bool}, q{Selectable}, q{const(char)* label, bool selected=false, ImGuiSelectableFlags_ flags=0, ref const ImVec2 size=Vec2_0_0}, `C++, "ImGui"`],
		[q{bool}, q{Selectable}, q{const(char)* label, bool* p_selected, ImGuiSelectableFlags_ flags=0, ref const ImVec2 size=Vec2_0_0}, `C++, "ImGui"`],
		[q{bool}, q{BeginListBox}, q{const(char)* label, ref const ImVec2 size=Vec2_0_0}, `C++, "ImGui"`],
		[q{void}, q{EndListBox}, q{}, `C++, "ImGui"`],
		[q{bool}, q{ListBox}, q{const(char)* label, int* current_item, const(char*)* items, int items_count, int height_in_items=-1}, `C++, "ImGui"`],
		[q{bool}, q{ListBox}, q{const(char)* label, int* current_item, ItemsGetterFn items_getter, void* data, int items_count, int height_in_items=-1}, `C++, "ImGui"`],
		
		[q{void}, q{PlotLines}, q{const(char)* label, const(float)* values, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=Vec2_0_0, int stride=float.sizeof}, `C++, "ImGui"`],
		[q{void}, q{PlotLines}, q{const(char)* label, ValuesGetterFn values_getter, void* data, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=Vec2_0_0}, `C++, "ImGui"`],
		[q{void}, q{PlotHistogram}, q{const(char)* label, const(float)* values, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=Vec2_0_0, int stride=float.sizeof}, `C++, "ImGui"`],
		[q{void}, q{PlotHistogram}, q{const(char)* label, ValuesGetterFn values_getter, void* data, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=Vec2_0_0}, `C++, "ImGui"`],
		
		[q{void}, q{Value}, q{const(char)* prefix, bool b}, `C++, "ImGui"`],
		[q{void}, q{Value}, q{const(char)* prefix, int v}, `C++, "ImGui"`],
		[q{void}, q{Value}, q{const(char)* prefix, uint v}, `C++, "ImGui"`],
		[q{void}, q{Value}, q{const(char)* prefix, float v, const(char)* float_format=null}, `C++, "ImGui"`],
		
		[q{bool}, q{BeginMenuBar}, q{}, `C++, "ImGui"`],
		[q{void}, q{EndMenuBar}, q{}, `C++, "ImGui"`],
		[q{bool}, q{BeginMainMenuBar}, q{}, `C++, "ImGui"`],
		[q{void}, q{EndMainMenuBar}, q{}, `C++, "ImGui"`],
		[q{bool}, q{BeginMenu}, q{const(char)* label, bool enabled=true}, `C++, "ImGui"`],
		[q{void}, q{EndMenu}, q{}, `C++, "ImGui"`],
		[q{bool}, q{MenuItem}, q{const(char)* label, const(char)* shortcut=null, bool selected=false, bool enabled=true}, `C++, "ImGui"`],
		[q{bool}, q{MenuItem}, q{const(char)* label, const(char)* shortcut, bool* p_selected, bool enabled=true}, `C++, "ImGui"`],
		[q{bool}, q{BeginTooltip}, q{}, `C++, "ImGui"`],
		[q{void}, q{EndTooltip}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetTooltip}, q{const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{SetTooltipV}, q{const(char)* fmt, va_list args}, `C++, "ImGui"`],
		
		[q{bool}, q{BeginPopup}, q{const(char)* str_id, ImGuiWindowFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{BeginPopupModal}, q{const(char)* name, bool* p_open=null, ImGuiWindowFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{EndPopup}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{OpenPopup}, q{const(char)* str_id, ImGuiPopupFlags_ popup_flags=0}, `C++, "ImGui"`],
		[q{void}, q{OpenPopup}, q{ImGuiID id, ImGuiPopupFlags_ popup_flags=0}, `C++, "ImGui"`],
		[q{void}, q{OpenPopupOnItemClick}, q{const(char)* str_id=null, ImGuiPopupFlags_ popup_flags=1}, `C++, "ImGui"`],
		[q{void}, q{CloseCurrentPopup}, q{}, `C++, "ImGui"`],
		
		[q{bool}, q{BeginPopupContextItem}, q{const(char)* str_id=null, ImGuiPopupFlags_ popup_flags=1}, `C++, "ImGui"`],
		[q{bool}, q{BeginPopupContextWindow}, q{const(char)* str_id=null, ImGuiPopupFlags_ popup_flags=1}, `C++, "ImGui"`],
		[q{bool}, q{BeginPopupContextVoid}, q{const(char)* str_id=null, ImGuiPopupFlags_ popup_flags=1}, `C++, "ImGui"`],
		[q{bool}, q{IsPopupOpen}, q{const(char)* str_id, ImGuiPopupFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{BeginTable}, q{const(char)* str_id, int column, ImGuiTableFlags_ flags=0, ref const ImVec2 outer_size=Vec2_0_0, float inner_width=0f}, `C++, "ImGui"`],
		[q{void}, q{EndTable}, q{}, `C++, "ImGui"`],
		[q{void}, q{TableNextRow}, q{ImGuiTableRowFlags_ row_flags=0, float min_row_height=0f}, `C++, "ImGui"`],
		[q{bool}, q{TableNextColumn}, q{}, `C++, "ImGui"`],
		[q{bool}, q{TableSetColumnIndex}, q{int column_n}, `C++, "ImGui"`],
		
		[q{void}, q{TableSetupColumn}, q{const(char)* label, ImGuiTableColumnFlags_ flags=0, float init_width_or_weight=0f, ImGuiID user_id=0}, `C++, "ImGui"`],
		[q{void}, q{TableSetupScrollFreeze}, q{int cols, int rows}, `C++, "ImGui"`],
		[q{void}, q{TableHeadersRow}, q{}, `C++, "ImGui"`],
		[q{void}, q{TableHeader}, q{const(char)* label}, `C++, "ImGui"`],
		
		[q{ImGuiTableSortSpecs*}, q{TableGetSortSpecs}, q{}, `C++, "ImGui"`],
		[q{int}, q{TableGetColumnCount}, q{}, `C++, "ImGui"`],
		[q{int}, q{TableGetColumnIndex}, q{}, `C++, "ImGui"`],
		[q{int}, q{TableGetRowIndex}, q{}, `C++, "ImGui"`],
		[q{const(char)*}, q{TableGetColumnName}, q{int column_n=-1}, `C++, "ImGui"`],
		[q{ImGuiTableColumnFlags}, q{TableGetColumnFlags}, q{int column_n=-1}, `C++, "ImGui"`],
		[q{void}, q{TableSetColumnEnabled}, q{int column_n, bool v}, `C++, "ImGui"`],
		[q{void}, q{TableSetBgColor}, q{ImGuiTableBgTarget_ target, uint color, int column_n=-1}, `C++, "ImGui"`],
		[q{void}, q{Columns}, q{int count=1, const(char)* id=null, bool border=true}, `C++, "ImGui"`],
		[q{void}, q{NextColumn}, q{}, `C++, "ImGui"`],
		[q{int}, q{GetColumnIndex}, q{}, `C++, "ImGui"`],
		[q{float}, q{GetColumnWidth}, q{int column_index=-1}, `C++, "ImGui"`],
		[q{void}, q{SetColumnWidth}, q{int column_index, float width}, `C++, "ImGui"`],
		[q{float}, q{GetColumnOffset}, q{int column_index=-1}, `C++, "ImGui"`],
		[q{void}, q{SetColumnOffset}, q{int column_index, float offset_x}, `C++, "ImGui"`],
		[q{int}, q{GetColumnsCount}, q{}, `C++, "ImGui"`],
		
		[q{bool}, q{BeginTabBar}, q{const(char)* str_id, ImGuiTabBarFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{EndTabBar}, q{}, `C++, "ImGui"`],
		[q{bool}, q{BeginTabItem}, q{const(char)* label, bool* p_open=null, ImGuiTabItemFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{EndTabItem}, q{}, `C++, "ImGui"`],
		[q{bool}, q{TabItemButton}, q{const(char)* label, ImGuiTabItemFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{SetTabItemClosed}, q{const(char)* tab_or_docked_window_label}, `C++, "ImGui"`],
		
		[q{void}, q{LogToTTY}, q{int auto_open_depth=-1}, `C++, "ImGui"`],
		[q{void}, q{LogToFile}, q{int auto_open_depth=-1, const(char)* filename=null}, `C++, "ImGui"`],
		[q{void}, q{LogToClipboard}, q{int auto_open_depth=-1}, `C++, "ImGui"`],
		[q{void}, q{LogFinish}, q{}, `C++, "ImGui"`],
		[q{void}, q{LogButtons}, q{}, `C++, "ImGui"`],
		[q{void}, q{LogText}, q{const(char)* fmt, ...}, `C++, "ImGui"`],
		[q{void}, q{LogTextV}, q{const(char)* fmt, va_list args}, `C++, "ImGui"`],
		
		[q{bool}, q{BeginDragDropSource}, q{ImGuiDragDropFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{SetDragDropPayload}, q{const(char)* type, const(void)* data, size_t sz, ImGuiCond_ cond=0}, `C++, "ImGui"`],
		[q{void}, q{EndDragDropSource}, q{}, `C++, "ImGui"`],
		[q{bool}, q{BeginDragDropTarget}, q{}, `C++, "ImGui"`],
		[q{const(ImGuiPayload)*}, q{AcceptDragDropPayload}, q{const(char)* type, ImGuiDragDropFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{EndDragDropTarget}, q{}, `C++, "ImGui"`],
		[q{const(ImGuiPayload)*}, q{GetDragDropPayload}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{BeginDisabled}, q{bool disabled=true}, `C++, "ImGui"`],
		[q{void}, q{EndDisabled}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{PushClipRect}, q{ref const ImVec2 clip_rect_min, ref const ImVec2 clip_rect_max, bool intersect_with_current_clip_rect}, `C++, "ImGui"`],
		[q{void}, q{PopClipRect}, q{}, `C++, "ImGui"`],
		
		[q{void}, q{SetItemDefaultFocus}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetKeyboardFocusHere}, q{int offset=0}, `C++, "ImGui"`],
		
		[q{bool}, q{IsItemHovered}, q{ImGuiHoveredFlags_ flags=0}, `C++, "ImGui"`],
		[q{bool}, q{IsItemActive}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsItemFocused}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsItemClicked}, q{ImGuiMouseButton_ mouse_button=0}, `C++, "ImGui"`],
		[q{bool}, q{IsItemVisible}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsItemEdited}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsItemActivated}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsItemDeactivated}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsItemDeactivatedAfterEdit}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsItemToggledOpen}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsAnyItemHovered}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsAnyItemActive}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsAnyItemFocused}, q{}, `C++, "ImGui"`],
		[q{ImGuiID}, q{GetItemID}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetItemRectMin}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetItemRectMax}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetItemRectSize}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetItemAllowOverlap}, q{}, `C++, "ImGui"`],
		
		[q{ImGuiViewport*}, q{GetMainViewport}, q{}, `C++, "ImGui"`],
		
		[q{ImDrawList*}, q{GetBackgroundDrawList}, q{}, `C++, "ImGui"`],
		[q{ImDrawList*}, q{GetForegroundDrawList}, q{}, `C++, "ImGui"`],
		
		[q{bool}, q{IsRectVisible}, q{ref const ImVec2 size}, `C++, "ImGui"`],
		[q{bool}, q{IsRectVisible}, q{ref const ImVec2 rect_min, ref const ImVec2 rect_max}, `C++, "ImGui"`],
		[q{double}, q{GetTime}, q{}, `C++, "ImGui"`],
		[q{int}, q{GetFrameCount}, q{}, `C++, "ImGui"`],
		[q{ImDrawListSharedData*}, q{GetDrawListSharedData}, q{}, `C++, "ImGui"`],
		[q{const(char)*}, q{GetStyleColorName}, q{ImGuiCol_ idx}, `C++, "ImGui"`],
		[q{void}, q{SetStateStorage}, q{ImGuiStorage* storage}, `C++, "ImGui"`],
		[q{ImGuiStorage*}, q{GetStateStorage}, q{}, `C++, "ImGui"`],
		[q{bool}, q{BeginChildFrame}, q{ImGuiID id, ref const ImVec2 size, ImGuiWindowFlags_ flags=0}, `C++, "ImGui"`],
		[q{void}, q{EndChildFrame}, q{}, `C++, "ImGui"`],
		
		[q{ImVec2}, q{CalcTextSize}, q{const(char)* text, const(char)* text_end=null, bool hide_text_after_double_hash=false, float wrap_width=-1f}, `C++, "ImGui"`],
		
		[q{ImVec4}, q{ColorConvertU32ToFloat4}, q{uint in_}, `C++, "ImGui"`],
		[q{uint}, q{ColorConvertFloat4ToU32}, q{ref const ImVec4 inP}, `C++, "ImGui"`],
		[q{void}, q{ColorConvertRGBtoHSV}, q{float r, float g, float b, ref float out_h, ref float out_s, ref float out_v}, `C++, "ImGui"`],
		[q{void}, q{ColorConvertHSVtoRGB}, q{float h, float s, float v, ref float out_r, ref float out_g, ref float out_b}, `C++, "ImGui"`],
		
		[q{bool}, q{IsKeyDown}, q{ImGuiKey_ key}, `C++, "ImGui"`],
		[q{bool}, q{IsKeyPressed}, q{ImGuiKey_ key, bool repeat=true}, `C++, "ImGui"`],
		[q{bool}, q{IsKeyReleased}, q{ImGuiKey_ key}, `C++, "ImGui"`],
		[q{int}, q{GetKeyPressedAmount}, q{ImGuiKey_ key, float repeat_delay, float rate}, `C++, "ImGui"`],
		[q{const(char)*}, q{GetKeyName}, q{ImGuiKey_ key}, `C++, "ImGui"`],
		[q{void}, q{SetNextFrameWantCaptureKeyboard}, q{bool want_capture_keyboard}, `C++, "ImGui"`],
		
		[q{bool}, q{IsMouseDown}, q{ImGuiMouseButton_ button}, `C++, "ImGui"`],
		[q{bool}, q{IsMouseClicked}, q{ImGuiMouseButton_ button, bool repeat=false}, `C++, "ImGui"`],
		[q{bool}, q{IsMouseReleased}, q{ImGuiMouseButton_ button}, `C++, "ImGui"`],
		[q{bool}, q{IsMouseDoubleClicked}, q{ImGuiMouseButton_ button}, `C++, "ImGui"`],
		[q{int}, q{GetMouseClickedCount}, q{ImGuiMouseButton_ button}, `C++, "ImGui"`],
		[q{bool}, q{IsMouseHoveringRect}, q{ref const ImVec2 r_min, ref const ImVec2 r_max, bool clip=true}, `C++, "ImGui"`],
		[q{bool}, q{IsMousePosValid}, q{const(ImVec2)* mouse_pos=null}, `C++, "ImGui"`],
		[q{bool}, q{IsAnyMouseDown}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetMousePos}, q{}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetMousePosOnOpeningCurrentPopup}, q{}, `C++, "ImGui"`],
		[q{bool}, q{IsMouseDragging}, q{ImGuiMouseButton_ button, float lock_threshold=-1f}, `C++, "ImGui"`],
		[q{ImVec2}, q{GetMouseDragDelta}, q{ImGuiMouseButton_ button=0, float lock_threshold=-1f}, `C++, "ImGui"`],
		[q{void}, q{ResetMouseDragDelta}, q{ImGuiMouseButton_ button=0}, `C++, "ImGui"`],
		[q{ImGuiMouseCursor}, q{GetMouseCursor}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetMouseCursor}, q{ImGuiMouseCursor cursor_type}, `C++, "ImGui"`],
		[q{void}, q{SetNextFrameWantCaptureMouse}, q{bool want_capture_mouse}, `C++, "ImGui"`],
		
		[q{const(char)*}, q{GetClipboardText}, q{}, `C++, "ImGui"`],
		[q{void}, q{SetClipboardText}, q{const(char)* text}, `C++, "ImGui"`],
		
		[q{void}, q{LoadIniSettingsFromDisk}, q{const(char)* ini_filename}, `C++, "ImGui"`],
		[q{void}, q{LoadIniSettingsFromMemory}, q{const(char)* ini_data, size_t ini_size=0}, `C++, "ImGui"`],
		[q{void}, q{SaveIniSettingsToDisk}, q{const(char)* ini_filename}, `C++, "ImGui"`],
		[q{const(char)*}, q{SaveIniSettingsToMemory}, q{size_t* out_ini_size=null}, `C++, "ImGui"`],
		
		[q{void}, q{DebugTextEncoding}, q{const(char)* text}, `C++, "ImGui"`],
		[q{bool}, q{DebugCheckVersionAndDataLayout}, q{const(char)* version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert, size_t sz_drawidx}, `C++, "ImGui"`],
		[q{void}, q{SetAllocatorFunctions}, q{ImGuiMemAllocFunc alloc_func, ImGuiMemFreeFunc free_func, void* user_data=null}, `C++, "ImGui"`],
		[q{void}, q{GetAllocatorFunctions}, q{ImGuiMemAllocFunc* p_alloc_func, ImGuiMemFreeFunc* p_free_func, void** p_user_data}, `C++, "ImGui"`],
		[q{void*}, q{MemAlloc}, q{size_t size}, `C++, "ImGui"`],
		[q{void}, q{MemFree}, q{void* ptr}, `C++, "ImGui"`],
	]);
	version(ImGui_DisableObsoleteFunctions){
	}else{
		ret ~= makeFnBinds([
			[q{bool}, q{ImageButton}, q{ImTextureID user_texture_id, ref const ImVec2 size, ref const ImVec2 uv0=Vec2_0_0, ref const ImVec2 uv1=Vec2_1_1, int frame_padding=-1, ref const ImVec4 bg_col=Vec4_0_0_0_0, ref const ImVec4 tint_col=Vec4_1_1_1_1}, `C++, "ImGui"`],
			
			[q{void}, q{CalcListClipping}, q{int items_count, float items_height, int* out_items_display_start, int* out_items_display_end}, `C++, "ImGui"`],
		]);
	}
	return ret;
}(), __MODULE__));

alias StyleColoursDark = StyleColorsDark;
alias StyleColoursLight = StyleColorsLight;
alias StyleColoursClassic = StyleColorsClassic;
alias PushStyleColour = PushStyleColor;
alias PopStyleColour = PopStyleColor;
alias GetColourU32 = GetColorU32;
alias GetStyleColourVec4 = GetStyleColorVec4;
alias TextColoured = TextColored;
alias TextColouredV = TextColoredV;
alias ColourEdit3 = ColorEdit3;
alias ColourEdit4 = ColorEdit4;
alias ColourPicker3 = ColorPicker3;
alias ColourPicker4 = ColorPicker4;
alias ColourButton = ColorButton;
alias SetColourEditOptions = SetColorEditOptions;
alias TableSetBgColour = TableSetBgColor;
alias GetStyleColourName = GetStyleColorName;
alias ColourConvertU32ToFloat4 = ColorConvertU32ToFloat4;
alias ColourConvertFloat4ToU32 = ColorConvertFloat4ToU32;
alias ColourConvertRGBtoHSV = ColorConvertRGBtoHSV;
alias ColourConvertHSVtoRGB = ColorConvertHSVtoRGB;

pragma(inline,true) nothrow @nogc{
	auto IM_ALLOC(size_t _SIZE){ return MemAlloc(_SIZE); }
	auto IM_FREE(void* _PTR){ MemFree(_PTR); }
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

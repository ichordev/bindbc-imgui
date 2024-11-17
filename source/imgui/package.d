/+
+            Copyright 2023 – 2024 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui;

import bindbc.imgui.config;
import bindbc.imgui.codegen;

public import imgui.impl;

import core.lifetime: emplace, copyEmplace;
import std.algorithm.comparison: min, max, clamp;
import std.bitmanip: bitfields;

version(ImGui_DisableFileFunctions){
}else{
	import core.stdc.stdio: FILE;
}

version(OSX) version = Apple;
else version(iOS) version = Apple;
else version(TVOS) version = Apple;
else version(WatchOS) version = Apple;
else version(VisionOS) version = Apple;

pragma(inline,true) extern(C++) bool IMGUI_CHECKVERSION() nothrow @nogc =>
	DebugCheckVersionAndDataLayout(
		IMGUI_VERSION,
		ImGuiIO.sizeof, ImGuiStyle.sizeof,
		ImVec2.sizeof, ImVec4.sizeof,
		ImDrawVert.sizeof, ImDrawIdx.sizeof,
	);

alias ImGuiID = uint;
alias ImGuiKeyChord = int;
alias ImTextureID = ulong;
alias ImDrawIdx = ushort;
alias ImWChar32 = uint;
alias ImWChar16 = ushort;
version(ImGui_WChar32){
	alias ImWChar = ImWChar32;
}
version(ImGui_WChar32){
}else{
	alias ImWChar = ImWChar16;
}
alias ImGuiSelectionUserData = long;
alias ImGuiInputTextCallback = extern(C++) int function(ImGuiInputTextCallbackData* data) nothrow @nogc;
alias ImGuiSizeCallback = extern(C++) void function(ImGuiSizeCallbackData* data) nothrow @nogc;
alias ImGuiMemAllocFunc = extern(C++) void* function(size_t sz, void* userData) nothrow @nogc;
alias ImGuiMemFreeFunc = extern(C++) void function(void* ptr, void* userData) nothrow @nogc;
alias ImDrawCallback = extern(C++) void function(const(ImDrawList)* parentList, const(ImDrawCmd)* cmd) nothrow @nogc;

enum IMGUI_VERSION = "1.91.4";
enum IMGUI_VERSION_NUM = 19140;

alias ImGuiWindowFlags_ = int;
mixin(makeEnumBind(q{ImGuiWindowFlags}, q{ImGuiWindowFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                        q{ImGuiWindowFlags_None}},                       q{0}},
		{{q{noTitleBar},                  q{ImGuiWindowFlags_NoTitleBar}},                 q{1<<0}},
		{{q{noResize},                    q{ImGuiWindowFlags_NoResize}},                   q{1<<1}},
		{{q{noMove},                      q{ImGuiWindowFlags_NoMove}},                     q{1<<2}},
		{{q{noScrollbar},                 q{ImGuiWindowFlags_NoScrollbar}},                q{1<<3}},
		{{q{noScrollWithMouse},           q{ImGuiWindowFlags_NoScrollWithMouse}},          q{1<<4}},
		{{q{noCollapse},                  q{ImGuiWindowFlags_NoCollapse}},                 q{1<<5}},
		{{q{alwaysAutoResize},            q{ImGuiWindowFlags_AlwaysAutoResize}},           q{1<<6}},
		{{q{noBackground},                q{ImGuiWindowFlags_NoBackground}},               q{1<<7}},
		{{q{noSavedSettings},             q{ImGuiWindowFlags_NoSavedSettings}},            q{1<<8}},
		{{q{noMouseInputs},               q{ImGuiWindowFlags_NoMouseInputs}},              q{1<<9}},
		{{q{menuBar},                     q{ImGuiWindowFlags_MenuBar}},                    q{1<<10}},
		{{q{horizontalScrollbar},         q{ImGuiWindowFlags_HorizontalScrollbar}},        q{1<<11}},
		{{q{noFocusOnAppearing},          q{ImGuiWindowFlags_NoFocusOnAppearing}},         q{1<<12}},
		{{q{noBringToFrontOnFocus},       q{ImGuiWindowFlags_NoBringToFrontOnFocus}},      q{1<<13}},
		{{q{alwaysVerticalScrollbar},     q{ImGuiWindowFlags_AlwaysVerticalScrollbar}},    q{1<<14}},
		{{q{alwaysHorizontalScrollbar},   q{ImGuiWindowFlags_AlwaysHorizontalScrollbar}},  q{1<<15}},
		{{q{noNavInputs},                 q{ImGuiWindowFlags_NoNavInputs}},                q{1<<16}},
		{{q{noNavFocus},                  q{ImGuiWindowFlags_NoNavFocus}},                 q{1<<17}},
		{{q{unsavedDocument},             q{ImGuiWindowFlags_UnsavedDocument}},            q{1<<18}},
		{{q{noNav},                       q{ImGuiWindowFlags_NoNav}},                      q{noNavInputs | noNavFocus}},
		{{q{noDecoration},                q{ImGuiWindowFlags_NoDecoration}},               q{noTitleBar | noResize | noScrollbar | noCollapse}},
		{{q{noInputs},                    q{ImGuiWindowFlags_NoInputs}},                   q{noMouseInputs | noNavInputs | noNavFocus}},
		
		{{q{childWindow},                 q{ImGuiWindowFlags_ChildWindow}},                q{1<<24}},
		{{q{tooltip},                     q{ImGuiWindowFlags_Tooltip}},                    q{1<<25}},
		{{q{popup},                       q{ImGuiWindowFlags_Popup}},                      q{1<<26}},
		{{q{modal},                       q{ImGuiWindowFlags_Modal}},                      q{1<<27}},
		{{q{childMenu},                   q{ImGuiWindowFlags_ChildMenu}},                  q{1<<28}},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		EnumMember[] add = [
			{{q{alwaysUseWindowPadding},  q{ImGuiWindowFlags_AlwaysUseWindowPadding}},     q{1<<30}},
			{{q{navFlattened},            q{ImGuiWindowFlags_NavFlattened}},               q{1<<31}},
		];
		ret ~= add;
	}}
	return ret;
}()));

alias ImGuiChildFlags_ = int;
mixin(makeEnumBind(q{ImGuiChildFlags}, q{ImGuiChildFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                    q{ImGuiChildFlags_None}},                    q{0}},
		{{q{borders},                 q{ImGuiChildFlags_Borders}},                 q{1<<0}},
		{{q{alwaysUseWindowPadding},  q{ImGuiChildFlags_AlwaysUseWindowPadding}},  q{1<<1}},
		{{q{resizeX},                 q{ImGuiChildFlags_ResizeX}},                 q{1<<2}},
		{{q{resizeY},                 q{ImGuiChildFlags_ResizeY}},                 q{1<<3}},
		{{q{autoResizeX},             q{ImGuiChildFlags_AutoResizeX}},             q{1<<4}},
		{{q{autoResizeY},             q{ImGuiChildFlags_AutoResizeY}},             q{1<<5}},
		{{q{alwaysAutoResize},        q{ImGuiChildFlags_AlwaysAutoResize}},        q{1<<6}},
		{{q{frameStyle},              q{ImGuiChildFlags_FrameStyle}},              q{1<<7}},
		{{q{navFlattened},            q{ImGuiChildFlags_NavFlattened}},            q{1<<8}},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		EnumMember[] add = [
			{{q{border},              q{ImGuiChildFlags_Border}},                  q{borders}},
		];
		ret ~= add;
	}}
	return ret;
}()));

alias ImGuiItemFlags_ = int;
mixin(makeEnumBind(q{ImGuiItemFlags}, q{ImGuiItemFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                    q{ImGuiItemFlags_None}},                    q{0}},
		{{q{noTabStop},               q{ImGuiItemFlags_NoTabStop}},               q{1<<0}},
		{{q{noNav},                   q{ImGuiItemFlags_NoNav}},                   q{1<<1}},
		{{q{noNavDefaultFocus},       q{ImGuiItemFlags_NoNavDefaultFocus}},       q{1<<2}},
		{{q{buttonRepeat},            q{ImGuiItemFlags_ButtonRepeat}},            q{1<<3}},
		{{q{autoClosePopups},         q{ImGuiItemFlags_AutoClosePopups}},         q{1<<4}},
		{{q{allowDuplicateID},        q{ImGuiItemFlags_AllowDuplicateId}},        q{1<<5}},
		
		//private:
		{{q{disabled},                q{ImGuiItemFlags_Disabled}},                q{1<<10}},
		{{q{readOnly},                q{ImGuiItemFlags_ReadOnly}},                q{1<<11}},
		{{q{mixedValue},              q{ImGuiItemFlags_MixedValue}},              q{1<<12}},
		{{q{noWindowHoverableCheck},  q{ImGuiItemFlags_NoWindowHoverableCheck}},  q{1<<13}},
		{{q{allowOverlap},            q{ImGuiItemFlags_AllowOverlap}},            q{1<<14}},
		{{q{noNavDisableMouseHover},  q{ImGuiItemFlags_NoNavDisableMouseHover}},  q{1<<15}},
		{{q{noMarkEdited},            q{ImGuiItemFlags_NoMarkEdited}},            q{1<<16}},
		
		{{q{inputable},               q{ImGuiItemFlags_Inputable}},               q{1<<20}},
		{{q{hasSelectionUserData},    q{ImGuiItemFlags_HasSelectionUserData}},    q{1<<21}},
		{{q{isMultiSelect},           q{ImGuiItemFlags_IsMultiSelect}},           q{1<<22}},
		
		{{q{default_},                q{ImGuiItemFlags_Default_}},                q{autoClosePopups}},
	];
	return ret;
}()));
alias ImGuiInputTextFlags_ = int;
mixin(makeEnumBind(q{ImGuiInputTextFlags}, q{ImGuiInputTextFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                  q{ImGuiInputTextFlags_None}},                  q{0}},
		{{q{charsDecimal},          q{ImGuiInputTextFlags_CharsDecimal}},          q{1<<0}},
		{{q{charsHexadecimal},      q{ImGuiInputTextFlags_CharsHexadecimal}},      q{1<<1}},
		{{q{charsScientific},       q{ImGuiInputTextFlags_CharsScientific}},       q{1<<2}},
		{{q{charsUppercase},        q{ImGuiInputTextFlags_CharsUppercase}},        q{1<<3}},
		{{q{charsNoBlank},          q{ImGuiInputTextFlags_CharsNoBlank}},          q{1<<4}},
		
		{{q{allowTabInput},         q{ImGuiInputTextFlags_AllowTabInput}},         q{1<<5}},
		{{q{enterReturnsTrue},      q{ImGuiInputTextFlags_EnterReturnsTrue}},      q{1<<6}},
		{{q{escapeClearsAll},       q{ImGuiInputTextFlags_EscapeClearsAll}},       q{1<<7}},
		{{q{ctrlEnterForNewLine},   q{ImGuiInputTextFlags_CtrlEnterForNewLine}},   q{1<<8}},
		
		{{q{readOnly},              q{ImGuiInputTextFlags_ReadOnly}},              q{1<<9}},
		{{q{password},              q{ImGuiInputTextFlags_Password}},              q{1<<10}},
		{{q{alwaysOverwrite},       q{ImGuiInputTextFlags_AlwaysOverwrite}},       q{1<<11}},
		{{q{autoSelectAll},         q{ImGuiInputTextFlags_AutoSelectAll}},         q{1<<12}},
		{{q{parseEmptyRefVal},      q{ImGuiInputTextFlags_ParseEmptyRefVal}},      q{1<<13}},
		{{q{displayEmptyRefVal},    q{ImGuiInputTextFlags_DisplayEmptyRefVal}},    q{1<<14}},
		{{q{noHorizontalScroll},    q{ImGuiInputTextFlags_NoHorizontalScroll}},    q{1<<15}},
		{{q{noUndoRedo},            q{ImGuiInputTextFlags_NoUndoRedo}},            q{1<<16}},
		
		{{q{callbackCompletion},    q{ImGuiInputTextFlags_CallbackCompletion}},    q{1<<17}},
		{{q{callbackHistory},       q{ImGuiInputTextFlags_CallbackHistory}},       q{1<<18}},
		{{q{callbackAlways},        q{ImGuiInputTextFlags_CallbackAlways}},        q{1<<19}},
		{{q{callbackCharFilter},    q{ImGuiInputTextFlags_CallbackCharFilter}},    q{1<<20}},
		{{q{callbackResize},        q{ImGuiInputTextFlags_CallbackResize}},        q{1<<21}},
		{{q{callbackEdit},          q{ImGuiInputTextFlags_CallbackEdit}},          q{1<<22}},
		
		//private:
		{{q{multiline},             q{ImGuiInputTextFlags_Multiline}},             q{1<<26}},
		{{q{mergedItem},            q{ImGuiInputTextFlags_MergedItem}},            q{1<<27}},
		{{q{localiseDecimalPoint},  q{ImGuiInputTextFlags_LocaliseDecimalPoint}},  q{1<<28}, aliases: [{q{localizeDecimalPoint}, q{ImGuiInputTextFlags_LocalizeDecimalPoint}}]},
	];
	return ret;
}()));
alias ImGuiTreeNodeFlags_ = int;
mixin(makeEnumBind(q{ImGuiTreeNodeFlags}, q{ImGuiTreeNodeFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                        q{ImGuiTreeNodeFlags_None}},                        q{0}},
		{{q{selected},                    q{ImGuiTreeNodeFlags_Selected}},                    q{1<<0}},
		{{q{framed},                      q{ImGuiTreeNodeFlags_Framed}},                      q{1<<1}},
		{{q{allowOverlap},                q{ImGuiTreeNodeFlags_AllowOverlap}},                q{1<<2}},
		{{q{noTreePushOnOpen},            q{ImGuiTreeNodeFlags_NoTreePushOnOpen}},            q{1<<3}},
		{{q{noAutoOpenOnLog},             q{ImGuiTreeNodeFlags_NoAutoOpenOnLog}},             q{1<<4}},
		{{q{defaultOpen},                 q{ImGuiTreeNodeFlags_DefaultOpen}},                 q{1<<5}},
		{{q{openOnDoubleClick},           q{ImGuiTreeNodeFlags_OpenOnDoubleClick}},           q{1<<6}},
		{{q{openOnArrow},                 q{ImGuiTreeNodeFlags_OpenOnArrow}},                 q{1<<7}},
		{{q{leaf},                        q{ImGuiTreeNodeFlags_Leaf}},                        q{1<<8}},
		{{q{bullet},                      q{ImGuiTreeNodeFlags_Bullet}},                      q{1<<9}},
		{{q{framePadding},                q{ImGuiTreeNodeFlags_FramePadding}},                q{1<<10}},
		{{q{spanAvailWidth},              q{ImGuiTreeNodeFlags_SpanAvailWidth}},              q{1<<11}},
		{{q{spanFullWidth},               q{ImGuiTreeNodeFlags_SpanFullWidth}},               q{1<<12}},
		{{q{spanTextWidth},               q{ImGuiTreeNodeFlags_SpanTextWidth}},               q{1<<13}},
		{{q{spanAllColumns},              q{ImGuiTreeNodeFlags_SpanAllColumns}},              q{1<<14}},
		{{q{navLeftJumpsBackHere},        q{ImGuiTreeNodeFlags_NavLeftJumpsBackHere}},        q{1<<15}},
		
		{{q{collapsingHeader},            q{ImGuiTreeNodeFlags_CollapsingHeader}},            q{framed | noTreePushOnOpen | noAutoOpenOnLog}},
		
		//private:
		{{q{clipLabelForTrailingButton},  q{ImGuiTreeNodeFlags_ClipLabelForTrailingButton}},  q{1<<28}},
		{{q{upsideDownArrow},             q{ImGuiTreeNodeFlags_UpsideDownArrow}},             q{1<<29}},
		{{q{openOnMask},                  q{ImGuiTreeNodeFlags_OpenOnMask_}},                 q{openOnDoubleClick | openOnArrow}},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		EnumMember[] add = [
			{{q{allowItemOverlap},        q{ImGuiTreeNodeFlags_AllowItemOverlap}},            q{allowOverlap}},
		];
		ret ~= add;
	}}
	return ret;
}()));

alias ImGuiPopupFlags_ = int;
mixin(makeEnumBind(q{ImGuiPopupFlags}, q{ImGuiPopupFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                     q{ImGuiPopupFlags_None}},                     q{0}},
		{{q{mouseButtonLeft},          q{ImGuiPopupFlags_MouseButtonLeft}},          q{0}},
		{{q{mouseButtonRight},         q{ImGuiPopupFlags_MouseButtonRight}},         q{1}},
		{{q{mouseButtonMiddle},        q{ImGuiPopupFlags_MouseButtonMiddle}},        q{2}},
		{{q{mouseButtonMask},          q{ImGuiPopupFlags_MouseButtonMask_}},         q{0x1F}},
		{{q{mouseButtonDefault},       q{ImGuiPopupFlags_MouseButtonDefault_}},      q{1}},
		{{q{noReopen},                 q{ImGuiPopupFlags_NoReopen}},                 q{1<<5}},
		
		{{q{noOpenOverExistingPopup},  q{ImGuiPopupFlags_NoOpenOverExistingPopup}},  q{1<<7}},
		{{q{noOpenOverItems},          q{ImGuiPopupFlags_NoOpenOverItems}},          q{1<<8}},
		{{q{anyPopupID},               q{ImGuiPopupFlags_AnyPopupId}},               q{1<<10}},
		{{q{anyPopupLevel},            q{ImGuiPopupFlags_AnyPopupLevel}},            q{1<<11}},
		{{q{anyPopup},                 q{ImGuiPopupFlags_AnyPopup}},                 q{anyPopupID | anyPopupLevel}},
	];
	return ret;
}()));

alias ImGuiSelectableFlags_ = int;
mixin(makeEnumBind(q{ImGuiSelectableFlags}, q{ImGuiSelectableFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                  q{ImGuiSelectableFlags_None}},                  q{0}},
		{{q{noAutoClosePopups},     q{ImGuiSelectableFlags_NoAutoClosePopups}},     q{1<<0}},
		{{q{spanAllColumns},        q{ImGuiSelectableFlags_SpanAllColumns}},        q{1<<1}},
		{{q{allowDoubleClick},      q{ImGuiSelectableFlags_AllowDoubleClick}},      q{1<<2}},
		{{q{disabled},              q{ImGuiSelectableFlags_Disabled}},              q{1<<3}},
		{{q{allowOverlap},          q{ImGuiSelectableFlags_AllowOverlap}},          q{1<<4}},
		{{q{highlight},             q{ImGuiSelectableFlags_Highlight}},             q{1<<5}},
		
		//private:
		{{q{noHoldingActiveID},     q{ImGuiSelectableFlags_NoHoldingActiveID}},     q{1<<20}},
		{{q{selectOnNav},           q{ImGuiSelectableFlags_SelectOnNav}},           q{1<<21}},
		{{q{selectOnClick},         q{ImGuiSelectableFlags_SelectOnClick}},         q{1<<22}},
		{{q{selectOnRelease},       q{ImGuiSelectableFlags_SelectOnRelease}},       q{1<<23}},
		{{q{spanAvailWidth},        q{ImGuiSelectableFlags_SpanAvailWidth}},        q{1<<24}},
		{{q{setNavIDOnHover},       q{ImGuiSelectableFlags_SetNavIdOnHover}},       q{1<<25}},
		{{q{noPadWithHalfSpacing},  q{ImGuiSelectableFlags_NoPadWithHalfSpacing}},  q{1<<26}},
		{{q{noSetKeyOwner},         q{ImGuiSelectableFlags_NoSetKeyOwner}},         q{1<<27}},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		EnumMember[] add = [
			{{q{dontClosePopups},   q{ImGuiSelectableFlags_DontClosePopups}},       q{noAutoClosePopups}},
			{{q{allowItemOverlap},  q{ImGuiSelectableFlags_AllowItemOverlap}},      q{allowOverlap}},
		];
		ret ~= add;
	}}
	return ret;
}()));
alias ImGuiComboFlags_ = int;
mixin(makeEnumBind(q{ImGuiComboFlags}, q{ImGuiComboFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},             q{ImGuiComboFlags_None}},             q{0}},
		{{q{popupAlignLeft},   q{ImGuiComboFlags_PopupAlignLeft}},   q{1<<0}},
		{{q{heightSmall},      q{ImGuiComboFlags_HeightSmall}},      q{1<<1}},
		{{q{heightRegular},    q{ImGuiComboFlags_HeightRegular}},    q{1<<2}},
		{{q{heightLarge},      q{ImGuiComboFlags_HeightLarge}},      q{1<<3}},
		{{q{heightLargest},    q{ImGuiComboFlags_HeightLargest}},    q{1<<4}},
		{{q{noArrowButton},    q{ImGuiComboFlags_NoArrowButton}},    q{1<<5}},
		{{q{noPreview},        q{ImGuiComboFlags_NoPreview}},        q{1<<6}},
		{{q{widthFitPreview},  q{ImGuiComboFlags_WidthFitPreview}},  q{1<<7}},
		{{q{heightMask},       q{ImGuiComboFlags_HeightMask_}},      q{heightSmall | heightRegular | heightLarge | heightLargest}},
		
		//private:
		{{q{customPreview},    q{ImGuiComboFlags_CustomPreview}},    q{1<<20}},
	];
	return ret;
}()));
alias ImGuiTabBarFlags_ = int;
mixin(makeEnumBind(q{ImGuiTabBarFlags}, q{ImGuiTabBarFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                          q{ImGuiTabBarFlags_None}},                          q{0}},
		{{q{reorderable},                   q{ImGuiTabBarFlags_Reorderable}},                   q{1<<0}},
		{{q{autoSelectNewTabs},             q{ImGuiTabBarFlags_AutoSelectNewTabs}},             q{1<<1}},
		{{q{tabListPopupButton},            q{ImGuiTabBarFlags_TabListPopupButton}},            q{1<<2}},
		{{q{noCloseWithMiddleMouseButton},  q{ImGuiTabBarFlags_NoCloseWithMiddleMouseButton}},  q{1<<3}},
		{{q{noTabListScrollingButtons},     q{ImGuiTabBarFlags_NoTabListScrollingButtons}},     q{1<<4}},
		{{q{noTooltip},                     q{ImGuiTabBarFlags_NoTooltip}},                     q{1<<5}},
		{{q{drawSelectedOverline},          q{ImGuiTabBarFlags_DrawSelectedOverline}},          q{1<<6}},
		{{q{fittingPolicyResizeDown},       q{ImGuiTabBarFlags_FittingPolicyResizeDown}},       q{1<<7}},
		{{q{fittingPolicyScroll},           q{ImGuiTabBarFlags_FittingPolicyScroll}},           q{1<<8}},
		{{q{fittingPolicyMask},             q{ImGuiTabBarFlags_FittingPolicyMask_}},            q{fittingPolicyResizeDown | fittingPolicyScroll}},
		{{q{fittingPolicyDefault},          q{ImGuiTabBarFlags_FittingPolicyDefault_}},         q{fittingPolicyResizeDown}},
		
		//private:
		{{q{dockNode},                      q{ImGuiTabBarFlags_DockNode}},                      q{1<<20}},
		{{q{isFocused},                     q{ImGuiTabBarFlags_IsFocused}},                     q{1<<21}},
		{{q{saveSettings},                  q{ImGuiTabBarFlags_SaveSettings}},                  q{1<<22}},
	];
	return ret;
}()));
alias ImGuiTabItemFlags_ = int;
mixin(makeEnumBind(q{ImGuiTabItemFlags}, q{ImGuiTabItemFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                          q{ImGuiTabItemFlags_None}},                          q{0}},
		{{q{unsavedDocument},               q{ImGuiTabItemFlags_UnsavedDocument}},               q{1<<0}},
		{{q{setSelected},                   q{ImGuiTabItemFlags_SetSelected}},                   q{1<<1}},
		{{q{noCloseWithMiddleMouseButton},  q{ImGuiTabItemFlags_NoCloseWithMiddleMouseButton}},  q{1<<2}},
		{{q{noPushID},                      q{ImGuiTabItemFlags_NoPushId}},                      q{1<<3}},
		{{q{noTooltip},                     q{ImGuiTabItemFlags_NoTooltip}},                     q{1<<4}},
		{{q{noReorder},                     q{ImGuiTabItemFlags_NoReorder}},                     q{1<<5}},
		{{q{leading},                       q{ImGuiTabItemFlags_Leading}},                       q{1<<6}},
		{{q{trailing},                      q{ImGuiTabItemFlags_Trailing}},                      q{1<<7}},
		{{q{noAssumedClosure},              q{ImGuiTabItemFlags_NoAssumedClosure}},              q{1<<8}},
		
		//private:
		{{q{sectionMask},                   q{ImGuiTabItemFlags_SectionMask_}},                  q{leading | trailing}},
		{{q{noCloseButton},                 q{ImGuiTabItemFlags_NoCloseButton}},                 q{1<<20}},
		{{q{button},                        q{ImGuiTabItemFlags_Button}},                        q{1<<21}},
	];
	return ret;
}()));
alias ImGuiFocusedFlags_ = int;
mixin(makeEnumBind(q{ImGuiFocusedFlags}, q{ImGuiFocusedFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                 q{ImGuiFocusedFlags_None}},                 q{0}},
		{{q{childWindows},         q{ImGuiFocusedFlags_ChildWindows}},         q{1<<0}},
		{{q{rootWindow},           q{ImGuiFocusedFlags_RootWindow}},           q{1<<1}},
		{{q{anyWindow},            q{ImGuiFocusedFlags_AnyWindow}},            q{1<<2}},
		{{q{noPopupHierarchy},     q{ImGuiFocusedFlags_NoPopupHierarchy}},     q{1<<3}},
		
		{{q{rootAndChildWindows},  q{ImGuiFocusedFlags_RootAndChildWindows}},  q{rootWindow | childWindows}},
	];
	return ret;
}()));

alias ImGuiHoveredFlags_ = int;
mixin(makeEnumBind(q{ImGuiHoveredFlags}, q{ImGuiHoveredFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                           q{ImGuiHoveredFlags_None}},                           q{0}},
		{{q{childWindows},                   q{ImGuiHoveredFlags_ChildWindows}},                   q{1<<0}},
		{{q{rootWindow},                     q{ImGuiHoveredFlags_RootWindow}},                     q{1<<1}},
		{{q{anyWindow},                      q{ImGuiHoveredFlags_AnyWindow}},                      q{1<<2}},
		{{q{noPopupHierarchy},               q{ImGuiHoveredFlags_NoPopupHierarchy}},               q{1<<3}},
		
		{{q{allowWhenBlockedByPopup},        q{ImGuiHoveredFlags_AllowWhenBlockedByPopup}},        q{1<<5}},
		
		{{q{allowWhenBlockedByActiveItem},   q{ImGuiHoveredFlags_AllowWhenBlockedByActiveItem}},   q{1<<7}},
		{{q{allowWhenOverlappedByItem},      q{ImGuiHoveredFlags_AllowWhenOverlappedByItem}},      q{1<<8}},
		{{q{allowWhenOverlappedByWindow},    q{ImGuiHoveredFlags_AllowWhenOverlappedByWindow}},    q{1<<9}},
		{{q{allowWhenDisabled},              q{ImGuiHoveredFlags_AllowWhenDisabled}},              q{1<<10}},
		{{q{noNavOverride},                  q{ImGuiHoveredFlags_NoNavOverride}},                  q{1<<11}},
		{{q{allowWhenOverlapped},            q{ImGuiHoveredFlags_AllowWhenOverlapped}},            q{allowWhenOverlappedByItem | allowWhenOverlappedByWindow}},
		{{q{rectOnly},                       q{ImGuiHoveredFlags_RectOnly}},                       q{allowWhenBlockedByPopup | allowWhenBlockedByActiveItem | allowWhenOverlapped}},
		{{q{rootAndChildWindows},            q{ImGuiHoveredFlags_RootAndChildWindows}},            q{rootWindow | childWindows}},
		
		{{q{forTooltip},                     q{ImGuiHoveredFlags_ForTooltip}},                     q{1<<12}},
		
		{{q{stationary},                     q{ImGuiHoveredFlags_Stationary}},                     q{1<<13}},
		{{q{delayNone},                      q{ImGuiHoveredFlags_DelayNone}},                      q{1<<14}},
		{{q{delayShort},                     q{ImGuiHoveredFlags_DelayShort}},                     q{1<<15}},
		{{q{delayNormal},                    q{ImGuiHoveredFlags_DelayNormal}},                    q{1<<16}},
		{{q{noSharedDelay},                  q{ImGuiHoveredFlags_NoSharedDelay}},                  q{1<<17}},
		
		//private:
		{{q{delayMask},                      q{ImGuiHoveredFlags_DelayMask_}},                     q{delayNone | delayShort | delayNormal | noSharedDelay}},
		{{q{allowedMaskForIsWindowHovered},  q{ImGuiHoveredFlags_AllowedMaskForIsWindowHovered}},  q{childWindows | rootWindow | anyWindow | noPopupHierarchy | allowWhenBlockedByPopup | allowWhenBlockedByActiveItem | forTooltip | stationary}},
		{{q{allowedMaskForIsItemHovered},    q{ImGuiHoveredFlags_AllowedMaskForIsItemHovered}},    q{allowWhenBlockedByPopup | allowWhenBlockedByActiveItem | allowWhenOverlapped | allowWhenDisabled | noNavOverride | forTooltip | stationary | delayMask}},
	];
	return ret;
}()));
alias ImGuiDragDropFlags_ = int;
mixin(makeEnumBind(q{ImGuiDragDropFlags}, q{ImGuiDragDropFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                         q{ImGuiDragDropFlags_None}},                      q{0}},
		
		{{q{sourceNoPreviewTooltip},       q{ImGuiDragDropFlags_SourceNoPreviewTooltip}},    q{1<<0}},
		{{q{sourceNoDisableHover},         q{ImGuiDragDropFlags_SourceNoDisableHover}},      q{1<<1}},
		{{q{sourceNoHoldToOpenOthers},     q{ImGuiDragDropFlags_SourceNoHoldToOpenOthers}},  q{1<<2}},
		{{q{sourceAllowNullID},            q{ImGuiDragDropFlags_SourceAllowNullID}},         q{1<<3}},
		{{q{sourceExtern},                 q{ImGuiDragDropFlags_SourceExtern}},              q{1<<4}},
		{{q{payloadAutoExpire},            q{ImGuiDragDropFlags_PayloadAutoExpire}},         q{1<<5}},
		{{q{payloadNoCrossContext},        q{ImGuiDragDropFlags_PayloadNoCrossContext}},     q{1<<6}},
		{{q{payloadNoCrossProcess},        q{ImGuiDragDropFlags_PayloadNoCrossProcess}},     q{1<<7}},
		
		{{q{acceptBeforeDelivery},         q{ImGuiDragDropFlags_AcceptBeforeDelivery}},      q{1<<10}},
		{{q{acceptNoDrawDefaultRect},      q{ImGuiDragDropFlags_AcceptNoDrawDefaultRect}},   q{1<<11}},
		{{q{acceptNoPreviewTooltip},       q{ImGuiDragDropFlags_AcceptNoPreviewTooltip}},    q{1<<12}},
		{{q{acceptPeekOnly},               q{ImGuiDragDropFlags_AcceptPeekOnly}},            q{acceptBeforeDelivery | acceptNoDrawDefaultRect}},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		EnumMember[] add = [
			{{q{sourceAutoExpirePayload},  q{ImGuiDragDropFlags_SourceAutoExpirePayload}},   q{payloadAutoExpire}},
		];
		ret ~= add;
	}}
	return ret;
}()));

enum IMGUI_PAYLOAD_TYPE_COLOR_3F = "_COL3F";
enum IMGUI_PAYLOAD_TYPE_COLOR_4F = "_COL4F";

alias ImGuiDataType_ = int;
mixin(makeEnumBind(q{ImGuiDataType}, q{ImGuiDataType_}, members: (){
	EnumMember[] ret = [
		{{q{s8},       q{ImGuiDataType_S8}}},
		{{q{u8},       q{ImGuiDataType_U8}}},
		{{q{s16},      q{ImGuiDataType_S16}}},
		{{q{u16},      q{ImGuiDataType_U16}}},
		{{q{s32},      q{ImGuiDataType_S32}}},
		{{q{u32},      q{ImGuiDataType_U32}}},
		{{q{s64},      q{ImGuiDataType_S64}}},
		{{q{u64},      q{ImGuiDataType_U64}}},
		{{q{float_},   q{ImGuiDataType_Float}}},
		{{q{double_},  q{ImGuiDataType_Double}}},
		{{q{bool_},    q{ImGuiDataType_Bool}}},
		{{q{count},    q{ImGuiDataType_COUNT}}},
		
		//private:
		{{q{string},   q{ImGuiDataType_String}},  q{count+1}},
		{{q{pointer},  q{ImGuiDataType_Pointer}}},
		{{q{id},       q{ImGuiDataType_ID}}},
	];
	return ret;
}()));
mixin(makeEnumBind(q{ImGuiDir}, q{int}, members: (){
	EnumMember[] ret = [
		{{q{none},   q{ImGuiDir_None}},   q{-1}},
		{{q{left},   q{ImGuiDir_Left}},   q{0}},
		{{q{right},  q{ImGuiDir_Right}},  q{1}},
		{{q{up},     q{ImGuiDir_Up}},     q{2}},
		{{q{down},   q{ImGuiDir_Down}},   q{3}},
		{{q{count},  q{ImGuiDir_COUNT}}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiSortDirection}, q{ubyte}, members: (){
	EnumMember[] ret = [
		{{q{none},        q{ImGuiSortDirection_None}},        q{0}},
		{{q{ascending},   q{ImGuiSortDirection_Ascending}},   q{1}},
		{{q{descending},  q{ImGuiSortDirection_Descending}},  q{2}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiKey}, q{int}, members: (){
	EnumMember[] ret = [
		{{q{none},                 q{ImGuiKey_None}},  q{0}},
		{{q{tab},                  q{ImGuiKey_Tab}},   q{512}},
		{{q{leftArrow},            q{ImGuiKey_LeftArrow}}},
		{{q{rightArrow},           q{ImGuiKey_RightArrow}}},
		{{q{upArrow},              q{ImGuiKey_UpArrow}}},
		{{q{downArrow},            q{ImGuiKey_DownArrow}}},
		{{q{pageUp},               q{ImGuiKey_PageUp}}},
		{{q{pageDown},             q{ImGuiKey_PageDown}}},
		{{q{home},                 q{ImGuiKey_Home}}},
		{{q{end},                  q{ImGuiKey_End}}},
		{{q{insert},               q{ImGuiKey_Insert}}},
		{{q{delete_},              q{ImGuiKey_Delete}}},
		{{q{backspace},            q{ImGuiKey_Backspace}}},
		{{q{space},                q{ImGuiKey_Space}}},
		{{q{enter},                q{ImGuiKey_Enter}}},
		{{q{escape},               q{ImGuiKey_Escape}}},
		{{q{leftCtrl},             q{ImGuiKey_LeftCtrl}}},
		{{q{leftShift},            q{ImGuiKey_LeftShift}}},
		{{q{leftAlt},              q{ImGuiKey_LeftAlt}}},
		{{q{leftSuper},            q{ImGuiKey_LeftSuper}}},
		{{q{rightCtrl},            q{ImGuiKey_RightCtrl}}},
		{{q{rightShift},           q{ImGuiKey_RightShift}}},
		{{q{rightAlt},             q{ImGuiKey_RightAlt}}},
		{{q{rightSuper},           q{ImGuiKey_RightSuper}}},
		{{q{menu},                 q{ImGuiKey_Menu}}},
		{{q{_0},                   q{ImGuiKey_0}}},
		{{q{_1},                   q{ImGuiKey_1}}},
		{{q{_2},                   q{ImGuiKey_2}}},
		{{q{_3},                   q{ImGuiKey_3}}},
		{{q{_4},                   q{ImGuiKey_4}}},
		{{q{_5},                   q{ImGuiKey_5}}},
		{{q{_6},                   q{ImGuiKey_6}}},
		{{q{_7},                   q{ImGuiKey_7}}},
		{{q{_8},                   q{ImGuiKey_8}}},
		{{q{_9},                   q{ImGuiKey_9}}},
		{{q{a},                    q{ImGuiKey_A}}},
		{{q{b},                    q{ImGuiKey_B}}},
		{{q{c},                    q{ImGuiKey_C}}},
		{{q{d},                    q{ImGuiKey_D}}},
		{{q{e},                    q{ImGuiKey_E}}},
		{{q{f},                    q{ImGuiKey_F}}},
		{{q{g},                    q{ImGuiKey_G}}},
		{{q{h},                    q{ImGuiKey_H}}},
		{{q{i},                    q{ImGuiKey_I}}},
		{{q{j},                    q{ImGuiKey_J}}},
		{{q{k},                    q{ImGuiKey_K}}},
		{{q{l},                    q{ImGuiKey_L}}},
		{{q{m},                    q{ImGuiKey_M}}},
		{{q{n},                    q{ImGuiKey_N}}},
		{{q{o},                    q{ImGuiKey_O}}},
		{{q{p},                    q{ImGuiKey_P}}},
		{{q{q},                    q{ImGuiKey_Q}}},
		{{q{r},                    q{ImGuiKey_R}}},
		{{q{s},                    q{ImGuiKey_S}}},
		{{q{t},                    q{ImGuiKey_T}}},
		{{q{u},                    q{ImGuiKey_U}}},
		{{q{v},                    q{ImGuiKey_V}}},
		{{q{w},                    q{ImGuiKey_W}}},
		{{q{x},                    q{ImGuiKey_X}}},
		{{q{y},                    q{ImGuiKey_Y}}},
		{{q{z},                    q{ImGuiKey_Z}}},
		{{q{f1},                   q{ImGuiKey_F1}}},
		{{q{f2},                   q{ImGuiKey_F2}}},
		{{q{f3},                   q{ImGuiKey_F3}}},
		{{q{f4},                   q{ImGuiKey_F4}}},
		{{q{f5},                   q{ImGuiKey_F5}}},
		{{q{f6},                   q{ImGuiKey_F6}}},
		{{q{f7},                   q{ImGuiKey_F7}}},
		{{q{f8},                   q{ImGuiKey_F8}}},
		{{q{f9},                   q{ImGuiKey_F9}}},
		{{q{f10},                  q{ImGuiKey_F10}}},
		{{q{f11},                  q{ImGuiKey_F11}}},
		{{q{f12},                  q{ImGuiKey_F12}}},
		{{q{f13},                  q{ImGuiKey_F13}}},
		{{q{f14},                  q{ImGuiKey_F14}}},
		{{q{f15},                  q{ImGuiKey_F15}}},
		{{q{f16},                  q{ImGuiKey_F16}}},
		{{q{f17},                  q{ImGuiKey_F17}}},
		{{q{f18},                  q{ImGuiKey_F18}}},
		{{q{f19},                  q{ImGuiKey_F19}}},
		{{q{f20},                  q{ImGuiKey_F20}}},
		{{q{f21},                  q{ImGuiKey_F21}}},
		{{q{f22},                  q{ImGuiKey_F22}}},
		{{q{f23},                  q{ImGuiKey_F23}}},
		{{q{f24},                  q{ImGuiKey_F24}}},
		{{q{apostrophe},           q{ImGuiKey_Apostrophe}}},
		{{q{comma},                q{ImGuiKey_Comma}}},
		{{q{minus},                q{ImGuiKey_Minus}}},
		{{q{period},               q{ImGuiKey_Period}}},
		{{q{slash},                q{ImGuiKey_Slash}}},
		{{q{semicolon},            q{ImGuiKey_Semicolon}}},
		{{q{equal},                q{ImGuiKey_Equal}}},
		{{q{leftBracket},          q{ImGuiKey_LeftBracket}}},
		{{q{backslash},            q{ImGuiKey_Backslash}}},
		{{q{rightBracket},         q{ImGuiKey_RightBracket}}},
		{{q{graveAccent},          q{ImGuiKey_GraveAccent}}},
		{{q{capsLock},             q{ImGuiKey_CapsLock}}},
		{{q{scrollLock},           q{ImGuiKey_ScrollLock}}},
		{{q{numLock},              q{ImGuiKey_NumLock}}},
		{{q{printScreen},          q{ImGuiKey_PrintScreen}}},
		{{q{pause},                q{ImGuiKey_Pause}}},
		{{q{keypad0},              q{ImGuiKey_Keypad0}}},
		{{q{keypad1},              q{ImGuiKey_Keypad1}}},
		{{q{keypad2},              q{ImGuiKey_Keypad2}}},
		{{q{keypad3},              q{ImGuiKey_Keypad3}}},
		{{q{keypad4},              q{ImGuiKey_Keypad4}}},
		{{q{keypad5},              q{ImGuiKey_Keypad5}}},
		{{q{keypad6},              q{ImGuiKey_Keypad6}}},
		{{q{keypad7},              q{ImGuiKey_Keypad7}}},
		{{q{keypad8},              q{ImGuiKey_Keypad8}}},
		{{q{keypad9},              q{ImGuiKey_Keypad9}}},
		{{q{keypadDecimal},        q{ImGuiKey_KeypadDecimal}}},
		{{q{keypadDivide},         q{ImGuiKey_KeypadDivide}}},
		{{q{keypadMultiply},       q{ImGuiKey_KeypadMultiply}}},
		{{q{keypadSubtract},       q{ImGuiKey_KeypadSubtract}}},
		{{q{keypadAdd},            q{ImGuiKey_KeypadAdd}}},
		{{q{keypadEnter},          q{ImGuiKey_KeypadEnter}}},
		{{q{keypadEqual},          q{ImGuiKey_KeypadEqual}}},
		{{q{appBack},              q{ImGuiKey_AppBack}}},
		{{q{appForward},           q{ImGuiKey_AppForward}}},
		
		{{q{gamepadStart},         q{ImGuiKey_GamepadStart}}},
		{{q{gamepadBack},          q{ImGuiKey_GamepadBack}}},
		{{q{gamepadFaceLeft},      q{ImGuiKey_GamepadFaceLeft}}},
		{{q{gamepadFaceRight},     q{ImGuiKey_GamepadFaceRight}}},
		{{q{gamepadFaceUp},        q{ImGuiKey_GamepadFaceUp}}},
		{{q{gamepadFaceDown},      q{ImGuiKey_GamepadFaceDown}}},
		{{q{gamepadDpadLeft},      q{ImGuiKey_GamepadDpadLeft}}},
		{{q{gamepadDpadRight},     q{ImGuiKey_GamepadDpadRight}}},
		{{q{gamepadDpadUp},        q{ImGuiKey_GamepadDpadUp}}},
		{{q{gamepadDpadDown},      q{ImGuiKey_GamepadDpadDown}}},
		{{q{gamepadL1},            q{ImGuiKey_GamepadL1}}},
		{{q{gamepadR1},            q{ImGuiKey_GamepadR1}}},
		{{q{gamepadL2},            q{ImGuiKey_GamepadL2}}},
		{{q{gamepadR2},            q{ImGuiKey_GamepadR2}}},
		{{q{gamepadL3},            q{ImGuiKey_GamepadL3}}},
		{{q{gamepadR3},            q{ImGuiKey_GamepadR3}}},
		{{q{gamepadLStickLeft},    q{ImGuiKey_GamepadLStickLeft}}},
		{{q{gamepadLStickRight},   q{ImGuiKey_GamepadLStickRight}}},
		{{q{gamepadLStickUp},      q{ImGuiKey_GamepadLStickUp}}},
		{{q{gamepadLStickDown},    q{ImGuiKey_GamepadLStickDown}}},
		{{q{gamepadRStickLeft},    q{ImGuiKey_GamepadRStickLeft}}},
		{{q{gamepadRStickRight},   q{ImGuiKey_GamepadRStickRight}}},
		{{q{gamepadRStickUp},      q{ImGuiKey_GamepadRStickUp}}},
		{{q{gamepadRStickDown},    q{ImGuiKey_GamepadRStickDown}}},
		
		{{q{mouseLeft},            q{ImGuiKey_MouseLeft}}},
		{{q{mouseRight},           q{ImGuiKey_MouseRight}}},
		{{q{mouseMiddle},          q{ImGuiKey_MouseMiddle}}},
		{{q{mouseX1},              q{ImGuiKey_MouseX1}}},
		{{q{mouseX2},              q{ImGuiKey_MouseX2}}},
		{{q{mouseWheelX},          q{ImGuiKey_MouseWheelX}}},
		{{q{mouseWheelY},          q{ImGuiKey_MouseWheelY}}},
		
		{{q{reservedForModCtrl},   q{ImGuiKey_ReservedForModCtrl}}},
		{{q{reservedForModShift},  q{ImGuiKey_ReservedForModShift}}},
		{{q{reservedForModAlt},    q{ImGuiKey_ReservedForModAlt}}},
		{{q{reservedForModSuper},  q{ImGuiKey_ReservedForModSuper}}},
		{{q{count},                q{ImGuiKey_COUNT}}},
		
		{{q{namedKeyBegin},        q{ImGuiKey_NamedKey_BEGIN}},   q{512}},
		{{q{namedKeyEnd},          q{ImGuiKey_NamedKey_END}},     q{count}},
		{{q{namedKeyCount},        q{ImGuiKey_NamedKey_COUNT}},   q{namedKeyEnd-namedKeyBegin}},
	];
	version(ImGui_DisableObsoleteKeyIO){{
		EnumMember[] add = [
			{{q{keysDataSize},     q{ImGuiKey_KeysData_SIZE}},    q{namedKeyCount}},
			{{q{keysDataOffset},   q{ImGuiKey_KeysData_OFFSET}},  q{namedKeyBegin}},
		];
		ret ~= add;
	}}
	version(ImGui_DisableObsoleteKeyIO){
	}else{{
		EnumMember[] add = [
			{{q{keysDataSize},     q{ImGuiKey_KeysData_SIZE}},    q{count}},
			{{q{keysDataOffset},   q{ImGuiKey_KeysData_OFFSET}},  q{0}},
		];
		ret ~= add;
	}}
	return ret;
}()));
mixin(makeEnumBind(q{ImGuiMod}, q{int}, members: (){
	EnumMember[] ret = [
		{{q{none},    q{ImGuiMod_None}},   q{0}},
		{{q{ctrl},    q{ImGuiMod_Ctrl}},   q{1<<12}},
		{{q{shift},   q{ImGuiMod_Shift}},  q{1<<13}},
		{{q{alt},     q{ImGuiMod_Alt}},    q{1<<14}},
		{{q{super_},  q{ImGuiMod_Super}},  q{1<<15}},
		{{q{mask},    q{ImGuiMod_Mask_}},  q{0xF000}},
	];
	return ret;
}()));

alias ImGuiInputFlags_ = int;
mixin(makeEnumBind(q{ImGuiInputFlags}, q{ImGuiInputFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                              q{ImGuiInputFlags_None}},                              q{0}},
		{{q{repeat},                            q{ImGuiInputFlags_Repeat}},                            q{1<<0}},
		
		{{q{routeActive},                       q{ImGuiInputFlags_RouteActive}},                       q{1<<10}},
		{{q{routeFocused},                      q{ImGuiInputFlags_RouteFocused}},                      q{1<<11}},
		{{q{routeGlobal},                       q{ImGuiInputFlags_RouteGlobal}},                       q{1<<12}},
		{{q{routeAlways},                       q{ImGuiInputFlags_RouteAlways}},                       q{1<<13}},
		
		{{q{routeOverFocused},                  q{ImGuiInputFlags_RouteOverFocused}},                  q{1<<14}},
		{{q{routeOverActive},                   q{ImGuiInputFlags_RouteOverActive}},                   q{1<<15}},
		{{q{routeUnlessBgFocused},              q{ImGuiInputFlags_RouteUnlessBgFocused}},              q{1<<16}},
		{{q{routeFromRootWindow},               q{ImGuiInputFlags_RouteFromRootWindow}},               q{1<<17}},
		
		{{q{tooltip},                           q{ImGuiInputFlags_Tooltip}},                           q{1<<18}},
		
		//private:
		{{q{repeatRateDefault},                 q{ImGuiInputFlags_RepeatRateDefault}},                 q{1<<1}},
		{{q{repeatRateNavMove},                 q{ImGuiInputFlags_RepeatRateNavMove}},                 q{1<<2}},
		{{q{repeatRateNavTweak},                q{ImGuiInputFlags_RepeatRateNavTweak}},                q{1<<3}},
		
		{{q{repeatUntilRelease},                q{ImGuiInputFlags_RepeatUntilRelease}},                q{1<<4}},
		{{q{repeatUntilKeyModsChange},          q{ImGuiInputFlags_RepeatUntilKeyModsChange}},          q{1<<5}},
		{{q{repeatUntilKeyModsChangeFromNone},  q{ImGuiInputFlags_RepeatUntilKeyModsChangeFromNone}},  q{1<<6}},
		{{q{repeatUntilOtherKeyPress},          q{ImGuiInputFlags_RepeatUntilOtherKeyPress}},          q{1<<7}},
		
		{{q{lockThisFrame},                     q{ImGuiInputFlags_LockThisFrame}},                     q{1<<20}},
		{{q{lockUntilRelease},                  q{ImGuiInputFlags_LockUntilRelease}},                  q{1<<21}},
		
		{{q{condHovered},                       q{ImGuiInputFlags_CondHovered}},                       q{1<<22}},
		{{q{condActive},                        q{ImGuiInputFlags_CondActive}},                        q{1<<23}},
		{{q{condDefault},                       q{ImGuiInputFlags_CondDefault_}},                      q{condHovered | condActive}},
		
		{{q{repeatRateMask},                    q{ImGuiInputFlags_RepeatRateMask_}},                   q{repeatRateDefault | repeatRateNavMove | repeatRateNavTweak}},
		{{q{repeatUntilMask},                   q{ImGuiInputFlags_RepeatUntilMask_}},                  q{repeatUntilRelease | repeatUntilKeyModsChange | repeatUntilKeyModsChangeFromNone | repeatUntilOtherKeyPress}},
		{{q{repeatMask},                        q{ImGuiInputFlags_RepeatMask_}},                       q{repeat | repeatRateMask | repeatUntilMask}},
		{{q{condMask},                          q{ImGuiInputFlags_CondMask_}},                         q{condHovered | condActive}},
		{{q{routeTypeMask},                     q{ImGuiInputFlags_RouteTypeMask_}},                    q{routeActive | routeFocused | routeGlobal | routeAlways}},
		{{q{routeOptionsMask},                  q{ImGuiInputFlags_RouteOptionsMask_}},                 q{routeOverFocused | routeOverActive | routeUnlessBgFocused | routeFromRootWindow}},
		{{q{supportedByIsKeyPressed},           q{ImGuiInputFlags_SupportedByIsKeyPressed}},           q{repeatMask}},
		{{q{supportedByIsMouseClicked},         q{ImGuiInputFlags_SupportedByIsMouseClicked}},         q{repeat}},
		{{q{supportedByShortcut},               q{ImGuiInputFlags_SupportedByShortcut}},               q{repeatMask | routeTypeMask | routeOptionsMask}},
		{{q{supportedBySetNextItemShortcut},    q{ImGuiInputFlags_SupportedBySetNextItemShortcut}},    q{repeatMask | routeTypeMask | routeOptionsMask | tooltip}},
		{{q{supportedBySetKeyOwner},            q{ImGuiInputFlags_SupportedBySetKeyOwner}},            q{lockThisFrame | lockUntilRelease}},
		{{q{supportedBySetItemKeyOwner},        q{ImGuiInputFlags_SupportedBySetItemKeyOwner}},        q{supportedBySetKeyOwner | condMask}},
	];
	return ret;
}()));
mixin(makeEnumBind(q{ImGuiNavInput}, members: (){
	EnumMember[] ret;
	version(ImGui_DisableObsoleteKeyIO){
	}else{{
		EnumMember[] add = [
			{{q{activate},     q{ImGuiNavInput_Activate}}},
			{{q{cancel},       q{ImGuiNavInput_Cancel}}},
			{{q{input},        q{ImGuiNavInput_Input}}},
			{{q{menu},         q{ImGuiNavInput_Menu}}},
			{{q{dpadLeft},     q{ImGuiNavInput_DpadLeft}}},
			{{q{dpadRight},    q{ImGuiNavInput_DpadRight}}},
			{{q{dpadUp},       q{ImGuiNavInput_DpadUp}}},
			{{q{dpadDown},     q{ImGuiNavInput_DpadDown}}},
			{{q{lStickLeft},   q{ImGuiNavInput_LStickLeft}}},
			{{q{lStickRight},  q{ImGuiNavInput_LStickRight}}},
			{{q{lStickUp},     q{ImGuiNavInput_LStickUp}}},
			{{q{lStickDown},   q{ImGuiNavInput_LStickDown}}},
			{{q{focusPrev},    q{ImGuiNavInput_FocusPrev}}},
			{{q{focusNext},    q{ImGuiNavInput_FocusNext}}},
			{{q{tweakSlow},    q{ImGuiNavInput_TweakSlow}}},
			{{q{tweakFast},    q{ImGuiNavInput_TweakFast}}},
			{{q{count},        q{ImGuiNavInput_COUNT}}},
		];
		ret ~= add;
	}}
	return ret;
}()));

alias ImGuiConfigFlags_ = int;
mixin(makeEnumBind(q{ImGuiConfigFlags}, q{ImGuiConfigFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                      q{ImGuiConfigFlags_None}},                  q{0}},
		{{q{navEnableKeyboard},         q{ImGuiConfigFlags_NavEnableKeyboard}},     q{1<<0}},
		{{q{navEnableGamepad},          q{ImGuiConfigFlags_NavEnableGamepad}},      q{1<<1}},
		{{q{noMouse},                   q{ImGuiConfigFlags_NoMouse}},               q{1<<4}},
		{{q{noMouseCursorChange},       q{ImGuiConfigFlags_NoMouseCursorChange}},   q{1<<5}},
		{{q{noKeyboard},                q{ImGuiConfigFlags_NoKeyboard}},            q{1<<6}},
		
		{{q{isSRGB},                    q{ImGuiConfigFlags_IsSRGB}},                q{1<<20}},
		{{q{isTouchScreen},             q{ImGuiConfigFlags_IsTouchScreen}},         q{1<<21}},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		EnumMember[] add = [
			{{q{navEnableSetMousePos},  q{ImGuiConfigFlags_NavEnableSetMousePos}},  q{1<<2}},
			{{q{navNoCaptureKeyboard},  q{ImGuiConfigFlags_NavNoCaptureKeyboard}},  q{1<<3}},
		];
		ret ~= add;
	}}
	return ret;
}()));

alias ImGuiBackendFlags_ = int;
mixin(makeEnumBind(q{ImGuiBackendFlags}, q{ImGuiBackendFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                  q{ImGuiBackendFlags_None}},                  q{0}},
		{{q{hasGamepad},            q{ImGuiBackendFlags_HasGamepad}},            q{1<<0}},
		{{q{hasMouseCursors},       q{ImGuiBackendFlags_HasMouseCursors}},       q{1<<1}},
		{{q{hasSetMousePos},        q{ImGuiBackendFlags_HasSetMousePos}},        q{1<<2}},
		{{q{rendererHasVtxOffset},  q{ImGuiBackendFlags_RendererHasVtxOffset}},  q{1<<3}},
	];
	return ret;
}()));

alias ImGuiCol_ = int;
mixin(makeEnumBind(q{ImGuiCol}, q{ImGuiCol_}, members: (){
	EnumMember[] ret = [
		{{q{text},                       q{ImGuiCol_Text}}},
		{{q{textDisabled},               q{ImGuiCol_TextDisabled}}},
		{{q{windowBg},                   q{ImGuiCol_WindowBg}}},
		{{q{childBg},                    q{ImGuiCol_ChildBg}}},
		{{q{popupBg},                    q{ImGuiCol_PopupBg}}},
		{{q{border},                     q{ImGuiCol_Border}}},
		{{q{borderShadow},               q{ImGuiCol_BorderShadow}}},
		{{q{frameBg},                    q{ImGuiCol_FrameBg}}},
		{{q{frameBgHovered},             q{ImGuiCol_FrameBgHovered}}},
		{{q{frameBgActive},              q{ImGuiCol_FrameBgActive}}},
		{{q{titleBg},                    q{ImGuiCol_TitleBg}}},
		{{q{titleBgActive},              q{ImGuiCol_TitleBgActive}}},
		{{q{titleBgCollapsed},           q{ImGuiCol_TitleBgCollapsed}}},
		{{q{menuBarBg},                  q{ImGuiCol_MenuBarBg}}},
		{{q{scrollbarBg},                q{ImGuiCol_ScrollbarBg}}},
		{{q{scrollbarGrab},              q{ImGuiCol_ScrollbarGrab}}},
		{{q{scrollbarGrabHovered},       q{ImGuiCol_ScrollbarGrabHovered}}},
		{{q{scrollbarGrabActive},        q{ImGuiCol_ScrollbarGrabActive}}},
		{{q{checkMark},                  q{ImGuiCol_CheckMark}}},
		{{q{sliderGrab},                 q{ImGuiCol_SliderGrab}}},
		{{q{sliderGrabActive},           q{ImGuiCol_SliderGrabActive}}},
		{{q{button},                     q{ImGuiCol_Button}}},
		{{q{buttonHovered},              q{ImGuiCol_ButtonHovered}}},
		{{q{buttonActive},               q{ImGuiCol_ButtonActive}}},
		{{q{header},                     q{ImGuiCol_Header}}},
		{{q{headerHovered},              q{ImGuiCol_HeaderHovered}}},
		{{q{headerActive},               q{ImGuiCol_HeaderActive}}},
		{{q{separator},                  q{ImGuiCol_Separator}}},
		{{q{separatorHovered},           q{ImGuiCol_SeparatorHovered}}},
		{{q{separatorActive},            q{ImGuiCol_SeparatorActive}}},
		{{q{resizeGrip},                 q{ImGuiCol_ResizeGrip}}},
		{{q{resizeGripHovered},          q{ImGuiCol_ResizeGripHovered}}},
		{{q{resizeGripActive},           q{ImGuiCol_ResizeGripActive}}},
		{{q{tabHovered},                 q{ImGuiCol_TabHovered}}},
		{{q{tab},                        q{ImGuiCol_Tab}}},
		{{q{tabSelected},                q{ImGuiCol_TabSelected}}},
		{{q{tabSelectedOverline},        q{ImGuiCol_TabSelectedOverline}}},
		{{q{tabDimmed},                  q{ImGuiCol_TabDimmed}}},
		{{q{tabDimmedSelected},          q{ImGuiCol_TabDimmedSelected}}},
		{{q{tabDimmedSelectedOverline},  q{ImGuiCol_TabDimmedSelectedOverline}}},
		{{q{plotLines},                  q{ImGuiCol_PlotLines}}},
		{{q{plotLinesHovered},           q{ImGuiCol_PlotLinesHovered}}},
		{{q{plotHistogram},              q{ImGuiCol_PlotHistogram}}},
		{{q{plotHistogramHovered},       q{ImGuiCol_PlotHistogramHovered}}},
		{{q{tableHeaderBg},              q{ImGuiCol_TableHeaderBg}}},
		{{q{tableBorderStrong},          q{ImGuiCol_TableBorderStrong}}},
		{{q{tableBorderLight},           q{ImGuiCol_TableBorderLight}}},
		{{q{tableRowBg},                 q{ImGuiCol_TableRowBg}}},
		{{q{tableRowBgAlt},              q{ImGuiCol_TableRowBgAlt}}},
		{{q{textLink},                   q{ImGuiCol_TextLink}}},
		{{q{textSelectedBg},             q{ImGuiCol_TextSelectedBg}}},
		{{q{dragDropTarget},             q{ImGuiCol_DragDropTarget}}},
		{{q{navCursor},                  q{ImGuiCol_NavCursor}}},
		{{q{navWindowingHighlight},      q{ImGuiCol_NavWindowingHighlight}}},
		{{q{navWindowingDimBg},          q{ImGuiCol_NavWindowingDimBg}}},
		{{q{modalWindowDimBg},           q{ImGuiCol_ModalWindowDimBg}}},
		{{q{count},                      q{ImGuiCol_COUNT}}},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		EnumMember[] add = [
			{{q{tabActive},              q{ImGuiCol_TabActive}},           q{tabSelected}},
			{{q{tabUnfocused},           q{ImGuiCol_TabUnfocused}},        q{tabDimmed}},
			{{q{tabUnfocusedActive},     q{ImGuiCol_TabUnfocusedActive}},  q{tabDimmedSelected}},
			{{q{navHighlight},           q{ImGuiCol_NavHighlight}},        q{navCursor}},
		];
		ret ~= add;
	}}
	return ret;
}()));

alias ImGuiStyleVar_ = int;
mixin(makeEnumBind(q{ImGuiStyleVar}, q{ImGuiStyleVar_}, members: (){
	EnumMember[] ret = [
		{{q{alpha},                        q{ImGuiStyleVar_Alpha}}},
		{{q{disabledAlpha},                q{ImGuiStyleVar_DisabledAlpha}}},
		{{q{windowPadding},                q{ImGuiStyleVar_WindowPadding}}},
		{{q{windowRounding},               q{ImGuiStyleVar_WindowRounding}}},
		{{q{windowBorderSize},             q{ImGuiStyleVar_WindowBorderSize}}},
		{{q{windowMinSize},                q{ImGuiStyleVar_WindowMinSize}}},
		{{q{windowTitleAlign},             q{ImGuiStyleVar_WindowTitleAlign}}},
		{{q{childRounding},                q{ImGuiStyleVar_ChildRounding}}},
		{{q{childBorderSize},              q{ImGuiStyleVar_ChildBorderSize}}},
		{{q{popupRounding},                q{ImGuiStyleVar_PopupRounding}}},
		{{q{popupBorderSize},              q{ImGuiStyleVar_PopupBorderSize}}},
		{{q{framePadding},                 q{ImGuiStyleVar_FramePadding}}},
		{{q{frameRounding},                q{ImGuiStyleVar_FrameRounding}}},
		{{q{frameBorderSize},              q{ImGuiStyleVar_FrameBorderSize}}},
		{{q{itemSpacing},                  q{ImGuiStyleVar_ItemSpacing}}},
		{{q{itemInnerSpacing},             q{ImGuiStyleVar_ItemInnerSpacing}}},
		{{q{indentSpacing},                q{ImGuiStyleVar_IndentSpacing}}},
		{{q{cellPadding},                  q{ImGuiStyleVar_CellPadding}}},
		{{q{scrollbarSize},                q{ImGuiStyleVar_ScrollbarSize}}},
		{{q{scrollbarRounding},            q{ImGuiStyleVar_ScrollbarRounding}}},
		{{q{grabMinSize},                  q{ImGuiStyleVar_GrabMinSize}}},
		{{q{grabRounding},                 q{ImGuiStyleVar_GrabRounding}}},
		{{q{tabRounding},                  q{ImGuiStyleVar_TabRounding}}},
		{{q{tabBorderSize},                q{ImGuiStyleVar_TabBorderSize}}},
		{{q{tabBarBorderSize},             q{ImGuiStyleVar_TabBarBorderSize}}},
		{{q{tabBarOverlineSize},           q{ImGuiStyleVar_TabBarOverlineSize}}},
		{{q{tableAngledHeadersAngle},      q{ImGuiStyleVar_TableAngledHeadersAngle}}},
		{{q{tableAngledHeadersTextAlign},  q{ImGuiStyleVar_TableAngledHeadersTextAlign}}},
		{{q{buttonTextAlign},              q{ImGuiStyleVar_ButtonTextAlign}}},
		{{q{selectableTextAlign},          q{ImGuiStyleVar_SelectableTextAlign}}},
		{{q{separatorTextBorderSize},      q{ImGuiStyleVar_SeparatorTextBorderSize}}},
		{{q{separatorTextAlign},           q{ImGuiStyleVar_SeparatorTextAlign}}},
		{{q{separatorTextPadding},         q{ImGuiStyleVar_SeparatorTextPadding}}},
		{{q{count},                        q{ImGuiStyleVar_COUNT}}},
	];
	return ret;
}()));

alias ImGuiButtonFlags_ = int;
mixin(makeEnumBind(q{ImGuiButtonFlags}, q{ImGuiButtonFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                           q{ImGuiButtonFlags_None}},                           q{0}},
		{{q{mouseButtonLeft},                q{ImGuiButtonFlags_MouseButtonLeft}},                q{1<<0}},
		{{q{mouseButtonRight},               q{ImGuiButtonFlags_MouseButtonRight}},               q{1<<1}},
		{{q{mouseButtonMiddle},              q{ImGuiButtonFlags_MouseButtonMiddle}},              q{1<<2}},
		{{q{mouseButtonMask},                q{ImGuiButtonFlags_MouseButtonMask_}},               q{mouseButtonLeft | mouseButtonRight | mouseButtonMiddle}},
		{{q{enableNav},                      q{ImGuiButtonFlags_EnableNav}},                      q{1<<3}},
		
		//private:
		{{q{pressedOnClick},                 q{ImGuiButtonFlags_PressedOnClick}},                 q{1<<4}},
		{{q{pressedOnClickRelease},          q{ImGuiButtonFlags_PressedOnClickRelease}},          q{1<<5}},
		{{q{pressedOnClickReleaseAnywhere},  q{ImGuiButtonFlags_PressedOnClickReleaseAnywhere}},  q{1<<6}},
		{{q{pressedOnRelease},               q{ImGuiButtonFlags_PressedOnRelease}},               q{1<<7}},
		{{q{pressedOnDoubleClick},           q{ImGuiButtonFlags_PressedOnDoubleClick}},           q{1<<8}},
		{{q{pressedOnDragDropHold},          q{ImGuiButtonFlags_PressedOnDragDropHold}},          q{1<<9}},
		
		{{q{flattenChildren},                q{ImGuiButtonFlags_FlattenChildren}},                q{1<<11}},
		{{q{allowOverlap},                   q{ImGuiButtonFlags_AllowOverlap}},                   q{1<<12}},
		
		{{q{alignTextBaseLine},              q{ImGuiButtonFlags_AlignTextBaseLine}},              q{1<<15}},
		{{q{noKeyModsAllowed},               q{ImGuiButtonFlags_NoKeyModsAllowed}},               q{1<<16}},
		{{q{noHoldingActiveID},              q{ImGuiButtonFlags_NoHoldingActiveId}},              q{1<<17}},
		{{q{noNavFocus},                     q{ImGuiButtonFlags_NoNavFocus}},                     q{1<<18}},
		{{q{noHoveredOnFocus},               q{ImGuiButtonFlags_NoHoveredOnFocus}},               q{1<<19}},
		{{q{noSetKeyOwner},                  q{ImGuiButtonFlags_NoSetKeyOwner}},                  q{1<<20}},
		{{q{noTestKeyOwner},                 q{ImGuiButtonFlags_NoTestKeyOwner}},                 q{1<<21}},
		{{q{pressedOnMask},                  q{ImGuiButtonFlags_PressedOnMask_}},                 q{pressedOnClick | pressedOnClickRelease | pressedOnClickReleaseAnywhere | pressedOnRelease | pressedOnDoubleClick | pressedOnDragDropHold}},
		{{q{pressedOnDefault},               q{ImGuiButtonFlags_PressedOnDefault_}},              q{pressedOnClickRelease}},
	];
	return ret;
}()));
alias ImGuiColourEditFlags_ = int;
mixin(makeEnumBind(q{ImGuiColorEditFlags}, q{ImGuiColourEditFlags_}, aliases: [q{ImGuiColourEditFlags}], members: (){
	EnumMember[] ret = [
		{{q{none},              q{ImGuiColourEditFlags_None}},              q{0}, aliases: [{c: q{ImGuiColorEditFlags_None}}]},
		{{q{noAlpha},           q{ImGuiColourEditFlags_NoAlpha}},           q{1<<1}, aliases: [{c: q{ImGuiColorEditFlags_NoAlpha}}]},
		{{q{noPicker},          q{ImGuiColourEditFlags_NoPicker}},          q{1<<2}, aliases: [{c: q{ImGuiColorEditFlags_NoPicker}}]},
		{{q{noOptions},         q{ImGuiColourEditFlags_NoOptions}},         q{1<<3}, aliases: [{c: q{ImGuiColorEditFlags_NoOptions}}]},
		{{q{noSmallPreview},    q{ImGuiColourEditFlags_NoSmallPreview}},    q{1<<4}, aliases: [{c: q{ImGuiColorEditFlags_NoSmallPreview}}]},
		{{q{noInputs},          q{ImGuiColourEditFlags_NoInputs}},          q{1<<5}, aliases: [{c: q{ImGuiColorEditFlags_NoInputs}}]},
		{{q{noTooltip},         q{ImGuiColourEditFlags_NoTooltip}},         q{1<<6}, aliases: [{c: q{ImGuiColorEditFlags_NoTooltip}}]},
		{{q{noLabel},           q{ImGuiColourEditFlags_NoLabel}},           q{1<<7}, aliases: [{c: q{ImGuiColorEditFlags_NoLabel}}]},
		{{q{noSidePreview},     q{ImGuiColourEditFlags_NoSidePreview}},     q{1<<8}, aliases: [{c: q{ImGuiColorEditFlags_NoSidePreview}}]},
		{{q{noDragDrop},        q{ImGuiColourEditFlags_NoDragDrop}},        q{1<<9}, aliases: [{c: q{ImGuiColorEditFlags_NoDragDrop}}]},
		{{q{noBorder},          q{ImGuiColourEditFlags_NoBorder}},          q{1<<10}, aliases: [{c: q{ImGuiColorEditFlags_NoBorder}}]},
		
		{{q{alphaBar},          q{ImGuiColourEditFlags_AlphaBar}},          q{1<<16}, aliases: [{c: q{ImGuiColorEditFlags_AlphaBar}}]},
		{{q{alphaPreview},      q{ImGuiColourEditFlags_AlphaPreview}},      q{1<<17}, aliases: [{c: q{ImGuiColorEditFlags_AlphaPreview}}]},
		{{q{alphaPreviewHalf},  q{ImGuiColourEditFlags_AlphaPreviewHalf}},  q{1<<18}, aliases: [{c: q{ImGuiColorEditFlags_AlphaPreviewHalf}}]},
		{{q{hdr},               q{ImGuiColourEditFlags_HDR}},               q{1<<19}, aliases: [{c: q{ImGuiColorEditFlags_HDR}}]},
		{{q{displayRGB},        q{ImGuiColourEditFlags_DisplayRGB}},        q{1<<20}, aliases: [{c: q{ImGuiColorEditFlags_DisplayRGB}}]},
		{{q{displayHSV},        q{ImGuiColourEditFlags_DisplayHSV}},        q{1<<21}, aliases: [{c: q{ImGuiColorEditFlags_DisplayHSV}}]},
		{{q{displayHex},        q{ImGuiColourEditFlags_DisplayHex}},        q{1<<22}, aliases: [{c: q{ImGuiColorEditFlags_DisplayHex}}]},
		{{q{uint8},             q{ImGuiColourEditFlags_Uint8}},             q{1<<23}, aliases: [{c: q{ImGuiColorEditFlags_Uint8}}]},
		{{q{float_},            q{ImGuiColourEditFlags_Float}},             q{1<<24}, aliases: [{c: q{ImGuiColorEditFlags_Float}}]},
		{{q{pickerHueBar},      q{ImGuiColourEditFlags_PickerHueBar}},      q{1<<25}, aliases: [{c: q{ImGuiColorEditFlags_PickerHueBar}}]},
		{{q{pickerHueWheel},    q{ImGuiColourEditFlags_PickerHueWheel}},    q{1<<26}, aliases: [{c: q{ImGuiColorEditFlags_PickerHueWheel}}]},
		{{q{inputRGB},          q{ImGuiColourEditFlags_InputRGB}},          q{1<<27}, aliases: [{c: q{ImGuiColorEditFlags_InputRGB}}]},
		{{q{inputHSV},          q{ImGuiColourEditFlags_InputHSV}},          q{1<<28}, aliases: [{c: q{ImGuiColorEditFlags_InputHSV}}]},
		
		{{q{defaultOptions},    q{ImGuiColourEditFlags_DefaultOptions_}},   q{uint8 | displayRGB | inputRGB | pickerHueBar}, aliases: [{c: q{ImGuiColorEditFlags_DefaultOptions_}}]},
		
		{{q{displayMask},       q{ImGuiColourEditFlags_DisplayMask_}},      q{displayRGB | displayHSV | displayHex}, aliases: [{c: q{ImGuiColorEditFlags_DisplayMask_}}]},
		{{q{dataTypeMask},      q{ImGuiColourEditFlags_DataTypeMask_}},     q{uint8 | float_}, aliases: [{c: q{ImGuiColorEditFlags_DataTypeMask_}}]},
		{{q{pickerMask},        q{ImGuiColourEditFlags_PickerMask_}},       q{pickerHueWheel | pickerHueBar}, aliases: [{c: q{ImGuiColorEditFlags_PickerMask_}}]},
		{{q{inputMask},         q{ImGuiColourEditFlags_InputMask_}},        q{inputRGB | inputHSV}, aliases: [{c: q{ImGuiColorEditFlags_InputMask_}}]},
	];
	return ret;
}()));

alias ImGuiSliderFlags_ = int;
mixin(makeEnumBind(q{ImGuiSliderFlags}, q{ImGuiSliderFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},             q{ImGuiSliderFlags_None}},             q{0}},
		{{q{logarithmic},      q{ImGuiSliderFlags_Logarithmic}},      q{1<<5}},
		{{q{noRoundToFormat},  q{ImGuiSliderFlags_NoRoundToFormat}},  q{1<<6}},
		{{q{noInput},          q{ImGuiSliderFlags_NoInput}},          q{1<<7}},
		{{q{wrapAround},       q{ImGuiSliderFlags_WrapAround}},       q{1<<8}},
		{{q{clampOnInput},     q{ImGuiSliderFlags_ClampOnInput}},     q{1<<9}},
		{{q{clampZeroRange},   q{ImGuiSliderFlags_ClampZeroRange}},   q{1<<10}},
		{{q{alwaysClamp},      q{ImGuiSliderFlags_AlwaysClamp}},      q{clampOnInput | clampZeroRange}},
		{{q{invalidMask},      q{ImGuiSliderFlags_InvalidMask_}},     q{0x7000000F}},
		
		//private:
		{{q{vertical},         q{ImGuiSliderFlags_Vertical}},         q{1<<20}},
		{{q{readOnly},         q{ImGuiSliderFlags_ReadOnly}},         q{1<<21}},
	];
	return ret;
}()));
alias ImGuiMouseButton_ = int;
mixin(makeEnumBind(q{ImGuiMouseButton}, q{ImGuiMouseButton_}, members: (){
	EnumMember[] ret = [
		{{q{left},    q{ImGuiMouseButton_Left}},    q{0}},
		{{q{right},   q{ImGuiMouseButton_Right}},   q{1}},
		{{q{middle},  q{ImGuiMouseButton_Middle}},  q{2}},
		{{q{count},   q{ImGuiMouseButton_COUNT}},   q{5}},
	];
	return ret;
}()));

alias ImGuiMouseCursor_ = int;
mixin(makeEnumBind(q{ImGuiMouseCursor}, q{ImGuiMouseCursor_}, members: (){
	EnumMember[] ret = [
		{{q{none},        q{ImGuiMouseCursor_None}},   q{-1}},
		{{q{arrow},       q{ImGuiMouseCursor_Arrow}},  q{0}},
		{{q{textInput},   q{ImGuiMouseCursor_TextInput}}},
		{{q{resizeAll},   q{ImGuiMouseCursor_ResizeAll}}},
		{{q{resizeNS},    q{ImGuiMouseCursor_ResizeNS}}},
		{{q{resizeEW},    q{ImGuiMouseCursor_ResizeEW}}},
		{{q{resizeNESW},  q{ImGuiMouseCursor_ResizeNESW}}},
		{{q{resizeNWSE},  q{ImGuiMouseCursor_ResizeNWSE}}},
		{{q{hand},        q{ImGuiMouseCursor_Hand}}},
		{{q{notAllowed},  q{ImGuiMouseCursor_NotAllowed}}},
		{{q{count},       q{ImGuiMouseCursor_COUNT}}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiMouseSource}, q{int}, members: (){
	EnumMember[] ret = [
		{{q{mouse},        q{ImGuiMouseSource_Mouse}},  q{0}},
		{{q{touchScreen},  q{ImGuiMouseSource_TouchScreen}}},
		{{q{pen},          q{ImGuiMouseSource_Pen}}},
		{{q{count},        q{ImGuiMouseSource_COUNT}}},
	];
	return ret;
}()));

alias ImGuiCond_ = int;
mixin(makeEnumBind(q{ImGuiCond}, q{ImGuiCond_}, members: (){
	EnumMember[] ret = [
		{{q{none},          q{ImGuiCond_None}},          q{0}},
		{{q{always},        q{ImGuiCond_Always}},        q{1<<0}},
		{{q{once},          q{ImGuiCond_Once}},          q{1<<1}},
		{{q{firstUseEver},  q{ImGuiCond_FirstUseEver}},  q{1<<2}},
		{{q{appearing},     q{ImGuiCond_Appearing}},     q{1<<3}},
	];
	return ret;
}()));

alias ImGuiTableFlags_ = int;
mixin(makeEnumBind(q{ImGuiTableFlags}, q{ImGuiTableFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                        q{ImGuiTableFlags_None}},                        q{0}},
		{{q{resizable},                   q{ImGuiTableFlags_Resizable}},                   q{1<<0}},
		{{q{reorderable},                 q{ImGuiTableFlags_Reorderable}},                 q{1<<1}},
		{{q{hideable},                    q{ImGuiTableFlags_Hideable}},                    q{1<<2}},
		{{q{sortable},                    q{ImGuiTableFlags_Sortable}},                    q{1<<3}},
		{{q{noSavedSettings},             q{ImGuiTableFlags_NoSavedSettings}},             q{1<<4}},
		{{q{contextMenuInBody},           q{ImGuiTableFlags_ContextMenuInBody}},           q{1<<5}},
		
		{{q{rowBg},                       q{ImGuiTableFlags_RowBg}},                       q{1<<6}},
		{{q{bordersInnerH},               q{ImGuiTableFlags_BordersInnerH}},               q{1<<7}},
		{{q{bordersOuterH},               q{ImGuiTableFlags_BordersOuterH}},               q{1<<8}},
		{{q{bordersInnerV},               q{ImGuiTableFlags_BordersInnerV}},               q{1<<9}},
		{{q{bordersOuterV},               q{ImGuiTableFlags_BordersOuterV}},               q{1<<10}},
		{{q{bordersH},                    q{ImGuiTableFlags_BordersH}},                    q{bordersInnerH | bordersOuterH}},
		{{q{bordersV},                    q{ImGuiTableFlags_BordersV}},                    q{bordersInnerV | bordersOuterV}},
		{{q{bordersInner},                q{ImGuiTableFlags_BordersInner}},                q{bordersInnerV | bordersInnerH}},
		{{q{bordersOuter},                q{ImGuiTableFlags_BordersOuter}},                q{bordersOuterV | bordersOuterH}},
		{{q{borders},                     q{ImGuiTableFlags_Borders}},                     q{bordersInner | bordersOuter}},
		{{q{noBordersInBody},             q{ImGuiTableFlags_NoBordersInBody}},             q{1<<11}},
		{{q{noBordersInBodyUntilResize},  q{ImGuiTableFlags_NoBordersInBodyUntilResize}},  q{1<<12}},
		
		{{q{sizingFixedFit},              q{ImGuiTableFlags_SizingFixedFit}},              q{1<<13}},
		{{q{sizingFixedSame},             q{ImGuiTableFlags_SizingFixedSame}},             q{2<<13}},
		{{q{sizingStretchProp},           q{ImGuiTableFlags_SizingStretchProp}},           q{3<<13}},
		{{q{sizingStretchSame},           q{ImGuiTableFlags_SizingStretchSame}},           q{4<<13}},
		
		{{q{noHostExtendX},               q{ImGuiTableFlags_NoHostExtendX}},               q{1<<16}},
		{{q{noHostExtendY},               q{ImGuiTableFlags_NoHostExtendY}},               q{1<<17}},
		{{q{noKeepColumnsVisible},        q{ImGuiTableFlags_NoKeepColumnsVisible}},        q{1<<18}},
		{{q{preciseWidths},               q{ImGuiTableFlags_PreciseWidths}},               q{1<<19}},
		
		{{q{noClip},                      q{ImGuiTableFlags_NoClip}},                      q{1<<20}},
		
		{{q{padOuterX},                   q{ImGuiTableFlags_PadOuterX}},                   q{1<<21}},
		{{q{noPadOuterX},                 q{ImGuiTableFlags_NoPadOuterX}},                 q{1<<22}},
		{{q{noPadInnerX},                 q{ImGuiTableFlags_NoPadInnerX}},                 q{1<<23}},
		
		{{q{scrollX},                     q{ImGuiTableFlags_ScrollX}},                     q{1<<24}},
		{{q{scrollY},                     q{ImGuiTableFlags_ScrollY}},                     q{1<<25}},
		
		{{q{sortMulti},                   q{ImGuiTableFlags_SortMulti}},                   q{1<<26}},
		{{q{sortTriState},                q{ImGuiTableFlags_SortTristate}},                q{1<<27}},
		
		{{q{highlightHoveredColumn},      q{ImGuiTableFlags_HighlightHoveredColumn}},      q{1<<28}},
		
		{{q{sizingMask},                  q{ImGuiTableFlags_SizingMask_}},                 q{sizingFixedFit | sizingFixedSame | sizingStretchProp | sizingStretchSame}},
	];
	return ret;
}()));

alias ImGuiTableColumnFlags_ = int;
mixin(makeEnumBind(q{ImGuiTableColumnFlags}, q{ImGuiTableColumnFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                  q{ImGuiTableColumnFlags_None}},                  q{0}},
		{{q{disabled},              q{ImGuiTableColumnFlags_Disabled}},              q{1<<0}},
		{{q{defaultHide},           q{ImGuiTableColumnFlags_DefaultHide}},           q{1<<1}},
		{{q{defaultSort},           q{ImGuiTableColumnFlags_DefaultSort}},           q{1<<2}},
		{{q{widthStretch},          q{ImGuiTableColumnFlags_WidthStretch}},          q{1<<3}},
		{{q{widthFixed},            q{ImGuiTableColumnFlags_WidthFixed}},            q{1<<4}},
		{{q{noResize},              q{ImGuiTableColumnFlags_NoResize}},              q{1<<5}},
		{{q{noReorder},             q{ImGuiTableColumnFlags_NoReorder}},             q{1<<6}},
		{{q{noHide},                q{ImGuiTableColumnFlags_NoHide}},                q{1<<7}},
		{{q{noClip},                q{ImGuiTableColumnFlags_NoClip}},                q{1<<8}},
		{{q{noSort},                q{ImGuiTableColumnFlags_NoSort}},                q{1<<9}},
		{{q{noSortAscending},       q{ImGuiTableColumnFlags_NoSortAscending}},       q{1<<10}},
		{{q{noSortDescending},      q{ImGuiTableColumnFlags_NoSortDescending}},      q{1<<11}},
		{{q{noHeaderLabel},         q{ImGuiTableColumnFlags_NoHeaderLabel}},         q{1<<12}},
		{{q{noHeaderWidth},         q{ImGuiTableColumnFlags_NoHeaderWidth}},         q{1<<13}},
		{{q{preferSortAscending},   q{ImGuiTableColumnFlags_PreferSortAscending}},   q{1<<14}},
		{{q{preferSortDescending},  q{ImGuiTableColumnFlags_PreferSortDescending}},  q{1<<15}},
		{{q{indentEnable},          q{ImGuiTableColumnFlags_IndentEnable}},          q{1<<16}},
		{{q{indentDisable},         q{ImGuiTableColumnFlags_IndentDisable}},         q{1<<17}},
		{{q{angledHeader},          q{ImGuiTableColumnFlags_AngledHeader}},          q{1<<18}},
		
		{{q{isEnabled},             q{ImGuiTableColumnFlags_IsEnabled}},             q{1<<24}},
		{{q{isVisible},             q{ImGuiTableColumnFlags_IsVisible}},             q{1<<25}},
		{{q{isSorted},              q{ImGuiTableColumnFlags_IsSorted}},              q{1<<26}},
		{{q{isHovered},             q{ImGuiTableColumnFlags_IsHovered}},             q{1<<27}},
		
		{{q{widthMask},             q{ImGuiTableColumnFlags_WidthMask_}},            q{widthStretch | widthFixed}},
		{{q{indentMask},            q{ImGuiTableColumnFlags_IndentMask_}},           q{indentEnable | indentDisable}},
		{{q{statusMask},            q{ImGuiTableColumnFlags_StatusMask_}},           q{isEnabled | isVisible | isSorted | isHovered}},
		{{q{noDirectResize},        q{ImGuiTableColumnFlags_NoDirectResize_}},       q{1<<30}},
	];
	return ret;
}()));

alias ImGuiTableRowFlags_ = int;
mixin(makeEnumBind(q{ImGuiTableRowFlags}, q{ImGuiTableRowFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},     q{ImGuiTableRowFlags_None}},     q{0}},
		{{q{headers},  q{ImGuiTableRowFlags_Headers}},  q{1<<0}},
	];
	return ret;
}()));

alias ImGuiTableBgTarget_ = int;
mixin(makeEnumBind(q{ImGuiTableBgTarget}, q{ImGuiTableBgTarget_}, members: (){
	EnumMember[] ret = [
		{{q{none},    q{ImGuiTableBgTarget_None}},    q{0}},
		{{q{rowBg0},  q{ImGuiTableBgTarget_RowBg0}},  q{1}},
		{{q{rowBg1},  q{ImGuiTableBgTarget_RowBg1}},  q{2}},
		{{q{cellBg},  q{ImGuiTableBgTarget_CellBg}},  q{3}},
	];
	return ret;
}()));

enum IM_UNICODE_CODEPOINT_INVALID = 0xFFFD;
version(ImGui_WChar32){
	enum IM_UNICODE_CODEPOINT_MAX = 0x10FFFF;
}
version(ImGui_WChar32){
}else{
	enum IM_UNICODE_CODEPOINT_MAX = 0xFFFF;
}

version(ImGui_BGRAPackedCol){
	enum IM_COL32_R_SHIFT = 16;
}
version(ImGui_BGRAPackedCol){
	enum IM_COL32_G_SHIFT = 8;
}
version(ImGui_BGRAPackedCol){
	enum IM_COL32_B_SHIFT = 0;
}
version(ImGui_BGRAPackedCol){
	enum IM_COL32_A_SHIFT = 24;
}
version(ImGui_BGRAPackedCol){
	enum IM_COL32_A_MASK = 0xFF000000;
}
version(ImGui_BGRAPackedCol){
}else{
	enum IM_COL32_R_SHIFT = 0;
}
version(ImGui_BGRAPackedCol){
}else{
	enum IM_COL32_G_SHIFT = 8;
}
version(ImGui_BGRAPackedCol){
}else{
	enum IM_COL32_B_SHIFT = 16;
}
version(ImGui_BGRAPackedCol){
}else{
	enum IM_COL32_A_SHIFT = 24;
}
version(ImGui_BGRAPackedCol){
}else{
	enum IM_COL32_A_MASK = 0xFF000000;
}
pragma(inline,true) extern(C) uint IM_COL32(uint r, uint g, uint b, uint a) =>
	(a << IM_COL32_A_SHIFT) | (b << IM_COL32_B_SHIFT) | (g << IM_COL32_G_SHIFT) | (r << IM_COL32_R_SHIFT);
enum IM_COL32_WHITE       = IM_COL32(0xFF,0xFF,0xFF,0xFF);
enum IM_COL32_BLACK       = IM_COL32(0x00,0x00,0x00,0xFF);
enum IM_COL32_BLACK_TRANS = IM_COL32(0x00,0x00,0x00,0x00);

alias ImGuiMultiSelectFlags_ = int;
mixin(makeEnumBind(q{ImGuiMultiSelectFlags}, q{ImGuiMultiSelectFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                   q{ImGuiMultiSelectFlags_None}},                   q{0}},
		{{q{singleSelect},           q{ImGuiMultiSelectFlags_SingleSelect}},           q{1<<0}},
		{{q{noSelectAll},            q{ImGuiMultiSelectFlags_NoSelectAll}},            q{1<<1}},
		{{q{noRangeSelect},          q{ImGuiMultiSelectFlags_NoRangeSelect}},          q{1<<2}},
		{{q{noAutoSelect},           q{ImGuiMultiSelectFlags_NoAutoSelect}},           q{1<<3}},
		{{q{noAutoClear},            q{ImGuiMultiSelectFlags_NoAutoClear}},            q{1<<4}},
		{{q{noAutoClearOnReselect},  q{ImGuiMultiSelectFlags_NoAutoClearOnReselect}},  q{1<<5}},
		{{q{boxSelect1D},            q{ImGuiMultiSelectFlags_BoxSelect1d}},            q{1<<6}},
		{{q{boxSelect2D},            q{ImGuiMultiSelectFlags_BoxSelect2d}},            q{1<<7}},
		{{q{boxSelectNoScroll},      q{ImGuiMultiSelectFlags_BoxSelectNoScroll}},      q{1<<8}},
		{{q{clearOnEscape},          q{ImGuiMultiSelectFlags_ClearOnEscape}},          q{1<<9}},
		{{q{clearOnClickVoid},       q{ImGuiMultiSelectFlags_ClearOnClickVoid}},       q{1<<10}},
		{{q{scopeWindow},            q{ImGuiMultiSelectFlags_ScopeWindow}},            q{1<<11}},
		{{q{scopeRect},              q{ImGuiMultiSelectFlags_ScopeRect}},              q{1<<12}},
		{{q{selectOnClick},          q{ImGuiMultiSelectFlags_SelectOnClick}},          q{1<<13}},
		{{q{selectOnClickRelease},   q{ImGuiMultiSelectFlags_SelectOnClickRelease}},   q{1<<14}},
		
		{{q{navWrapX},               q{ImGuiMultiSelectFlags_NavWrapX}},               q{1<<16}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiSelectionRequestType}, members: (){
	EnumMember[] ret = [
		{{q{none},      q{ImGuiSelectionRequestType_None}},  q{0}},
		{{q{setAll},    q{ImGuiSelectionRequestType_SetAll}}},
		{{q{setRange},  q{ImGuiSelectionRequestType_SetRange}}},
	];
	return ret;
}()));

enum IM_DRAWLIST_TEX_LINES_WIDTH_MAX = 63;

alias ImDrawFlags_ = int;
mixin(makeEnumBind(q{ImDrawFlags}, q{ImDrawFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                     q{ImDrawFlags_None}},                     q{0}},
		{{q{closed},                   q{ImDrawFlags_Closed}},                   q{1<<0}},
		{{q{roundCornersTopLeft},      q{ImDrawFlags_RoundCornersTopLeft}},      q{1<<4}},
		{{q{roundCornersTopRight},     q{ImDrawFlags_RoundCornersTopRight}},     q{1<<5}},
		{{q{roundCornersBottomLeft},   q{ImDrawFlags_RoundCornersBottomLeft}},   q{1<<6}},
		{{q{roundCornersBottomRight},  q{ImDrawFlags_RoundCornersBottomRight}},  q{1<<7}},
		{{q{roundCornersNone},         q{ImDrawFlags_RoundCornersNone}},         q{1<<8}},
		{{q{roundCornersTop},          q{ImDrawFlags_RoundCornersTop}},          q{roundCornersTopLeft | roundCornersTopRight}},
		{{q{roundCornersBottom},       q{ImDrawFlags_RoundCornersBottom}},       q{roundCornersBottomLeft | roundCornersBottomRight}},
		{{q{roundCornersLeft},         q{ImDrawFlags_RoundCornersLeft}},         q{roundCornersBottomLeft | roundCornersTopLeft}},
		{{q{roundCornersRight},        q{ImDrawFlags_RoundCornersRight}},        q{roundCornersBottomRight | roundCornersTopRight}},
		{{q{roundCornersAll},          q{ImDrawFlags_RoundCornersAll}},          q{roundCornersTopLeft | roundCornersTopRight | roundCornersBottomLeft | roundCornersBottomRight}},
		{{q{roundCornersDefault},      q{ImDrawFlags_RoundCornersDefault_}},     q{roundCornersAll}},
		{{q{roundCornersMask},         q{ImDrawFlags_RoundCornersMask_}},        q{roundCornersAll | roundCornersNone}},
	];
	return ret;
}()));

alias ImDrawListFlags_ = int;
mixin(makeEnumBind(q{ImDrawListFlags}, q{ImDrawListFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                    q{ImDrawListFlags_None}},                    q{0}},
		{{q{antiAliasedLines},        q{ImDrawListFlags_AntiAliasedLines}},        q{1<<0}},
		{{q{antiAliasedLinesUseTex},  q{ImDrawListFlags_AntiAliasedLinesUseTex}},  q{1<<1}},
		{{q{antiAliasedFill},         q{ImDrawListFlags_AntiAliasedFill}},         q{1<<2}},
		{{q{allowVtxOffset},          q{ImDrawListFlags_AllowVtxOffset}},          q{1<<3}},
	];
	return ret;
}()));

alias ImFontAtlasFlags_ = int;
mixin(makeEnumBind(q{ImFontAtlasFlags}, q{ImFontAtlasFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                q{ImFontAtlasFlags_None}},                q{0}},
		{{q{noPowerOfTwoHeight},  q{ImFontAtlasFlags_NoPowerOfTwoHeight}},  q{1<<0}},
		{{q{noMouseCursors},      q{ImFontAtlasFlags_NoMouseCursors}},      q{1<<1}},
		{{q{noBakedLines},        q{ImFontAtlasFlags_NoBakedLines}},        q{1<<2}},
	];
	return ret;
}()));

alias ImGuiViewportFlags_ = int;
mixin(makeEnumBind(q{ImGuiViewportFlags}, q{ImGuiViewportFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},               q{ImGuiViewportFlags_None}},               q{0}},
		{{q{isPlatformWindow},   q{ImGuiViewportFlags_IsPlatformWindow}},   q{1<<0}},
		{{q{isPlatformMonitor},  q{ImGuiViewportFlags_IsPlatformMonitor}},  q{1<<1}},
		{{q{ownedByApp},         q{ImGuiViewportFlags_OwnedByApp}},         q{1<<2}},
	];
	return ret;
}()));

alias ImGuiTableColumnIdx = short;
version(ImGui_DisableFileFunctions){
	alias ImFileHandle = void*;
}
version(ImGui_DisableFileFunctions){
}else{
	alias ImFileHandle = FILE*;
}
alias ImBitArrayPtr = uint*;
alias ImPoolIdx = int;
alias ImGuiKeyRoutingIndex = short;
alias ImGuiErrorCallback = extern(C++) void function(ImGuiContext* ctx, void* userData, const(char)* msg) nothrow @nogc;
alias ImGuiContextHookCallback = extern(C++) void function(ImGuiContext* ctx, ImGuiContextHook* hook) nothrow @nogc;
alias ImGuiTableDrawChannelIdx = ushort;

enum IM_PI = 3.14159265358979323846f;
version(Windows){
	enum IM_NEWLINE = "\r\n";
}
version(Windows){
}else{
	enum IM_NEWLINE = "\n";
}

enum IM_TABSIZE = 4;

enum IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MIN = 4;
enum IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MAX = 512;

enum IM_DRAWLIST_ARCFAST_TABLE_SIZE = 48;
alias IM_DRAWLIST_ARCFAST_SAMPLE_MAX = IM_DRAWLIST_ARCFAST_TABLE_SIZE;

alias ImGuiItemStatusFlags_ = int;
mixin(makeEnumBind(q{ImGuiItemStatusFlags}, q{ImGuiItemStatusFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},              q{ImGuiItemStatusFlags_None}},              q{0}},
		{{q{hoveredRect},       q{ImGuiItemStatusFlags_HoveredRect}},       q{1<<0}},
		{{q{hasDisplayRect},    q{ImGuiItemStatusFlags_HasDisplayRect}},    q{1<<1}},
		{{q{edited},            q{ImGuiItemStatusFlags_Edited}},            q{1<<2}},
		{{q{toggledSelection},  q{ImGuiItemStatusFlags_ToggledSelection}},  q{1<<3}},
		{{q{toggledOpen},       q{ImGuiItemStatusFlags_ToggledOpen}},       q{1<<4}},
		{{q{hasDeactivated},    q{ImGuiItemStatusFlags_HasDeactivated}},    q{1<<5}},
		{{q{deactivated},       q{ImGuiItemStatusFlags_Deactivated}},       q{1<<6}},
		{{q{hoveredWindow},     q{ImGuiItemStatusFlags_HoveredWindow}},     q{1<<7}},
		{{q{visible},           q{ImGuiItemStatusFlags_Visible}},           q{1<<8}},
		{{q{hasClipRect},       q{ImGuiItemStatusFlags_HasClipRect}},       q{1<<9}},
		{{q{hasShortcut},       q{ImGuiItemStatusFlags_HasShortcut}},       q{1<<10}},
	];
	version(ImGui_TestEngine){{
		EnumMember[] add = [
			{{q{openable},      q{ImGuiItemStatusFlags_Openable}},          q{1<<20}},
			{{q{opened},        q{ImGuiItemStatusFlags_Opened}},            q{1<<21}},
			{{q{checkable},     q{ImGuiItemStatusFlags_Checkable}},         q{1<<22}},
			{{q{checked},       q{ImGuiItemStatusFlags_Checked}},           q{1<<23}},
			{{q{inputable},     q{ImGuiItemStatusFlags_Inputable}},         q{1<<24}},
		];
		ret ~= add;
	}}
	return ret;
}()));

alias ImGuiSeparatorFlags_ = int;
mixin(makeEnumBind(q{ImGuiSeparatorFlags}, q{ImGuiSeparatorFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},            q{ImGuiSeparatorFlags_None}},            q{0}},
		{{q{horizontal},      q{ImGuiSeparatorFlags_Horizontal}},      q{1<<0}},
		{{q{vertical},        q{ImGuiSeparatorFlags_Vertical}},        q{1<<1}},
		{{q{spanAllColumns},  q{ImGuiSeparatorFlags_SpanAllColumns}},  q{1<<2}},
	];
	return ret;
}()));

alias ImGuiFocusRequestFlags_ = int;
mixin(makeEnumBind(q{ImGuiFocusRequestFlags}, q{ImGuiFocusRequestFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                 q{ImGuiFocusRequestFlags_None}},                 q{0}},
		{{q{restoreFocusedChild},  q{ImGuiFocusRequestFlags_RestoreFocusedChild}},  q{1<<0}},
		{{q{unlessBelowModal},     q{ImGuiFocusRequestFlags_UnlessBelowModal}},     q{1<<1}},
	];
	return ret;
}()));

alias ImGuiTextFlags_ = int;
mixin(makeEnumBind(q{ImGuiTextFlags}, q{ImGuiTextFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                        q{ImGuiTextFlags_None}},                        q{0}},
		{{q{noWidthForLargeClippedText},  q{ImGuiTextFlags_NoWidthForLargeClippedText}},  q{1<<0}},
	];
	return ret;
}()));

alias ImGuiTooltipFlags_ = int;
mixin(makeEnumBind(q{ImGuiTooltipFlags}, q{ImGuiTooltipFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},              q{ImGuiTooltipFlags_None}},              q{0}},
		{{q{overridePrevious},  q{ImGuiTooltipFlags_OverridePrevious}},  q{1<<1}},
	];
	return ret;
}()));

alias ImGuiLayoutType_ = int;
mixin(makeEnumBind(q{ImGuiLayoutType}, q{ImGuiLayoutType_}, members: (){
	EnumMember[] ret = [
		{{q{horizontal},  q{ImGuiLayoutType_Horizontal}},  q{0}},
		{{q{vertical},    q{ImGuiLayoutType_Vertical}},    q{1}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiLogType}, members: (){
	EnumMember[] ret = [
		{{q{none},       q{ImGuiLogType_None}},  q{0}},
		{{q{tty},        q{ImGuiLogType_TTY}}},
		{{q{file},       q{ImGuiLogType_File}}},
		{{q{buffer},     q{ImGuiLogType_Buffer}}},
		{{q{clipboard},  q{ImGuiLogType_Clipboard}}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiAxis}, members: (){
	EnumMember[] ret = [
		{{q{none},  q{ImGuiAxis_None}},  q{-1}},
		{{q{x},     q{ImGuiAxis_X}},     q{0}},
		{{q{y},     q{ImGuiAxis_Y}},     q{1}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiPlotType}, members: (){
	EnumMember[] ret = [
		{{q{lines},      q{ImGuiPlotType_Lines}}},
		{{q{histogram},  q{ImGuiPlotType_Histogram}}},
	];
	return ret;
}()));

alias IMSTB_TEXTEDIT_STRING = ImGuiInputTextState;
alias IMSTB_TEXTEDIT_CHARTYPE = char;
enum IMSTB_TEXTEDIT_GETWIDTH_NEWLINE = -1.0f;
enum IMSTB_TEXTEDIT_UNDOSTATECOUNT = 99;
enum IMSTB_TEXTEDIT_UNDOCHARCOUNT = 999;

alias ImGuiWindowRefreshFlags_ = int;
mixin(makeEnumBind(q{ImGuiWindowRefreshFlags}, q{ImGuiWindowRefreshFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},               q{ImGuiWindowRefreshFlags_None}},               q{0}},
		{{q{tryToAvoidRefresh},  q{ImGuiWindowRefreshFlags_TryToAvoidRefresh}},  q{1<<0}},
		{{q{refreshOnHover},     q{ImGuiWindowRefreshFlags_RefreshOnHover}},     q{1<<1}},
		{{q{refreshOnFocus},     q{ImGuiWindowRefreshFlags_RefreshOnFocus}},     q{1<<2}},
	];
	return ret;
}()));

alias ImGuiNextWindowDataFlags_ = int;
mixin(makeEnumBind(q{ImGuiNextWindowDataFlags}, q{ImGuiNextWindowDataFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},               q{ImGuiNextWindowDataFlags_None}},               q{0}},
		{{q{hasPos},             q{ImGuiNextWindowDataFlags_HasPos}},             q{1<<0}},
		{{q{hasSize},            q{ImGuiNextWindowDataFlags_HasSize}},            q{1<<1}},
		{{q{hasContentSize},     q{ImGuiNextWindowDataFlags_HasContentSize}},     q{1<<2}},
		{{q{hasCollapsed},       q{ImGuiNextWindowDataFlags_HasCollapsed}},       q{1<<3}},
		{{q{hasSizeConstraint},  q{ImGuiNextWindowDataFlags_HasSizeConstraint}},  q{1<<4}},
		{{q{hasFocus},           q{ImGuiNextWindowDataFlags_HasFocus}},           q{1<<5}},
		{{q{hasBgAlpha},         q{ImGuiNextWindowDataFlags_HasBgAlpha}},         q{1<<6}},
		{{q{hasScroll},          q{ImGuiNextWindowDataFlags_HasScroll}},          q{1<<7}},
		{{q{hasChildFlags},      q{ImGuiNextWindowDataFlags_HasChildFlags}},      q{1<<8}},
		{{q{hasRefreshPolicy},   q{ImGuiNextWindowDataFlags_HasRefreshPolicy}},   q{1<<9}},
	];
	return ret;
}()));

alias ImGuiNextItemDataFlags_ = int;
mixin(makeEnumBind(q{ImGuiNextItemDataFlags}, q{ImGuiNextItemDataFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},          q{ImGuiNextItemDataFlags_None}},          q{0}},
		{{q{hasWidth},      q{ImGuiNextItemDataFlags_HasWidth}},      q{1<<0}},
		{{q{hasOpen},       q{ImGuiNextItemDataFlags_HasOpen}},       q{1<<1}},
		{{q{hasShortcut},   q{ImGuiNextItemDataFlags_HasShortcut}},   q{1<<2}},
		{{q{hasRefVal},     q{ImGuiNextItemDataFlags_HasRefVal}},     q{1<<3}},
		{{q{hasStorageID},  q{ImGuiNextItemDataFlags_HasStorageID}},  q{1<<4}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiPopupPositionPolicy}, members: (){
	EnumMember[] ret = [
		{{q{default_},  q{ImGuiPopupPositionPolicy_Default}}},
		{{q{comboBox},  q{ImGuiPopupPositionPolicy_ComboBox}}},
		{{q{tooltip},   q{ImGuiPopupPositionPolicy_Tooltip}}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiInputEventType}, members: (){
	EnumMember[] ret = [
		{{q{none},         q{ImGuiInputEventType_None}},  q{0}},
		{{q{mousePos},     q{ImGuiInputEventType_MousePos}}},
		{{q{mouseWheel},   q{ImGuiInputEventType_MouseWheel}}},
		{{q{mouseButton},  q{ImGuiInputEventType_MouseButton}}},
		{{q{key},          q{ImGuiInputEventType_Key}}},
		{{q{text},         q{ImGuiInputEventType_Text}}},
		{{q{focus},        q{ImGuiInputEventType_Focus}}},
		{{q{count},        q{ImGuiInputEventType_COUNT}}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiInputSource}, members: (){
	EnumMember[] ret = [
		{{q{none},      q{ImGuiInputSource_None}},  q{0}},
		{{q{mouse},     q{ImGuiInputSource_Mouse}}},
		{{q{keyboard},  q{ImGuiInputSource_Keyboard}}},
		{{q{gamepad},   q{ImGuiInputSource_Gamepad}}},
		{{q{count},     q{ImGuiInputSource_COUNT}}},
	];
	return ret;
}()));

enum ImGuiKeyOwner_Any = cast(ImGuiID)0;
enum ImGuiKeyOwner_NoOwner = cast(ImGuiID)-1;

alias ImGuiActivateFlags_ = int;
mixin(makeEnumBind(q{ImGuiActivateFlags}, q{ImGuiActivateFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                q{ImGuiActivateFlags_None}},                q{0}},
		{{q{preferInput},         q{ImGuiActivateFlags_PreferInput}},         q{1<<0}},
		{{q{preferTweak},         q{ImGuiActivateFlags_PreferTweak}},         q{1<<1}},
		{{q{tryToPreserveState},  q{ImGuiActivateFlags_TryToPreserveState}},  q{1<<2}},
		{{q{fromTabbing},         q{ImGuiActivateFlags_FromTabbing}},         q{1<<3}},
		{{q{fromShortcut},        q{ImGuiActivateFlags_FromShortcut}},        q{1<<4}},
	];
	return ret;
}()));

alias ImGuiScrollFlags_ = int;
mixin(makeEnumBind(q{ImGuiScrollFlags}, q{ImGuiScrollFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                q{ImGuiScrollFlags_None}},                q{0}},
		{{q{keepVisibleEdgeX},    q{ImGuiScrollFlags_KeepVisibleEdgeX}},    q{1<<0}},
		{{q{keepVisibleEdgeY},    q{ImGuiScrollFlags_KeepVisibleEdgeY}},    q{1<<1}},
		{{q{keepVisibleCentreX},  q{ImGuiScrollFlags_KeepVisibleCentreX}},  q{1<<2}, aliases: [{q{keepVisibleCenterX}, q{ImGuiScrollFlags_KeepVisibleCenterX}}]},
		{{q{keepVisibleCentreY},  q{ImGuiScrollFlags_KeepVisibleCentreY}},  q{1<<3}, aliases: [{q{keepVisibleCenterY}, q{ImGuiScrollFlags_KeepVisibleCenterY}}]},
		{{q{alwaysCentreX},       q{ImGuiScrollFlags_AlwaysCentreX}},       q{1<<4}, aliases: [{q{alwaysCenterX}, q{ImGuiScrollFlags_AlwaysCenterX}}]},
		{{q{alwaysCentreY},       q{ImGuiScrollFlags_AlwaysCentreY}},       q{1<<5}, aliases: [{q{alwaysCenterY}, q{ImGuiScrollFlags_AlwaysCenterY}}]},
		{{q{noScrollParent},      q{ImGuiScrollFlags_NoScrollParent}},      q{1<<6}},
		{{q{maskX},               q{ImGuiScrollFlags_MaskX_}},              q{keepVisibleEdgeX | keepVisibleCentreX | alwaysCentreX}},
		{{q{maskY},               q{ImGuiScrollFlags_MaskY_}},              q{keepVisibleEdgeY | keepVisibleCentreY | alwaysCentreY}},
	];
	return ret;
}()));

alias ImGuiNavRenderCursorFlags_ = int;
mixin(makeEnumBind(q{ImGuiNavRenderCursorFlags}, q{ImGuiNavRenderCursorFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},        q{ImGuiNavRenderCursorFlags_None}},        q{0}},
		{{q{compact},     q{ImGuiNavRenderCursorFlags_Compact}},     q{1<<1}},
		{{q{alwaysDraw},  q{ImGuiNavRenderCursorFlags_AlwaysDraw}},  q{1<<2}},
		{{q{noRounding},  q{ImGuiNavRenderCursorFlags_NoRounding}},  q{1<<3}},
	];
	return ret;
}()));

alias ImGuiNavMoveFlags_ = int;
mixin(makeEnumBind(q{ImGuiNavMoveFlags}, q{ImGuiNavMoveFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                   q{ImGuiNavMoveFlags_None}},                   q{0}},
		{{q{loopX},                  q{ImGuiNavMoveFlags_LoopX}},                  q{1<<0}},
		{{q{loopY},                  q{ImGuiNavMoveFlags_LoopY}},                  q{1<<1}},
		{{q{wrapX},                  q{ImGuiNavMoveFlags_WrapX}},                  q{1<<2}},
		{{q{wrapY},                  q{ImGuiNavMoveFlags_WrapY}},                  q{1<<3}},
		{{q{wrapMask},               q{ImGuiNavMoveFlags_WrapMask_}},              q{loopX | loopY | wrapX | wrapY}},
		{{q{allowCurrentNavID},      q{ImGuiNavMoveFlags_AllowCurrentNavId}},      q{1<<4}},
		{{q{alsoScoreVisibleSet},    q{ImGuiNavMoveFlags_AlsoScoreVisibleSet}},    q{1<<5}},
		{{q{scrollToEdgeY},          q{ImGuiNavMoveFlags_ScrollToEdgeY}},          q{1<<6}},
		{{q{forwarded},              q{ImGuiNavMoveFlags_Forwarded}},              q{1<<7}},
		{{q{debugNoResult},          q{ImGuiNavMoveFlags_DebugNoResult}},          q{1<<8}},
		{{q{focusApi},               q{ImGuiNavMoveFlags_FocusApi}},               q{1<<9}},
		{{q{isTabbing},              q{ImGuiNavMoveFlags_IsTabbing}},              q{1<<10}},
		{{q{isPageMove},             q{ImGuiNavMoveFlags_IsPageMove}},             q{1<<11}},
		{{q{activate},               q{ImGuiNavMoveFlags_Activate}},               q{1<<12}},
		{{q{noSelect},               q{ImGuiNavMoveFlags_NoSelect}},               q{1<<13}},
		{{q{noSetNavCursorVisible},  q{ImGuiNavMoveFlags_NoSetNavCursorVisible}},  q{1<<14}},
		{{q{noClearActiveID},        q{ImGuiNavMoveFlags_NoClearActiveId}},        q{1<<15}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiNavLayer}, members: (){
	EnumMember[] ret = [
		{{q{main},   q{ImGuiNavLayer_Main}},  q{0}},
		{{q{menu},   q{ImGuiNavLayer_Menu}},  q{1}},
		{{q{count},  q{ImGuiNavLayer_COUNT}}},
	];
	return ret;
}()));

alias ImGuiTypingSelectFlags_ = int;
mixin(makeEnumBind(q{ImGuiTypingSelectFlags}, q{ImGuiTypingSelectFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                 q{ImGuiTypingSelectFlags_None}},                 q{0}},
		{{q{allowBackspace},       q{ImGuiTypingSelectFlags_AllowBackspace}},       q{1<<0}},
		{{q{allowSingleCharMode},  q{ImGuiTypingSelectFlags_AllowSingleCharMode}},  q{1<<1}},
	];
	return ret;
}()));

alias ImGuiOldColumnFlags_ = int;
mixin(makeEnumBind(q{ImGuiOldColumnFlags}, q{ImGuiOldColumnFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                    q{ImGuiOldColumnFlags_None}},                    q{0}},
		{{q{noBorder},                q{ImGuiOldColumnFlags_NoBorder}},                q{1<<0}},
		{{q{noResize},                q{ImGuiOldColumnFlags_NoResize}},                q{1<<1}},
		{{q{noPreserveWidths},        q{ImGuiOldColumnFlags_NoPreserveWidths}},        q{1<<2}},
		{{q{noForceWithinWindow},     q{ImGuiOldColumnFlags_NoForceWithinWindow}},     q{1<<3}},
		{{q{growParentContentsSize},  q{ImGuiOldColumnFlags_GrowParentContentsSize}},  q{1<<4}},
	];
	return ret;
}()));

enum ImGuiSelectionUserData_Invalid = cast(ImGuiSelectionUserData)-1;

alias ImGuiLocKey_ = int;
mixin(makeEnumBind(q{ImGuiLocKey}, q{ImGuiLocKey_}, members: (){
	EnumMember[] ret = [
		{{q{versionStr},            q{ImGuiLocKey_VersionStr}}},
		{{q{tableSizeOne},          q{ImGuiLocKey_TableSizeOne}}},
		{{q{tableSizeAllFit},       q{ImGuiLocKey_TableSizeAllFit}}},
		{{q{tableSizeAllDefault},   q{ImGuiLocKey_TableSizeAllDefault}}},
		{{q{tableResetOrder},       q{ImGuiLocKey_TableResetOrder}}},
		{{q{windowingMainMenuBar},  q{ImGuiLocKey_WindowingMainMenuBar}}},
		{{q{windowingPopup},        q{ImGuiLocKey_WindowingPopup}}},
		{{q{windowingUntitled},     q{ImGuiLocKey_WindowingUntitled}}},
		{{q{openLinkS},             q{ImGuiLocKey_OpenLink_s}}},
		{{q{copyLink},              q{ImGuiLocKey_CopyLink}}},
		{{q{count},                 q{ImGuiLocKey_COUNT}}},
	];
	return ret;
}()));

alias ImGuiDebugLogFlags_ = int;
mixin(makeEnumBind(q{ImGuiDebugLogFlags}, q{ImGuiDebugLogFlags_}, members: (){
	EnumMember[] ret = [
		{{q{none},                q{ImGuiDebugLogFlags_None}},                q{0}},
		{{q{eventError},          q{ImGuiDebugLogFlags_EventError}},          q{1<<0}},
		{{q{eventActiveID},       q{ImGuiDebugLogFlags_EventActiveId}},       q{1<<1}},
		{{q{eventFocus},          q{ImGuiDebugLogFlags_EventFocus}},          q{1<<2}},
		{{q{eventPopup},          q{ImGuiDebugLogFlags_EventPopup}},          q{1<<3}},
		{{q{eventNav},            q{ImGuiDebugLogFlags_EventNav}},            q{1<<4}},
		{{q{eventClipper},        q{ImGuiDebugLogFlags_EventClipper}},        q{1<<5}},
		{{q{eventSelection},      q{ImGuiDebugLogFlags_EventSelection}},      q{1<<6}},
		{{q{eventIO},             q{ImGuiDebugLogFlags_EventIO}},             q{1<<7}},
		{{q{eventInputRouting},   q{ImGuiDebugLogFlags_EventInputRouting}},   q{1<<8}},
		{{q{eventDocking},        q{ImGuiDebugLogFlags_EventDocking}},        q{1<<9}},
		{{q{eventViewport},       q{ImGuiDebugLogFlags_EventViewport}},       q{1<<10}},
		
		{{q{eventMask},           q{ImGuiDebugLogFlags_EventMask_}},          q{eventError | eventActiveID | eventFocus | eventPopup | eventNav | eventClipper | eventSelection | eventIO | eventInputRouting | eventDocking | eventViewport}},
		{{q{outputToTTY},         q{ImGuiDebugLogFlags_OutputToTTY}},         q{1<<20}},
		{{q{outputToTestEngine},  q{ImGuiDebugLogFlags_OutputToTestEngine}},  q{1<<21}},
	];
	return ret;
}()));

mixin(makeEnumBind(q{ImGuiContextHookType}, members: (){
	EnumMember[] ret = [
		{{q{newFramePre},     q{ImGuiContextHookType_NewFramePre}}},
		{{q{newFramePost},    q{ImGuiContextHookType_NewFramePost}}},
		{{q{endFramePre},     q{ImGuiContextHookType_EndFramePre}}},
		{{q{endFramePost},    q{ImGuiContextHookType_EndFramePost}}},
		{{q{renderPre},       q{ImGuiContextHookType_RenderPre}}},
		{{q{renderPost},      q{ImGuiContextHookType_RenderPost}}},
		{{q{shutdown},        q{ImGuiContextHookType_Shutdown}}},
		{{q{pendingRemoval},  q{ImGuiContextHookType_PendingRemoval_}}},
	];
	return ret;
}()));

enum IM_COL32_DISABLE = IM_COL32(0,0,0,1);
enum IMGUI_TABLE_MAX_COLUMNS = 512;

mixin(joinFnBinds((){
	FnBind[] ret = [
		{q{ImGuiContext*}, q{CreateContext}, q{ImFontAtlas* sharedFontAtlas=null}, ext: `C++, "ImGui"`},
		{q{void}, q{DestroyContext}, q{ImGuiContext* ctx=null}, ext: `C++, "ImGui"`},
		{q{ImGuiContext*}, q{GetCurrentContext}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetCurrentContext}, q{ImGuiContext* ctx}, ext: `C++, "ImGui"`},
		
		{q{ImGuiIO*}, q{GetIO}, q{}, ext: `C++, "ImGui"`},
		{q{ImGuiPlatformIO*}, q{GetPlatformIO}, q{}, ext: `C++, "ImGui"`},
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
		
		{q{void}, q{StyleColorsDark}, q{ImGuiStyle* dst=null}, ext: `C++, "ImGui"`, aliases: [q{StyleColoursDark}]},
		{q{void}, q{StyleColorsLight}, q{ImGuiStyle* dst=null}, ext: `C++, "ImGui"`, aliases: [q{StyleColoursLight}]},
		{q{void}, q{StyleColorsClassic}, q{ImGuiStyle* dst=null}, ext: `C++, "ImGui"`, aliases: [q{StyleColoursClassic}]},
		
		{q{bool}, q{Begin}, q{const(char)* name, bool* pOpen=null, ImGuiWindowFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{End}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginChild}, q{const(char)* strID, in ImVec2 size=ImVec2(0, 0), ImGuiChildFlags_ childFlags=0, ImGuiWindowFlags_ windowFlags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginChild}, q{ImGuiID id, in ImVec2 size=ImVec2(0, 0), ImGuiChildFlags_ childFlags=0, ImGuiWindowFlags_ windowFlags=0}, ext: `C++, "ImGui"`},
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
		
		{q{void}, q{SetNextWindowPos}, q{in ImVec2 pos, ImGuiCond_ cond=0, in ImVec2 pivot=ImVec2(0, 0)}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowSize}, q{in ImVec2 size, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextWindowSizeConstraints}, q{in ImVec2 sizeMin, in ImVec2 sizeMax, ImGuiSizeCallback customCallback=null, void* customCallbackData=null}, ext: `C++, "ImGui"`},
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
		{q{void}, q{PushStyleColor}, q{ImGuiCol_ idx, uint col}, ext: `C++, "ImGui"`, aliases: [q{PushStyleColour}]},
		{q{void}, q{PushStyleColor}, q{ImGuiCol_ idx, in ImVec4 col}, ext: `C++, "ImGui"`, aliases: [q{PushStyleColour}]},
		{q{void}, q{PopStyleColor}, q{int count=1}, ext: `C++, "ImGui"`, aliases: [q{PopStyleColour}]},
		{q{void}, q{PushStyleVar}, q{ImGuiStyleVar_ idx, float val}, ext: `C++, "ImGui"`},
		{q{void}, q{PushStyleVar}, q{ImGuiStyleVar_ idx, in ImVec2 val}, ext: `C++, "ImGui"`},
		{q{void}, q{PushStyleVarX}, q{ImGuiStyleVar_ idx, float valX}, ext: `C++, "ImGui"`},
		{q{void}, q{PushStyleVarY}, q{ImGuiStyleVar_ idx, float valY}, ext: `C++, "ImGui"`},
		{q{void}, q{PopStyleVar}, q{int count=1}, ext: `C++, "ImGui"`},
		{q{void}, q{PushItemFlag}, q{ImGuiItemFlags_ option, bool enabled}, ext: `C++, "ImGui"`},
		{q{void}, q{PopItemFlag}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{PushItemWidth}, q{float itemWidth}, ext: `C++, "ImGui"`},
		{q{void}, q{PopItemWidth}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextItemWidth}, q{float itemWidth}, ext: `C++, "ImGui"`},
		{q{float}, q{CalcItemWidth}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{PushTextWrapPos}, q{float wrapLocalPosX=0f}, ext: `C++, "ImGui"`},
		{q{void}, q{PopTextWrapPos}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImFont*}, q{GetFont}, q{}, ext: `C++, "ImGui"`},
		{q{float}, q{GetFontSize}, q{}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetFontTexUvWhitePixel}, q{}, ext: `C++, "ImGui"`, aliases: [q{GetFontTexUVWhitePixel}]},
		{q{uint}, q{GetColorU32}, q{ImGuiCol_ idx, float alphaMul=1f}, ext: `C++, "ImGui"`, aliases: [q{GetColourU32}]},
		{q{uint}, q{GetColorU32}, q{in ImVec4 col}, ext: `C++, "ImGui"`, aliases: [q{GetColourU32}]},
		{q{uint}, q{GetColorU32}, q{uint col, float alphaMul=1f}, ext: `C++, "ImGui"`, aliases: [q{GetColourU32}]},
		{q{const(ImVec4)*}, q{GetStyleColorVec4}, q{ImGuiCol_ idx}, ext: `C++, "ImGui"`, aliases: [q{GetStyleColourVec4}]},
		
		{q{ImVec2}, q{GetCursorScreenPos}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetCursorScreenPos}, q{in ImVec2 pos}, ext: `C++, "ImGui"`},
		{q{ImVec2}, q{GetContentRegionAvail}, q{}, ext: `C++, "ImGui"`},
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
		{q{ImGuiID}, q{GetID}, q{int intID}, ext: `C++, "ImGui"`},
		
		{q{void}, q{TextUnformatted}, q{const(char)* text, const(char)* textEnd=null}, ext: `C++, "ImGui"`},
		{q{void}, q{Text}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{TextV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{TextColored}, q{in ImVec4 col, const(char)* fmt, ...}, ext: `C++, "ImGui"`, aliases: [q{TextColoured}]},
		{q{void}, q{TextColoredV}, q{in ImVec4 col, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`, aliases: [q{TextColouredV}]},
		{q{void}, q{TextDisabled}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{TextDisabledV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{TextWrapped}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{TextWrappedV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{LabelText}, q{const(char)* label, const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{LabelTextV}, q{const(char)* label, const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{BulletText}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{BulletTextV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		{q{void}, q{SeparatorText}, q{const(char)* label}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{Button}, q{const(char)* label, in ImVec2 size=ImVec2(0, 0)}, ext: `C++, "ImGui"`},
		{q{bool}, q{SmallButton}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{bool}, q{InvisibleButton}, q{const(char)* strID, in ImVec2 size, ImGuiButtonFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{ArrowButton}, q{const(char)* strID, ImGuiDir dir}, ext: `C++, "ImGui"`},
		{q{bool}, q{Checkbox}, q{const(char)* label, bool* v}, ext: `C++, "ImGui"`},
		{q{bool}, q{CheckboxFlags}, q{const(char)* label, int* flags, int flagsValue}, ext: `C++, "ImGui"`},
		{q{bool}, q{CheckboxFlags}, q{const(char)* label, uint* flags, uint flagsValue}, ext: `C++, "ImGui"`},
		{q{bool}, q{RadioButton}, q{const(char)* label, bool active}, ext: `C++, "ImGui"`},
		{q{bool}, q{RadioButton}, q{const(char)* label, int* v, int vButton}, ext: `C++, "ImGui"`},
		{q{void}, q{ProgressBar}, q{float fraction, in ImVec2 sizeArg=ImVec2(-float.min_normal, 0), const(char)* overlay=null}, ext: `C++, "ImGui"`},
		{q{void}, q{Bullet}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{TextLink}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{void}, q{TextLinkOpenURL}, q{const(char)* label, const(char)* url=null}, ext: `C++, "ImGui"`},
		
		{q{void}, q{Image}, q{ImTextureID userTextureID, in ImVec2 imageSize, in ImVec2 uv0=ImVec2(0, 0), in ImVec2 uv1=ImVec2(1, 1), in ImVec4 tintCol=ImVec4(1, 1, 1, 1), in ImVec4 borderCol=ImVec4(0, 0, 0, 0)}, ext: `C++, "ImGui"`},
		{q{bool}, q{ImageButton}, q{const(char)* strID, ImTextureID userTextureID, in ImVec2 imageSize, in ImVec2 uv0=ImVec2(0, 0), in ImVec2 uv1=ImVec2(1, 1), in ImVec4 bgCol=ImVec4(0, 0, 0, 0), in ImVec4 tintCol=ImVec4(1, 1, 1, 1)}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginCombo}, q{const(char)* label, const(char)* previewValue, ImGuiComboFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndCombo}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{Combo}, q{const(char)* label, int* currentItem, const(char*)*/+ARRAY?+/ items, int itemsCount, int popupMaxHeightInItems=-1}, ext: `C++, "ImGui"`},
		{q{bool}, q{Combo}, q{const(char)* label, int* currentItem, const(char)* itemsSeparatedByZeros, int popupMaxHeightInItems=-1}, ext: `C++, "ImGui"`},
		{q{bool}, q{Combo}, q{const(char)* label, int* currentItem, StrGetterFn getter, void* userData, int itemsCount, int popupMaxHeightInItems=-1}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{DragFloat}, q{const(char)* label, float* v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloat2}, q{const(char)* label, float*/+ARRAY?+/ v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloat3}, q{const(char)* label, float*/+ARRAY?+/ v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloat4}, q{const(char)* label, float*/+ARRAY?+/ v, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragFloatRange2}, q{const(char)* label, float* vCurrentMin, float* vCurrentMax, float vSpeed=1f, float vMin=0f, float vMax=0f, const(char)* format="%.3f", const(char)* formatMax=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt}, q{const(char)* label, int* v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt2}, q{const(char)* label, int*/+ARRAY?+/ v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt3}, q{const(char)* label, int*/+ARRAY?+/ v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragInt4}, q{const(char)* label, int*/+ARRAY?+/ v, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragIntRange2}, q{const(char)* label, int* vCurrentMin, int* vCurrentMax, float vSpeed=1f, int vMin=0, int vMax=0, const(char)* format="%d", const(char)* formatMax=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragScalar}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, float vSpeed=1f, const(void)* pMin=null, const(void)* pMax=null, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{DragScalarN}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, int components, float vSpeed=1f, const(void)* pMin=null, const(void)* pMax=null, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{SliderFloat}, q{const(char)* label, float* v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderFloat2}, q{const(char)* label, float*/+ARRAY?+/ v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderFloat3}, q{const(char)* label, float*/+ARRAY?+/ v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderFloat4}, q{const(char)* label, float*/+ARRAY?+/ v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderAngle}, q{const(char)* label, float* vRad, float vDegreesMin=-360f, float vDegreesMax=360f, const(char)* format="%f deg", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt}, q{const(char)* label, int* v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt2}, q{const(char)* label, int*/+ARRAY?+/ v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt3}, q{const(char)* label, int*/+ARRAY?+/ v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderInt4}, q{const(char)* label, int*/+ARRAY?+/ v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderScalar}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, const(void)* pMin, const(void)* pMax, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{SliderScalarN}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, int components, const(void)* pMin, const(void)* pMax, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{VSliderFloat}, q{const(char)* label, in ImVec2 size, float* v, float vMin, float vMax, const(char)* format="%.3f", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{VSliderInt}, q{const(char)* label, in ImVec2 size, int* v, int vMin, int vMax, const(char)* format="%d", ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{VSliderScalar}, q{const(char)* label, in ImVec2 size, ImGuiDataType_ dataType, void* pData, const(void)* pMin, const(void)* pMax, const(char)* format=null, ImGuiSliderFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{InputText}, q{const(char)* label, char* buf, size_t bufSize, ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* userData=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputTextMultiline}, q{const(char)* label, char* buf, size_t bufSize, in ImVec2 size=ImVec2(0, 0), ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* userData=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputTextWithHint}, q{const(char)* label, const(char)* hint, char* buf, size_t bufSize, ImGuiInputTextFlags_ flags=0, ImGuiInputTextCallback callback=null, void* userData=null}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat}, q{const(char)* label, float* v, float step=0f, float stepFast=0f, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat2}, q{const(char)* label, float*/+ARRAY?+/ v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat3}, q{const(char)* label, float*/+ARRAY?+/ v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputFloat4}, q{const(char)* label, float*/+ARRAY?+/ v, const(char)* format="%.3f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt}, q{const(char)* label, int* v, int step=1, int stepFast=100, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt2}, q{const(char)* label, int*/+ARRAY?+/ v, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt3}, q{const(char)* label, int*/+ARRAY?+/ v, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputInt4}, q{const(char)* label, int*/+ARRAY?+/ v, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputDouble}, q{const(char)* label, double* v, double step=0, double stepFast=0, const(char)* format="%.6f", ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputScalar}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, const(void)* pStep=null, const(void)* pStepFast=null, const(char)* format=null, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{InputScalarN}, q{const(char)* label, ImGuiDataType_ dataType, void* pData, int components, const(void)* pStep=null, const(void)* pStepFast=null, const(char)* format=null, ImGuiInputTextFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{ColorEdit3}, q{const(char)* label, float*/+ARRAY?+/ col, ImGuiColourEditFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: [q{ColourEdit3}]},
		{q{bool}, q{ColorEdit4}, q{const(char)* label, float*/+ARRAY?+/ col, ImGuiColourEditFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: [q{ColourEdit4}]},
		{q{bool}, q{ColorPicker3}, q{const(char)* label, float*/+ARRAY?+/ col, ImGuiColourEditFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: [q{ColourPicker3}]},
		{q{bool}, q{ColorPicker4}, q{const(char)* label, float*/+ARRAY?+/ col, ImGuiColourEditFlags_ flags=0, const(float)* refCol=null}, ext: `C++, "ImGui"`, aliases: [q{ColourPicker4}]},
		{q{bool}, q{ColorButton}, q{const(char)* descID, in ImVec4 col, ImGuiColourEditFlags_ flags=0, in ImVec2 size=ImVec2(0, 0)}, ext: `C++, "ImGui"`, aliases: [q{ColourButton}]},
		{q{void}, q{SetColorEditOptions}, q{ImGuiColourEditFlags_ flags}, ext: `C++, "ImGui"`, aliases: [q{SetColourEditOptions}]},
		
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
		{q{bool}, q{CollapsingHeader}, q{const(char)* label, bool* pVisible, ImGuiTreeNodeFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextItemOpen}, q{bool isOpen, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextItemStorageID}, q{ImGuiID storageID}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{Selectable}, q{const(char)* label, bool selected=false, ImGuiSelectableFlags_ flags=0, in ImVec2 size=ImVec2(0, 0)}, ext: `C++, "ImGui"`},
		{q{bool}, q{Selectable}, q{const(char)* label, bool* pSelected, ImGuiSelectableFlags_ flags=0, in ImVec2 size=ImVec2(0, 0)}, ext: `C++, "ImGui"`},
		
		{q{ImGuiMultiSelectIO*}, q{BeginMultiSelect}, q{ImGuiMultiSelectFlags_ flags, int selectionSize=-1, int itemsCount=-1}, ext: `C++, "ImGui"`},
		{q{ImGuiMultiSelectIO*}, q{EndMultiSelect}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextItemSelectionUserData}, q{ImGuiSelectionUserData selectionUserData}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsItemToggledSelection}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginListBox}, q{const(char)* label, in ImVec2 size=ImVec2(0, 0)}, ext: `C++, "ImGui"`},
		{q{void}, q{EndListBox}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{ListBox}, q{const(char)* label, int* currentItem, const(char*)*/+ARRAY?+/ items, int itemsCount, int heightInItems=-1}, ext: `C++, "ImGui"`},
		{q{bool}, q{ListBox}, q{const(char)* label, int* currentItem, StrGetterFn getter, void* userData, int itemsCount, int heightInItems=-1}, ext: `C++, "ImGui"`},
		
		{q{void}, q{PlotLines}, q{const(char)* label, const(float)* values, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0, 0), int stride=float.sizeof}, ext: `C++, "ImGui"`},
		{q{void}, q{PlotLines}, q{const(char)* label, ValuesGetterFn valuesGetter, void* data, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0, 0)}, ext: `C++, "ImGui"`},
		{q{void}, q{PlotHistogram}, q{const(char)* label, const(float)* values, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0, 0), int stride=float.sizeof}, ext: `C++, "ImGui"`},
		{q{void}, q{PlotHistogram}, q{const(char)* label, ValuesGetterFn valuesGetter, void* data, int valuesCount, int valuesOffset=0, const(char)* overlayText=null, float scaleMin=float.max, float scaleMax=float.max, ImVec2 graphSize=ImVec2(0, 0)}, ext: `C++, "ImGui"`},
		
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
		
		{q{bool}, q{BeginPopup}, q{const(char)* strID, ImGuiWindowFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginPopupModal}, q{const(char)* name, bool* pOpen=null, ImGuiWindowFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{EndPopup}, q{}, ext: `C++, "ImGui"`},
		
		{q{void}, q{OpenPopup}, q{const(char)* strID, ImGuiPopupFlags_ popupFlags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{OpenPopup}, q{ImGuiID id, ImGuiPopupFlags_ popupFlags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{OpenPopupOnItemClick}, q{const(char)* strID=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		{q{void}, q{CloseCurrentPopup}, q{}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginPopupContextItem}, q{const(char)* strID=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginPopupContextWindow}, q{const(char)* strID=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		{q{bool}, q{BeginPopupContextVoid}, q{const(char)* strID=null, ImGuiPopupFlags_ popupFlags=1}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{IsPopupOpen}, q{const(char)* strID, ImGuiPopupFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{BeginTable}, q{const(char)* strID, int columns, ImGuiTableFlags_ flags=0, in ImVec2 outerSize=ImVec2(0f, 0f), float innerWidth=0f}, ext: `C++, "ImGui"`},
		{q{void}, q{EndTable}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{TableNextRow}, q{ImGuiTableRowFlags_ rowFlags=0, float minRowHeight=0f}, ext: `C++, "ImGui"`},
		{q{bool}, q{TableNextColumn}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{TableSetColumnIndex}, q{int columnN}, ext: `C++, "ImGui"`},
		
		{q{void}, q{TableSetupColumn}, q{const(char)* label, ImGuiTableColumnFlags_ flags=0, float initWidthOrWeight=0f, ImGuiID userID=0}, ext: `C++, "ImGui"`, aliases: [q{TableSetUpColumn}]},
		{q{void}, q{TableSetupScrollFreeze}, q{int cols, int rows}, ext: `C++, "ImGui"`, aliases: [q{TableSetUpScrollFreeze}]},
		{q{void}, q{TableHeader}, q{const(char)* label}, ext: `C++, "ImGui"`},
		{q{void}, q{TableHeadersRow}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{TableAngledHeadersRow}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImGuiTableSortSpecs*}, q{TableGetSortSpecs}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{TableGetColumnCount}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{TableGetColumnIndex}, q{}, ext: `C++, "ImGui"`},
		{q{int}, q{TableGetRowIndex}, q{}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{TableGetColumnName}, q{int columnN=-1}, ext: `C++, "ImGui"`},
		{q{ImGuiTableColumnFlags_}, q{TableGetColumnFlags}, q{int columnN=-1}, ext: `C++, "ImGui"`},
		{q{void}, q{TableSetColumnEnabled}, q{int columnN, bool v}, ext: `C++, "ImGui"`},
		{q{int}, q{TableGetHoveredColumn}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{TableSetBgColor}, q{ImGuiTableBgTarget_ target, uint colour, int columnN=-1}, ext: `C++, "ImGui"`, aliases: [q{TableSetBgColour}]},
		
		{q{void}, q{Columns}, q{int count=1, const(char)* id=null, bool borders=true}, ext: `C++, "ImGui"`},
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
		
		{q{void}, q{LogToTTY}, q{int autoOpenDepth=-1}, ext: `C++, "ImGui"`},
		{q{void}, q{LogToFile}, q{int autoOpenDepth=-1, const(char)* filename=null}, ext: `C++, "ImGui"`},
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
		
		{q{void}, q{SetNavCursorVisible}, q{bool visible}, ext: `C++, "ImGui"`},
		
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
		{q{const(char)*}, q{GetStyleColorName}, q{ImGuiCol_ idx}, ext: `C++, "ImGui"`, aliases: [q{GetStyleColourName}]},
		{q{void}, q{SetStateStorage}, q{ImGuiStorage* storage}, ext: `C++, "ImGui"`},
		{q{ImGuiStorage*}, q{GetStateStorage}, q{}, ext: `C++, "ImGui"`},
		
		{q{ImVec2}, q{CalcTextSize}, q{const(char)* text, const(char)* textEnd=null, bool hideTextAfterDoubleHash=false, float wrapWidth=-1f}, ext: `C++, "ImGui"`},
		
		{q{ImVec4}, q{ColorConvertU32ToFloat4}, q{uint in_}, ext: `C++, "ImGui"`, aliases: [q{ColourConvertU32ToFloat4}]},
		{q{uint}, q{ColorConvertFloat4ToU32}, q{in ImVec4 in_}, ext: `C++, "ImGui"`, aliases: [q{ColourConvertFloat4ToU32}]},
		{q{void}, q{ColorConvertRGBtoHSV}, q{float r, float g, float b, ref float outH, ref float outS, ref float outV}, ext: `C++, "ImGui"`, aliases: [q{ColourConvertRgBtoHSV}, q{ColorConvertRgBtoHSV}, q{ColourConvertRGBtoHSV}]},
		{q{void}, q{ColorConvertHSVtoRGB}, q{float h, float s, float v, ref float outR, ref float outG, ref float outB}, ext: `C++, "ImGui"`, aliases: [q{ColourConvertHsVtoRGB}, q{ColorConvertHsVtoRGB}, q{ColourConvertHSVtoRGB}]},
		
		{q{bool}, q{IsKeyDown}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsKeyPressed}, q{ImGuiKey key, bool repeat=true}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsKeyReleased}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
		{q{bool}, q{IsKeyChordPressed}, q{ImGuiKeyChord keyChord}, ext: `C++, "ImGui"`},
		{q{int}, q{GetKeyPressedAmount}, q{ImGuiKey key, float repeatDelay, float rate}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{GetKeyName}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextFrameWantCaptureKeyboard}, q{bool wantCaptureKeyboard}, ext: `C++, "ImGui"`},
		
		{q{bool}, q{Shortcut}, q{ImGuiKeyChord keyChord, ImGuiInputFlags_ flags=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextItemShortcut}, q{ImGuiKeyChord keyChord, ImGuiInputFlags_ flags=0}, ext: `C++, "ImGui"`},
		
		{q{void}, q{SetItemKeyOwner}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
		
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
		{q{ImGuiMouseCursor_}, q{GetMouseCursor}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetMouseCursor}, q{ImGuiMouseCursor_ cursorType}, ext: `C++, "ImGui"`},
		{q{void}, q{SetNextFrameWantCaptureMouse}, q{bool wantCaptureMouse}, ext: `C++, "ImGui"`},
		
		{q{const(char)*}, q{GetClipboardText}, q{}, ext: `C++, "ImGui"`},
		{q{void}, q{SetClipboardText}, q{const(char)* text}, ext: `C++, "ImGui"`},
		
		{q{void}, q{LoadIniSettingsFromDisk}, q{const(char)* iniFilename}, ext: `C++, "ImGui"`},
		{q{void}, q{LoadIniSettingsFromMemory}, q{const(char)* iniData, size_t iniSize=0}, ext: `C++, "ImGui"`},
		{q{void}, q{SaveIniSettingsToDisk}, q{const(char)* iniFilename}, ext: `C++, "ImGui"`},
		{q{const(char)*}, q{SaveIniSettingsToMemory}, q{size_t* outIniSize=null}, ext: `C++, "ImGui"`},
		
		{q{void}, q{DebugTextEncoding}, q{const(char)* text}, ext: `C++, "ImGui"`},
		{q{void}, q{DebugFlashStyleColor}, q{ImGuiCol_ idx}, ext: `C++, "ImGui"`, aliases: [q{DebugFlashStyleColour}]},
		{q{void}, q{DebugStartItemPicker}, q{}, ext: `C++, "ImGui"`},
		{q{bool}, q{DebugCheckVersionAndDataLayout}, q{const(char)* versionStr, size_t szIO, size_t szStyle, size_t szVec2, size_t szVec4, size_t szDrawVert, size_t szDrawIdx}, ext: `C++, "ImGui"`},
		
		{q{void}, q{DebugLog}, q{const(char)* fmt, ...}, ext: `C++, "ImGui"`},
		{q{void}, q{DebugLogV}, q{const(char)* fmt, va_list args}, ext: `C++, "ImGui"`},
		
		{q{void}, q{SetAllocatorFunctions}, q{ImGuiMemAllocFunc allocFunc, ImGuiMemFreeFunc freeFunc, void* userData=null}, ext: `C++, "ImGui"`},
		{q{void}, q{GetAllocatorFunctions}, q{ImGuiMemAllocFunc* pAllocFunc, ImGuiMemFreeFunc* pFreeFunc, void** pUserData}, ext: `C++, "ImGui"`},
		{q{void*}, q{MemAlloc}, q{size_t size}, ext: `C++, "ImGui"`},
		{q{void}, q{MemFree}, q{void* ptr}, ext: `C++, "ImGui"`},
		{q{void}, q{ImVector_Construct}, q{void* vector}, ext: `C++`, aliases: [q{ImVectorConstruct}]},
		{q{void}, q{ImVector_Destruct}, q{void* vector}, ext: `C++`, aliases: [q{ImVectorDestruct}]},
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		FnBind[] add = [
			{q{ImVec2}, q{GetContentRegionMax}, q{}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}}
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		FnBind[] add = [
			{q{ImVec2}, q{GetWindowContentRegionMin}, q{}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}}
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		FnBind[] add = [
			{q{ImVec2}, q{GetWindowContentRegionMax}, q{}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}}
	
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		FnBind[] add = [
			{q{bool}, q{Combo}, q{const(char)* label, int* currentItem, OldCallbackFn oldCallback, void* userData, int itemsCount, int popupMaxHeightInItems=-1}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}}
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		FnBind[] add = [
			{q{bool}, q{ListBox}, q{const(char)* label, int* currentItem, OldCallbackFn oldCallback, void* userData, int itemsCount, int heightInItems=-1}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}}
	
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		FnBind[] add = [
			{q{void}, q{SetItemAllowOverlap}, q{}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}}
	
	version(ImGui_DisableObsoleteFunctions){
	}else{{
		FnBind[] add = [
			{q{ImGuiKey}, q{GetKeyIndex}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
		];
		ret ~= add;
	}}
	version(ImGui_Internal){
		{
			FnBind[] add = [
				{q{ImGuiID}, q{ImHashData}, q{const(void)* data, size_t dataSize, ImGuiID seed=0}, ext: `C++`},
				{q{ImGuiID}, q{ImHashStr}, q{const(char)* data, size_t dataSize=0, ImGuiID seed=0}, ext: `C++`},
				
				{q{uint}, q{ImAlphaBlendColors}, q{uint colA, uint colB}, ext: `C++`, aliases: [q{ImAlphaBlendColours}]},
				
				{q{int}, q{ImStricmp}, q{const(char)* str1, const(char)* str2}, ext: `C++`},
				{q{int}, q{ImStrnicmp}, q{const(char)* str1, const(char)* str2, size_t count}, ext: `C++`},
				{q{void}, q{ImStrncpy}, q{char* dst, const(char)* src, size_t count}, ext: `C++`},
				{q{char*}, q{ImStrdup}, q{const(char)* str}, ext: `C++`},
				{q{char*}, q{ImStrdupcpy}, q{char* dst, size_t* pDstSize, const(char)* str}, ext: `C++`},
				{q{const(char)*}, q{ImStrchrRange}, q{const(char)* strBegin, const(char)* strEnd, char c}, ext: `C++`},
				{q{const(char)*}, q{ImStreolRange}, q{const(char)* str, const(char)* strEnd}, ext: `C++`},
				{q{const(char)*}, q{ImStristr}, q{const(char)* haystack, const(char)* haystackEnd, const(char)* needle, const(char)* needleEnd}, ext: `C++`},
				{q{void}, q{ImStrTrimBlanks}, q{char* str}, ext: `C++`},
				{q{const(char)*}, q{ImStrSkipBlank}, q{const(char)* str}, ext: `C++`},
				{q{int}, q{ImStrlenW}, q{const(ImWChar)* str}, ext: `C++`},
				{q{const(char)*}, q{ImStrbol}, q{const(char)* bufMidLine, const(char)* bufBegin}, ext: `C++`},
				
				{q{int}, q{ImFormatString}, q{char* buf, size_t bufSize, const(char)* fmt, ...}, ext: `C++`},
				{q{int}, q{ImFormatStringV}, q{char* buf, size_t bufSize, const(char)* fmt, va_list args}, ext: `C++`},
				{q{void}, q{ImFormatStringToTempBuffer}, q{const(char)** outBuf, const(char)** outBufEnd, const(char)* fmt, ...}, ext: `C++`},
				{q{void}, q{ImFormatStringToTempBufferV}, q{const(char)** outBuf, const(char)** outBufEnd, const(char)* fmt, va_list args}, ext: `C++`},
				{q{const(char)*}, q{ImParseFormatFindStart}, q{const(char)* format}, ext: `C++`},
				{q{const(char)*}, q{ImParseFormatFindEnd}, q{const(char)* format}, ext: `C++`},
				{q{const(char)*}, q{ImParseFormatTrimDecorations}, q{const(char)* format, char* buf, size_t bufSize}, ext: `C++`},
				{q{void}, q{ImParseFormatSanitizeForPrinting}, q{const(char)* fmtIn, char* fmtOut, size_t fmtOutSize}, ext: `C++`},
				{q{const(char)*}, q{ImParseFormatSanitizeForScanning}, q{const(char)* fmtIn, char* fmtOut, size_t fmtOutSize}, ext: `C++`},
				{q{int}, q{ImParseFormatPrecision}, q{const(char)* format, int defaultValue}, ext: `C++`},
				
				{q{const(char)*}, q{ImTextCharToUtf8}, q{char*/+ARRAY?+/ outBuf, uint c}, ext: `C++`, aliases: [q{ImTextCharToUTF8}]},
				{q{int}, q{ImTextStrToUtf8}, q{char* outBuf, int outBufSize, const(ImWChar)* inText, const(ImWChar)* inTextEnd}, ext: `C++`, aliases: [q{ImTextStrToUTF8}]},
				{q{int}, q{ImTextCharFromUtf8}, q{uint* outChar, const(char)* inText, const(char)* inTextEnd}, ext: `C++`, aliases: [q{ImTextCharFromUTF8}]},
				{q{int}, q{ImTextStrFromUtf8}, q{ImWChar* outBuf, int outBufSize, const(char)* inText, const(char)* inTextEnd, const(char)** inRemaining=null}, ext: `C++`, aliases: [q{ImTextStrFromUTF8}]},
				{q{int}, q{ImTextCountCharsFromUtf8}, q{const(char)* inText, const(char)* inTextEnd}, ext: `C++`, aliases: [q{ImTextCountCharsFromUTF8}]},
				{q{int}, q{ImTextCountUtf8BytesFromChar}, q{const(char)* inText, const(char)* inTextEnd}, ext: `C++`, aliases: [q{ImTextCountUTF8BytesFromChar}]},
				{q{int}, q{ImTextCountUtf8BytesFromStr}, q{const(ImWChar)* inText, const(ImWChar)* inTextEnd}, ext: `C++`, aliases: [q{ImTextCountUTF8BytesFromStr}]},
				{q{const(char)*}, q{ImTextFindPreviousUtf8Codepoint}, q{const(char)* inTextStart, const(char)* inTextCurr}, ext: `C++`, aliases: [q{ImTextFindPreviousUTF8Codepoint}]},
				{q{int}, q{ImTextCountLines}, q{const(char)* inText, const(char)* inTextEnd}, ext: `C++`},
				
				{q{void*}, q{ImFileLoadToMemory}, q{const(char)* filename, const(char)* mode, size_t* outFileSize=null, int paddingBytes=0}, ext: `C++`},
				
				{q{ImVec2}, q{ImBezierCubicCalc}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, float t}, ext: `C++`},
				{q{ImVec2}, q{ImBezierCubicClosestPoint}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, in ImVec2 p, int numSegments}, ext: `C++`},
				{q{ImVec2}, q{ImBezierCubicClosestPointCasteljau}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, in ImVec2 p, float tessTol}, ext: `C++`},
				{q{ImVec2}, q{ImBezierQuadraticCalc}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, float t}, ext: `C++`},
				{q{ImVec2}, q{ImLineClosestPoint}, q{in ImVec2 a, in ImVec2 b, in ImVec2 p}, ext: `C++`},
				{q{bool}, q{ImTriangleContainsPoint}, q{in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 p}, ext: `C++`},
				{q{ImVec2}, q{ImTriangleClosestPoint}, q{in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 p}, ext: `C++`},
				{q{void}, q{ImTriangleBarycentricCoords}, q{in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 p, ref float outU, ref float outV, ref float outW}, ext: `C++`},
				
				{q{size_t}, q{ImBitArrayGetStorageSizeInBytes}, q{int bitcount}, ext: `C++`},
				{q{void}, q{ImBitArrayClearAllBits}, q{uint* arr, int bitcount}, ext: `C++`},
				{q{bool}, q{ImBitArrayTestBit}, q{const(uint)* arr, int n}, ext: `C++`},
				{q{void}, q{ImBitArrayClearBit}, q{uint* arr, int n}, ext: `C++`},
				{q{void}, q{ImBitArraySetBit}, q{uint* arr, int n}, ext: `C++`},
				{q{void}, q{ImBitArraySetBitRange}, q{uint* arr, int n, int n2}, ext: `C++`},
				
				{q{ImGuiStoragePair*}, q{ImLowerBound}, q{ImGuiStoragePair* inBegin, ImGuiStoragePair* inEnd, ImGuiID key}, ext: `C++`},
				
				{q{ImGuiWindow*}, q{GetCurrentWindowRead}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiWindow*}, q{GetCurrentWindow}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiWindow*}, q{FindWindowByID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{ImGuiWindow*}, q{FindWindowByName}, q{const(char)* name}, ext: `C++, "ImGui"`},
				{q{void}, q{UpdateWindowParentAndRootLinks}, q{ImGuiWindow* window, ImGuiWindowFlags_ flags, ImGuiWindow* parentWindow}, ext: `C++, "ImGui"`},
				{q{void}, q{UpdateWindowSkipRefresh}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{CalcWindowNextAutoFitSize}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsWindowChildOf}, q{ImGuiWindow* window, ImGuiWindow* potentialParent, bool popupHierarchy}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsWindowWithinBeginStackOf}, q{ImGuiWindow* window, ImGuiWindow* potentialParent}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsWindowAbove}, q{ImGuiWindow* potentialAbove, ImGuiWindow* potentialBelow}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsWindowNavFocusable}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{SetWindowPos}, q{ImGuiWindow* window, in ImVec2 pos, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
				{q{void}, q{SetWindowSize}, q{ImGuiWindow* window, in ImVec2 size, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
				{q{void}, q{SetWindowCollapsed}, q{ImGuiWindow* window, bool collapsed, ImGuiCond_ cond=0}, ext: `C++, "ImGui"`},
				{q{void}, q{SetWindowHitTestHole}, q{ImGuiWindow* window, in ImVec2 pos, in ImVec2 size}, ext: `C++, "ImGui"`},
				{q{void}, q{SetWindowHiddenAndSkipItemsForCurrentFrame}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{SetWindowParentWindowForFocusRoute}, q{ImGuiWindow* window, ImGuiWindow* parentWindow}, ext: `C++, "ImGui"`},
				{q{ImRect}, q{WindowRectAbsToRel}, q{ImGuiWindow* window, ImRect r}, ext: `C++, "ImGui"`},
				{q{ImRect}, q{WindowRectRelToAbs}, q{ImGuiWindow* window, ImRect r}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{WindowPosAbsToRel}, q{ImGuiWindow* window, in ImVec2 p}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{WindowPosRelToAbs}, q{ImGuiWindow* window, in ImVec2 p}, ext: `C++, "ImGui"`},
				
				{q{void}, q{FocusWindow}, q{ImGuiWindow* window, ImGuiFocusRequestFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{void}, q{FocusTopMostWindowUnderOne}, q{ImGuiWindow* underThisWindow, ImGuiWindow* ignoreWindow, ImGuiViewport* filterViewport, ImGuiFocusRequestFlags_ flags}, ext: `C++, "ImGui"`},
				{q{void}, q{BringWindowToFocusFront}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{BringWindowToDisplayFront}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{BringWindowToDisplayBack}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{BringWindowToDisplayBehind}, q{ImGuiWindow* window, ImGuiWindow* aboveWindow}, ext: `C++, "ImGui"`},
				{q{int}, q{FindWindowDisplayIndex}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{ImGuiWindow*}, q{FindBottomMostVisibleWindowWithinBeginStack}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				
				{q{void}, q{SetNextWindowRefreshPolicy}, q{ImGuiWindowRefreshFlags_ flags}, ext: `C++, "ImGui"`},
				
				{q{void}, q{SetCurrentFont}, q{ImFont* font}, ext: `C++, "ImGui"`},
				{q{ImFont*}, q{GetDefaultFont}, q{}, ext: `C++, "ImGui"`},
				{q{ImDrawList*}, q{GetForegroundDrawList}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{ImDrawList*}, q{GetBackgroundDrawList}, q{ImGuiViewport* viewport}, ext: `C++, "ImGui"`},
				{q{ImDrawList*}, q{GetForegroundDrawList}, q{ImGuiViewport* viewport}, ext: `C++, "ImGui"`},
				{q{void}, q{AddDrawListToDrawDataEx}, q{ImDrawData* drawData, ImVector!(ImDrawList*)* outList, ImDrawList* drawList}, ext: `C++, "ImGui"`},
				
				{q{void}, q{Initialize}, q{}, ext: `C++, "ImGui"`, aliases: [q{Initialise}]},
				{q{void}, q{Shutdown}, q{}, ext: `C++, "ImGui"`},
				
				{q{void}, q{UpdateInputEvents}, q{bool trickleFastInputs}, ext: `C++, "ImGui"`},
				{q{void}, q{UpdateHoveredWindowAndCaptureFlags}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{FindHoveredWindowEx}, q{in ImVec2 pos, bool findFirstAndInAnyViewport, ImGuiWindow** outHoveredWindow, ImGuiWindow** outHoveredWindowUnderMovingWindow}, ext: `C++, "ImGui"`},
				{q{void}, q{StartMouseMovingWindow}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{UpdateMouseMovingWindowNewFrame}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{UpdateMouseMovingWindowEndFrame}, q{}, ext: `C++, "ImGui"`},
				
				{q{ImGuiID}, q{AddContextHook}, q{ImGuiContext* context, const(ImGuiContextHook)* hook}, ext: `C++, "ImGui"`},
				{q{void}, q{RemoveContextHook}, q{ImGuiContext* context, ImGuiID hookToRemove}, ext: `C++, "ImGui"`},
				{q{void}, q{CallContextHooks}, q{ImGuiContext* context, ImGuiContextHookType type}, ext: `C++, "ImGui"`},
				
				{q{void}, q{SetWindowViewport}, q{ImGuiWindow* window, ImGuiViewportP* viewport}, ext: `C++, "ImGui"`},
				
				{q{void}, q{MarkIniSettingsDirty}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{MarkIniSettingsDirty}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{ClearIniSettings}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{AddSettingsHandler}, q{const(ImGuiSettingsHandler)* handler}, ext: `C++, "ImGui"`},
				{q{void}, q{RemoveSettingsHandler}, q{const(char)* typeName}, ext: `C++, "ImGui"`},
				{q{ImGuiSettingsHandler*}, q{FindSettingsHandler}, q{const(char)* typeName}, ext: `C++, "ImGui"`},
				
				{q{ImGuiWindowSettings*}, q{CreateNewWindowSettings}, q{const(char)* name}, ext: `C++, "ImGui"`},
				{q{ImGuiWindowSettings*}, q{FindWindowSettingsByID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{ImGuiWindowSettings*}, q{FindWindowSettingsByWindow}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{ClearWindowSettings}, q{const(char)* name}, ext: `C++, "ImGui"`},
				
				{q{void}, q{LocalizeRegisterEntries}, q{const(ImGuiLocEntry)* entries, int count}, ext: `C++, "ImGui"`, aliases: [q{LocaliseRegisterEntries}]},
				{q{const(char)*}, q{LocalizeGetMsg}, q{ImGuiLocKey_ key}, ext: `C++, "ImGui"`, aliases: [q{LocaliseGetMsg}]},
				
				{q{void}, q{SetScrollX}, q{ImGuiWindow* window, float scrollX}, ext: `C++, "ImGui"`},
				{q{void}, q{SetScrollY}, q{ImGuiWindow* window, float scrollY}, ext: `C++, "ImGui"`},
				{q{void}, q{SetScrollFromPosX}, q{ImGuiWindow* window, float localX, float centreXRatio}, ext: `C++, "ImGui"`},
				{q{void}, q{SetScrollFromPosY}, q{ImGuiWindow* window, float localY, float centreYRatio}, ext: `C++, "ImGui"`},
				
				{q{void}, q{ScrollToItem}, q{ImGuiScrollFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{void}, q{ScrollToRect}, q{ImGuiWindow* window, ImRect rect, ImGuiScrollFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{ScrollToRectEx}, q{ImGuiWindow* window, ImRect rect, ImGuiScrollFlags_ flags=0}, ext: `C++, "ImGui"`},
				
				{q{void}, q{ScrollToBringRectIntoView}, q{ImGuiWindow* window, ImRect rect}, ext: `C++, "ImGui"`},
				
				{q{ImGuiItemStatusFlags_}, q{GetItemStatusFlags}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiItemFlags_}, q{GetItemFlags}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetActiveID}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetFocusID}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{SetActiveID}, q{ImGuiID id, ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{SetFocusID}, q{ImGuiID id, ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{ClearActiveID}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetHoveredID}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{SetHoveredID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{void}, q{KeepAliveID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{void}, q{MarkItemEdited}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{void}, q{PushOverrideID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetIDWithSeed}, q{const(char)* strIDBegin, const(char)* strIDEnd, ImGuiID seed}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetIDWithSeed}, q{int n, ImGuiID seed}, ext: `C++, "ImGui"`},
				
				{q{void}, q{ItemSize}, q{in ImVec2 size, float textBaselineY=-1f}, ext: `C++, "ImGui"`},
				{q{void}, q{ItemSize}, q{ImRect bb, float textBaselineY=-1f}, ext: `C++, "ImGui"`},
				{q{bool}, q{ItemAdd}, q{ImRect bb, ImGuiID id, const(ImRect)* navBb=null, ImGuiItemFlags_ extraFlags=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{ItemHoverable}, q{ImRect bb, ImGuiID id, ImGuiItemFlags_ itemFlags}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsWindowContentHoverable}, q{ImGuiWindow* window, ImGuiHoveredFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsClippedEx}, q{ImRect bb, ImGuiID id}, ext: `C++, "ImGui"`},
				{q{void}, q{SetLastItemData}, q{ImGuiID itemID, ImGuiItemFlags_ inFlags, ImGuiItemStatusFlags_ statusFlags, ImRect itemRect}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{CalcItemSize}, q{ImVec2 size, float defaultW, float defaultH}, ext: `C++, "ImGui"`},
				{q{float}, q{CalcWrapWidthForPos}, q{in ImVec2 pos, float wrapPosX}, ext: `C++, "ImGui"`},
				{q{void}, q{PushMultiItemsWidths}, q{int components, float widthFull}, ext: `C++, "ImGui"`},
				{q{void}, q{ShrinkWidths}, q{ImGuiShrinkWidthItem* items, int count, float widthExcess}, ext: `C++, "ImGui"`},
				
				{q{const(ImGuiDataVarInfo)*}, q{GetStyleVarInfo}, q{ImGuiStyleVar_ idx}, ext: `C++, "ImGui"`},
				{q{void}, q{BeginDisabledOverrideReenable}, q{}, ext: `C++, "ImGui"`, aliases: [q{BeginDisabledOverrideReEnable}]},
				{q{void}, q{EndDisabledOverrideReenable}, q{}, ext: `C++, "ImGui"`, aliases: [q{EndDisabledOverrideReEnable}]},
				
				{q{void}, q{LogBegin}, q{ImGuiLogType type, int autoOpenDepth}, ext: `C++, "ImGui"`},
				{q{void}, q{LogToBuffer}, q{int autoOpenDepth=-1}, ext: `C++, "ImGui"`},
				{q{void}, q{LogRenderedText}, q{const(ImVec2)* refPos, const(char)* text, const(char)* textEnd=null}, ext: `C++, "ImGui"`},
				{q{void}, q{LogSetNextTextDecoration}, q{const(char)* prefix, const(char)* suffix}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{BeginChildEx}, q{const(char)* name, ImGuiID id, in ImVec2 sizeArg, ImGuiChildFlags_ childFlags, ImGuiWindowFlags_ windowFlags}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{BeginPopupEx}, q{ImGuiID id, ImGuiWindowFlags_ extraWindowFlags}, ext: `C++, "ImGui"`},
				{q{void}, q{OpenPopupEx}, q{ImGuiID id, ImGuiPopupFlags_ popupFlags=ImGuiPopupFlags.none}, ext: `C++, "ImGui"`},
				{q{void}, q{ClosePopupToLevel}, q{int remaining, bool restoreFocusToWindowUnderPopup}, ext: `C++, "ImGui"`},
				{q{void}, q{ClosePopupsOverWindow}, q{ImGuiWindow* refWindow, bool restoreFocusToWindowUnderPopup}, ext: `C++, "ImGui"`},
				{q{void}, q{ClosePopupsExceptModals}, q{}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsPopupOpen}, q{ImGuiID id, ImGuiPopupFlags_ popupFlags}, ext: `C++, "ImGui"`},
				{q{ImRect}, q{GetPopupAllowedExtentRect}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{ImGuiWindow*}, q{GetTopMostPopupModal}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiWindow*}, q{GetTopMostAndVisiblePopupModal}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiWindow*}, q{FindBlockingModal}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{FindBestWindowPosForPopup}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{FindBestWindowPosForPopupEx}, q{in ImVec2 refPos, in ImVec2 size, ImGuiDir* lastDir, ImRect rOuter, ImRect rAvoid, ImGuiPopupPositionPolicy policy}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{BeginTooltipEx}, q{ImGuiTooltipFlags_ tooltipFlags, ImGuiWindowFlags_ extraWindowFlags}, ext: `C++, "ImGui"`},
				{q{bool}, q{BeginTooltipHidden}, q{}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{BeginViewportSideBar}, q{const(char)* name, ImGuiViewport* viewport, ImGuiDir dir, float size, ImGuiWindowFlags_ windowFlags}, ext: `C++, "ImGui"`},
				{q{bool}, q{BeginMenuEx}, q{const(char)* label, const(char)* icon, bool enabled=true}, ext: `C++, "ImGui"`},
				{q{bool}, q{MenuItemEx}, q{const(char)* label, const(char)* icon, const(char)* shortcut=null, bool selected=false, bool enabled=true}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{BeginComboPopup}, q{ImGuiID popupID, ImRect bb, ImGuiComboFlags_ flags}, ext: `C++, "ImGui"`},
				{q{bool}, q{BeginComboPreview}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{EndComboPreview}, q{}, ext: `C++, "ImGui"`},
				
				{q{void}, q{NavInitWindow}, q{ImGuiWindow* window, bool forceReinit}, ext: `C++, "ImGui"`},
				{q{void}, q{NavInitRequestApplyResult}, q{}, ext: `C++, "ImGui"`},
				{q{bool}, q{NavMoveRequestButNoResultYet}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{NavMoveRequestSubmit}, q{ImGuiDir moveDir, ImGuiDir clipDir, ImGuiNavMoveFlags_ moveFlags, ImGuiScrollFlags_ scrollFlags}, ext: `C++, "ImGui"`},
				{q{void}, q{NavMoveRequestForward}, q{ImGuiDir moveDir, ImGuiDir clipDir, ImGuiNavMoveFlags_ moveFlags, ImGuiScrollFlags_ scrollFlags}, ext: `C++, "ImGui"`},
				{q{void}, q{NavMoveRequestResolveWithLastItem}, q{ImGuiNavItemData* result}, ext: `C++, "ImGui"`},
				{q{void}, q{NavMoveRequestResolveWithPastTreeNode}, q{ImGuiNavItemData* result, ImGuiTreeNodeStackData* treeNodeData}, ext: `C++, "ImGui"`},
				{q{void}, q{NavMoveRequestCancel}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{NavMoveRequestApplyResult}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{NavMoveRequestTryWrapping}, q{ImGuiWindow* window, ImGuiNavMoveFlags_ moveFlags}, ext: `C++, "ImGui"`},
				{q{void}, q{NavHighlightActivated}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{void}, q{NavClearPreferredPosForAxis}, q{ImGuiAxis axis}, ext: `C++, "ImGui"`},
				{q{void}, q{SetNavCursorVisibleAfterMove}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{NavUpdateCurrentWindowIsScrollPushableX}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{SetNavWindow}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{SetNavID}, q{ImGuiID id, ImGuiNavLayer navLayer, ImGuiID focusScopeID, ImRect rectRel}, ext: `C++, "ImGui"`},
				{q{void}, q{SetNavFocusScope}, q{ImGuiID focusScopeID}, ext: `C++, "ImGui"`},
				
				{q{void}, q{FocusItem}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{ActivateItemByID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{IsNamedKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsNamedKeyOrMod}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsLegacyKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsKeyboardKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsGamepadKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsMouseKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsAliasKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsLRModKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`, aliases: [q{IsLrModKey}]},
				{q{ImGuiKeyChord}, q{FixupKeyChord}, q{ImGuiKeyChord keyChord}, ext: `C++, "ImGui"`},
				{q{ImGuiKey}, q{ConvertSingleModFlagToKey}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				
				{q{ImGuiKeyData*}, q{GetKeyData}, q{ImGuiContext* ctx, ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{ImGuiKeyData*}, q{GetKeyData}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{const(char)*}, q{GetKeyChordName}, q{ImGuiKeyChord keyChord}, ext: `C++, "ImGui"`},
				{q{ImGuiKey}, q{MouseButtonToKey}, q{ImGuiMouseButton_ button}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsMouseDragPastThreshold}, q{ImGuiMouseButton_ button, float lockThreshold=-1f}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{GetKeyMagnitude2d}, q{ImGuiKey keyLeft, ImGuiKey keyRight, ImGuiKey keyUp, ImGuiKey keyDown}, ext: `C++, "ImGui"`, aliases: [q{GetKeyMagnitude2D}]},
				{q{float}, q{GetNavTweakPressedAmount}, q{ImGuiAxis axis}, ext: `C++, "ImGui"`},
				{q{int}, q{CalcTypematicRepeatAmount}, q{float t0, float t1, float repeatDelay, float repeatRate}, ext: `C++, "ImGui"`},
				{q{void}, q{GetTypematicRepeatRate}, q{ImGuiInputFlags_ flags, float* repeatDelay, float* repeatRate}, ext: `C++, "ImGui"`},
				{q{void}, q{TeleportMousePos}, q{in ImVec2 pos}, ext: `C++, "ImGui"`},
				{q{void}, q{SetActiveIdUsingAllKeyboardKeys}, q{}, ext: `C++, "ImGui"`, aliases: [q{SetActiveIDUsingAllKeyboardKeys}]},
				{q{bool}, q{IsActiveIdUsingNavDir}, q{ImGuiDir dir}, ext: `C++, "ImGui"`, aliases: [q{IsActiveIDUsingNavDir}]},
				
				{q{ImGuiID}, q{GetKeyOwner}, q{ImGuiKey key}, ext: `C++, "ImGui"`},
				{q{void}, q{SetKeyOwner}, q{ImGuiKey key, ImGuiID ownerID, ImGuiInputFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{void}, q{SetKeyOwnersForKeyChord}, q{ImGuiKeyChord key, ImGuiID ownerID, ImGuiInputFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{void}, q{SetItemKeyOwner}, q{ImGuiKey key, ImGuiInputFlags_ flags}, ext: `C++, "ImGui"`},
				{q{bool}, q{TestKeyOwner}, q{ImGuiKey key, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{ImGuiKeyOwnerData*}, q{GetKeyOwnerData}, q{ImGuiContext* ctx, ImGuiKey key}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{IsKeyDown}, q{ImGuiKey key, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsKeyPressed}, q{ImGuiKey key, ImGuiInputFlags_ flags, ImGuiID ownerID=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsKeyReleased}, q{ImGuiKey key, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsKeyChordPressed}, q{ImGuiKeyChord keyChord, ImGuiInputFlags_ flags, ImGuiID ownerID=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsMouseDown}, q{ImGuiMouseButton_ button, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsMouseClicked}, q{ImGuiMouseButton_ button, ImGuiInputFlags_ flags, ImGuiID ownerID=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsMouseReleased}, q{ImGuiMouseButton_ button, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsMouseDoubleClicked}, q{ImGuiMouseButton_ button, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{Shortcut}, q{ImGuiKeyChord keyChord, ImGuiInputFlags_ flags, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{bool}, q{SetShortcutRouting}, q{ImGuiKeyChord keyChord, ImGuiInputFlags_ flags, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{bool}, q{TestShortcutRouting}, q{ImGuiKeyChord keyChord, ImGuiID ownerID}, ext: `C++, "ImGui"`},
				{q{ImGuiKeyRoutingData*}, q{GetShortcutRoutingData}, q{ImGuiKeyChord keyChord}, ext: `C++, "ImGui"`},
				
				{q{void}, q{PushFocusScope}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{void}, q{PopFocusScope}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetCurrentFocusScope}, q{}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{IsDragDropActive}, q{}, ext: `C++, "ImGui"`},
				{q{bool}, q{BeginDragDropTargetCustom}, q{ImRect bb, ImGuiID id}, ext: `C++, "ImGui"`},
				{q{void}, q{ClearDragDrop}, q{}, ext: `C++, "ImGui"`},
				{q{bool}, q{IsDragDropPayloadBeingAccepted}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderDragDropTargetRect}, q{ImRect bb, ImRect itemClipRect}, ext: `C++, "ImGui"`},
				
				{q{ImGuiTypingSelectRequest*}, q{GetTypingSelectRequest}, q{ImGuiTypingSelectFlags_ flags=ImGuiTypingSelectFlags.none}, ext: `C++, "ImGui"`},
				{q{int}, q{TypingSelectFindMatch}, q{ImGuiTypingSelectRequest* req, int itemsCount, _3E968BE8A4B269A3_Fn getItemNameFunc, void* userData, int navItemIdx}, ext: `C++, "ImGui"`},
				{q{int}, q{TypingSelectFindNextSingleCharMatch}, q{ImGuiTypingSelectRequest* req, int itemsCount, _3E968BE8A4B269A3_Fn getItemNameFunc, void* userData, int navItemIdx}, ext: `C++, "ImGui"`},
				{q{int}, q{TypingSelectFindBestLeadingMatch}, q{ImGuiTypingSelectRequest* req, int itemsCount, _3E968BE8A4B269A3_Fn getItemNameFunc, void* userData}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{BeginBoxSelect}, q{ImRect scopeRect, ImGuiWindow* window, ImGuiID boxSelectID, ImGuiMultiSelectFlags_ msFlags}, ext: `C++, "ImGui"`},
				{q{void}, q{EndBoxSelect}, q{ImRect scopeRect, ImGuiMultiSelectFlags_ msFlags}, ext: `C++, "ImGui"`},
				
				{q{void}, q{MultiSelectItemHeader}, q{ImGuiID id, bool* pSelected, ImGuiButtonFlags_* pButtonFlags}, ext: `C++, "ImGui"`},
				{q{void}, q{MultiSelectItemFooter}, q{ImGuiID id, bool* pSelected, bool* pPressed}, ext: `C++, "ImGui"`},
				{q{void}, q{MultiSelectAddSetAll}, q{ImGuiMultiSelectTempData* ms, bool selected}, ext: `C++, "ImGui"`},
				{q{void}, q{MultiSelectAddSetRange}, q{ImGuiMultiSelectTempData* ms, bool selected, int rangeDir, ImGuiSelectionUserData firstItem, ImGuiSelectionUserData lastItem}, ext: `C++, "ImGui"`},
				{q{ImGuiBoxSelectState*}, q{GetBoxSelectState}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{ImGuiMultiSelectState*}, q{GetMultiSelectState}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				
				{q{void}, q{SetWindowClipRectBeforeSetChannel}, q{ImGuiWindow* window, ImRect clipRect}, ext: `C++, "ImGui"`},
				{q{void}, q{BeginColumns}, q{const(char)* strID, int count, ImGuiOldColumnFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{void}, q{EndColumns}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{PushColumnClipRect}, q{int columnIndex}, ext: `C++, "ImGui"`},
				{q{void}, q{PushColumnsBackground}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{PopColumnsBackground}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetColumnsID}, q{const(char)* strID, int count}, ext: `C++, "ImGui"`},
				{q{ImGuiOldColumns*}, q{FindOrCreateColumns}, q{ImGuiWindow* window, ImGuiID id}, ext: `C++, "ImGui"`},
				{q{float}, q{GetColumnOffsetFromNorm}, q{const(ImGuiOldColumns)* columns, float offsetNorm}, ext: `C++, "ImGui"`},
				{q{float}, q{GetColumnNormFromOffset}, q{const(ImGuiOldColumns)* columns, float offset}, ext: `C++, "ImGui"`},
				
				{q{void}, q{TableOpenContextMenu}, q{int columnN=-1}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSetColumnWidth}, q{int columnN, float width}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSetColumnSortDirection}, q{int columnN, ImGuiSortDirection sortDirection, bool appendToSortSpecs}, ext: `C++, "ImGui"`},
				{q{int}, q{TableGetHoveredRow}, q{}, ext: `C++, "ImGui"`},
				{q{float}, q{TableGetHeaderRowHeight}, q{}, ext: `C++, "ImGui"`},
				{q{float}, q{TableGetHeaderAngledMaxLabelWidth}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{TablePushBackgroundChannel}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{TablePopBackgroundChannel}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{TableAngledHeadersRowEx}, q{ImGuiID rowID, float angle, float maxLabelWidth, const(ImGuiTableHeaderData)* data, int dataCount}, ext: `C++, "ImGui"`},
				
				{q{ImGuiTable*}, q{GetCurrentTable}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiTable*}, q{TableFindByID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{bool}, q{BeginTableEx}, q{const(char)* name, ImGuiID id, int columnsCount, ImGuiTableFlags_ flags=0, in ImVec2 outerSize=ImVec2(0, 0), float innerWidth=0f}, ext: `C++, "ImGui"`},
				{q{void}, q{TableBeginInitMemory}, q{ImGuiTable* table, int columnsCount}, ext: `C++, "ImGui"`},
				{q{void}, q{TableBeginApplyRequests}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSetupDrawChannels}, q{ImGuiTable* table}, ext: `C++, "ImGui"`, aliases: [q{TableSetUpDrawChannels}]},
				{q{void}, q{TableUpdateLayout}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableUpdateBorders}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableUpdateColumnsWeightFromWidth}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableDrawBorders}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableDrawDefaultContextMenu}, q{ImGuiTable* table, ImGuiTableFlags_ flagsForSectionToDisplay}, ext: `C++, "ImGui"`},
				{q{bool}, q{TableBeginContextMenuPopup}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableMergeDrawChannels}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{ImGuiTableInstanceData*}, q{TableGetInstanceData}, q{ImGuiTable* table, int instanceNo}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{TableGetInstanceID}, q{ImGuiTable* table, int instanceNo}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSortSpecsSanitize}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSortSpecsBuild}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{ImGuiSortDirection}, q{TableGetColumnNextSortDirection}, q{ImGuiTableColumn* column}, ext: `C++, "ImGui"`},
				{q{void}, q{TableFixColumnSortDirection}, q{ImGuiTable* table, ImGuiTableColumn* column}, ext: `C++, "ImGui"`},
				{q{float}, q{TableGetColumnWidthAuto}, q{ImGuiTable* table, ImGuiTableColumn* column}, ext: `C++, "ImGui"`},
				{q{void}, q{TableBeginRow}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableEndRow}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableBeginCell}, q{ImGuiTable* table, int columnN}, ext: `C++, "ImGui"`},
				{q{void}, q{TableEndCell}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{ImRect}, q{TableGetCellBgRect}, q{const(ImGuiTable)* table, int columnN}, ext: `C++, "ImGui"`},
				{q{const(char)*}, q{TableGetColumnName}, q{const(ImGuiTable)* table, int columnN}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{TableGetColumnResizeID}, q{ImGuiTable* table, int columnN, int instanceNo=0}, ext: `C++, "ImGui"`},
				{q{float}, q{TableCalcMaxColumnWidth}, q{const(ImGuiTable)* table, int columnN}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSetColumnWidthAutoSingle}, q{ImGuiTable* table, int columnN}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSetColumnWidthAutoAll}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableRemove}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableGcCompactTransientBuffers}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableGcCompactTransientBuffers}, q{ImGuiTableTempData* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableGcCompactSettings}, q{}, ext: `C++, "ImGui"`},
				
				{q{void}, q{TableLoadSettings}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSaveSettings}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableResetSettings}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{ImGuiTableSettings*}, q{TableGetBoundSettings}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{TableSettingsAddSettingsHandler}, q{}, ext: `C++, "ImGui"`},
				{q{ImGuiTableSettings*}, q{TableSettingsCreate}, q{ImGuiID id, int columnsCount}, ext: `C++, "ImGui"`},
				{q{ImGuiTableSettings*}, q{TableSettingsFindByID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				
				{q{ImGuiTabBar*}, q{GetCurrentTabBar}, q{}, ext: `C++, "ImGui"`},
				{q{bool}, q{BeginTabBarEx}, q{ImGuiTabBar* tabBar, ImRect bb, ImGuiTabBarFlags_ flags}, ext: `C++, "ImGui"`},
				{q{ImGuiTabItem*}, q{TabBarFindTabByID}, q{ImGuiTabBar* tabBar, ImGuiID tabID}, ext: `C++, "ImGui"`},
				{q{ImGuiTabItem*}, q{TabBarFindTabByOrder}, q{ImGuiTabBar* tabBar, int order}, ext: `C++, "ImGui"`},
				{q{ImGuiTabItem*}, q{TabBarGetCurrentTab}, q{ImGuiTabBar* tabBar}, ext: `C++, "ImGui"`},
				{q{int}, q{TabBarGetTabOrder}, q{ImGuiTabBar* tabBar, ImGuiTabItem* tab}, ext: `C++, "ImGui"`},
				{q{const(char)*}, q{TabBarGetTabName}, q{ImGuiTabBar* tabBar, ImGuiTabItem* tab}, ext: `C++, "ImGui"`},
				{q{void}, q{TabBarRemoveTab}, q{ImGuiTabBar* tabBar, ImGuiID tabID}, ext: `C++, "ImGui"`},
				{q{void}, q{TabBarCloseTab}, q{ImGuiTabBar* tabBar, ImGuiTabItem* tab}, ext: `C++, "ImGui"`},
				{q{void}, q{TabBarQueueFocus}, q{ImGuiTabBar* tabBar, ImGuiTabItem* tab}, ext: `C++, "ImGui"`},
				{q{void}, q{TabBarQueueFocus}, q{ImGuiTabBar* tabBar, const(char)* tabName}, ext: `C++, "ImGui"`},
				{q{void}, q{TabBarQueueReorder}, q{ImGuiTabBar* tabBar, ImGuiTabItem* tab, int offset}, ext: `C++, "ImGui"`},
				{q{void}, q{TabBarQueueReorderFromMousePos}, q{ImGuiTabBar* tabBar, ImGuiTabItem* tab, ImVec2 mousePos}, ext: `C++, "ImGui"`},
				{q{bool}, q{TabBarProcessReorder}, q{ImGuiTabBar* tabBar}, ext: `C++, "ImGui"`},
				{q{bool}, q{TabItemEx}, q{ImGuiTabBar* tabBar, const(char)* label, bool* pOpen, ImGuiTabItemFlags_ flags, ImGuiWindow* dockedWindow}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{TabItemCalcSize}, q{const(char)* label, bool hasCloseButtonOrUnsavedMarker}, ext: `C++, "ImGui"`},
				{q{ImVec2}, q{TabItemCalcSize}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{TabItemBackground}, q{ImDrawList* drawList, ImRect bb, ImGuiTabItemFlags_ flags, uint col}, ext: `C++, "ImGui"`},
				{q{void}, q{TabItemLabelAndCloseButton}, q{ImDrawList* drawList, ImRect bb, ImGuiTabItemFlags_ flags, ImVec2 framePadding, const(char)* label, ImGuiID tabID, ImGuiID closeButtonID, bool isContentsVisible, bool* outJustClosed, bool* outTextClipped}, ext: `C++, "ImGui"`},
				
				{q{void}, q{RenderText}, q{ImVec2 pos, const(char)* text, const(char)* textEnd=null, bool hideTextAfterHash=true}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderTextWrapped}, q{ImVec2 pos, const(char)* text, const(char)* textEnd, float wrapWidth}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderTextClipped}, q{in ImVec2 posMin, in ImVec2 posMax, const(char)* text, const(char)* textEnd, const(ImVec2)* textSizeIfKnown, in ImVec2 align_=ImVec2(0, 0), const(ImRect)* clipRect=null}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderTextClippedEx}, q{ImDrawList* drawList, in ImVec2 posMin, in ImVec2 posMax, const(char)* text, const(char)* textEnd, const(ImVec2)* textSizeIfKnown, in ImVec2 align_=ImVec2(0, 0), const(ImRect)* clipRect=null}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderTextEllipsis}, q{ImDrawList* drawList, in ImVec2 posMin, in ImVec2 posMax, float clipMaxX, float ellipsisMaxX, const(char)* text, const(char)* textEnd, const(ImVec2)* textSizeIfKnown}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderFrame}, q{ImVec2 pMin, ImVec2 pMax, uint fillCol, bool borders=true, float rounding=0f}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderFrameBorder}, q{ImVec2 pMin, ImVec2 pMax, float rounding=0f}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderColorRectWithAlphaCheckerboard}, q{ImDrawList* drawList, ImVec2 pMin, ImVec2 pMax, uint fillCol, float gridStep, ImVec2 gridOff, float rounding=0f, ImDrawFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: [q{RenderColourRectWithAlphaCheckerboard}]},
				{q{void}, q{RenderNavCursor}, q{ImRect bb, ImGuiID id, ImGuiNavRenderCursorFlags_ flags=ImGuiNavRenderCursorFlags.none}, ext: `C++, "ImGui"`},
				
				{q{const(char)*}, q{FindRenderedTextEnd}, q{const(char)* text, const(char)* textEnd=null}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderMouseCursor}, q{ImVec2 pos, float scale, ImGuiMouseCursor_ mouseCursor, uint colFill, uint colBorder, uint colShadow}, ext: `C++, "ImGui"`},
				
				{q{void}, q{RenderArrow}, q{ImDrawList* drawList, ImVec2 pos, uint col, ImGuiDir dir, float scale=1f}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderBullet}, q{ImDrawList* drawList, ImVec2 pos, uint col}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderCheckMark}, q{ImDrawList* drawList, ImVec2 pos, uint col, float sz}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderArrowPointingAt}, q{ImDrawList* drawList, ImVec2 pos, ImVec2 halfSz, ImGuiDir direction, uint col}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderRectFilledRangeH}, q{ImDrawList* drawList, ImRect rect, uint col, float xStartNorm, float xEndNorm, float rounding}, ext: `C++, "ImGui"`},
				{q{void}, q{RenderRectFilledWithHole}, q{ImDrawList* drawList, ImRect outer, ImRect inner, uint col, float rounding}, ext: `C++, "ImGui"`},
				
				{q{void}, q{TextEx}, q{const(char)* text, const(char)* textEnd=null, ImGuiTextFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{ButtonEx}, q{const(char)* label, in ImVec2 sizeArg=ImVec2(0, 0), ImGuiButtonFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{ArrowButtonEx}, q{const(char)* strID, ImGuiDir dir, ImVec2 sizeArg, ImGuiButtonFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{bool}, q{ImageButtonEx}, q{ImGuiID id, ImTextureID textureID, in ImVec2 imageSize, in ImVec2 uv0, in ImVec2 uv1, in ImVec4 bgCol, in ImVec4 tintCol, ImGuiButtonFlags_ flags=0}, ext: `C++, "ImGui"`},
				{q{void}, q{SeparatorEx}, q{ImGuiSeparatorFlags_ flags, float thickness=1f}, ext: `C++, "ImGui"`},
				{q{void}, q{SeparatorTextEx}, q{ImGuiID id, const(char)* label, const(char)* labelEnd, float extraWidth}, ext: `C++, "ImGui"`},
				{q{bool}, q{CheckboxFlags}, q{const(char)* label, long* flags, long flagsValue}, ext: `C++, "ImGui"`},
				{q{bool}, q{CheckboxFlags}, q{const(char)* label, ulong* flags, ulong flagsValue}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{CloseButton}, q{ImGuiID id, in ImVec2 pos}, ext: `C++, "ImGui"`},
				{q{bool}, q{CollapseButton}, q{ImGuiID id, in ImVec2 pos}, ext: `C++, "ImGui"`},
				{q{void}, q{Scrollbar}, q{ImGuiAxis axis}, ext: `C++, "ImGui"`},
				{q{bool}, q{ScrollbarEx}, q{ImRect bb, ImGuiID id, ImGuiAxis axis, long* pScrollV, long availV, long contentsV, ImDrawFlags_ flags}, ext: `C++, "ImGui"`},
				{q{ImRect}, q{GetWindowScrollbarRect}, q{ImGuiWindow* window, ImGuiAxis axis}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetWindowScrollbarID}, q{ImGuiWindow* window, ImGuiAxis axis}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetWindowResizeCornerID}, q{ImGuiWindow* window, int n}, ext: `C++, "ImGui"`},
				{q{ImGuiID}, q{GetWindowResizeBorderID}, q{ImGuiWindow* window, ImGuiDir dir}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{ButtonBehavior}, q{ImRect bb, ImGuiID id, bool* outHovered, bool* outHeld, ImGuiButtonFlags_ flags=0}, ext: `C++, "ImGui"`, aliases: [q{ButtonBehaviour}]},
				{q{bool}, q{DragBehavior}, q{ImGuiID id, ImGuiDataType_ dataType, void* pV, float vSpeed, const(void)* pMin, const(void)* pMax, const(char)* format, ImGuiSliderFlags_ flags}, ext: `C++, "ImGui"`, aliases: [q{DragBehaviour}]},
				{q{bool}, q{SliderBehavior}, q{ImRect bb, ImGuiID id, ImGuiDataType_ dataType, void* pV, const(void)* pMin, const(void)* pMax, const(char)* format, ImGuiSliderFlags_ flags, ImRect* outGrabBb}, ext: `C++, "ImGui"`, aliases: [q{SliderBehaviour}]},
				{q{bool}, q{SplitterBehavior}, q{ImRect bb, ImGuiID id, ImGuiAxis axis, float* size1, float* size2, float minSize1, float minSize2, float hoverExtend=0f, float hoverVisibilityDelay=0f, uint bgCol=0}, ext: `C++, "ImGui"`, aliases: [q{SplitterBehaviour}]},
				
				{q{bool}, q{TreeNodeBehavior}, q{ImGuiID id, ImGuiTreeNodeFlags_ flags, const(char)* label, const(char)* labelEnd=null}, ext: `C++, "ImGui"`, aliases: [q{TreeNodeBehaviour}]},
				{q{void}, q{TreePushOverrideID}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{bool}, q{TreeNodeGetOpen}, q{ImGuiID storageID}, ext: `C++, "ImGui"`},
				{q{void}, q{TreeNodeSetOpen}, q{ImGuiID storageID, bool open}, ext: `C++, "ImGui"`},
				{q{bool}, q{TreeNodeUpdateNextOpen}, q{ImGuiID storageID, ImGuiTreeNodeFlags_ flags}, ext: `C++, "ImGui"`},
				
				{q{const(ImGuiDataTypeInfo)*}, q{DataTypeGetInfo}, q{ImGuiDataType_ dataType}, ext: `C++, "ImGui"`},
				{q{int}, q{DataTypeFormatString}, q{char* buf, int bufSize, ImGuiDataType_ dataType, const(void)* pData, const(char)* format}, ext: `C++, "ImGui"`},
				{q{void}, q{DataTypeApplyOp}, q{ImGuiDataType_ dataType, int op, void* output, const(void)* arg1, const(void)* arg2}, ext: `C++, "ImGui"`},
				{q{bool}, q{DataTypeApplyFromText}, q{const(char)* buf, ImGuiDataType_ dataType, void* pData, const(char)* format, void* pDataWhenEmpty=null}, ext: `C++, "ImGui"`},
				{q{int}, q{DataTypeCompare}, q{ImGuiDataType_ dataType, const(void)* arg1, const(void)* arg2}, ext: `C++, "ImGui"`},
				{q{bool}, q{DataTypeClamp}, q{ImGuiDataType_ dataType, void* pData, const(void)* pMin, const(void)* pMax}, ext: `C++, "ImGui"`},
				{q{bool}, q{DataTypeIsZero}, q{ImGuiDataType_ dataType, const(void)* pData}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{InputTextEx}, q{const(char)* label, const(char)* hint, char* buf, int bufSize, in ImVec2 sizeArg, ImGuiInputTextFlags_ flags, ImGuiInputTextCallback callback=null, void* userData=null}, ext: `C++, "ImGui"`},
				{q{void}, q{InputTextDeactivateHook}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				{q{bool}, q{TempInputText}, q{ImRect bb, ImGuiID id, const(char)* label, char* buf, int bufSize, ImGuiInputTextFlags_ flags}, ext: `C++, "ImGui"`},
				{q{bool}, q{TempInputScalar}, q{ImRect bb, ImGuiID id, const(char)* label, ImGuiDataType_ dataType, void* pData, const(char)* format, const(void)* pClampMin=null, const(void)* pClampMax=null}, ext: `C++, "ImGui"`},
				{q{bool}, q{TempInputIsActive}, q{ImGuiID id}, ext: `C++, "ImGui"`},
				
				{q{void}, q{SetNextItemRefVal}, q{ImGuiDataType_ dataType, void* pData}, ext: `C++, "ImGui"`},
				
				{q{void}, q{ColorTooltip}, q{const(char)* text, const(float)* col, ImGuiColourEditFlags_ flags}, ext: `C++, "ImGui"`, aliases: [q{ColourTooltip}]},
				{q{void}, q{ColorEditOptionsPopup}, q{const(float)* col, ImGuiColourEditFlags_ flags}, ext: `C++, "ImGui"`, aliases: [q{ColourEditOptionsPopup}]},
				{q{void}, q{ColorPickerOptionsPopup}, q{const(float)* refCol, ImGuiColourEditFlags_ flags}, ext: `C++, "ImGui"`, aliases: [q{ColourPickerOptionsPopup}]},
				
				{q{int}, q{PlotEx}, q{ImGuiPlotType plotType, const(char)* label, ValuesGetterFn valuesGetter, void* data, int valuesCount, int valuesOffset, const(char)* overlayText, float scaleMin, float scaleMax, in ImVec2 sizeArg}, ext: `C++, "ImGui"`},
				
				{q{void}, q{ShadeVertsLinearColorGradientKeepAlpha}, q{ImDrawList* drawList, int vertStartIdx, int vertEndIdx, ImVec2 gradientP0, ImVec2 gradientP1, uint col0, uint col1}, ext: `C++, "ImGui"`, aliases: [q{ShadeVertsLinearColourGradientKeepAlpha}]},
				{q{void}, q{ShadeVertsLinearUV}, q{ImDrawList* drawList, int vertStartIdx, int vertEndIdx, in ImVec2 a, in ImVec2 b, in ImVec2 uvA, in ImVec2 uvB, bool clamp}, ext: `C++, "ImGui"`},
				{q{void}, q{ShadeVertsTransformPos}, q{ImDrawList* drawList, int vertStartIdx, int vertEndIdx, in ImVec2 pivotIn, float cosA, float sinA, in ImVec2 pivotOut}, ext: `C++, "ImGui"`},
				
				{q{void}, q{GcCompactTransientMiscBuffers}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{GcCompactTransientWindowBuffers}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				{q{void}, q{GcAwakeTransientWindowBuffers}, q{ImGuiWindow* window}, ext: `C++, "ImGui"`},
				
				{q{bool}, q{ErrorLog}, q{const(char)* msg}, ext: `C++, "ImGui"`},
				{q{void}, q{ErrorRecoveryStoreState}, q{ImGuiErrorRecoveryState* stateOut}, ext: `C++, "ImGui"`},
				{q{void}, q{ErrorRecoveryTryToRecoverState}, q{const(ImGuiErrorRecoveryState)* stateIn}, ext: `C++, "ImGui"`},
				{q{void}, q{ErrorRecoveryTryToRecoverWindowState}, q{const(ImGuiErrorRecoveryState)* stateIn}, ext: `C++, "ImGui"`},
				{q{void}, q{ErrorCheckUsingSetCursorPosToExtendParentBoundaries}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{ErrorCheckEndFrameFinalizeErrorTooltip}, q{}, ext: `C++, "ImGui"`},
				{q{bool}, q{BeginErrorTooltip}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{EndErrorTooltip}, q{}, ext: `C++, "ImGui"`},
				
				{q{void}, q{DebugAllocHook}, q{ImGuiDebugAllocInfo* info, int frameCount, void* ptr, size_t size}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugDrawCursorPos}, q{uint col=IM_COL32(255, 0, 0, 255)}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugDrawLineExtents}, q{uint col=IM_COL32(255, 0, 0, 255)}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugDrawItemRect}, q{uint col=IM_COL32(255, 0, 0, 255)}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugTextUnformattedWithLocateItem}, q{const(char)* lineBegin, const(char)* lineEnd}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugLocateItem}, q{ImGuiID targetID}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugLocateItemOnHover}, q{ImGuiID targetID}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugLocateItemResolveWithLastItem}, q{}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugBreakClearData}, q{}, ext: `C++, "ImGui"`},
				{q{bool}, q{DebugBreakButton}, q{const(char)* label, const(char)* descriptionOfLocation}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugBreakButtonTooltip}, q{bool keyboardOnly, const(char)* descriptionOfLocation}, ext: `C++, "ImGui"`},
				{q{void}, q{ShowFontAtlas}, q{ImFontAtlas* atlas}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugHookIdInfo}, q{ImGuiID id, ImGuiDataType_ dataType, const(void)* dataID, const(void)* dataIDEnd}, ext: `C++, "ImGui"`, aliases: [q{DebugHookIDInfo}]},
				{q{void}, q{DebugNodeColumns}, q{ImGuiOldColumns* columns}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeDrawList}, q{ImGuiWindow* window, ImGuiViewportP* viewport, const(ImDrawList)* drawList, const(char)* label}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeDrawCmdShowMeshAndBoundingBox}, q{ImDrawList* outDrawList, const(ImDrawList)* drawList, const(ImDrawCmd)* drawCmd, bool showMesh, bool showAabb}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeFont}, q{ImFont* font}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeFontGlyph}, q{ImFont* font, const(ImFontGlyph)* glyph}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeStorage}, q{ImGuiStorage* storage, const(char)* label}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeTabBar}, q{ImGuiTabBar* tabBar, const(char)* label}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeTable}, q{ImGuiTable* table}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeTableSettings}, q{ImGuiTableSettings* settings}, ext: `C++, "ImGui"`},
				
				{q{void}, q{DebugNodeTypingSelectState}, q{ImGuiTypingSelectState* state}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeMultiSelectState}, q{ImGuiMultiSelectState* state}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeWindow}, q{ImGuiWindow* window, const(char)* label}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeWindowSettings}, q{ImGuiWindowSettings* settings}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeWindowsList}, q{ImVector!(ImGuiWindow*)* windows, const(char)* label}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeWindowsListByBeginStackParent}, q{ImGuiWindow** windows, int windowsSize, ImGuiWindow* parentInBeginStack}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugNodeViewport}, q{ImGuiViewportP* viewport}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugRenderKeyboardPreview}, q{ImDrawList* drawList}, ext: `C++, "ImGui"`},
				{q{void}, q{DebugRenderViewportThumbnail}, q{ImDrawList* drawList, ImGuiViewportP* viewport, ImRect bb}, ext: `C++, "ImGui"`},
				
				{q{const(ImFontBuilderIO)*}, q{ImFontAtlasGetBuilderForStbTruetype}, q{}, ext: `C++`},
				
				{q{void}, q{ImFontAtlasUpdateConfigDataPointers}, q{ImFontAtlas* atlas}, ext: `C++`},
				{q{void}, q{ImFontAtlasBuildInit}, q{ImFontAtlas* atlas}, ext: `C++`},
				{q{void}, q{ImFontAtlasBuildSetupFont}, q{ImFontAtlas* atlas, ImFont* font, ImFontConfig* fontConfig, float ascent, float descent}, ext: `C++`, aliases: [q{ImFontAtlasBuildSetUpFont}]},
				{q{void}, q{ImFontAtlasBuildPackCustomRects}, q{ImFontAtlas* atlas, void* stbrpContextOpaque}, ext: `C++`},
				{q{void}, q{ImFontAtlasBuildFinish}, q{ImFontAtlas* atlas}, ext: `C++`},
				{q{void}, q{ImFontAtlasBuildRender8bppRectFromString}, q{ImFontAtlas* atlas, int x, int y, int w, int h, const(char)* inStr, char inMarkerChar, ubyte inMarkerPixelValue}, ext: `C++`, aliases: [q{ImFontAtlasBuildRender8BPPRectFromString}]},
				{q{void}, q{ImFontAtlasBuildRender32bppRectFromString}, q{ImFontAtlas* atlas, int x, int y, int w, int h, const(char)* inStr, char inMarkerChar, uint inMarkerPixelValue}, ext: `C++`, aliases: [q{ImFontAtlasBuildRender32BPPRectFromString}]},
				{q{void}, q{ImFontAtlasBuildMultiplyCalcLookupTable}, q{ubyte*/+ARRAY?+/ outTable, float inMultiplyFactor}, ext: `C++`},
				{q{void}, q{ImFontAtlasBuildMultiplyRectAlpha8}, q{const(ubyte)*/+ARRAY?+/ table, ubyte* pixels, int x, int y, int w, int h, int stride}, ext: `C++`},
			];
			ret ~= add;
		}
		version(ImGui_DisableObsoleteFunctions){
		}else{{
			FnBind[] add = [
				{q{void}, q{RenderNavHighlight}, q{ImRect bb, ImGuiID id, ImGuiNavRenderCursorFlags_ flags=ImGuiNavRenderCursorFlags.none}, ext: `C++, "ImGui"`},
			];
			ret ~= add;
		}}
		
		version(ImGui_TestEngine){{
			FnBind[] add = [
				{q{void}, q{ImGuiTestEngineHook_ItemAdd}, q{ImGuiContext* ctx, ImGuiID id, ImRect bb, const(ImGuiLastItemData)* itemData}, ext: `C++`, aliases: [q{ImGuiTestEngineHookItemAdd}]},
			];
			ret ~= add;
		}}
		version(ImGui_TestEngine){{
			FnBind[] add = [
				{q{void}, q{ImGuiTestEngineHook_ItemInfo}, q{ImGuiContext* ctx, ImGuiID id, const(char)* label, ImGuiItemStatusFlags_ flags}, ext: `C++`, aliases: [q{ImGuiTestEngineHookItemInfo}]},
			];
			ret ~= add;
		}}
		version(ImGui_TestEngine){{
			FnBind[] add = [
				{q{void}, q{ImGuiTestEngineHook_Log}, q{ImGuiContext* ctx, const(char)* fmt, ...}, ext: `C++`, aliases: [q{ImGuiTestEngineHookLog}]},
			];
			ret ~= add;
		}}
		version(ImGui_TestEngine){{
			FnBind[] add = [
				{q{const(char)*}, q{ImGuiTestEngine_FindItemDebugLabel}, q{ImGuiContext* ctx, ImGuiID id}, ext: `C++`, aliases: [q{ImGuiTestEngineFindItemDebugLabel}]},
			];
			ret ~= add;
		}}
	}
	return ret;
}(), "ImGuiStyle, ImGuiIO, ImGuiInputTextCallbackData, ImGuiPayload, ImGuiTextFilter.ImGuiTextRange, ImGuiTextFilter, ImGuiTextBuffer, ImGuiStorage, ImGuiListClipper, ImGuiSelectionBasicStorage, ImGuiSelectionExternalStorage, ImDrawCmd, ImDrawListSplitter, ImDrawList, ImDrawData, ImFontGlyphRangesBuilder, ImFontAtlasCustomRect, ImFontAtlas, ImFont, ImGuiViewport, ImRect, ImBitVector, ImDrawListSharedData, ImGuiDataVarInfo, ImGuiTextIndex, ImGuiMenuColumns, ImGuiInputTextDeactivatedState, ImGuiInputTextState, ImGuiNextWindowData, ImGuiNextItemData, ImGuiKeyRoutingTable, ImGuiListClipperRange, ImGuiListClipperData, ImGuiNavItemData, ImGuiTypingSelectState, ImGuiMultiSelectTempData, ImGuiViewportP, ImGuiWindowSettings, ImGuiWindow, ImGuiTableSettings"));

extern(C++) struct ImVec2{
	float x = 0f, y = 0f;
	
	nothrow @nogc{
		float opIndex(size_t i) const pure @safe in(i >= 0 && i <= 1) =>
			i == 0 ? x : y;
		ImVec2 opUnary(string op)() const pure @safe =>
			mixin("ImVec2("~op~"x, "~op~"y)");
		ImVec2 opBinary(string op)(float rhs) const pure @safe =>
			mixin("ImVec2(x "~op~" rhs, y "~op~" rhs)");
		ImVec2 opBinary(string op)(const ImVec2 rhs) const pure @safe =>
			mixin("ImVec2(x "~op~" rhs.x, y "~op~" rhs.y)");
		ref ImVec2 opOpAssign(string op)(float rhs) pure @safe{
			mixin("x "~op~"= rhs; y "~op~"= rhs;");
			return this;
		}
		ref ImVec2 opOpAssign(string op)(const ImVec2 rhs) pure @safe{
			mixin("x "~op~"= rhs.x; y "~op~"= rhs.y;");
			return this;
		}
	}
}

extern(C++) struct ImVec4{
	float x = 0f, y = 0f, z = 0f, w = 0f;
	
	nothrow @nogc{
		ImVec4 opUnary(string op)() const pure @safe =>
			mixin("ImVec4("~op~"x, "~op~"y, "~op~"z, "~op~"w)");
		ImVec4 opBinary(string op)(float rhs) const pure @safe =>
			mixin("ImVec4(x "~op~" rhs, y "~op~" rhs, z "~op~" rhs, w "~op~" rhs)");
		ImVec4 opBinary(string op)(const ImVec4 rhs) const pure @safe =>
			mixin("ImVec4(x "~op~" rhs.x, y "~op~" rhs.y, z "~op~" rhs.z, w "~op~" rhs.w)");
		ref ImVec4 opOpAssign(string op)(const float rhs) pure @safe{
			mixin("x "~op~"= rhs; y "~op~"= rhs; z "~op~"= rhs; w "~op~"= rhs;");
			return this;
		}
		ref ImVec4 opOpAssign(string op)(const ImVec4 rhs) pure @safe{
			mixin("x "~op~"= rhs.x; y "~op~"= rhs.y; z "~op~"= rhs.z; w "~op~"= rhs.w;");
			return this;
		}
	}
}

extern(C++) struct ImGuiTableSortSpecs{
	const(ImGuiTableColumnSortSpecs)* specs;
	int specsCount;
	bool specsDirty;
	
	alias Specs = specs;
	alias SpecsCount = specsCount;
	alias SpecsDirty = specsDirty;
}

extern(C++) struct ImGuiTableColumnSortSpecs{
	ImGuiID columnUserID;
	short columnIndex;
	short sortOrder;
	ImGuiSortDirection sortDirection;
	
	alias ColumnUserID = columnUserID;
	alias ColumnIndex = columnIndex;
	alias SortOrder = sortOrder;
	alias SortDirection = sortDirection;
}

extern(C++) struct ImVector(T){
	int size;
	int capacity;
	T* data;
	
	alias ValueType = T;
	alias Iterator = ValueType*;
	alias ConstIterator = const(ValueType)*;
	
	nothrow @nogc{
		this(ImVector!T src){ opAssign(src); }
		ref ImVector!T opAssign(ImVector!T src){
			clear();
			resize(src.size);
			if(src.data){
				const len = size * T.sizeof;
				data[0..len] = src.data[0..len];
			}
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
		void clearDelete(){
			foreach(n; 0..size){
				data[n].destroy!false();
				static if(is(T D: D*)) MemFree(data[n]);
			}
			clear();
		}
		void clearDestruct(){
			foreach(n; 0..size)
				data[n].destroy!false();
			clear();
		}
		
		bool empty() const pure @safe => size == 0;
		int sizeInBytes() const pure @safe => size * cast(int)T.sizeof;
		int maxSize() pure @safe => 0x7FFFFFFF / cast(int)T.sizeof;
		ref inout(T) opIndex(int i) inout in(i >= 0 && i <= size) => data[i];
		
		inout(T)* begin() inout pure @safe => data;
		inout(T)* end() inout => data + size;
		ref inout(T) front() inout pure in(size > 0) => data[0];
		ref inout(T) back() inout pure in(size > 0) => data[size-1];
		void swap(ref ImVector!T rhs){
			int rhsSize = rhs.size;      rhs.size     = size;      size     = rhsSize;
			int rhsCap  = rhs.capacity;  rhs.capacity = capacity;  capacity = rhsCap;
			T* rhsData  = rhs.data;      rhs.data     = data;      data     = rhsData;
		}
		
		int growCapacity(int sz) const pure @safe{
			int newCapacity = capacity ? (capacity + capacity/2) : 8;
			return newCapacity > sz ? newCapacity : sz;
		}
		void resize(int newSize){
			if(newSize > capacity) reserve(growCapacity(newSize));
			size = newSize;
		}
		void resize(int newSize, ref T v){
			if(newSize > capacity) reserve(growCapacity(newSize));
			if(newSize > size){
				foreach(n; size..newSize)
					copyEmplace(v, data[n]);
			}
			size = newSize;
		}
		void shrink(int newSize) pure @safe
		in(newSize <= size){
			size = newSize;
		}
		void reserve(int newCapacity){
			if(newCapacity <= capacity) return;
			T* newData = cast(T*)MemAlloc(cast(size_t)newCapacity * T.sizeof);
			if(data){
				foreach(n; 0..size)
					copyEmplace(data[n], newData[n]);
				MemFree(data);
			}
			data = newData;
			capacity = newCapacity;
		}
		void reserveDiscard(int newCapacity){
			if(newCapacity <= capacity) return;
			if(data) MemFree(data);
			data = cast(T*)MemAlloc(cast(size_t)newCapacity * T.sizeof);
			capacity = newCapacity;
		}
		
		void pushBack(ref T v){
			if(size == capacity) reserve(growCapacity(size + 1));
			data[size++] = v;
		}
		void popBack() pure @safe
		in(size > 0){
			size--;
		}
		void pushFront(ref T v){
			if(size == 0) pushBack(v);
			else insert(data, v);
		}
		T* erase(const(T)* it)
		in(it >= data && it < data + size){
			const off = it - data;
			foreach(n; off..size-1)
				copyEmplace(data[n+1], data[n]);
			size--;
			return data + off;
		}
		T* erase(const(T)* it, const(T)* itLast)
		in(it >= data && it < data + size)
		in(itLast >= it && itLast <= data + size){
			const count = itLast - it;
			const off = it - data;
			foreach(n; off..size-count)
				copyEmplace(data[n+count], data[n]);
			size -= cast(int)count;
			return data + off;
		}
		T* eraseUnsorted(const(T)* it)
		in(it >= data && it < data + size){
			const off = it - data;
			if(it < data + size - 1)
				copyEmplace(data[size-1], data[off]);
			size--;
			return data + off;
		}
		T* insert(const(T)* it, ref T v)
		in(it >= data && it <= data + size){
			const off = it - data;
			if(size == capacity) reserve(growCapacity(size + 1));
			if(off < cast(int)size){
				foreach_reverse(n; off..size)
					copyEmplace(data[n], data[n+1]);
			}
			copyEmplace(v, data[off]);
			size++;
			return data + off;
		}
		bool contains(in T v) const{
			foreach(item; data[0..size])
				if(item == v) return true;
			return false;
		}
		inout(T)* find(ref const T v) inout{
			foreach(ref item; data[0..size])
				if(item == v) return &item;
			return data + size;
		}
		int findIndex(ref const T v) const @trusted{
			const(T)* it = find(v);
			return it == data + size ? -1 : cast(int)cast(ptrdiff_t)(it - data);
		}
		bool findErase(ref const T v){
			const(T)* it = find(v);
			if(it < data + size){
				erase(it);
				return true;
			}
			return false;
		}
		bool findEraseUnsorted(ref const T v){
			const(T)* it = find(v);
			if(it < data + size){
				eraseUnsorted(it);
				return true;
			}
			return false;
		}
		int indexFromPtr(const(T)* it) const pure @trusted
		in(it >= data && it < data + size) =>
			cast(int)cast(ptrdiff_t)(it - data);
	}
	
	alias Size = size;
	alias Capacity = capacity;
	alias Data = data;
	
	alias value_type = ValueType;
	alias iterator = Iterator;
	alias const_iterator = ConstIterator;
	
	alias clear_delete = clearDelete;
	alias clear_destruct = clearDestruct;
	alias size_in_bytes = sizeInBytes;
	alias max_size = maxSize;
	alias _grow_capacity = growCapacity;
	alias reserve_discard = reserveDiscard;
	alias push_back = pushBack;
	alias pop_back = popBack;
	alias push_front = pushFront;
	alias erase_unsorted = eraseUnsorted;
	//alias find_index = findIndex;
	//alias find_erase = findErase;
	//alias find_erase_unsorted = findEraseUnsorted;
	//alias index_from_ptr = indexFromPtr;
}

extern(C++) struct ImGuiStyle{
	float alpha = 0f;
	float disabledAlpha = 0f;
	ImVec2 windowPadding;
	float windowRounding = 0f;
	float windowBorderSize = 0f;
	ImVec2 windowMinSize;
	ImVec2 windowTitleAlign;
	ImGuiDir windowMenuButtonPosition;
	float childRounding = 0f;
	float childBorderSize = 0f;
	float popupRounding = 0f;
	float popupBorderSize = 0f;
	ImVec2 framePadding;
	float frameRounding = 0f;
	float frameBorderSize = 0f;
	ImVec2 itemSpacing;
	ImVec2 itemInnerSpacing;
	ImVec2 cellPadding;
	ImVec2 touchExtraPadding;
	float indentSpacing = 0f;
	float columnsMinSpacing = 0f;
	float scrollbarSize = 0f;
	float scrollbarRounding = 0f;
	float grabMinSize = 0f;
	float grabRounding = 0f;
	float logSliderDeadzone = 0f;
	float tabRounding = 0f;
	float tabBorderSize = 0f;
	float tabMinWidthForCloseButton = 0f;
	float tabBarBorderSize = 0f;
	float tabBarOverlineSize = 0f;
	float tableAngledHeadersAngle = 0f;
	ImVec2 tableAngledHeadersTextAlign;
	ImGuiDir colourButtonPosition;
	ImVec2 buttonTextAlign;
	ImVec2 selectableTextAlign;
	float separatorTextBorderSize = 0f;
	ImVec2 separatorTextAlign;
	ImVec2 separatorTextPadding;
	ImVec2 displayWindowPadding;
	ImVec2 displaySafeAreaPadding;
	float mouseCursorScale = 0f;
	bool antiAliasedLines;
	bool antiAliasedLinesUseTex;
	bool antiAliasedFill;
	float curveTessellationTol = 0f;
	float circleTessellationMaxError = 0f;
	ImVec4[ImGuiCol.count] colours;
	
	float hoverStationaryDelay = 0f;
	float hoverDelayShort = 0f;
	float hoverDelayNormal = 0f;
	ImGuiHoveredFlags_ hoverFlagsForTooltipMouse;
	ImGuiHoveredFlags_ hoverFlagsForTooltipNav;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ScaleAllSizes}, q{float scaleFactor}, ext: `C++`, aliases: [q{scaleAllSizes}]},
		];
		return ret;
	}()));
	
	alias Alpha = alpha;
	alias DisabledAlpha = disabledAlpha;
	alias WindowPadding = windowPadding;
	alias WindowRounding = windowRounding;
	alias WindowBorderSize = windowBorderSize;
	alias WindowMinSize = windowMinSize;
	alias WindowTitleAlign = windowTitleAlign;
	alias WindowMenuButtonPosition = windowMenuButtonPosition;
	alias ChildRounding = childRounding;
	alias ChildBorderSize = childBorderSize;
	alias PopupRounding = popupRounding;
	alias PopupBorderSize = popupBorderSize;
	alias FramePadding = framePadding;
	alias FrameRounding = frameRounding;
	alias FrameBorderSize = frameBorderSize;
	alias ItemSpacing = itemSpacing;
	alias ItemInnerSpacing = itemInnerSpacing;
	alias CellPadding = cellPadding;
	alias TouchExtraPadding = touchExtraPadding;
	alias IndentSpacing = indentSpacing;
	alias ColumnsMinSpacing = columnsMinSpacing;
	alias ScrollbarSize = scrollbarSize;
	alias ScrollbarRounding = scrollbarRounding;
	alias GrabMinSize = grabMinSize;
	alias GrabRounding = grabRounding;
	alias LogSliderDeadzone = logSliderDeadzone;
	alias TabRounding = tabRounding;
	alias TabBorderSize = tabBorderSize;
	alias TabMinWidthForCloseButton = tabMinWidthForCloseButton;
	alias TabBarBorderSize = tabBarBorderSize;
	alias TabBarOverlineSize = tabBarOverlineSize;
	alias TableAngledHeadersAngle = tableAngledHeadersAngle;
	alias TableAngledHeadersTextAlign = tableAngledHeadersTextAlign;
	alias ColourButtonPosition = colourButtonPosition;
	alias ColorButtonPosition = colourButtonPosition;
	alias colorButtonPosition = colourButtonPosition;
	alias ButtonTextAlign = buttonTextAlign;
	alias SelectableTextAlign = selectableTextAlign;
	alias SeparatorTextBorderSize = separatorTextBorderSize;
	alias SeparatorTextAlign = separatorTextAlign;
	alias SeparatorTextPadding = separatorTextPadding;
	alias DisplayWindowPadding = displayWindowPadding;
	alias DisplaySafeAreaPadding = displaySafeAreaPadding;
	alias MouseCursorScale = mouseCursorScale;
	alias AntiAliasedLines = antiAliasedLines;
	alias AntiAliasedLinesUseTex = antiAliasedLinesUseTex;
	alias AntiAliasedFill = antiAliasedFill;
	alias CurveTessellationTol = curveTessellationTol;
	alias CircleTessellationMaxError = circleTessellationMaxError;
	alias Colours = colours;
	alias Colors = colours;
	alias colors = colours;
	
	alias HoverStationaryDelay = hoverStationaryDelay;
	alias HoverDelayShort = hoverDelayShort;
	alias HoverDelayNormal = hoverDelayNormal;
	alias HoverFlagsForTooltipMouse = hoverFlagsForTooltipMouse;
	alias HoverFlagsForTooltipNav = hoverFlagsForTooltipNav;
}

extern(C++) struct ImGuiKeyData{
	bool down;
	float downDuration = 0f;
	float downDurationPrev = 0f;
	float analogValue = 0f;
	
	alias Down = down;
	alias DownDuration = downDuration;
	alias DownDurationPrev = downDurationPrev;
	alias AnalogValue = analogValue;
}

extern(C++) struct ImGuiIO{
	ImGuiConfigFlags_ configFlags;
	ImGuiBackendFlags_ backendFlags;
	ImVec2 displaySize;
	float deltaTime = 1f/60f;
	float iniSavingRate = 5f;
	const(char)* iniFilename = "imgui.ini";
	const(char)* logFilename = "imgui_log.txt";
	void* userData;
	
	ImFontAtlas* fonts;
	float fontGlobalScale = 1f;
	bool fontAllowUserScaling;
	ImFont* fontDefault;
	ImVec2 displayFramebufferScale = ImVec2(1f, 1f);
	
	bool configNavSwapGamepadButtons;
	bool configNavMoveSetMousePos;
	bool configNavCaptureKeyboard;
	bool configNavEscapeClearFocusItem;
	bool configNavEscapeClearFocusWindow;
	bool configNavCursorVisibleAuto;
	bool configNavCursorVisibleAlways;
	
	bool mouseDrawCursor;
	bool configMacOSXBehaviours = (){ version(Apple) return true; else return false; }();
	bool configInputTrickleEventQueue = true;
	bool configInputTextCursorBlink = true;
	bool configInputTextEnterKeepActive;
	bool configDragClickToInputText;
	bool configWindowsResizeFromEdges = true;
	bool configWindowsMoveFromTitleBarOnly;
	bool configScrollbarScrollByPage;
	float configMemoryCompactTimer = 60f;
	
	float mouseDoubleClickTime = 0f;
	float mouseDoubleClickMaxDist = 0f;
	float mouseDragThreshold = 0f;
	float keyRepeatDelay = 0f;
	float keyRepeatRate = 0f;
	
	bool configErrorRecovery;
	bool configErrorRecoveryEnableAssert;
	bool configErrorRecoveryEnableDebugLog;
	bool configErrorRecoveryEnableTooltip;
	
	bool configDebugIsDebuggerPresent;
	
	bool configDebugHighlightIDConflicts;
	
	bool configDebugBeginReturnValueOnce;
	bool configDebugBeginReturnValueLoop;
	
	bool configDebugIgnoreFocusLoss;
	
	bool configDebugIniSettings;
	
	const(char)* backendPlatformName;
	const(char)* backendRendererName;
	void* backendPlatformUserData;
	void* backendRendererUserData;
	void* backendLanguageUserData;
	
	bool wantCaptureMouse;
	bool wantCaptureKeyboard;
	bool wantTextInput;
	bool wantSetMousePos;
	bool wantSaveIniSettings;
	bool navActive;
	bool navVisible;
	float framerate = 0f;
	int metricsRenderVertices;
	int metricsRenderIndices;
	int metricsRenderWindows;
	int metricsActiveWindows;
	ImVec2 mouseDelta;
	
	ImGuiContext* ctx;
	
	ImVec2 mousePos;
	bool[5] mouseDown;
	float mouseWheel = 0f;
	float mouseWheelH = 0f;
	ImGuiMouseSource mouseSource;
	bool keyCtrl;
	bool keyShift;
	bool keyAlt;
	bool keySuper;
	
	ImGuiKeyChord keyMods;
	ImGuiKeyData[ImGuiKey.keysDataSize] keysData;
	bool wantCaptureMouseUnlessPopupClose;
	ImVec2 mousePosPrev;
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
	bool mouseCtrlLeftAsRightClick;
	float[5] mouseDownDuration;
	float[5] mouseDownDurationPrev;
	float[5] mouseDragMaxDistanceSqr;
	float penPressure = 0f;
	bool appFocusLost;
	bool appAcceptingEvents;
	byte backendUsingLegacyKeyArrays;
	bool backendUsingLegacyNavInputArray;
	ImWChar16 inputQueueSurrogate;
	ImVector!(ImWChar) inputQueueCharacters;
	
	int[ImGuiKey.count] keyMap;
	bool[ImGuiKey.count] keysDown;
	float[ImGuiNavInput.count] navInputs;
	private alias GetClipboardTextFnFn = extern(C++) const(char)* function(void* userData) nothrow @nogc;
	GetClipboardTextFnFn getClipboardTextFn;
	private alias SetClipboardTextFnFn = extern(C++) void function(void* userData, const(char)* text) nothrow @nogc;
	SetClipboardTextFnFn setClipboardTextFn;
	
	void* clipboardUserData;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{AddKeyEvent}, q{ImGuiKey key, bool down}, ext: `C++`, aliases: [q{addKeyEvent}]},
			{q{void}, q{AddKeyAnalogEvent}, q{ImGuiKey key, bool down, float v}, ext: `C++`, aliases: [q{addKeyAnalogEvent}]},
			{q{void}, q{AddMousePosEvent}, q{float x, float y}, ext: `C++`, aliases: [q{addMousePosEvent}]},
			{q{void}, q{AddMouseButtonEvent}, q{int button, bool down}, ext: `C++`, aliases: [q{addMouseButtonEvent}]},
			{q{void}, q{AddMouseWheelEvent}, q{float wheelX, float wheelY}, ext: `C++`, aliases: [q{addMouseWheelEvent}]},
			{q{void}, q{AddMouseSourceEvent}, q{ImGuiMouseSource source}, ext: `C++`, aliases: [q{addMouseSourceEvent}]},
			{q{void}, q{AddFocusEvent}, q{bool focused}, ext: `C++`, aliases: [q{addFocusEvent}]},
			{q{void}, q{AddInputCharacter}, q{uint c}, ext: `C++`, aliases: [q{addInputCharacter}]},
			{q{void}, q{AddInputCharacterUTF16}, q{ImWChar16 c}, ext: `C++`, aliases: [q{addInputCharacterUTF16}]},
			{q{void}, q{AddInputCharactersUTF8}, q{const(char)* str}, ext: `C++`, aliases: [q{addInputCharactersUTF8}]},
			{q{void}, q{SetKeyEventNativeData}, q{ImGuiKey key, int nativeKeycode, int nativeScancode, int nativeLegacyIndex=-1}, ext: `C++`, aliases: [q{setKeyEventNativeData}]},
			{q{void}, q{SetAppAcceptingEvents}, q{bool acceptingEvents}, ext: `C++`, aliases: [q{setAppAcceptingEvents}]},
			{q{void}, q{ClearEventsQueue}, q{}, ext: `C++`, aliases: [q{clearEventsQueue}]},
			{q{void}, q{ClearInputKeys}, q{}, ext: `C++`, aliases: [q{clearInputKeys}]},
			{q{void}, q{ClearInputMouse}, q{}, ext: `C++`, aliases: [q{clearInputMouse}]},
		];
		version(ImGui_DisableObsoleteFunctions){
		}else{{
			FnBind[] add = [
				{q{void}, q{ClearInputCharacters}, q{}, ext: `C++`, aliases: [q{clearInputCharacters}]},
			];
			ret ~= add;
		}}
		return ret;
	}()));
	
	alias ConfigFlags = configFlags;
	alias BackendFlags = backendFlags;
	alias DisplaySize = displaySize;
	alias DeltaTime = deltaTime;
	alias IniSavingRate = iniSavingRate;
	alias IniFilename = iniFilename;
	alias LogFilename = logFilename;
	alias UserData = userData;
	
	alias Fonts = fonts;
	alias FontGlobalScale = fontGlobalScale;
	alias FontAllowUserScaling = fontAllowUserScaling;
	alias FontDefault = fontDefault;
	alias DisplayFramebufferScale = displayFramebufferScale;
	
	alias ConfigNavSwapGamepadButtons = configNavSwapGamepadButtons;
	alias ConfigNavMoveSetMousePos = configNavMoveSetMousePos;
	alias ConfigNavCaptureKeyboard = configNavCaptureKeyboard;
	alias ConfigNavEscapeClearFocusItem = configNavEscapeClearFocusItem;
	alias ConfigNavEscapeClearFocusWindow = configNavEscapeClearFocusWindow;
	alias ConfigNavCursorVisibleAuto = configNavCursorVisibleAuto;
	alias ConfigNavCursorVisibleAlways = configNavCursorVisibleAlways;
	
	alias MouseDrawCursor = mouseDrawCursor;
	alias ConfigMacOSXBehaviours = configMacOSXBehaviours;
	alias ConfigMacOSXBehaviors = configMacOSXBehaviours;
	alias configMacOSXBehaviors = configMacOSXBehaviours;
	alias ConfigInputTrickleEventQueue = configInputTrickleEventQueue;
	alias ConfigInputTextCursorBlink = configInputTextCursorBlink;
	alias ConfigInputTextEnterKeepActive = configInputTextEnterKeepActive;
	alias ConfigDragClickToInputText = configDragClickToInputText;
	alias ConfigWindowsResizeFromEdges = configWindowsResizeFromEdges;
	alias ConfigWindowsMoveFromTitleBarOnly = configWindowsMoveFromTitleBarOnly;
	alias ConfigScrollbarScrollByPage = configScrollbarScrollByPage;
	alias ConfigMemoryCompactTimer = configMemoryCompactTimer;
	
	alias MouseDoubleClickTime = mouseDoubleClickTime;
	alias MouseDoubleClickMaxDist = mouseDoubleClickMaxDist;
	alias MouseDragThreshold = mouseDragThreshold;
	alias KeyRepeatDelay = keyRepeatDelay;
	alias KeyRepeatRate = keyRepeatRate;
	
	alias ConfigErrorRecovery = configErrorRecovery;
	alias ConfigErrorRecoveryEnableAssert = configErrorRecoveryEnableAssert;
	alias ConfigErrorRecoveryEnableDebugLog = configErrorRecoveryEnableDebugLog;
	alias ConfigErrorRecoveryEnableTooltip = configErrorRecoveryEnableTooltip;
	
	alias ConfigDebugIsDebuggerPresent = configDebugIsDebuggerPresent;
	
	alias ConfigDebugHighlightIdConflicts = configDebugHighlightIDConflicts;
	
	alias ConfigDebugBeginReturnValueOnce = configDebugBeginReturnValueOnce;
	alias ConfigDebugBeginReturnValueLoop = configDebugBeginReturnValueLoop;
	
	alias ConfigDebugIgnoreFocusLoss = configDebugIgnoreFocusLoss;
	
	alias ConfigDebugIniSettings = configDebugIniSettings;
	
	alias BackendPlatformName = backendPlatformName;
	alias BackendRendererName = backendRendererName;
	alias BackendPlatformUserData = backendPlatformUserData;
	alias BackendRendererUserData = backendRendererUserData;
	alias BackendLanguageUserData = backendLanguageUserData;
	
	alias WantCaptureMouse = wantCaptureMouse;
	alias WantCaptureKeyboard = wantCaptureKeyboard;
	alias WantTextInput = wantTextInput;
	alias WantSetMousePos = wantSetMousePos;
	alias WantSaveIniSettings = wantSaveIniSettings;
	alias NavActive = navActive;
	alias NavVisible = navVisible;
	alias Framerate = framerate;
	alias MetricsRenderVertices = metricsRenderVertices;
	alias MetricsRenderIndices = metricsRenderIndices;
	alias MetricsRenderWindows = metricsRenderWindows;
	alias MetricsActiveWindows = metricsActiveWindows;
	alias MouseDelta = mouseDelta;
	
	alias Ctx = ctx;
	
	alias MousePos = mousePos;
	alias MouseDown = mouseDown;
	alias MouseWheel = mouseWheel;
	alias MouseWheelH = mouseWheelH;
	alias MouseSource = mouseSource;
	alias KeyCtrl = keyCtrl;
	alias KeyShift = keyShift;
	alias KeyAlt = keyAlt;
	alias KeySuper = keySuper;
	
	alias KeyMods = keyMods;
	alias KeysData = keysData;
	alias WantCaptureMouseUnlessPopupClose = wantCaptureMouseUnlessPopupClose;
	alias MousePosPrev = mousePosPrev;
	alias MouseClickedPos = mouseClickedPos;
	alias MouseClickedTime = mouseClickedTime;
	alias MouseClicked = mouseClicked;
	alias MouseDoubleClicked = mouseDoubleClicked;
	alias MouseClickedCount = mouseClickedCount;
	alias MouseClickedLastCount = mouseClickedLastCount;
	alias MouseReleased = mouseReleased;
	alias MouseDownOwned = mouseDownOwned;
	alias MouseDownOwnedUnlessPopupClose = mouseDownOwnedUnlessPopupClose;
	alias MouseWheelRequestAxisSwap = mouseWheelRequestAxisSwap;
	alias MouseCtrlLeftAsRightClick = mouseCtrlLeftAsRightClick;
	alias MouseDownDuration = mouseDownDuration;
	alias MouseDownDurationPrev = mouseDownDurationPrev;
	alias MouseDragMaxDistanceSqr = mouseDragMaxDistanceSqr;
	alias PenPressure = penPressure;
	alias AppFocusLost = appFocusLost;
	alias AppAcceptingEvents = appAcceptingEvents;
	alias BackendUsingLegacyKeyArrays = backendUsingLegacyKeyArrays;
	alias BackendUsingLegacyNavInputArray = backendUsingLegacyNavInputArray;
	alias InputQueueSurrogate = inputQueueSurrogate;
	alias InputQueueCharacters = inputQueueCharacters;
	
	alias KeyMap = keyMap;
	alias KeysDown = keysDown;
	alias NavInputs = navInputs;
	alias GetClipboardTextFn = getClipboardTextFn;
	alias SetClipboardTextFn = setClipboardTextFn;
	
	alias ClipboardUserData = clipboardUserData;
}

extern(C++) struct ImGuiInputTextCallbackData{
	ImGuiContext* ctx;
	ImGuiInputTextFlags_ eventFlag;
	ImGuiInputTextFlags_ flags;
	void* userData;
	
	ImWChar eventChar = '\u0000';
	ImGuiKey eventKey;
	char* buf;
	int bufTextLen;
	int bufSize;
	bool bufDirty;
	int cursorPos;
	int selectionStart;
	int selectionEnd;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{DeleteChars}, q{int pos, int bytesCount}, ext: `C++`, aliases: [q{deleteChars}]},
			{q{void}, q{InsertChars}, q{int pos, const(char)* text, const(char)* textEnd=null}, ext: `C++`, aliases: [q{insertChars}]},
			{q{void}, q{SelectAll}, q{}, ext: `C++`, aliases: [q{selectAll}]},
			{q{void}, q{ClearSelection}, q{}, ext: `C++`, aliases: [q{clearSelection}]},
			{q{bool}, q{HasSelection}, q{}, ext: `C++`, attr: q{const}, aliases: [q{hasSelection}]},
		];
		return ret;
	}()));
	
	alias Ctx = ctx;
	alias EventFlag = eventFlag;
	alias Flags = flags;
	alias UserData = userData;
	
	alias EventChar = eventChar;
	alias EventKey = eventKey;
	alias Buf = buf;
	alias BufTextLen = bufTextLen;
	alias BufSize = bufSize;
	alias BufDirty = bufDirty;
	alias CursorPos = cursorPos;
	alias SelectionStart = selectionStart;
	alias SelectionEnd = selectionEnd;
}

extern(C++) struct ImGuiSizeCallbackData{
	void* userData;
	ImVec2 pos;
	ImVec2 currentSize;
	ImVec2 desiredSize;
	
	alias UserData = userData;
	alias Pos = pos;
	alias CurrentSize = currentSize;
	alias DesiredSize = desiredSize;
}

extern(C++) struct ImGuiPayload{
	void* data;
	int dataSize;
	
	ImGuiID sourceID;
	ImGuiID sourceParentID;
	int dataFrameCount = -1;
	char[32+1] dataType = '\x00';
	bool preview;
	bool delivery;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{bool}, q{IsDataType}, q{const(char)* type}, ext: `C++`, attr: q{const}, aliases: [q{isDataType}]},
			{q{bool}, q{IsPreview}, q{}, ext: `C++`, attr: q{const}, aliases: [q{isPreview}]},
			{q{bool}, q{IsDelivery}, q{}, ext: `C++`, attr: q{const}, aliases: [q{isDelivery}]},
		];
		return ret;
	}()));
	
	alias Data = data;
	alias DataSize = dataSize;
	
	alias SourceId = sourceID;
	alias SourceParentId = sourceParentID;
	alias DataFrameCount = dataFrameCount;
	alias DataType = dataType;
	alias Preview = preview;
	alias Delivery = delivery;
}

extern(C++) struct ImGuiTextFilter{
	extern(C++) struct ImGuiTextRange{
		const(char)* b;
		const(char)* e;
		
		extern(D) mixin(joinFnBinds((){
			FnBind[] ret = [
				{q{bool}, q{empty}, q{}, ext: `C++`, attr: q{const}},
				{q{void}, q{split}, q{char separator, ImVector!(ImGuiTextRange)* out_}, ext: `C++`, attr: q{const}},
			];
			return ret;
		}()));
	}
	
	char[256] inputBuf = '\x00';
	ImVector!(ImGuiTextRange) filters;
	int countGrep;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{bool}, q{Draw}, q{const(char)* label="Filter (inc,-exc)", float width=0f}, ext: `C++`, aliases: [q{draw}]},
			{q{bool}, q{PassFilter}, q{const(char)* text, const(char)* textEnd=null}, ext: `C++`, attr: q{const}, aliases: [q{passFilter}]},
			{q{void}, q{Build}, q{}, ext: `C++`, aliases: [q{build}]},
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{bool}, q{IsActive}, q{}, ext: `C++`, attr: q{const}, aliases: [q{isActive}]},
		];
		return ret;
	}()));
	
	alias InputBuf = inputBuf;
	alias Filters = filters;
	alias CountGrep = countGrep;
}

extern(C++) struct ImGuiTextBuffer{
	ImVector!(char) buf;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{const(char)*}, q{begin}, q{}, ext: `C++`, attr: q{const}},
			{q{const(char)*}, q{end}, q{}, ext: `C++`, attr: q{const}},
			{q{int}, q{size}, q{}, ext: `C++`, attr: q{const}},
			{q{bool}, q{empty}, q{}, ext: `C++`, attr: q{const}},
			{q{void}, q{clear}, q{}, ext: `C++`},
			{q{void}, q{reserve}, q{int capacity}, ext: `C++`},
			{q{const(char)*}, q{c_str}, q{}, ext: `C++`, attr: q{const}, aliases: [q{cStr}]},
			{q{void}, q{append}, q{const(char)* str, const(char)* strEnd=null}, ext: `C++`},
			{q{void}, q{appendf}, q{const(char)* fmt, ...}, ext: `C++`, aliases: [q{appendF}]},
			{q{void}, q{appendfv}, q{const(char)* fmt, va_list args}, ext: `C++`, aliases: [q{appendFV}]},
		];
		return ret;
	}()));
	
	alias Buf = buf;
}

extern(C++) struct ImGuiStoragePair{
	ImGuiID key;
	extern(C++) union{
		int valI;
		float valF;
		void* valP;
		
		alias val_i = valI;
		alias val_f = valF;
		alias val_p = valP;
	}
}

extern(C++) struct ImGuiStorage{
	ImVector!(ImGuiStoragePair) data;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{int}, q{GetInt}, q{ImGuiID key, int defaultVal=0}, ext: `C++`, attr: q{const}, aliases: [q{getInt}]},
			{q{void}, q{SetInt}, q{ImGuiID key, int val}, ext: `C++`, aliases: [q{setInt}]},
			{q{bool}, q{GetBool}, q{ImGuiID key, bool defaultVal=false}, ext: `C++`, attr: q{const}, aliases: [q{getBool}]},
			{q{void}, q{SetBool}, q{ImGuiID key, bool val}, ext: `C++`, aliases: [q{setBool}]},
			{q{float}, q{GetFloat}, q{ImGuiID key, float defaultVal=0f}, ext: `C++`, attr: q{const}, aliases: [q{getFloat}]},
			{q{void}, q{SetFloat}, q{ImGuiID key, float val}, ext: `C++`, aliases: [q{setFloat}]},
			{q{void*}, q{GetVoidPtr}, q{ImGuiID key}, ext: `C++`, attr: q{const}, aliases: [q{getVoidPtr}]},
			{q{void}, q{SetVoidPtr}, q{ImGuiID key, void* val}, ext: `C++`, aliases: [q{setVoidPtr}]},
			{q{int*}, q{GetIntRef}, q{ImGuiID key, int defaultVal=0}, ext: `C++`, aliases: [q{getIntRef}]},
			{q{bool*}, q{GetBoolRef}, q{ImGuiID key, bool defaultVal=false}, ext: `C++`, aliases: [q{getBoolRef}]},
			{q{float*}, q{GetFloatRef}, q{ImGuiID key, float defaultVal=0f}, ext: `C++`, aliases: [q{getFloatRef}]},
			{q{void**}, q{GetVoidPtrRef}, q{ImGuiID key, void* defaultVal=null}, ext: `C++`, aliases: [q{getVoidPtrRef}]},
			{q{void}, q{BuildSortByKey}, q{}, ext: `C++`, aliases: [q{buildSortByKey}]},
			{q{void}, q{SetAllInt}, q{int val}, ext: `C++`, aliases: [q{setAllInt}]},
		];
		return ret;
	}()));
	
	alias Data = data;
}

extern(C++) struct ImGuiListClipper{
	ImGuiContext* ctx;
	int displayStart;
	int displayEnd;
	int itemsCount;
	float itemsHeight = 0f;
	float startPosY = 0f;
	double startSeekOffsetY = 0.0;
	void* tempData;
	
	nothrow @nogc{
		void includeItemByIndex(int itemIndex){ includeItemsByIndex(itemIndex, itemIndex + 1); }
		version(ImGui_DisableObsoleteFunctions){
		}else{
			void includeRangeByIndices(int itemBegin, int itemEnd){ includeItemsByIndex(itemBegin, itemEnd); }
		}
		version(ImGui_DisableObsoleteFunctions){
		}else{
			void forceDisplayRangeByIndices(int itemBegin, int itemEnd){ includeItemsByIndex(itemBegin, itemEnd); }
		}
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Begin}, q{int itemsCount, float itemsHeight=-1f}, ext: `C++`, aliases: [q{begin}]},
			{q{void}, q{End}, q{}, ext: `C++`, aliases: [q{end}]},
			{q{bool}, q{Step}, q{}, ext: `C++`, aliases: [q{step}]},
			{q{void}, q{IncludeItemsByIndex}, q{int itemBegin, int itemEnd}, ext: `C++`, aliases: [q{includeItemsByIndex}]},
			{q{void}, q{SeekCursorForItem}, q{int itemIndex}, ext: `C++`, aliases: [q{seekCursorForItem}]},
		];
		return ret;
	}()));
	
	alias Ctx = ctx;
	alias DisplayStart = displayStart;
	alias DisplayEnd = displayEnd;
	alias ItemsCount = itemsCount;
	alias ItemsHeight = itemsHeight;
	alias StartPosY = startPosY;
	alias StartSeekOffsetY = startSeekOffsetY;
	alias TempData = tempData;
	
	alias IncludeItemByIndex = includeItemByIndex;
	alias IncludeRangeByIndices = includeRangeByIndices;
	alias ForceDisplayRangeByIndices = forceDisplayRangeByIndices;
}

extern(C++) struct ImColor{
	ImVec4 value;
	
	nothrow @nogc{
		this(float r, float g, float b, float a=1f) pure @safe{
			value = ImVec4(r,g,b,a);
		}
		this(int r, int g, int b, int a=255) pure @safe{
			value = ImVec4(
				cast(float)r * (1f/255f),
				cast(float)g * (1f/255f),
				cast(float)b * (1f/255f),
				cast(float)a * (1f/255f),
			);
		}
		this(uint rgba) pure @safe{
			value = ImVec4(
				cast(float)((rgba >> IM_COL32_R_SHIFT) & 0xFF) * (1f/255f),
				cast(float)((rgba >> IM_COL32_G_SHIFT) & 0xFF) * (1f/255f),
				cast(float)((rgba >> IM_COL32_B_SHIFT) & 0xFF) * (1f/255f),
				cast(float)((rgba >> IM_COL32_A_SHIFT) & 0xFF) * (1f/255f),
			);
		}
		void setHSV(float h, float s, float v, float a=1f){
			ColourConvertHSVtoRGB(h,s,v, value.x, value.y, value.z);
			value.w = a;
		}
		static ImColour hsv(float h, float s, float v, float a=1f){
			float r, g, b;
			ColourConvertHSVtoRGB(h,s,v, r,g,b);
			return ImColour(r,g,b,a);
		}
	}
	
	alias Value = value;
	
	alias SetHSV = setHSV;
	alias HSV = hsv;
}
alias ImColour = ImColor;

extern(C++) struct ImGuiMultiSelectIO{
	ImVector!(ImGuiSelectionRequest) requests;
	ImGuiSelectionUserData rangeSrcItem;
	ImGuiSelectionUserData navIDItem;
	bool navIDSelected;
	bool rangeSrcReset;
	int itemsCount;
	
	alias Requests = requests;
	alias RangeSrcItem = rangeSrcItem;
	alias NavIdItem = navIDItem;
	alias NavIdSelected = navIDSelected;
	alias RangeSrcReset = rangeSrcReset;
	alias ItemsCount = itemsCount;
}

extern(C++) struct ImGuiSelectionRequest{
	ImGuiSelectionRequestType type;
	bool selected;
	byte rangeDirection;
	ImGuiSelectionUserData rangeFirstItem;
	ImGuiSelectionUserData rangeLastItem;
	
	alias Type = type;
	alias Selected = selected;
	alias RangeDirection = rangeDirection;
	alias RangeFirstItem = rangeFirstItem;
	alias RangeLastItem = rangeLastItem;
}

extern(C++) struct ImGuiSelectionBasicStorage{
	int size;
	bool preserveOrder;
	void* userData;
	private alias AdapterIndexToStorageIDFn = extern(C++) ImGuiID function(ImGuiSelectionBasicStorage* self, int idx) nothrow @nogc;
	AdapterIndexToStorageIDFn adapterIndexToStorageID;
	
	int selectionOrder;
	ImGuiStorage storage;
	
	nothrow @nogc{
		ImGuiID getStorageIDFromIndex(int idx) => adapterIndexToStorageID(&this, idx);
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ApplyRequests}, q{ImGuiMultiSelectIO* msIO}, ext: `C++`, aliases: [q{applyRequests}]},
			{q{bool}, q{Contains}, q{ImGuiID id}, ext: `C++`, attr: q{const}, aliases: [q{contains}]},
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{void}, q{Swap}, q{ref ImGuiSelectionBasicStorage r}, ext: `C++`, aliases: [q{swap}]},
			{q{void}, q{SetItemSelected}, q{ImGuiID id, bool selected}, ext: `C++`, aliases: [q{setItemSelected}]},
			{q{bool}, q{GetNextSelectedItem}, q{void** opaqueIt, ImGuiID* outID}, ext: `C++`, aliases: [q{getNextSelectedItem}]},
		];
		return ret;
	}()));
	
	alias Size = size;
	alias PreserveOrder = preserveOrder;
	alias UserData = userData;
	alias AdapterIndexToStorageId = adapterIndexToStorageID;
	
	alias _SelectionOrder = selectionOrder;
	alias _Storage = storage;
	
	alias GetStorageIdFromIndex = getStorageIDFromIndex;
}

extern(C++) struct ImGuiSelectionExternalStorage{
	void* userData;
	private alias AdapterSetItemSelectedFn = extern(C++) void function(ImGuiSelectionExternalStorage* self, int idx, bool selected) nothrow @nogc;
	AdapterSetItemSelectedFn adapterSetItemSelected;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ApplyRequests}, q{ImGuiMultiSelectIO* msIO}, ext: `C++`, aliases: [q{applyRequests}]},
		];
		return ret;
	}()));
	
	alias UserData = userData;
	alias AdapterSetItemSelected = adapterSetItemSelected;
}

extern(C++) struct ImDrawCmd{
	ImVec4 clipRect;
	ImTextureID textureID;
	uint vtxOffset;
	uint idxOffset;
	uint elemCount;
	ImDrawCallback userCallback;
	void* userCallbackData;
	int userCallbackDataSize;
	int userCallbackDataOffset;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{ImTextureID}, q{GetTexID}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getTexID}]},
		];
		return ret;
	}()));
	
	alias ClipRect = clipRect;
	alias TextureId = textureID;
	alias VtxOffset = vtxOffset;
	alias IdxOffset = idxOffset;
	alias ElemCount = elemCount;
	alias UserCallback = userCallback;
	alias UserCallbackData = userCallbackData;
	alias UserCallbackDataSize = userCallbackDataSize;
	alias UserCallbackDataOffset = userCallbackDataOffset;
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
	
	alias ClipRect = clipRect;
	alias TextureId = textureID;
	alias VtxOffset = vtxOffset;
}

extern(C++) struct ImDrawChannel{
	ImVector!(ImDrawCmd) cmdBuffer;
	ImVector!(ImDrawIdx) idxBuffer;
	
	alias _CmdBuffer = cmdBuffer;
	alias _IdxBuffer = idxBuffer;
}

extern(C++) struct ImDrawListSplitter{
	int current;
	int count;
	ImVector!(ImDrawChannel) channels;
	
	nothrow @nogc{
		void clear(){ current = 0; count = 1; }
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ClearFreeMemory}, q{}, ext: `C++`, aliases: [q{clearFreeMemory}]},
			{q{void}, q{Split}, q{ImDrawList* drawList, int count}, ext: `C++`, aliases: [q{split}]},
			{q{void}, q{Merge}, q{ImDrawList* drawList}, ext: `C++`, aliases: [q{merge}]},
			{q{void}, q{SetCurrentChannel}, q{ImDrawList* drawList, int channelIdx}, ext: `C++`, aliases: [q{setCurrentChannel}]},
		];
		return ret;
	}()));
	
	alias _Current = current;
	alias _Count = count;
	alias _Channels = channels;
	
	alias Clear = clear;
}

extern(C++) struct ImDrawList{
	ImVector!(ImDrawCmd) cmdBuffer;
	ImVector!(ImDrawIdx) idxBuffer;
	ImVector!(ImDrawVert) vtxBuffer;
	ImDrawListFlags_ flags;
	
	uint vtxCurrentIdx;
	ImDrawListSharedData* data;
	ImDrawVert* vtxWritePtr;
	ImDrawIdx* idxWritePtr;
	ImVector!(ImVec2) path;
	ImDrawCmdHeader cmdHeader;
	ImDrawListSplitter splitter;
	ImVector!(ImVec4) clipRectStack;
	ImVector!(ImTextureID) textureIDStack;
	ImVector!(ubyte) callbacksDataBuf;
	float fringeScale = 0f;
	const(char)* ownerName;
	
	nothrow @nogc{
		ImVec2 getClipRectMin() const => ImVec2(clipRectStack.back().x, clipRectStack.back().y);
		ImVec2 getClipRectMax() const => ImVec2(clipRectStack.back().z, clipRectStack.back().w);
		void pathClear(){ path.size = 0; }
		void pathLineTo(ImVec2 pos){ path.pushBack(pos); }
		void pathLineToMergeDuplicate(ImVec2 pos){ if(!path.size || path.data[path.size-1] != pos) path.pushBack(pos); }
		void pathFillConvex(uint col){ addConvexPolyFilled(path.data, path.size, col); path.size = 0; }
		void pathFillConcave(uint col){ addConcavePolyFilled(path.data, path.size, col); path.size = 0; }
		void pathStroke(uint col, ImDrawFlags_ flags=0, float thickness=1f){ addPolyline(path.data, path.size, col, flags, thickness); path.size = 0; }
		void channelsSplit(int count){ splitter.split(&this, count); }
		void channelsMerge(){ splitter.merge(&this); }
		void channelsSetCurrent(int n){ splitter.setCurrentChannel(&this, n); }
		void primWriteVtx(ImVec2 pos, ImVec2 uv, uint col){ vtxWritePtr.pos = pos; vtxWritePtr.uv = uv; vtxWritePtr.col = col; vtxWritePtr++; vtxCurrentIdx++; }
		void primWriteIdx(ImDrawIdx idx){ *idxWritePtr = idx; idxWritePtr++; }
		void primVtx(ImVec2 pos, ImVec2 uv, uint col){ primWriteIdx(cast(ImDrawIdx)vtxCurrentIdx); primWriteVtx(pos, uv, col); }
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{PushClipRect}, q{in ImVec2 clipRectMin, in ImVec2 clipRectMax, bool intersectWithCurrentClipRect=false}, ext: `C++`, aliases: [q{pushClipRect}]},
			{q{void}, q{PushClipRectFullScreen}, q{}, ext: `C++`, aliases: [q{pushClipRectFullScreen}]},
			{q{void}, q{PopClipRect}, q{}, ext: `C++`, aliases: [q{popClipRect}]},
			{q{void}, q{PushTextureID}, q{ImTextureID textureID}, ext: `C++`, aliases: [q{pushTextureID}]},
			{q{void}, q{PopTextureID}, q{}, ext: `C++`, aliases: [q{popTextureID}]},
			{q{void}, q{AddLine}, q{in ImVec2 p1, in ImVec2 p2, uint col, float thickness=1f}, ext: `C++`, aliases: [q{addLine}]},
			{q{void}, q{AddRect}, q{in ImVec2 pMin, in ImVec2 pMax, uint col, float rounding=0f, ImDrawFlags_ flags=0, float thickness=1f}, ext: `C++`, aliases: [q{addRect}]},
			{q{void}, q{AddRectFilled}, q{in ImVec2 pMin, in ImVec2 pMax, uint col, float rounding=0f, ImDrawFlags_ flags=0}, ext: `C++`, aliases: [q{addRectFilled}]},
			{q{void}, q{AddRectFilledMultiColor}, q{in ImVec2 pMin, in ImVec2 pMax, uint colUprLeft, uint colUprRight, uint colBotRight, uint colBotLeft}, ext: `C++`, aliases: [q{addRectFilledMultiColour}, q{addRectFilledMultiColor}, q{AddRectFilledMultiColour}]},
			{q{void}, q{AddQuad}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, uint col, float thickness=1f}, ext: `C++`, aliases: [q{addQuad}]},
			{q{void}, q{AddQuadFilled}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, uint col}, ext: `C++`, aliases: [q{addQuadFilled}]},
			{q{void}, q{AddTriangle}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, uint col, float thickness=1f}, ext: `C++`, aliases: [q{addTriangle}]},
			{q{void}, q{AddTriangleFilled}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, uint col}, ext: `C++`, aliases: [q{addTriangleFilled}]},
			{q{void}, q{AddCircle}, q{in ImVec2 centre, float radius, uint col, int numSegments=0, float thickness=1f}, ext: `C++`, aliases: [q{addCircle}]},
			{q{void}, q{AddCircleFilled}, q{in ImVec2 centre, float radius, uint col, int numSegments=0}, ext: `C++`, aliases: [q{addCircleFilled}]},
			{q{void}, q{AddNgon}, q{in ImVec2 centre, float radius, uint col, int numSegments, float thickness=1f}, ext: `C++`, aliases: [q{addNgon}]},
			{q{void}, q{AddNgonFilled}, q{in ImVec2 centre, float radius, uint col, int numSegments}, ext: `C++`, aliases: [q{addNgonFilled}]},
			{q{void}, q{AddEllipse}, q{in ImVec2 centre, in ImVec2 radius, uint col, float rot=0f, int numSegments=0, float thickness=1f}, ext: `C++`, aliases: [q{addEllipse}]},
			{q{void}, q{AddEllipseFilled}, q{in ImVec2 centre, in ImVec2 radius, uint col, float rot=0f, int numSegments=0}, ext: `C++`, aliases: [q{addEllipseFilled}]},
			{q{void}, q{AddText}, q{in ImVec2 pos, uint col, const(char)* textBegin, const(char)* textEnd=null}, ext: `C++`, aliases: [q{addText}]},
			{q{void}, q{AddText}, q{const(ImFont)* font, float fontSize, in ImVec2 pos, uint col, const(char)* textBegin, const(char)* textEnd=null, float wrapWidth=0f, const(ImVec4)* cpuFineClipRect=null}, ext: `C++`, aliases: [q{addText}]},
			{q{void}, q{AddBezierCubic}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, uint col, float thickness, int numSegments=0}, ext: `C++`, aliases: [q{addBezierCubic}]},
			{q{void}, q{AddBezierQuadratic}, q{in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, uint col, float thickness, int numSegments=0}, ext: `C++`, aliases: [q{addBezierQuadratic}]},
			{q{void}, q{AddPolyline}, q{const(ImVec2)* points, int numPoints, uint col, ImDrawFlags_ flags, float thickness}, ext: `C++`, aliases: [q{addPolyline}]},
			{q{void}, q{AddConvexPolyFilled}, q{const(ImVec2)* points, int numPoints, uint col}, ext: `C++`, aliases: [q{addConvexPolyFilled}]},
			{q{void}, q{AddConcavePolyFilled}, q{const(ImVec2)* points, int numPoints, uint col}, ext: `C++`, aliases: [q{addConcavePolyFilled}]},
			{q{void}, q{AddImage}, q{ImTextureID userTextureID, in ImVec2 pMin, in ImVec2 pMax, in ImVec2 uvMin=ImVec2(0, 0), in ImVec2 uvMax=ImVec2(1, 1), uint col=IM_COL32_WHITE}, ext: `C++`, aliases: [q{addImage}]},
			{q{void}, q{AddImageQuad}, q{ImTextureID userTextureID, in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, in ImVec2 uv1=ImVec2(0, 0), in ImVec2 uv2=ImVec2(1, 0), in ImVec2 uv3=ImVec2(1, 1), in ImVec2 uv4=ImVec2(0, 1), uint col=IM_COL32_WHITE}, ext: `C++`, aliases: [q{addImageQuad}]},
			{q{void}, q{AddImageRounded}, q{ImTextureID userTextureID, in ImVec2 pMin, in ImVec2 pMax, in ImVec2 uvMin, in ImVec2 uvMax, uint col, float rounding, ImDrawFlags_ flags=0}, ext: `C++`, aliases: [q{addImageRounded}]},
			{q{void}, q{PathArcTo}, q{in ImVec2 centre, float radius, float aMin, float aMax, int numSegments=0}, ext: `C++`, aliases: [q{pathArcTo}]},
			{q{void}, q{PathArcToFast}, q{in ImVec2 centre, float radius, int aMinOf12, int aMaxOf12}, ext: `C++`, aliases: [q{pathArcToFast}]},
			{q{void}, q{PathEllipticalArcTo}, q{in ImVec2 centre, in ImVec2 radius, float rot, float aMin, float aMax, int numSegments=0}, ext: `C++`, aliases: [q{pathEllipticalArcTo}]},
			{q{void}, q{PathBezierCubicCurveTo}, q{in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, int numSegments=0}, ext: `C++`, aliases: [q{pathBezierCubicCurveTo}]},
			{q{void}, q{PathBezierQuadraticCurveTo}, q{in ImVec2 p2, in ImVec2 p3, int numSegments=0}, ext: `C++`, aliases: [q{pathBezierQuadraticCurveTo}]},
			{q{void}, q{PathRect}, q{in ImVec2 rectMin, in ImVec2 rectMax, float rounding=0f, ImDrawFlags_ flags=0}, ext: `C++`, aliases: [q{pathRect}]},
			{q{void}, q{AddCallback}, q{ImDrawCallback callback, void* userdata, size_t userdataSize=0}, ext: `C++`, aliases: [q{addCallback}]},
			{q{void}, q{AddDrawCmd}, q{}, ext: `C++`, aliases: [q{addDrawCmd}]},
			{q{ImDrawList*}, q{CloneOutput}, q{}, ext: `C++`, attr: q{const}, aliases: [q{cloneOutput}]},
			{q{void}, q{PrimReserve}, q{int idxCount, int vtxCount}, ext: `C++`, aliases: [q{primReserve}]},
			{q{void}, q{PrimUnreserve}, q{int idxCount, int vtxCount}, ext: `C++`, aliases: [q{primUnReserve}]},
			{q{void}, q{PrimRect}, q{in ImVec2 a, in ImVec2 b, uint col}, ext: `C++`, aliases: [q{primRect}]},
			{q{void}, q{PrimRectUV}, q{in ImVec2 a, in ImVec2 b, in ImVec2 uvA, in ImVec2 uvB, uint col}, ext: `C++`, aliases: [q{primRectUV}]},
			{q{void}, q{PrimQuadUV}, q{in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 d, in ImVec2 uvA, in ImVec2 uvB, in ImVec2 uvC, in ImVec2 uvD, uint col}, ext: `C++`, aliases: [q{primQuadUV}]},
			{q{void}, q{_ResetForNewFrame}, q{}, ext: `C++`, aliases: [q{resetForNewFrame}]},
			{q{void}, q{_ClearFreeMemory}, q{}, ext: `C++`, aliases: [q{clearFreeMemory}]},
			{q{void}, q{_PopUnusedDrawCmd}, q{}, ext: `C++`, aliases: [q{popUnusedDrawCmd}]},
			{q{void}, q{_TryMergeDrawCmds}, q{}, ext: `C++`, aliases: [q{tryMergeDrawCmds}]},
			{q{void}, q{_OnChangedClipRect}, q{}, ext: `C++`, aliases: [q{onChangedClipRect}]},
			{q{void}, q{_OnChangedTextureID}, q{}, ext: `C++`, aliases: [q{onChangedTextureID}]},
			{q{void}, q{_OnChangedVtxOffset}, q{}, ext: `C++`, aliases: [q{onChangedVtxOffset}]},
			{q{void}, q{_SetTextureID}, q{ImTextureID textureID}, ext: `C++`, aliases: [q{setTextureID}]},
			{q{int}, q{_CalcCircleAutoSegmentCount}, q{float radius}, ext: `C++`, attr: q{const}, aliases: [q{calcCircleAutoSegmentCount}]},
			{q{void}, q{_PathArcToFastEx}, q{in ImVec2 centre, float radius, int aMinSample, int aMaxSample, int aStep}, ext: `C++`, aliases: [q{pathArcToFastEx}]},
			{q{void}, q{_PathArcToN}, q{in ImVec2 centre, float radius, float aMin, float aMax, int numSegments}, ext: `C++`, aliases: [q{pathArcToN}]},
		];
		return ret;
	}()));
	
	alias CmdBuffer = cmdBuffer;
	alias IdxBuffer = idxBuffer;
	alias VtxBuffer = vtxBuffer;
	alias Flags = flags;
	
	alias _VtxCurrentIdx = vtxCurrentIdx;
	alias _Data = data;
	alias _VtxWritePtr = vtxWritePtr;
	alias _IdxWritePtr = idxWritePtr;
	alias _Path = path;
	alias _CmdHeader = cmdHeader;
	alias _Splitter = splitter;
	alias _ClipRectStack = clipRectStack;
	alias _TextureIdStack = textureIDStack;
	alias _CallbacksDataBuf = callbacksDataBuf;
	alias _FringeScale = fringeScale;
	alias _OwnerName = ownerName;
	
	alias GetClipRectMin = getClipRectMin;
	alias GetClipRectMax = getClipRectMax;
	alias PathClear = pathClear;
	alias PathLineTo = pathLineTo;
	alias PathLineToMergeDuplicate = pathLineToMergeDuplicate;
	alias PathFillConvex = pathFillConvex;
	alias PathFillConcave = pathFillConcave;
	alias PathStroke = pathStroke;
	alias ChannelsSplit = channelsSplit;
	alias ChannelsMerge = channelsMerge;
	alias ChannelsSetCurrent = channelsSetCurrent;
	alias PrimWriteVtx = primWriteVtx;
	alias PrimWriteIdx = primWriteIdx;
	alias PrimVtx = primVtx;
}

extern(C++) struct ImDrawData{
	bool valid;
	int cmdListsCount;
	int totalIdxCount;
	int totalVtxCount;
	ImVector!(ImDrawList*) cmdLists;
	ImVec2 displayPos;
	ImVec2 displaySize;
	ImVec2 framebufferScale;
	ImGuiViewport* ownerViewport;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{void}, q{AddDrawList}, q{ImDrawList* drawList}, ext: `C++`, aliases: [q{addDrawList}]},
			{q{void}, q{DeIndexAllBuffers}, q{}, ext: `C++`, aliases: [q{deIndexAllBuffers}]},
			{q{void}, q{ScaleClipRects}, q{in ImVec2 fbScale}, ext: `C++`, aliases: [q{scaleClipRects}]},
		];
		return ret;
	}()));
	
	alias Valid = valid;
	alias CmdListsCount = cmdListsCount;
	alias TotalIdxCount = totalIdxCount;
	alias TotalVtxCount = totalVtxCount;
	alias CmdLists = cmdLists;
	alias DisplayPos = displayPos;
	alias DisplaySize = displaySize;
	alias FramebufferScale = framebufferScale;
	alias OwnerViewport = ownerViewport;
}

extern(C++) struct ImFontConfig{
	void* fontData;
	int fontDataSize;
	bool fontDataOwnedByAtlas = true;
	int fontNo;
	float sizePixels = 0f;
	int oversampleH = 2;
	int oversampleV = 1;
	bool pixelSnapH;
	ImVec2 glyphExtraSpacing;
	ImVec2 glyphOffset;
	const(ImWChar)* glyphRanges;
	float glyphMinAdvanceX = 0f;
	float glyphMaxAdvanceX = float.max;
	bool mergeMode;
	uint fontBuilderFlags;
	float rasteriserMultiply = 1f;
	float rasteriserDensity = 1f;
	ImWChar ellipsisChar = cast(ImWChar)-1;
	
	char[40] name = '\x00';
	ImFont* dstFont;
	
	alias FontData = fontData;
	alias FontDataSize = fontDataSize;
	alias FontDataOwnedByAtlas = fontDataOwnedByAtlas;
	alias FontNo = fontNo;
	alias SizePixels = sizePixels;
	alias OversampleH = oversampleH;
	alias OversampleV = oversampleV;
	alias PixelSnapH = pixelSnapH;
	alias GlyphExtraSpacing = glyphExtraSpacing;
	alias GlyphOffset = glyphOffset;
	alias GlyphRanges = glyphRanges;
	alias GlyphMinAdvanceX = glyphMinAdvanceX;
	alias GlyphMaxAdvanceX = glyphMaxAdvanceX;
	alias MergeMode = mergeMode;
	alias FontBuilderFlags = fontBuilderFlags;
	alias RasteriserMultiply = rasteriserMultiply;
	alias RasterizerMultiply = rasteriserMultiply;
	alias rasterizerMultiply = rasteriserMultiply;
	alias RasteriserDensity = rasteriserDensity;
	alias RasterizerDensity = rasteriserDensity;
	alias rasterizerDensity = rasteriserDensity;
	alias EllipsisChar = ellipsisChar;
	
	alias Name = name;
	alias DstFont = dstFont;
}

extern(C++) struct ImFontGlyph{
	mixin(bitfields!(
		uint, q{coloured}, 1,
		uint, q{visible}, 1,
		uint, q{codepoint}, 30,
	));
	float advanceX = 0f;
	float x0 = 0f, y0 = 0f, x1 = 0f, y1 = 0f;
	float u0 = 0f, v0 = 0f, u1 = 0f, v1 = 0f;
	
	alias Coloured = coloured;
	alias Colored = coloured;
	alias colored = coloured;
	alias Visible = visible;
	alias Codepoint = codepoint;
	alias AdvanceX = advanceX;
	alias X0 = x0;
	alias Y0 = y0;
	alias X1 = x1;
	alias Y1 = y1;
	alias U0 = u0;
	alias V0 = v0;
	alias U1 = u1;
	alias V1 = v1;
}

extern(C++) struct ImFontGlyphRangesBuilder{
	ImVector!(uint) usedChars;
	
	nothrow @nogc{
		void clear(){
			enum int sizeInBytes = (IM_UNICODE_CODEPOINT_MAX + 1) / 8;
			usedChars.resize(sizeInBytes / uint.sizeof);
			usedChars.data[0..sizeInBytes] = 0;
		}
		bool getBit(size_t n) const => (usedChars[cast(int)(n >> 5)] & (1U << (n & 31))) != 0;
		void setBit(size_t n){ usedChars[cast(int)(n >> 5)] |= 1U << (n & 31); }
		void addChar(ImWChar c){ setBit(c); }
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{AddText}, q{const(char)* text, const(char)* textEnd=null}, ext: `C++`, aliases: [q{addText}]},
			{q{void}, q{AddRanges}, q{const(ImWChar)* ranges}, ext: `C++`, aliases: [q{addRanges}]},
			{q{void}, q{BuildRanges}, q{ImVector!(ImWChar)* outRanges}, ext: `C++`, aliases: [q{buildRanges}]},
		];
		return ret;
	}()));
	
	alias UsedChars = usedChars;
	
	alias Clear = clear;
	alias GetBit = getBit;
	alias SetBit = setBit;
	alias AddChar = addChar;
}

extern(C++) struct ImFontAtlasCustomRect{
	ushort width, height;
	ushort x = 0xFFFF, y = 0xFFFF;
	uint glyphID;
	float glyphAdvanceX = 0f;
	ImVec2 glyphOffset;
	ImFont* font;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{bool}, q{IsPacked}, q{}, ext: `C++`, attr: q{const}, aliases: [q{isPacked}]},
		];
		return ret;
	}()));
	
	alias Width = width;
	alias Height = height;
	alias X = x;
	alias Y = y;
	alias GlyphID = glyphID;
	alias GlyphAdvanceX = glyphAdvanceX;
	alias GlyphOffset = glyphOffset;
	alias Font = font;
}

extern(C++) struct ImFontAtlas{
	ImFontAtlasFlags_ flags;
	ImTextureID texID;
	int texDesiredWidth;
	int texGlyphPadding;
	bool locked;
	void* userData;
	
	bool texReady;
	bool texPixelsUseColours;
	ubyte* texPixelsAlpha8;
	uint* texPixelsRGBA32;
	int texWidth;
	int texHeight;
	ImVec2 texUVScale;
	ImVec2 texUVWhitePixel;
	ImVector!(ImFont*) fonts;
	ImVector!(ImFontAtlasCustomRect) customRects;
	ImVector!(ImFontConfig) configData;
	ImVec4[IM_DRAWLIST_TEX_LINES_WIDTH_MAX+1] texUVLines;
	
	const(ImFontBuilderIO)* fontBuilderIO;
	uint fontBuilderFlags;
	
	int packIDMouseCursors;
	int packIDLines;
	
	nothrow @nogc{
		bool isBuilt() const pure => fonts.size > 0 && texReady;
		void setTexID(ImTextureID id) pure{ texID = id; }
		ImFontAtlasCustomRect* getCustomRectByIndex(int index) pure in(index >= 0) => &customRects[index];
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{ImFont*}, q{AddFont}, q{const(ImFontConfig)* fontCfg}, ext: `C++`, aliases: [q{addFont}]},
			{q{ImFont*}, q{AddFontDefault}, q{const(ImFontConfig)* fontCfg=null}, ext: `C++`, aliases: [q{addFontDefault}]},
			{q{ImFont*}, q{AddFontFromFileTTF}, q{const(char)* filename, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWChar)* glyphRanges=null}, ext: `C++`, aliases: [q{addFontFromFileTTF}]},
			{q{ImFont*}, q{AddFontFromMemoryTTF}, q{void* fontData, int fontDataSize, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWChar)* glyphRanges=null}, ext: `C++`, aliases: [q{addFontFromMemoryTTF}]},
			{q{ImFont*}, q{AddFontFromMemoryCompressedTTF}, q{const(void)* compressedFontData, int compressedFontDataSize, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWChar)* glyphRanges=null}, ext: `C++`, aliases: [q{addFontFromMemoryCompressedTTF}]},
			{q{ImFont*}, q{AddFontFromMemoryCompressedBase85TTF}, q{const(char)* compressedFontDataBase85, float sizePixels, const(ImFontConfig)* fontCfg=null, const(ImWChar)* glyphRanges=null}, ext: `C++`, aliases: [q{addFontFromMemoryCompressedBase85TTF}]},
			{q{void}, q{ClearInputData}, q{}, ext: `C++`, aliases: [q{clearInputData}]},
			{q{void}, q{ClearTexData}, q{}, ext: `C++`, aliases: [q{clearTexData}]},
			{q{void}, q{ClearFonts}, q{}, ext: `C++`, aliases: [q{clearFonts}]},
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{bool}, q{Build}, q{}, ext: `C++`, aliases: [q{build}]},
			{q{void}, q{GetTexDataAsAlpha8}, q{ubyte** outPixels, int* outWidth, int* outHeight, int* outBytesPerPixel=null}, ext: `C++`, aliases: [q{getTexDataAsAlpha8}]},
			{q{void}, q{GetTexDataAsRGBA32}, q{ubyte** outPixels, int* outWidth, int* outHeight, int* outBytesPerPixel=null}, ext: `C++`, aliases: [q{getTexDataAsRGBA32}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesDefault}, q{}, ext: `C++`, aliases: [q{getGlyphRangesDefault}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesGreek}, q{}, ext: `C++`, aliases: [q{getGlyphRangesGreek}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesKorean}, q{}, ext: `C++`, aliases: [q{getGlyphRangesKorean}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesJapanese}, q{}, ext: `C++`, aliases: [q{getGlyphRangesJapanese}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesChineseFull}, q{}, ext: `C++`, aliases: [q{getGlyphRangesChineseFull}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesChineseSimplifiedCommon}, q{}, ext: `C++`, aliases: [q{getGlyphRangesChineseSimplifiedCommon}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesCyrillic}, q{}, ext: `C++`, aliases: [q{getGlyphRangesCyrillic}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesThai}, q{}, ext: `C++`, aliases: [q{getGlyphRangesThai}]},
			{q{const(ImWChar)*}, q{GetGlyphRangesVietnamese}, q{}, ext: `C++`, aliases: [q{getGlyphRangesVietnamese}]},
			{q{int}, q{AddCustomRectRegular}, q{int width, int height}, ext: `C++`, aliases: [q{addCustomRectRegular}]},
			{q{int}, q{AddCustomRectFontGlyph}, q{ImFont* font, ImWChar id, int width, int height, float advanceX, in ImVec2 offset=ImVec2(0, 0)}, ext: `C++`, aliases: [q{addCustomRectFontGlyph}]},
			{q{void}, q{CalcCustomRectUV}, q{const(ImFontAtlasCustomRect)* rect, ImVec2* outUVMin, ImVec2* outUVMax}, ext: `C++`, attr: q{const}, aliases: [q{calcCustomRectUV}]},
			{q{bool}, q{GetMouseCursorTexData}, q{ImGuiMouseCursor_ cursor, ImVec2* outOffset, ImVec2* outSize, ImVec2*/+ARRAY?+/ outUVBorder, ImVec2*/+ARRAY?+/ outUVFill}, ext: `C++`, aliases: [q{getMouseCursorTexData}]},
		];
		return ret;
	}()));
	
	alias Flags = flags;
	alias TexID = texID;
	alias TexDesiredWidth = texDesiredWidth;
	alias TexGlyphPadding = texGlyphPadding;
	alias Locked = locked;
	alias UserData = userData;
	
	alias TexReady = texReady;
	alias TexPixelsUseColours = texPixelsUseColours;
	alias TexPixelsUseColors = texPixelsUseColours;
	alias texPixelsUseColors = texPixelsUseColours;
	alias TexPixelsAlpha8 = texPixelsAlpha8;
	alias TexPixelsRGBA32 = texPixelsRGBA32;
	alias TexWidth = texWidth;
	alias TexHeight = texHeight;
	alias TexUvScale = texUVScale;
	alias TexUvWhitePixel = texUVWhitePixel;
	alias Fonts = fonts;
	alias CustomRects = customRects;
	alias ConfigData = configData;
	alias TexUvLines = texUVLines;
	
	alias FontBuilderIO = fontBuilderIO;
	alias FontBuilderFlags = fontBuilderFlags;
	
	alias PackIdMouseCursors = packIDMouseCursors;
	alias PackIdLines = packIDLines;
	
	alias IsBuilt = isBuilt;
	alias SetTexID = setTexID;
	alias GetCustomRectByIndex = getCustomRectByIndex;
}

extern(C++) struct ImFont{
	ImVector!(float) indexAdvanceX;
	float fallbackAdvanceX = 0f;
	float fontSize = 0f;
	
	ImVector!(ImWChar) indexLookup;
	ImVector!(ImFontGlyph) glyphs;
	const(ImFontGlyph)* fallbackGlyph;
	
	ImFontAtlas* containerAtlas;
	const(ImFontConfig)* configData;
	short configDataCount;
	ImWChar fallbackChar = '\u0000';
	ImWChar ellipsisChar = '\u0000';
	short ellipsisCharCount;
	float ellipsisWidth = 0f;
	float ellipsisCharStep = 0f;
	bool dirtyLookupTables;
	float scale = 0f;
	float ascent = 0f, descent = 0f;
	int metricsTotalSurface;
	ubyte[(IM_UNICODE_CODEPOINT_MAX+1)/4096/8] used4KPagesMap;
	
	nothrow @nogc{
		float getCharAdvance(ImWChar c) const pure => (cast(int)c < indexAdvanceX.size) ? indexAdvanceX[cast(int)c] : fallbackAdvanceX;
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{const(ImFontGlyph)*}, q{FindGlyph}, q{ImWChar c}, ext: `C++`, attr: q{const}, aliases: [q{findGlyph}]},
			{q{const(ImFontGlyph)*}, q{FindGlyphNoFallback}, q{ImWChar c}, ext: `C++`, attr: q{const}, aliases: [q{findGlyphNoFallback}]},
			{q{bool}, q{IsLoaded}, q{}, ext: `C++`, attr: q{const}, aliases: [q{isLoaded}]},
			{q{const(char)*}, q{GetDebugName}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getDebugName}]},
			{q{ImVec2}, q{CalcTextSizeA}, q{float size, float maxWidth, float wrapWidth, const(char)* textBegin, const(char)* textEnd=null, const(char)** remaining=null}, ext: `C++`, attr: q{const}, aliases: [q{calcTextSizeA}]},
			{q{const(char)*}, q{CalcWordWrapPositionA}, q{float scale, const(char)* text, const(char)* textEnd, float wrapWidth}, ext: `C++`, attr: q{const}, aliases: [q{calcWordWrapPositionA}]},
			{q{void}, q{RenderChar}, q{ImDrawList* drawList, float size, in ImVec2 pos, uint col, ImWChar c}, ext: `C++`, attr: q{const}, aliases: [q{renderChar}]},
			{q{void}, q{RenderText}, q{ImDrawList* drawList, float size, in ImVec2 pos, uint col, in ImVec4 clipRect, const(char)* textBegin, const(char)* textEnd, float wrapWidth=0f, bool cpuFineClip=false}, ext: `C++`, attr: q{const}, aliases: [q{renderText}]},
			{q{void}, q{BuildLookupTable}, q{}, ext: `C++`, aliases: [q{buildLookupTable}]},
			{q{void}, q{ClearOutputData}, q{}, ext: `C++`, aliases: [q{clearOutputData}]},
			{q{void}, q{GrowIndex}, q{int newSize}, ext: `C++`, aliases: [q{growIndex}]},
			{q{void}, q{AddGlyph}, q{const(ImFontConfig)* srcCfg, ImWChar c, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1, float advanceX}, ext: `C++`, aliases: [q{addGlyph}]},
			{q{void}, q{AddRemapChar}, q{ImWChar dst, ImWChar src, bool overwriteDst=true}, ext: `C++`, aliases: [q{addRemapChar}]},
			{q{void}, q{SetGlyphVisible}, q{ImWChar c, bool visible}, ext: `C++`, aliases: [q{setGlyphVisible}]},
			{q{bool}, q{IsGlyphRangeUnused}, q{uint cBegin, uint cLast}, ext: `C++`, aliases: [q{isGlyphRangeUnused}]},
		];
		return ret;
	}()));
	
	alias IndexAdvanceX = indexAdvanceX;
	alias FallbackAdvanceX = fallbackAdvanceX;
	alias FontSize = fontSize;
	
	alias IndexLookup = indexLookup;
	alias Glyphs = glyphs;
	alias FallbackGlyph = fallbackGlyph;
	
	alias ContainerAtlas = containerAtlas;
	alias ConfigData = configData;
	alias ConfigDataCount = configDataCount;
	alias FallbackChar = fallbackChar;
	alias EllipsisChar = ellipsisChar;
	alias EllipsisCharCount = ellipsisCharCount;
	alias EllipsisWidth = ellipsisWidth;
	alias EllipsisCharStep = ellipsisCharStep;
	alias DirtyLookupTables = dirtyLookupTables;
	alias Scale = scale;
	alias Ascent = ascent;
	alias Descent = descent;
	alias MetricsTotalSurface = metricsTotalSurface;
	alias Used4kPagesMap = used4KPagesMap;
	
	alias GetCharAdvance = getCharAdvance;
}

extern(C++) struct ImGuiViewport{
	ImGuiID id;
	ImGuiViewportFlags_ flags;
	ImVec2 pos;
	ImVec2 size;
	ImVec2 workPos;
	ImVec2 workSize;
	
	void* platformHandle;
	void* platformHandleRaw;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{ImVec2}, q{GetCenter}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getCentre}, q{getCenter}, q{GetCentre}]},
			{q{ImVec2}, q{GetWorkCenter}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getWorkCentre}, q{getWorkCenter}, q{GetWorkCentre}]},
		];
		return ret;
	}()));
	
	alias ID = id;
	alias Flags = flags;
	alias Pos = pos;
	alias Size = size;
	alias WorkPos = workPos;
	alias WorkSize = workSize;
	
	alias PlatformHandle = platformHandle;
	alias PlatformHandleRaw = platformHandleRaw;
}

extern(C++) struct ImGuiPlatformIO{
	private alias PlatformGetClipboardTextFnFn = extern(C++) const(char)* function(ImGuiContext* ctx) nothrow @nogc;
	PlatformGetClipboardTextFnFn platformGetClipboardTextFn;
	private alias PlatformSetClipboardTextFnFn = extern(C++) void function(ImGuiContext* ctx, const(char)* text) nothrow @nogc;
	PlatformSetClipboardTextFnFn platformSetClipboardTextFn;
	void* platformClipboardUserData;
	private alias PlatformOpenInShellFnFn = extern(C++) bool function(ImGuiContext* ctx, const(char)* path) nothrow @nogc;
	PlatformOpenInShellFnFn platformOpenInShellFn;
	
	void* platformOpenInShellUserData;
	private alias PlatformSetIMEDataFnFn = extern(C++) void function(ImGuiContext* ctx, ImGuiViewport* viewport, ImGuiPlatformImeData* data) nothrow @nogc;
	PlatformSetIMEDataFnFn platformSetIMEDataFn;
	
	void* platformIMEUserData;
	
	ImWChar platformLocaleDecimalPoint = '\u0000';
	
	void* rendererRenderState;
	
	alias Platform_GetClipboardTextFn = platformGetClipboardTextFn;
	alias Platform_SetClipboardTextFn = platformSetClipboardTextFn;
	alias Platform_ClipboardUserData = platformClipboardUserData;
	alias Platform_OpenInShellFn = platformOpenInShellFn;
	
	alias Platform_OpenInShellUserData = platformOpenInShellUserData;
	alias Platform_SetImeDataFn = platformSetIMEDataFn;
	
	alias Platform_ImeUserData = platformIMEUserData;
	
	alias Platform_LocaleDecimalPoint = platformLocaleDecimalPoint;
	
	alias Renderer_RenderState = rendererRenderState;
}

extern(C++) struct ImGuiPlatformImeData{
	bool wantVisible;
	ImVec2 inputPos;
	float inputLineHeight = 0f;
	
	alias WantVisible = wantVisible;
	alias InputPos = inputPos;
	alias InputLineHeight = inputLineHeight;
}
alias ImGuiPlatformIMEData = ImGuiPlatformImeData;

private extern(C++) nothrow{
	alias StrGetterFn = const(char)* function(void* userData, int idx);
	alias ValuesGetterFn = float function(void* data, int idx);
	alias OldCallbackFn = bool function(void* userData, int idx, const(char)** outText);
}
//imgui_internal.h:

extern(C++) struct ImGuiInputTextDeactivateData;

extern(C++) struct ImGuiTableColumnsSettings;

extern(C++) struct ImVec1{
	float x = 0f;
}

extern(C++) struct ImVec2ih{
	short x, y;
}
alias ImVec2IH = ImVec2ih;

extern(C++) struct ImRect{
	ImVec2 min;
	ImVec2 max;
	
	nothrow @nogc{
		ImVec2 getCentre() const pure @safe => ImVec2((min.x + max.x) * 0.5f, (min.y + max.y) * 0.5f);
		ImVec2 getSize() const pure @safe => ImVec2(max.x - min.x, max.y - min.y);
		float getWidth() const pure @safe => max.x - min.x;
		float getHeight() const pure @safe => max.y - min.y;
		float getArea() const pure @safe => (max.x - min.x) * (max.y - min.y);
		ImVec2 getTL() const pure @safe => min;
		ImVec2 getTR() const pure @safe => ImVec2(max.x, min.y);
		ImVec2 getBL() const pure @safe => ImVec2(min.x, max.y);
		ImVec2 getBR() const pure @safe => max;
		bool contains(ImVec2 p) const pure @safe => p.x >= min.x && p.y >= min.y && p.x < max.x && p.y < max.y;
		bool contains(ImRect r) const pure @safe => r.min.x >= min.x && r.min.y >= min.y && r.max.x <= max.x && r.max.y <= max.y;
		bool containsWithPad(ImVec2 p, ImVec2 pad) const pure @safe => p.x >= min.x - pad.x && p.y >= min.y - pad.y && p.x < max.x + pad.x && p.y < max.y + pad.y;
		bool overlaps(ImRect r) const pure @safe => r.min.y < max.y && r.max.y > min.y && r.min.x < max.x && r.max.x > min.x;
		void add(ImVec2 p) pure @safe{ min = ImVec2(.min(min.x, p.x), .min(min.y, p.y)); max = ImVec2(.max(max.x, p.x), .max(max.y, p.y)); }
		void add(ImRect r) pure @safe{ min = ImVec2(.min(min.x, r.min.x), .min(min.y, r.min.y)); max = ImVec2(.max(max.x, r.max.x), .max(max.y, r.max.y)); }
		void expand(const(float) amount) pure @safe{ min.x -= amount; min.y -= amount; max.x += amount; max.y += amount; }
		void expand(ImVec2 amount) pure @safe{ min.x -= amount.x; min.y -= amount.y; max.x += amount.x; max.y += amount.y; }
		void translate(ImVec2 d) pure @safe{ min += d; max += d; }
		void translateX(float dx) pure @safe{ min.x += dx; max.x += dx; }
		void translateY(float dy) pure @safe{ min.y += dy; max.y += dy; }
	}
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ClipWith}, q{ImRect r}, ext: `C++`, aliases: [q{clipWith}]},
			{q{void}, q{ClipWithFull}, q{ImRect r}, ext: `C++`, aliases: [q{clipWithFull}]},
			{q{void}, q{Floor}, q{}, ext: `C++`, aliases: [q{floor}]},
			{q{bool}, q{IsInverted}, q{}, ext: `C++`, attr: q{const}, aliases: [q{isInverted}]},
			{q{ImVec4}, q{ToVec4}, q{}, ext: `C++`, attr: q{const}, aliases: [q{toVec4}]},
		];
		return ret;
	}()));
	
	alias Min = min;
	alias Max = max;
	
	alias GetCentre = getCentre;
	alias GetCenter = getCentre;
	alias getCenter = getCentre;
	alias GetSize = getSize;
	alias GetWidth = getWidth;
	alias GetHeight = getHeight;
	alias GetArea = getArea;
	alias GetTL = getTL;
	alias GetTR = getTR;
	alias GetBL = getBL;
	alias GetBR = getBR;
	alias Contains = contains;
	alias Contains = contains;
	alias ContainsWithPad = containsWithPad;
	alias Overlaps = overlaps;
	alias Add = add;
	alias Add = add;
	alias Expand = expand;
	alias Expand = expand;
	alias Translate = translate;
	alias TranslateX = translateX;
	alias TranslateY = translateY;
}

extern(C++) struct ImBitVector{
	ImVector!(uint) storage;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Create}, q{int sz}, ext: `C++`, aliases: [q{create}]},
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{bool}, q{TestBit}, q{int n}, ext: `C++`, attr: q{const}, aliases: [q{testBit}]},
			{q{void}, q{SetBit}, q{int n}, ext: `C++`, aliases: [q{setBit}]},
			{q{void}, q{ClearBit}, q{int n}, ext: `C++`, aliases: [q{clearBit}]},
		];
		return ret;
	}()));
	
	alias Storage = storage;
}

extern(C++) struct ImSpan(T){
	T* data;
	T* dataEnd;
	
	nothrow @nogc{
		this(T* data, int size){ this.data = data; this.dataEnd = data + size; }
		this(T* data, T* dataEnd) pure @safe{ this.data = data; this.dataEnd = dataEnd; }
		
		void set(T* data, int size){ data = data; dataEnd = data + size; }
		void set(T* data, T* dataEnd) pure @safe{ data = data; dataEnd = dataEnd; }
		int size() const pure @trusted => cast(int)cast(ptrdiff_t)(dataEnd - data);
		int sizeInBytes() const pure @trusted => cast(int)cast(ptrdiff_t)(dataEnd - data) * cast(int)T.sizeof;
		ref T opIndex(int i) out(p; &p >= data && &p < dataEnd) => *(data + i);
		ref const(T) opIndex(int i) const out(p; &p >= data && &p < dataEnd) => *(data + i);
		
		T* begin() pure @safe => data;
		const(T)* begin() const pure @safe => data;
		T* end() pure @safe => dataEnd;
		const(T)* end() const pure @safe => dataEnd;
		
		int indexFromPtr(const(T)* it) const pure @trusted
		in(it >= data && it < dataEnd) =>
			cast(int)cast(ptrdiff_t)(it - data);
	}
	
	alias Data = data;
	alias DataEnd = dataEnd;
	
	alias size_in_bytes = sizeInBytes;
	
	alias index_from_ptr = indexFromPtr;
}

extern(C++) struct ImDrawListSharedData{
	ImVec2 texUVWhitePixel;
	ImFont* font;
	float fontSize = 0f;
	float fontScale = 0f;
	float curveTessellationTol = 0f;
	float circleSegmentMaxError = 0f;
	ImVec4 clipRectFullscreen;
	ImDrawListFlags_ initialFlags;
	
	ImVector!(ImVec2) tempBuffer;
	
	ImVec2[IM_DRAWLIST_ARCFAST_TABLE_SIZE] arcFastVtx;
	float arcFastRadiusCutoff = 0f;
	ubyte[64] circleSegmentCounts;
	const(ImVec4)* texUVLines;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{SetCircleTessellationMaxError}, q{float maxError}, ext: `C++`, aliases: [q{setCircleTessellationMaxError}]},
		];
		return ret;
	}()));
	
	alias TexUvWhitePixel = texUVWhitePixel;
	alias Font = font;
	alias FontSize = fontSize;
	alias FontScale = fontScale;
	alias CurveTessellationTol = curveTessellationTol;
	alias CircleSegmentMaxError = circleSegmentMaxError;
	alias ClipRectFullscreen = clipRectFullscreen;
	alias InitialFlags = initialFlags;
	
	alias TempBuffer = tempBuffer;
	
	alias ArcFastVtx = arcFastVtx;
	alias ArcFastRadiusCutoff = arcFastRadiusCutoff;
	alias CircleSegmentCounts = circleSegmentCounts;
	alias TexUvLines = texUVLines;
}

extern(C++) struct ImDrawDataBuilder{
	ImVector!(ImDrawList*)*[2] layers;
	ImVector!(ImDrawList*) layerData1;
	
	alias Layers = layers;
	alias LayerData1 = layerData1;
}

extern(C++) struct ImGuiDataVarInfo{
	ImGuiDataType_ type;
	uint count;
	uint offset;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void*}, q{GetVarPtr}, q{void* parent}, ext: `C++`, attr: q{const}, aliases: [q{getVarPtr}]},
		];
		return ret;
	}()));
	
	alias Type = type;
	alias Count = count;
	alias Offset = offset;
}

extern(C++) struct ImGuiDataTypeStorage{
	ubyte[8] data;
	
	alias Data = data;
}

extern(C++) struct ImGuiDataTypeInfo{
	size_t size;
	const(char)* name;
	const(char)* printFmt;
	const(char)* scanFmt;
	
	alias Size = size;
	alias Name = name;
	alias PrintFmt = printFmt;
	alias ScanFmt = scanFmt;
}
extern(C++) struct ImChunkStream(T){
	ImVector!byte buf;
	private enum headerSize = 4;
	
	nothrow @nogc{
		void clear(){ buf.clear(); }
		bool empty() const pure @safe => buf.size == 0;
		int size() const pure @safe => buf.size;
		T* allocChunk(size_t sz){
			enum alignment = 4U;
			sz = ((headerSize + sz) + (alignment-1)) & ~(alignment-1);
			int off = buf.size;
			buf.resize(off + cast(int)sz);
			(cast(int*)(buf.data + off))[0] = cast(int)sz;
			return cast(T*)(buf.data + off + headerSize);
		}
		T* begin() => !buf.data ? null : cast(T*)(buf.data + headerSize);
		T* nextChunk(T* p)
		in(p >= begin() && p < end()){
			p = cast(T*)((cast(byte*)p) + chunkSize(p));
			if(p == (end() + headerSize)) return null;
			assert(p < end());
			return p;
		}
		int chunkSize(const(T)* p) => (cast(const(int)*)p)[-1];
		T* end() => cast(T*)(buf.data + buf.size);
		int offsetFromPtr(const(T)* p) in(p >= begin() && p < end()) => cast(int)(cast(const(byte)*)p - buf.data);
		T* ptrFromOffset(int off) in(off >= 4 && off < buf.size) => cast(T*)(buf.data + off);
		void swap(ref ImChunkStream!T rhs){ rhs.buf.swap(buf); }
	}
	
	alias Buf = buf;
	
	alias alloc_chunk = allocChunk;
	alias next_chunk = nextChunk;
	alias chunk_size = chunkSize;
	alias offset_from_ptr = offsetFromPtr;
	alias ptr_from_offset = ptrFromOffset;
}
extern(C++) struct ImPool(T){
	ImVector!T buf;
	ImGuiStorage map;
	ImPoolIdx freeIdx;
	ImPoolIdx aliveCount;
	
	nothrow @nogc{
		~this(){ clear(); }
		T* getByKey(ImGuiID key){
			int idx = map.getInt(key, -1);
			return idx != -1 ? &buf[idx] : null;
		}
		T* getByIndex(ImPoolIdx n) => &buf[n];
		ImPoolIdx getIndex(const(T)* p) const pure @trusted
		in(p >= buf.data && p < buf.data + buf.size) =>
			cast(ImPoolIdx)(p - buf.data);
		T* getOrAddByKey(ImGuiID key){
			int* pIdx = map.getIntRef(key, -1);
			if(*pIdx != -1) return &buf[*pIdx];
			*pIdx = freeIdx;
			return add();
		}
		bool contains(const(T)* p) const pure @trusted => p >= buf.data && p < buf.data + buf.size;
		void clear(){
			for(int n = 0; n < map.data.size; n++){
				int idx = map.data[n].valI;
				if(idx != -1) buf[idx].destroy!false();
			}
			map.clear();
			buf.clear();
			freeIdx = aliveCount = 0;
		}
		T* add(){
			int idx = freeIdx;
			if(idx == buf.size){
				buf.resize(buf.size + 1);
				freeIdx++;
			}else{
				freeIdx = *cast(int*)&buf[idx];
			}
			emplace!T((cast(void*)&buf[idx])[0..T.sizeof]);
			aliveCount++;
			return &buf[idx];
		}
		void remove(ImGuiID key, const(T)* p){
			remove(key, getIndex(p));
		}
		void remove(ImGuiID key, ImPoolIdx idx){
			buf[idx].destroy!false();
			*cast(int*)&buf[idx] = freeIdx;
			freeIdx = idx; map.setInt(key, -1);
			aliveCount--;
		}
		void reserve(int capacity){
			buf.reserve(capacity);
			map.data.reserve(capacity);
		}
		
		int getAliveCount() const pure @safe => aliveCount;
		int getBufSize() const pure @safe => buf.size;
		int getMapSize() const pure @safe => map.data.size;
		T* tryGetMapData(ImPoolIdx n){
			int idx = map.data[n].valI;
			return idx == -1 ? null : getByIndex(idx);
		}
	}
	
	alias Buf = buf;
	alias Map = map;
	alias FreeIdx = freeIdx;
	alias AliveCount = aliveCount;
	
	alias GetByKey = getByKey;
	alias GetByIndex = getByIndex;
	alias GetIndex = getIndex;
	alias GetOrAddByKey = getOrAddByKey;
	alias Contains = contains;
	alias Clear = clear;
	alias Add = add;
	alias Remove = remove;
	alias Remove = remove;
	alias Reserve = reserve;
	
	alias GetAliveCount = getAliveCount;
	alias GetBufSize = getBufSize;
	alias GetMapSize = getMapSize;
	alias TryGetMapData = tryGetMapData;
}

extern(C++) struct ImGuiTextIndex{
	ImVector!(int) lineOffsets;
	int endOffset;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{clear}, q{}, ext: `C++`},
			{q{int}, q{size}, q{}, ext: `C++`},
			{q{const(char)*}, q{get_line_begin}, q{const(char)* base, int n}, ext: `C++`, aliases: [q{getLineBegin}]},
			{q{const(char)*}, q{get_line_end}, q{const(char)* base, int n}, ext: `C++`, aliases: [q{getLineEnd}]},
			{q{void}, q{append}, q{const(char)* base, int oldSize, int newSize}, ext: `C++`},
		];
		return ret;
	}()));
	
	alias LineOffsets = lineOffsets;
	alias EndOffset = endOffset;
}

extern(C++) struct ImGuiColorMod{
	ImGuiCol_ col;
	ImVec4 backupValue;
	
	alias Col = col;
	alias BackupValue = backupValue;
}
alias ImGuiColourMod = ImGuiColorMod;

extern(C++) struct ImGuiStyleMod{
	ImGuiStyleVar_ varIdx;
	extern(C++) union{
		int[2] backupInt;
		float[2] backupFloat;
		
		alias BackupInt = backupInt;
		alias BackupFloat = backupFloat;
	}
	
	alias VarIdx = varIdx;
}

extern(C++) struct ImGuiComboPreviewData{
	ImRect previewRect;
	ImVec2 backupCursorPos;
	ImVec2 backupCursorMaxPos;
	ImVec2 backupCursorPosPrevLine;
	float backupPrevLineTextBaseOffset = 0f;
	ImGuiLayoutType_ backupLayout;
	
	alias PreviewRect = previewRect;
	alias BackupCursorPos = backupCursorPos;
	alias BackupCursorMaxPos = backupCursorMaxPos;
	alias BackupCursorPosPrevLine = backupCursorPosPrevLine;
	alias BackupPrevLineTextBaseOffset = backupPrevLineTextBaseOffset;
	alias BackupLayout = backupLayout;
}

extern(C++) struct ImGuiGroupData{
	ImGuiID windowID;
	ImVec2 backupCursorPos;
	ImVec2 backupCursorMaxPos;
	ImVec2 backupCursorPosPrevLine;
	ImVec1 backupIndent;
	ImVec1 backupGroupOffset;
	ImVec2 backupCurrLineSize;
	float backupCurrLineTextBaseOffset = 0f;
	ImGuiID backupActiveIDIsAlive;
	bool backupActiveIDPreviousFrameIsAlive;
	bool backupHoveredIDIsAlive;
	bool backupIsSameLine;
	bool emitItem;
	
	alias WindowID = windowID;
	alias BackupCursorPos = backupCursorPos;
	alias BackupCursorMaxPos = backupCursorMaxPos;
	alias BackupCursorPosPrevLine = backupCursorPosPrevLine;
	alias BackupIndent = backupIndent;
	alias BackupGroupOffset = backupGroupOffset;
	alias BackupCurrLineSize = backupCurrLineSize;
	alias BackupCurrLineTextBaseOffset = backupCurrLineTextBaseOffset;
	alias BackupActiveIdIsAlive = backupActiveIDIsAlive;
	alias BackupActiveIdPreviousFrameIsAlive = backupActiveIDPreviousFrameIsAlive;
	alias BackupHoveredIdIsAlive = backupHoveredIDIsAlive;
	alias BackupIsSameLine = backupIsSameLine;
	alias EmitItem = emitItem;
}

extern(C++) struct ImGuiMenuColumns{
	uint totalWidth;
	uint nextTotalWidth;
	ushort spacing;
	ushort offsetIcon;
	ushort offsetLabel;
	ushort offsetShortcut;
	ushort offsetMark;
	ushort[4] widths;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Update}, q{float spacing, bool windowReappearing}, ext: `C++`, aliases: [q{update}]},
			{q{float}, q{DeclColumns}, q{float wIcon, float wLabel, float wShortcut, float wMark}, ext: `C++`, aliases: [q{declColumns}]},
			{q{void}, q{CalcNextTotalWidth}, q{bool updateOffsets}, ext: `C++`, aliases: [q{calcNextTotalWidth}]},
		];
		return ret;
	}()));
	
	alias TotalWidth = totalWidth;
	alias NextTotalWidth = nextTotalWidth;
	alias Spacing = spacing;
	alias OffsetIcon = offsetIcon;
	alias OffsetLabel = offsetLabel;
	alias OffsetShortcut = offsetShortcut;
	alias OffsetMark = offsetMark;
	alias Widths = widths;
}

extern(C++) struct ImGuiInputTextDeactivatedState{
	ImGuiID id;
	ImVector!(char) textA;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ClearFreeMemory}, q{}, ext: `C++`, aliases: [q{clearFreeMemory}]},
		];
		return ret;
	}()));
	
	alias ID = id;
	alias TextA = textA;
}

extern(C++) struct ImGuiInputTextState{
	ImGuiContext* ctx;
	void* stb;
	ImGuiID id;
	int curLenA;
	ImVector!(char) textA;
	ImVector!(char) initialTextA;
	ImVector!(char) callbackTextBackup;
	int bufCapacityA;
	ImVec2 scroll;
	float cursorAnim = 0f;
	bool cursorFollow;
	bool selectedAllMouseLock;
	bool edited;
	ImGuiInputTextFlags_ flags;
	bool reloadUserBuf;
	int reloadSelectionStart;
	int reloadSelectionEnd;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ClearText}, q{}, ext: `C++`, aliases: [q{clearText}]},
			{q{void}, q{ClearFreeMemory}, q{}, ext: `C++`, aliases: [q{clearFreeMemory}]},
			{q{void}, q{OnKeyPressed}, q{int key}, ext: `C++`, aliases: [q{onKeyPressed}]},
			{q{void}, q{OnCharPressed}, q{uint c}, ext: `C++`, aliases: [q{onCharPressed}]},
			{q{void}, q{CursorAnimReset}, q{}, ext: `C++`, aliases: [q{cursorAnimReset}]},
			{q{void}, q{CursorClamp}, q{}, ext: `C++`, aliases: [q{cursorClamp}]},
			{q{bool}, q{HasSelection}, q{}, ext: `C++`, attr: q{const}, aliases: [q{hasSelection}]},
			{q{void}, q{ClearSelection}, q{}, ext: `C++`, aliases: [q{clearSelection}]},
			{q{int}, q{GetCursorPos}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getCursorPos}]},
			{q{int}, q{GetSelectionStart}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getSelectionStart}]},
			{q{int}, q{GetSelectionEnd}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getSelectionEnd}]},
			{q{void}, q{SelectAll}, q{}, ext: `C++`, aliases: [q{selectAll}]},
			{q{void}, q{ReloadUserBufAndSelectAll}, q{}, ext: `C++`, aliases: [q{reloadUserBufAndSelectAll}]},
			{q{void}, q{ReloadUserBufAndKeepSelection}, q{}, ext: `C++`, aliases: [q{reloadUserBufAndKeepSelection}]},
			{q{void}, q{ReloadUserBufAndMoveToEnd}, q{}, ext: `C++`, aliases: [q{reloadUserBufAndMoveToEnd}]},
		];
		return ret;
	}()));
	
	alias Ctx = ctx;
	alias Stb = stb;
	alias ID = id;
	alias CurLenA = curLenA;
	alias TextA = textA;
	alias InitialTextA = initialTextA;
	alias CallbackTextBackup = callbackTextBackup;
	alias BufCapacityA = bufCapacityA;
	alias Scroll = scroll;
	alias CursorAnim = cursorAnim;
	alias CursorFollow = cursorFollow;
	alias SelectedAllMouseLock = selectedAllMouseLock;
	alias Edited = edited;
	alias Flags = flags;
	alias ReloadUserBuf = reloadUserBuf;
	alias ReloadSelectionStart = reloadSelectionStart;
	alias ReloadSelectionEnd = reloadSelectionEnd;
}

extern(C++) struct ImGuiNextWindowData{
	ImGuiNextWindowDataFlags_ flags;
	ImGuiCond_ posCond;
	ImGuiCond_ sizeCond;
	ImGuiCond_ collapsedCond;
	ImVec2 posVal;
	ImVec2 posPivotVal;
	ImVec2 sizeVal;
	ImVec2 contentSizeVal;
	ImVec2 scrollVal;
	ImGuiChildFlags_ childFlags;
	bool collapsedVal;
	ImRect sizeConstraintRect;
	ImGuiSizeCallback sizeCallback;
	void* sizeCallbackUserData;
	float bgAlphaVal = 0f;
	ImVec2 menuBarOffsetMinVal;
	ImGuiWindowRefreshFlags_ refreshFlagsVal;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ClearFlags}, q{}, ext: `C++`, aliases: [q{clearFlags}]},
		];
		return ret;
	}()));
	
	alias Flags = flags;
	alias PosCond = posCond;
	alias SizeCond = sizeCond;
	alias CollapsedCond = collapsedCond;
	alias PosVal = posVal;
	alias PosPivotVal = posPivotVal;
	alias SizeVal = sizeVal;
	alias ContentSizeVal = contentSizeVal;
	alias ScrollVal = scrollVal;
	alias ChildFlags = childFlags;
	alias CollapsedVal = collapsedVal;
	alias SizeConstraintRect = sizeConstraintRect;
	alias SizeCallback = sizeCallback;
	alias SizeCallbackUserData = sizeCallbackUserData;
	alias BgAlphaVal = bgAlphaVal;
	alias MenuBarOffsetMinVal = menuBarOffsetMinVal;
	alias RefreshFlagsVal = refreshFlagsVal;
}

extern(C++) struct ImGuiNextItemData{
	ImGuiNextItemDataFlags_ hasFlags;
	ImGuiItemFlags_ itemFlags;
	
	ImGuiID focusScopeID;
	ImGuiSelectionUserData selectionUserData = -1;
	float width = 0f;
	ImGuiKeyChord shortcut;
	ImGuiInputFlags_ shortcutFlags;
	bool openVal;
	ubyte openCond;
	ImGuiDataTypeStorage refVal;
	ImGuiID storageID;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{ClearFlags}, q{}, ext: `C++`, aliases: [q{clearFlags}]},
		];
		return ret;
	}()));
	
	alias HasFlags = hasFlags;
	alias ItemFlags = itemFlags;
	
	alias FocusScopeId = focusScopeID;
	alias SelectionUserData = selectionUserData;
	alias Width = width;
	alias Shortcut = shortcut;
	alias ShortcutFlags = shortcutFlags;
	alias OpenVal = openVal;
	alias OpenCond = openCond;
	alias RefVal = refVal;
	alias StorageId = storageID;
}

extern(C++) struct ImGuiLastItemData{
	ImGuiID id;
	ImGuiItemFlags_ itemFlags;
	ImGuiItemStatusFlags_ statusFlags;
	ImRect rect;
	ImRect navRect;
	
	ImRect displayRect;
	ImRect clipRect;
	ImGuiKeyChord shortcut;
	
	alias ID = id;
	alias ItemFlags = itemFlags;
	alias StatusFlags = statusFlags;
	alias Rect = rect;
	alias NavRect = navRect;
	
	alias DisplayRect = displayRect;
	alias ClipRect = clipRect;
	alias Shortcut = shortcut;
}

extern(C++) struct ImGuiTreeNodeStackData{
	ImGuiID id;
	ImGuiTreeNodeFlags_ treeFlags;
	ImGuiItemFlags_ itemFlags;
	ImRect navRect;
	
	alias ID = id;
	alias TreeFlags = treeFlags;
	alias ItemFlags = itemFlags;
	alias NavRect = navRect;
}

extern(C++) struct ImGuiErrorRecoveryState{
	short sizeOfWindowStack;
	short sizeOfIDStack;
	short sizeOfTreeStack;
	short sizeOfColourStack;
	short sizeOfStyleVarStack;
	short sizeOfFontStack;
	short sizeOfFocusScopeStack;
	short sizeOfGroupStack;
	short sizeOfItemFlagsStack;
	short sizeOfBeginPopupStack;
	short sizeOfDisabledStack;
	
	alias SizeOfWindowStack = sizeOfWindowStack;
	alias SizeOfIDStack = sizeOfIDStack;
	alias SizeOfTreeStack = sizeOfTreeStack;
	alias SizeOfColourStack = sizeOfColourStack;
	alias SizeOfColorStack = sizeOfColourStack;
	alias sizeOfColorStack = sizeOfColourStack;
	alias SizeOfStyleVarStack = sizeOfStyleVarStack;
	alias SizeOfFontStack = sizeOfFontStack;
	alias SizeOfFocusScopeStack = sizeOfFocusScopeStack;
	alias SizeOfGroupStack = sizeOfGroupStack;
	alias SizeOfItemFlagsStack = sizeOfItemFlagsStack;
	alias SizeOfBeginPopupStack = sizeOfBeginPopupStack;
	alias SizeOfDisabledStack = sizeOfDisabledStack;
}

extern(C++) struct ImGuiWindowStackData{
	ImGuiWindow* window;
	ImGuiLastItemData parentLastItemDataBackup;
	ImGuiErrorRecoveryState stackSizesInBegin;
	bool disabledOverrideReEnable;
	
	alias Window = window;
	alias ParentLastItemDataBackup = parentLastItemDataBackup;
	alias StackSizesInBegin = stackSizesInBegin;
	alias DisabledOverrideReenable = disabledOverrideReEnable;
}

extern(C++) struct ImGuiShrinkWidthItem{
	int index;
	float width = 0f;
	float initialWidth = 0f;
	
	alias Index = index;
	alias Width = width;
	alias InitialWidth = initialWidth;
}

extern(C++) struct ImGuiPtrOrIndex{
	void* ptr;
	int index = -1;
	
	alias Ptr = ptr;
	alias Index = index;
}

extern(C++) struct ImGuiPopupData{
	ImGuiID popupID;
	ImGuiWindow* window;
	ImGuiWindow* restoreNavWindow;
	int parentNavLayer = -1;
	int openFrameCount = -1;
	ImGuiID openParentID;
	ImVec2 openPopupPos;
	ImVec2 openMousePos;
	
	alias PopupId = popupID;
	alias Window = window;
	alias RestoreNavWindow = restoreNavWindow;
	alias ParentNavLayer = parentNavLayer;
	alias OpenFrameCount = openFrameCount;
	alias OpenParentId = openParentID;
	alias OpenPopupPos = openPopupPos;
	alias OpenMousePos = openMousePos;
}
extern(C++) struct ImBitArrayForNamedKeys{
	char[20] dummy = '\x00';
	
	alias __dummy = dummy;
}

extern(C++) struct ImGuiInputEventMousePos{
	float posX = 0f, posY = 0f;
	ImGuiMouseSource mouseSource;
	
	alias PosX = posX;
	alias PosY = posY;
	alias MouseSource = mouseSource;
}
extern(C++) struct ImGuiInputEventMouseWheel{
	float wheelX = 0f, wheelY = 0f;
	ImGuiMouseSource mouseSource;
	
	alias WheelX = wheelX;
	alias WheelY = wheelY;
	alias MouseSource = mouseSource;
}
extern(C++) struct ImGuiInputEventMouseButton{
	int button;
	bool down;
	ImGuiMouseSource mouseSource;
	
	alias Button = button;
	alias Down = down;
	alias MouseSource = mouseSource;
}
extern(C++) struct ImGuiInputEventKey{
	ImGuiKey key;
	bool down;
	float analogValue = 0f;
	
	alias Key = key;
	alias Down = down;
	alias AnalogValue = analogValue;
}
extern(C++) struct ImGuiInputEventText{
	uint char_;
	
	alias Char = char_;
}
extern(C++) struct ImGuiInputEventAppFocused{
	bool focused;
	
	alias Focused = focused;
}

extern(C++) struct ImGuiInputEvent{
	ImGuiInputEventType type;
	ImGuiInputSource source;
	uint eventID;
	extern(C++) union{
		ImGuiInputEventMousePos mousePos;
		ImGuiInputEventMouseWheel mouseWheel;
		ImGuiInputEventMouseButton mouseButton;
		ImGuiInputEventKey key;
		ImGuiInputEventText text;
		ImGuiInputEventAppFocused appFocused;
		
		alias MousePos = mousePos;
		alias MouseWheel = mouseWheel;
		alias MouseButton = mouseButton;
		alias Key = key;
		alias Text = text;
		alias AppFocused = appFocused;
	}
	bool addedByTestEngine;
	
	alias Type = type;
	alias Source = source;
	alias EventId = eventID;
	alias AddedByTestEngine = addedByTestEngine;
}

extern(C++) struct ImGuiKeyRoutingData{
	ImGuiKeyRoutingIndex nextEntryIndex = -1;
	ushort mods;
	ubyte routingCurrScore = 255;
	ubyte routingNextScore = 255;
	ImGuiID routingCurr = ImGuiKeyOwner_NoOwner;
	ImGuiID routingNext = ImGuiKeyOwner_NoOwner;
	
	alias NextEntryIndex = nextEntryIndex;
	alias Mods = mods;
	alias RoutingCurrScore = routingCurrScore;
	alias RoutingNextScore = routingNextScore;
	alias RoutingCurr = routingCurr;
	alias RoutingNext = routingNext;
}

extern(C++) struct ImGuiKeyRoutingTable{
	ImGuiKeyRoutingIndex[ImGuiKey.namedKeyCount] index = -1;
	ImVector!(ImGuiKeyRoutingData) entries;
	ImVector!(ImGuiKeyRoutingData) entriesNext;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
		];
		return ret;
	}()));
	
	alias Index = index;
	alias Entries = entries;
	alias EntriesNext = entriesNext;
}

extern(C++) struct ImGuiKeyOwnerData{
	ImGuiID ownerCurr;
	ImGuiID ownerNext;
	bool lockThisFrame;
	bool lockUntilRelease;
	
	alias OwnerCurr = ownerCurr;
	alias OwnerNext = ownerNext;
	alias LockThisFrame = lockThisFrame;
	alias LockUntilRelease = lockUntilRelease;
}

extern(C++) struct ImGuiListClipperRange{
	int min;
	int max;
	bool posToIndexConvert;
	byte posToIndexOffsetMin;
	byte posToIndexOffsetMax;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{ImGuiListClipperRange}, q{FromIndices}, q{int min, int max}, ext: `C++`, pfix: q{static}, aliases: [q{fromIndices}]},
			{q{ImGuiListClipperRange}, q{FromPositions}, q{float y1, float y2, int offMin, int offMax}, ext: `C++`, pfix: q{static}, aliases: [q{fromPositions}]},
		];
		return ret;
	}()));
	
	alias Min = min;
	alias Max = max;
	alias PosToIndexConvert = posToIndexConvert;
	alias PosToIndexOffsetMin = posToIndexOffsetMin;
	alias PosToIndexOffsetMax = posToIndexOffsetMax;
}

extern(C++) struct ImGuiListClipperData{
	ImGuiListClipper* listClipper;
	float lossynessOffset = 0f;
	int stepNo;
	int itemsFrozen;
	ImVector!(ImGuiListClipperRange) ranges;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Reset}, q{ImGuiListClipper* clipper}, ext: `C++`, aliases: [q{reset}]},
		];
		return ret;
	}()));
	
	alias ListClipper = listClipper;
	alias LossynessOffset = lossynessOffset;
	alias StepNo = stepNo;
	alias ItemsFrozen = itemsFrozen;
	alias Ranges = ranges;
}

extern(C++) struct ImGuiNavItemData{
	ImGuiWindow* window;
	ImGuiID id;
	ImGuiID focusScopeID;
	ImRect rectRel;
	ImGuiItemFlags_ itemFlags;
	float distBox = float.max;
	float distCentre = float.max;
	float distAxial = float.max;
	ImGuiSelectionUserData selectionUserData = -1;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
		];
		return ret;
	}()));
	
	alias Window = window;
	alias ID = id;
	alias FocusScopeId = focusScopeID;
	alias RectRel = rectRel;
	alias ItemFlags = itemFlags;
	alias DistBox = distBox;
	alias DistCentre = distCentre;
	alias DistCenter = distCentre;
	alias distCenter = distCentre;
	alias DistAxial = distAxial;
	alias SelectionUserData = selectionUserData;
}

extern(C++) struct ImGuiFocusScopeData{
	ImGuiID id;
	ImGuiID windowID;
	
	alias ID = id;
	alias WindowID = windowID;
}

extern(C++) struct ImGuiTypingSelectRequest{
	ImGuiTypingSelectFlags_ flags;
	int searchBufferLen;
	const(char)* searchBuffer;
	bool selectRequest;
	bool singleCharMode;
	byte singleCharSize;
	
	alias Flags = flags;
	alias SearchBufferLen = searchBufferLen;
	alias SearchBuffer = searchBuffer;
	alias SelectRequest = selectRequest;
	alias SingleCharMode = singleCharMode;
	alias SingleCharSize = singleCharSize;
}

extern(C++) struct ImGuiTypingSelectState{
	ImGuiTypingSelectRequest request;
	char[64] searchBuffer = '\x00';
	ImGuiID focusScope;
	int lastRequestFrame;
	float lastRequestTime = 0f;
	bool singleCharModeLock;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
		];
		return ret;
	}()));
	
	alias Request = request;
	alias SearchBuffer = searchBuffer;
	alias FocusScope = focusScope;
	alias LastRequestFrame = lastRequestFrame;
	alias LastRequestTime = lastRequestTime;
	alias SingleCharModeLock = singleCharModeLock;
}

extern(C++) struct ImGuiOldColumnData{
	float offsetNorm = 0f;
	float offsetNormBeforeResize = 0f;
	ImGuiOldColumnFlags_ flags;
	ImRect clipRect;
	
	alias OffsetNorm = offsetNorm;
	alias OffsetNormBeforeResize = offsetNormBeforeResize;
	alias Flags = flags;
	alias ClipRect = clipRect;
}

extern(C++) struct ImGuiOldColumns{
	ImGuiID id;
	ImGuiOldColumnFlags_ flags;
	bool isFirstFrame;
	bool isBeingResized;
	int current;
	int count;
	float offMinX = 0f, offMaxX = 0f;
	float lineMinY = 0f, lineMaxY = 0f;
	float hostCursorPosY = 0f;
	float hostCursorMaxPosX = 0f;
	ImRect hostInitialClipRect;
	ImRect hostBackupClipRect;
	ImRect hostBackupParentWorkRect;
	ImVector!(ImGuiOldColumnData) columns;
	ImDrawListSplitter splitter;
	
	alias ID = id;
	alias Flags = flags;
	alias IsFirstFrame = isFirstFrame;
	alias IsBeingResized = isBeingResized;
	alias Current = current;
	alias Count = count;
	alias OffMinX = offMinX;
	alias OffMaxX = offMaxX;
	alias LineMinY = lineMinY;
	alias LineMaxY = lineMaxY;
	alias HostCursorPosY = hostCursorPosY;
	alias HostCursorMaxPosX = hostCursorMaxPosX;
	alias HostInitialClipRect = hostInitialClipRect;
	alias HostBackupClipRect = hostBackupClipRect;
	alias HostBackupParentWorkRect = hostBackupParentWorkRect;
	alias Columns = columns;
	alias Splitter = splitter;
}

extern(C++) struct ImGuiBoxSelectState{
	ImGuiID id;
	bool isActive;
	bool isStarting;
	bool isStartedFromVoid;
	bool isStartedSetNavIDOnce;
	bool requestClear;
	mixin(bitfields!(
		ImGuiKeyChord, q{keyMods}, 16,
	));
	ImVec2 startPosRel;
	ImVec2 endPosRel;
	ImVec2 scrollAccum;
	ImGuiWindow* window;
	
	bool unclipMode;
	ImRect unclipRect;
	ImRect boxSelectRectPrev;
	ImRect boxSelectRectCurr;
	
	alias ID = id;
	alias IsActive = isActive;
	alias IsStarting = isStarting;
	alias IsStartedFromVoid = isStartedFromVoid;
	alias IsStartedSetNavIdOnce = isStartedSetNavIDOnce;
	alias RequestClear = requestClear;
	alias KeyMods = keyMods;
	alias StartPosRel = startPosRel;
	alias EndPosRel = endPosRel;
	alias ScrollAccum = scrollAccum;
	alias Window = window;
	
	alias UnclipMode = unclipMode;
	alias UnclipRect = unclipRect;
	alias BoxSelectRectPrev = boxSelectRectPrev;
	alias BoxSelectRectCurr = boxSelectRectCurr;
}

extern(C++) struct ImGuiMultiSelectTempData{
	ImGuiMultiSelectIO io = ImGuiMultiSelectIO(rangeSrcItem: ImGuiSelectionUserData_Invalid, navIDItem: ImGuiSelectionUserData_Invalid);
	ImGuiMultiSelectState* storage;
	ImGuiID focusScopeID;
	ImGuiMultiSelectFlags_ flags;
	ImVec2 scopeRectMin;
	ImVec2 backupCursorMaxPos;
	ImGuiSelectionUserData lastSubmittedItem;
	ImGuiID boxSelectID;
	ImGuiKeyChord keyMods;
	byte loopRequestSetAll;
	bool isEndIO;
	bool isFocused;
	bool isKeyboardSetRange;
	bool navIDPassedBy;
	bool rangeSrcPassedBy;
	bool rangeDstPassedBy;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{void}, q{Clear}, q{}, ext: `C++`, aliases: [q{clear}]},
			{q{void}, q{ClearIO}, q{}, ext: `C++`, aliases: [q{clearIO}]},
		];
		return ret;
	}()));
	
	alias IO = io;
	alias Storage = storage;
	alias FocusScopeId = focusScopeID;
	alias Flags = flags;
	alias ScopeRectMin = scopeRectMin;
	alias BackupCursorMaxPos = backupCursorMaxPos;
	alias LastSubmittedItem = lastSubmittedItem;
	alias BoxSelectId = boxSelectID;
	alias KeyMods = keyMods;
	alias LoopRequestSetAll = loopRequestSetAll;
	alias IsEndIO = isEndIO;
	alias IsFocused = isFocused;
	alias IsKeyboardSetRange = isKeyboardSetRange;
	alias NavIdPassedBy = navIDPassedBy;
	alias RangeSrcPassedBy = rangeSrcPassedBy;
	alias RangeDstPassedBy = rangeDstPassedBy;
}

extern(C++) struct ImGuiMultiSelectState{
	ImGuiWindow* window;
	ImGuiID id;
	int lastFrameActive;
	int lastSelectionSize;
	byte rangeSelected = -1;
	byte navIDSelected = -1;
	ImGuiSelectionUserData rangeSrcItem = ImGuiSelectionUserData_Invalid;
	ImGuiSelectionUserData navIDItem = ImGuiSelectionUserData_Invalid;
	
	alias Window = window;
	alias ID = id;
	alias LastFrameActive = lastFrameActive;
	alias LastSelectionSize = lastSelectionSize;
	alias RangeSelected = rangeSelected;
	alias NavIdSelected = navIDSelected;
	alias RangeSrcItem = rangeSrcItem;
	alias NavIdItem = navIDItem;
}

extern(C++) struct ImGuiViewportP{
	ImGuiID id;
	ImGuiViewportFlags_ flags;
	ImVec2 pos;
	ImVec2 size;
	ImVec2 workPos;
	ImVec2 workSize;
	
	void* platformHandle;
	void* platformHandleRaw;
	int[2] bgFgDrawListsLastFrame = -1;
	ImDrawList*[2] bgFgDrawLists;
	ImDrawData drawDataP;
	ImDrawDataBuilder drawDataBuilder;
	
	ImVec2 workInsetMin;
	ImVec2 workInsetMax;
	ImVec2 buildWorkInsetMin;
	ImVec2 buildWorkInsetMax;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{ImVec2}, q{CalcWorkRectPos}, q{in ImVec2 insetMin}, ext: `C++`, attr: q{const}, aliases: [q{calcWorkRectPos}]},
			{q{ImVec2}, q{CalcWorkRectSize}, q{in ImVec2 insetMin, in ImVec2 insetMax}, ext: `C++`, attr: q{const}, aliases: [q{calcWorkRectSize}]},
			{q{void}, q{UpdateWorkRect}, q{}, ext: `C++`, aliases: [q{updateWorkRect}]},
			{q{ImRect}, q{GetMainRect}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getMainRect}]},
			{q{ImRect}, q{GetWorkRect}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getWorkRect}]},
			{q{ImRect}, q{GetBuildWorkRect}, q{}, ext: `C++`, attr: q{const}, aliases: [q{getBuildWorkRect}]},
		];
		return ret;
	}()));
	
	alias ID = id;
	alias Flags = flags;
	alias Pos = pos;
	alias Size = size;
	alias WorkPos = workPos;
	alias WorkSize = workSize;
	
	alias PlatformHandle = platformHandle;
	alias PlatformHandleRaw = platformHandleRaw;
	alias BgFgDrawListsLastFrame = bgFgDrawListsLastFrame;
	alias BgFgDrawLists = bgFgDrawLists;
	alias DrawDataP = drawDataP;
	alias DrawDataBuilder = drawDataBuilder;
	
	alias WorkInsetMin = workInsetMin;
	alias WorkInsetMax = workInsetMax;
	alias BuildWorkInsetMin = buildWorkInsetMin;
	alias BuildWorkInsetMax = buildWorkInsetMax;
}

extern(C++) struct ImGuiWindowSettings{
	ImGuiID id;
	ImVec2IH pos;
	ImVec2IH size;
	bool collapsed;
	bool isChild;
	bool wantApply;
	bool wantDelete;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{char*}, q{GetName}, q{}, ext: `C++`, aliases: [q{getName}]},
		];
		return ret;
	}()));
	
	alias ID = id;
	alias Pos = pos;
	alias Size = size;
	alias Collapsed = collapsed;
	alias IsChild = isChild;
	alias WantApply = wantApply;
	alias WantDelete = wantDelete;
}

extern(C++) struct ImGuiSettingsHandler{
	const(char)* typeName;
	ImGuiID typeHash;
	private alias ClearAllFnFn = extern(C++) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler) nothrow @nogc;
	ClearAllFnFn clearAllFn;
	private alias ReadInitFnFn = extern(C++) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler) nothrow @nogc;
	ReadInitFnFn readInitFn;
	private alias ReadOpenFnFn = extern(C++) void* function(ImGuiContext* ctx, ImGuiSettingsHandler* handler, const(char)* name) nothrow @nogc;
	ReadOpenFnFn readOpenFn;
	private alias ReadLineFnFn = extern(C++) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler, void* entry, const(char)* line) nothrow @nogc;
	ReadLineFnFn readLineFn;
	private alias ApplyAllFnFn = extern(C++) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler) nothrow @nogc;
	ApplyAllFnFn applyAllFn;
	private alias WriteAllFnFn = extern(C++) void function(ImGuiContext* ctx, ImGuiSettingsHandler* handler, ImGuiTextBuffer* outBuf) nothrow @nogc;
	WriteAllFnFn writeAllFn;
	
	void* userData;
	
	alias TypeName = typeName;
	alias TypeHash = typeHash;
	alias ClearAllFn = clearAllFn;
	alias ReadInitFn = readInitFn;
	alias ReadOpenFn = readOpenFn;
	alias ReadLineFn = readLineFn;
	alias ApplyAllFn = applyAllFn;
	alias WriteAllFn = writeAllFn;
	
	alias UserData = userData;
}

extern(C++) struct ImGuiLocEntry{
	ImGuiLocKey_ key;
	const(char)* text;
	
	alias Key = key;
	alias Text = text;
}

extern(C++) struct ImGuiDebugAllocEntry{
	int frameCount;
	short allocCount;
	short freeCount;
	
	alias FrameCount = frameCount;
	alias AllocCount = allocCount;
	alias FreeCount = freeCount;
}

extern(C++) struct ImGuiDebugAllocInfo{
	int totalAllocCount;
	int totalFreeCount;
	short lastEntriesIdx;
	ImGuiDebugAllocEntry[6] lastEntriesBuf;
	
	alias TotalAllocCount = totalAllocCount;
	alias TotalFreeCount = totalFreeCount;
	alias LastEntriesIdx = lastEntriesIdx;
	alias LastEntriesBuf = lastEntriesBuf;
}

extern(C++) struct ImGuiMetricsConfig{
	bool showDebugLog;
	bool showIDStackTool;
	bool showWindowsRects;
	bool showWindowsBeginOrder;
	bool showTablesRects;
	bool showDrawCmdMesh = true;
	bool showDrawCmdBoundingBoxes = true;
	bool showTextEncodingViewer;
	bool showAtlasTintedWithTextColour;
	int showWindowsRectsType = -1;
	int showTablesRectsType = -1;
	int highlightMonitorIdx = -1;
	ImGuiID highlightViewportID;
	
	alias ShowDebugLog = showDebugLog;
	alias ShowIDStackTool = showIDStackTool;
	alias ShowWindowsRects = showWindowsRects;
	alias ShowWindowsBeginOrder = showWindowsBeginOrder;
	alias ShowTablesRects = showTablesRects;
	alias ShowDrawCmdMesh = showDrawCmdMesh;
	alias ShowDrawCmdBoundingBoxes = showDrawCmdBoundingBoxes;
	alias ShowTextEncodingViewer = showTextEncodingViewer;
	alias ShowAtlasTintedWithTextColour = showAtlasTintedWithTextColour;
	alias ShowAtlasTintedWithTextColor = showAtlasTintedWithTextColour;
	alias showAtlasTintedWithTextColor = showAtlasTintedWithTextColour;
	alias ShowWindowsRectsType = showWindowsRectsType;
	alias ShowTablesRectsType = showTablesRectsType;
	alias HighlightMonitorIdx = highlightMonitorIdx;
	alias HighlightViewportID = highlightViewportID;
}

extern(C++) struct ImGuiStackLevelInfo{
	ImGuiID id;
	byte queryFrameCount;
	bool querySuccess;
	mixin(bitfields!(
		ImGuiDataType_, q{dataType}, 8,
	));
	char[57] desc = '\x00';
	
	alias ID = id;
	alias QueryFrameCount = queryFrameCount;
	alias QuerySuccess = querySuccess;
	alias DataType = dataType;
	alias Desc = desc;
}

extern(C++) struct ImGuiIDStackTool{
	int lastActiveFrame;
	int stackLevel;
	ImGuiID queryID;
	ImVector!(ImGuiStackLevelInfo) results;
	bool copyToClipboardOnCtrlC;
	float copyToClipboardLastTime = -float.max;
	
	alias LastActiveFrame = lastActiveFrame;
	alias StackLevel = stackLevel;
	alias QueryId = queryID;
	alias Results = results;
	alias CopyToClipboardOnCtrlC = copyToClipboardOnCtrlC;
	alias CopyToClipboardLastTime = copyToClipboardLastTime;
}

extern(C++) struct ImGuiContextHook{
	ImGuiID hookID;
	ImGuiContextHookType type;
	ImGuiID owner;
	ImGuiContextHookCallback callback;
	void* userData;
	
	alias HookId = hookID;
	alias Type = type;
	alias Owner = owner;
	alias Callback = callback;
	alias UserData = userData;
}

extern(C++) struct ImGuiContext{
	bool initialised;
	bool fontAtlasOwnedByContext;
	ImGuiIO io;
	ImGuiPlatformIO platformIO;
	ImGuiStyle style;
	ImFont* font;
	float fontSize = 0f;
	float fontBaseSize = 0f;
	float fontScale = 0f;
	float currentDPIScale = 0f;
	ImDrawListSharedData drawListSharedData;
	double time = 0.0;
	int frameCount;
	int frameCountEnded = -1;
	int frameCountRendered = -1;
	bool withinFrameScope;
	bool withinFrameScopeWithImplicitWindow;
	bool withinEndChild;
	bool gcCompactAll;
	bool testEngineHookItems;
	void* testEngine;
	char[16] contextName = '\x00';
	
	ImVector!(ImGuiInputEvent) inputEventsQueue;
	ImVector!(ImGuiInputEvent) inputEventsTrail;
	ImGuiMouseSource inputEventsNextMouseSource;
	uint inputEventsNextEventID = 1;
	
	ImVector!(ImGuiWindow*) windows;
	ImVector!(ImGuiWindow*) windowsFocusOrder;
	ImVector!(ImGuiWindow*) windowsTempSortBuffer;
	ImVector!(ImGuiWindowStackData) currentWindowStack;
	ImGuiStorage windowsByID;
	int windowsActiveCount;
	ImVec2 windowsHoverPadding;
	ImGuiID debugBreakInWindow;
	ImGuiWindow* currentWindow;
	ImGuiWindow* hoveredWindow;
	ImGuiWindow* hoveredWindowUnderMovingWindow;
	ImGuiWindow* hoveredWindowBeforeClear;
	ImGuiWindow* movingWindow;
	ImGuiWindow* wheelingWindow;
	ImVec2 wheelingWindowRefMousePos;
	int wheelingWindowStartFrame = -1;
	int wheelingWindowScrolledFrame = -1;
	float wheelingWindowReleaseTimer = 0f;
	ImVec2 wheelingWindowWheelRemainder;
	ImVec2 wheelingAxisAvg;
	
	ImGuiID debugDrawIDConflicts;
	ImGuiID debugHookIDInfo;
	ImGuiID hoveredID;
	ImGuiID hoveredIDPreviousFrame;
	int hoveredIDPreviousFrameItemCount;
	float hoveredIDTimer = 0f;
	float hoveredIDNotActiveTimer = 0f;
	bool hoveredIDAllowOverlap;
	bool hoveredIDIsDisabled;
	bool itemUnclipByLog;
	ImGuiID activeID;
	ImGuiID activeIDIsAlive;
	float activeIDTimer = 0f;
	bool activeIDIsJustActivated;
	bool activeIDAllowOverlap;
	bool activeIDNoClearOnFocusLoss;
	bool activeIDHasBeenPressedBefore;
	bool activeIDHasBeenEditedBefore;
	bool activeIDHasBeenEditedThisFrame;
	bool activeIDFromShortcut;
	mixin(bitfields!(
		int, q{activeIDMouseButton}, 8,
	));
	ImVec2 activeIDClickOffset = ImVec2(-1f, -1f);
	ImGuiWindow* activeIDWindow;
	ImGuiInputSource activeIDSource;
	ImGuiID activeIDPreviousFrame;
	bool activeIDPreviousFrameIsAlive;
	bool activeIDPreviousFrameHasBeenEditedBefore;
	ImGuiWindow* activeIDPreviousFrameWindow;
	ImGuiID lastActiveID;
	float lastActiveIDTimer = 0f;
	
	double lastKeyModsChangeTime = -1.0;
	double lastKeyModsChangeFromNoneTime = -1.0;
	double lastKeyboardKeyPressTime = -1.0;
	ImBitArrayForNamedKeys keysMayBeCharInput;
	ImGuiKeyOwnerData[ImGuiKey.namedKeyCount] keysOwnerData;
	ImGuiKeyRoutingTable keysRoutingTable;
	uint activeIDUsingNavDirMask;
	bool activeIDUsingAllKeyboardKeys;
	ImGuiKeyChord debugBreakInShortcutRouting = ImGuiKey.none;
	
	ImGuiID currentFocusScopeID;
	ImGuiItemFlags_ currentItemFlags;
	ImGuiID debugLocateID;
	ImGuiNextItemData nextItemData;
	ImGuiLastItemData lastItemData;
	ImGuiNextWindowData nextWindowData;
	bool debugShowGroupRects;
	
	ImGuiCol_ debugFlashStyleColourIdx = ImGuiCol.count;
	ImVector!(ImGuiColourMod) colourStack;
	ImVector!(ImGuiStyleMod) styleVarStack;
	ImVector!(ImFont*) fontStack;
	ImVector!(ImGuiFocusScopeData) focusScopeStack;
	ImVector!(ImGuiItemFlags_) itemFlagsStack;
	ImVector!(ImGuiGroupData) groupStack;
	ImVector!(ImGuiPopupData) openPopupStack;
	ImVector!(ImGuiPopupData) beginPopupStack;
	ImVector!(ImGuiTreeNodeStackData) treeNodeStack;
	
	ImVector!(ImGuiViewportP*) viewports;
	
	bool navCursorVisible;
	bool navHighlightItemUnderNav;
	
	bool navMousePosDirty;
	bool navIDIsAlive;
	ImGuiID navID;
	ImGuiWindow* navWindow;
	ImGuiID navFocusScopeID;
	ImGuiNavLayer navLayer;
	ImGuiID navActivateID;
	ImGuiID navActivateDownID;
	ImGuiID navActivatePressedID;
	ImGuiActivateFlags_ navActivateFlags;
	ImVector!(ImGuiFocusScopeData) navFocusRoute;
	ImGuiID navHighlightActivatedID;
	float navHighlightActivatedTimer = 0f;
	ImGuiID navNextActivateID;
	ImGuiActivateFlags_ navNextActivateFlags;
	ImGuiInputSource navInputSource = ImGuiInputSource.keyboard;
	ImGuiSelectionUserData navLastValidSelectionUserData = ImGuiSelectionUserData_Invalid;
	byte navCursorHideFrames;
	
	bool navAnyRequest;
	bool navInitRequest;
	bool navInitRequestFromMove;
	ImGuiNavItemData navInitResult;
	bool navMoveSubmitted;
	bool navMoveScoringItems;
	bool navMoveForwardToNextFrame;
	ImGuiNavMoveFlags_ navMoveFlags;
	ImGuiScrollFlags_ navMoveScrollFlags;
	ImGuiKeyChord navMoveKeyMods;
	ImGuiDir navMoveDir;
	ImGuiDir navMoveDirForDebug;
	ImGuiDir navMoveClipDir;
	ImRect navScoringRect;
	ImRect navScoringNoClipRect;
	int navScoringDebugCount;
	int navTabbingDir;
	int navTabbingCounter;
	ImGuiNavItemData navMoveResultLocal;
	ImGuiNavItemData navMoveResultLocalVisible;
	ImGuiNavItemData navMoveResultOther;
	ImGuiNavItemData navTabbingResultFirst;
	
	ImGuiID navJustMovedFromFocusScopeID;
	ImGuiID navJustMovedToID;
	ImGuiID navJustMovedToFocusScopeID;
	ImGuiKeyChord navJustMovedToKeyMods;
	bool navJustMovedToIsTabbing;
	bool navJustMovedToHasSelectionData;
	
	ImGuiKeyChord configNavWindowingKeyNext;
	ImGuiKeyChord configNavWindowingKeyPrev;
	ImGuiWindow* navWindowingTarget;
	ImGuiWindow* navWindowingTargetAnim;
	ImGuiWindow* navWindowingListWindow;
	float navWindowingTimer = 0f;
	float navWindowingHighlightAlpha = 0f;
	bool navWindowingToggleLayer;
	ImGuiKey navWindowingToggleKey;
	ImVec2 navWindowingAccumDeltaPos;
	ImVec2 navWindowingAccumDeltaSize;
	
	float dimBgRatio = 0f;
	
	bool dragDropActive;
	bool dragDropWithinSource;
	bool dragDropWithinTarget;
	ImGuiDragDropFlags_ dragDropSourceFlags;
	int dragDropSourceFrameCount = -1;
	int dragDropMouseButton = -1;
	ImGuiPayload dragDropPayload;
	ImRect dragDropTargetRect;
	ImRect dragDropTargetClipRect;
	ImGuiID dragDropTargetID;
	ImGuiDragDropFlags_ dragDropAcceptFlags;
	float dragDropAcceptIDCurrRectSurface = 0f;
	ImGuiID dragDropAcceptIDCurr;
	ImGuiID dragDropAcceptIDPrev;
	int dragDropAcceptFrameCount = -1;
	ImGuiID dragDropHoldJustPressedID;
	ImVector!(ubyte) dragDropPayloadBufHeap;
	ubyte[16] dragDropPayloadBufLocal;
	
	int clipperTempDataStacked;
	ImVector!(ImGuiListClipperData) clipperTempData;
	
	ImGuiTable* currentTable;
	ImGuiID debugBreakInTable;
	int tablesTempDataStacked;
	ImVector!(ImGuiTableTempData) tablesTempData;
	ImPool!(ImGuiTable) tables;
	ImVector!(float) tablesLastTimeActive;
	ImVector!(ImDrawChannel) drawChannelsTempMergeBuffer;
	
	ImGuiTabBar* currentTabBar;
	ImPool!(ImGuiTabBar) tabBars;
	ImVector!(ImGuiPtrOrIndex) currentTabBarStack;
	ImVector!(ImGuiShrinkWidthItem) shrinkWidthBuffer;
	
	ImGuiBoxSelectState boxSelectState;
	ImGuiMultiSelectTempData* currentMultiSelect;
	int multiSelectTempDataStacked;
	ImVector!(ImGuiMultiSelectTempData) multiSelectTempData;
	ImPool!(ImGuiMultiSelectState) multiSelectStorage;
	
	ImGuiID hoverItemDelayID;
	ImGuiID hoverItemDelayIDPreviousFrame;
	float hoverItemDelayTimer = 0f;
	float hoverItemDelayClearTimer = 0f;
	ImGuiID hoverItemUnlockedStationaryID;
	ImGuiID hoverWindowUnlockedStationaryID;
	
	ImGuiMouseCursor_ mouseCursor;
	float mouseStationaryTimer = 0f;
	ImVec2 mouseLastValidPos;
	
	ImGuiInputTextState inputTextState;
	ImGuiInputTextDeactivatedState inputTextDeactivatedState;
	ImFont inputTextPasswordFont;
	ImGuiID tempInputID;
	ImGuiDataTypeStorage dataTypeZeroValue;
	int beginMenuDepth;
	int beginComboDepth;
	ImGuiColourEditFlags_ colourEditOptions;
	ImGuiID colourEditCurrentID;
	ImGuiID colourEditSavedID;
	float colourEditSavedHue = 0f;
	float colourEditSavedSat = 0f;
	uint colourEditSavedColour;
	ImVec4 colourPickerRef;
	ImGuiComboPreviewData comboPreviewData;
	ImRect windowResizeBorderExpectedRect;
	bool windowResizeRelativeMode;
	short scrollbarSeekMode;
	float scrollbarClickDeltaToGrabCentre = 0f;
	float sliderGrabClickOffset = 0f;
	float sliderCurrentAccum = 0f;
	bool sliderCurrentAccumDirty;
	bool dragCurrentAccumDirty;
	float dragCurrentAccum = 0f;
	float dragSpeedDefaultRatio = 1f/100f;
	float disabledAlphaBackup = 0f;
	short disabledStackSize;
	short tooltipOverrideCount;
	ImGuiWindow* tooltipPreviousWindow;
	ImVector!(char) clipboardHandlerData;
	ImVector!(ImGuiID) menusIDSubmittedThisFrame;
	ImGuiTypingSelectState typingSelectState;
	
	ImGuiPlatformIMEData platformIMEData;
	ImGuiPlatformIMEData platformIMEDataPrev = {inputPos: ImVec2(-1f, -1f)};
	
	bool settingsLoaded;
	float settingsDirtyTimer = 0f;
	ImGuiTextBuffer settingsIniData;
	ImVector!(ImGuiSettingsHandler) settingsHandlers;
	ImChunkStream!(ImGuiWindowSettings) settingsWindows;
	ImChunkStream!(ImGuiTableSettings) settingsTables;
	ImVector!(ImGuiContextHook) hooks;
	ImGuiID hookIDNext;
	
	const(char)*[ImGuiLocKey.count] localisationTable;
	
	bool logEnabled;
	ImGuiLogType logType;
	ImFileHandle logFile;
	ImGuiTextBuffer logBuffer;
	const(char)* logNextPrefix;
	const(char)* logNextSuffix;
	float logLinePosY = float.max;
	bool logLineFirstItem;
	int logDepthRef;
	int logDepthToExpand = 2;
	int logDepthToExpandDefault = 2;
	
	ImGuiErrorCallback errorCallback;
	void* errorCallbackUserData;
	ImVec2 errorTooltipLockedPos;
	bool errorFirst;
	int errorCountCurrentFrame;
	ImGuiErrorRecoveryState stackSizesInNewFrame;
	ImGuiErrorRecoveryState* stackSizesInBeginForCurrentWindow;
	
	int debugDrawIDConflictsCount;
	ImGuiDebugLogFlags_ debugLogFlags = ImGuiDebugLogFlags.outputToTTY;
	ImGuiTextBuffer debugLogBuf;
	ImGuiTextIndex debugLogIndex;
	int debugLogSkippedErrors;
	ImGuiDebugLogFlags_ debugLogAutoDisableFlags;
	ubyte debugLogAutoDisableFrames;
	ubyte debugLocateFrames;
	bool debugBreakInLocateID;
	ImGuiKeyChord debugBreakKeyChord = ImGuiKey.pause;
	byte debugBeginReturnValueCullDepth = -1;
	bool debugItemPickerActive;
	ubyte debugItemPickerMouseButton;
	ImGuiID debugItemPickerBreakID;
	float debugFlashStyleColourTime = 0f;
	ImVec4 debugFlashStyleColourBackup;
	ImGuiMetricsConfig debugMetricsConfig;
	ImGuiIDStackTool debugIDStackTool;
	ImGuiDebugAllocInfo debugAllocInfo;
	
	float[60] framerateSecPerFrame;
	int framerateSecPerFrameIdx;
	int framerateSecPerFrameCount;
	float framerateSecPerFrameAccum = 0f;
	int wantCaptureMouseNextFrame = -1;
	int wantCaptureKeyboardNextFrame = -1;
	int wantTextInputNextFrame = -1;
	ImVector!(char) tempBuffer;
	char[64] tempKeychordName = '\x00';
	
	alias Initialised = initialised;
	alias Initialized = initialised;
	alias initialized = initialised;
	alias FontAtlasOwnedByContext = fontAtlasOwnedByContext;
	alias IO = io;
	alias PlatformIO = platformIO;
	alias Style = style;
	alias Font = font;
	alias FontSize = fontSize;
	alias FontBaseSize = fontBaseSize;
	alias FontScale = fontScale;
	alias CurrentDpiScale = currentDPIScale;
	alias DrawListSharedData = drawListSharedData;
	alias Time = time;
	alias FrameCount = frameCount;
	alias FrameCountEnded = frameCountEnded;
	alias FrameCountRendered = frameCountRendered;
	alias WithinFrameScope = withinFrameScope;
	alias WithinFrameScopeWithImplicitWindow = withinFrameScopeWithImplicitWindow;
	alias WithinEndChild = withinEndChild;
	alias GcCompactAll = gcCompactAll;
	alias TestEngineHookItems = testEngineHookItems;
	alias TestEngine = testEngine;
	alias ContextName = contextName;
	
	alias InputEventsQueue = inputEventsQueue;
	alias InputEventsTrail = inputEventsTrail;
	alias InputEventsNextMouseSource = inputEventsNextMouseSource;
	alias InputEventsNextEventId = inputEventsNextEventID;
	
	alias Windows = windows;
	alias WindowsFocusOrder = windowsFocusOrder;
	alias WindowsTempSortBuffer = windowsTempSortBuffer;
	alias CurrentWindowStack = currentWindowStack;
	alias WindowsById = windowsByID;
	alias WindowsActiveCount = windowsActiveCount;
	alias WindowsHoverPadding = windowsHoverPadding;
	alias DebugBreakInWindow = debugBreakInWindow;
	alias CurrentWindow = currentWindow;
	alias HoveredWindow = hoveredWindow;
	alias HoveredWindowUnderMovingWindow = hoveredWindowUnderMovingWindow;
	alias HoveredWindowBeforeClear = hoveredWindowBeforeClear;
	alias MovingWindow = movingWindow;
	alias WheelingWindow = wheelingWindow;
	alias WheelingWindowRefMousePos = wheelingWindowRefMousePos;
	alias WheelingWindowStartFrame = wheelingWindowStartFrame;
	alias WheelingWindowScrolledFrame = wheelingWindowScrolledFrame;
	alias WheelingWindowReleaseTimer = wheelingWindowReleaseTimer;
	alias WheelingWindowWheelRemainder = wheelingWindowWheelRemainder;
	alias WheelingAxisAvg = wheelingAxisAvg;
	
	alias DebugDrawIdConflicts = debugDrawIDConflicts;
	alias DebugHookIdInfo = debugHookIDInfo;
	alias HoveredId = hoveredID;
	alias HoveredIdPreviousFrame = hoveredIDPreviousFrame;
	alias HoveredIdPreviousFrameItemCount = hoveredIDPreviousFrameItemCount;
	alias HoveredIdTimer = hoveredIDTimer;
	alias HoveredIdNotActiveTimer = hoveredIDNotActiveTimer;
	alias HoveredIdAllowOverlap = hoveredIDAllowOverlap;
	alias HoveredIdIsDisabled = hoveredIDIsDisabled;
	alias ItemUnclipByLog = itemUnclipByLog;
	alias ActiveId = activeID;
	alias ActiveIdIsAlive = activeIDIsAlive;
	alias ActiveIdTimer = activeIDTimer;
	alias ActiveIdIsJustActivated = activeIDIsJustActivated;
	alias ActiveIdAllowOverlap = activeIDAllowOverlap;
	alias ActiveIdNoClearOnFocusLoss = activeIDNoClearOnFocusLoss;
	alias ActiveIdHasBeenPressedBefore = activeIDHasBeenPressedBefore;
	alias ActiveIdHasBeenEditedBefore = activeIDHasBeenEditedBefore;
	alias ActiveIdHasBeenEditedThisFrame = activeIDHasBeenEditedThisFrame;
	alias ActiveIdFromShortcut = activeIDFromShortcut;
	alias ActiveIdMouseButton = activeIDMouseButton;
	alias ActiveIdClickOffset = activeIDClickOffset;
	alias ActiveIdWindow = activeIDWindow;
	alias ActiveIdSource = activeIDSource;
	alias ActiveIdPreviousFrame = activeIDPreviousFrame;
	alias ActiveIdPreviousFrameIsAlive = activeIDPreviousFrameIsAlive;
	alias ActiveIdPreviousFrameHasBeenEditedBefore = activeIDPreviousFrameHasBeenEditedBefore;
	alias ActiveIdPreviousFrameWindow = activeIDPreviousFrameWindow;
	alias LastActiveId = lastActiveID;
	alias LastActiveIdTimer = lastActiveIDTimer;
	
	alias LastKeyModsChangeTime = lastKeyModsChangeTime;
	alias LastKeyModsChangeFromNoneTime = lastKeyModsChangeFromNoneTime;
	alias LastKeyboardKeyPressTime = lastKeyboardKeyPressTime;
	alias KeysMayBeCharInput = keysMayBeCharInput;
	alias KeysOwnerData = keysOwnerData;
	alias KeysRoutingTable = keysRoutingTable;
	alias ActiveIdUsingNavDirMask = activeIDUsingNavDirMask;
	alias ActiveIdUsingAllKeyboardKeys = activeIDUsingAllKeyboardKeys;
	alias DebugBreakInShortcutRouting = debugBreakInShortcutRouting;
	
	alias CurrentFocusScopeId = currentFocusScopeID;
	alias CurrentItemFlags = currentItemFlags;
	alias DebugLocateId = debugLocateID;
	alias NextItemData = nextItemData;
	alias LastItemData = lastItemData;
	alias NextWindowData = nextWindowData;
	alias DebugShowGroupRects = debugShowGroupRects;
	
	alias DebugFlashStyleColourIdx = debugFlashStyleColourIdx;
	alias DebugFlashStyleColorIdx = debugFlashStyleColourIdx;
	alias debugFlashStyleColorIdx = debugFlashStyleColourIdx;
	alias ColourStack = colourStack;
	alias ColorStack = colourStack;
	alias colorStack = colourStack;
	alias StyleVarStack = styleVarStack;
	alias FontStack = fontStack;
	alias FocusScopeStack = focusScopeStack;
	alias ItemFlagsStack = itemFlagsStack;
	alias GroupStack = groupStack;
	alias OpenPopupStack = openPopupStack;
	alias BeginPopupStack = beginPopupStack;
	alias TreeNodeStack = treeNodeStack;
	
	alias Viewports = viewports;
	
	alias NavCursorVisible = navCursorVisible;
	alias NavHighlightItemUnderNav = navHighlightItemUnderNav;
	
	alias NavMousePosDirty = navMousePosDirty;
	alias NavIdIsAlive = navIDIsAlive;
	alias NavId = navID;
	alias NavWindow = navWindow;
	alias NavFocusScopeId = navFocusScopeID;
	alias NavLayer = navLayer;
	alias NavActivateId = navActivateID;
	alias NavActivateDownId = navActivateDownID;
	alias NavActivatePressedId = navActivatePressedID;
	alias NavActivateFlags = navActivateFlags;
	alias NavFocusRoute = navFocusRoute;
	alias NavHighlightActivatedId = navHighlightActivatedID;
	alias NavHighlightActivatedTimer = navHighlightActivatedTimer;
	alias NavNextActivateId = navNextActivateID;
	alias NavNextActivateFlags = navNextActivateFlags;
	alias NavInputSource = navInputSource;
	alias NavLastValidSelectionUserData = navLastValidSelectionUserData;
	alias NavCursorHideFrames = navCursorHideFrames;
	
	alias NavAnyRequest = navAnyRequest;
	alias NavInitRequest = navInitRequest;
	alias NavInitRequestFromMove = navInitRequestFromMove;
	alias NavInitResult = navInitResult;
	alias NavMoveSubmitted = navMoveSubmitted;
	alias NavMoveScoringItems = navMoveScoringItems;
	alias NavMoveForwardToNextFrame = navMoveForwardToNextFrame;
	alias NavMoveFlags = navMoveFlags;
	alias NavMoveScrollFlags = navMoveScrollFlags;
	alias NavMoveKeyMods = navMoveKeyMods;
	alias NavMoveDir = navMoveDir;
	alias NavMoveDirForDebug = navMoveDirForDebug;
	alias NavMoveClipDir = navMoveClipDir;
	alias NavScoringRect = navScoringRect;
	alias NavScoringNoClipRect = navScoringNoClipRect;
	alias NavScoringDebugCount = navScoringDebugCount;
	alias NavTabbingDir = navTabbingDir;
	alias NavTabbingCounter = navTabbingCounter;
	alias NavMoveResultLocal = navMoveResultLocal;
	alias NavMoveResultLocalVisible = navMoveResultLocalVisible;
	alias NavMoveResultOther = navMoveResultOther;
	alias NavTabbingResultFirst = navTabbingResultFirst;
	
	alias NavJustMovedFromFocusScopeId = navJustMovedFromFocusScopeID;
	alias NavJustMovedToId = navJustMovedToID;
	alias NavJustMovedToFocusScopeId = navJustMovedToFocusScopeID;
	alias NavJustMovedToKeyMods = navJustMovedToKeyMods;
	alias NavJustMovedToIsTabbing = navJustMovedToIsTabbing;
	alias NavJustMovedToHasSelectionData = navJustMovedToHasSelectionData;
	
	alias ConfigNavWindowingKeyNext = configNavWindowingKeyNext;
	alias ConfigNavWindowingKeyPrev = configNavWindowingKeyPrev;
	alias NavWindowingTarget = navWindowingTarget;
	alias NavWindowingTargetAnim = navWindowingTargetAnim;
	alias NavWindowingListWindow = navWindowingListWindow;
	alias NavWindowingTimer = navWindowingTimer;
	alias NavWindowingHighlightAlpha = navWindowingHighlightAlpha;
	alias NavWindowingToggleLayer = navWindowingToggleLayer;
	alias NavWindowingToggleKey = navWindowingToggleKey;
	alias NavWindowingAccumDeltaPos = navWindowingAccumDeltaPos;
	alias NavWindowingAccumDeltaSize = navWindowingAccumDeltaSize;
	
	alias DimBgRatio = dimBgRatio;
	
	alias DragDropActive = dragDropActive;
	alias DragDropWithinSource = dragDropWithinSource;
	alias DragDropWithinTarget = dragDropWithinTarget;
	alias DragDropSourceFlags = dragDropSourceFlags;
	alias DragDropSourceFrameCount = dragDropSourceFrameCount;
	alias DragDropMouseButton = dragDropMouseButton;
	alias DragDropPayload = dragDropPayload;
	alias DragDropTargetRect = dragDropTargetRect;
	alias DragDropTargetClipRect = dragDropTargetClipRect;
	alias DragDropTargetId = dragDropTargetID;
	alias DragDropAcceptFlags = dragDropAcceptFlags;
	alias DragDropAcceptIdCurrRectSurface = dragDropAcceptIDCurrRectSurface;
	alias DragDropAcceptIdCurr = dragDropAcceptIDCurr;
	alias DragDropAcceptIdPrev = dragDropAcceptIDPrev;
	alias DragDropAcceptFrameCount = dragDropAcceptFrameCount;
	alias DragDropHoldJustPressedId = dragDropHoldJustPressedID;
	alias DragDropPayloadBufHeap = dragDropPayloadBufHeap;
	alias DragDropPayloadBufLocal = dragDropPayloadBufLocal;
	
	alias ClipperTempDataStacked = clipperTempDataStacked;
	alias ClipperTempData = clipperTempData;
	
	alias CurrentTable = currentTable;
	alias DebugBreakInTable = debugBreakInTable;
	alias TablesTempDataStacked = tablesTempDataStacked;
	alias TablesTempData = tablesTempData;
	alias Tables = tables;
	alias TablesLastTimeActive = tablesLastTimeActive;
	alias DrawChannelsTempMergeBuffer = drawChannelsTempMergeBuffer;
	
	alias CurrentTabBar = currentTabBar;
	alias TabBars = tabBars;
	alias CurrentTabBarStack = currentTabBarStack;
	alias ShrinkWidthBuffer = shrinkWidthBuffer;
	
	alias BoxSelectState = boxSelectState;
	alias CurrentMultiSelect = currentMultiSelect;
	alias MultiSelectTempDataStacked = multiSelectTempDataStacked;
	alias MultiSelectTempData = multiSelectTempData;
	alias MultiSelectStorage = multiSelectStorage;
	
	alias HoverItemDelayId = hoverItemDelayID;
	alias HoverItemDelayIdPreviousFrame = hoverItemDelayIDPreviousFrame;
	alias HoverItemDelayTimer = hoverItemDelayTimer;
	alias HoverItemDelayClearTimer = hoverItemDelayClearTimer;
	alias HoverItemUnlockedStationaryId = hoverItemUnlockedStationaryID;
	alias HoverWindowUnlockedStationaryId = hoverWindowUnlockedStationaryID;
	
	alias MouseCursor = mouseCursor;
	alias MouseStationaryTimer = mouseStationaryTimer;
	alias MouseLastValidPos = mouseLastValidPos;
	
	alias InputTextState = inputTextState;
	alias InputTextDeactivatedState = inputTextDeactivatedState;
	alias InputTextPasswordFont = inputTextPasswordFont;
	alias TempInputId = tempInputID;
	alias DataTypeZeroValue = dataTypeZeroValue;
	alias BeginMenuDepth = beginMenuDepth;
	alias BeginComboDepth = beginComboDepth;
	alias ColourEditOptions = colourEditOptions;
	alias ColorEditOptions = colourEditOptions;
	alias colorEditOptions = colourEditOptions;
	alias ColourEditCurrentID = colourEditCurrentID;
	alias ColorEditCurrentID = colourEditCurrentID;
	alias colorEditCurrentID = colourEditCurrentID;
	alias ColourEditSavedID = colourEditSavedID;
	alias ColorEditSavedID = colourEditSavedID;
	alias colorEditSavedID = colourEditSavedID;
	alias ColourEditSavedHue = colourEditSavedHue;
	alias ColorEditSavedHue = colourEditSavedHue;
	alias colorEditSavedHue = colourEditSavedHue;
	alias ColourEditSavedSat = colourEditSavedSat;
	alias ColorEditSavedSat = colourEditSavedSat;
	alias colorEditSavedSat = colourEditSavedSat;
	alias ColourEditSavedColour = colourEditSavedColour;
	alias ColorEditSavedColor = colourEditSavedColour;
	alias colorEditSavedColor = colourEditSavedColour;
	alias ColourPickerRef = colourPickerRef;
	alias ColorPickerRef = colourPickerRef;
	alias colorPickerRef = colourPickerRef;
	alias ComboPreviewData = comboPreviewData;
	alias WindowResizeBorderExpectedRect = windowResizeBorderExpectedRect;
	alias WindowResizeRelativeMode = windowResizeRelativeMode;
	alias ScrollbarSeekMode = scrollbarSeekMode;
	alias ScrollbarClickDeltaToGrabCentre = scrollbarClickDeltaToGrabCentre;
	alias ScrollbarClickDeltaToGrabCenter = scrollbarClickDeltaToGrabCentre;
	alias scrollbarClickDeltaToGrabCenter = scrollbarClickDeltaToGrabCentre;
	alias SliderGrabClickOffset = sliderGrabClickOffset;
	alias SliderCurrentAccum = sliderCurrentAccum;
	alias SliderCurrentAccumDirty = sliderCurrentAccumDirty;
	alias DragCurrentAccumDirty = dragCurrentAccumDirty;
	alias DragCurrentAccum = dragCurrentAccum;
	alias DragSpeedDefaultRatio = dragSpeedDefaultRatio;
	alias DisabledAlphaBackup = disabledAlphaBackup;
	alias DisabledStackSize = disabledStackSize;
	alias TooltipOverrideCount = tooltipOverrideCount;
	alias TooltipPreviousWindow = tooltipPreviousWindow;
	alias ClipboardHandlerData = clipboardHandlerData;
	alias MenusIdSubmittedThisFrame = menusIDSubmittedThisFrame;
	alias TypingSelectState = typingSelectState;
	
	alias PlatformImeData = platformIMEData;
	alias PlatformImeDataPrev = platformIMEDataPrev;
	
	alias SettingsLoaded = settingsLoaded;
	alias SettingsDirtyTimer = settingsDirtyTimer;
	alias SettingsIniData = settingsIniData;
	alias SettingsHandlers = settingsHandlers;
	alias SettingsWindows = settingsWindows;
	alias SettingsTables = settingsTables;
	alias Hooks = hooks;
	alias HookIdNext = hookIDNext;
	
	alias LocalisationTable = localisationTable;
	alias LocalizationTable = localisationTable;
	alias localizationTable = localisationTable;
	
	alias LogEnabled = logEnabled;
	alias LogType = logType;
	alias LogFile = logFile;
	alias LogBuffer = logBuffer;
	alias LogNextPrefix = logNextPrefix;
	alias LogNextSuffix = logNextSuffix;
	alias LogLinePosY = logLinePosY;
	alias LogLineFirstItem = logLineFirstItem;
	alias LogDepthRef = logDepthRef;
	alias LogDepthToExpand = logDepthToExpand;
	alias LogDepthToExpandDefault = logDepthToExpandDefault;
	
	alias ErrorCallback = errorCallback;
	alias ErrorCallbackUserData = errorCallbackUserData;
	alias ErrorTooltipLockedPos = errorTooltipLockedPos;
	alias ErrorFirst = errorFirst;
	alias ErrorCountCurrentFrame = errorCountCurrentFrame;
	alias StackSizesInNewFrame = stackSizesInNewFrame;
	alias StackSizesInBeginForCurrentWindow = stackSizesInBeginForCurrentWindow;
	
	alias DebugDrawIdConflictsCount = debugDrawIDConflictsCount;
	alias DebugLogFlags = debugLogFlags;
	alias DebugLogBuf = debugLogBuf;
	alias DebugLogIndex = debugLogIndex;
	alias DebugLogSkippedErrors = debugLogSkippedErrors;
	alias DebugLogAutoDisableFlags = debugLogAutoDisableFlags;
	alias DebugLogAutoDisableFrames = debugLogAutoDisableFrames;
	alias DebugLocateFrames = debugLocateFrames;
	alias DebugBreakInLocateId = debugBreakInLocateID;
	alias DebugBreakKeyChord = debugBreakKeyChord;
	alias DebugBeginReturnValueCullDepth = debugBeginReturnValueCullDepth;
	alias DebugItemPickerActive = debugItemPickerActive;
	alias DebugItemPickerMouseButton = debugItemPickerMouseButton;
	alias DebugItemPickerBreakId = debugItemPickerBreakID;
	alias DebugFlashStyleColourTime = debugFlashStyleColourTime;
	alias DebugFlashStyleColorTime = debugFlashStyleColourTime;
	alias debugFlashStyleColorTime = debugFlashStyleColourTime;
	alias DebugFlashStyleColourBackup = debugFlashStyleColourBackup;
	alias DebugFlashStyleColorBackup = debugFlashStyleColourBackup;
	alias debugFlashStyleColorBackup = debugFlashStyleColourBackup;
	alias DebugMetricsConfig = debugMetricsConfig;
	alias DebugIDStackTool = debugIDStackTool;
	alias DebugAllocInfo = debugAllocInfo;
	
	alias FramerateSecPerFrame = framerateSecPerFrame;
	alias FramerateSecPerFrameIdx = framerateSecPerFrameIdx;
	alias FramerateSecPerFrameCount = framerateSecPerFrameCount;
	alias FramerateSecPerFrameAccum = framerateSecPerFrameAccum;
	alias WantCaptureMouseNextFrame = wantCaptureMouseNextFrame;
	alias WantCaptureKeyboardNextFrame = wantCaptureKeyboardNextFrame;
	alias WantTextInputNextFrame = wantTextInputNextFrame;
	alias TempBuffer = tempBuffer;
	alias TempKeychordName = tempKeychordName;
}

extern(C++) struct ImGuiWindowTempData{
	ImVec2 cursorPos;
	ImVec2 cursorPosPrevLine;
	ImVec2 cursorStartPos;
	ImVec2 cursorMaxPos;
	ImVec2 idealMaxPos;
	ImVec2 currLineSize;
	ImVec2 prevLineSize;
	float currLineTextBaseOffset = 0f;
	float prevLineTextBaseOffset = 0f;
	bool isSameLine;
	bool isSetPos;
	ImVec1 indent;
	ImVec1 columnsOffset;
	ImVec1 groupOffset;
	ImVec2 cursorStartPosLossyness;
	
	ImGuiNavLayer navLayerCurrent;
	short navLayersActiveMask;
	short navLayersActiveMaskNext;
	bool navIsScrollPushableX;
	bool navHideHighlightOneFrame;
	bool navWindowHasScrollY;
	
	bool menuBarAppending;
	ImVec2 menuBarOffset;
	ImGuiMenuColumns menuColumns;
	int treeDepth;
	uint treeHasStackDataDepthMask;
	ImVector!(ImGuiWindow*) childWindows;
	ImGuiStorage* stateStorage;
	ImGuiOldColumns* currentColumns;
	int currentTableIdx;
	ImGuiLayoutType_ layoutType;
	ImGuiLayoutType_ parentLayoutType;
	uint modalDimBgColour;
	
	float itemWidth = 0f;
	float textWrapPos = 0f;
	ImVector!(float) itemWidthStack;
	ImVector!(float) textWrapPosStack;
	
	alias CursorPos = cursorPos;
	alias CursorPosPrevLine = cursorPosPrevLine;
	alias CursorStartPos = cursorStartPos;
	alias CursorMaxPos = cursorMaxPos;
	alias IdealMaxPos = idealMaxPos;
	alias CurrLineSize = currLineSize;
	alias PrevLineSize = prevLineSize;
	alias CurrLineTextBaseOffset = currLineTextBaseOffset;
	alias PrevLineTextBaseOffset = prevLineTextBaseOffset;
	alias IsSameLine = isSameLine;
	alias IsSetPos = isSetPos;
	alias Indent = indent;
	alias ColumnsOffset = columnsOffset;
	alias GroupOffset = groupOffset;
	alias CursorStartPosLossyness = cursorStartPosLossyness;
	
	alias NavLayerCurrent = navLayerCurrent;
	alias NavLayersActiveMask = navLayersActiveMask;
	alias NavLayersActiveMaskNext = navLayersActiveMaskNext;
	alias NavIsScrollPushableX = navIsScrollPushableX;
	alias NavHideHighlightOneFrame = navHideHighlightOneFrame;
	alias NavWindowHasScrollY = navWindowHasScrollY;
	
	alias MenuBarAppending = menuBarAppending;
	alias MenuBarOffset = menuBarOffset;
	alias MenuColumns = menuColumns;
	alias TreeDepth = treeDepth;
	alias TreeHasStackDataDepthMask = treeHasStackDataDepthMask;
	alias ChildWindows = childWindows;
	alias StateStorage = stateStorage;
	alias CurrentColumns = currentColumns;
	alias CurrentTableIdx = currentTableIdx;
	alias LayoutType = layoutType;
	alias ParentLayoutType = parentLayoutType;
	alias ModalDimBgColour = modalDimBgColour;
	alias ModalDimBgColor = modalDimBgColour;
	alias modalDimBgColor = modalDimBgColour;
	
	alias ItemWidth = itemWidth;
	alias TextWrapPos = textWrapPos;
	alias ItemWidthStack = itemWidthStack;
	alias TextWrapPosStack = textWrapPosStack;
}

extern(C++) struct ImGuiWindow{
	ImGuiContext* ctx;
	char* name;
	ImGuiID id;
	ImGuiWindowFlags_ flags;
	ImGuiChildFlags_ childFlags;
	ImGuiViewportP* viewport;
	ImVec2 pos;
	ImVec2 size;
	ImVec2 sizeFull;
	ImVec2 contentSize;
	ImVec2 contentSizeIdeal;
	ImVec2 contentSizeExplicit;
	ImVec2 windowPadding;
	float windowRounding = 0f;
	float windowBorderSize = 0f;
	float titleBarHeight = 0f, menuBarHeight = 0f;
	float decoOuterSizeX1 = 0f, decoOuterSizeY1 = 0f;
	float decoOuterSizeX2 = 0f, decoOuterSizeY2 = 0f;
	float decoInnerSizeX1 = 0f, decoInnerSizeY1 = 0f;
	int nameBufLen;
	ImGuiID moveID;
	ImGuiID childID;
	ImGuiID popupID;
	ImVec2 scroll;
	ImVec2 scrollMax;
	ImVec2 scrollTarget;
	ImVec2 scrollTargetCentreRatio;
	ImVec2 scrollTargetEdgeSnapDist;
	ImVec2 scrollbarSizes;
	bool scrollbarX, scrollbarY;
	bool active;
	bool wasActive;
	bool writeAccessed;
	bool collapsed;
	bool wantCollapseToggle;
	bool skipItems;
	bool skipRefresh;
	bool appearing;
	bool hidden;
	bool isFallbackWindow;
	bool isExplicitChild;
	bool hasCloseButton;
	char resizeBorderHovered = '\x00';
	char resizeBorderHeld = '\x00';
	short beginCount;
	short beginCountPreviousFrame;
	short beginOrderWithinParent;
	short beginOrderWithinContext;
	short focusOrder;
	byte autoFitFramesX, autoFitFramesY;
	bool autoFitOnlyGrows;
	ImGuiDir autoPosLastDirection;
	byte hiddenFramesCanSkipItems;
	byte hiddenFramesCannotSkipItems;
	byte hiddenFramesForRenderOnly;
	byte disableInputsFrames;
	mixin(bitfields!(
		ImGuiCond_, q{setWindowPosAllowFlags}, 8,
		ImGuiCond_, q{setWindowSizeAllowFlags}, 8,
		ImGuiCond_, q{setWindowCollapsedAllowFlags}, 8,
		
		uint, q{}, 8,
	));
	ImVec2 setWindowPosVal;
	ImVec2 setWindowPosPivot;
	
	ImVector!(ImGuiID) idStack;
	ImGuiWindowTempData dc;
	
	ImRect outerRectClipped;
	ImRect innerRect;
	ImRect innerClipRect;
	ImRect workRect;
	ImRect parentWorkRect;
	ImRect clipRect;
	ImRect contentRegionRect;
	ImVec2IH hitTestHoleSize;
	ImVec2IH hitTestHoleOffset;
	
	int lastFrameActive;
	float lastTimeActive = 0f;
	float itemWidthDefault = 0f;
	ImGuiStorage stateStorage;
	ImVector!(ImGuiOldColumns) columnsStorage;
	float fontWindowScale = 0f;
	int settingsOffset;
	
	ImDrawList* drawList;
	ImDrawList drawListInst;
	ImGuiWindow* parentWindow;
	ImGuiWindow* parentWindowInBeginStack;
	ImGuiWindow* rootWindow;
	ImGuiWindow* rootWindowPopupTree;
	ImGuiWindow* rootWindowForTitleBarHighlight;
	ImGuiWindow* rootWindowForNav;
	ImGuiWindow* parentWindowForFocusRoute;
	
	ImGuiWindow* navLastChildNavWindow;
	ImGuiID[ImGuiNavLayer.count] navLastIDs;
	ImRect[ImGuiNavLayer.count] navRectRel;
	ImVec2[ImGuiNavLayer.count] navPreferredScoringPosRel;
	ImGuiID navRootFocusScopeID;
	
	int memoryDrawListIdxCapacity;
	int memoryDrawListVtxCapacity;
	bool memoryCompacted;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{ImGuiID}, q{GetID}, q{const(char)* str, const(char)* strEnd=null}, ext: `C++`, aliases: [q{getID}]},
			{q{ImGuiID}, q{GetID}, q{const(void)* ptr}, ext: `C++`, aliases: [q{getID}]},
			{q{ImGuiID}, q{GetID}, q{int n}, ext: `C++`, aliases: [q{getID}]},
			{q{ImGuiID}, q{GetIDFromPos}, q{in ImVec2 pAbs}, ext: `C++`, aliases: [q{getIDFromPos}]},
			{q{ImGuiID}, q{GetIDFromRectangle}, q{ImRect rAbs}, ext: `C++`, aliases: [q{getIDFromRectangle}]},
			{q{ImRect}, q{Rect}, q{}, ext: `C++`, attr: q{const}, aliases: [q{rect}]},
			{q{float}, q{CalcFontSize}, q{}, ext: `C++`, attr: q{const}, aliases: [q{calcFontSize}]},
			{q{ImRect}, q{TitleBarRect}, q{}, ext: `C++`, attr: q{const}, aliases: [q{titleBarRect}]},
			{q{ImRect}, q{MenuBarRect}, q{}, ext: `C++`, attr: q{const}, aliases: [q{menuBarRect}]},
		];
		return ret;
	}()));
	
	alias Ctx = ctx;
	alias Name = name;
	alias ID = id;
	alias Flags = flags;
	alias ChildFlags = childFlags;
	alias Viewport = viewport;
	alias Pos = pos;
	alias Size = size;
	alias SizeFull = sizeFull;
	alias ContentSize = contentSize;
	alias ContentSizeIdeal = contentSizeIdeal;
	alias ContentSizeExplicit = contentSizeExplicit;
	alias WindowPadding = windowPadding;
	alias WindowRounding = windowRounding;
	alias WindowBorderSize = windowBorderSize;
	alias TitleBarHeight = titleBarHeight;
	alias MenuBarHeight = menuBarHeight;
	alias DecoOuterSizeX1 = decoOuterSizeX1;
	alias DecoOuterSizeY1 = decoOuterSizeY1;
	alias DecoOuterSizeX2 = decoOuterSizeX2;
	alias DecoOuterSizeY2 = decoOuterSizeY2;
	alias DecoInnerSizeX1 = decoInnerSizeX1;
	alias DecoInnerSizeY1 = decoInnerSizeY1;
	alias NameBufLen = nameBufLen;
	alias MoveId = moveID;
	alias ChildId = childID;
	alias PopupId = popupID;
	alias Scroll = scroll;
	alias ScrollMax = scrollMax;
	alias ScrollTarget = scrollTarget;
	alias ScrollTargetCentreRatio = scrollTargetCentreRatio;
	alias ScrollTargetCenterRatio = scrollTargetCentreRatio;
	alias scrollTargetCenterRatio = scrollTargetCentreRatio;
	alias ScrollTargetEdgeSnapDist = scrollTargetEdgeSnapDist;
	alias ScrollbarSizes = scrollbarSizes;
	alias ScrollbarX = scrollbarX;
	alias ScrollbarY = scrollbarY;
	alias Active = active;
	alias WasActive = wasActive;
	alias WriteAccessed = writeAccessed;
	alias Collapsed = collapsed;
	alias WantCollapseToggle = wantCollapseToggle;
	alias SkipItems = skipItems;
	alias SkipRefresh = skipRefresh;
	alias Appearing = appearing;
	alias Hidden = hidden;
	alias IsFallbackWindow = isFallbackWindow;
	alias IsExplicitChild = isExplicitChild;
	alias HasCloseButton = hasCloseButton;
	alias ResizeBorderHovered = resizeBorderHovered;
	alias ResizeBorderHeld = resizeBorderHeld;
	alias BeginCount = beginCount;
	alias BeginCountPreviousFrame = beginCountPreviousFrame;
	alias BeginOrderWithinParent = beginOrderWithinParent;
	alias BeginOrderWithinContext = beginOrderWithinContext;
	alias FocusOrder = focusOrder;
	alias AutoFitFramesX = autoFitFramesX;
	alias AutoFitFramesY = autoFitFramesY;
	alias AutoFitOnlyGrows = autoFitOnlyGrows;
	alias AutoPosLastDirection = autoPosLastDirection;
	alias HiddenFramesCanSkipItems = hiddenFramesCanSkipItems;
	alias HiddenFramesCannotSkipItems = hiddenFramesCannotSkipItems;
	alias HiddenFramesForRenderOnly = hiddenFramesForRenderOnly;
	alias DisableInputsFrames = disableInputsFrames;
	alias SetWindowPosAllowFlags = setWindowPosAllowFlags;
	alias SetWindowSizeAllowFlags = setWindowSizeAllowFlags;
	alias SetWindowCollapsedAllowFlags = setWindowCollapsedAllowFlags;
	alias SetWindowPosVal = setWindowPosVal;
	alias SetWindowPosPivot = setWindowPosPivot;
	
	alias IDStack = idStack;
	alias DC = dc;
	
	alias OuterRectClipped = outerRectClipped;
	alias InnerRect = innerRect;
	alias InnerClipRect = innerClipRect;
	alias WorkRect = workRect;
	alias ParentWorkRect = parentWorkRect;
	alias ClipRect = clipRect;
	alias ContentRegionRect = contentRegionRect;
	alias HitTestHoleSize = hitTestHoleSize;
	alias HitTestHoleOffset = hitTestHoleOffset;
	
	alias LastFrameActive = lastFrameActive;
	alias LastTimeActive = lastTimeActive;
	alias ItemWidthDefault = itemWidthDefault;
	alias StateStorage = stateStorage;
	alias ColumnsStorage = columnsStorage;
	alias FontWindowScale = fontWindowScale;
	alias SettingsOffset = settingsOffset;
	
	alias DrawList = drawList;
	alias DrawListInst = drawListInst;
	alias ParentWindow = parentWindow;
	alias ParentWindowInBeginStack = parentWindowInBeginStack;
	alias RootWindow = rootWindow;
	alias RootWindowPopupTree = rootWindowPopupTree;
	alias RootWindowForTitleBarHighlight = rootWindowForTitleBarHighlight;
	alias RootWindowForNav = rootWindowForNav;
	alias ParentWindowForFocusRoute = parentWindowForFocusRoute;
	
	alias NavLastChildNavWindow = navLastChildNavWindow;
	alias NavLastIds = navLastIDs;
	alias NavRectRel = navRectRel;
	alias NavPreferredScoringPosRel = navPreferredScoringPosRel;
	alias NavRootFocusScopeId = navRootFocusScopeID;
	
	alias MemoryDrawListIdxCapacity = memoryDrawListIdxCapacity;
	alias MemoryDrawListVtxCapacity = memoryDrawListVtxCapacity;
	alias MemoryCompacted = memoryCompacted;
}

extern(C++) struct ImGuiTabItem{
	ImGuiID id;
	ImGuiTabItemFlags_ flags;
	int lastFrameVisible = -1;
	int lastFrameSelected = -1;
	float offset = 0f;
	float width = 0f;
	float contentWidth = 0f;
	float requestedWidth = -1f;
	int nameOffset = -1;
	short beginOrder = -1;
	short indexDuringLayout = -1;
	bool wantClose;
	
	alias ID = id;
	alias Flags = flags;
	alias LastFrameVisible = lastFrameVisible;
	alias LastFrameSelected = lastFrameSelected;
	alias Offset = offset;
	alias Width = width;
	alias ContentWidth = contentWidth;
	alias RequestedWidth = requestedWidth;
	alias NameOffset = nameOffset;
	alias BeginOrder = beginOrder;
	alias IndexDuringLayout = indexDuringLayout;
	alias WantClose = wantClose;
}

extern(C++) struct ImGuiTabBar{
	ImGuiWindow* window;
	ImVector!(ImGuiTabItem) tabs;
	ImGuiTabBarFlags_ flags;
	ImGuiID id;
	ImGuiID selectedTabID;
	ImGuiID nextSelectedTabID;
	ImGuiID visibleTabID;
	int currFrameVisible;
	int prevFrameVisible;
	ImRect barRect;
	float currTabsContentsHeight = 0f;
	float prevTabsContentsHeight = 0f;
	float widthAllTabs = 0f;
	float widthAllTabsIdeal = 0f;
	float scrollingAnim = 0f;
	float scrollingTarget = 0f;
	float scrollingTargetDistToVisibility = 0f;
	float scrollingSpeed = 0f;
	float scrollingRectMinX = 0f;
	float scrollingRectMaxX = 0f;
	float separatorMinX = 0f;
	float separatorMaxX = 0f;
	ImGuiID reorderRequestTabID;
	short reorderRequestOffset;
	byte beginCount;
	bool wantLayout;
	bool visibleTabWasSubmitted;
	bool tabsAddedNew;
	short tabsActiveCount;
	short lastTabItemIdx;
	float itemSpacingY = 0f;
	ImVec2 framePadding;
	ImVec2 backupCursorPos;
	ImGuiTextBuffer tabsNames;
	
	alias Window = window;
	alias Tabs = tabs;
	alias Flags = flags;
	alias ID = id;
	alias SelectedTabId = selectedTabID;
	alias NextSelectedTabId = nextSelectedTabID;
	alias VisibleTabId = visibleTabID;
	alias CurrFrameVisible = currFrameVisible;
	alias PrevFrameVisible = prevFrameVisible;
	alias BarRect = barRect;
	alias CurrTabsContentsHeight = currTabsContentsHeight;
	alias PrevTabsContentsHeight = prevTabsContentsHeight;
	alias WidthAllTabs = widthAllTabs;
	alias WidthAllTabsIdeal = widthAllTabsIdeal;
	alias ScrollingAnim = scrollingAnim;
	alias ScrollingTarget = scrollingTarget;
	alias ScrollingTargetDistToVisibility = scrollingTargetDistToVisibility;
	alias ScrollingSpeed = scrollingSpeed;
	alias ScrollingRectMinX = scrollingRectMinX;
	alias ScrollingRectMaxX = scrollingRectMaxX;
	alias SeparatorMinX = separatorMinX;
	alias SeparatorMaxX = separatorMaxX;
	alias ReorderRequestTabId = reorderRequestTabID;
	alias ReorderRequestOffset = reorderRequestOffset;
	alias BeginCount = beginCount;
	alias WantLayout = wantLayout;
	alias VisibleTabWasSubmitted = visibleTabWasSubmitted;
	alias TabsAddedNew = tabsAddedNew;
	alias TabsActiveCount = tabsActiveCount;
	alias LastTabItemIdx = lastTabItemIdx;
	alias ItemSpacingY = itemSpacingY;
	alias FramePadding = framePadding;
	alias BackupCursorPos = backupCursorPos;
	alias TabsNames = tabsNames;
}

extern(C++) struct ImGuiTableColumn{
	ImGuiTableColumnFlags_ flags;
	float widthGiven = 0f;
	float minX = 0f;
	float maxX = 0f;
	float widthRequest = -1f;
	float widthAuto = 0f;
	float widthMax = 0f;
	float stretchWeight = -1f;
	float initStretchWeightOrWidth = 0f;
	ImRect clipRect;
	ImGuiID userID;
	float workMinX = 0f;
	float workMaxX = 0f;
	float itemWidth = 0f;
	float contentMaxXFrozen = 0f;
	float contentMaxXUnfrozen = 0f;
	float contentMaxXHeadersUsed = 0f;
	float contentMaxXHeadersIdeal = 0f;
	short nameOffset = -1;
	ImGuiTableColumnIdx displayOrder = -1;
	ImGuiTableColumnIdx indexWithinEnabledSet = -1;
	ImGuiTableColumnIdx prevEnabledColumn = -1;
	ImGuiTableColumnIdx nextEnabledColumn = -1;
	ImGuiTableColumnIdx sortOrder = -1;
	ImGuiTableDrawChannelIdx drawChannelCurrent = cast(ubyte)-1;
	ImGuiTableDrawChannelIdx drawChannelFrozen = cast(ubyte)-1;
	ImGuiTableDrawChannelIdx drawChannelUnfrozen = cast(ubyte)-1;
	bool isEnabled;
	bool isUserEnabled;
	bool isUserEnabledNextFrame;
	bool isVisibleX;
	bool isVisibleY;
	bool isRequestOutput;
	bool isSkipItems;
	bool isPreserveWidthAuto;
	byte navLayerCurrent;
	ubyte autoFitQueue;
	ubyte cannotSkipItemsQueue;
	mixin(bitfields!(
		ubyte, q{sortDirection}, 2,
		ubyte, q{sortDirectionsAvailCount}, 2,
		ubyte, q{sortDirectionsAvailMask}, 4,
	));
	ubyte sortDirectionsAvailList;
	
	alias Flags = flags;
	alias WidthGiven = widthGiven;
	alias MinX = minX;
	alias MaxX = maxX;
	alias WidthRequest = widthRequest;
	alias WidthAuto = widthAuto;
	alias WidthMax = widthMax;
	alias StretchWeight = stretchWeight;
	alias InitStretchWeightOrWidth = initStretchWeightOrWidth;
	alias ClipRect = clipRect;
	alias UserID = userID;
	alias WorkMinX = workMinX;
	alias WorkMaxX = workMaxX;
	alias ItemWidth = itemWidth;
	alias ContentMaxXFrozen = contentMaxXFrozen;
	alias ContentMaxXUnfrozen = contentMaxXUnfrozen;
	alias ContentMaxXHeadersUsed = contentMaxXHeadersUsed;
	alias ContentMaxXHeadersIdeal = contentMaxXHeadersIdeal;
	alias NameOffset = nameOffset;
	alias DisplayOrder = displayOrder;
	alias IndexWithinEnabledSet = indexWithinEnabledSet;
	alias PrevEnabledColumn = prevEnabledColumn;
	alias NextEnabledColumn = nextEnabledColumn;
	alias SortOrder = sortOrder;
	alias DrawChannelCurrent = drawChannelCurrent;
	alias DrawChannelFrozen = drawChannelFrozen;
	alias DrawChannelUnfrozen = drawChannelUnfrozen;
	alias IsEnabled = isEnabled;
	alias IsUserEnabled = isUserEnabled;
	alias IsUserEnabledNextFrame = isUserEnabledNextFrame;
	alias IsVisibleX = isVisibleX;
	alias IsVisibleY = isVisibleY;
	alias IsRequestOutput = isRequestOutput;
	alias IsSkipItems = isSkipItems;
	alias IsPreserveWidthAuto = isPreserveWidthAuto;
	alias NavLayerCurrent = navLayerCurrent;
	alias AutoFitQueue = autoFitQueue;
	alias CannotSkipItemsQueue = cannotSkipItemsQueue;
	alias SortDirection = sortDirection;
	alias SortDirectionsAvailCount = sortDirectionsAvailCount;
	alias SortDirectionsAvailMask = sortDirectionsAvailMask;
	alias SortDirectionsAvailList = sortDirectionsAvailList;
}

extern(C++) struct ImGuiTableCellData{
	uint bgColour;
	ImGuiTableColumnIdx column;
	
	alias BgColour = bgColour;
	alias BgColor = bgColour;
	alias bgColor = bgColour;
	alias Column = column;
}

extern(C++) struct ImGuiTableHeaderData{
	ImGuiTableColumnIdx index;
	uint textColour;
	uint bgColour0;
	uint bgColour1;
	
	alias Index = index;
	alias TextColour = textColour;
	alias TextColor = textColour;
	alias textColor = textColour;
	alias BgColour0 = bgColour0;
	alias BgColor0 = bgColour0;
	alias bgColor0 = bgColour0;
	alias BgColour1 = bgColour1;
	alias BgColor1 = bgColour1;
	alias bgColor1 = bgColour1;
}

extern(C++) struct ImGuiTableInstanceData{
	ImGuiID tableInstanceID;
	float lastOuterHeight = 0f;
	float lastTopHeadersRowHeight = 0f;
	float lastFrozenHeight = 0f;
	int hoveredRowLast = -1;
	int hoveredRowNext = -1;
	
	alias TableInstanceID = tableInstanceID;
	alias LastOuterHeight = lastOuterHeight;
	alias LastTopHeadersRowHeight = lastTopHeadersRowHeight;
	alias LastFrozenHeight = lastFrozenHeight;
	alias HoveredRowLast = hoveredRowLast;
	alias HoveredRowNext = hoveredRowNext;
}

extern(C++) struct ImGuiTable{
	ImGuiID id;
	ImGuiTableFlags_ flags;
	void* rawData;
	ImGuiTableTempData* tempData;
	ImSpan!(ImGuiTableColumn) columns;
	ImSpan!(ImGuiTableColumnIdx) displayOrderToIndex;
	ImSpan!(ImGuiTableCellData) rowCellData;
	ImBitArrayPtr enabledMaskByDisplayOrder;
	ImBitArrayPtr enabledMaskByIndex;
	ImBitArrayPtr visibleMaskByIndex;
	ImGuiTableFlags_ settingsLoadedFlags;
	int settingsOffset;
	int lastFrameActive = -1;
	int columnsCount;
	int currentRow;
	int currentColumn;
	short instanceCurrent;
	short instanceInteracted;
	float rowPosY1 = 0f;
	float rowPosY2 = 0f;
	float rowMinHeight = 0f;
	float rowCellPaddingY = 0f;
	float rowTextBaseline = 0f;
	float rowIndentOffsetX = 0f;
	mixin(bitfields!(
		ImGuiTableRowFlags_, q{rowFlags}, 16,
		ImGuiTableRowFlags_, q{lastRowFlags}, 16,
	));
	int rowBgColourCounter;
	uint[2] rowBgColour;
	uint borderColourStrong;
	uint borderColourLight;
	float borderX1 = 0f;
	float borderX2 = 0f;
	float hostIndentX = 0f;
	float minColumnWidth = 0f;
	float outerPaddingX = 0f;
	float cellPaddingX = 0f;
	float cellSpacingX1 = 0f;
	float cellSpacingX2 = 0f;
	float innerWidth = 0f;
	float columnsGivenWidth = 0f;
	float columnsAutoFitWidth = 0f;
	float columnsStretchSumWeights = 0f;
	float resizedColumnNextWidth = 0f;
	float resizeLockMinContentsX2 = 0f;
	float refScale = 0f;
	float angledHeadersHeight = 0f;
	float angledHeadersSlope = 0f;
	ImRect outerRect;
	ImRect innerRect;
	ImRect workRect;
	ImRect innerClipRect;
	ImRect bgClipRect;
	ImRect bg0ClipRectForDrawCmd;
	ImRect bg2ClipRectForDrawCmd;
	ImRect hostClipRect;
	ImRect hostBackupInnerClipRect;
	ImGuiWindow* outerWindow;
	ImGuiWindow* innerWindow;
	ImGuiTextBuffer columnsNames;
	ImDrawListSplitter* drawSplitter;
	ImGuiTableInstanceData instanceDataFirst;
	ImVector!(ImGuiTableInstanceData) instanceDataExtra;
	ImGuiTableColumnSortSpecs sortSpecsSingle;
	ImVector!(ImGuiTableColumnSortSpecs) sortSpecsMulti;
	ImGuiTableSortSpecs sortSpecs;
	ImGuiTableColumnIdx sortSpecsCount;
	ImGuiTableColumnIdx columnsEnabledCount;
	ImGuiTableColumnIdx columnsEnabledFixedCount;
	ImGuiTableColumnIdx declColumnsCount;
	ImGuiTableColumnIdx angledHeadersCount;
	ImGuiTableColumnIdx hoveredColumnBody;
	ImGuiTableColumnIdx hoveredColumnBorder;
	ImGuiTableColumnIdx highlightColumnHeader;
	ImGuiTableColumnIdx autoFitSingleColumn;
	ImGuiTableColumnIdx resizedColumn;
	ImGuiTableColumnIdx lastResizedColumn;
	ImGuiTableColumnIdx heldHeaderColumn;
	ImGuiTableColumnIdx reorderColumn;
	ImGuiTableColumnIdx reorderColumnDir;
	ImGuiTableColumnIdx leftMostEnabledColumn;
	ImGuiTableColumnIdx rightMostEnabledColumn;
	ImGuiTableColumnIdx leftMostStretchedColumn;
	ImGuiTableColumnIdx rightMostStretchedColumn;
	ImGuiTableColumnIdx contextPopupColumn;
	ImGuiTableColumnIdx freezeRowsRequest;
	ImGuiTableColumnIdx freezeRowsCount;
	ImGuiTableColumnIdx freezeColumnsRequest;
	ImGuiTableColumnIdx freezeColumnsCount;
	ImGuiTableColumnIdx rowCellDataCurrent;
	ImGuiTableDrawChannelIdx dummyDrawChannel;
	ImGuiTableDrawChannelIdx bg2DrawChannelCurrent;
	ImGuiTableDrawChannelIdx bg2DrawChannelUnfrozen;
	bool isLayoutLocked;
	bool isInsideRow;
	bool isInitializing;
	bool isSortSpecsDirty;
	bool isUsingHeaders;
	bool isContextPopupOpen;
	bool disableDefaultContextMenu;
	bool isSettingsRequestLoad;
	bool isSettingsDirty;
	bool isDefaultDisplayOrder;
	bool isResetAllRequest;
	bool isResetDisplayOrderRequest;
	bool isUnfrozenRows;
	bool isDefaultSizingPolicy;
	bool isActiveIDAliveBeforeTable;
	bool isActiveIDInTable;
	bool hasScrollbarYCurr;
	bool hasScrollbarYPrev;
	bool memoryCompacted;
	bool hostSkipItems;
	
	alias ID = id;
	alias Flags = flags;
	alias RawData = rawData;
	alias TempData = tempData;
	alias Columns = columns;
	alias DisplayOrderToIndex = displayOrderToIndex;
	alias RowCellData = rowCellData;
	alias EnabledMaskByDisplayOrder = enabledMaskByDisplayOrder;
	alias EnabledMaskByIndex = enabledMaskByIndex;
	alias VisibleMaskByIndex = visibleMaskByIndex;
	alias SettingsLoadedFlags = settingsLoadedFlags;
	alias SettingsOffset = settingsOffset;
	alias LastFrameActive = lastFrameActive;
	alias ColumnsCount = columnsCount;
	alias CurrentRow = currentRow;
	alias CurrentColumn = currentColumn;
	alias InstanceCurrent = instanceCurrent;
	alias InstanceInteracted = instanceInteracted;
	alias RowPosY1 = rowPosY1;
	alias RowPosY2 = rowPosY2;
	alias RowMinHeight = rowMinHeight;
	alias RowCellPaddingY = rowCellPaddingY;
	alias RowTextBaseline = rowTextBaseline;
	alias RowIndentOffsetX = rowIndentOffsetX;
	alias RowFlags = rowFlags;
	alias LastRowFlags = lastRowFlags;
	alias RowBgColourCounter = rowBgColourCounter;
	alias RowBgColorCounter = rowBgColourCounter;
	alias rowBgColorCounter = rowBgColourCounter;
	alias RowBgColour = rowBgColour;
	alias RowBgColor = rowBgColour;
	alias rowBgColor = rowBgColour;
	alias BorderColourStrong = borderColourStrong;
	alias BorderColorStrong = borderColourStrong;
	alias borderColorStrong = borderColourStrong;
	alias BorderColourLight = borderColourLight;
	alias BorderColorLight = borderColourLight;
	alias borderColorLight = borderColourLight;
	alias BorderX1 = borderX1;
	alias BorderX2 = borderX2;
	alias HostIndentX = hostIndentX;
	alias MinColumnWidth = minColumnWidth;
	alias OuterPaddingX = outerPaddingX;
	alias CellPaddingX = cellPaddingX;
	alias CellSpacingX1 = cellSpacingX1;
	alias CellSpacingX2 = cellSpacingX2;
	alias InnerWidth = innerWidth;
	alias ColumnsGivenWidth = columnsGivenWidth;
	alias ColumnsAutoFitWidth = columnsAutoFitWidth;
	alias ColumnsStretchSumWeights = columnsStretchSumWeights;
	alias ResizedColumnNextWidth = resizedColumnNextWidth;
	alias ResizeLockMinContentsX2 = resizeLockMinContentsX2;
	alias RefScale = refScale;
	alias AngledHeadersHeight = angledHeadersHeight;
	alias AngledHeadersSlope = angledHeadersSlope;
	alias OuterRect = outerRect;
	alias InnerRect = innerRect;
	alias WorkRect = workRect;
	alias InnerClipRect = innerClipRect;
	alias BgClipRect = bgClipRect;
	alias Bg0ClipRectForDrawCmd = bg0ClipRectForDrawCmd;
	alias Bg2ClipRectForDrawCmd = bg2ClipRectForDrawCmd;
	alias HostClipRect = hostClipRect;
	alias HostBackupInnerClipRect = hostBackupInnerClipRect;
	alias OuterWindow = outerWindow;
	alias InnerWindow = innerWindow;
	alias ColumnsNames = columnsNames;
	alias DrawSplitter = drawSplitter;
	alias InstanceDataFirst = instanceDataFirst;
	alias InstanceDataExtra = instanceDataExtra;
	alias SortSpecsSingle = sortSpecsSingle;
	alias SortSpecsMulti = sortSpecsMulti;
	alias SortSpecs = sortSpecs;
	alias SortSpecsCount = sortSpecsCount;
	alias ColumnsEnabledCount = columnsEnabledCount;
	alias ColumnsEnabledFixedCount = columnsEnabledFixedCount;
	alias DeclColumnsCount = declColumnsCount;
	alias AngledHeadersCount = angledHeadersCount;
	alias HoveredColumnBody = hoveredColumnBody;
	alias HoveredColumnBorder = hoveredColumnBorder;
	alias HighlightColumnHeader = highlightColumnHeader;
	alias AutoFitSingleColumn = autoFitSingleColumn;
	alias ResizedColumn = resizedColumn;
	alias LastResizedColumn = lastResizedColumn;
	alias HeldHeaderColumn = heldHeaderColumn;
	alias ReorderColumn = reorderColumn;
	alias ReorderColumnDir = reorderColumnDir;
	alias LeftMostEnabledColumn = leftMostEnabledColumn;
	alias RightMostEnabledColumn = rightMostEnabledColumn;
	alias LeftMostStretchedColumn = leftMostStretchedColumn;
	alias RightMostStretchedColumn = rightMostStretchedColumn;
	alias ContextPopupColumn = contextPopupColumn;
	alias FreezeRowsRequest = freezeRowsRequest;
	alias FreezeRowsCount = freezeRowsCount;
	alias FreezeColumnsRequest = freezeColumnsRequest;
	alias FreezeColumnsCount = freezeColumnsCount;
	alias RowCellDataCurrent = rowCellDataCurrent;
	alias DummyDrawChannel = dummyDrawChannel;
	alias Bg2DrawChannelCurrent = bg2DrawChannelCurrent;
	alias Bg2DrawChannelUnfrozen = bg2DrawChannelUnfrozen;
	alias IsLayoutLocked = isLayoutLocked;
	alias IsInsideRow = isInsideRow;
	alias IsInitializing = isInitializing;
	alias IsSortSpecsDirty = isSortSpecsDirty;
	alias IsUsingHeaders = isUsingHeaders;
	alias IsContextPopupOpen = isContextPopupOpen;
	alias DisableDefaultContextMenu = disableDefaultContextMenu;
	alias IsSettingsRequestLoad = isSettingsRequestLoad;
	alias IsSettingsDirty = isSettingsDirty;
	alias IsDefaultDisplayOrder = isDefaultDisplayOrder;
	alias IsResetAllRequest = isResetAllRequest;
	alias IsResetDisplayOrderRequest = isResetDisplayOrderRequest;
	alias IsUnfrozenRows = isUnfrozenRows;
	alias IsDefaultSizingPolicy = isDefaultSizingPolicy;
	alias IsActiveIdAliveBeforeTable = isActiveIDAliveBeforeTable;
	alias IsActiveIdInTable = isActiveIDInTable;
	alias HasScrollbarYCurr = hasScrollbarYCurr;
	alias HasScrollbarYPrev = hasScrollbarYPrev;
	alias MemoryCompacted = memoryCompacted;
	alias HostSkipItems = hostSkipItems;
}

extern(C++) struct ImGuiTableTempData{
	int tableIndex;
	float lastTimeActive = -1f;
	float angledHeadersExtraWidth = 0f;
	ImVector!(ImGuiTableHeaderData) angledHeadersRequests;
	
	ImVec2 userOuterSize;
	ImDrawListSplitter drawSplitter;
	
	ImRect hostBackupWorkRect;
	ImRect hostBackupParentWorkRect;
	ImVec2 hostBackupPrevLineSize;
	ImVec2 hostBackupCurrLineSize;
	ImVec2 hostBackupCursorMaxPos;
	ImVec1 hostBackupColumnsOffset;
	float hostBackupItemWidth = 0f;
	int hostBackupItemWidthStackSize;
	
	alias TableIndex = tableIndex;
	alias LastTimeActive = lastTimeActive;
	alias AngledHeadersExtraWidth = angledHeadersExtraWidth;
	alias AngledHeadersRequests = angledHeadersRequests;
	
	alias UserOuterSize = userOuterSize;
	alias DrawSplitter = drawSplitter;
	
	alias HostBackupWorkRect = hostBackupWorkRect;
	alias HostBackupParentWorkRect = hostBackupParentWorkRect;
	alias HostBackupPrevLineSize = hostBackupPrevLineSize;
	alias HostBackupCurrLineSize = hostBackupCurrLineSize;
	alias HostBackupCursorMaxPos = hostBackupCursorMaxPos;
	alias HostBackupColumnsOffset = hostBackupColumnsOffset;
	alias HostBackupItemWidth = hostBackupItemWidth;
	alias HostBackupItemWidthStackSize = hostBackupItemWidthStackSize;
}

extern(C++) struct ImGuiTableColumnSettings{
	float widthOrWeight = 0f;
	ImGuiID userID;
	ImGuiTableColumnIdx index = -1;
	ImGuiTableColumnIdx displayOrder = -1;
	ImGuiTableColumnIdx sortOrder = -1;
	mixin(bitfields!(
		ubyte, q{sortDirection}, 2,
		ubyte, q{isEnabled}, 1,
		ubyte, q{isStretch}, 1,
		
		uint, q{}, 4,
	));
	
	alias WidthOrWeight = widthOrWeight;
	alias UserID = userID;
	alias Index = index;
	alias DisplayOrder = displayOrder;
	alias SortOrder = sortOrder;
	alias SortDirection = sortDirection;
	alias IsEnabled = isEnabled;
	alias IsStretch = isStretch;
}

extern(C++) struct ImGuiTableSettings{
	ImGuiID id;
	ImGuiTableFlags_ saveFlags;
	float refScale = 0f;
	ImGuiTableColumnIdx columnsCount;
	ImGuiTableColumnIdx columnsCountMax;
	bool wantApply;
	
	extern(D) mixin(joinFnBinds((){
		FnBind[] ret = [
			{q{ImGuiTableColumnSettings*}, q{GetColumnSettings}, q{}, ext: `C++`, aliases: [q{getColumnSettings}]},
		];
		return ret;
	}()));
	
	alias ID = id;
	alias SaveFlags = saveFlags;
	alias RefScale = refScale;
	alias ColumnsCount = columnsCount;
	alias ColumnsCountMax = columnsCountMax;
	alias WantApply = wantApply;
}

extern(C++) struct ImFontBuilderIO{
	private alias FontBuilderBuildFn = extern(C++) bool function(ImFontAtlas* atlas) nothrow @nogc;
	FontBuilderBuildFn fontBuilderBuild;
	
	alias FontBuilder_Build = fontBuilderBuild;
}


static if(!staticBinding):
import bindbc.loader;

mixin(makeDynloadFns("ImGui", makeLibPaths(["imgui"]), [__MODULE__]));

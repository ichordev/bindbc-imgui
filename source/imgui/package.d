/+
+                Copyright 2023 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui;

import bindbc.imgui.config;

import core.vararg: va_list;

public import
	imgui.demo;

enum IMGUI_VERSION        = "1.89.4";
enum IMGUI_VERSION_NUM    = 18940;

alias ImTextureID = void*;

version(ImGui_ImDrawIdx32){
	alias ImDrawIdx = uint;
}else{
	alias ImDrawIdx = ushort;
}

version(ImGui_WChar32){
	alias ImWchar = dchar;
}else{
	alias ImWchar = wchar;
}

alias ImGuiID = uint;

alias ImGuiInputTextCallback = extern(C++) int function(ImGuiInputTextCallbackData* data);
alias ImGuiSizeCallback = extern(C++) void function(ImGuiSizeCallbackData* data);
alias ImGuiMemAllocFunc = extern(C++) void* function(size_t sz, void* user_data);
alias ImGuiMemFreeFunc = extern(C++) void function(void* ptr, void* user_data);

extern(C++) struct ImVec2{
	float x=0f, y=0f;
	
	float opIndex(size_t idx) const;
	ref float opIndex(size_t idx);
}

extern(C++) struct ImVec4{
	float x=0f, y=0f, z=0f, w=0f;
}

struct ImGuiSizeCallbackData;
struct ImGuiInputTextCallbackData;
struct ImFont;
struct ImFontAtlas;
struct ImGuiContext;
struct ImGuiPayload;
struct ImGuiTableSortSpecs;
struct ImGuiViewport;
struct ImGuiStorage;
struct ImGuiStyle;
struct ImDrawData;
struct ImDrawList;
struct ImDrawListSharedData;
struct ImGuiIO{}//TODO:remove THISSS

extern(C++, "ImGui"){
	private alias ItemsGetterFn = extern(C++) bool function(void* data, int idx, const(char)** out_text);
	
	ImGuiContext* CreateContext(ImFontAtlas* shared_font_atlas=null);
	void DestroyContext(ImGuiContext* ctx=null);
	ImGuiContext* GetCurrentContext();
	void SetCurrentContext(ImGuiContext* ctx);
	
	ImGuiIO* GetIO();
	ImGuiStyle* GetStyle();
	void NewFrame();
	void EndFrame();
	void Render();
	ImDrawData* GetDrawData();
	
	void ShowDemoWindow(bool* p_open=null);
	void ShowMetricsWindow(bool* p_open=null);
	void ShowDebugLogWindow(bool* p_open=null);
	void ShowStackToolWindow(bool* p_open=null);
	void ShowAboutWindow(bool* p_open=null);
	void ShowStyleEditor(ImGuiStyle* ref_=null);
	bool ShowStyleSelector(const(char)* label);
	void ShowFontSelector(const(char)* label);
	void ShowUserGuide();
	const(char)* GetVersion();
	
	void StyleColorsDark(ImGuiStyle* dst=null);
	alias StyleColoursDark = StyleColorsDark;
	void StyleColorsLight(ImGuiStyle* dst=null);
	alias StyleColoursLight = StyleColorsLight;
	void StyleColorsClassic(ImGuiStyle* dst=null);
	alias StyleColoursClassic = StyleColorsClassic;
	
	bool Begin(const(char)* name, bool* p_open=null, ImGuiWindowFlags flags=ImGuiWindowFlags.None);
	void End();
	
	bool BeginChild(const(char)* str_id, const auto ref ImVec2 size=ImVec2(0, 0), bool border=false, ImGuiWindowFlags flags=ImGuiWindowFlags.None);
	bool BeginChild(ImGuiID id, const auto ref ImVec2 size=ImVec2(0, 0), bool border=false, ImGuiWindowFlags flags=ImGuiWindowFlags.None);
	void EndChild();
	
	bool IsWindowAppearing();
	bool IsWindowCollapsed();
	bool IsWindowFocused(ImGuiFocusedFlags flags=ImGuiFocusedFlags.None);
	bool IsWindowHovered(ImGuiHoveredFlags flags=ImGuiHoveredFlags.None);
	ImDrawList* GetWindowDrawList();
	ImVec2 GetWindowPos();
	ImVec2 GetWindowSize();
	float GetWindowWidth();
	float GetWindowHeight();
	
	void SetNextWindowPos(ref const(ImVec2) pos, ImGuiCond cond=ImGuiCond.None, const auto ref ImVec2 pivot=ImVec2(0, 0));
	void SetNextWindowSize(ref const(ImVec2) size, ImGuiCond cond=ImGuiCond.None);
	void SetNextWindowSizeConstraints(ref const(ImVec2) size_min, ref const(ImVec2) size_max, ImGuiSizeCallback custom_callback=null, void* custom_callback_data=null);
	void SetNextWindowContentSize(ref const(ImVec2) size);
	void SetNextWindowCollapsed(bool collapsed, ImGuiCond cond=ImGuiCond.None);
	void SetNextWindowFocus();
	void SetNextWindowScroll(ref const(ImVec2) scroll);
	void SetNextWindowBgAlpha(float alpha);
	void SetWindowPos(ref const(ImVec2) pos, ImGuiCond cond=ImGuiCond.None);
	void SetWindowSize(ref const(ImVec2) size, ImGuiCond cond=ImGuiCond.None);
	void SetWindowCollapsed(bool collapsed, ImGuiCond cond=ImGuiCond.None);
	void SetWindowFocus();
	void SetWindowFontScale(float scale);
	void SetWindowPos(const(char)* name, ref const(ImVec2) pos, ImGuiCond cond=ImGuiCond.None);
	void SetWindowSize(const(char)* name, ref const(ImVec2) size, ImGuiCond cond=ImGuiCond.None);
	void SetWindowCollapsed(const(char)* name, bool collapsed, ImGuiCond cond=ImGuiCond.None);
	void SetWindowFocus(const(char)* name);
	
	ImVec2 GetContentRegionAvail();
	ImVec2 GetContentRegionMax();
	ImVec2 GetWindowContentRegionMin();
	ImVec2 GetWindowContentRegionMax();
	
	float GetScrollX();
	float GetScrollY();
	void SetScrollX(float scroll_x);
	void SetScrollY(float scroll_y);
	float GetScrollMaxX();
	float GetScrollMaxY();
	void SetScrollHereX(float center_x_ratio=0.5f);
	void SetScrollHereY(float center_y_ratio=0.5f);
	void SetScrollFromPosX(float local_x, float center_x_ratio=0.5f);
	void SetScrollFromPosY(float local_y, float center_y_ratio=0.5f);
	void PushFont(ImFont* font);
	void PopFont();
	void PushStyleColor(ImGuiCol idx, uint col);
	void PushStyleColor(ImGuiCol idx, ref const(ImVec4) col);
	alias PushStyleColour = PushStyleColor;
	void PopStyleColor(int count=1);
	alias PopStyleColour = PopStyleColor;
	void PushStyleVar(ImGuiStyleVar idx, float val);
	void PushStyleVar(ImGuiStyleVar idx, ref const(ImVec2) val);
	void PopStyleVar(int count=1);
	void PushTabStop(bool tab_stop);
	void PopTabStop();
	void PushButtonRepeat(bool repeat);
	void PopButtonRepeat();
	
	void PushItemWidth(float item_width);
	void PopItemWidth();
	void SetNextItemWidth(float item_width);
	float CalcItemWidth();
	void PushTextWrapPos(float wrap_local_pos_x=0f);
	void PopTextWrapPos();
	
	ImFont* GetFont();
	float GetFontSize();
	ImVec2 GetFontTexUvWhitePixel();
	uint GetColorU32(ImGuiCol idx, float alpha_mul=1f);
	uint GetColorU32(ref const(ImVec4) col);
	uint GetColorU32(uint col);
	alias GetColourU32 = GetColorU32;
	const(ImVec4)* GetStyleColorVec4(ImGuiCol idx);
	alias GetStyleColourVec4 = GetStyleColorVec4;
	
	void Separator();
	void SameLine(float offset_from_start_x=0f, float spacing=-1f);
	void NewLine();
	void Spacing();
	void Dummy(ref const(ImVec2) size);
	void Indent(float indent_w=0f);
	void Unindent(float indent_w=0f);
	void BeginGroup();
	void EndGroup();
	ImVec2 GetCursorPos();
	float GetCursorPosX();
	float GetCursorPosY();
	void SetCursorPos(ref const(ImVec2) local_pos);
	void SetCursorPosX(float local_x);
	void SetCursorPosY(float local_y);
	ImVec2 GetCursorStartPos();
	ImVec2 GetCursorScreenPos();
	void SetCursorScreenPos(ref const(ImVec2) pos);
	void AlignTextToFramePadding();
	float GetTextLineHeight();
	float GetTextLineHeightWithSpacing();
	float GetFrameHeight();
	float GetFrameHeightWithSpacing();
	
	void PushID(const(char)* str_id);
	void PushID(const(char)* str_id_begin, const(char)* str_id_end);
	void PushID(const(void)* ptr_id);
	void PushID(int int_id);
	void PopID();
	ImGuiID GetID(const(char)* str_id);
	ImGuiID GetID(const(char)* str_id_begin, const(char)* str_id_end);
	ImGuiID GetID(const(void)* ptr_id);
	
	void TextUnformatted(const(char)* text, const(char)* text_end=null);
	void Text(const(char)* fmt, ...);
	void TextV(const(char)* fmt, va_list args);
	void TextColored(ref const(ImVec4) col, const(char)* fmt, ...);
	alias TextColoured = TextColored;
	void TextColoredV(ref const(ImVec4) col, const(char)* fmt, va_list args);
	alias TextColouredV = TextColoredV;
	void TextDisabled(const(char)* fmt, ...);
	void TextDisabledV(const(char)* fmt, va_list args);
	void TextWrapped(const(char)* fmt, ...);
	void TextWrappedV(const(char)* fmt, va_list args);
	void LabelText(const(char)* label, const(char)* fmt, ...);
	void LabelTextV(const(char)* label, const(char)* fmt, va_list args);
	void BulletText(const(char)* fmt, ...);
	void BulletTextV(const(char)* fmt, va_list args);
	void SeparatorText(const(char)* label);
	
	bool Button(const(char)* label, const auto ref ImVec2 size=ImVec2(0, 0));
	bool SmallButton(const(char)* label);
	bool InvisibleButton(const(char)* str_id, ref const(ImVec2) size, ImGuiButtonFlags flags=ImGuiButtonFlags.None);
	bool ArrowButton(const(char)* str_id, ImGuiDir dir);
	bool Checkbox(const(char)* label, bool* v);
	bool CheckboxFlags(const(char)* label, int* flags, int flags_value);
	bool CheckboxFlags(const(char)* label, uint* flags, uint flags_value);
	bool RadioButton(const(char)* label, bool active);
	bool RadioButton(const(char)* label, int* v, int v_button);
	void ProgressBar(float fraction, const auto ref ImVec2 size_arg=ImVec2(-float.min_normal, 0), const(char)* overlay=null);
	void Bullet();
	
	void Image(ImTextureID user_texture_id, ref const(ImVec2) size, const auto ref ImVec2 uv0=ImVec2(0, 0), const auto ref ImVec2 uv1=ImVec2(1, 1), const auto ref ImVec4 tint_col=ImVec4(1, 1, 1, 1), const auto ref ImVec4 border_col=ImVec4(0, 0, 0, 0));
	bool ImageButton(const(char)* str_id, ImTextureID user_texture_id, ref const(ImVec2) size, const auto ref ImVec2 uv0=ImVec2(0, 0), const auto ref ImVec2 uv1=ImVec2(1, 1), const auto ref ImVec4 bg_col=ImVec4(0, 0, 0, 0), const auto ref ImVec4 tint_col=ImVec4(1, 1, 1, 1));
	
	bool BeginCombo(const(char)* label, const(char)* preview_value, ImGuiComboFlags flags=ImGuiComboFlags.None);
	void EndCombo();
	bool Combo(const(char)* label, int* current_item, const(char*)* items, int items_count, int popup_max_height_in_items=-1);
	bool Combo(const(char)* label, int* current_item, const(char)* items_separated_by_zeros, int popup_max_height_in_items=-1);
	bool Combo(const(char)* label, int* current_item, ItemsGetterFn items_getter, void* data, int items_count, int popup_max_height_in_items=-1);
	
	bool DragFloat(const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragFloat2(const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragFloat3(const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragFloat4(const(char)* label, float* v, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragFloatRange2(const(char)* label, float* v_current_min, float* v_current_max, float v_speed=1f, float v_min=0f, float v_max=0f, const(char)* format="%.3f", const(char)* format_max=null, ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragInt(const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragInt2(const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragInt3(const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragInt4(const(char)* label, int* v, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragIntRange2(const(char)* label, int* v_current_min, int* v_current_max, float v_speed=1f, int v_min=0, int v_max=0, const(char)* format="%d", const(char)* format_max=null, ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragScalar(const(char)* label, ImGuiDataType data_type, void* p_data, float v_speed=1f, const(void)* p_min=null, const(void)* p_max=null, const(char)* format=null, ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool DragScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, float v_speed=1f, const(void)* p_min=null, const(void)* p_max=null, const(char)* format=null, ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	
	bool SliderFloat(const(char)* label, float* v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderFloat2(const(char)** label, float v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderFloat3(const(char)** label, float v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderFloat4(const(char)** label, float v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderAngle(const(char)* label, float* v_rad, float v_degrees_min=-360f, float v_degrees_max=+360f, const(char)* format="%.0f deg", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderInt(const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderInt2(const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderInt3(const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderInt4(const(char)* label, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format=null, ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool SliderScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const(void)* p_min, const(void)* p_max, const(char)* format=null, ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool VSliderFloat(const(char)* label, ref const(ImVec2) size, float* v, float v_min, float v_max, const(char)* format="%.3f", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool VSliderInt(const(char)* label, ref const(ImVec2) size, int* v, int v_min, int v_max, const(char)* format="%d", ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	bool VSliderScalar(const(char)* label, ref const(ImVec2) size, ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format=null, ImGuiSliderFlags flags=ImGuiSliderFlags.None);
	
	bool InputText(const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None, ImGuiInputTextCallback callback=null, void* user_data=null);
	bool InputTextMultiline(const(char)* label, char* buf, size_t buf_size, auto ref const(ImVec2) size=ImVec2(0, 0), ImGuiInputTextFlags flags=ImGuiInputTextFlags.None, ImGuiInputTextCallback callback=null, void* user_data=null);
	bool InputTextWithHint(const(char)* label, const(char)* hint, char* buf, size_t buf_size, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None, ImGuiInputTextCallback callback=null, void* user_data=null);
	bool InputFloat(const(char)* label, float* v, float step=0f, float step_fast=0f, const(char)* format="%.3f", ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputFloat2(const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputFloat3(const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputFloat4(const(char)* label, float* v, const(char)* format="%.3f", ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputInt(const(char)* label, int* v, int step=1, int step_fast=100, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputInt2(const(char)* label, int* v, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputInt3(const(char)* label, int* v, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputInt4(const(char)* label, int* v, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputDouble(const(char)* label, double* v, double step=0.0, double step_fast=0.0, const(char)* format="%.6f", ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const(void)* p_step=null, const(void)* p_step_fast=null, const(char)* format=null, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	bool InputScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const(void)* p_step=null, const(void)* p_step_fast=null, const(char)* format=null, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	
	bool ColorEdit3(const(char)* label, float* col, ImGuiColorEditFlags flags=ImGuiColorEditFlags.None);
	alias ColourEdit3 = ColorEdit3;
	bool ColorEdit4(const(char)* label, float* col, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	alias ColourEdit4 = ColorEdit4;
	bool ColorPicker3(const(char)* label, float* col, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None);
	alias ColourPicker3 = ColorPicker3;
	bool ColorPicker4(const(char)* label, float* col, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None, const(float)* ref_col=null);
	alias ColourPicker4 = ColorPicker4;
	bool ColorButton(const(char)* desc_id, ref const(ImVec4) col, ImGuiInputTextFlags flags=ImGuiInputTextFlags.None, auto ref const(ImVec2) size=ImVec2(0, 0));
	alias ColourButton = ColorButton;
	void SetColorEditOptions(ImGuiColorEditFlags flags);
	alias SetColourEditOptions = SetColorEditOptions;
	
	bool TreeNode(const(char)* label);
	bool TreeNode(const(char)* str_id, const(char)* fmt, ...);
	bool TreeNode(const(void)* ptr_id, const(char)* fmt, ...);
	bool TreeNodeV(const(char)* str_id, const(char)* fmt, va_list args);
	bool TreeNodeV(const(void)* ptr_id, const(char)* fmt, va_list args);
	bool TreeNodeEx(const(char)* label, ImGuiTreeNodeFlags flags=ImGuiTreeNodeFlags.None);
	bool TreeNodeEx(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...);
	bool TreeNodeEx(const(void)* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...);
	bool TreeNodeExV(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args);
	bool TreeNodeExV(const(void)* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args);
	void TreePush(const(char)* str_id);
	void TreePush(const(void)* ptr_id);
	void TreePop();
	float GetTreeNodeToLabelSpacing();
	bool CollapsingHeader(const(char)* label, ImGuiTreeNodeFlags flags=ImGuiTreeNodeFlags.None);
	bool CollapsingHeader(const(char)* label, bool* p_visible, ImGuiTreeNodeFlags flags=ImGuiTreeNodeFlags.None);
	void SetNextItemOpen(bool is_open, ImGuiCond cond=ImGuiCond.None);
	bool Selectable(const(char)* label, bool selected=false, ImGuiSelectableFlags flags=ImGuiSelectableFlags.None, auto ref const(ImVec2) size=ImVec2(0, 0));
	bool Selectable(const(char)* label, bool* p_selected, ImGuiSelectableFlags flags=ImGuiSelectableFlags.None, auto ref const(ImVec2) size=ImVec2(0, 0));
	bool BeginListBox(const(char)* label, auto ref const(ImVec2) size=ImVec2(0, 0));
	void EndListBox();
	bool ListBox(const(char)* label, int* current_item, const(char*)* items, int items_count, int height_in_items=-1);
	bool ListBox(const(char)* label, int* current_item, ItemsGetterFn items_getter, void* data, int items_count, int height_in_items=-1);
	
	private alias valuesGetterFn = extern(C++) float function(void* data, int idx);
	void PlotLines(const(char)* label, const(float)* values, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=ImVec2(0, 0), int stride=float.sizeof);
	void PlotLines(const(char)* label, valuesGetterFn values_getter, void* data, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=ImVec2(0, 0));
	void PlotHistogram(const(char)* label, const(float)* values, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=ImVec2(0, 0), int stride=float.sizeof);
	void PlotHistogram(const(char)* label, valuesGetterFn values_getter, void* data, int values_count, int values_offset=0, const(char)* overlay_text=null, float scale_min=float.max, float scale_max=float.max, ImVec2 graph_size=ImVec2(0, 0));
	
	void Value(const(char)* prefix, bool b);
	void Value(const(char)* prefix, int v);
	void Value(const(char)* prefix, uint v);
	void Value(const(char)* prefix, float v, const(char)* float_format=null);
	
	bool BeginMenuBar();
	void EndMenuBar();
	bool BeginMainMenuBar();
	void EndMainMenuBar();
	bool BeginMenu(const(char)* label, bool enabled=true);
	void EndMenu();
	bool MenuItem(const(char)* label, const(char)* shortcut=null, bool selected=false, bool enabled=true);
	bool MenuItem(const(char)* label, const(char)* shortcut, bool* p_selected, bool enabled=true);
	bool BeginTooltip();
	void EndTooltip();
	void SetTooltip(const(char)* fmt, ...);
	void SetTooltipV(const(char)* fmt, va_list args);
	
	bool BeginPopup(const(char)* str_id, ImGuiWindowFlags flags=ImGuiWindowFlags.None);
	bool BeginPopupModal(const(char)* name, bool* p_open=null, ImGuiWindowFlags flags=ImGuiWindowFlags.None);
	void EndPopup();
	
	void OpenPopup(const(char)* str_id, ImGuiPopupFlags popup_flags=ImGuiPopupFlags.None);
	void OpenPopup(ImGuiID id, ImGuiPopupFlags popup_flags=ImGuiPopupFlags.None);
	void OpenPopupOnItemClick(const(char)* str_id=null, ImGuiPopupFlags popup_flags=ImGuiPopupFlags.MouseButtonRight);
	void CloseCurrentPopup();
	
	bool BeginPopupContextItem(const(char)* str_id=null, ImGuiPopupFlags popup_flags=ImGuiPopupFlags.MouseButtonRight);
	bool BeginPopupContextWindow(const(char)* str_id=null, ImGuiPopupFlags popup_flags=ImGuiPopupFlags.MouseButtonRight);
	bool BeginPopupContextVoid(const(char)* str_id=null, ImGuiPopupFlags popup_flags=ImGuiPopupFlags.MouseButtonRight);
	bool IsPopupOpen(const(char)* str_id, ImGuiPopupFlags flags=ImGuiPopupFlags.None);
	bool BeginTable(const(char)* str_id, int column, ImGuiTableFlags flags= ImGuiTableFlags.None, auto ref const(ImVec2) outer_size=ImVec2(0f, 0f), float inner_width=0f);
	void EndTable();
	void TableNextRow(ImGuiTableRowFlags row_flags=ImGuiTableRowFlags.None, float min_row_height=0f);
	bool TableNextColumn();
	bool TableSetColumnIndex(int column_n);
	
	void TableSetupColumn(const(char)* label, ImGuiTableColumnFlags flags=ImGuiTableColumnFlags.None, float init_width_or_weight=0f, ImGuiID user_id=0);
	void TableSetupScrollFreeze(int cols, int rows);
	void TableHeadersRow();
	void TableHeader(const(char)* label);
	
	ImGuiTableSortSpecs* TableGetSortSpecs();
	int TableGetColumnCount();
	int TableGetColumnIndex();
	int TableGetRowIndex();
	const(char)* TableGetColumnName(int column_n=-1);
	ImGuiTableColumnFlags TableGetColumnFlags(int column_n=-1);
	void TableSetColumnEnabled(int column_n, bool v);
	void TableSetBgColor(ImGuiTableBgTarget target, uint color, int column_n=-1);
	alias TableSetBgColour = TableSetBgColor;
	void Columns(int count=1, const(char)* id=null, bool border=true);
	void NextColumn();
	int GetColumnIndex();
	float GetColumnWidth(int column_index=-1);
	void SetColumnWidth(int column_index, float width);
	float GetColumnOffset(int column_index=-1);
	void SetColumnOffset(int column_index, float offset_x);
	int GetColumnsCount();
	
	bool BeginTabBar(const(char)* str_id, ImGuiTabBarFlags flags=ImGuiTabBarFlags.None);
	void EndTabBar();
	bool BeginTabItem(const(char)* label, bool* p_open=null, ImGuiTabItemFlags flags=ImGuiTabItemFlags.None);
	void EndTabItem();
	bool TabItemButton(const(char)* label, ImGuiTabItemFlags flags=ImGuiTabItemFlags.None);
	void SetTabItemClosed(const(char)* tab_or_docked_window_label);
	
	void LogToTTY(int auto_open_depth=-1);
	void LogToFile(int auto_open_depth=-1, const(char)* filename=null);
	void LogToClipboard(int auto_open_depth=-1);
	void LogFinish();
	void LogButtons();
	void LogText(const(char)* fmt, ...);
	void LogTextV(const(char)* fmt, va_list args);
	
	bool BeginDragDropSource(ImGuiDragDropFlags flags=ImGuiDragDropFlags.None);
	bool SetDragDropPayload(const(char)* type, const(void)* data, size_t sz, ImGuiCond cond=ImGuiCond.None);
	void EndDragDropSource();
	bool BeginDragDropTarget();
	const(ImGuiPayload)* AcceptDragDropPayload(const(char)* type, ImGuiDragDropFlags flags=ImGuiDragDropFlags.None);
	void EndDragDropTarget();
	const(ImGuiPayload)* GetDragDropPayload();
	
	void BeginDisabled(bool disabled=true);
	void EndDisabled();
	
	void PushClipRect(ref const(ImVec2) clip_rect_min, ref const(ImVec2) clip_rect_max, bool intersect_with_current_clip_rect);
	void PopClipRect();
	
	void SetItemDefaultFocus();
	void SetKeyboardFocusHere(int offset=0);
	
	bool IsItemHovered(ImGuiHoveredFlags flags=ImGuiHoveredFlags.None);
	bool IsItemActive();
	bool IsItemFocused();
	bool IsItemClicked(ImGuiMouseButton mouse_button=ImGuiMouseButton.Left);
	bool IsItemVisible();
	bool IsItemEdited();
	bool IsItemActivated();
	bool IsItemDeactivated();
	bool IsItemDeactivatedAfterEdit();
	bool IsItemToggledOpen();
	bool IsAnyItemHovered();
	bool IsAnyItemActive();
	bool IsAnyItemFocused();
	ImGuiID GetItemID();
	ImVec2 GetItemRectMin();
	ImVec2 GetItemRectMax();
	ImVec2 GetItemRectSize();
	void SetItemAllowOverlap();
	
	ImGuiViewport* GetMainViewport();
	
	ImDrawList* GetBackgroundDrawList();
	ImDrawList* GetForegroundDrawList();
	
	bool IsRectVisible(ref const(ImVec2) size);
	bool IsRectVisible(ref const(ImVec2) rect_min, ref const(ImVec2) rect_max);
	double GetTime();
	int GetFrameCount();
	ImDrawListSharedData* GetDrawListSharedData();
	const(char)* GetStyleColorName(ImGuiCol idx);
	alias GetStyleColourName = GetStyleColorName;
	void SetStateStorage(ImGuiStorage* storage);
	ImGuiStorage* GetStateStorage();
	bool BeginChildFrame(ImGuiID id, ref const(ImVec2) size, ImGuiWindowFlags flags=ImGuiWindowFlags.None);
	void EndChildFrame();
	
	ImVec2 CalcTextSize(const(char)* text, const(char)* text_end=null, bool hide_text_after_double_hash=false, float wrap_width=-1f);
	
	ImVec4 ColorConvertU32ToFloat4(uint in_);
	alias ColourConvertU32ToFloat4 = ColorConvertU32ToFloat4;
	uint ColorConvertFloat4ToU32(ref const(ImVec4) inP);
	alias ColourConvertFloat4ToU32 = ColorConvertFloat4ToU32;
	void ColorConvertRGBtoHSV(float r, float g, float b, ref float out_h, ref float out_s, ref float out_v);
	alias ColourConvertRGBtoHSV = ColorConvertRGBtoHSV;
	void ColorConvertHSVtoRGB(float h, float s, float v, ref float out_r, ref float out_g, ref float out_b);
	alias ColourConvertHSVtoRGB = ColorConvertHSVtoRGB;
	
	bool IsKeyDown(ImGuiKey key);
	bool IsKeyPressed(ImGuiKey key, bool repeat=true);
	bool IsKeyReleased(ImGuiKey key);
	int GetKeyPressedAmount(ImGuiKey key, float repeat_delay, float rate);
	const(char)* GetKeyName(ImGuiKey key);
	void SetNextFrameWantCaptureKeyboard(bool want_capture_keyboard);
	
	bool IsMouseDown(ImGuiMouseButton button);
	bool IsMouseClicked(ImGuiMouseButton button, bool repeat=false);
	bool IsMouseReleased(ImGuiMouseButton button);
	bool IsMouseDoubleClicked(ImGuiMouseButton button);
	int GetMouseClickedCount(ImGuiMouseButton button);
	bool IsMouseHoveringRect(ref const(ImVec2) r_min, ref const(ImVec2) r_max, bool clip=true);
	bool IsMousePosValid(const(ImVec2)* mouse_pos=null);
	bool IsAnyMouseDown();
	ImVec2 GetMousePos();
	ImVec2 GetMousePosOnOpeningCurrentPopup();
	bool IsMouseDragging(ImGuiMouseButton button, float lock_threshold=-1f);
	ImVec2 GetMouseDragDelta(ImGuiMouseButton button=ImGuiMouseButton.Left, float lock_threshold=-1f);
	void ResetMouseDragDelta(ImGuiMouseButton button=ImGuiMouseButton.Left);
	ImGuiMouseCursor GetMouseCursor();
	void SetMouseCursor(ImGuiMouseCursor cursor_type);
	void SetNextFrameWantCaptureMouse(bool want_capture_mouse);
	
	const(char)* GetClipboardText();
	void SetClipboardText(const(char)* text);
	
	void LoadIniSettingsFromDisk(const(char)* ini_filename);
	void LoadIniSettingsFromMemory(const(char)* ini_data, size_t ini_size=0);
	void SaveIniSettingsToDisk(const(char)* ini_filename);
	const(char)* SaveIniSettingsToMemory(size_t* out_ini_size=null);
	
	void DebugTextEncoding(const(char)* text);
	bool DebugCheckVersionAndDataLayout(const(char)* version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert, size_t sz_drawidx);
	void SetAllocatorFunctions(ImGuiMemAllocFunc alloc_func, ImGuiMemFreeFunc free_func, void* user_data=null);
	void GetAllocatorFunctions(ImGuiMemAllocFunc* p_alloc_func, ImGuiMemFreeFunc* p_free_func, void** p_user_data);
	void* MemAlloc(size_t size);
	void MemFree(void* ptr);
}

enum ImGuiWindowFlags: int{
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
	AlwaysHorizontalScrollbar = 1<< 15,
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

enum ImGuiInputTextFlags: int{
	None                = 0,
	CharsDecimal        = 1 << 0,
	CharsHexadecimal    = 1 << 1,
	CharsUppercase      = 1 << 2,
	CharsNoBlank        = 1 << 3,
	AutoSelectAll       = 1 << 4,
	EnterReturnsTrue    = 1 << 5,
	CallbackCompletion  = 1 << 6,
	CallbackHistory     = 1 << 7,
	CallbackAlways      = 1 << 8,
	CallbackCharFilter  = 1 << 9,
	AllowTabInput       = 1 << 10,
	CtrlEnterForNewLine = 1 << 11,
	NoHorizontalScroll  = 1 << 12,
	AlwaysOverwrite     = 1 << 13,
	ReadOnly            = 1 << 14,
	Password            = 1 << 15,
	NoUndoRedo          = 1 << 16,
	CharsScientific     = 1 << 17,
	CallbackResize      = 1 << 18,
	CallbackEdit        = 1 << 19,
	EscapeClearsAll     = 1 << 20,
}

enum ImGuiTreeNodeFlags: int{
	None                 = 0,
	Selected             = 1 << 0,
	Framed               = 1 << 1,
	AllowItemOverlap     = 1 << 2,
	NoTreePushOnOpen     = 1 << 3,
	NoAutoOpenOnLog      = 1 << 4,
	DefaultOpen          = 1 << 5,
	OpenOnDoubleClick    = 1 << 6,
	OpenOnArrow          = 1 << 7,
	Leaf                 = 1 << 8,
	Bullet               = 1 << 9,
	FramePadding         = 1 << 10,
	SpanAvailWidth       = 1 << 11,
	SpanFullWidth        = 1 << 12,
	NavLeftJumpsBackHere = 1 << 13,
	CollapsingHeader     = ImGuiTreeNodeFlags.Framed | ImGuiTreeNodeFlags.NoTreePushOnOpen | ImGuiTreeNodeFlags.NoAutoOpenOnLog,
}

enum ImGuiPopupFlags: int{
	None                    = 0,
	MouseButtonLeft         = 0,
	MouseButtonRight        = 1,
	MouseButtonMiddle       = 2,
	MouseButtonMask_        = 0x1F,
	MouseButtonDefault_     = 1,
	NoOpenOverExistingPopup = 1 << 5,
	NoOpenOverItems         = 1 << 6,
	AnyPopupId              = 1 << 7,
	AnyPopupLevel           = 1 << 8,
	AnyPopup                = ImGuiPopupFlags.AnyPopupId | ImGuiPopupFlags.AnyPopupLevel,
}

enum ImGuiSelectableFlags: int{
	None               = 0,
	DontClosePopups    = 1 << 0,
	SpanAllColumns     = 1 << 1,
	AllowDoubleClick   = 1 << 2,
	Disabled           = 1 << 3,
	AllowItemOverlap   = 1 << 4,
}

enum ImGuiComboFlags: int{
	None                    = 0,
	PopupAlignLeft          = 1 << 0,
	HeightSmall             = 1 << 1,
	HeightRegular           = 1 << 2,
	HeightLarge             = 1 << 3,
	HeightLargest           = 1 << 4,
	NoArrowButton           = 1 << 5,
	NoPreview               = 1 << 6,
	HeightMask_             = ImGuiComboFlags.HeightSmall | ImGuiComboFlags.HeightRegular | ImGuiComboFlags.HeightLarge | ImGuiComboFlags.HeightLargest,
}

enum ImGuiTabBarFlags: int{
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

enum ImGuiTabItemFlags: int{
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

enum ImGuiTableFlags: int{
	None                       = 0,
	Resizable                  = 1 << 0,
	Reorderable                = 1 << 1,
	Hideable                   = 1 << 2,
	Sortable                   = 1 << 3,
	NoSavedSettings            = 1 << 4,
	ContextMenuInBody          = 1 << 5,
	
	RowBg                      = 1 << 6,
	BordersInnerH              = 1 << 7,
	BordersOuterH              = 1 << 8,
	BordersInnerV              = 1 << 9,
	BordersOuterV              = 1 << 10,
	BordersH                   = ImGuiTableFlags.BordersInnerH | ImGuiTableFlags.BordersOuterH,
	BordersV                   = ImGuiTableFlags.BordersInnerV | ImGuiTableFlags.BordersOuterV,
	BordersInner               = ImGuiTableFlags.BordersInnerV | ImGuiTableFlags.BordersInnerH,
	BordersOuter               = ImGuiTableFlags.BordersOuterV | ImGuiTableFlags.BordersOuterH,
	Borders                    = ImGuiTableFlags.BordersInner | ImGuiTableFlags.BordersOuter,
	NoBordersInBody            = 1 << 11,
	NoBordersInBodyUntilResize = 1 << 12,
	
	SizingFixedFit             = 1 << 13,
	SizingFixedSame            = 2 << 13,
	SizingStretchProp          = 3 << 13,
	SizingStretchSame          = 4 << 13,
	
	NoHostExtendX              = 1 << 16,
	NoHostExtendY              = 1 << 17,
	NoKeepColumnsVisible       = 1 << 18,
	PreciseWidths              = 1 << 19,
	
	NoClip                     = 1 << 20,
	
	PadOuterX                  = 1 << 21,
	NoPadOuterX                = 1 << 22,
	NoPadInnerX                = 1 << 23,
	
	ScrollX                    = 1 << 24,
	ScrollY                    = 1 << 25,
	
	SortMulti                  = 1 << 26,
	SortTristate               = 1 << 27,
	
	SizingMask_                = ImGuiTableFlags.SizingFixedFit | ImGuiTableFlags.SizingFixedSame | ImGuiTableFlags.SizingStretchProp | ImGuiTableFlags.SizingStretchSame,
}

enum ImGuiTableColumnFlags: int{
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

enum ImGuiTableRowFlags: int{
	None                     = 0,
	Headers                  = 1 << 0,
}

enum ImGuiTableBgTarget: int{
	None                     = 0,
	RowBg0                   = 1,
	RowBg1                   = 2,
	CellBg                   = 3,
}

enum ImGuiFocusedFlags: int{
	None                          = 0,
	ChildWindows                  = 1 << 0,
	RootWindow                    = 1 << 1,
	AnyWindow                     = 1 << 2,
	NoPopupHierarchy              = 1 << 3,
	s_DockHierarchy               = 1 << 4,
	RootAndChildWindows           = ImGuiFocusedFlags.RootWindow | ImGuiFocusedFlags.ChildWindows,
}

enum ImGuiHoveredFlags: int{
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

enum ImGuiDragDropFlags: int{
	None                         = 0,
	
	SourceNoPreviewTooltip       = 1 << 0,
	SourceNoDisableHover         = 1 << 1,
	SourceNoHoldToOpenOthers     = 1 << 2,
	SourceAllowNullID            = 1 << 3,
	SourceExtern                 = 1 << 4,
	SourceAutoExpirePayload      = 1 << 5,
	
	AcceptBeforeDelivery         = 1 << 10,
	AcceptNoDrawDefaultRect      = 1 << 11,
	AcceptNoPreviewTooltip       = 1 << 12,
	AcceptPeekOnly               = ImGuiDragDropFlags.AcceptBeforeDelivery | ImGuiDragDropFlags.AcceptNoDrawDefaultRect,
}

enum IMGUI_PAYLOAD_TYPE_COLOR_3F = "_COL3F";
enum IMGUI_PAYLOAD_TYPE_COLOR_4F = "_COL4F";

enum ImGuiDataType: int{
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
	COUNT
}

enum ImGuiDir: int{
	None    = -1,
	Left    = 0,
	Right   = 1,
	Up      = 2,
	Down    = 3,
	COUNT
}

enum ImGuiSortDirection: int{
	None         = 0,
	Ascending    = 1,
	Descending   = 2
}

enum ImGuiKey: int{
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
//version(ImGui_DisableObsoleteKeyIO){
//	KeysData_SIZE          = ImGuiKey.NamedKey_COUNT,
//	KeysData_OFFSET        = ImGuiKey.NamedKey_BEGIN,
//}else{
	KeysData_SIZE          = ImGuiKey.COUNT,
	KeysData_OFFSET        = 0,
//}
	ModCtrl = ImGuiMod.Ctrl, ModShift = ImGuiMod.Shift, ModAlt = ImGuiMod.Alt, ModSuper = ImGuiMod.Super,
	KeyPadEnter = ImGuiKey.KeypadEnter,
}

enum ImGuiMod: int{
	None                   = 0,
	Ctrl                   = 1 << 12,
	Shift                  = 1 << 13,
	Alt                    = 1 << 14,
	Super                  = 1 << 15,
	Shortcut               = 1 << 11,
	Mask_                  = 0xF800,
}

version(ImGui_DisableObsoleteKeyIO){
}else{
	enum ImGuiNavInput{
	    Activate, Cancel, Input, Menu, DpadLeft, DpadRight, DpadUp, DpadDown,
	    LStickLeft, LStickRight, LStickUp, LStickDown, FocusPrev, FocusNext, TweakSlow, TweakFast,
	    COUNT,
	}
}

enum ImGuiConfigFlags: int{
	None                   = 0,
	NavEnableKeyboard      = 1 << 0,
	NavEnableGamepad       = 1 << 1,
	NavEnableSetMousePos   = 1 << 2,
	NavNoCaptureKeyboard   = 1 << 3,
	NoMouse                = 1 << 4,
	NoMouseCursorChange    = 1 << 5,
	
	IsSRGB                 = 1 << 20,
	IsTouchScreen          = 1 << 21,
}

enum ImGuiBackendFlags: int{
	None                  = 0,
	HasGamepad            = 1 << 0,
	HasMouseCursors       = 1 << 1,
	HasSetMousePos        = 1 << 2,
	RendererHasVtxOffset  = 1 << 3,
}

enum ImGuiCol: int{
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
	COUNT
}

enum ImGuiStyleVar: int{
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
	COUNT
}


enum ImGuiButtonFlags: int{
	None                   = 0,
	MouseButtonLeft        = 1 << 0,
	MouseButtonRight       = 1 << 1,
	MouseButtonMiddle      = 1 << 2,
	
	MouseButtonMask_       = ImGuiButtonFlags.MouseButtonLeft | ImGuiButtonFlags.MouseButtonRight | ImGuiButtonFlags.MouseButtonMiddle,
	MouseButtonDefault_    = ImGuiButtonFlags.MouseButtonLeft,
}

enum ImGuiColorEditFlags: int{
	None            = 0,
	NoAlpha         = 1 << 1,
	NoPicker        = 1 << 2,
	NoOptions       = 1 << 3,
	NoSmallPreview  = 1 << 4,
	NoInputs        = 1 << 5,
	NoTooltip       = 1 << 6,
	NoLabel         = 1 << 7,
	NoSidePreview   = 1 << 8,
	NoDragDrop      = 1 << 9,
	NoBorder        = 1 << 10,
	
	AlphaBar        = 1 << 16,
	AlphaPreview    = 1 << 17,
	AlphaPreviewHalf= 1 << 18,
	HDR             = 1 << 19,
	DisplayRGB      = 1 << 20,
	DisplayHSV      = 1 << 21,
	DisplayHex      = 1 << 22,
	Uint8           = 1 << 23,
	Float           = 1 << 24,
	PickerHueBar    = 1 << 25,
	PickerHueWheel  = 1 << 26,
	InputRGB        = 1 << 27,
	InputHSV        = 1 << 28,
	
	DefaultOptions_ = ImGuiColorEditFlags.Uint8 | ImGuiColorEditFlags.DisplayRGB | ImGuiColorEditFlags.InputRGB | ImGuiColorEditFlags.PickerHueBar,
	
	DisplayMask_    = ImGuiColorEditFlags.DisplayRGB | ImGuiColorEditFlags.DisplayHSV | ImGuiColorEditFlags.DisplayHex,
	DataTypeMask_   = ImGuiColorEditFlags.Uint8 | ImGuiColorEditFlags.Float,
	PickerMask_     = ImGuiColorEditFlags.PickerHueWheel | ImGuiColorEditFlags.PickerHueBar,
	InputMask_      = ImGuiColorEditFlags.InputRGB | ImGuiColorEditFlags.InputHSV,
}
alias ImGuiColourEditFlags = ImGuiColorEditFlags;

enum ImGuiSliderFlags: int{
	None                   = 0,
	AlwaysClamp            = 1 << 4,
	Logarithmic            = 1 << 5,
	NoRoundToFormat        = 1 << 6,
	NoInput                = 1 << 7,
	InvalidMask_           = 0x7000000F,
}

enum ImGuiMouseButton: int{
	Left = 0,
	Right = 1,
	Middle = 2,
	COUNT = 5
}

enum ImGuiMouseCursor: int{
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
	COUNT
}

enum ImGuiCond: int{
	None          = 0,
	Always        = 1 << 0,
	Once          = 1 << 1,
	FirstUseEver  = 1 << 2,
	Appearing     = 1 << 3,
}

//struct ImNewWrapper {};
//void* operator new(size_t, ImNewWrapper, void* ptr) { return ptr; }
//void  operator delete(void*, ImNewWrapper, void*)   {}
pragma(inline,true) auto IM_ALLOC(size_t _SIZE){ return MemAlloc(_SIZE); }
pragma(inline,true) auto IM_FREE(void* _PTR){ MemFree(_PTR); }
//#define IM_PLACEMENT_NEW(_PTR)              new(ImNewWrapper(), _PTR)
//#define IM_NEW(_TYPE)                       new(ImNewWrapper(), ImGui::MemAlloc(sizeof(_TYPE))) _TYPE
pragma(inline,true) void IM_DELETE(T)(T* p){ p.__dtor__(); MemFree(p); }

extern(C++) struct ImVector(T){
	int Size = 0;
	int Capacity = 0;
	T* Data = null;
	
	// Provide standard typedefs but we don't use them ourselves.
	alias value_type = T;
	alias iterator = value_type*;
	alias const_iterator = const(value_type)*;
	
	pragma(inline,true):
	this(T: ImVector!V, V)(ref const(T) src){ this = src; }
	void opAssign(T: ImVector!V, V)(ref const(T) src){ clear(); resize(src.Size); if(src.Data) (cast(void*)Data)[0..Size*Data[0].sizeof] = (cast(void*)src.Data)[0..Size*src.Data[0].sizeof]; }
	~this(){ if(Data) IM_FREE(Data); }
	
	void clear();
	void clear_delete();
	void clear_destruct();
	
	bool empty() const;
	int size() const;
	int size_in_bytes() const;
	int max_size() const;
	int capacity() const;
	ref T opIndex(int i);
	ref const(T) opIndex(int i);
	
	T* begin();
	const T* begin();
	T* end();
	const T* end();
	ref T front();
	ref const(T) front();
	ref T back();
	ref const(T) back();
	void swap(T: ImVector!V, V)(ref T rhs){ int rhs_size = rhs.Size; rhs.Size = Size; Size = rhs_size; int rhs_cap = rhs.Capacity; rhs.Capacity = Capacity; Capacity = rhs_cap; T* rhs_data = rhs.Data; rhs.Data = Data; Data = rhs_data; }
	
	int          _grow_capacity(int sz) const;
	void         resize(int new_size);
	void         resize(int new_size, ref const(T) v);
	void         shrink(int new_size);
	void         reserve(int new_capacity);
	void         reserve_discard(int new_capacity);
	
	// void         push_back(const T& v)               { if (Size == Capacity) reserve(_grow_capacity(Size + 1)); memcpy(&Data[Size], &v, sizeof(v)); Size++; }
	// void         pop_back()                          { IM_ASSERT(Size > 0); Size--; }
	// void         push_front(const T& v)              { if (Size == 0) push_back(v); else insert(Data, v); }
	// T*           erase(const T* it)                  { IM_ASSERT(it >= Data && it < Data + Size); const ptrdiff_t off = it - Data; memmove(Data + off, Data + off + 1, ((size_t)Size - (size_t)off - 1) * sizeof(T)); Size--; return Data + off; }
	// T*           erase(const T* it, const T* it_last){ IM_ASSERT(it >= Data && it < Data + Size && it_last >= it && it_last <= Data + Size); const ptrdiff_t count = it_last - it; const ptrdiff_t off = it - Data; memmove(Data + off, Data + off + count, ((size_t)Size - (size_t)off - (size_t)count) * sizeof(T)); Size -= (int)count; return Data + off; }
	// T*           erase_unsorted(const T* it)         { IM_ASSERT(it >= Data && it < Data + Size);  const ptrdiff_t off = it - Data; if (it < Data + Size - 1) memcpy(Data + off, Data + Size - 1, sizeof(T)); Size--; return Data + off; }
	// T*           insert(const T* it, const T& v)     { IM_ASSERT(it >= Data && it <= Data + Size); const ptrdiff_t off = it - Data; if (Size == Capacity) reserve(_grow_capacity(Size + 1)); if (off < (int)Size) memmove(Data + off + 1, Data + off, ((size_t)Size - (size_t)off) * sizeof(T)); memcpy(&Data[off], &v, sizeof(v)); Size++; return Data + off; }
	// bool         contains(const T& v) const          { const T* data = Data;  const T* data_end = Data + Size; while (data < data_end) if (*data++ == v) return true; return false; }
	// T*           find(const T& v)                    { T* data = Data;  const T* data_end = Data + Size; while (data < data_end) if (*data == v) break; else ++data; return data; }
	// const T*     find(const T& v) const              { const T* data = Data;  const T* data_end = Data + Size; while (data < data_end) if (*data == v) break; else ++data; return data; }
	// bool         find_erase(const T& v)              { const T* it = find(v); if (it < Data + Size) { erase(it); return true; } return false; }
	// bool         find_erase_unsorted(const T& v)     { const T* it = find(v); if (it < Data + Size) { erase_unsorted(it); return true; } return false; }
	// int          index_from_ptr(const T* it) const   { IM_ASSERT(it >= Data && it < Data + Size); const ptrdiff_t off = it - Data; return (int)off; }
}

// static if(!staticBinding):
// import bindbc.loader;
//
// mixin(makeDynloadFns("ImGui",
// 	(){
// 		version(Windows){
// 			return q{[
// 				`___.dll`,
// 			]};
// 		}else version(OSX){
// 			return q{[
// 				`lib___.dylib`,
// 				`___`,
// 				`/Library/Frameworks/___.framework/___`,
// 				`/System/Library/Frameworks/___.framework/___`,
// 			]};
// 		}else version(Posix){
// 			return q{[
// 				`lib___.so`,
// 				`lib___.so.0`,
// 				`lib___.so.0.8.0`,
// 			]};
// 		}else static assert(0, "BindBC-ImGui does not have library search paths set up for this platform.");
// 	}(), [
// 	"imgui.imgui",
// ]));


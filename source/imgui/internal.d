/+
+                Copyright 2023 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http:
+/
module imgui.internal;
/*
version(ImGui_Internal):
import bindbc.imgui.config;
import bindbc.imgui.codegen;

struct ImBitVector;
struct ImRect;
struct ImDrawDataBuilder;
struct ImDrawListSharedData;
struct ImGuiColorMod;
struct ImGuiContext;
struct ImGuiContextHook;
struct ImGuiDataVarInfo;
struct ImGuiDataTypeInfo;
struct ImGuiGroupData;
struct ImGuiInputTextState;
struct ImGuiInputTextDeactivateData;
struct ImGuiLastItemData;
struct ImGuiLocEntry;
struct ImGuiMenuColumns;
struct ImGuiNavItemData;
struct ImGuiMetricsConfig;
struct ImGuiNextWindowData;
struct ImGuiNextItemData;
struct ImGuiOldColumnData;
struct ImGuiOldColumns;
struct ImGuiPopupData;
struct ImGuiSettingsHandler;
struct ImGuiStackSizes;
struct ImGuiStyleMod;
struct ImGuiTabBar;
struct ImGuiTabItem;
struct ImGuiTable;
struct ImGuiTableColumn;
struct ImGuiTableInstanceData;
struct ImGuiTableTempData;
struct ImGuiTableSettings;
struct ImGuiTableColumnsSettings;
struct ImGuiWindow;
struct ImGuiWindowTempData;
struct ImGuiWindowSettings;

enum ImGuiLocKey: int;

alias ImGuiActivateFlags_ = int;
alias ImGuiDebugLogFlags_ = int;
alias ImGuiInputFlags_ = int;
alias ImGuiOldColumnFlags_ = int;
alias ImGuiNavHighlightFlags_ = int;
alias ImGuiNavMoveFlags_ = int;
alias ImGuiScrollFlags_ = int;

alias ImGuiErrorLogCallback = extern(C++) void function(void* user_data, const(char)* fmt, ...);

enum IM_PI = 3.14159265358979323846f;

extern(C++) struct ImVec1{
	float x = 0f;
}

extern(C++) struct ImVec2ih{
	short x = 0, y = 0;
	
	nothrow @nogc:
	this(const ImVec2 rhs){
		x = cast(short)rhs.x;
		y = cast(short)rhs.y;
	}
}

extern(C++) struct ImRect{
	ImVec2 Min = {0f, 0f};
	ImVec2 Max = {0f, 0f};
	
	nothrow @nogc:
	this(const ImVec4 v){
		Min = ImVec2(v.x, v.y);
		Max = ImVec2(v.z, v.w);
	}
	this(float x1, float y1, float x2, float y2){
		Min = ImVec2(x1, y1);
		Max = ImVec2(x2, y2);
	}
	
	ImVec2 GetCenter() const{ return ImVec2((Min.x + Max.x) * 0.5f, (Min.y + Max.y) * 0.5f); }
	alias GetCentre = GetCenter;
	ImVec2 GetSize() const{ return ImVec2(Max.x - Min.x, Max.y - Min.y); }
	float GetWidth() const{ return Max.x - Min.x; }
	float GetHeight() const{ return Max.y - Min.y; }
	float GetArea() const{ return (Max.x - Min.x) * (Max.y - Min.y); }
	ImVec2 GetTL() const{ return Min; }
	ImVec2 GetTR() const{ return ImVec2(Max.x, Min.y); }
	ImVec2 GetBL() const{ return ImVec2(Min.x, Max.y); }
	ImVec2 GetBR() const{ return Max; }
	bool Contains(const ImVec2 p) const{ return p.x     >= Min.x && p.y     >= Min.y && p.x     <  Max.x && p.y     <  Max.y; }
	bool Contains(const ImRect r) const{ return r.Min.x >= Min.x && r.Min.y >= Min.y && r.Max.x <= Max.x && r.Max.y <= Max.y; }
	bool Overlaps(const ImRect r) const{ return r.Min.y <  Max.y && r.Max.y >  Min.y && r.Min.x <  Max.x && r.Max.x >  Min.x; }
	void Add(const ImVec2 p){
		if(Min.x > p.x) Min.x = p.x;
		if(Min.y > p.y) Min.y = p.y;
		if(Max.x < p.x) Max.x = p.x;
		if(Max.y < p.y) Max.y = p.y;
	}
	void Add(const ImRect r){
		if(Min.x > r.Min.x) Min.x = r.Min.x;
		if(Min.y > r.Min.y) Min.y = r.Min.y;
		if(Max.x < r.Max.x) Max.x = r.Max.x;
		if(Max.y < r.Max.y) Max.y = r.Max.y;
	}
	void Expand(const float amount){
		Min.x -= amount; Min.y -= amount;
		Max.x += amount; Max.y += amount;
	}
	void Expand(const ImVec2 amount){
		Min.x -= amount.x; Min.y -= amount.y;
		Max.x += amount.x; Max.y += amount.y;
	}
	void Translate(const ImVec2 d){
		Min.x += d.x; Min.y += d.y;
		Max.x += d.x; Max.y += d.y;
	}
	void TranslateX(float dx){
		Min.x += dx;
		Max.x += dx;
	}
	void TranslateY(float dy){
		Min.y += dy; Max.y += dy;
	}
	void ClipWith(const ImRect r){
		Min = ImMax(Min, r.Min);
		Max = ImMin(Max, r.Max);
	}
	void ClipWithFull(const ImRect r){
		Min = ImClamp(Min, r.Min, r.Max);
		Max = ImClamp(Max, r.Min, r.Max);
	}
	void Floor(){
		Min.x = IM_FLOOR(Min.x); Min.y = IM_FLOOR(Min.y);
		Max.x = IM_FLOOR(Max.x); Max.y = IM_FLOOR(Max.y);
	}
	bool IsInverted() const{ return Min.x > Max.x || Min.y > Max.y; }
	ImVec4 ToVec4() const{ return ImVec4(Min.x, Min.y, Max.x, Max.y); }
	
}

alias ImBitArrayPtr = ImU32*;

extern(C++) struct ImBitArray(int BITCOUNT, int OFFSET=0){
	uint[(BITCOUNT + 31) >> 5] Storage;
	
	nothrow @nogc:
	void ClearAllBits(){ memset(Storage, 0, Storage.sizeof); }
	void SetAllBits(){ memset(Storage, 255, Storage.sizeof); }
	bool TestBit(int n) const{
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		return IM_BITARRAY_TESTBIT(Storage, n);
	}
	void SetBit(int n){
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		ImBitArraySetBit(Storage, n);
	}
	void ClearBit(int n){
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		ImBitArrayClearBit(Storage, n);
	}
	void SetBitRange(int n, int n2){
		n += OFFSET;
		n2 += OFFSET;
		assert(n >= 0 && n < BITCOUNT && n2 > n && n2 <= BITCOUNT);
		ImBitArraySetBitRange(Storage, n, n2);
	}
	bool opIndex(int n) const{
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		return IM_BITARRAY_TESTBIT(Storage, n);
	}
}

extern(C++) struct ImBitVector{
	ImVector!uint Storage;
	
	nothrow @nogc:
	void Create(int sz){
		Storage.resize((sz + 31) >> 5);
		memset(Storage.Data, 0, cast(size_t)Storage.Size * Storage.Data[0].sizeof);
	}
	void Clear(){ Storage.clear(); }
	bool TestBit(int n) const{
		assert(n < (Storage.Size << 5));
		return IM_BITARRAY_TESTBIT(Storage.Data, n);
	}
	void SetBit(int n){
		assert(n < (Storage.Size << 5));
		ImBitArraySetBit(Storage.Data, n);
	}
	void ClearBit(int n){
		assert(n < (Storage.Size << 5));
		ImBitArrayClearBit(Storage.Data, n);
	}
}

extern(C++) struct ImSpan(T){
	T* Data = null;
	T* DataEnd = null;
	
	nothrow @nogc:
	pragma(inline,true){
		this(T* data, int size){
			Data = data;
			DataEnd = data + size;
		}
		void set(T* data, int size){
			Data = data;
			DataEnd = data + size;
		}
		void set(T* data, T* data_end){
			Data = data;
			DataEnd = data_end;
		}
		int size() const{ return cast(int)cast(ptrdiff_t)(DataEnd - Data); }
		int size_in_bytes() const{ return cast(int)cast(ptrdiff_t)(DataEnd - Data) * cast(int)sizeof(T); }
		ref inout(T) opIndex(int i) inout{
			inout(T)* p = Data + i;
			assert(p >= Data && p < DataEnd);
			return *p;
		}
		
		inout(T)* begin() inout{ return Data; }
		inout(T)* end() inout{ return DataEnd; }
		
		int index_from_ptr(const(T)* it) const{
			assert(it >= Data && it < DataEnd);
			const ptrdiff_t off = it - Data;
			return cast(int)off;
		}
	}
}

extern(C++) struct ImSpanAllocator(int CHUNKS){
	char* BasePtr = null;
	int CurrOff = 0;
	int CurrIdx = 0;
	int[CHUNKS] Offsets;
	int[CHUNKS] Sizes;
	
	nothrow @nogc:
	pragma(inline,true){
		void Reserve(int n, size_t sz, int a=4){
			assert(n == CurrIdx && n < CHUNKS);
			CurrOff = IM_MEMALIGN(CurrOff, a);
			Offsets[n] = CurrOff;
			Sizes[n] = cast(int)sz;
			CurrIdx++; CurrOff += cast(int)sz;
		}
		int GetArenaSizeInBytes(){ return CurrOff; }
		void SetArenaBasePtr(void* base_ptr){ BasePtr = cast(char*)base_ptr; }
		void* GetSpanPtrBegin(int n){
			assert(n >= 0 && n < CHUNKS && CurrIdx == CHUNKS);
			return (void*)(BasePtr + Offsets[n]);
		}
		void* GetSpanPtrEnd(int n){
			assert(n >= 0 && n < CHUNKS && CurrIdx == CHUNKS);
			return (void*)(BasePtr + Offsets[n] + Sizes[n]);
		}
		void  GetSpan(T)(int n, ImSpan!(T)* span){ span.set(cast(T*)GetSpanPtrBegin(n), cast(T*)GetSpanPtrEnd(n)); }
	}
}

alias ImPoolIdx = int;
extern(C++) struct ImPool(T){
	ImVector!T Buf;
	ImGuiStorage Map;
	ImPoolIdx FreeIdx = 0;
	ImPoolIdx AliveCount = 0;
	
	nothrow @nogc:
	~this(){ Clear(); }
	T* GetByKey(ImGuiID key){
		int idx = Map.GetInt(key, -1);
		return (idx != -1) ? &Buf[idx] : null;
	}
	T* GetByIndex(ImPoolIdx n){ return &Buf[n]; }
	ImPoolIdx GetIndex(const T* p) const{
		assert(p >= Buf.Data && p < Buf.Data + Buf.Size);
		return (ImPoolIdx)(p - Buf.Data);
	}
	T* GetOrAddByKey(ImGuiID key){
		int* p_idx = Map.GetIntRef(key, -1);
		if(*p_idx != -1) return &Buf[*p_idx];
		*p_idx = FreeIdx;
		return Add();
	}
	bool Contains(const T* p) const{ return (p >= Buf.Data && p < Buf.Data + Buf.Size); }
	void Clear(){
		for(int n = 0; n < Map.Data.Size; n++){
			int idx = Map.Data[n].val_i;
			if(idx != -1) Buf[idx].~T();
		}
		Map.Clear();
		Buf.clear();
		FreeIdx = AliveCount = 0;
	}
	T* Add(){
		int idx = FreeIdx;
		if(idx == Buf.Size){
			Buf.resize(Buf.Size + 1);
			FreeIdx++;
		}else{
			FreeIdx = *cast(int*)&Buf[idx];
		}
		Buf[idx] = T();
		AliveCount++;
		return &Buf[idx];
	}
	void Remove(ImGuiID key, const T* p){ Remove(key, GetIndex(p)); }
	void Remove(ImGuiID key, ImPoolIdx idx){
		Buf[idx].~T();
		*cast(int*)&Buf[idx] = FreeIdx;
		FreeIdx = idx;
		Map.SetInt(key, -1);
		AliveCount--;
	}
	void Reserve(int capacity){
		Buf.reserve(capacity);
		Map.Data.reserve(capacity);
	}
	
	int GetAliveCount() const{ return AliveCount; }
	int GetBufSize() const{ return Buf.Size; }
	int GetMapSize() const{ return Map.Data.Size; }
	T* TryGetMapData(ImPoolIdx n){
		int idx = Map.Data[n].val_i;
		if(idx == -1) return null;
		return GetByIndex(idx);
	}
	version(ImGui_DisableObsoleteFunctions){
	else{
		int GetSize(){ return GetMapSize(); }
	}
}

extern(C++) struct ImChunkStream(T){
	ImVector!char Buf;
	
	nothrow @nogc:
	void clear(){ Buf.clear(); }
	bool empty() const{ return Buf.Size == 0; }
	int size() const{ return Buf.Size; }
	T* alloc_chunk(size_t sz){
		size_t HDR_SZ = 4;
		sz = IM_MEMALIGN(HDR_SZ + sz, 4U);
		int off = Buf.Size;
		Buf.resize(off + cast(int)sz);
		(cast(int*)cast(void*)(Buf.Data + off))[0] = cast(int)sz;
		return cast(T*)cast(void*)(Buf.Data + off + cast(int)HDR_SZ);
	}
	T* begin(){
		size_t HDR_SZ = 4;
		if(!Buf.Data) return null;
		return cast(T*)cast(void*)(Buf.Data + HDR_SZ);
	}
	T* next_chunk(T* p){
		size_t HDR_SZ = 4;
		assert(p >= begin() && p < end());
		p = cast(T*)cast(void*)(cast(char*)cast(void*)p + chunk_size(p));
		if(p == cast(T*)cast(void*)(cast(char*)end() + HDR_SZ)) return (T*)0;
		assert(p < end());
		return p;
	}
	int chunk_size(const T* p){ return (cast(const(int)*)p)[-1]; }
	T* end(){ return cast(T*)cast(void*)(Buf.Data + Buf.Size); }
	int offset_from_ptr(const T* p){
		assert(p >= begin() && p < end());
		const ptrdiff_t off = cast(const(char)*)p - Buf.Data;
		return cast(int)off;
	}
	T* ptr_from_offset(int off){
		assert(off >= 4 && off < Buf.Size);
		return cast(T*)cast(void*)(Buf.Data + off);
	}
	void swap(ref ImChunkStream!T rhs){ rhs.Buf.swap(Buf); }
}

extern(C++) struct ImGuiTextIndex{
	ImVector!int LineOffsets;
	int EndOffset = 0;
	
	nothrow @nogc:
	void clear(){
		LineOffsets.clear();
		EndOffset = 0;
	}
	int size(){ return LineOffsets.Size; }
	const(char)* get_line_begin(const char* base, int n){ return base + LineOffsets[n]; }
	const(char)* get_line_end(const char* base, int n){ return base + (n + 1 < LineOffsets.Size ? (LineOffsets[n + 1] - 1) : EndOffset); }
}

enum IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MIN = 4;
enum IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MAX = 512;

enum IM_DRAWLIST_ARCFAST_TABLE_SIZE = 48;
enum IM_DRAWLIST_ARCFAST_SAMPLE_MAX = IM_DRAWLIST_ARCFAST_TABLE_SIZE; 

extern(C++) struct ImDrawListSharedData{
	ImVec2 TexUvWhitePixel;
	ImFont* Font;
	float FontSize;
	float CurveTessellationTol;
	float CircleSegmentMaxError;
	ImVec4 ClipRectFullscreen;
	ImDrawListFlags InitialFlags;
	
	ImVector!ImVec2 TempBuffer;
	
	ImVec2[IM_DRAWLIST_ARCFAST_TABLE_SIZE] ArcFastVtx;
	float ArcFastRadiusCutoff;
	ubyte[64] CircleSegmentCounts;
	const(ImVec4)* TexUvLines;
}

extern(C++) struct ImDrawDataBuilder{
	ImVector!(ImDrawList*)[2] Layers;
	
	nothrow @nogc:
	void Clear(){ for(int n = 0; n < IM_ARRAYSIZE(Layers); n++) Layers[n].resize(0); }
	void ClearFreeMemory(){ for(int n = 0; n < IM_ARRAYSIZE(Layers); n++) Layers[n].clear(); }
	int  GetDrawListCount() const{
		int count = 0;
		for(int n = 0; n < IM_ARRAYSIZE(Layers); n++) count += Layers[n].Size;
		return count;
	}
	
	void FlattenIntoSingleLayer();
}

alias ImGuiItemFlags_ = int;
enum ImGuiItemFlags: ImGuiItemFlags_{
	// Controlled by user
	None                      = 0,
	NoTabStop                 = 1 << 0, 
	ButtonRepeat              = 1 << 1,
	Disabled                  = 1 << 2,
	NoNav                     = 1 << 3,
	NoNavDefaultFocus         = 1 << 4,
	SelectableDontClosePopup  = 1 << 5,
	MixedValue                = 1 << 6,
	ReadOnly                  = 1 << 7,
	NoWindowHoverableCheck    = 1 << 8,
	
	Inputable                 = 1 << 10,
}

alias ImGuiItemStatusFlags_ = int;
enum ImGuiItemStatusFlags: ImGuiItemStatusFlags_{
	None              = 0,
	HoveredRect       = 1 << 0,
	HasDisplayRect    = 1 << 1,
	Edited            = 1 << 2,
	ToggledSelection  = 1 << 3,
	ToggledOpen       = 1 << 4,
	HasDeactivated    = 1 << 5,
	Deactivated       = 1 << 6,
	HoveredWindow     = 1 << 7,
	FocusedByTabbing  = 1 << 8,
	Visible           = 1 << 9,
}

enum ImGuiInputTextFlagsPrivate: ImGuiInputTextFlags_{
	Multiline     = 1 << 26,
	NoMarkEdited  = 1 << 27,
	MergedItem    = 1 << 28,
}

enum ImGuiButtonFlagsPrivate: ImGuiButtonFlags_{
	PressedOnClick         = 1 << 4,
	PressedOnClickRelease  = 1 << 5,
	PressedOnClickReleaseAnywhere = 1 << 6,
	PressedOnRelease       = 1 << 7,
	PressedOnDoubleClick   = 1 << 8,
	PressedOnDragDropHold  = 1 << 9,
	Repeat                 = 1 << 10,
	FlattenChildren        = 1 << 11,
	AllowItemOverlap       = 1 << 12,
	DontClosePopups        = 1 << 13,
	
	AlignTextBaseLine      = 1 << 15,
	NoKeyModifiers         = 1 << 16,
	NoHoldingActiveId      = 1 << 17,
	NoNavFocus             = 1 << 18,
	NoHoveredOnFocus       = 1 << 19,
	NoSetKeyOwner          = 1 << 20,
	NoTestKeyOwner         = 1 << 21,
	PressedOnMask_         = ImGuiButtonFlags.PressedOnClick | ImGuiButtonFlags.PressedOnClickRelease | ImGuiButtonFlags.PressedOnClickReleaseAnywhere | ImGuiButtonFlags.PressedOnRelease | ImGuiButtonFlags.PressedOnDoubleClick | ImGuiButtonFlags.PressedOnDragDropHold,
	PressedOnDefault_      = ImGuiButtonFlags.PressedOnClickRelease,
}

// Extend ImGuiComboFlags_
enum ImGuiComboFlagsPrivate: ImGuiComboFlags_{
	CustomPreview    = 1 << 20,
}

// Extend ImGuiSliderFlags_
enum ImGuiSliderFlagsPrivate: ImGuiSliderFlags_{
	Vertical    = 1 << 20,
	ReadOnly    = 1 << 21,
}

// Extend ImGuiSelectableFlags_
enum ImGuiSelectableFlagsPrivate: ImGuiSelectableFlags_{
	NoHoldingActiveID       = 1 << 20,
	SelectOnNav             = 1 << 21,
	SelectOnClick           = 1 << 22,
	SelectOnRelease         = 1 << 23,
	SpanAvailWidth          = 1 << 24,
	SetNavIdOnHover         = 1 << 25,
	NoPadWithHalfSpacing    = 1 << 26,
	NoSetKeyOwner           = 1 << 27,
}

enum ImGuiTreeNodeFlagsPrivate: ImGuiTreeNodeFlags_{
	ClipLabelForTrailingButton    = 1 << 20,
}

alias ImGuiSeparatorFlags_ = int;
enum ImGuiSeparatorFlags: ImGuiSeparatorFlags_{
	None              = 0,
	Horizontal        = 1 << 0,
	Vertical          = 1 << 1,
	SpanAllColumns    = 1 << 2,
}

alias ImGuiFocusRequestFlags_ = int;
enum ImGuiFocusRequestFlags: ImGuiFocusRequestFlags_{
	None                 = 0,
	RestoreFocusedChild  = 1 << 0,
	UnlessBelowModal     = 1 << 1,
}

alias ImGuiTextFlags_ = int;
enum ImGuiTextFlags: ImGuiTextFlags_{
	None                        = 0,
	NoWidthForLargeClippedText  = 1 << 0,
}

alias ImGuiTooltipFlags_ = int;
enum ImGuiTooltipFlags: ImGuiTooltipFlags_{
	None                     = 0,
	OverridePreviousTooltip  = 1 << 0,
}

alias ImGuiLayoutType_ = int;
enum ImGuiLayoutType: ImGuiLayoutType_{
	Horizontal  = 0,
	Vertical    = 1,
}

enum ImGuiLogType{
	None = 0,
	TTY,
	File,
	Buffer,
	Clipboard,
}

enum ImGuiAxis{
	None  = -1,
	X     = 0,
	Y     = 1
}

enum ImGuiPlotType{
	Lines,
	Histogram,
}

enum ImGuiPopupPositionPolicy{
	Default,
	ComboBox,
	Tooltip,
}

extern(C++) struct ImGuiDataVarInfo{
	ImGuiDataType Type;
	uint Count;
	uint Offset;
	
	nothrow @nogc:
	void* GetVarPtr(void* parent) const{ return cast(void*)(cast(ubyte*)parent + Offset); }
}

extern(C++) struct ImGuiDataTypeTempStorage{
	ubyte[8] Data;
}

extern(C++) struct ImGuiDataTypeInfo{
	size_t Size;
	const(char)* Name;
	const(char)* PrintFmt;
	const(char)* ScanFmt;
}

enum ImGuiDataTypePrivate: ImGuiDataType_{
	String = ImGuiDataType.COUNT + 1,
	Pointer,
	ID,
}

extern(C++) struct ImGuiColorMod{
	ImGuiCol Col;
	ImVec4 BackupValue;
}
alias ImGuiColourMod = ImGuiColorMod;

extern(C++) struct ImGuiStyleMod{
	ImGuiStyleVar_ VarIdx;
	union _Var{
		int[2] BackupInt;
		float[2] BackupFloat;
	}
	_Val var;
	
	nothrow @nogc:
	this(ImGuiStyleVar_ idx, int v){
		VarIdx = idx;
		var.BackupInt[0] = v;
	}
	this(ImGuiStyleVar_ idx, float v){
		VarIdx = idx;
		var.BackupFloat[0] = v;
	}
	this(ImGuiStyleVar_ idx, ImVec2 v){
		VarIdx = idx;
		var.BackupFloat[0] = v.x;
		var.BackupFloat[1] = v.y;
	}
}

extern(C++) struct ImGuiComboPreviewData{
	ImRect PreviewRect = {ImVec2(0f, 0f), ImVec2(0f, 0f)};
	ImVec2 BackupCursorPos = {0f, 0f};
	ImVec2 BackupCursorMaxPos = {0f, 0f};
	ImVec2 BackupCursorPosPrevLine = {0f, 0f};
	float BackupPrevLineTextBaseOffset = 0f;
	ImGuiLayoutType_ BackupLayout = 0;
}

extern(C++) struct ImGuiGroupData{
	ImGuiID WindowID;
	ImVec2 BackupCursorPos;
	ImVec2 BackupCursorMaxPos;
	ImVec1 BackupIndent;
	ImVec1 BackupGroupOffset;
	ImVec2 BackupCurrLineSize;
	float BackupCurrLineTextBaseOffset;
	ImGuiID BackupActiveIdIsAlive;
	bool BackupActiveIdPreviousFrameIsAlive;
	bool BackupHoveredIdIsAlive;
	bool EmitItem;
}

extern(C++) struct ImGuiMenuColumns{
	uint TotalWidth = 0;
	uint NextTotalWidth = 0;
	ushort Spacing = 0;
	ushort OffsetIcon = 0;
	ushort OffsetLabel = 0;
	ushort OffsetShortcut = 0;
	ushort OffsetMark = 0;
	ushort[4] Widths;
}

extern(C++) struct ImGuiInputTextDeactivatedState{
	ImGuiID ID = 0;
	ImVector!char TextA;
	
	nothrow @nogc:
	void ClearFreeMemory(){
		ID = 0;
		TextA.clear();
	}
}

extern(C++) struct ImGuiPopupData{
	ImGuiID PopupId = 0;
	ImGuiWindow* Window = null;
	ImGuiWindow* BackupNavWindow = null;
	int ParentNavLayer = -1;
	int OpenFrameCount = -1;
	ImGuiID OpenParentId = 0;
	ImVec2 OpenPopupPos = {0f, 0f};
	ImVec2 OpenMousePos = {0f, 0f};
}

alias ImGuiNextWindowDataFlags_ = int;
enum ImGuiNextWindowDataFlags: ImGuiNextWindowDataFlags_{
	None               = 0,
	HasPos             = 1 << 0,
	HasSize            = 1 << 1,
	HasContentSize     = 1 << 2,
	HasCollapsed       = 1 << 3,
	HasSizeConstraint  = 1 << 4,
	HasFocus           = 1 << 5,
	HasBgAlpha         = 1 << 6,
	HasScroll          = 1 << 7,
}

struct ImGuiNextWindowData{
	ImGuiNextWindowDataFlags_ Flags = 0;
	ImGuiCond_ PosCond = 0;
	ImGuiCond_ SizeCond = 0;
	ImGuiCond_ CollapsedCond = 0;
	ImVec2 PosVal = {0f, 0f};
	ImVec2 PosPivotVal = {0f, 0f};
	ImVec2 SizeVal = {0f, 0f};
	ImVec2 ContentSizeVal = {0f, 0f};
	ImVec2 ScrollVal = {0f, 0f};
	bool CollapsedVal = false;
	ImRect SizeConstraintRect = {ImVec2(0f, 0f), ImVec2(0f, 0f)};
	ImGuiSizeCallback SizeCallback = null;
	void* SizeCallbackUserData = null;
	float BgAlphaVal = 0f;
	ImVec2 MenuBarOffsetMinVal = {0f, 0f};
	
	nothrow @nogc:
	pragma(inline,true){
		void ClearFlags(){ Flags = ImGuiNextWindowDataFlags.None; }
	}
}

alias ImGuiNextItemDataFlags_ = int;
enum ImGuiNextItemDataFlags: ImGuiNextItemDataFlags_{
	None      = 0,
	HasWidth  = 1 << 0,
	HasOpen   = 1 << 1,
}

struct ImGuiNextItemData
{
	ImGuiNextItemDataFlags_ Flags;
	float Width = 0f;
	ImGuiID FocusScopeId = 0;
	ImGuiCond_ OpenCond = 0;
	bool OpenVal = false;
	
	nothrow @nogc:
	pragma(inline,true){
		void ClearFlags()    { Flags = ImGuiNextItemDataFlags.None; }
	}
}

struct ImGuiLastItemData{
	ImGuiID                 ID;
	ImGuiItemFlags          InFlags;            // See ImGuiItemFlags_
	ImGuiItemStatusFlags    StatusFlags;        // See ImGuiItemStatusFlags_
	ImRect                  Rect;               // Full rectangle
	ImRect                  NavRect;            // Navigation scoring rectangle (not displayed)
	ImRect                  DisplayRect;        // Display rectangle (only if ImGuiItemStatusFlags_HasDisplayRect is set)
	
	ImGuiLastItemData()     { memset(this, 0, sizeof(*this)); }
}

struct IMGUI_API ImGuiStackSizes{
	short   SizeOfIDStack;
	short   SizeOfColorStack;
	short   SizeOfStyleVarStack;
	short   SizeOfFontStack;
	short   SizeOfFocusScopeStack;
	short   SizeOfGroupStack;
	short   SizeOfItemFlagsStack;
	short   SizeOfBeginPopupStack;
	short   SizeOfDisabledStack;
	
	ImGuiStackSizes() { memset(this, 0, sizeof(*this)); }
	void SetToContextState(ImGuiContext* ctx);
	void CompareWithContextState(ImGuiContext* ctx);
};

// Data saved for each window pushed into the stack
struct ImGuiWindowStackData
{
	ImGuiWindow*            Window;
	ImGuiLastItemData       ParentLastItemDataBackup;
	ImGuiStackSizes         StackSizesOnBegin;      // Store size of various stacks for asserting
};

struct ImGuiShrinkWidthItem
{
	int         Index;
	float       Width;
	float       InitialWidth;
};

struct ImGuiPtrOrIndex
{
	void*       Ptr;            // Either field can be set, not both. e.g. Dock node tab bars are loose while BeginTabBar() ones are in a pool.
	int         Index;          // Usually index in a main pool.

	ImGuiPtrOrIndex(void* ptr)  { Ptr = ptr; Index = -1; }
	ImGuiPtrOrIndex(int index)  { Ptr = NULL; Index = index; }
};

pragma(inline, true) nothrow @nogc{
	auto IM_MEMALIGN(size_t _OFF, size_t _ALIGN){ return (_OFF + (_ALIGN - 1)) & ~(_ALIGN - 1); }
	auto IM_F32_TO_INT8_UNBOUND(float _VAL){ return cast(int)((_VAL) * 255.0f + (_VAL >= 0 ? 0.5f : -0.5f)); }
	auto IM_F32_TO_INT8_SAT(float _VAL){ return cast(int)(ImSaturate(_VAL) * 255.0f + 0.5f); }
	auto IM_FLOOR(float _VAL){ return cast(float)cast(int)(_VAL); }
	auto IM_ROUND(float _VAL){ return cast(float)cast(int)(_VAL + 0.5f); }
	
	bool ImIsPowerOfTwo(int v){ return v != 0 && (v & (v - 1)) == 0; }
	bool ImIsPowerOfTwo(ulong v){ return v != 0 && (v & (v - 1)) == 0; }
	int ImUpperPowerOfTwo(int v){
		v--;
		v |= v >> 1;
		v |= v >> 2;
		v |= v >> 4;
		v |= v >> 8;
		v |= v >> 16;
		v++; return
		v;
	}
	
	char ImToUpper(char c){ return (c >= 'a' && c <= 'z') ? c &= ~32 : c; }
	bool ImCharIsBlankA(char c){ return c == ' ' || c == '\t'; }
	bool ImCharIsBlankW(uint c){ return c == ' ' || c == '\t' || c == 0x3000; }
	
	T ImMin(T)(T lhs, T rhs) if(__traits(isScalar, T)){ return lhs < rhs ? lhs : rhs; }
	T ImMax(T)(T lhs, T rhs) if(__traits(isScalar, T)){ return lhs >= rhs ? lhs : rhs; }
	T ImClamp(T)(T v, T mn, T mx) if(__traits(isScalar, T)){ return (v < mn) ? mn : (v > mx) ? mx : v; }
	T ImLerp(T)(T a, T b, float t) if(__traits(isScalar, T)){ return (T)(a + (b - a) * t); }
	void ImSwap(T)(ref T a, ref T b)
	if(__traits(isScalar, T)){
		T tmp = a;
		a = b;
		b = tmp;
	}
	T ImAddClampOverflow(T a, T b, T mn, T mx)
	if(__traits(isScalar, T)){
		if(b < 0 && (a < mn - b)) return mn;
		if(b > 0 && (a > mx - b)) return mx;
		return a + b;
	}
	T ImSubClampOverflow(T a, T b, T mn, T mx)
	if(__traits(isScalar, T)){
		if(b > 0 && (a < mn + b)) return mn;
		if(b < 0 && (a > mx + b)) return mx;
		return a - b;
	}
	
	ImVec2 ImMin(const ImVec2 lhs, const ImVec2 rhs){ return ImVec2(lhs.x < rhs.x ? lhs.x : rhs.x, lhs.y < rhs.y ? lhs.y : rhs.y); }
	ImVec2 ImMax(const ImVec2 lhs, const ImVec2 rhs){ return ImVec2(lhs.x >= rhs.x ? lhs.x : rhs.x, lhs.y >= rhs.y ? lhs.y : rhs.y); }
	ImVec2 ImClamp(const ImVec2 v, const ImVec2 mn, ImVec2 mx){ return ImVec2((v.x < mn.x) ? mn.x : (v.x > mx.x) ? mx.x : v.x, (v.y < mn.y) ? mn.y : (v.y > mx.y) ? mx.y : v.y); }
	ImVec2 ImLerp(const ImVec2 a, const ImVec2 b, float t){ return ImVec2(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t); }
	ImVec2 ImLerp(const ImVec2 a, const ImVec2 b, const ImVec2 t){ return ImVec2(a.x + (b.x - a.x) * t.x, a.y + (b.y - a.y) * t.y); }
	ImVec4 ImLerp(const ImVec4 a, const ImVec4 b, float t){ return ImVec4(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t, a.w + (b.w - a.w) * t); }
	float ImSaturate(float f){ return (f < 0f) ? 0f : (f > 1f) ? 1f : f; }
	float ImLengthSqr(const ImVec2 lhs){ return (lhs.x * lhs.x) + (lhs.y * lhs.y); }
	float ImLengthSqr(const ImVec4 lhs){ return (lhs.x * lhs.x) + (lhs.y * lhs.y) + (lhs.z * lhs.z) + (lhs.w * lhs.w); }
	float ImInvLength(const ImVec2 lhs, float fail_value){
		float d = (lhs.x * lhs.x) + (lhs.y * lhs.y);
		if(d > 0f) return ImRsqrt(d);
		return fail_value;
	}
	float ImFloor(float f){ return cast(float)cast(int)f; }
	float ImFloorSigned(float f){ return cast(float)((f >= 0 || cast(float)cast(int)f == f) ? cast(int)f : cast(int)f - 1); }
	ImVec2 ImFloor(const ImVec2 v){ return ImVec2(cast(float)cast(int)v.x, cast(float)cast(int)v.y); }
	ImVec2 ImFloorSigned(const ImVec2 v){ return ImVec2(ImFloorSigned(v.x), ImFloorSigned(v.y)); }
	int ImModPositive(int a, int b){ return (a + b) % b; }
	float ImDot(const ImVec2 a, const ImVec2 b){ return a.x * b.x + a.y * b.y; }
	ImVec2 ImRotate(const ImVec2 v, float cos_a, float sin_a){ return ImVec2(v.x * cos_a - v.y * sin_a, v.x * sin_a + v.y * cos_a); }
	float ImLinearSweep(float current, float target, float speed){
		if(current < target) return ImMin(current + speed, target);
		if(current > target) return ImMax(current - speed, target);
		return current;
	}
	ImVec2 ImMul(const ImVec2 lhs, const ImVec2 rhs){ return ImVec2(lhs.x * rhs.x, lhs.y * rhs.y); }
	bool ImIsFloatAboveGuaranteedIntegerPrecision(float f){ return f <= -16777216 || f >= 16777216; }
	float ImExponentialMovingAverage(float avg, float sample, int n){
		avg -= avg / n;
		avg += sample / n;
		return avg;
	}
	
	
	private{
		enum isImBitArray(T) = is(T: BitArray!(B,N), BitArray: ImBitArray);
		static assert(isImBitArray!(ImBitArray!(5,0)));
		static assert(!isImBitArray!(ImPool!(int)));
	}
	bool IM_BITARRAY_TESTBIT(Arr)(Arr _ARRAY, uint _N) if(isImBitArray!Arr){ return (_ARRAY[_N >> 5] & (cast(uint)1 << (_N & 31))) != 0; }
	void IM_BITARRAY_CLEARBIT(ref Arr _ARRAY, uint _N) if(isImBitArray!Arr){ _ARRAY[_N >> 5] &= ~(cast(uint)1 << (_N & 31)); }
	size_t ImBitArrayGetStorageSizeInBytes(int bitcount){ return cast(size_t)((bitcount + 31) >> 5) << 2; }
	void ImBitArrayClearAllBits(uint* arr, int bitcount){ memset(arr, 0, ImBitArrayGetStorageSizeInBytes(bitcount)); }
	bool ImBitArrayTestBit(const(uint)* arr, int n){
		uint mask = cast(uint)1 << (n & 31);
		return (arr[n >> 5] & mask) != 0;
	}
	void ImBitArrayClearBit(uint* arr, int n){
		uint mask = cast(uint)1 << (n & 31);
		arr[n >> 5] &= ~mask;
	}
	void ImBitArraySetBit(uint* arr, int n){
		uint mask = cast(uint)1 << (n & 31);
		arr[n >> 5] |= mask;
	}
	void ImBitArraySetBitRange(uint* arr, int n, int n2){
		n2--;
		while(n <= n2){
			int a_mod = (n & 31);
			int b_mod = (n2 > (n | 31) ? 31 : (n2 & 31)) + 1;
			uint mask = cast(uint)((cast(ulong)1 << b_mod) - 1) & ~cast(uint)((cast(ulong)1 << a_mod) - 1);
			arr[n >> 5] |= mask;
			n = (n + 32) & ~31;
		}
	}
	
	auto IM_ROUNDUP_TO_EVEN(float _V){ return (((_V) + 1) / 2) * 2; }
	auto IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_CALC(float _RAD, float _MAXERROR){
		return ImClamp(
			IM_ROUNDUP_TO_EVEN(cast(int)ImCeil(IM_PI / ImAcos(1 - ImMin(_MAXERROR, _RAD) / _RAD))),
			IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MIN,
			IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MAX,
		);
	}
	
	auto IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_CALC_R(float _N, float _MAXERROR){ return _MAXERROR / (1 - ImCos(IM_PI / ImMax(_N, IM_PI))); }
	auto IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_CALC_ERROR(float _N, float _RAD){ return (1 - ImCos(IM_PI / ImMax(_N, IM_PI))) / _RAD; }
}

//mixin(joinFnBinds((){
//	FnBind[] ret = [
ImGuiID ImHashData(const(void)* data, size_t data_size, ImGuiID seed=0);
ImGuiID ImHashStr(const(char)* data, size_t data_size=0, ImGuiID seed=0);

ImU32 ImAlphaBlendColors(ImU32 col_a, ImU32 col_b);

int ImStricmp(const char* str1, const char* str2);
int ImStrnicmp(const char* str1, const char* str2, size_t count);
void ImStrncpy(char* dst, const char* src, size_t count);
char* ImStrdup(const char* str);
char* ImStrdupcpy(char* dst, size_t* p_dst_size, const char* str);
const char* ImStrchrRange(const char* str_begin, const char* str_end, char c);
int ImStrlenW(const ImWchar* str);
const char* ImStreolRange(const char* str, const char* str_end);
const ImWchar ImStrbolW(const ImWchar* buf_mid_line, const ImWchar* buf_begin);
const char* ImStristr(const char* haystack, const char* haystack_end, const char* needle, const char* needle_end);
void ImStrTrimBlanks(char* str);
const char* ImStrSkipBlank(const char* str);

int ImFormatString(char* buf, size_t buf_size, const char* fmt, ...);
int ImFormatStringV(char* buf, size_t buf_size, const char* fmt, va_list args);
void ImFormatStringToTempBuffer(const char** out_buf, const char** out_buf_end, const char* fmt, ...);
void ImFormatStringToTempBufferV(const char** out_buf, const char** out_buf_end, const char* fmt, va_list args);
const char* ImParseFormatFindStart(const char* format);
const char* ImParseFormatFindEnd(const char* format);
const char* ImParseFormatTrimDecorations(const char* format, char* buf, size_t buf_size);
void ImParseFormatSanitizeForPrinting(const char* fmt_in, char* fmt_out, size_t fmt_out_size);
const char* ImParseFormatSanitizeForScanning(const char* fmt_in, char* fmt_out, size_t fmt_out_size);
int ImParseFormatPrecision(const char* format, int default_value);

extern(C++) const char* ImTextCharToUtf8(ref char[5] out_buf, uint c);
int ImTextStrToUtf8(char* out_buf, int out_buf_size, const ImWchar* in_text, const ImWchar* in_text_end);
int ImTextCharFromUtf8(uint* out_char, const char* in_text, const char* in_text_end);
int ImTextStrFromUtf8(ImWchar* out_buf, int out_buf_size, const char* in_text, const char* in_text_end, const char** in_remaining=null);
int ImTextCountCharsFromUtf8(const char* in_text, const char* in_text_end);
int ImTextCountUtf8BytesFromChar(const char* in_text, const char* in_text_end);
int ImTextCountUtf8BytesFromStr(const ImWchar* in_text, const ImWchar* in_text_end);

void* ImFileLoadToMemory(const char* filename, const char* mode, size_t* out_file_size=null, int padding_bytes=0);

ImVec2 ImBezierCubicCalc(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, float t);
ImVec2 ImBezierCubicClosestPoint(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, const ImVec2 p, int num_segments);
ImVec2 ImBezierCubicClosestPointCasteljau(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, const ImVec2 p4, const ImVec2 p, float tess_tol);
ImVec2 ImBezierQuadraticCalc(const ImVec2 p1, const ImVec2 p2, const ImVec2 p3, float t);
ImVec2 ImLineClosestPoint(const ImVec2 a, const ImVec2 b, const ImVec2 p);
bool ImTriangleContainsPoint(const ImVec2 a, const ImVec2 b, const ImVec2 c, const ImVec2 p);
ImVec2 ImTriangleClosestPoint(const ImVec2 a, const ImVec2 b, const ImVec2 c, const ImVec2 p);
void ImTriangleBarycentricCoords(const ImVec2 a, const ImVec2 b, const ImVec2 c, const ImVec2 p, out float out_u, out float out_v, out float out_w);
//	];
//	return ret;
//}(), ""));

//alias ImAlphaBlendColours = ImAlphaBlendColors;
*/
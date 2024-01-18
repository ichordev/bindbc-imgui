/+
+            Copyright 2023 – 2024 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui.internal;

import bindbc.imgui.config;
import bindbc.imgui.codegen;
import imstb.textedit;

import core.stdc.stdlib: memset;
import core.stdc.math: fabsf;

extern(C++){
	struct ImGuiDockRequest;            // Docking system dock/undock queued request
	struct ImGuiDockNodeSettings;       // Storage for a dock node in .ini file (we preserve those even if the associated dock node isn't active during the session)
	struct ImGuiInputTextDeactivateData;// Short term storage to backup text of a deactivating InputText() while another is stealing active id
	struct ImGuiSettingsHandler;        // Storage for one type registered in the .ini file
	struct ImGuiStackSizes;             // Storage of stack sizes for debugging/asserting
	struct ImGuiStyleMod;               // Stacked style modifier, backup of modified data so we can restore it
	struct ImGuiTabBar;                 // Storage for a tab bar
	struct ImGuiTabItem;                // Storage for a tab item (within a tab bar)
	struct ImGuiTable;                  // Storage for a table
	struct ImGuiTableColumn;            // Storage for one column of a table
	struct ImGuiTableInstanceData;      // Storage for one instance of a same table
	struct ImGuiTableTempData;          // Temporary storage for one table (one per table in the stack), shared between tables.
	struct ImGuiTableSettings;          // Storage for a table .ini settings
	struct ImGuiTableColumnsSettings;   // Storage for a column .ini settings
	struct ImGuiTypingSelectState;      // Storage for GetTypingSelectRequest()
	struct ImGuiTypingSelectRequest;    // Storage for GetTypingSelectRequest() (aimed to be public)
	struct ImGuiWindow;                 // Storage for one window
	struct ImGuiWindowTempData;         // Temporary storage for one window (that's the data which in theory we could ditch at the end of the frame, in practice we currently keep it for each window)
}

alias ImGuiErrorLogCallback = extern(C++) void function(void* userData, const(char)* fmt, ...);

extern ImGuiContext* gImGui;

enum IM_PI = 3.14159265358979323846f;

nothrow @nogc pure @safe{
	auto IM_MEMALIGN(ptrdiff_t off, size_t align_) => (off + (align_ - 1)) & ~(align_ - 1);           // Memory align e.g. IM_ALIGN(0,4)=0, IM_ALIGN(1,4)=4, IM_ALIGN(4,4)=4, IM_ALIGN(5,4)=8
	auto IM_TRUNC(float val) => cast(float)cast(int)val;                                    // ImTrunc() is not inlined in MSVC debug builds
	auto IM_ROUND(float val) => cast(float)cast(int)(val + 0.5f);                           //
}

static if({
	version(WebAssembly) return false;
	else version(WASI) return false;
	else return true;
}){
	import core.stdc.stdio: FILE;
	alias ImFileHandle = FILE*;
}else{
	alias ImFileHandle = void*;
}

extern(C++) struct ImVec1{
	float   x = 0f;
}

extern(C++) struct ImVec2ih{
	short x = 0, y = 0;
	
	this(ImVec2 rhs){
		x = cast(short)rhs.x;
		y = cast(short)rhs.y;
	}
}

extern(C++) struct ImRect{
	ImVec2 min = ImVec2(0f, 0f);
	ImVec2 max = ImVec2(0f, 0f);
	
	nothrow @nogc:
	this(ImVec4 v) pure @safe{
		min = ImVec2(v.x, v.y);
		max = ImVec2(v.z, v.w);
	}
	this(float x1, float y1, float x2, float y2) pure @safe{
		min = ImVec2(x1, y1);
		max = ImVec2(x2, y2);
	}

	ImVec2 getCenter() const pure @safe => ImVec2((min.x + max.x) * 0.5f, (min.y + max.y) * 0.5f);
	alias getCentre = getCenter;
	ImVec2 getSize() const pure @safe => ImVec2(max.x - min.x, max.y - min.y);
	float getWidth() const pure @safe => max.x - min.x;
	float getHeight() const pure @safe => max.y - min.y;
	float getArea() const pure @safe => (max.x - min.x) * (max.y - min.y);
	ImVec2 getTL() const pure @safe => min;
	ImVec2 getTR() const pure @safe => ImVec2(max.x, min.y);
	ImVec2 getBL() const pure @safe => ImVec2(min.x, max.y);
	ImVec2 getBR() const pure @safe => max;
	bool contains(ImVec2 p) const pure @safe => p.x >= min.x && p.y >= min.y && p.x <  max.x && p.y <  max.y;
	bool contains(ImRect r) const pure @safe => r.min.x >= min.x && r.min.y >= min.y && r.max.x <= max.x && r.max.y <= max.y;
	bool containsWithPad(ImVec2 p, ImVec2 pad) const pure @safe => p.x >= min.x - pad.x && p.y >= min.y - pad.y && p.x < max.x + pad.x && p.y < max.y + pad.y;
	bool overlaps(ImRect r) const pure @safe => r.min.y < max.y && r.max.y > min.y && r.min.x < max.x && r.max.x > min.x;
	void add(ImVec2 p) pure @safe{
		if(min.x > p.x) min.x = p.x;
		if(min.y > p.y) min.y = p.y;
		if(max.x < p.x) max.x = p.x;
		if(max.y < p.y) max.y = p.y;
	}
	void add(ImRect r) pure @safe{
		if(min.x > r.min.x) min.x = r.min.x;
		if(min.y > r.min.y) min.y = r.min.y;
		if(max.x < r.max.x) max.x = r.max.x;
		if(max.y < r.max.y) max.y = r.max.y;
	}
	void expand(float amount) pure @safe{
		min.x -= amount; min.y -= amount;
		max.x += amount; max.y += amount;
	}
	void expand(ImVec2 amount) pure @safe{
		min.x -= amount.x; min.y -= amount.y;
		max.x += amount.x; max.y += amount.y;
	}
	void translate(ImVec2 d) pure @safe{
		min.x += d.x; min.y += d.y;
		max.x += d.x; max.y += d.y;
	}
	void translateX(float dx) pure @safe{
		min.x += dx; max.x += dx;
	}
	void translateY(float dy) pure @safe{
		min.y += dy; max.y += dy;
	}
	void clipWith(ImRect r){
		min = ImMax(Min, r.min);
		max = ImMin(max, r.max);
	}
	void clipWithFull(ImRect r){
		min = ImClamp(Min, r.min, r.max);
		max = ImClamp(max, r.min, r.max);
	}
	void floor(){
		min.x = IM_TRUNC(min.x); min.y = IM_TRUNC(min.y);
		max.x = IM_TRUNC(max.x); max.y = IM_TRUNC(max.y);
	}
	bool isInverted() const pure @safe => min.x > max.x || min.y > max.y;
	ImVec4 toVec4() const pure @safe => ImVec4(min.x, min.y, max.x, max.y);
}

alias ImBitArrayPtr = uint*; // Name for use in structs

// Helper: ImBitArray class (wrapper over ImBitArray functions)
// Store 1-bit per value.
extern(C++) struct ImBitArray(int BITCOUNT, int OFFSET=0){
	uint[(BITCOUNT + 31) >> 5] storage;
	
	nothrow @nogc:
	void clearAllBits() pure{ memset(storage, 0, storage.sizeof); }
	void setAllBits() pure{ memset(storage, 255, storage.sizeof); }
	bool testBit(int n) const pure @safe{
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		return IM_BITARRAY_TESTBIT(storage, n);
	}
	void setBit(int n) pure @safe{
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		ImBitArraySetBit(storage, n);
	}
	void clearBit(int n) pure @safe{
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		ImBitArrayClearBit(storage, n);
	}
	void setBitRange(int n, int n2) pure @safe{
		n += OFFSET; n2 += OFFSET;
		assert(n >= 0 && n < BITCOUNT && n2 > n && n2 <= BITCOUNT);
		ImBitArraySetBitRange(storage, n, n2);
	}
	bool opIndex(int n) const pure @safe{
		n += OFFSET;
		assert(n >= 0 && n < BITCOUNT);
		return IM_BITARRAY_TESTBIT(storage, n);
	}
};

extern(C++) struct ImBitVector{
	ImVector!uint storage;
	
	nothrow @nogc:
	void create(int sz) pure{
		storage.resize((sz + 31) >> 5);
		memset(storage.data, 0, cast(size_t)storage.size * storage.data[0].sizeof);
	}
	void clear() pure{ storage.clear(); }
	bool testBit(int n) const pure @safe in(n < (storage.size << 5)) => IM_BITARRAY_TESTBIT(storage.data, n);
	void setBit(int n) in(n < (Storage.Size << 5)){ ImBitArraySetBit(storage.data, n); }
	void clearBit(int n) in(n < (Storage.Size << 5)){ ImBitArrayClearBit(storage.data, n); }
}

extern(C++) struct ImSpan(T){
	T* data = null;
	T* dataEnd = null;
	
	inline ImSpan(T* data, int size)                { Data = data; DataEnd = data + size; }
	inline ImSpan(T* data, T* dataEnd)             { Data = data; DataEnd = data_end; }

	inline void         set(T* data, int size)      { Data = data; DataEnd = data + size; }
	inline void         set(T* data, T* data_end)   { Data = data; DataEnd = data_end; }
	inline int          size() const                { return (int)(ptrdiff_t)(DataEnd - Data); }
	inline int          size_in_bytes() const       { return (int)(ptrdiff_t)(DataEnd - Data) * (int)sizeof(T); }
	inline T&           operator[](int i)           { T* p = Data + i; IM_ASSERT(p >= Data && p < DataEnd); return *p; }
	inline const T&     operator[](int i) const     { const(T)* p = Data + i; IM_ASSERT(p >= Data && p < DataEnd); return *p; }

	inline T*           begin()                     { return Data; }
	inline const(T)*     begin() const               { return Data; }
	inline T*           end()                       { return DataEnd; }
	inline const(T)*     end() const                 { return DataEnd; }

	// Utilities
	inline int  index_from_ptr(const(T)* it) const   { IM_ASSERT(it >= Data && it < DataEnd); const ptrdiff_t off = it - Data; return (int)off; }
};

// Helper: ImSpanAllocator<>
// Facilitate storing multiple chunks into a single large block (the "arena")
// - Usage: call Reserve() N times, allocate GetArenaSizeInBytes() worth, pass it to SetArenaBasePtr(), call GetSpan() N times to retrieve the aligned ranges.
struct ImSpanAllocator(int CHUNKS){
	char* basePtr = null;
	int currOff = 0;
	int currIdx = 0;
	int[CHUNKS] offsets;
	int[CHUNKS] sizes;

	inline void  Reserve(int n, size_t sz, int a=4) { IM_ASSERT(n == CurrIdx && n < CHUNKS); CurrOff = IM_MEMALIGN(currOff, a); Offsets[n] = CurrOff; Sizes[n] = (int)sz; CurrIdx++; CurrOff += (int)sz; }
	inline int   GetArenaSizeInBytes()              { return CurrOff; }
	inline void  SetArenaBasePtr(void* base_ptr)    { BasePtr = (char*)base_ptr; }
	inline void* GetSpanPtrBegin(int n)             { IM_ASSERT(n >= 0 && n < CHUNKS && CurrIdx == CHUNKS); return (void*)(BasePtr + Offsets[n]); }
	inline void* GetSpanPtrEnd(int n)               { IM_ASSERT(n >= 0 && n < CHUNKS && CurrIdx == CHUNKS); return (void*)(BasePtr + Offsets[n] + Sizes[n]); }
	template<typename T>
	inline void  GetSpan(int n, ImSpan<T>* span)    { span->set((T*)GetSpanPtrBegin(n), (T*)GetSpanPtrEnd(n)); }
};

// Helper: ImPool<>
// Basic keyed storage for contiguous instances, slow/amortized insertion, O(1) indexable, O(Log N) queries by ID over a dense/hot buffer,
// Honor constructor/destructor. Add/remove invalidate all pointers. Indexes have the same lifetime as the associated object.
alias ImPoolIdx = int;

struct ImPool(T){
	ImVector<T>     Buf;        // Contiguous data
	ImGuiStorage    Map;        // ID->Index
	ImPoolIdx       FreeIdx;    // Next free idx to use
	ImPoolIdx       AliveCount; // Number of active/alive items (for display purpose)

	ImPool()    { FreeIdx = AliveCount = 0; }
	~ImPool()   { Clear(); }
	T*          GetByKey(ImGuiID key)               { int idx = Map.GetInt(key, -1); return (idx != -1) ? &Buf[idx] : NULL; }
	T*          GetByIndex(ImPoolIdx n)             { return &Buf[n]; }
	ImPoolIdx   GetIndex(const(T)* p) const          { IM_ASSERT(p >= Buf.Data && p < Buf.Data + Buf.Size); return (ImPoolIdx)(p - Buf.Data); }
	T*          GetOrAddByKey(ImGuiID key)          { int* p_idx = Map.GetIntRef(key, -1); if (*p_idx != -1) return &Buf[*p_idx]; *p_idx = FreeIdx; return Add(); }
	bool        Contains(const(T)* p) const          { return (p >= Buf.Data && p < Buf.Data + Buf.Size); }
	void        Clear()                             { for (int n = 0; n < Map.Data.Size; n++) { int idx = Map.Data[n].val_i; if (idx != -1) Buf[idx].~T(); } Map.Clear(); Buf.clear(); FreeIdx = AliveCount = 0; }
	T*          Add()                               { int idx = FreeIdx; if (idx == Buf.Size) { Buf.resize(Buf.Size + 1); FreeIdx++; } else { FreeIdx = *(int*)&Buf[idx]; } IM_PLACEMENT_NEW(&Buf[idx]) T(); AliveCount++; return &Buf[idx]; }
	void        Remove(ImGuiID key, const(T)* p)     { Remove(key, GetIndex(p)); }
	void        Remove(ImGuiID key, ImPoolIdx idx)  { Buf[idx].~T(); *(int*)&Buf[idx] = FreeIdx; FreeIdx = idx; Map.SetInt(key, -1); AliveCount--; }
	void        Reserve(int capacity)               { Buf.reserve(capacity); Map.Data.reserve(capacity); }

	// To iterate a ImPool: for (int n = 0; n < pool.GetMapSize(); n++) if (T* t = pool.TryGetMapData(n)) { ... }
	// Can be avoided if you know .Remove() has never been called on the pool, or AliveCount == GetMapSize()
	int         GetAliveCount() const               { return AliveCount; }      // Number of active/alive items in the pool (for display purpose)
	int         GetBufSize() const                  { return Buf.Size; }
	int         GetMapSize() const                  { return Map.Data.Size; }   // It is the map we need iterate to find valid items, since we don't have "alive" storage anywhere
	T*          TryGetMapData(ImPoolIdx n)          { int idx = Map.Data[n].val_i; if (idx == -1) return NULL; return GetByIndex(idx); }
}

// Helper: ImChunkStream<>
// Build and iterate a contiguous stream of variable-sized structures.
// This is used by Settings to store persistent data while reducing allocation count.
// We store the chunk size first, and align the final size on 4 bytes boundaries.
// The tedious/zealous amount of casting is to avoid -Wcast-align warnings.
struct ImChunkStream(T){
	ImVector!char buf;
	
	nothrow @nogc:
	void clear() pure{ buf.clear(); }
	bool empty() const pure @safe => buf.size == 0;
	int size() const pure @safe => buf.size;
	T* allocChunk(size_t sz){
		size_t HDR_SZ = 4;
		sz = IM_MEMALIGN(HDR_SZ + sz, 4u);
		int off = buf.Size;
		buf.resize(off + cast(int)sz);
		((int*)(void*)(Buf.Data + off))[0] = (int)sz;
		return cast(T*)cast(void*)(buf.data + off + cast(int)HDR_SZ);
	}
	T* begin()                     { size_t HDR_SZ = 4; if (!Buf.Data) return NULL; return (T*)(void*)(Buf.Data + HDR_SZ); }
	T* nextChunk(T* p)            { size_t HDR_SZ = 4; IM_ASSERT(p >= begin() && p < end()); p = (T*)(void*)((char*)(void*)p + chunk_size(p)); if (p == (T*)(void*)((char*)end() + HDR_SZ)) return (T*)0; IM_ASSERT(p < end()); return p; }
	int chunkSize(const(T)* p)      { return ((const(int)*)p)[-1]; }
	T* end()                       { return (T*)(void*)(Buf.Data + Buf.Size); }
	int offsetFromPtr(const(T)* p) { IM_ASSERT(p >= begin() && p < end()); const ptrdiff_t off = (const(char)*)p - Buf.Data; return (int)off; }
	T* ptrFromOffset(int off)    { IM_ASSERT(off >= 4 && off < Buf.Size); return (T*)(void*)(Buf.Data + off); }
	void swap(ImChunkStream<T>& rhs) { rhs.Buf.swap(Buf); }
};

// Helper: ImGuiTextIndex<>
// Maintain a line index for a text buffer. This is a strong candidate to be moved into the public API.
extern(C++) struct ImGuiTextIndex{
	ImVector!int lineOffsets;
	int endOffset = 0;                          // Because we don't own text buffer we need to maintain EndOffset (may bake in LineOffsets?)
	
	void append(const(char)* base, int oldSize, int newSize);
	
	nothrow @nogc:
	void clear(){ LineOffsets.clear(); EndOffset = 0; }
	int size() => LineOffsets.Size;
	const(char)* getLineBegin(const(char)* base, int n) => base + LineOffsets[n];
	const(char)* getLineEnd(const(char)* base, int n) => base + (n + 1 < LineOffsets.Size ? (LineOffsets[n + 1] - 1) : EndOffset);
	
}

//-----------------------------------------------------------------------------
// [SECTION] ImDrawList support
//-----------------------------------------------------------------------------

// ImDrawList: Helper function to calculate a circle's segment count given its radius and a "maximum error" value.
// Estimation of number of circle segment based on error is derived using method described in https://stackoverflow.com/a/2244088/15194693
// Number of segments (N) is calculated using equation:
//   N = ceil ( pi / acos(1 - error / r) )     where r > 0, error <= r
// Our equation is significantly simpler that one in the post thanks for choosing segment that is
// perpendicular to X axis. Follow steps in the article from this starting condition and you will
// will get this result.
//
// Rendering circles with an odd number of segments, while mathematically correct will produce
// asymmetrical results on the raster grid. Therefore we're rounding N to next even number (7->8, 8->8, 9->10 etc.)
//#define IM_ROUNDUP_TO_EVEN(_V)                                  ((((_V) + 1) / 2) * 2)
//#define IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MIN                     4
//#define IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MAX                     512
//#define IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_CALC(_RAD,_MAXERROR)    ImClamp(IM_ROUNDUP_TO_EVEN((int)ImCeil(IM_PI / ImAcos(1 - ImMin((_MAXERROR), (_RAD)) / (_RAD)))), IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MIN, IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_MAX)

// Raw equation from IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_CALC rewritten for 'r' and 'error'.
//#define IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_CALC_R(_N,_MAXERROR)    ((_MAXERROR) / (1 - ImCos(IM_PI / ImMax((float)(_N), IM_PI))))
//#define IM_DRAWLIST_CIRCLE_AUTO_SEGMENT_CALC_ERROR(_N,_RAD)     ((1 - ImCos(IM_PI / ImMax((float)(_N), IM_PI))) / (_RAD))

// ImDrawList: Lookup table size for adaptive arc drawing, cover full circle.
enum IM_DRAWLIST_ARCFAST_TABLE_SIZE = 48; // Number of samples in lookup table.

//#define IM_DRAWLIST_ARCFAST_SAMPLE_MAX                          IM_DRAWLIST_ARCFAST_TABLE_SIZE // Sample index _PathArcToFastEx() for 360 angle.

// Data shared between all ImDrawList instances
// You may want to create your own instance of this if you want to use ImDrawList completely without ImGui. In that case, watch out for future changes to this structure.
extern(C++) struct IMGUI_API ImDrawListSharedData{
	ImVec2 TexUvWhitePixel;            // UV of white pixel in the atlas
	ImFont* Font;                       // Current/default font (optional, for simplified AddText overload)
	float FontSize;                   // Current/default font size (optional, for simplified AddText overload)
	float CurveTessellationTol;       // Tessellation tolerance when using PathBezierCurveTo()
	float CircleSegmentMaxError;      // Number of circle segments to use per pixel of radius for AddCircle() etc
	ImVec4 ClipRectFullscreen;         // Value for PushClipRectFullscreen()
	ImDrawListFlags InitialFlags;               // Initial flags at the beginning of the frame (it is possible to alter flags on a per-drawlist basis afterwards)
	
	ImVector!ImVec2 TempBuffer;
	
	ImVec2[IM_DRAWLIST_ARCFAST_TABLE_SIZE] arcFastVtx; // Sample points on the quarter of the circle.
	float arcFastRadiusCutoff;                        // Cutoff radius after which arc drawing will fallback to slower PathArcTo()
	ubyte[64] circleSegmentCounts;    // Precomputed segment count for given radius before we calculate it dynamically (to avoid calculation overhead)
	const(ImVec4)* texUvLines;                 // UV of anti-aliased lines in the atlas
	
	this();
	void SetCircleTessellationMaxError(float maxError);
}

extern(C++) struct ImDrawDataBuilder{
	ImVector!(ImDrawList*)*[2] layers;      // Pointers to global layers for: regular, tooltip. LayersP[0] is owned by DrawData.
	ImVector!(ImDrawList*) layerData1;
}

//-----------------------------------------------------------------------------
// [SECTION] Widgets support: flags, enums, data structures
//-----------------------------------------------------------------------------

// Flags used by upcoming items
// - input: PushItemFlag() manipulates g.CurrentItemFlags, ItemAdd() calls may add extra flags.
// - output: stored in g.LastItemData.InFlags
// Current window shared by all windows.
// This is going to be exposed in imgui.h when stabilized enough.
alias ImGuiItemFlags_ = int;
enum ImGuiItemFlags: ImGuiItemFlags_{
	none                     = 0,
	noTabStop                = 1 << 0,  // false     // Disable keyboard tabbing. This is a "lighter" version of ImGuiItemFlags_NoNav.
	buttonRepeat             = 1 << 1,  // false     // Button() will return true multiple times based on io.KeyRepeatDelay and io.KeyRepeatRate settings.
	disabled                 = 1 << 2,  // false     // Disable interactions but doesn't affect visuals. See BeginDisabled()/EndDisabled(). See github.com/ocornut/imgui/issues/211
	noNav                    = 1 << 3,  // false     // Disable any form of focusing (keyboard/gamepad directional navigation and SetKeyboardFocusHere() calls)
	noNavDefaultFocus        = 1 << 4,  // false     // Disable item being a candidate for default focus (e.g. used by title bar items)
	selectableDontClosePopup = 1 << 5,  // false     // Disable MenuItem/Selectable() automatically closing their popup window
	mixedValue               = 1 << 6,  // false     // [BETA] Represent a mixed/indeterminate value, generally multi-selection where values differ. Currently only supported by Checkbox() (later should support all sorts of widgets)
	readOnly                 = 1 << 7,  // false     // [ALPHA] Allow hovering interactions but underlying value is not changed.
	noWindowHoverableCheck   = 1 << 8,  // false     // Disable hoverable check in ItemHoverable()
	allowOverlap             = 1 << 9,  // false     // Allow being overlapped by another widget. Not-hovered to Hovered transition deferred by a frame.
	
	inputable                = 1 << 10, // false     // [WIP] Auto-activate input mode when tab focused. Currently only used and supported by a few items before it becomes a generic feature.
	hasSelectionUserData     = 1 << 11, // false     // Set by SetNextItemSelectionUserData()
}

// Status flags for an already submitted item
// - output: stored in g.LastItemData.StatusFlags
alias ImGuiItemStatusFlags_ = int;
enum ImGuiItemStatusFlags: ImGuiItemStatusFlags_{
	none               = 0,
	hoveredRect        = 1 << 0,   // Mouse position is within item rectangle (does NOT mean that the window is in correct z-order and can be hovered!, this is only one part of the most-common IsItemHovered test)
	hasDisplayRect     = 1 << 1,   // g.LastItemData.DisplayRect is valid
	edited             = 1 << 2,   // Value exposed by item was edited in the current frame (should match the bool return value of most widgets)
	toggledSelection   = 1 << 3,   // Set when Selectable(), TreeNode() reports toggling a selection. We can't report "Selected", only state changes, in order to easily handle clipping with less issues.
	toggledOpen        = 1 << 4,   // Set when TreeNode() reports toggling their open state.
	hasDeactivated     = 1 << 5,   // Set if the widget/group is able to provide data for the ImGuiItemStatusFlags_Deactivated flag.
	deactivated        = 1 << 6,   // Only valid if ImGuiItemStatusFlags_HasDeactivated is set.
	hoveredWindow      = 1 << 7,   // Override the HoveredWindow test to allow cross-window hover testing.
	focusedByTabbing   = 1 << 8,   // Set when the Focusable item just got focused by Tabbing (FIXME: to be removed soon)
	visible            = 1 << 9,   // [WIP] Set when item is overlapping the current clipping rectangle (Used internally. Please don't use yet: API/system will change as we refactor Itemadd()).
}

enum ImGuiHoveredFlagsPrivate: ImGuiHoveredFlags{
	delayMask_                    = ImGuiHoveredFlags_DelayNone | ImGuiHoveredFlags_DelayShort | ImGuiHoveredFlags_DelayNormal | ImGuiHoveredFlags_NoSharedDelay,
	allowedMaskForIsWindowHovered = ImGuiHoveredFlags_ChildWindows | ImGuiHoveredFlags_RootWindow | ImGuiHoveredFlags_AnyWindow | ImGuiHoveredFlags_NoPopupHierarchy | ImGuiHoveredFlags_DockHierarchy | ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_ForTooltip | ImGuiHoveredFlags_Stationary,
	allowedMaskForIsItemHovered   = ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_AllowWhenOverlapped | ImGuiHoveredFlags_AllowWhenDisabled | ImGuiHoveredFlags_NoNavOverride | ImGuiHoveredFlags_ForTooltip | ImGuiHoveredFlags_Stationary | ImGuiHoveredFlags_DelayMask_,
}

enum ImGuiInputTextFlagsPrivate: ImGuiInputTextFlags{
	multiline           = 1 << 26,  // For internal use by InputTextMultiline()
	noMarkEdited        = 1 << 27,  // For internal use by functions using InputText() before reformatting data
	mergedItem          = 1 << 28,  // For internal use by TempInputText(), will skip calling ItemAdd(). Require bounding-box to strictly match.
};

enum ImGuiButtonFlagsPrivate: ImGuiButtonFlags{
	pressedOnClick         = 1 << 4,   // return true on click (mouse down event)
	pressedOnClickRelease  = 1 << 5,   // [Default] return true on click + release on same item <-- this is what the majority of Button are using
	pressedOnClickReleaseAnywhere = 1 << 6, // return true on click + release even if the release event is not done while hovering the item
	pressedOnRelease       = 1 << 7,   // return true on release (default requires click+release)
	pressedOnDoubleClick   = 1 << 8,   // return true on double-click (default requires click+release)
	pressedOnDragDropHold  = 1 << 9,   // return true when held into while we are drag and dropping another item (used by e.g. tree nodes, collapsing headers)
	repeat                 = 1 << 10,  // hold to repeat
	flattenChildren        = 1 << 11,  // allow interactions even if a child window is overlapping
	allowOverlap           = 1 << 12,  // require previous frame HoveredId to either match id or be null before being usable.
	dontClosePopups        = 1 << 13,  // disable automatically closing parent popup on press // [UNUSED]
	
	alignTextBaseLine      = 1 << 15,  // vertically align button to match text baseline - ButtonEx() only // FIXME: Should be removed and handled by SmallButton(), not possible currently because of DC.CursorPosPrevLine
	noKeyModifiers         = 1 << 16,  // disable mouse interaction if a key modifier is held
	noHoldingActiveID      = 1 << 17,  // don't set ActiveId while holding the mouse (ImGuiButtonFlags_PressedOnClick only)
	noNavFocus             = 1 << 18,  // don't override navigation focus when activated (FIXME: this is essentially used everytime an item uses ImGuiItemFlags_NoNav, but because legacy specs don't requires LastItemData to be set ButtonBehavior(), we can't poll g.LastItemData.InFlags)
	noHoveredOnFocus       = 1 << 19,  // don't report as hovered when nav focus is on this item
	noSetKeyOwner          = 1 << 20,  // don't set key/input owner on the initial click (note: mouse buttons are keys! often, the key in question will be ImGuiKey_MouseLeft!)
	noTestKeyOwner         = 1 << 21,  // don't test key/input owner when polling the key (note: mouse buttons are keys! often, the key in question will be ImGuiKey_MouseLeft!)
	pressedOnMask_         = ImGuiButtonFlags_PressedOnClick | ImGuiButtonFlags_PressedOnClickRelease | ImGuiButtonFlags_PressedOnClickReleaseAnywhere | ImGuiButtonFlags_PressedOnRelease | ImGuiButtonFlags_PressedOnDoubleClick | ImGuiButtonFlags_PressedOnDragDropHold,
	pressedOnDefault_      = ImGuiButtonFlags_PressedOnClickRelease,
}

enum ImGuiComboFlagsPrivate: ImGuiComboFlags{
	customPreview           = 1 << 20,  // enable BeginComboPreview()
}

enum ImGuiSliderFlagsPrivate: ImGuiSliderFlags{
	vertical               = 1 << 20,  // Should this slider be orientated vertically?
	readOnly               = 1 << 21,  // Consider using g.NextItemData.ItemFlags |= ImGuiItemFlags_ReadOnly instead.
}

enum ImGuiSelectableFlagsPrivate: ImGuiSelectableFlags{
	noHoldingActiveID      = 1 << 20,
	selectOnNav            = 1 << 21,  // (WIP) Auto-select when moved into. This is not exposed in public API as to handle multi-select and modifiers we will need user to explicitly control focus scope. May be replaced with a BeginSelection() API.
	selectOnClick          = 1 << 22,  // Override button behavior to react on Click (default is Click+Release)
	selectOnRelease        = 1 << 23,  // Override button behavior to react on Release (default is Click+Release)
	spanAvailWidth         = 1 << 24,  // Span all avail width even if we declared less for layout purpose. FIXME: We may be able to remove this (added in 6251d379, 2bcafc86 for menus)
	setNavIdOnHover        = 1 << 25,  // Set Nav/Focus ID on mouse hover (used by MenuItem)
	noPadWithHalfSpacing   = 1 << 26,  // Disable padding each side with ItemSpacing * 0.5f
	noSetKeyOwner          = 1 << 27,  // Don't set key/input owner on the initial click (note: mouse buttons are keys! often, the key in question will be ImGuiKey_MouseLeft!)
}

enum ImGuiTreeNodeFlagsPrivate: ImGuiTreeNodeFlags{
	clipLabelForTrailingButton = 1 << 20,
	upsideDownArrow            = 1 << 21,// (FIXME-WIP) Turn Down arrow into an Up arrow, but reversed trees (#6517)
}

alias ImGuiSeparatorFlags_ = int;
enum ImGuiSeparatorFlags: ImGuiSeparatorFlags_{
	none                    = 0,
	horizontal              = 1 << 0,   // Axis default to current layout type, so generally Horizontal unless e.g. in a menu bar
	vertical                = 1 << 1,
	spanAllColumns          = 1 << 2,   // Make separator cover all columns of a legacy Columns() set.
}

// Flags for FocusWindow(). This is not called ImGuiFocusFlags to avoid confusion with public-facing ImGuiFocusedFlags.
// FIXME: Once we finishing replacing more uses of GetTopMostPopupModal()+IsWindowWithinBeginStackOf()
// and FindBlockingModal() with this, we may want to change the flag to be opt-out instead of opt-in.
alias ImGuiFocusRequestFlags_ = int;
enum ImGuiFocusRequestFlags: ImGuiFocusRequestFlags_{
	none                 = 0,
	restoreFocusedChild  = 1 << 0,   // Find last focused child (if any) and focus it instead.
	unlessBelowModal     = 1 << 1,   // Do not set focus if the window is below a modal.
}

alias ImGuiTextFlags_ = int;
enum ImGuiTextFlags: ImGuiTextFlags_{
	none                         = 0,
	noWidthForLargeClippedText   = 1 << 0,
}

alias ImGuiTooltipFlags_ = int;
enum ImGuiTooltipFlags: ImGuiTooltipFlags_{
	none                      = 0,
	overridePrevious          = 1 << 1,   // Clear/ignore previously submitted tooltip (defaults to append)
}

// FIXME: this is in development, not exposed/functional as a generic feature yet.
// Horizontal/Vertical enums are fixed to 0/1 so they may be used to index ImVec2
alias ImGuiLayoutType_ = int;
enum ImGuiLayoutType: ImGuiLayoutType_{
	horizontal = 0,
	vertical = 1,
}

enum ImGuiLogType{
	none = 0,
	tty,
	file,
	buffer,
	clipboard,
};

// X/Y enums are fixed to 0/1 so they may be used to index ImVec2
enum ImGuiAxis{
	none = -1,
	x = 0,
	y = 1,
};

enum ImGuiPlotType{
	lines,
	histogram,
}

enum ImGuiPopupPositionPolicy{
	default,
	comboBox,
	tooltip,
}

extern(C++) struct ImGuiDataVarInfo{
	ImGuiDataType type;
	uint count;      // 1+
	uint offset;     // Offset in parent structure
	
	nothrow @nogc:
	void* getVarPtr(void* parent) const pure @safe => cast(void*)(cast(ubyte*)parent + offset);
}

extern(C++) struct ImGuiDataTypeTempStorage{
	ubyte[8] data;        // Can fit any data up to ImGuiDataType_COUNT
}

// Type information associated to one ImGuiDataType. Retrieve with DataTypeGetInfo().
extern(C++) struct ImGuiDataTypeInfo{
	size_t size;           // Size in bytes
	const(char)* name;           // Short descriptive name for the type, for debugging
	const(char)* printFmt;       // Default printf format for the type
	const(char)* scanFmt;        // Default scanf format for the type
}

enum ImGuiDataTypePrivate: ImGuiDataType{
	string = ImGuiDataType.COUNT + 1,
	pointer,
	id,
}

// Stacked color modifier, backup of modified data so we can restore it
extern(C++) struct ImGuiColorMod{
	ImGuiCol        col;
	ImVec4          backupValue;
}
alias ImGuiColourMod = ImGuiColorMod;

// Stacked style modifier, backup of modified data so we can restore it. Data type inferred from the variable.
extern(C++) struct ImGuiStyleMod{
	ImGuiStyleVar varIdx;
	union{ int[2] backupInt; float[2] backupFloat; };
	ImGuiStyleMod(ImGuiStyleVar idx, int v)     { varIdx = idx; backupInt[0] = v; }
	ImGuiStyleMod(ImGuiStyleVar idx, float v)   { varIdx = idx; backupFloat[0] = v; }
	ImGuiStyleMod(ImGuiStyleVar idx, ImVec2 v)  { varIdx = idx; backupFloat[0] = v.x; backupFloat[1] = v.y; }
}

// Storage data for BeginComboPreview()/EndComboPreview()
extern(C++) struct IMGUI_API ImGuiComboPreviewData{
	ImRect previewRect;
	ImVec2 backupCursorPos;
	ImVec2 backupCursorMaxPos;
	ImVec2 backupCursorPosPrevLine;
	float backupPrevLineTextBaseOffset;
	ImGuiLayoutType backupLayout;

	ImGuiComboPreviewData() { memset(this, 0, sizeof(*this)); }
}

// Stacked storage data for BeginGroup()/EndGroup()
extern(C++) struct IMGUI_API ImGuiGroupData{
	ImGuiID     windowID;
	ImVec2      backupCursorPos;
	ImVec2      backupCursorMaxPos;
	ImVec2      backupCursorPosPrevLine;
	ImVec1      backupIndent;
	ImVec1      backupGroupOffset;
	ImVec2      backupCurrLineSize;
	float       backupCurrLineTextBaseOffset;
	ImGuiID     backupActiveIDIsAlive;
	bool        backupActiveIDPreviousFrameIsAlive;
	bool        backupHoveredIDIsAlive;
	bool        backupIsSameLine;
	bool        emitItem;
}

// Simple column measurement, currently used for MenuItem() only.. This is very short-sighted/throw-away code and NOT a generic helper.
extern(C++) struct IMGUI_API ImGuiMenuColumns{
	uint       totalWidth;
	uint       nextTotalWidth;
	ushort     spacing;
	ushort     offsetIcon;         // Always zero for now
	ushort     offsetLabel;        // Offsets are locked in Update()
	ushort     offsetShortcut;
	ushort     offsetMark;
	ushort[4]     widths;          // Width of:   Icon, Label, Shortcut, Mark  (accumulators for current frame)

	ImGuiMenuColumns() { memset(this, 0, sizeof(*this)); }
	void        Update(float spacing, bool window_reappearing);
	float       DeclColumns(float w_icon, float w_label, float w_shortcut, float w_mark);
	void        CalcNextTotalWidth(bool update_offsets);
}

// Internal temporary state for deactivating InputText() instances.
extern(C++) sstruct IMGUI_API ImGuiInputTextDeactivatedState{
	ImGuiID            id;              // widget id owning the text state (which just got deactivated)
	ImVector!char     textA;           // text buffer
	
	ImGuiInputTextDeactivatedState()    { memset(this, 0, sizeof(*this)); }
	void    ClearFreeMemory()           { ID = 0; TextA.clear(); }
}
// Internal state of the currently focused/edited text input box
// For a given item ID, access with ImGui::GetInputTextState()
extern(C++) struct IMGUI_API ImGuiInputTextState{
	ImGuiContext* ctx;                    // parent UI context (needs to be set explicitly by parent).
	ImGuiID id;                     // widget id owning the text state
	int curLenW, curLenA;       // we need to maintain our buffer length in both UTF-8 and wchar format. UTF-8 length is valid even if TextA is not.
	ImVector!ImWchar textW;                  // edit buffer, we need to persist but can't guarantee the persistence of the user-provided buffer. so we copy into own buffer.
	ImVector!char textA;                  // temporary UTF8 buffer for callbacks and other operations. this is not updated in every code-path! size=capacity.
	ImVector!char initialTextA;           // backup of end-user buffer at the time of focus (in UTF-8, unaltered)
	bool textAIsValid;           // temporary UTF8 buffer is not initially valid before we make the widget active (until then we pull the data from user argument)
	int bufCapacityA;           // end-user buffer capacity
	float scrollX;                // horizontal scrolling/offset
	STB_TexteditState stb;                   // state for stb_textedit.h
	float cursorAnim;             // timer for cursor blink, reset on every user action so the cursor reappears immediately
	bool cursorFollow;           // set when we want scrolling to follow the current cursor position (not always!)
	bool selectedAllMouseLock;   // after a double-click to select all, we ignore further mouse drags to update selection
	bool edited;                 // edited this frame
	ImGuiInputTextFlags flags;                  // copy of InputText() flags. may be used to check if e.g. ImGuiInputTextFlags_Password is set.

	ImGuiInputTextState()                   { memset(this, 0, sizeof(*this)); }
	void        ClearText()                 { CurLenW = CurLenA = 0; TextW[0] = 0; TextA[0] = 0; CursorClamp(); }
	void        ClearFreeMemory()           { TextW.clear(); TextA.clear(); InitialTextA.clear(); }
	int         GetUndoAvailCount() const   { return Stb.undostate.undo_point; }
	int         GetRedoAvailCount() const   { return STB_TEXTEDIT_UNDOSTATECOUNT - Stb.undostate.redo_point; }
	void        OnKeyPressed(int key);      // Cannot be inline because we call in code in stb_textedit.h implementation

	// Cursor & Selection
	void        CursorAnimReset()           { CursorAnim = -0.30f; }                                   // After a user-input the cursor stays on for a while without blinking
	void        CursorClamp()               { Stb.cursor = ImMin(Stb.cursor, CurLenW); Stb.select_start = ImMin(Stb.select_start, CurLenW); Stb.select_end = ImMin(Stb.select_end, CurLenW); }
	bool        HasSelection() const        { return Stb.select_start != Stb.select_end; }
	void        ClearSelection()            { Stb.select_start = Stb.select_end = Stb.cursor; }
	int         GetCursorPos() const        { return Stb.cursor; }
	int         GetSelectionStart() const   { return Stb.select_start; }
	int         GetSelectionEnd() const     { return Stb.select_end; }
	void        SelectAll()                 { Stb.select_start = 0; Stb.cursor = Stb.select_end = CurLenW; Stb.has_preferred_x = 0; }
};

// Storage for current popup stack
extern(C++) struct ImGuiPopupData{
	ImGuiID             PopupId;        // Set on OpenPopup()
	ImGuiWindow*        Window;         // Resolved on BeginPopup() - may stay unresolved if user never calls OpenPopup()
	ImGuiWindow*        BackupNavWindow;// Set on OpenPopup(), a NavWindow that will be restored on popup close
	int                 ParentNavLayer; // Resolved on BeginPopup(). Actually a ImGuiNavLayer type (declared down below), initialized to -1 which is not part of an enum, but serves well-enough as "not any of layers" value
	int                 OpenFrameCount; // Set on OpenPopup()
	ImGuiID             OpenParentId;   // Set on OpenPopup(), we need this to differentiate multiple menu sets from each others (e.g. inside menu bar vs loose menu items)
	ImVec2              OpenPopupPos;   // Set on OpenPopup(), preferred popup position (typically == OpenMousePos when using mouse)
	ImVec2              OpenMousePos;   // Set on OpenPopup(), copy of mouse position at the time of opening popup

	ImGuiPopupData()    { memset(this, 0, sizeof(*this)); ParentNavLayer = OpenFrameCount = -1; }
}

alias ImGuiNextWindowDataFlags_ = int;
enum ImGuiNextWindowDataFlags: ImGuiNextWindowDataFlags_{
	none               = 0,
	hasPos             = 1 << 0,
	hasSize            = 1 << 1,
	hasContentSize     = 1 << 2,
	hasCollapsed       = 1 << 3,
	hasSizeConstraint  = 1 << 4,
	hasFocus           = 1 << 5,
	hasBgAlpha         = 1 << 6,
	hasScroll          = 1 << 7,
	hasChildFlags      = 1 << 8,
	hasViewport        = 1 << 9,
	hasDock            = 1 << 10,
	hasWindowClass     = 1 << 11,
};

// Storage for SetNexWindow** functions
extern(C++) struct ImGuiNextWindowData{
	ImGuiNextWindowDataFlags_ flags = 0;
	ImGuiCond_ posCond = 0;
	ImGuiCond_ sizeCond = 0;
	ImGuiCond_ collapsedCond = 0;
	ImGuiCond_ dockCond = 0;
	ImVec2 posVal = ImVec2(0, 0);
	ImVec2 posPivotVal = ImVec2(0, 0);
	ImVec2 sizeVal = ImVec2(0, 0);
	ImVec2 contentSizeVal = ImVec2(0, 0);
	ImVec2 scrollVal = ImVec2(0, 0);
	ImGuiChildFlags_ childFlags = 0;
	bool posUndock = false;
	bool collapsedVal = false;
	ImRect sizeConstraintRect = ImRect(ImVec2(0, 0), ImVec2(0, 0));
	ImGuiSizeCallback sizeCallback = null;
	void* sizeCallbackUserData = null;
	float bgAlphaVal = 0f;
	ImGuiID viewportID = 0;
	ImGuiID dockID = 0;
	ImGuiWindowClass windowClass;
	ImVec2 menuBarOffsetMinVal = ImVec2(0, 0);
	
	nothrow @nogc:
	void clearFlags() pure @safe{ flags = ImGuiNextWindowDataFlags.none; }
}

alias ImGuiSelectionUserData = long;

alias ImGuiNextItemDataFlags_ = int;
enum ImGuiNextItemDataFlags: ImGuiNextItemDataFlags_{
	none      = 0,
	hasWidth  = 1 << 0,
	hasOpen   = 1 << 1,
}

extern(C++) struct ImGuiNextItemData{
	ImGuiNextItemDataFlags      Flags;
	ImGuiItemFlags              ItemFlags;          // Currently only tested/used for ImGuiItemFlags_AllowOverlap.
	// Non-flags members are NOT cleared by ItemAdd() meaning they are still valid during NavProcessItem()
	float                       Width;              // Set by SetNextItemWidth()
	ImGuiSelectionUserData      SelectionUserData = -1;  // Set by SetNextItemSelectionUserData() (note that NULL/0 is a valid value, we use -1 == ImGuiSelectionUserData_Invalid to mark invalid values)
	ImGuiCond                   OpenCond;
	bool                        OpenVal;            // Set by SetNextItemOpen()
	
	nothrow @nogc:
	this()         { memset(this, 0, sizeof(*this)); SelectionUserData = -1; }
	inline void ClearFlags()    { Flags = ImGuiNextItemDataFlags_None; ItemFlags = ImGuiItemFlags_None; } // Also cleared manually by ItemAdd()!
}

// Status storage for the last submitted item
extern(C++) struct ImGuiLastItemData{
	ImGuiID                 id;
	ImGuiItemFlags          inFlags;            // See ImGuiItemFlags_
	ImGuiItemStatusFlags    statusFlags;        // See ImGuiItemStatusFlags_
	ImRect                  rect;               // Full rectangle
	ImRect                  navRect;            // Navigation scoring rectangle (not displayed)
	ImRect                  displayRect;        // Display rectangle (only if ImGuiItemStatusFlags_HasDisplayRect is set)
	
	ImGuiLastItemData()     { memset(this, 0, sizeof(*this)); }
}

// Store data emitted by TreeNode() for usage by TreePop() to implement ImGuiTreeNodeFlags_NavLeftJumpsBackHere.
// This is the minimum amount of data that we need to perform the equivalent of NavApplyItemToResult() and which we can't infer in TreePop()
// Only stored when the node is a potential candidate for landing on a Left arrow jump.
extern(C++) struct ImGuiNavTreeNodeData{
	ImGuiID                 ID;
	ImGuiItemFlags          InFlags;
	ImRect                  NavRect;
}

extern(C++) struct IMGUI_API ImGuiStackSizes{
	short   SizeOfIDStack;
	short   SizeOfColorStack;
	short   SizeOfStyleVarStack;
	short   SizeOfFontStack;
	short   SizeOfFocusScopeStack;
	short   SizeOfGroupStack;
	short   SizeOfItemFlagsStack;
	short   SizeOfBeginPopupStack;
	short   SizeOfDisabledStack;
	
	nothrow @nogc:
	ImGuiStackSizes() { memset(this, 0, sizeof(*this)); }
	void SetToContextState(ImGuiContext* ctx);
	void CompareWithContextState(ImGuiContext* ctx);
}

// Data saved for each window pushed into the stack
extern(C++) struct ImGuiWindowStackData{
	ImGuiWindow*        Window;
	ImGuiLastItemData   ParentLastItemDataBackup;
	ImGuiStackSizes     StackSizesOnBegin;      // Store size of various stacks for asserting
}

extern(C++) struct ImGuiShrinkWidthItem{
	int         Index;
	float       Width;
	float       InitialWidth;
}

extern(C++) struct ImGuiPtrOrIndex{
	void*       Ptr;            // Either field can be set, not both. e.g. Dock node tab bars are loose while BeginTabBar() ones are in a pool.
	int         Index;          // Usually index in a main pool.
	
	nothrow @nogc:
	ImGuiPtrOrIndex(void* ptr)  { Ptr = ptr; Index = -1; }
	ImGuiPtrOrIndex(int index)  { Ptr = NULL; Index = index; }
}

//-----------------------------------------------------------------------------
// [SECTION] Inputs support
//-----------------------------------------------------------------------------

// Bit array for named keys
typedef ImBitArray<ImGuiKey_NamedKey_COUNT, -ImGuiKey_NamedKey_BEGIN>    ImBitArrayForNamedKeys;

// [Internal] Key ranges
#define ImGuiKey_LegacyNativeKey_BEGIN  0
#define ImGuiKey_LegacyNativeKey_END    512
#define ImGuiKey_Keyboard_BEGIN         (ImGuiKey.namedKey_BEGIN)
#define ImGuiKey_Keyboard_END           (ImGuiKey.gamepadStart)
#define ImGuiKey_Gamepad_BEGIN          (ImGuiKey.gamepadStart)
#define ImGuiKey_Gamepad_END            (ImGuiKey.gamepadRStickDown + 1)
#define ImGuiKey_Mouse_BEGIN            (ImGuiKey.mouseLeft)
#define ImGuiKey_Mouse_END              (ImGuiKey.mouseWheelY + 1)
#define ImGuiKey_Aliases_BEGIN          (ImGuiKey.mouse_BEGIN)
#define ImGuiKey_Aliases_END            (ImGuiKey.mouse_END)

// [Internal] Named shortcuts for Navigation
#define ImGuiKey_NavKeyboardTweakSlow   ImGuiMod_Ctrl
#define ImGuiKey_NavKeyboardTweakFast   ImGuiMod_Shift
#define ImGuiKey_NavGamepadTweakSlow    ImGuiKey_GamepadL1
#define ImGuiKey_NavGamepadTweakFast    ImGuiKey_GamepadR1
#define ImGuiKey_NavGamepadActivate     ImGuiKey_GamepadFaceDown
#define ImGuiKey_NavGamepadCancel       ImGuiKey_GamepadFaceRight
#define ImGuiKey_NavGamepadMenu         ImGuiKey_GamepadFaceLeft
#define ImGuiKey_NavGamepadInput        ImGuiKey_GamepadFaceUp

enum ImGuiInputEventType{
	none = 0,
	mousePos,
	mouseWheel,
	mouseButton,
	mouseViewport,
	key,
	text,
	focus,
	COUNT,
}

enum ImGuiInputSource{
	none = 0,
	mouse,         // Note: may be Mouse or TouchScreen or Pen. See io.MouseSource to distinguish them.
	keyboard,
	gamepad,
	clipboard,     // Currently only used by InputText()
	COUNT,
};

// FIXME: Structures in the union below need to be declared as anonymous unions appears to be an extension?
// Using ImVec2() would fail on Clang 'union member 'MousePos' has a non-trivial default constructor'
extern(C++) struct ImGuiInputEventMousePos{ float posX, posY; ImGuiMouseSource_ mouseSource; }
extern(C++) struct ImGuiInputEventMouseWheel{ float wheelX, wheelY; ImGuiMouseSource_ mouseSource; }
extern(C++) struct ImGuiInputEventMouseButton{ int button; bool down; ImGuiMouseSource_ mouseSource; }
extern(C++) struct ImGuiInputEventMouseViewport{ ImGuiID hoveredViewportID; }
extern(C++) struct ImGuiInputEventKey{ ImGuiKey key; bool down; float analogValue; }
extern(C++) struct ImGuiInputEventText{ uint char_; }
extern(C++) struct ImGuiInputEventAppFocused{ bool focused; }

extern(C++) struct ImGuiInputEvent{
	ImGuiInputEventType type = ImGuiInputEventType.none;
	ImGuiInputSource source = ImGuiInputSource.none;
	uint eventID;        // Unique, sequential increasing integer to identify an event (if you need to correlate them to other data).
	extern(C++) union{
		ImGuiInputEventMousePos mousePos = ImGuiInputEventMousePos(0f, 0f, 0);       // if Type == ImGuiInputEventType_MousePos
		ImGuiInputEventMouseWheel mouseWheel;     // if Type == ImGuiInputEventType_MouseWheel
		ImGuiInputEventMouseButton mouseButton;    // if Type == ImGuiInputEventType_MouseButton
		ImGuiInputEventMouseViewport mouseViewport; // if Type == ImGuiInputEventType_MouseViewport
		ImGuiInputEventKey key;            // if Type == ImGuiInputEventType_Key
		ImGuiInputEventText text;           // if Type == ImGuiInputEventType_Text
		ImGuiInputEventAppFocused appFocused;     // if Type == ImGuiInputEventType_Focus
	}
	bool addedByTestEngine = false;
	
	ImGuiInputEvent() { memset(this, 0, sizeof(*this)); }
}

// Input function taking an 'ImGuiID owner_id' argument defaults to (ImGuiKeyOwner_Any == 0) aka don't test ownership, which matches legacy behavior.
enum ImGuiKeyOwner: ImGuiID{
	any   = 0,    // Accept key that have an owner, UNLESS a call to SetKeyOwner() explicitly used ImGuiInputFlags_LockThisFrame or ImGuiInputFlags_LockUntilRelease.
	none  = -1,   // Require key to have no owner.
}

alias ImGuiKeyRoutingIndex = short;

// Routing table entry (sizeof() == 16 bytes)
extern(C++) struct ImGuiKeyRoutingData{
	ImGuiKeyRoutingIndex nextEntryIndex = -1;
	ushort mods = 0;               // Technically we'd only need 4-bits but for simplify we store ImGuiMod_ values which need 16-bits. ImGuiMod_Shortcut is already translated to Ctrl/Super.
	ubyte routingNextScore = 255;   // Lower is better (0: perfect score)
	ImGuiID routingCurr = ImGuiKeyOwner.none;
	ImGuiID routingNext = ImGuiKeyOwner.none;
}

// Routing table: maintain a desired owner for each possible key-chord (key + mods), and setup owner in NewFrame() when mods are matching.
// Stored in main context (1 instance)
extern(C++) struct ImGuiKeyRoutingTable{
	ImGuiKeyRoutingIndex[ImGuiKey.NamedKey_COUNT] index; // Index of first entry in Entries[]
	ImVector!ImGuiKeyRoutingData entries;
	ImVector!ImGuiKeyRoutingData entriesNext;                    // Double-buffer to avoid reallocation (could use a shared buffer)
	
	nothrow @nogc:
	this(){ clear(); }
	void clear(){
		for(int n = 0; n < index.length; n++)
			index[n] = -1; entries.clear();
		entriesNext.clear();
	}
}

// This extends ImGuiKeyData but only for named keys (legacy keys don't support the new features)
// Stored in main context (1 per named key). In the future it might be merged into ImGuiKeyData.
extern(C++) struct ImGuiKeyOwnerData{
	ImGuiID ownerCurr = ImGuiKeyOwner.none;
	ImGuiID ownerNext = ImGuiKeyOwner.none;
	bool lockThisFrame = false;      // Reading this key requires explicit owner id (until end of frame). Set by ImGuiInputFlags_LockThisFrame.
	bool lockUntilRelease = false;   // Reading this key requires explicit owner id (until key is released). Set by ImGuiInputFlags_LockUntilRelease. When this is true LockThisFrame is always true as well.
}

// Flags for extended versions of IsKeyPressed(), IsMouseClicked(), Shortcut(), SetKeyOwner(), SetItemKeyOwner()
// Don't mistake with ImGuiInputTextFlags!(for ImGui::InputText() function)
alias ImGuiInputFlags_ = int;
enum ImGuiInputFlags: ImGuiInputFlags_{
	none                  = 0,
	repeat                = 1 << 0,   // Return true on successive repeats. Default for legacy IsKeyPressed(). NOT Default for legacy IsMouseClicked(). MUST BE == 1.
	repeatRateDefault     = 1 << 1,   // Repeat rate: Regular (default)
	repeatRateNavMove     = 1 << 2,   // Repeat rate: Fast
	repeatRateNavTweak    = 1 << 3,   // Repeat rate: Faster
	repeatRateMask_       = repeatRateDefault | repeatRateNavMove | repeatRateNavTweak,
	
	condHovered           = 1 << 4,   // Only set if item is hovered (default to both)
	condActive            = 1 << 5,   // Only set if item is active (default to both)
	condDefault_          = condHovered | condActive,
	condMask_             = condHovered | condActive,
	
	lockThisFrame         = 1 << 6,   // Access to key data will require EXPLICIT owner ID (ImGuiKeyOwner_Any/0 will NOT accepted for polling). Cleared at end of frame. This is useful to make input-owner-aware code steal keys from non-input-owner-aware code.
	lockUntilRelease      = 1 << 7,   // Access to key data will require EXPLICIT owner ID (ImGuiKeyOwner_Any/0 will NOT accepted for polling). Cleared when the key is released or at end of each frame if key is released. This is useful to make input-owner-aware code steal keys from non-input-owner-aware code.
	
	routeFocused          = 1 << 8,   // (Default) Register focused route: Accept inputs if window is in focus stack. Deep-most focused window takes inputs. ActiveId takes inputs over deep-most focused window.
	routeGlobalLow        = 1 << 9,   // Register route globally (lowest priority: unless a focused window or active item registered the route) -> recommended Global priority.
	routeGlobal           = 1 << 10,  // Register route globally (medium priority: unless an active item registered the route, e.g. CTRL+A registered by InputText).
	routeGlobalHigh       = 1 << 11,  // Register route globally (highest priority: unlikely you need to use that: will interfere with every active items)
	routeMask_            = routeFocused | routeGlobal | routeGlobalLow | routeGlobalHigh, // _Always not part of this!
	routeAlways           = 1 << 12,  // Do not register route, poll keys directly.
	routeUnlessBgFocused  = 1 << 13,  // Global routes will not be applied if underlying background/void is focused (== no Dear ImGui windows are focused). Useful for overlay applications.
	routeExtraMask_       = routeAlways | routeUnlessBgFocused,
	
	supportedByIsKeyPressed     = repeat | repeatRateMask_,
	supportedByShortcut         = repeat | repeatRateMask_ | routeMask_ | routeExtraMask_,
	supportedBySetKeyOwner      = lockThisFrame | lockUntilRelease,
	supportedBySetItemKeyOwner  = supportedBySetKeyOwner | condMask_,
};

//-----------------------------------------------------------------------------
// [SECTION] Clipper support
//-----------------------------------------------------------------------------

// Note that Max is exclusive, so perhaps should be using a Begin/End convention.
extern(C++) struct ImGuiListClipperRange{
	int min;
	int max;
	bool posToIndexConvert;      // Begin/End are absolute position (will be converted to indices later)
	byte posToIndexOffsetMin;    // Add to Min after converting to indices
	byte posToIndexOffsetMax;    // Add to Min after converting to indices
	
	nothrow @nogc:
	static fromIndices(int min, int max) pure @safe =>
		ImGuiListClipperRange(min, max, false, 0, 0);
	static fromPositions(float y1, float y2, int offMin, int offMax) pure @safe =>
		ImGuiListClipperRange(cast(int)y1, cast(int)y2, true, cast(byte)offMin, cast(byte)offMax);
};

// Temporary clipper data, buffers shared/reused between instances
extern(C++) struct ImGuiListClipperData{
	ImGuiListClipper* listClipper = null;
	float lossynessOffset = 0f;
	int stepNo = 0;
	int itemsFrozen = 0;
	ImVector!ImGuiListClipperRange ranges;
	
	nothrow @nogc:
	void reset(ImGuiListClipper* clipper) pure{
		listClipper = clipper;
		stepNo = itemsFrozen = 0;
		ranges.resize(0);
	}
};

//-----------------------------------------------------------------------------
// [SECTION] Navigation support
//-----------------------------------------------------------------------------

alias ImGuiActivateFlags_ = int;
enum ImGuiActivateFlags: ImGuiActivateFlags_{
	none                = 0,
	preferInput         = 1 << 0,       // Favor activation that requires keyboard text input (e.g. for Slider/Drag). Default for Enter key.
	preferTweak         = 1 << 1,       // Favor activation for tweaking with arrows or gamepad (e.g. for Slider/Drag). Default for Space key and if keyboard is not used.
	tryToPreserveState  = 1 << 2,       // Request widget to preserve state if it can (e.g. InputText will try to preserve cursor/selection)
}

alias ImGuiScrollFlags_ = int;
enum ImGuiScrollFlags: ImGuiScrollFlags_{
	none = 0,
	keepVisibleEdgeX = 1 << 0,       // If item is not visible: scroll as little as possible on X axis to bring item back into view [default for X axis]
	keepVisibleEdgeY = 1 << 1,       // If item is not visible: scroll as little as possible on Y axis to bring item back into view [default for Y axis for windows that are already visible]
	keepVisibleCenterX = 1 << 2,       // If item is not visible: scroll to make the item centered on X axis [rarely used]
	keepVisibleCentreX = keepVisibleCenterX,
	keepVisibleCenterY = 1 << 3,       // If item is not visible: scroll to make the item centered on Y axis
	keepVisibleCentreY = keepVisibleCenterY,
	alwaysCenterX = 1 << 4,       // Always center the result item on X axis [rarely used]
	alwaysCentreX = alwaysCenterX,
	alwaysCenterY = 1 << 5,       // Always center the result item on Y axis [default for Y axis for appearing window)
	alwaysCentreY = alwaysCenterY,
	noScrollParent = 1 << 6,       // Disable forwarding scrolling to parent window if required to keep item/rect visible (only scroll window the function was applied to).
	maskX_ = keepVisibleEdgeX | keepVisibleCenterX | alwaysCenterX,
	maskY_ = keepVisibleEdgeY | keepVisibleCenterY | alwaysCenterY,
};

alias ImGuiNavHighlightFlags_ = int;
enum ImGuiNavHighlightFlags: ImGuiNavHighlightFlags_{
	none             = 0,
	typeDefault      = 1 << 0,
	typeThin         = 1 << 1,
	alwaysDraw       = 1 << 2,       // Draw rectangular highlight if (g.NavId == id) _even_ when using the mouse.
	noRounding       = 1 << 3,
}

alias ImGuiNavMoveFlags_= int;
enum ImGuiNavMoveFlags: ImGuiNavMoveFlags_{
	none                  = 0,
	loopX                 = 1 << 0,   // On failed request, restart from opposite side
	loopY                 = 1 << 1,
	wrapX                 = 1 << 2,   // On failed request, request from opposite side one line down (when NavDir==right) or one line up (when NavDir==left)
	wrapY                 = 1 << 3,   // This is not super useful but provided for completeness
	wrapMask_             = loopX | loopY | wrapX | wrapY,
	allowCurrentNavId     = 1 << 4,   // Allow scoring and considering the current NavId as a move target candidate. This is used when the move source is offset (e.g. pressing PageDown actually needs to send a Up move request, if we are pressing PageDown from the bottom-most item we need to stay in place)
	alsoScoreVisibleSet   = 1 << 5,   // Store alternate result in NavMoveResultLocalVisible that only comprise elements that are already fully visible (used by PageUp/PageDown)
	scrollToEdgeY         = 1 << 6,   // Force scrolling to min/max (used by Home/End) // FIXME-NAV: Aim to remove or reword, probably unnecessary
	forwarded             = 1 << 7,
	debugNoResult         = 1 << 8,   // Dummy scoring for debug purpose, don't apply result
	focusApi              = 1 << 9,   // Requests from focus API can land/focus/activate items even if they are marked with _NoTabStop (see NavProcessItemForTabbingRequest() for details)
	isTabbing             = 1 << 10,  // == Focus + Activate if item is Inputable + DontChangeNavHighlight
	isPageMove            = 1 << 11,  // Identify a PageDown/PageUp request.
	activate              = 1 << 12,  // Activate/select target item.
	noSelect              = 1 << 13,  // Don't trigger selection by not setting g.NavJustMovedTo
	noSetNavHighlight     = 1 << 14,  // Do not alter the visible state of keyboard vs mouse nav highlight
}

enum ImGuiNavLayer{
	main  = 0,    // Main scrolling layer
	menu  = 1,    // Menu layer (access with Alt)
	COUNT,
}

extern(C++) struct ImGuiNavItemData{
	ImGuiWindow* window;         // Init,Move    // Best candidate window (result->ItemWindow->RootWindowForNav == request->Window)
	ImGuiID id;             // Init,Move    // Best candidate item ID
	ImGuiID focusScopeID;   // Init,Move    // Best candidate focus scope ID
	ImRect rectRel;        // Init,Move    // Best candidate bounding box in window relative space
	ImGuiItemFlags inFlags;        // ????,Move    // Best candidate item flags
	ImGuiSelectionUserData selectionUserData;//I+Mov    // Best candidate SetNextItemSelectionData() value.
	float distBox;        //      Move    // Best candidate box distance to current NavId
	float distCenter;     //      Move    // Best candidate center distance to current NavId
	alias distCentre = distCenter
	float distAxial;      //      Move    // Best candidate axial distance to current NavId
	
	nothrow @nogc:
	this() pure @safe{ clear(); }
	void clear() pure @safe{
		window = null;
		id = focusScopeID = 0;
		inFlags = 0;
		selectionUserData = -1;
		distBox = distCenter = distAxial = float.max;
	}
}

//-----------------------------------------------------------------------------
// [SECTION] Typing-select support
//-----------------------------------------------------------------------------

// Flags for GetTypingSelectRequest()
alias ImGuiTypingSelectFlags_ = int;
enum ImGuiTypingSelectFlags: ImGuiTypingSelectFlags_{
	none                 = 0,
	allowBackspace       = 1 << 0,   // Backspace to delete character inputs. If using: ensure GetTypingSelectRequest() is not called more than once per frame (filter by e.g. focus state)
	allowSingleCharMode  = 1 << 1,   // Allow "single char" search mode which is activated when pressing the same character multiple times.
};

// Returned by GetTypingSelectRequest(), designed to eventually be public.
extern(C++) struct IMGUI_API ImGuiTypingSelectRequest{
	ImGuiTypingSelectFlags flags;              // Flags passed to GetTypingSelectRequest()
	int searchBufferLen;
	const(char)* searchBuffer;       // Search buffer contents (use full string. unless SingleCharMode is set, in which case use SingleCharSize).
	bool selectRequest;      // Set when buffer was modified this frame, requesting a selection.
	bool singleCharMode;     // Notify when buffer contains same character repeated, to implement special mode. In this situation it preferred to not display any on-screen search indication.
	byte singleCharSize;     // Length in bytes of first letter codepoint (1 for ascii, 2-4 for UTF-8). If (SearchBufferLen==RepeatCharSize) only 1 letter has been input.
}

// Storage for GetTypingSelectRequest()
extern(C++) struct IMGUI_API ImGuiTypingSelectState{
	ImGuiTypingSelectRequest request;           // User-facing data
	char[64] searchBuffer;           // Search buffer: no need to make dynamic as this search is very transient.
	ImGuiID focusScope = 0;
	int lastRequestFrame = 0;
	float lastRequestTime = 0f;
	bool singleCharModeLock = false; // After a certain single char repeat count we lock into SingleCharMode. Two benefits: 1) buffer never fill, 2) we can provide an immediate SingleChar mode without timer elapsing.
	
	nothrow @nogc:
	void clear() pure @safe{ searchBuffer[0] = 0; singleCharModeLock = false; } // We preserve remaining data for easier debugging
}

//-----------------------------------------------------------------------------
// [SECTION] Columns support
//-----------------------------------------------------------------------------

alias ImGuiOldColumnFlags_ = int;
enum ImGuiOldColumnFlags: ImGuiOldColumnFlags_{
	none                    = 0,
	noBorder                = 1 << 0,   // Disable column dividers
	noResize                = 1 << 1,   // Disable resizing columns when clicking on the dividers
	noPreserveWidths        = 1 << 2,   // Disable column width preservation when adjusting columns
	noForceWithinWindow     = 1 << 3,   // Disable forcing columns to fit within window
	growParentContentsSize  = 1 << 4,   // (WIP) Restore pre-1.51 behavior of extending the parent window contents size but _without affecting the columns width at all_. Will eventually remove.
}

extern(C++) struct ImGuiOldColumnData{
	float offsetNorm;             // Column start offset, normalized 0.0 (far left) -> 1.0 (far right)
	float offsetNormBeforeResize;
	ImGuiOldColumnFlags flags;                  // Not exposed
	ImRect clipRect;
	
	ImGuiOldColumnData() { memset(this, 0, sizeof(*this)); }
}

extern(C++) struct ImGuiOldColumns{
	ImGuiID id;
	ImGuiOldColumnFlags flags;
	bool isFirstFrame;
	bool isBeingResized;
	int current;
	int count;
	float offMinX, offMaxX;       // Offsets from HostWorkRect.Min.x
	float lineMinY, lineMaxY;
	float hostCursorPosY;         // Backup of CursorPos at the time of BeginColumns()
	float hostCursorMaxPosX;      // Backup of CursorMaxPos at the time of BeginColumns()
	ImRect hostInitialClipRect;    // Backup of ClipRect at the time of BeginColumns()
	ImRect hostBackupClipRect;     // Backup of ClipRect during PushColumnsBackground()/PopColumnsBackground()
	ImRect hostBackupParentWorkRect;//Backup of WorkRect at the time of BeginColumns()
	ImVector!ImGuiOldColumnData columns;
	ImDrawListSplitter splitter;
	
	ImGuiOldColumns()   { memset(this, 0, sizeof(*this)); }
}

//-----------------------------------------------------------------------------
// [SECTION] Multi-select support
//-----------------------------------------------------------------------------

// We always assume that -1 is an invalid value (which works for indices and pointers)
enum ImGuiSelectionUserData ImGuiSelectionUserDataInvalid = -1;

enum{
	DOCKING_HOST_DRAW_CHANNEL_BG = 0,
	DOCKING_HOST_DRAW_CHANNEL_FG = 1,
}

enum ImGuiDockNodeFlagsPrivate: ImGuiDockNodeFlags{
	dockSpace                = 1 << 10,  // Saved // A dockspace is a node that occupy space within an existing user window. Otherwise the node is floating and create its own window.
	centralNode              = 1 << 11,  // Saved // The central node has 2 main properties: stay visible when empty, only use "remaining" spaces from its neighbor.
	noTabBar                 = 1 << 12,  // Saved // Tab bar is completely unavailable. No triangle in the corner to enable it back.
	hiddenTabBar             = 1 << 13,  // Saved // Tab bar is hidden, with a triangle in the corner to show it again (NB: actual tab-bar instance may be destroyed as this is only used for single-window tab bar)
	noWindowMenuButton       = 1 << 14,  // Saved // Disable window/docking menu (that one that appears instead of the collapse button)
	noCloseButton            = 1 << 15,  // Saved // Disable close button
	noResizeX                = 1 << 16,  //       //
	noResizeY                = 1 << 17,  //       //
	
	noDockingSplitOther      = 1 << 19,  //       // Disable this node from splitting other windows/nodes.
	noDockingOverMe          = 1 << 20,  //       // Disable other windows/nodes from being docked over this node.
	noDockingOverOther       = 1 << 21,  //       // Disable this node from being docked over another window or non-empty node.
	noDockingOverEmpty       = 1 << 22,  //       // Disable this node from being docked over an empty node (e.g. DockSpace with no other windows)
	noDocking                = ImGuiDockNodeFlags_NoDockingOverMe | ImGuiDockNodeFlags_NoDockingOverOther | ImGuiDockNodeFlags_NoDockingOverEmpty | ImGuiDockNodeFlags_NoDockingSplit | ImGuiDockNodeFlags_NoDockingSplitOther,
	
	sharedFlagsInheritMask_  = ~0,
	noResizeFlagsMask_       = ImGuiDockNodeFlags_NoResize | ImGuiDockNodeFlags_NoResizeX | ImGuiDockNodeFlags_NoResizeY,
	
	localFlagsTransferMask_  = ImGuiDockNodeFlags_NoDockingSplit | ImGuiDockNodeFlags_NoResizeFlagsMask_ | ImGuiDockNodeFlags_AutoHideTabBar | ImGuiDockNodeFlags_CentralNode | ImGuiDockNodeFlags_NoTabBar | ImGuiDockNodeFlags_HiddenTabBar | ImGuiDockNodeFlags_NoWindowMenuButton | ImGuiDockNodeFlags_NoCloseButton,
	savedFlagsMask_          = ImGuiDockNodeFlags_NoResizeFlagsMask_ | ImGuiDockNodeFlags_DockSpace | ImGuiDockNodeFlags_CentralNode | ImGuiDockNodeFlags_NoTabBar | ImGuiDockNodeFlags_HiddenTabBar | ImGuiDockNodeFlags_NoWindowMenuButton | ImGuiDockNodeFlags_NoCloseButton,
}

// Store the source authority (dock node vs window) of a field
alias ImGuiDataAuthority_ = int;
enum ImGuiDataAuthority: ImGuiDataAuthority_{
	auto,
	dockNode,
	window,
}

enum ImGuiDockNodeState{
	unknown,
	hostWindowHiddenBecauseSingleWindow,
	hostWindowHiddenBecauseWindowsAreResizing,
	hostWindowVisible,
}

// sizeof() 156~192
extern(C++) struct IMGUI_API ImGuiDockNode{
	ImGuiID id;
	ImGuiDockNodeFlags sharedFlags;                // (Write) Flags shared by all nodes of a same dockspace hierarchy (inherited from the root node)
	ImGuiDockNodeFlags localFlags;                 // (Write) Flags specific to this node
	ImGuiDockNodeFlags localFlagsInWindows;        // (Write) Flags specific to this node, applied from windows
	ImGuiDockNodeFlags mergedFlags;                // (Read)  Effective flags (== SharedFlags | LocalFlagsInNode | LocalFlagsInWindows)
	ImGuiDockNodeState state;
	ImGuiDockNode* parentNode;
	ImGuiDockNode*[2] childNodes;              // [Split node only] Child nodes (left/right or top/bottom). Consider switching to an array.
	ImVector!(ImGuiWindow*) windows;                    // Note: unordered list! Iterate TabBar->Tabs for user-order.
	ImGuiTabBar* tabBar;
	ImVec2 pos;                        // Current position
	ImVec2 size;                       // Current size
	ImVec2 sizeRef;                    // [Split node only] Last explicitly written-to size (overridden when using a splitter affecting the node), used to calculate Size.
	ImGuiAxis splitAxis;                  // [Split node only] Split axis (X or Y)
	ImGuiWindowClass windowClass;                // [Root node only]
	uint lastBgColor;
	alias lastBgColour = lastBgColor;

	ImGuiWindow* hostWindow;
	ImGuiWindow* visibleWindow;              // Generally point to window which is ID is == SelectedTabID, but when CTRL+Tabbing this can be a different window.
	ImGuiDockNode* centralNode;                // [Root node only] Pointer to central node.
	ImGuiDockNode* onlyNodeWithWindows;        // [Root node only] Set when there is a single visible node within the hierarchy.
	int countNodeWithWindows;       // [Root node only]
	int lastFrameAlive;             // Last frame number the node was updated or kept alive explicitly with DockSpace() + ImGuiDockNodeFlags_KeepAliveOnly
	int lastFrameActive;            // Last frame number the node was updated.
	int lastFrameFocused;           // Last frame number the node was focused.
	ImGuiID lastFocusedNodeID;          // [Root node only] Which of our child docking node (any ancestor in the hierarchy) was last focused.
	ImGuiID selectedTabID;              // [Leaf node only] Which of our tab/window is selected.
	ImGuiID wantCloseTabID;             // [Leaf node only] Set when closing a specific tab/window.
	ImGuiID refViewportID;              // Reference viewport ID from visible window when HostWindow == NULL.
	ImGuiDataAuthority authorityForPos         :3;
	ImGuiDataAuthority authorityForSize        :3;
	ImGuiDataAuthority authorityForViewport    :3;
	bool isVisible               :1; // Set to false when the node is hidden (usually disabled as it has no active window)
	bool isFocused               :1;
	bool isBgDrawnThisFrame      :1;
	bool hasCloseButton          :1; // Provide space for a close button (if any of the docked window has one). Note that button may be hidden on window without one.
	bool hasWindowMenuButton     :1;
	bool hasCentralNodeChild     :1;
	bool wantCloseAll            :1; // Set when closing all tabs at once.
	bool wantLockSizeOnce        :1;
	bool wantMouseMove           :1; // After a node extraction we need to transition toward moving the newly created host window
	bool wantHiddenTabBarUpdate  :1;
	bool wantHiddenTabBarToggle  :1;

	ImGuiDockNode(ImGuiID id);
	~ImGuiDockNode();
	bool                    IsRootNode() const      { return ParentNode == NULL; }
	bool                    IsDockSpace() const     { return (MergedFlags & ImGuiDockNodeFlags_DockSpace) != 0; }
	bool                    IsFloatingNode() const  { return ParentNode == NULL && (MergedFlags & ImGuiDockNodeFlags_DockSpace) == 0; }
	bool                    IsCentralNode() const   { return (MergedFlags & ImGuiDockNodeFlags_CentralNode) != 0; }
	bool                    IsHiddenTabBar() const  { return (MergedFlags & ImGuiDockNodeFlags_HiddenTabBar) != 0; } // Hidden tab bar can be shown back by clicking the small triangle
	bool                    IsNoTabBar() const      { return (MergedFlags & ImGuiDockNodeFlags_NoTabBar) != 0; }     // Never show a tab bar
	bool                    IsSplitNode() const     { return ChildNodes[0] != NULL; }
	bool                    IsLeafNode() const      { return ChildNodes[0] == NULL; }
	bool                    IsEmpty() const         { return ChildNodes[0] == NULL && Windows.Size == 0; }
	ImRect                  Rect() const            { return ImRect(Pos.x, Pos.y, Pos.x + Size.x, Pos.y + Size.y); }

	void                    SetLocalFlags(ImGuiDockNodeFlags flags) { LocalFlags = flags; UpdateMergedFlags(); }
	void                    UpdateMergedFlags()     { MergedFlags = SharedFlags | LocalFlags | LocalFlagsInWindows; }
};

// List of colors that are stored at the time of Begin() into Docked Windows.
// We currently store the packed colors in a simple array window->DockStyle.Colors[].
// A better solution may involve appending into a log of colors in ImGuiContext + store offsets into those arrays in ImGuiWindow,
// but it would be more complex as we'd need to double-buffer both as e.g. drop target may refer to window from last frame.
enum ImGuiWindowDockStyleCol{
	text,
	tab,
	tabHovered,
	tabActive,
	tabUnfocused,
	tabUnfocusedActive,
	COUNT
}

extern(C++) struct ImGuiWindowDockStyle{
	uint[ImGuiWindowDockStyleCol.COUNT] colors;
	alias colours = colors;
}

extern(C++) struct ImGuiDockContext{
	ImGuiStorage                    nodes;          // Map ID -> ImGuiDockNode*: Active nodes
	ImVector!ImGuiDockRequest       requests;
	ImVector!ImGuiDockNodeSettings  nodesSettings;
	bool                            wantFullRebuild;
	ImGuiDockContext()              { memset(this, 0, sizeof(*this)); }
};

#endif // #ifdef IMGUI_HAS_DOCK

//-----------------------------------------------------------------------------
// [SECTION] Viewport support
//-----------------------------------------------------------------------------

// ImGuiViewport Private/Internals fields (cardinal sin: we are using inheritance!)
// Every instance of ImGuiViewport is in fact a ImGuiViewportP.
struct ImGuiViewportP : public ImGuiViewport
{
	ImGuiWindow*        Window;                 // Set when the viewport is owned by a window (and ImGuiViewportFlags_CanHostOtherWindows is NOT set)
	int                 Idx;
	int                 LastFrameActive;        // Last frame number this viewport was activated by a window
	int                 LastFocusedStampCount;  // Last stamp number from when a window hosted by this viewport was focused (by comparing this value between two viewport we have an implicit viewport z-order we use as fallback)
	ImGuiID             LastNameHash;
	ImVec2              LastPos;
	float               Alpha;                  // Window opacity (when dragging dockable windows/viewports we make them transparent)
	float               LastAlpha;
	bool                LastFocusedHadNavWindow;// Instead of maintaining a LastFocusedWindow (which may harder to correctly maintain), we merely store weither NavWindow != NULL last time the viewport was focused.
	short               PlatformMonitor;
	int                 BgFgDrawListsLastFrame[2]; // Last frame number the background (0) and foreground (1) draw lists were used
	ImDrawList*         BgFgDrawLists[2];       // Convenience background (0) and foreground (1) draw lists. We use them to draw software mouser cursor when io.MouseDrawCursor is set and to draw most debug overlays.
	ImDrawData          DrawDataP;
	ImDrawDataBuilder   DrawDataBuilder;        // Temporary data while building final ImDrawData
	ImVec2              LastPlatformPos;
	ImVec2              LastPlatformSize;
	ImVec2              LastRendererSize;
	ImVec2              WorkOffsetMin;          // Work Area: Offset from Pos to top-left corner of Work Area. Generally (0,0) or (0,+main_menu_bar_height). Work Area is Full Area but without menu-bars/status-bars (so WorkArea always fit inside Pos/Size!)
	ImVec2              WorkOffsetMax;          // Work Area: Offset from Pos+Size to bottom-right corner of Work Area. Generally (0,0) or (0,-status_bar_height).
	ImVec2              BuildWorkOffsetMin;     // Work Area: Offset being built during current frame. Generally >= 0.0f.
	ImVec2              BuildWorkOffsetMax;     // Work Area: Offset being built during current frame. Generally <= 0.0f.

	ImGuiViewportP()                    { Window = NULL; Idx = -1; LastFrameActive = BgFgDrawListsLastFrame[0] = BgFgDrawListsLastFrame[1] = LastFocusedStampCount = -1; LastNameHash = 0; Alpha = LastAlpha = 1.0f; LastFocusedHadNavWindow = false; PlatformMonitor = -1; BgFgDrawLists[0] = BgFgDrawLists[1] = NULL; LastPlatformPos = LastPlatformSize = LastRendererSize = ImVec2(FLT_MAX, FLT_MAX); }
	~ImGuiViewportP()                   { if (BgFgDrawLists[0]) IM_DELETE(BgFgDrawLists[0]); if (BgFgDrawLists[1]) IM_DELETE(BgFgDrawLists[1]); }
	void    ClearRequestFlags()         { PlatformRequestClose = PlatformRequestMove = PlatformRequestResize = false; }

	// Calculate work rect pos/size given a set of offset (we have 1 pair of offset for rect locked from last frame data, and 1 pair for currently building rect)
	ImVec2  CalcWorkRectPos(const ImVec2& off_min) const                            { return ImVec2(Pos.x + off_min.x, Pos.y + off_min.y); }
	ImVec2  CalcWorkRectSize(const ImVec2& off_min, const ImVec2& off_max) const    { return ImVec2(ImMax(0.0f, Size.x - off_min.x + off_max.x), ImMax(0.0f, Size.y - off_min.y + off_max.y)); }
	void    UpdateWorkRect()            { WorkPos = CalcWorkRectPos(WorkOffsetMin); WorkSize = CalcWorkRectSize(WorkOffsetMin, WorkOffsetMax); } // Update public fields

	// Helpers to retrieve ImRect (we don't need to store BuildWorkRect as every access tend to change it, hence the code asymmetry)
	ImRect  GetMainRect() const         { return ImRect(Pos.x, Pos.y, Pos.x + Size.x, Pos.y + Size.y); }
	ImRect  GetWorkRect() const         { return ImRect(WorkPos.x, WorkPos.y, WorkPos.x + WorkSize.x, WorkPos.y + WorkSize.y); }
	ImRect  GetBuildWorkRect() const    { ImVec2 pos = CalcWorkRectPos(BuildWorkOffsetMin); ImVec2 size = CalcWorkRectSize(BuildWorkOffsetMin, BuildWorkOffsetMax); return ImRect(pos.x, pos.y, pos.x + size.x, pos.y + size.y); }
};

//-----------------------------------------------------------------------------
// [SECTION] Settings support
//-----------------------------------------------------------------------------

// Windows data saved in imgui.ini file
// Because we never destroy or rename ImGuiWindowSettings, we can store the names in a separate buffer easily.
// (this is designed to be stored in a ImChunkStream buffer, with the variable-length Name following our structure)
extern(C++) struct ImGuiWindowSettings{
	ImGuiID     id = 0;
	ImVec2ih    pos = ImVec2ih(0, 0);            // NB: Settings position are stored RELATIVE to the viewport! Whereas runtime ones are absolute positions.
	ImVec2ih    size = ImVec2ih(0, 0);
	ImVec2ih    viewportPos = ImVec2ih(0, 0);
	ImGuiID     viewportID = 0;
	ImGuiID     dockID = 0;         // ID of last known DockNode (even if the DockNode is invisible because it has only 1 active window), or 0 if none.
	ImGuiID     classID = 0;        // ID of window class if specified
	short       dockOrder = -1;      // Order of the last time the window was visible within its DockNode. This is used to reorder windows that are reappearing on the same frame. Same value between windows that were active and windows that were none are possible.
	bool        collapsed = false;
	bool        isChild = false;
	bool        wantApply = false;      // Set when loaded from .ini data (to enable merging/loading .ini data into an already running context)
	bool        wantDelete = false;     // Set to invalidate/delete the settings entry
	
	char* getName() => cast(char*)(&this + 1);
};

extern(C++) struct ImGuiSettingsHandler{
	const(char)* TypeName;       // Short description stored in .ini file. Disallowed characters: '[' ']'
	ImGuiID     TypeHash;       // == ImHashStr(TypeName)
	void        (*ClearAllFn)(ImGuiContext* ctx, ImGuiSettingsHandler* handler);                                // Clear all settings data
	void        (*ReadInitFn)(ImGuiContext* ctx, ImGuiSettingsHandler* handler);                                // Read: Called before reading (in registration order)
	void*       (*ReadOpenFn)(ImGuiContext* ctx, ImGuiSettingsHandler* handler, const(char)* name);              // Read: Called when entering into a new ini entry e.g. "[Window][Name]"
	void        (*ReadLineFn)(ImGuiContext* ctx, ImGuiSettingsHandler* handler, void* entry, const(char)* line); // Read: Called for every line of text within an ini entry
	void        (*ApplyAllFn)(ImGuiContext* ctx, ImGuiSettingsHandler* handler);                                // Read: Called after reading (in registration order)
	void        (*WriteAllFn)(ImGuiContext* ctx, ImGuiSettingsHandler* handler, ImGuiTextBuffer* out_buf);      // Write: Output every entries into 'out_buf'
	void*       UserData;

	ImGuiSettingsHandler() { memset(this, 0, sizeof(*this)); }
};

//-----------------------------------------------------------------------------
// [SECTION] Localization support
//-----------------------------------------------------------------------------

// This is experimental and not officially supported, it'll probably fall short of features, if/when it does we may backtrack.
enum ImGuiLocKey: int{
	versionStr,
	tableSizeOne,
	tableSizeAllFit,
	tableSizeAllDefault,
	tableResetOrder,
	windowingMainMenuBar,
	windowingPopup,
	windowingUntitled,
	dockingHideTabBar,
	dockingHoldShiftToDock,
	dockingDragToUndockOrMoveNode,
	COUNT
}

struct ImGuiLocEntry{
	ImGuiLocKey key;
	const(char)* text;
}

//-----------------------------------------------------------------------------
// [SECTION] Metrics, Debug Tools
//-----------------------------------------------------------------------------

alias ImGuiDebugLogFlags_ = int;
enum ImGuiDebugLogFlags: ImGuiDebugLogFlags_{
	none             = 0,
	eventActiveID    = 1 << 0,
	eventFocus       = 1 << 1,
	eventPopup       = 1 << 2,
	eventNav         = 1 << 3,
	eventClipper     = 1 << 4,
	eventSelection   = 1 << 5,
	eventIO          = 1 << 6,
	eventDocking     = 1 << 7,
	eventViewport    = 1 << 8,
	eventMask_       = eventActiveID | eventFocus | eventPopup | eventNav | eventClipper | eventSelection | eventIO | eventDocking | eventViewport,
	outputToTTY      = 1 << 10,
	outputToTestEngine = 1 << 11,
};

struct ImGuiDebugAllocEntry{
	int         frameCount;
	short       allocCount;
	short       freeCount;
};

struct ImGuiDebugAllocInfo{
	int totalAllocCount;
	int totalFreeCount;
	short lastEntriesIdx;
	ImGuiDebugAllocEntry[6] lastEntriesBuf;
	
	imGuiDebugAllocInfo(){ memset(this, 0, sizeof(*this)); }
}

struct ImGuiMetricsConfig{
	bool ShowDebugLog = false;
	bool ShowIDStackTool = false;
	bool ShowWindowsRects = false;
	bool ShowWindowsBeginOrder = false;
	bool ShowTablesRects = false;
	bool ShowDrawCmdMesh = true;
	bool ShowDrawCmdBoundingBoxes = true;
	bool ShowAtlasTintedWithTextColor = false;
	bool ShowDockingNodes = false;
	int ShowWindowsRectsType = -1;
	int ShowTablesRectsType = -1;
}

struct ImGuiStackLevelInfo
{
	ImGuiID                 ID;
	byte                    QueryFrameCount;            // >= 1: Query in progress
	bool                    QuerySuccess;               // Obtained result from DebugHookIdInfo()
	ImGuiDataType           DataType : 8;
	char                    Desc[57];                   // Arbitrarily sized buffer to hold a result (FIXME: could replace Results[] with a chunk stream?) FIXME: Now that we added CTRL+C this should be fixed.

	ImGuiStackLevelInfo()   { memset(this, 0, sizeof(*this)); }
};

// State for ID Stack tool queries
struct ImGuiIDStackTool
{
	int                     LastActiveFrame;
	int                     StackLevel;                 // -1: query stack and resize Results, >= 0: individual stack level
	ImGuiID                 QueryId;                    // ID to query details for
	ImVector<ImGuiStackLevelInfo> Results;
	bool                    CopyToClipboardOnCtrlC;
	float                   CopyToClipboardLastTime;

	ImGuiIDStackTool()      { memset(this, 0, sizeof(*this)); CopyToClipboardLastTime = -FLT_MAX; }
};

//-----------------------------------------------------------------------------
// [SECTION] Generic context hooks
//-----------------------------------------------------------------------------

typedef void (*ImGuiContextHookCallback)(ImGuiContext* ctx, ImGuiContextHook* hook);
enum ImGuiContextHookType { ImGuiContextHookType_NewFramePre, ImGuiContextHookType_NewFramePost, ImGuiContextHookType_EndFramePre, ImGuiContextHookType_EndFramePost, ImGuiContextHookType_RenderPre, ImGuiContextHookType_RenderPost, ImGuiContextHookType_Shutdown, ImGuiContextHookType_PendingRemoval_ };

struct ImGuiContextHook
{
	ImGuiID                     HookID;     // A unique ID assigned by AddContextHook()
	ImGuiContextHookType        Type;
	ImGuiID                     Owner;
	ImGuiContextHookCallback    Callback;
	void*                       UserData;

	ImGuiContextHook()          { memset(this, 0, sizeof(*this)); }
};

//-----------------------------------------------------------------------------
// [SECTION] ImGuiContext (main Dear ImGui context)
//-----------------------------------------------------------------------------

extern(C++) struct ImGuiContext{
	bool initialized = false;
	alias initialised = initialized;
	bool fontAtlasOwnedByContext;            // IO.Fonts-> is owned by the ImGuiContext and will be destructed along with it.
	ImGuiIO io;
	ImGuiPlatformIO platformIO;
	ImGuiStyle style;
	ImGuiConfigFlags configFlagsCurrFrame = ImGuiConfigFlags.none;               // = g.IO.ConfigFlags at the time of NewFrame()
	ImGuiConfigFlags configFlagsLastFrame = ImGuiConfigFlags.none;
	ImFont* font = null;                               // (Shortcut) == FontStack.empty() ? IO.Font : FontStack.back()
	float fontSize = 0f;                           // (Shortcut) == FontBaseSize * g.CurrentWindow->FontWindowScale == window->FontSize(). Text height for current window.
	float fontBaseSize = 0f;                       // (Shortcut) == IO.FontGlobalScale * Font->Scale * Font->FontSize. Base text height.
	ImDrawListSharedData drawListSharedData;
	double time = 0f;
	int frameCount = 0;
	int frameCountEnded = -1;
	int frameCountPlatformEnded = -1;
	int frameCountRendered = -1;
	bool withinFrameScope = false;                   // Set by NewFrame(), cleared by EndFrame()
	bool withinFrameScopeWithImplicitWindow = false; // Set by NewFrame(), cleared by EndFrame() when the implicit debug window has been pushed
	bool withinEndChild = false;                     // Set within EndChild()
	bool gcCompactAll = false;                       // Request full GC
	bool testEngineHookItems = false;                // Will call test engine hooks: ImGuiTestEngineHook_ItemAdd(), ImGuiTestEngineHook_ItemInfo(), ImGuiTestEngineHook_Log()
	void* testEngine = null;                         // Test engine user data
	
	ImVector!ImGuiInputEvent inputEventsQueue;                 // Input events which will be trickled/written into IO structure.
	ImVector!ImGuiInputEvent inputEventsTrail;                 // Past input events processed in NewFrame(). This is to allow domain-specific application to access e.g mouse/pen trail.
	ImGuiMouseSource_ inputEventsNextMouseSource = ImGuiMouseSource.mouse;
	uint inputEventsNextEventID = 1;
	
	ImVector!(ImGuiWindow*) windows;                            // Windows, sorted in display order, back to front
	ImVector!(ImGuiWindow*) windowsFocusOrder;                  // Root windows, sorted in focus order, back to front.
	ImVector!(ImGuiWindow*) windowsTempSortBuffer;              // Temporary buffer used in EndFrame() to reorder windows so parents are kept before their child
	ImVector!ImGuiWindowStackData currentWindowStack;
	ImGuiStorage windowsByID;                        // Map window's ImGuiID to ImGuiWindow*
	int windowsActiveCount = 0;                 // Number of unique windows submitted by frame
	ImVec2 windowsHoverPadding;                // Padding around resizable windows for which hovering on counts as hovering the window == ImMax(style.TouchExtraPadding, WINDOWS_HOVER_PADDING)
	ImGuiWindow* currentWindow = null;                      // Window being drawn into
	ImGuiWindow* hoveredWindow = null;                      // Window the mouse is hovering. Will typically catch mouse inputs.
	ImGuiWindow* hoveredWindowUnderMovingWindow = null;     // Hovered window ignoring MovingWindow. Only set if MovingWindow is set.
	ImGuiWindow* movingWindow = null;                       // Track the window we clicked on (in order to preserve focus). The actual window that is moved is generally MovingWindow->RootWindowDockTree.
	ImGuiWindow* wheelingWindow = null;                     // Track the window we started mouse-wheeling on. Until a timer elapse or mouse has moved, generally keep scrolling the same window even if during the course of scrolling the mouse ends up hovering a child window.
	ImVec2 wheelingWindowRefMousePos;
	int wheelingWindowStartFrame = -1;           // This may be set one frame before WheelingWindow is != NULL
	int wheelingWindowScrolledFrame = -1;
	float wheelingWindowReleaseTimer = 0f;
	ImVec2 wheelingWindowWheelRemainder;
	ImVec2 wheelingAxisAvg;
	
	ImGuiID debugHookIDInfo = 0;                    // Will call core hooks: DebugHookIdInfo() from GetID functions, used by ID Stack Tool [next HoveredId/ActiveId to not pull in an extra cache-line]
	ImGuiID hoveredID = 0;                          // Hovered widget, filled during the frame
	ImGuiID hoveredIDPreviousFrame = 0;
	bool hoveredIDTimer = 0f;                     // Measure contiguous hovering time
	float hoveredIdNotActiveTimer = 0f;            // Measure contiguous hovering time where the item has not been active
	ImGuiID activeID = 0;                           // Active widget
	ImGuiID activeIDIsAlive = 0;                    // Active widget has been seen this frame (we can't use a bool as the ActiveId may change within the frame)
	float activeIDTimer = 0f;
	bool activeIDIsJustActivated = false;            // Set at the time of activation for one frame
	bool activeIDAllowOverlap = false;               // Active widget allows another widget to steal active id (generally for overlapping widgets, but not always)
	bool activeIDNoClearOnFocusLoss = false;         // Disable losing active id if the active id window gets unfocused.
	bool activeIDHasBeenPressedBefore = false;       // Track whether the active id led to a press (this is to allow changing between PressOnClick and PressOnRelease without pressing twice). Used by range_select branch.
	bool activeIDHasBeenEditedBefore = false;        // Was the value associated to the widget Edited over the course of the Active state.
	bool activeIDHasBeenEditedThisFrame = false;
	ImVec2 activeIDClickOffset = ImVec2(-1, -1);                // Clicked offset from upper-left corner, if applicable (currently only set by ButtonBehavior)
	ImGuiWindow* activeIDWindow = null;
	ImGuiInputSource activeIDSource = ImGuiInputSource.none;                     // Activating source: ImGuiInputSource_Mouse OR ImGuiInputSource_Keyboard OR ImGuiInputSource_Gamepad
	int activeIDMouseButton = -1;
	ImGuiID activeIDPreviousFrame = 0;
	bool activeIDPreviousFrameIsAlive = false;
	bool activeIDPreviousFrameHasBeenEditedBefore = false;
	ImGuiWindow* activeIDPreviousFrameWindow = null;
	ImGuiID lastActiveID = 0;                       // Store the last non-zero ActiveId, useful for animation.
	float lastActiveIDTimer = 0f;                  // Store the last non-zero ActiveId timer since the beginning of activation, useful for animation.
	
	ImGuiKeyOwnerData[ImGuiKey.namedKey_COUNT] keysOwnerData;
	ImGuiKeyRoutingTable keysRoutingTable;
	uint activeIDUsingNavDirMask = 0x00;            // Active widget will want to read those nav move requests (e.g. can activate a button and move away from it)
	bool activeIDUsingAllKeyboardKeys = false;       // Active widget will want to read all keyboard keys inputs. (FIXME: This is a shortcut for not taking ownership of 100+ keys but perhaps best to not have the inconsistency)
	deprecated uint activeIDUsingNavInputMask = 0x00;          // If you used this. Since (IMGUI_VERSION_NUM >= 18804) : 'g.ActiveIdUsingNavInputMask |= (1 << ImGuiNavInput_Cancel);' becomes 'SetKeyOwner(ImGuiKey_Escape, g.ActiveId) and/or SetKeyOwner(ImGuiKey_NavGamepadCancel, g.ActiveId);'
	
	ImGuiID currentFocusScopeID = 0;                // == g.FocusScopeStack.back()
	ImGuiItemFlags_ currentItemFlags = ImGuiItemFlags.none;                   // == g.ItemFlagsStack.back()
	ImGuiID debugLocateID = 0;                      // Storage for DebugLocateItemOnHover() feature: this is read by ItemAdd() so we keep it in a hot/cached location
	ImGuiNextItemData nextItemData;                       // Storage for SetNextItem** functions
	ImGuiLastItemData lastItemData;                       // Storage for last submitted item (setup by ItemAdd)
	ImGuiNextWindowData nextWindowData;                     // Storage for SetNextWindow** functions
	bool debugShowGroupRects = false;
	
	ImVector!ImGuiColorMod colorStack;                     // Stack for PushStyleColor()/PopStyleColor() - inherited by Begin()
	alias colourStack = colorStack;
	ImVector!ImGuiStyleMod styleVarStack;                  // Stack for PushStyleVar()/PopStyleVar() - inherited by Begin()
	ImVector!(ImFont*) fontStack;                      // Stack for PushFont()/PopFont() - inherited by Begin()
	ImVector!ImGuiID focusScopeStack;                // Stack for PushFocusScope()/PopFocusScope() - inherited by BeginChild(), pushed into by Begin()
	ImVector!ImGuiItemFlags itemFlagsStack;                 // Stack for PushItemFlag()/PopItemFlag() - inherited by Begin()
	ImVector!ImGuiGroupData groupStack;                     // Stack for BeginGroup()/EndGroup() - not inherited by Begin()
	ImVector!ImGuiPopupData openPopupStack;                 // Which popups are open (persistent)
	ImVector!ImGuiPopupData beginPopupStack;                // Which level of BeginPopup() we are in (reset every frame)
	ImVector!ImGuiNavTreeNodeData navTreeNodeStack;            // Stack for TreeNode() when a NavLeft requested is emitted.
	
	int beginMenuCount = 0;
	
	ImVector!(ImGuiViewportP*) viewports;                        // Active viewports (always 1+, and generally 1 unless multi-viewports are enabled). Each viewports hold their copy of ImDrawData.
	float currentDPIScale = 0f;                    // == CurrentViewport->DpiScale
	ImGuiViewportP* currentViewport = null;                    // We track changes of viewport (happening in Begin) so we can call Platform_OnChangedViewport()
	ImGuiViewportP* mouseViewport = null;
	ImGuiViewportP* mouseLastHoveredViewport = null;           // Last known viewport that was hovered by mouse (even if we are not hovering any viewport any more) + honoring the _NoInputs flag.
	ImGuiID platformLastFocusedViewportID = 0;
	ImGuiPlatformMonitor fallbackMonitor;                    // Virtual monitor used as fallback if backend doesn't provide monitor information.
	int viewportCreatedCount = 0;               // Unique sequential creation counter (mostly for testing/debugging)
	int platformWindowsCreatedCount = 0;        // Unique sequential creation counter (mostly for testing/debugging)
	int viewportFocusedStampCount = 0;          // Every time the front-most window changes, we stamp its viewport with an incrementing counter
	
	ImGuiWindow* navWindow = null;                          // Focused window for navigation. Could be called 'FocusedWindow'
	ImGuiID navID = 0;                              // Focused item for navigation
	ImGuiID navFocusScopeID = 0;                    // Identify a selection scope (selection code often wants to "clear other items" when landing on an item of the selection set)
	ImGuiID navActivateID = 0;                      // ~~ (g.ActiveId == 0) && (IsKeyPressed(ImGuiKey_Space) || IsKeyDown(ImGuiKey_Enter) || IsKeyPressed(ImGuiKey_NavGamepadActivate)) ? NavId : 0, also set when calling ActivateItem()
	ImGuiID navActivateDownID = 0;                  // ~~ IsKeyDown(ImGuiKey_Space) || IsKeyDown(ImGuiKey_Enter) || IsKeyDown(ImGuiKey_NavGamepadActivate) ? NavId : 0
	ImGuiID navActivatePressedID = 0;               // ~~ IsKeyPressed(ImGuiKey_Space) || IsKeyPressed(ImGuiKey_Enter) || IsKeyPressed(ImGuiKey_NavGamepadActivate) ? NavId : 0 (no repeat)
	ImGuiActivateFlags_ navActivateFlags = ImGuiActivateFlags.none;
	ImGuiID navJustMovedToID = 0;                   // Just navigated to this id (result of a successfully MoveRequest).
	ImGuiID navJustMovedToFocusScopeID = 0;         // Just navigated to this focus scope id (result of a successfully MoveRequest).
	ImGuiKeyChord navJustMovedToKeyMods = ImGuiMod.none;
	ImGuiID navNextActivateID = 0;                  // Set by ActivateItem(), queued until next frame.
	ImGuiActivateFlags_ navNextActivateFlags = ImGuiActivateFlags.none;
	ImGuiInputSource navInputSource = ImGuiInputSource.keyboard;                     // Keyboard or Gamepad mode? THIS CAN ONLY BE ImGuiInputSource_Keyboard or ImGuiInputSource_Mouse
	ImGuiNavLayer navLayer = ImGuiNavLayer.main;                           // Layer we are navigating on. For now the system is hard-coded for 0=main contents and 1=menu/title bar, may expose layers later.
	ImGuiSelectionUserData navLastValidSelectionUserData = ImGuiSelectionUserData.invalid;      // Last valid data passed to SetNextItemSelectionUser(), or -1. For current window. Not reset when focusing an item that doesn't have selection data.
	bool navIDIsAlive = false;                       // Nav widget has been seen this frame ~~ NavRectRel is valid
	bool navMousePosDirty = false;                   // When set we will update mouse position if (io.ConfigFlags & ImGuiConfigFlags_NavEnableSetMousePos) if set (NB: this not enabled by default)
	bool navDisableHighlight = false;                // When user starts using mouse, we hide gamepad/keyboard highlight (NB: but they are still available, which is why NavDisableHighlight isn't always != NavDisableMouseHover)
	bool navDisableMouseHover = false;               // When user starts using gamepad/keyboard, we hide mouse hovering highlight until mouse is touched again.
	
	bool navAnyRequest = false;                      // ~~ NavMoveRequest || NavInitRequest this is to perform early out in ItemAdd()
	bool navInitRequest = false;                     // Init request for appearing window to select first item
	bool navInitRequestFromMove = false;
	ImGuiNavItemData navInitResult;                      // Init request result (first item of the window, or one for which SetItemDefaultFocus() was called)
	bool navMoveSubmitted = false;                   // Move request submitted, will process result on next NewFrame()
	bool navMoveScoringItems = false;                // Move request submitted, still scoring incoming items
	bool navMoveForwardToNextFrame = false;
	ImGuiNavMoveFlags_ navMoveFlags = ImGuiNavMoveFlags.none;
	ImGuiScrollFlags_ navMoveScrollFlags = ImGuiScrollFlags.none;
	ImGuiKeyChord navMoveKeyMods = ImGuiMod.none;
	ImGuiDir_ navMoveDir = ImGuiDir.none;                         // Direction of the move request (left/right/up/down)
	ImGuiDir_ navMoveDirForDebug = ImGuiDir.none;
	ImGuiDir_ navMoveClipDir = ImGuiDir.none;                     // FIXME-NAV: Describe the purpose of this better. Might want to rename?
	ImRect navScoringRect;                     // Rectangle used for scoring, in screen space. Based of window->NavRectRel[], modified for directional navigation scoring.
	ImRect navScoringNoClipRect;               // Some nav operations (such as PageUp/PageDown) enforce a region which clipper will attempt to always keep submitted
	int navScoringDebugCount = 0;               // Metrics for debugging
	int navTabbingDir = 0;                      // Generally -1 or +1, 0 when tabbing without a nav id
	int navTabbingCounter = 0;                  // >0 when counting items for tabbing
	ImGuiNavItemData navMoveResultLocal;                 // Best move request candidate within NavWindow
	ImGuiNavItemData navMoveResultLocalVisible;          // Best move request candidate within NavWindow that are mostly visible (when using ImGuiNavMoveFlags_AlsoScoreVisibleSet flag)
	ImGuiNavItemData navMoveResultOther;                 // Best move request candidate within NavWindow's flattened hierarchy (when using ImGuiWindowFlags_NavFlattened flag)
	ImGuiNavItemData navTabbingResultFirst;              // First tabbing request candidate within NavWindow and flattened hierarchy
	
	ImGuiKeyChord configNavWindowingKeyNext = ImGuiMod.ctrl | ImGuiKey.tab;          // = ImGuiMod_Ctrl | ImGuiKey_Tab, for reconfiguration (see #4828)
	ImGuiKeyChord configNavWindowingKeyPrev = ImGuiMod.ctrl | ImGuiMod.shift | ImGuiKey.tab;          // = ImGuiMod_Ctrl | ImGuiMod_Shift | ImGuiKey_Tab
	ImGuiWindow* navWindowingTarget = null;                 // Target window when doing CTRL+Tab (or Pad Menu + FocusPrev/Next), this window is temporarily displayed top-most!
	ImGuiWindow* navWindowingTargetAnim = null;             // Record of last valid NavWindowingTarget until DimBgRatio and NavWindowingHighlightAlpha becomes 0.0f, so the fade-out can stay on it.
	ImGuiWindow* navWindowingListWindow = null;             // Internal window actually listing the CTRL+Tab contents
	float navWindowingTimer = 0f;
	float navWindowingHighlightAlpha = 0f;
	bool navWindowingToggleLayer = false;
	ImVec2 navWindowingAccumDeltaPos;
	ImVec2 navWindowingAccumDeltaSize;
	
	float dimBgRatio = 0f;                         // 0.0..1.0 animation when fading in a dimming background (for modal window and CTRL+TAB list)
	
	bool dragDropActive = false;
	bool dragDropWithinSource = false;               // Set when within a BeginDragDropXXX/EndDragDropXXX block for a drag source.
	bool dragDropWithinTarget = false;               // Set when within a BeginDragDropXXX/EndDragDropXXX block for a drag target.
	ImGuiDragDropFlags_ dragDropSourceFlags = ImGuiDragDropFlags.none;
	int dragDropSourceFrameCount = -1;
	int dragDropMouseButton = -1;
	ImGuiPayload_ dragDropPayload;
	ImRect dragDropTargetRect;                 // Store rectangle of current target candidate (we favor small targets when overlapping)
	ImGuiID dragDropTargetID = 0;
	ImGuiDragDropFlags_ dragDropAcceptFlags = ImGuiDragDropFlags.none;
	float dragDropAcceptIDCurrRectSurface = 0f;    // Target item surface (we resolve overlapping targets by prioritizing the smaller surface)
	ImGuiID dragDropAcceptIDCurr = 0;               // Target item id (set at the time of accepting the payload)
	ImGuiID dragDropAcceptIDPrev = 0;               // Target item id from previous frame (we need to store this to allow for overlapping drag and drop targets)
	int dragDropAcceptFrameCount = -1;           // Last time a target expressed a desire to accept the source
	ImGuiID dragDropHoldJustPressedID = 0;          // Set when holding a payload just made ButtonBehavior() return a press.
	ImVector!ubyte dragDropPayloadBufHeap;             // We don't expose the ImVector<> directly, ImGuiPayload only holds pointer+size
	ubyte[16] dragDropPayloadBufLocal;        // Local buffer for small payloads
	
	int clipperTempDataStacked = 0;
	ImVector!ImGuiListClipperData clipperTempData;
	
	ImGuiTable* currentTable = null;
	int tablesTempDataStacked = 0;      // Temporary table data size (because we leave previous instances undestructed, we generally don't use TablesTempData.Size)
	ImVector!ImGuiTableTempData tablesTempData;             // Temporary table data (buffers reused/shared across instances, support nesting)
	ImPool!ImGuiTable tables;                     // Persistent table data
	ImVector!float tablesLastTimeActive;       // Last used timestamp of each tables (SOA, for efficient GC)
	ImVector!ImDrawChannel drawChannelsTempMergeBuffer;
	
	ImGuiTabBar* currentTabBar = null;
	ImPool!ImGuiTabBar tabBars;
	ImVector!ImGuiPtrOrIndex currentTabBarStack;
	ImVector!ImGuiShrinkWidthItem shrinkWidthBuffer;
	
	ImGuiID hoverItemDelayID = 0;
	ImGuiID hoverItemDelayIdPreviousFrame = 0;
	float hoverItemDelayTimer = 0f;                // Currently used by IsItemHovered()
	float hoverItemDelayClearTimer = 0f;           // Currently used by IsItemHovered(): grace time before g.TooltipHoverTimer gets cleared.
	ImGuiID hoverItemUnlockedStationaryID = 0;      // Mouse has once been stationary on this item. Only reset after departing the item.
	ImGuiID hoverWindowUnlockedStationaryID = 0;    // Mouse has once been stationary on this window. Only reset after departing the window.
	
	ImGuiMouseCursor_ mouseCursor = ImGuiMouseCursor.arrow;
	float mouseStationaryTimer = 0f;               // Time the mouse has been stationary (with some loose heuristic)
	ImVec2 mouseLastValidPos;
	
	ImGuiInputTextState inputTextState;
	ImGuiInputTextDeactivatedState inputTextDeactivatedState;
	ImFont inputTextPasswordFont;
	ImGuiID tempInputID = 0;                        // Temporary text input when CTRL+clicking on a slider, etc.
	ImGuiColorEditFlags colorEditOptions = ImGuiColorEditFlags.defaultOptions_;                   // Store user options for color edit widgets
	alias colourEditOptions = colorEditOptions;
	ImGuiID colorEditCurrentID = 0;                 // Set temporarily while inside of the parent-most ColorEdit4/ColorPicker4 (because they call each others).
	alias colourEditCurrentID = colorEditCurrentID;
	ImGuiID colorEditSavedID = 0;                   // ID we are saving/restoring HS for
	alias colourEditSavedID = colorEditSavedID;
	float colorEditSavedHue = 0f;                  // Backup of last Hue associated to LastColor, so we can restore Hue in lossy RGB<>HSV round trips
	alias colourEditSavedHue = colorEditSavedHue;
	float colorEditSavedSat = 0f;                  // Backup of last Saturation associated to LastColor, so we can restore Saturation in lossy RGB<>HSV round trips
	alias colourEditSavedSat = colorEditSavedSat;
	uint colorEditSavedColor = 0;                // RGB value with alpha set to 0.
	alias colourEditSavedColour = colorEditSavedColor;
	ImVec4 colorPickerRef;                     // Initial/reference color at the time of opening the color picker.
	alias colourPickerRef = colorPickerRef;
	ImGuiComboPreviewData comboPreviewData;
	ImRect windowResizeBorderExpectedRect;     // Expected border rect, switch to relative edit if moving
	bool windowResizeRelativeMode = false;
	float sliderGrabClickOffset = 0f;
	float sliderCurrentAccum = 0f;                 // Accumulated slider delta when using navigation controls.
	bool sliderCurrentAccumDirty = false;            // Has the accumulated slider delta changed since last time we tried to apply it?
	bool dragCurrentAccumDirty = false;
	float dragCurrentAccum = 0f;                   // Accumulator for dragging modification. Always high-precision, not rounded by end-user precision settings
	float dragSpeedDefaultRatio = 1f / 100f;              // If speed == 0.0f, uses (max-min) * DragSpeedDefaultRatio 
	float scrollbarClickDeltaToGrabCenter = 0f;    // Distance between mouse and center of grab box, normalized in parent space. Use storage?
	alias scrollbarClickDeltaToGrabCentre = scrollbarClickDeltaToGrabCenter;
	float disabledAlphaBackup = 0f;                // Backup for style.Alpha for BeginDisabled()
	short disabledStackSize = 0;
	short lockMarkEdited = 0;
	short tooltipOverrideCount = 0;
	ImVector!char clipboardHandlerData;               // If no custom clipboard handler is defined
	ImVector!ImGuiID menusIdSubmittedThisFrame;          // A list of menu IDs that were rendered at least once
	ImGuiTypingSelectState typingSelectState;                  // State for GetTypingSelectRequest()
	
	ImGuiPlatformIMEData platformIMEData = {inputPos: ImVec2(0f, 0f)};                    // Data updated by current frame
	ImGuiPlatformIMEData platformIMEDataPrev = {inputPos: ImVec2(-1f, -1f)};                // Previous frame data (when changing we will call io.SetPlatformImeDataFn
	ImGuiID platformIMEViewport = 0;
	
	ImGuiDockContext dockContext;
	extern(C++) void function(ImGuiContext* ctx, ImGuiDockNode* node, ImGuiTabBar* tabBar) dockNodeWindowMenuHandler = null;
	
	bool settingsLoaded = false;
	float settingsDirtyTimer = 0f;                 // Save .ini Settings to memory when time reaches zero
	ImGuiTextBuffer settingsIniData;                    // In memory .ini settings
	ImVector!ImGuiSettingsHandler settingsHandlers;       // List of .ini settings handlers
	ImChunkStream!ImGuiWindowSettings settingsWindows;        // ImGuiWindow .ini settings entries
	ImChunkStream!ImGuiTableSettings settingsTables;         // ImGuiTable .ini settings entries
	ImVector!ImGuiContextHook hooks;                  // Hooks for extensions (e.g. test engine)
	ImGuiID hookIDNext = 0;             // Next available HookId
	
	const(char)*[ImGuiLocKey.COUNT] localizationTable;
	alias localisationTable = localizationTable;
	
	bool logEnabled = false;                         // Currently capturing
	ImGuiLogType logType = ImGuiLogType.none;                            // Capture target
	ImFileHandle logFile = null;                            // If != NULL log to stdout/ file
	ImGuiTextBuffer logBuffer;                          // Accumulation buffer when log to clipboard. This is pointer so our GImGui static constructor doesn't call heap allocators.
	const(char)* logNextPrefix = null;
	const(char)* logNextSuffix = null;
	float logLinePosY = float.max;
	bool logLineFirstItem = false;
	int logDepthRef = 0;
	int logDepthToExpand = 2;
	int logDepthToExpandDefault = 2;            // Default/stored value for LogDepthMaxExpand if not specified in the LogXXX function call.
	
	ImGuiDebugLogFlags debugLogFlags = ImGuiDebugLogFlags.outputToTTY;
	ImGuiTextBuffer debugLogBuf;
	ImGuiTextIndex debugLogIndex;
	ubyte debugLogClipperAutoDisableFrames = 0;
	ubyte debugLocateFrames = 0;                  // For DebugLocateItemOnHover(). This is used together with DebugLocateId which is in a hot/cached spot above.
	byte debugBeginReturnValueCullDepth = -1;     // Cycle between 0..9 then wrap around.
	bool debugItemPickerActive = false;              // Item picker is active (started with DebugStartItemPicker())
	ubyte debugItemPickerMouseButton = ImGuiMouseButton.left;
	ImGuiID debugItemPickerBreakID = 0;             // Will call IM_DEBUG_BREAK() when encountering this ID
	ImGuiMetricsConfig debugMetricsConfig;
	ImGuiIDStackTool debugIDStackTool;
	ImGuiDebugAllocInfo debugAllocInfo;
	ImGuiDockNode* debugHoveredDockNode = null;               // Hovered dock node.
	
	float[60] framerateSecPerFrame = {
		float[60] ret;
		foreach(ref v; ret) v = 0f;
		return ret;
	}();           // Calculate estimate of framerate for user over the last 60 frames..
	int framerateSecPerFrameIdx = 0;
	int framerateSecPerFrameCount = 0;
	float framerateSecPerFrameAccum = 0f;
	int wantCaptureMouseNextFrame = -1;          // Explicit capture override via SetNextFrameWantCaptureMouse()/SetNextFrameWantCaptureKeyboard(). Default to -1.
	int wantCaptureKeyboardNextFrame = -1;       // "
	int wantTextInputNextFrame = -1;
	ImVector!char tempBuffer;                         // Temporary text buffer
	
	this(ImFontAtlas* sharedFontAtlas){
		io.ctx = &this;
		inputTextState.ctx = &this;
		
		fontAtlasOwnedByContext = sharedFontAtlas ? false : true;
		if(sharedFontAtlas){
			io.fonts = sharedFontAtlas;
		}else{
			io.fonts = IM_NEW!ImFontAtlas(0);
		}
	}
};

//-----------------------------------------------------------------------------
// [SECTION] ImGuiWindowTempData, ImGuiWindow
//-----------------------------------------------------------------------------

// Transient per-window data, reset at the beginning of the frame. This used to be called ImGuiDrawContext, hence the DC variable name in ImGuiWindow.
// (That's theory, in practice the delimitation between ImGuiWindow and ImGuiWindowTempData is quite tenuous and could be reconsidered..)
// (This doesn't need a constructor because we zero-clear it as part of ImGuiWindow and all frame-temporary data are setup on Begin)
extern(C++) struct IMGUI_API ImGuiWindowTempData{
	ImVec2 cursorPos;              // Current emitting position, in absolute coordinates.
	ImVec2 cursorPosPrevLine;
	ImVec2 cursorStartPos;         // Initial position after Begin(), generally ~ window position + WindowPadding.
	ImVec2 cursorMaxPos;           // Used to implicitly calculate ContentSize at the beginning of next frame, for scrolling range and auto-resize. Always growing during the frame.
	ImVec2 idealMaxPos;            // Used to implicitly calculate ContentSizeIdeal at the beginning of next frame, for auto-resize only. Always growing during the frame.
	ImVec2 currLineSize;
	ImVec2 prevLineSize;
	float currLineTextBaseOffset; // Baseline offset (0.0f by default on a new line, generally == style.FramePadding.y when a framed item has been added).
	float prevLineTextBaseOffset;
	bool isSameLine;
	bool isSetPos;
	ImVec1 indent;                 // Indentation / start position from left of window (increased by TreePush/TreePop, etc.)
	ImVec1 columnsOffset;          // Offset to the current column (if ColumnsCurrent > 0). FIXME: This and the above should be a stack to allow use cases like Tree->Column->Tree. Need revamp columns API.
	ImVec1 groupOffset;
	ImVec2 cursorStartPosLossyness;// Record the loss of precision of CursorStartPos due to really large scrolling amount. This is used by clipper to compensate and fix the most common use case of large scroll area.
	
	ImGuiNavLayer navLayerCurrent;        // Current layer, 0..31 (we currently only use 0..1)
	short navLayersActiveMask;    // Which layers have been written to (result from previous frame)
	short navLayersActiveMaskNext;// Which layers have been written to (accumulator for current frame)
	bool navIsScrollPushableX;   // Set when current work location may be scrolled horizontally when moving left / right. This is generally always true UNLESS within a column.
	bool navHideHighlightOneFrame;
	bool navWindowHasScrollY;    // Set per window when scrolling can be used (== ScrollMax.y > 0.0f)
	
	bool menuBarAppending;       // FIXME: Remove this
	ImVec2 menuBarOffset;          // MenuBarOffset.x is sort of equivalent of a per-layer CursorPos.x, saved/restored as we switch to the menu bar. The only situation when MenuBarOffset.y is > 0 if when (SafeAreaPadding.y > FramePadding.y), often used on TVs.
	ImGuiMenuColumns menuColumns;            // Simplified columns storage for menu items measurement
	int treeDepth;              // Current tree depth.
	uint treeJumpToParentOnPopMask; // Store a copy of !g.NavIdIsAlive for TreeDepth 0..31.. Could be turned into a ulong if necessary.
	ImVector!(ImGuiWindow*) childWindows;
	ImGuiStorage* stateStorage;           // Current persistent per-window storage (store e.g. tree node open/close state)
	ImGuiOldColumns* currentColumns;         // Current columns set
	int currentTableIdx;        // Current table index (into g.Tables)
	ImGuiLayoutType layoutType;
	ImGuiLayoutType parentLayoutType;       // Layout type of parent window at the time of Begin()
	
	float itemWidth;              // Current item width (>0.0: width in pixels, <0.0: align xx pixels to the right of window).
	float textWrapPos;            // Current text wrap pos.
	ImVector!float itemWidthStack;         // Store item widths to restore (attention: .back() is not == ItemWidth)
	ImVector!float textWrapPosStack;       // Store text wrap pos to restore (attention: .back() is not == TextWrapPos)
};

// Storage for one window
extern(C++) struct IMGUI_API ImGuiWindow{
	ImGuiContext* ctx;                                // Parent UI context (needs to be set explicitly by parent).
	char* name;                               // Window name, owned by the window.
	ImGuiID id;                                 // == ImHashStr(Name)
	ImGuiWindowFlags flags, flagsPreviousFrame;          // See enum ImGuiWindowFlags_
	ImGuiChildFlags childFlags;                         // Set when window is a child window. See enum ImGuiChildFlags_
	ImGuiWindowClass windowClass;                        // Advanced users only. Set with SetNextWindowClass()
	ImGuiViewportP* viewport;                           // Always set in Begin(). Inactive windows may have a NULL value here if their viewport was discarded.
	ImGuiID viewportID;                         // We backup the viewport id (since the viewport may disappear or never be created if the window is inactive)
	ImVec2 viewportPos;                        // We backup the viewport position (since the viewport may disappear or never be created if the window is inactive)
	int viewportAllowPlatformMonitorExtend; // Reset to -1 every frame (index is guaranteed to be valid between NewFrame..EndFrame), only used in the Appearing frame of a tooltip/popup to enforce clamping to a given monitor
	ImVec2 pos;                                // Position (always rounded-up to nearest pixel)
	ImVec2 size;                               // Current size (==SizeFull or collapsed title bar size)
	ImVec2 sizeFull;                           // Size when non collapsed
	ImVec2 contentSize;                        // Size of contents/scrollable client area (calculated from the extents reach of the cursor) from previous frame. Does not include window decoration or window padding.
	ImVec2 contentSizeIdeal;
	ImVec2 contentSizeExplicit;                // Size of contents/scrollable client area explicitly request by the user via SetNextWindowContentSize().
	ImVec2 windowPadding;                      // Window padding at the time of Begin().
	float windowRounding;                     // Window rounding at the time of Begin(). May be clamped lower to avoid rendering artifacts with title bar, menu bar etc.
	float windowBorderSize;                   // Window border size at the time of Begin().
	float decoOuterSizeX1, decoOuterSizeY1;   // Left/Up offsets. Sum of non-scrolling outer decorations (X1 generally == 0.0f. Y1 generally = TitleBarHeight + MenuBarHeight). Locked during Begin().
	float decoOuterSizeX2, decoOuterSizeY2;   // Right/Down offsets (X2 generally == ScrollbarSize.x, Y2 == ScrollbarSizes.y).
	float decoInnerSizeX1, decoInnerSizeY1;   // Applied AFTER/OVER InnerRect. Specialized for Tables as they use specialized form of clipping and frozen rows/columns are inside InnerRect (and not part of regular decoration sizes).
	int nameBufLen;                         // Size of buffer storing Name. May be larger than strlen(Name)!
	ImGuiID moveID;                             // == window->GetID("#MOVE")
	ImGuiID tabID;                              // == window->GetID("#TAB")
	ImGuiID childID;                            // ID of corresponding item in parent window (for navigation to return from child window to parent window)
	ImVec2 scroll;
	ImVec2 scrollMax;
	ImVec2 scrollTarget;                       // target scroll position. stored as cursor position with scrolling canceled out, so the highest point is always 0.0f. (FLT_MAX for no change)
	ImVec2 scrollTargetCenterRatio;            // 0.0f = scroll so that target position is at top, 0.5f = scroll so that target position is centered
	ImVec2 scrollTargetEdgeSnapDist;           // 0.0f = no snapping, >0.0f snapping threshold
	ImVec2 scrollbarSizes;                     // Size taken by each scrollbars on their smaller axis. Pay attention! ScrollbarSizes.x == width of the vertical scrollbar, ScrollbarSizes.y = height of the horizontal scrollbar.
	bool scrollbarX, ScrollbarY;             // Are scrollbars visible?
	bool viewportOwned;
	bool active;                             // Set to true on Begin(), unless Collapsed
	bool wasActive;
	bool writeAccessed;                      // Set to true when any widget access the current window
	bool collapsed;                          // Set when collapsing window to become only title-bar
	bool wantCollapseToggle;
	bool skipItems;                          // Set when items can safely be all clipped (e.g. window not visible or collapsed)
	bool appearing;                          // Set during the frame where the window is appearing (or re-appearing)
	bool hidden;                             // Do not display (== HiddenFrames*** > 0)
	bool isFallbackWindow;                   // Set on the "Debug##Default" window.
	bool isExplicitChild;                    // Set when passed _ChildWindow, left to false by BeginDocked()
	bool hasCloseButton;                     // Set when the window has a close button (p_open != NULL)
	byte resizeBorderHovered;                // Current border being hovered for resize (-1: none, otherwise 0-3)
	byte resizeBorderHeld;                   // Current border being held for resize (-1: none, otherwise 0-3)
	short beginCount;                         // Number of Begin() during the current frame (generally 0 or 1, 1+ if appending via multiple Begin/End pairs)
	short beginCountPreviousFrame;            // Number of Begin() during the previous frame
	short beginOrderWithinParent;             // Begin() order within immediate parent window, if we are a child window. Otherwise 0.
	short beginOrderWithinContext;            // Begin() order within entire imgui context. This is mostly used for debugging submission order related issues.
	short focusOrder;                         // Order within WindowsFocusOrder[], altered when windows are focused.
	ImGuiID popupID;                            // ID in the popup stack when this window is used as a popup/menu (because we use generic Name/ID for recycling)
	byte autoFitFramesX, autoFitFramesY;
	bool autoFitOnlyGrows;
	ImGuiDir autoPosLastDirection;
	byte hiddenFramesCanSkipItems;           // Hide the window for N frames
	byte hiddenFramesCannotSkipItems;        // Hide the window for N frames while allowing items to be submitted so we can measure their size
	byte hiddenFramesForRenderOnly;          // Hide the window until frame N at Render() time only
	byte disableInputsFrames;                // Disable window interactions for N frames
	//ImGuiCond setWindowPosAllowFlags: 8;
	//ImGuiCond setWindowSizeAllowFlags: 8;
	//ImGuiCond setWindowCollapsedAllowFlags: 8;
	//ImGuiCond setWindowDockAllowFlags: 8;
	private uint setWindowBitfields; //this replaces the 4 8-bit bitfields above
	ImVec2 setWindowPosVal;                    // store window position when using a non-zero Pivot (position set needs to be processed when we know the window size)
	ImVec2 setWindowPosPivot;                  // store window pivot for positioning. ImVec2(0, 0) when positioning from top-left corner; ImVec2(0.5f, 0.5f) for centering; ImVec2(1, 1) for bottom right.
	
	ImVector!ImGuiID idStack;                            // ID stack. ID are hashes seeded with the value at the top of the stack. (In theory this should be in the TempData structure)
	ImGuiWindowTempData dc;                                 // Temporary per-window data, reset at the beginning of the frame. This used to be called ImGuiDrawContext, hence the "DC" variable name.
	
	ImRect outerRectClipped;                   // == Window->Rect() just after setup in Begin(). == window->Rect() for root window.
	ImRect innerRect;                          // Inner rectangle (omit title bar, menu bar, scroll bar)
	ImRect innerClipRect;                      // == InnerRect shrunk by WindowPadding*0.5f on each side, clipped within viewport or parent clip rect.
	ImRect workRect;                           // Initially covers the whole scrolling region. Reduced by containers e.g columns/tables when active. Shrunk by WindowPadding*1.0f on each side. This is meant to replace ContentRegionRect over time (from 1.71+ onward).
	ImRect parentWorkRect;                     // Backup of WorkRect before entering a container such as columns/tables. Used by e.g. SpanAllColumns functions to easily access. Stacked containers are responsible for maintaining this. // FIXME-WORKRECT: Could be a stack?
	ImRect clipRect;                           // Current clipping/scissoring rectangle, evolve as we are using PushClipRect(), etc. == DrawList->clip_rect_stack.back().
	ImRect contentRegionRect;                  // FIXME: This is currently confusing/misleading. It is essentially WorkRect but not handling of scrolling. We currently rely on it as right/bottom aligned sizing operation need some size to rely on.
	ImVec2ih hitTestHoleSize;                    // Define an optional rectangular hole where mouse will pass-through the window.
	ImVec2ih hitTestHoleOffset;
	
	int lastFrameActive;                    // Last frame number the window was Active.
	int lastFrameJustFocused;               // Last frame number the window was made Focused.
	float lastTimeActive;                     // Last timestamp the window was Active (using float as we don't need high precision there)
	float itemWidthDefault;
	ImGuiStorage stateStorage;
	ImVector!ImGuiOldColumns columnsStorage;
	float fontWindowScale;                    // User scale multiplier per-window, via SetWindowFontScale()
	float fontDPIScale;
	int settingsOffset;                     // Offset into SettingsWindows[] (offsets are always valid as we only grow the array from the back)
	
	ImDrawList* drawList;                           // == &DrawListInst (for backward compatibility reason with code using imgui_internal.h we keep this a pointer)
	ImDrawList drawListInst;
	ImGuiWindow* parentWindow;                       // If we are a child _or_ popup _or_ docked window, this is pointing to our parent. Otherwise NULL.
	ImGuiWindow* parentWindowInBeginStack;
	ImGuiWindow* rootWindow;                         // Point to ourself or first ancestor that is not a child window. Doesn't cross through popups/dock nodes.
	ImGuiWindow* rootWindowPopupTree;                // Point to ourself or first ancestor that is not a child window. Cross through popups parent<>child.
	ImGuiWindow* rootWindowDockTree;                 // Point to ourself or first ancestor that is not a child window. Cross through dock nodes.
	ImGuiWindow* rootWindowForTitleBarHighlight;     // Point to ourself or first ancestor which will display TitleBgActive color when this window is active.
	ImGuiWindow* rootWindowForNav;                   // Point to ourself or first ancestor which doesn't have the NavFlattened flag.
	
	ImGuiWindow* navLastChildNavWindow;              // When going to the menu bar, we remember the child window we came from. (This could probably be made implicit if we kept g.Windows sorted by last focused including child window.)
	ImGuiID[ImGuiNavLayer.COUNT] navLastIDs;    // Last known NavId for this window, per layer (0/1)
	ImRect[ImGuiNavLayer.COUNT] navRectRel;    // Reference rectangle, in window relative space
	ImVec2[ImGuiNavLayer.COUNT] navPreferredScoringPosRel; // Preferred X/Y position updated when moving on a given axis, reset to FLT_MAX.
	ImGuiID navRootFocusScopeID;                // Focus Scope ID at the time of Begin()
	
	int memoryDrawListIdxCapacity;          // Backup of last idx/vtx count, so when waking up the window we can preallocate and avoid iterative alloc/copy
	int memoryDrawListVtxCapacity;
	bool memoryCompacted;                    // Set when window extraneous data have been garbage collected
	
	bool dockIsActive        :1;             // When docking artifacts are actually visible. When this is set, DockNode is guaranteed to be != NULL. ~~ (DockNode != NULL) && (DockNode->Windows.Size > 1).
	bool dockNodeIsVisible   :1;
	bool dockTabIsVisible    :1;             // Is our window visible this frame? ~~ is the corresponding tab selected?
	bool dockTabWantClose    :1;
	short dockOrder;                          // Order of the last time the window was visible within its DockNode. This is used to reorder windows that are reappearing on the same frame. Same value between windows that were active and windows that were none are possible.
	ImGuiWindowDockStyle dockStyle;
	ImGuiDockNode* dockNode;                           // Which node are we docked into. Important: Prefer testing DockIsActive in many cases as this will still be set when the dock node is hidden.
	ImGuiDockNode* dockNodeAsHost;                     // Which node are we owning (for parent windows)
	ImGuiID dockID;                             // Backup of last valid DockNode->ID, so single window remember their dock node id even when they are not bound any more
	ImGuiItemStatusFlags dockTabItemStatusFlags;
	ImRect dockTabItemRect;
	
	this(ImGuiContext* context, const(char)* name);
	~this();
	
	ImGuiID     GetID(const(char)* str, const(char)* strEnd=null);
	ImGuiID     GetID(const(void)* ptr);
	ImGuiID     GetID(int n);
	ImGuiID     GetIDFromRectangle(in ImRect rAbs);
	
	nothrow @nogc:
	ImRect rect() const pure @safe => ImRect(pos.x, pos.y, pos.x + size.x, pos.y + size.y);
	float calcFontSize() const pure @safe{
		float scale = ctx.fontBaseSize * fontWindowScale * fontDPIScale;
		if(parentWindow) scale *= parentWindow.fontWindowScale;
		return scale;
	}
	float titleBarHeight() const pure @safe => (flags & ImGuiWindowFlags.noTitleBar) ? 0f : calcFontSize() + ctx.style.framePadding.y * 2f;
	ImRect titleBarRect() const pure @safe => ImRect(pos, ImVec2(pos.x + sizeFull.x, pos.y + titleBarHeight()));
	float menuBarHeight() const pure @safe => (flags & ImGuiWindowFlags.menuBar) ? dc.menuBarOffset.y + calcFontSize() + ctx.style.framePadding.y * 2f : 0f;
	ImRect menuBarRect() const pure @safe{
		float y1 = pos.y + titleBarHeight();
		return ImRect(pos.x, y1, pos.x + sizeFull.x, y1 + menuBarHeight());
	}
}

enum ImGuiTabBarFlagsPrivate: ImGuiTabBarFlags{
	dockNode                   = 1 << 20,  // Part of a dock node [we don't use this in the master branch but it facilitate branch syncing to keep this around]
	isFocused                  = 1 << 21,
	saveSettings               = 1 << 22,  // FIXME: Settings are handled by the docking system, this only request the tab bar to mark settings dirty when reordering tabs
}

enum ImGuiTabItemFlagsPrivate: ImGuiTabItemFlags{
	sectionMask_              = ImGuiTabItemFlags.leading | ImGuiTabItemFlags.trailing,
	noCloseButton             = 1 << 20,  // Track whether p_open was set or not (we'll need this info on the next frame to recompute ContentWidth during layout)
	button                    = 1 << 21,  // Used by TabItemButton, change the tab item behavior to mimic a button
	unsorted                  = 1 << 22,  // [Docking] Trailing tabs with the _Unsorted flag will be sorted based on the DockOrder of their Window.
}

extern(C++) struct ImGuiTabItem{
	ImGuiID             id = 0;
	ImGuiTabItemFlags   flags = 0;
	ImGuiWindow*        window = null;                 // When TabItem is part of a DockNode's TabBar, we hold on to a window.
	int                 lastFrameVisible = -1;
	int                 lastFrameSelected = -1;      // This allows us to infer an ordered list of the last activated tabs with little maintenance
	float               offset = 0f;                 // Position relative to beginning of tab
	float               width = 0f;                  // Width currently displayed
	float               contentWidth = 0f;           // Width of label, stored during BeginTabItem() call
	float               requestedWidth = -1f;         // Width optionally requested by caller, -1.0f is unused
	int                 nameOffset = -1;             // When Window==NULL, offset to name within parent ImGuiTabBar::TabsNames
	short               beginOrder = -1;             // BeginTabItem() order, used to re-order tabs after toggling ImGuiTabBarFlags_Reorderable
	short               indexDuringLayout = -1;      // Index only used during TabBarLayout(). Tabs gets reordered so 'Tabs[n].IndexDuringLayout == n' but may mismatch during additions.
	bool                wantClose = false;              // Marked as closed by SetTabItemClosed()
}
static assert(ImGuiTabItem.sizeof == 48);

extern(C++) struct IMGUI_API ImGuiTabBar{
	ImVector!ImGuiTabItem tabs;
	ImGuiTabBarFlags flags;
	ImGuiID id;                     // Zero for tab-bars used by docking
	ImGuiID selectedTabID;          // Selected tab/window
	ImGuiID nextSelectedTabID;      // Next selected tab/window. Will also trigger a scrolling animation
	ImGuiID visibleTabID;           // Can occasionally be != SelectedTabId (e.g. when previewing contents for CTRL+TAB preview)
	int currFrameVisible;
	int prevFrameVisible;
	ImRect barRect;
	float currTabsContentsHeight;
	float prevTabsContentsHeight; // Record the height of contents submitted below the tab bar
	float widthAllTabs;           // Actual width of all tabs (locked during layout)
	float widthAllTabsIdeal;      // Ideal width if all tabs were visible and not clipped
	float scrollingAnim;
	float scrollingTarget;
	float scrollingTargetDistToVisibility;
	float scrollingSpeed;
	float scrollingRectMinX;
	float scrollingRectMaxX;
	float separatorMinX;
	float separatorMaxX;
	ImGuiID reorderRequestTabID;
	short reorderRequestOffset;
	byte beginCount;
	bool wantLayout;
	bool visibleTabWasSubmitted;
	bool tabsAddedNew;           // Set to true when a new tab item or button has been added to the tab bar during last frame
	short tabsActiveCount;        // Number of tabs submitted this frame.
	short lastTabItemIdx;         // Index of last BeginTabItem() tab for use by EndTabItem()
	float itemSpacingY;
	ImVec2 framePadding;           // style.FramePadding locked at the time of BeginTabBar()
	ImVec2 backupCursorPos;
	ImGuiTextBuffer tabsNames;              // For non-docking tab bar we re-append names in a contiguous buffer.
	
	ImGuiTabBar();
}
static assert(ImGuiTabBar.sizeof == 152);

alias ImGuiTableColumnIdx = short;
alias ImGuiTableDrawChannelIdx = ushort;

extern(C++) struct ImGuiTableColumn{
	ImGuiTableColumnFlags flags = 0;                          // Flags after some patching (not directly same as provided by user). See ImGuiTableColumnFlags_
	float widthGiven = 0f;                     // Final/actual width visible == (MaxX - MinX), locked in TableUpdateLayout(). May be > WidthRequest to honor minimum width, may be < WidthRequest to honor shrinking columns down in tight space.
	float minX = 0f;                           // Absolute positions
	float maxX = 0f;
	float widthRequest = 1f;                   // Master width absolute value when !(Flags & _WidthStretch). When Stretch this is derived every frame from StretchWeight in TableUpdateLayout()
	float widthAuto = 0f;                      // Automatic width
	float stretchWeight = 1f;                  // Master width weight when (Flags & _WidthStretch). Often around ~1.0f initially.
	float initStretchWeightOrWidth = 0f;       // Value passed to TableSetupColumn(). For Width it is a content width (_without padding_).
	ImRect clipRect = ImRect(0f, 0f, 0f, 0f);                       // Clipping rectangle for the column
	ImGuiID userID = 0;                         // Optional, value passed to TableSetupColumn()
	float workMinX = 0f;                       // Contents region min ~(MinX + CellPaddingX + CellSpacingX1) == cursor start position when entering column
	float workMaxX = 0f;                       // Contents region max ~(MaxX - CellPaddingX - CellSpacingX2)
	float itemWidth = 0f;                      // Current item width for the column, preserved across rows
	float contentMaxXFrozen = 0f;              // Contents maximum position for frozen rows (apart from headers), from which we can infer content width.
	float contentMaxXUnfrozen = 0f;
	float contentMaxXHeadersUsed = 0f;         // Contents maximum position for headers rows (regardless of freezing). TableHeader() automatically softclip itself + report ideal desired size, to avoid creating extraneous draw calls
	float contentMaxXHeadersIdeal = 0f;
	short nameOffset = -1;                     // Offset into parent ColumnsNames[]
	ImGuiTableColumnIdx displayOrder = -1;                   // Index within Table's IndexToDisplayOrder[] (column may be reordered by users)
	ImGuiTableColumnIdx indexWithinEnabledSet = -1;          // Index within enabled/visible set (<= IndexToDisplayOrder)
	ImGuiTableColumnIdx prevEnabledColumn = -1;              // Index of prev enabled/visible column within Columns[], -1 if first enabled/visible column
	ImGuiTableColumnIdx nextEnabledColumn = -1;              // Index of next enabled/visible column within Columns[], -1 if last enabled/visible column
	ImGuiTableColumnIdx sortOrder = -1;                      // Index of this column within sort specs, -1 if not sorting on this column, 0 for single-sort, may be >0 on multi-sort
	ImGuiTableDrawChannelIdx drawChannelCurrent = -1;            // Index within DrawSplitter.Channels[]
	ImGuiTableDrawChannelIdx drawChannelFrozen = -1;             // Draw channels for frozen rows (often headers)
	ImGuiTableDrawChannelIdx drawChannelUnfrozen = -1;           // Draw channels for unfrozen rows
	bool isEnabled = false;                      // IsUserEnabled && (Flags & ImGuiTableColumnFlags_Disabled) == 0
	bool isUserEnabled = false;                  // Is the column not marked Hidden by the user? (unrelated to being off view, e.g. clipped by scrolling).
	bool isUserEnabledNextFrame = false;
	bool isVisibleX = false;                     // Is actually in view (e.g. overlapping the host window clipping rectangle, not scrolled).
	bool isVisibleY = false;
	bool isRequestOutput = false;                // Return value for TableSetColumnIndex() / TableNextColumn(): whether we request user to output contents or not.
	bool isSkipItems = false;                    // Do we want item submissions to this column to be completely ignored (no layout will happen).
	bool isPreserveWidthAuto = false = 0;
	byte navLayerCurrent = 0;                // ImGuiNavLayer in 1 byte
	ubyte autoFitQueue = 0;                   // Queue of 8 values for the next 8 frames to request auto-fit
	ubyte cannotSkipItemsQueue = 0;           // Queue of 8 values for the next 8 frames to disable Clipped/SkipItem
	ubyte sortDirection : 2 = ImGuiSortDirection.none;              // ImGuiSortDirection_Ascending or ImGuiSortDirection_Descending
	ubyte sortDirectionsAvailCount : 2 = 0;   // Number of available sort directions (0 to 3)
	ubyte sortDirectionsAvailMask : 4 = 0;    // Mask of available sort directions (1-bit each)
	ubyte sortDirectionsAvailList = 0;        // Ordered list of available sort directions (2-bits each, total 8-bits)
}
static assert(ImGuiTableColumn.sizeof == 112);

// Transient cell data stored per row.
extern(C++) struct ImGuiTableCellData{
	uint bgColor;    // Actual color
	alias bgColour = bgColor;
	ImGuiTableColumnIdx column;     // Column number
}
static assert(ImGuiTableCellData.sizeof == 6);

// Per-instance data that needs preserving across frames (seemingly most others do not need to be preserved aside from debug needs. Does that means they could be moved to ImGuiTableTempData?)
extern(C++) struct ImGuiTableInstanceData{
	ImGuiID tableInstanceID = 0;
	float lastOuterHeight = 0f;            // Outer height from last frame
	float lastTopHeadersRowHeight = 0f;    // Height of first consecutive header rows from last frame (FIXME: this is used assuming consecutive headers are in same frozen set)
	float lastFrozenHeight = 0f;           // Height of frozen section from last frame
	int hoveredRowLast = -1;             // Index of row which was hovered last frame.
	int hoveredRowNext = -1;             // Index of row hovered this frame, set after encountering it.
}
static assert(ImGuiTableCellData.sizeof == 24);

// FIXME-TABLE: more transient data could be stored in a stacked ImGuiTableTempData: e.g. SortSpecs, incoming RowData
// sizeof() ~ 580 bytes + heap allocs described in TableBeginInitMemory()
extern(C++) struct IMGUI_API ImGuiTable{
	ImGuiID id = 0;
	ImGuiTableFlags_ flags = 0;
	void* rawData = null;                    // Single allocation to hold Columns[], DisplayOrderToIndex[] and RowCellData[]
	ImGuiTableTempData* tempData = null;                   // Transient data while table is active. Point within g.CurrentTableStack[]
	ImSpan!ImGuiTableColumn columns;                    // Point within RawData[]
	ImSpan!ImGuiTableColumnIdx displayOrderToIndex;        // Point within RawData[]. Store display order of columns (when not reordered, the values are 0...Count-1)
	ImSpan!ImGuiTableCellData rowCellData;                // Point within RawData[]. Store cells background requests for current row.
	ImBitArrayPtr enabledMaskByDisplayOrder = null;  // Column DisplayOrder -> IsEnabled map
	ImBitArrayPtr enabledMaskByIndex = null;         // Column Index -> IsEnabled map (== not hidden by user/api) in a format adequate for iterating column without touching cold data
	ImBitArrayPtr visibleMaskByIndex = null;         // Column Index -> IsVisibleX|IsVisibleY map (== not hidden by user/api && not hidden by scrolling/cliprect)
	ImGuiTableFlags_ settingsLoadedFlags;        // Which data were loaded from the .ini file (e.g. when order is not altered we won't save order)
	int settingsOffset = 0;             // Offset in g.SettingsTables
	int lastFrameActive = -1;
	int columnsCount = 0;               // Number of columns declared in BeginTable()
	int currentRow = 0;
	int currentColumn = 0;
	short instanceCurrent = 0;            // Count of BeginTable() calls with same ID in the same frame (generally 0). This is a little bit similar to BeginCount for a window, but multiple table with same ID look are multiple tables, they are just synched.
	short instanceInteracted = 0;         // Mark which instance (generally 0) of the same ID is being interacted with
	float rowPosY1 = 0f;
	float rowPosY2 = 0f;
	float rowMinHeight = 0f;               // Height submitted to TableNextRow()
	float rowCellPaddingY = 0f;            // Top and bottom padding. Reloaded during row change.
	float rowTextBaseline = 0f;
	float rowIndentOffsetX = 0f;
	ImGuiTableRowFlags_ rowFlags : 16 = 0;              // Current row flags, see ImGuiTableRowFlags_
	ImGuiTableRowFlags_ lastRowFlags : 16 = 0;
	int rowBgColorCounter = 0;          // Counter for alternating background colors (can be fast-forwarded by e.g clipper), not same as CurrentRow because header rows typically don't increase this.
	alias rowBgColourCounter = rowBgColorCounter;
	uint[2] rowBgColor;              // Background color override for current row.
	alias rowBgColour = rowBgColor;
	uint borderColorStrong = 0;
	alias borderColourStrong = borderColorStrong;
	uint borderColorLight = 0;
	alias borderColourLight = borderColorLight;
	float borderX1 = 0f;
	float borderX2 = 0f;
	float hostIndentX = 0f;
	float minColumnWidth = 0f;
	float outerPaddingX = 0f;
	float cellPaddingX = 0f;               // Padding from each borders. Locked in BeginTable()/Layout.
	float cellSpacingX1 = 0f;              // Spacing between non-bordered cells. Locked in BeginTable()/Layout.
	float cellSpacingX2 = 0f;
	float innerWidth = 0f;                 // User value passed to BeginTable(), see comments at the top of BeginTable() for details.
	float columnsGivenWidth = 0f;          // Sum of current column width
	float columnsAutoFitWidth = 0f;        // Sum of ideal column width in order nothing to be clipped, used for auto-fitting and content width submission in outer window
	float columnsStretchSumWeights = 0f;   // Sum of weight of all enabled stretching columns
	float resizedColumnNextWidth = 0f;
	float resizeLockMinContentsX2 = 0f;    // Lock minimum contents width while resizing down in order to not create feedback loops. But we allow growing the table.
	float refScale = 0f;                   // Reference scale to be able to rescale columns on font/dpi changes.
	float angledHeadersHeight = 0f;        // Set by TableAngledHeadersRow(), used in TableUpdateLayout()
	float angledHeadersSlope = 0f;         // Set by TableAngledHeadersRow(), used in TableUpdateLayout()
	ImRect outerRect = ImRect(0f, 0f, 0f, 0f);                  // Note: for non-scrolling table, OuterRect.Max.y is often FLT_MAX until EndTable(), unless a height has been specified in BeginTable().
	ImRect innerRect = ImRect(0f, 0f, 0f, 0f);                  // InnerRect but without decoration. As with OuterRect, for non-scrolling tables, InnerRect.Max.y is
	ImRect workRect = ImRect(0f, 0f, 0f, 0f);
	ImRect innerClipRect = ImRect(0f, 0f, 0f, 0f);
	ImRect bgClipRect = ImRect(0f, 0f, 0f, 0f);                 // We use this to cpu-clip cell background color fill, evolve during the frame as we cross frozen rows boundaries
	ImRect bg0ClipRectForDrawCmd = ImRect(0f, 0f, 0f, 0f);      // Actual ImDrawCmd clip rect for BG0/1 channel. This tends to be == OuterWindow->ClipRect at BeginTable() because output in BG0/BG1 is cpu-clipped
	ImRect bg2ClipRectForDrawCmd = ImRect(0f, 0f, 0f, 0f);      // Actual ImDrawCmd clip rect for BG2 channel. This tends to be a correct, tight-fit, because output to BG2 are done by widgets relying on regular ClipRect.
	ImRect hostClipRect = ImRect(0f, 0f, 0f, 0f);               // This is used to check if we can eventually merge our columns draw calls into the current draw call of the current window.
	ImRect hostBackupInnerClipRect = ImRect(0f, 0f, 0f, 0f);    // Backup of InnerWindow->ClipRect during PushTableBackground()/PopTableBackground()
	ImGuiWindow* outerWindow = null;                // Parent window for the table
	ImGuiWindow* innerWindow = null;                // Window holding the table data (== OuterWindow or a child window)
	ImGuiTextBuffer columnsNames;               // Contiguous buffer holding columns names
	ImDrawListSplitter* drawSplitter = null;               // Shortcut to TempData->DrawSplitter while in table. Isolate draw commands per columns to avoid switching clip rect constantly
	ImGuiTableInstanceData instanceDataFirst;
	ImVector!ImGuiTableInstanceData instanceDataExtra;  // FIXME-OPT: Using a small-vector pattern would be good.
	ImGuiTableColumnSortSpecs sortSpecsSingle;
	ImVector!ImGuiTableColumnSortSpecs sortSpecsMulti;     // FIXME-OPT: Using a small-vector pattern would be good.
	ImGuiTableSortSpecs sortSpecs;                  // Public facing sorts specs, this is what we return in TableGetSortSpecs()
	ImGuiTableColumnIdx sortSpecsCount = 0;
	ImGuiTableColumnIdx columnsEnabledCount = 0;        // Number of enabled columns (<= ColumnsCount)
	ImGuiTableColumnIdx columnsEnabledFixedCount = 0;   // Number of enabled columns (<= ColumnsCount)
	ImGuiTableColumnIdx declColumnsCount = 0;           // Count calls to TableSetupColumn()
	ImGuiTableColumnIdx angledHeadersCount = 0;         // Count columns with angled headers
	ImGuiTableColumnIdx hoveredColumnBody = 0;          // Index of column whose visible region is being hovered. Important: == ColumnsCount when hovering empty region after the right-most column!
	ImGuiTableColumnIdx hoveredColumnBorder = 0;        // Index of column whose right-border is being hovered (for resizing).
	ImGuiTableColumnIdx highlightColumnHeader = 0;      // Index of column which should be highlighted.
	ImGuiTableColumnIdx autoFitSingleColumn = 0;        // Index of single column requesting auto-fit.
	ImGuiTableColumnIdx resizedColumn = 0;              // Index of column being resized. Reset when InstanceCurrent==0.
	ImGuiTableColumnIdx lastResizedColumn = 0;          // Index of column being resized from previous frame.
	ImGuiTableColumnIdx heldHeaderColumn = 0;           // Index of column header being held.
	ImGuiTableColumnIdx reorderColumn = 0;              // Index of column being reordered. (not cleared)
	ImGuiTableColumnIdx reorderColumnDir = 0;           // -1 or +1
	ImGuiTableColumnIdx leftMostEnabledColumn = 0;      // Index of left-most non-hidden column.
	ImGuiTableColumnIdx rightMostEnabledColumn = 0;     // Index of right-most non-hidden column.
	ImGuiTableColumnIdx leftMostStretchedColumn = 0;    // Index of left-most stretched column.
	ImGuiTableColumnIdx rightMostStretchedColumn = 0;   // Index of right-most stretched column.
	ImGuiTableColumnIdx contextPopupColumn = 0;         // Column right-clicked on, of -1 if opening context menu from a neutral/empty spot
	ImGuiTableColumnIdx freezeRowsRequest = 0;          // Requested frozen rows count
	ImGuiTableColumnIdx freezeRowsCount = 0;            // Actual frozen row count (== FreezeRowsRequest, or == 0 when no scrolling offset)
	ImGuiTableColumnIdx freezeColumnsRequest = 0;       // Requested frozen columns count
	ImGuiTableColumnIdx freezeColumnsCount = 0;         // Actual frozen columns count (== FreezeColumnsRequest, or == 0 when no scrolling offset)
	ImGuiTableColumnIdx rowCellDataCurrent = 0;         // Index of current RowCellData[] entry in current row
	ImGuiTableDrawChannelIdx dummyDrawChannel = 0;           // Redirect non-visible columns here.
	ImGuiTableDrawChannelIdx bg2DrawChannelCurrent = 0;      // For Selectable() and other widgets drawing across columns after the freezing line. Index within DrawSplitter.Channels[]
	ImGuiTableDrawChannelIdx bg2DrawChannelUnfrozen = 0;
	bool isLayoutLocked = false;             // Set by TableUpdateLayout() which is called when beginning the first row.
	bool isInsideRow = false;                // Set when inside TableBeginRow()/TableEndRow().
	bool isInitializing = false;
	alias isInitialising = isInitializing;
	bool isSortSpecsDirty = false;
	bool isUsingHeaders = false;             // Set when the first row had the ImGuiTableRowFlags_Headers flag.
	bool isContextPopupOpen = false;         // Set when default context menu is open (also see: ContextPopupColumn, InstanceInteracted).
	bool disableDefaultContextMenu = false;  // Disable default context menu contents. You may submit your own using TableBeginContextMenuPopup()/EndPopup()
	bool isSettingsRequestLoad = false;
	bool isSettingsDirty = false;            // Set when table settings have changed and needs to be reported into ImGuiTableSetttings data.
	bool isDefaultDisplayOrder = false;      // Set when display order is unchanged from default (DisplayOrder contains 0...Count-1)
	bool isResetAllRequest = false;
	bool isResetDisplayOrderRequest = false;
	bool isUnfrozenRows = false;             // Set when we got past the frozen row.
	bool isDefaultSizingPolicy = false;      // Set if user didn't explicitly set a sizing policy in BeginTable()
	bool isActiveIdAliveBeforeTable = false;
	bool isActiveIdInTable = false;
	bool hasScrollbarYCurr = false;          // Whether ANY instance of this table had a vertical scrollbar during the current frame.
	bool hasScrollbarYPrev = false;          // Whether ANY instance of this table had a vertical scrollbar during the previous.
	bool memoryCompacted = false;
	bool hostSkipItems = false;              // Backup of InnerWindow->SkipItem at the end of BeginTable(), because we will overwrite InnerWindow->SkipItem on a per-column basis
	
	~this(){ IM_FREE(rawData); }
}
static assert(ImGuiTable.sizeof == 580);

extern(C++) struct IMGUI_API ImGuiTableTempData{
	int tableIndex = 0;                 // Index in g.Tables.Buf[] pool
	float lastTimeActive = -1f;             // Last timestamp this structure was used
	float angledheadersExtraWidth = 0f;    // Used in EndTable()
	
	ImVec2 userOuterSize = ImRect(0f, 0f, 0f, 0f);              // outer_size.x passed to BeginTable()
	ImDrawListSplitter drawSplitter;
	
	ImRect hostBackupWorkRect = ImRect(0f, 0f, 0f, 0f);         // Backup of InnerWindow->WorkRect at the end of BeginTable()
	ImRect hostBackupParentWorkRect = ImRect(0f, 0f, 0f, 0f);   // Backup of InnerWindow->ParentWorkRect at the end of BeginTable()
	ImVec2 hostBackupPrevLineSize = ImVec2(0f, 0f);     // Backup of InnerWindow->DC.PrevLineSize at the end of BeginTable()
	ImVec2 hostBackupCurrLineSize = ImVec2(0f, 0f);     // Backup of InnerWindow->DC.CurrLineSize at the end of BeginTable()
	ImVec2 hostBackupCursorMaxPos = ImVec2(0f, 0f);     // Backup of InnerWindow->DC.CursorMaxPos at the end of BeginTable()
	ImVec1 hostBackupColumnsOffset = ImVec1(0f);    // Backup of OuterWindow->DC.ColumnsOffset at the end of BeginTable()
	float hostBackupItemWidth = 0f;        // Backup of OuterWindow->DC.ItemWidth at the end of BeginTable()
	int hostBackupItemWidthStackSize = 0;//Backup of OuterWindow->DC.ItemWidthStack.Size at the end of BeginTable()
}
static assert(ImGuiTableTempData.sizeof == 120);

extern(C++) struct ImGuiTableColumnSettings{
	float widthOrWeight = 0f;
	ImGuiID userID = 0;
	ImGuiTableColumnIdx index = -1;
	ImGuiTableColumnIdx displayOrder = -1;
	ImGuiTableColumnIdx sortOrder = -1;
	ubyte sortDirection : 2 = ImGuiSortDirection.none;
	ubyte isEnabled : 1 = true; // "Visible" in ini file
	ubyte isStretch : 1 = false;
}
static assert(ImGuiTableColumnSettings.sizeof == 12);

extern(C++) struct ImGuiTableSettings{
	ImGuiID id = 0;                     // Set to 0 to invalidate/delete the setting
	ImGuiTableFlags saveFlags = 0;              // Indicate data we want to save using the Resizable/Reorderable/Sortable/Hideable flags (could be using its own flags..)
	float refScale = 0f;               // Reference scale to be able to rescale columns on font/dpi changes.
	ImGuiTableColumnIdx columnsCount = 0;
	ImGuiTableColumnIdx columnsCountMax = 0;        // Maximum number of columns this settings instance can store, we can recycle a settings instance with lower number of columns but not higher
	bool wantApply = false;              // Set when loaded from .ini data (to enable merging/loading .ini data into an already running context)
	
	nothrow @nogc:
	ImGuiTableColumnSettings* getColumnSettings() const pure @safe => cast(ImGuiTableColumnSettings*)(&this + 1);
}

nothrow @nogc{
	auto IM_BITARRAY_TESTBIT(A)(A array, size_t n) pure @safe => (array[n >> 5] & (cast(uint)1 << (n & 31))) != 0;
	auto IM_BITARRAY_CLEARBIT(A)(A array, size_t n) pure @safe{ array[n >> 5] &= ~(cast(uint)1 << (n & 31)); }
	size_t ImBitArrayGetStorageSizeInBytes(int bitcount) pure @safe => cast(size_t)((bitcount + 31) >> 5) << 2;
	void ImBitArrayClearAllBits(uint* arr, int bitcount){ memset(arr, 0, ImBitArrayGetStorageSizeInBytes(bitcount)); }
	bool ImBitArrayTestBit(const(uint)* arr, int n) pure @safe => (arr[n >> 5] & (cast(uint)1 << (n & 31))) != 0;
	void ImBitArrayClearBit(uint* arr, int n) pure @safe{ arr[n >> 5] &= ~(cast(uint)1 << (n & 31)); }
	void ImBitArraySetBit(uint* arr, int n) pure @safe{ arr[n >> 5] |= (cast(uint)1 << (n & 31)); }
	void ImBitArraySetBitRange(uint* arr, int n, int n2) pure @safe{
		n2--;
		while(n <= n2){
			int aMod = n & 31;
			int bMod = (n2 > (n | 31) ? 31 : (n2 & 31)) + 1;
			uint mask = cast(uint)((cast(ulong)1 << bMod) - 1) & ~(uint)((cast(ulong)1 << aMod) - 1);
			arr[n >> 5] |= mask;
			n = (n + 32) & ~31;
		}
	}
	
	float ImTriangleArea(ImVec2 a, ImVec2 b, ImVec2 c) pure @safe => fabsf((a.x * (b.y - c.y)) + (b.x * (c.y - a.y)) + (c.x * (a.y - b.y))) * 0.5f;
	
	ImGuiWindow* GetCurrentWindowRead() @safe => gImGui.currentWindow;
	ImGuiWindow* GetCurrentWindow() @safe{ gImGui.currentWindow.writeAccessed = true; return gImGui.currentWindow; }
	ImRect WindowRectAbsToRel(ImGuiWindow* window, ImRect r) pure @safe{
		ImVec2 off = window.dc.cursorStartPos;
		return ImRect(r.min.x - off.x, r.min.y - off.y, r.max.x - off.x, r.max.y - off.y);
	}
	ImRect WindowRectRelToAbs(ImGuiWindow* window, ImRect r) pure @safe{
		ImVec2 off = window.dc.cursorStartPos;
		return ImRect(r.min.x + off.x, r.min.y + off.y, r.max.x + off.x, r.max.y + off.y);
	}
	ImVec2 WindowPosRelToAbs(ImGuiWindow* window, ImVec2 p) pure @safe{
		ImVec2 off = window.dc.cursorStartPos;
		return ImVec2(p.x + off.x, p.y + off.y);
	}
	
	ImFont* GetDefaultFont() @safe => gImGui.io.fontDefault ? gImGui.io.fontDefault : gImGui.io.fonts.fonts[0];
	ImDrawList* GetForegroundDrawList(ImGuiWindow* window) @safe pure => GetForegroundDrawList(window.viewport);
	const(char)* LocalizeGetMsg(ImGuiLocKey key) @safe => gImGui.LocalizationTable[key] ? gImGui.LocalizationTable[key] : "*Missing Text*";
	alias LocaliseGetMsg = LocalizeGetMsg;
	void ScrollToBringRectIntoView(ImGuiWindow* window, ImRect rect) @safe{ ScrollToRect(window, rect, ImGuiScrollFlags.KeepVisibleEdgeY); }
	ImGuiItemStatusFlags GetItemStatusFlags() @safe => gImGui.lastItemData.statusFlags;
	ImGuiItemFlags GetItemFlags() @safe => gImGui.lastItemData.inFlags;
	ImGuiID GetActiveID() @safe => gImGui.ActiveID;
	ImGuiID GetFocusID() @safe => gImGui.NavID;
	void ItemSize(ImRect bb, float textBaselineY=-1f) pure @safe{ ItemSize(bb.getSize(), textBaselineY); }
	bool IsNamedKey(ImGuiKey key) pure @safe => key >= ImGuiKey.namedKey_BEGIN && key < ImGuiKey.namedKey_END;
	bool IsNamedKeyOrModKey(ImGuiKey key) pure @safe =>
		(key >= ImGuiKey.namedKey_BEGIN && key < ImGuiKey.namedKey_END) ||
		key == ImGuiMod.ctrl || key == ImGuiMod.shift || key == ImGuiMod.alt || key == ImGuiMod.super || key == ImGuiMod.shortcut;
	bool IsLegacyKey(ImGuiKey key) pure @safe => key >= ImGuiKey.legacyNativeKey_BEGIN && key < ImGuiKey.legacyNativeKey_END;
	bool IsKeyboardKey(ImGuiKey key) pure @safe => key >= ImGuiKey.keyboard_BEGIN && key < ImGuiKey.keyboard_END;
	bool IsGamepadKey(ImGuiKey key) pure @safe => key >= ImGuiKey.gamepad_BEGIN && key < ImGuiKey.gamepad_END;
	bool IsMouseKey(ImGuiKey key) pure @safe => key >= ImGuiKey.mouse_BEGIN && key < ImGuiKey.mouse_END;
	bool IsAliasKey(ImGuiKey key) pure @safe => key >= ImGuiKey.aliases_BEGIN && key < ImGuiKey.aliases_END;
	ImGuiKeyChord ConvertShortcutMod(ImGuiKeyChord keyChord) @safe in(keyChord & ImGuiMod.shortcut) =>
		(keyChord & ~ImGuiMod.shortcut) | (gImGui.io.configMacOSXBehaviors ? ImGuiMod.super : ImGuiMod.ctrl);
	ImGuiKey ConvertSingleModFlagToKey(ImGuiContext* ctx, ImGuiKey key){
		switch(key){
			case ImGuiMod.ctrl: return ImGuiKey_ReservedForModCtrl;
			case ImGuiMod.shift: return ImGuiKey_ReservedForModShift;
			case ImGuiMod.alt: return ImGuiKey_ReservedForModAlt;
			case ImGuiMod.super: return ImGuiKey_ReservedForModSuper;
			case ImGuiMod.shortcut: return ctx.io.configMacOSXBehaviors ? ImGuiKey.reservedForModSuper : ImGuiKey.reservedForModCtrl;
			default: return key;
		}
	}
	ImGuiKeyData* GetKeyData(ImGuiKey key) => GetKeyData(&gImGui, key);
	ImGuiKey MouseButtonToKey(ImGuiMouseButton button) pure @safe in(button >= 0 && button < ImGuiMouseButton.COUNT) =>
		cast(ImGuiKey)(ImGuiKey.mouseLeft + button);
	bool IsActiveIdUsingNavDir(ImGuiDir dir) @safe => (gImGui.activeIDUsingNavDirMask & (1 << dir)) != 0;
	ImGuiKeyOwnerData* GetKeyOwnerData(ImGuiContext* ctx, ImGuiKey key){
		if(key & ImGuiMod.mask_) key = ConvertSingleModFlagToKey(ctx, key);
		assert(IsNamedKey(key));
		return &ctx.keysOwnerData[key - ImGuiKey.namedKey_BEGIN];
	}
	ImGuiDockNode* DockNodeGetRootNode(ImGuiDockNode* node) pure @safe{
		while(node.parentNode) node = node.parentNode;
		return node;
	}
	bool DockNodeIsInHierarchyOf(ImGuiDockNode* node, ImGuiDockNode* parent) pure @safe{
		while(node){
			if(node == parent) return true;
			node = node.parentNode;
		}
		return false;
	}
	int DockNodeGetDepth(const(ImGuiDockNode)* node) pure @safe{
		int depth = 0;
		while(node.parentNode){
			node = node.parentNode;
			depth++;
		}
		return depth;
	}
	ImGuiID DockNodeGetWindowMenuButtonID(const(ImGuiDockNode)* node) => ImHashStr("#COLLAPSE", 0, node.id);
	ImGuiDockNode* GetWindowDockNode() @safe => gImGui.currentWindow.dockNode;
	ImGuiDockNode* DockBuilderGetCentralNode(ImGuiID nodeID){
		ImGuiDockNode* node = DockBuilderGetNode(nodeID);
		if(!node) return null;
		return DockNodeGetRootNode(node).centralNode;
	}
	ImGuiID GetCurrentFocusScope() @safe => gImGui.CurrentFocusScopeID;
	ImGuiTable* GetCurrentTable() @safe => gImGui.CurrentTable;
	ImGuiTableInstanceData* TableGetInstanceData(ImGuiTable* table, int instanceNo) pure @safe{
		if(instance_no == 0) return &table.instanceDataFirst;
		return &table.instanceDataExtra[instanceNo - 1];
	}
	ImGuiID TableGetInstanceID(ImGuiTable* table, int instanceNo) pure @safe => TableGetInstanceData(table, instanceNo).tableInstanceID;
	ImGuiTabBar* GetCurrentTabBar() pure @safe => gImGui.currentTabBar;
	int TabBarGetTabOrder(ImGuiTabBar* tabBar, ImGuiTabItem* tab) pure @safe => tabBar.tabs.indexFromPtr(tab);
	bool TempInputIsActive(ImGuiID id) @safe => gImGui.activeID == id && gImGui.tempInputID == id;
	ImGuiInputTextState* GetInputTextState(ImGuiID id) @safe => (id != 0 && gImGui.inputTextState.id == id) ? &gImGui.inputTextState : null;
	void DebugStartItemPicker() @safe{ gImGui.debugItemPickerActive = true; }
}

mixin(joinFnBinds((){
	FnBind[] ret = [
IMGUI_API ImGuiID       ImHashData(const(void)* data, size_t dataSize, ImGuiID seed=0);
IMGUI_API ImGuiID       ImHashStr(const(char)* data, size_t dataSize=0, ImGuiID seed=0);

IMGUI_API uint         ImAlphaBlendColors(uint colA, uint colB);

IMGUI_API int           ImStricmp(const(char)* str1, const(char)* str2);                      // Case insensitive compare.
IMGUI_API int           ImStrnicmp(const(char)* str1, const(char)* str2, size_t count);       // Case insensitive compare to a certain count.
IMGUI_API void          ImStrncpy(char* dst, const(char)* src, size_t count);                // Copy to a certain count and always zero terminate (strncpy doesn't).
IMGUI_API char*         ImStrdup(const(char)* str);                                          // Duplicate a string.
IMGUI_API char*         ImStrdupcpy(char* dst, size_t* pDstSize, const(char)* str);        // Copy in provided buffer, recreate buffer if needed.
IMGUI_API const(char)*   ImStrchrRange(const(char)* strBegin, const(char)* strEnd, char c);  // Find first occurrence of 'c' in string range.
IMGUI_API const(char)*   ImStreolRange(const(char)* str, const(char)* strEnd);                // End end-of-line
IMGUI_API const(char)*   ImStristr(const(char)* haystack, const(char)* haystackEnd, const(char)* needle, const(char)* needleEnd);  // Find a substring in a string range.
IMGUI_API void          ImStrTrimBlanks(char* str);                                         // Remove leading and trailing blanks from a buffer.
IMGUI_API const(char)*   ImStrSkipBlank(const(char)* str);                                    // Find first non-blank character.
IMGUI_API int           ImStrlenW(const(ImWchar)* str);                                      // Computer string length (ImWchar string)
IMGUI_API const(ImWchar)   *ImStrbolW(const(ImWchar)* bufMidLine, const(ImWchar)* bufBegin);   // Find beginning-of-line (ImWchar string)

IMGUI_API int            ImFormatString(char* buf, size_t bufSize, const(char)* fmt, ...) IM_FMTARGS(3);
IMGUI_API int            ImFormatStringV(char* buf, size_t bufSize, const(char)* fmt, va_list args) IM_FMTLIST(3);
IMGUI_API void           ImFormatStringToTempBuffer(const(char)** outBuf, const(char)** outBufEnd, const(char)* fmt, ...) IM_FMTARGS(3);
IMGUI_API void           ImFormatStringToTempBufferV(const(char)** outBuf, const(char)** outBufEnd, const(char)* fmt, va_list args) IM_FMTLIST(3);
IMGUI_API const(char)*   ImParseFormatFindStart(const(char)* format);
IMGUI_API const(char)*   ImParseFormatFindEnd(const(char)* format);
IMGUI_API const(char)*   ImParseFormatTrimDecorations(const(char)* format, char* buf, size_t bufSize);
IMGUI_API void           ImParseFormatSanitizeForPrinting(const(char)* fmtIn, char* fmtOut, size_t fmtOutSize);
IMGUI_API const(char)*   ImParseFormatSanitizeForScanning(const(char)* fmtIn, char* fmtOut, size_t fmtOutSize);
IMGUI_API int            ImParseFormatPrecision(const(char)* format, int defaultValue);

IMGUI_API const(char)*  ImTextCharToUtf8(char[5] outBuf, uint c);                                                      // return out_buf
IMGUI_API int           ImTextStrToUtf8(char* out_buf, int outBufSize, const(ImWchar)* in_text, const(ImWchar)* inTextEnd);   // return output UTF-8 bytes count
IMGUI_API int           ImTextCharFromUtf8(uint* outChar, const(char)* inText, const(char)* inTextEnd);               // read one character. return input UTF-8 bytes count
IMGUI_API int           ImTextStrFromUtf8(ImWchar* outBuf, int outBufSize, const(char)* inText, const(char)* inTextEnd, const(char)** inRemaining=null);   // return input UTF-8 bytes count
IMGUI_API int           ImTextCountCharsFromUtf8(const(char)* inText, const(char)* inTextEnd);                                 // return number of UTF-8 code-points (NOT bytes count)
IMGUI_API int           ImTextCountUtf8BytesFromChar(const(char)* inText, const(char)* inTextEnd);                             // return number of bytes to express one char in UTF-8
IMGUI_API int           ImTextCountUtf8BytesFromStr(const(ImWchar)* inText, const(ImWchar)* inTextEnd);                        // return number of bytes to express string in UTF-8
IMGUI_API const(char)*   ImTextFindPreviousUtf8Codepoint(const(char)* inTextStart, const(char)* inTextCurr);                   // return previous UTF-8 code-point.

IMGUI_API void*      ImFileLoadToMemory(const(char)* filename, const(char)* mode, size_t* outFileSize=null, int paddingBytes=0);

IMGUI_API ImVec2     ImBezierCubicCalc(in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, float t);
IMGUI_API ImVec2     ImBezierCubicClosestPoint(in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, in ImVec2 p, int numSegments);       // For curves with explicit number of segments
IMGUI_API ImVec2     ImBezierCubicClosestPointCasteljau(in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, in ImVec2 p4, in ImVec2 p, float tessTol);// For auto-tessellated curves you can use tess_tol = style.CurveTessellationTol
IMGUI_API ImVec2     ImBezierQuadraticCalc(in ImVec2 p1, in ImVec2 p2, in ImVec2 p3, float t);
IMGUI_API ImVec2     ImLineClosestPoint(in ImVec2 a, in ImVec2 b, in ImVec2 p);
IMGUI_API bool       ImTriangleContainsPoint(in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 p);
IMGUI_API ImVec2     ImTriangleClosestPoint(in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 p);
IMGUI_API void       ImTriangleBarycentricCoords(in ImVec2 a, in ImVec2 b, in ImVec2 c, in ImVec2 p, ref float outU, ref float outV, ref float koutW);

namespace ImGui{
	IMGUI_API ImGuiWindow*  FindWindowByID(ImGuiID id);
	IMGUI_API ImGuiWindow*  FindWindowByName(const(char)* name);
	IMGUI_API void          UpdateWindowParentAndRootLinks(ImGuiWindow* window, ImGuiWindowFlags flags, ImGuiWindow* parent_window);
	IMGUI_API ImVec2        CalcWindowNextAutoFitSize(ImGuiWindow* window);
	IMGUI_API bool          IsWindowChildOf(ImGuiWindow* window, ImGuiWindow* potential_parent, bool popup_hierarchy, bool dock_hierarchy);
	IMGUI_API bool          IsWindowWithinBeginStackOf(ImGuiWindow* window, ImGuiWindow* potential_parent);
	IMGUI_API bool          IsWindowAbove(ImGuiWindow* potential_above, ImGuiWindow* potential_below);
	IMGUI_API bool          IsWindowNavFocusable(ImGuiWindow* window);
	IMGUI_API void          SetWindowPos(ImGuiWindow* window, const ImVec2& pos, ImGuiCond cond = 0);
	IMGUI_API void          SetWindowSize(ImGuiWindow* window, const ImVec2& size, ImGuiCond cond = 0);
	IMGUI_API void          SetWindowCollapsed(ImGuiWindow* window, bool collapsed, ImGuiCond cond = 0);
	IMGUI_API void          SetWindowHitTestHole(ImGuiWindow* window, const ImVec2& pos, const ImVec2& size);
	IMGUI_API void          SetWindowHiddendAndSkipItemsForCurrentFrame(ImGuiWindow* window);

	// Windows: Display Order and Focus Order
	IMGUI_API void          FocusWindow(ImGuiWindow* window, ImGuiFocusRequestFlags flags = 0);
	IMGUI_API void          FocusTopMostWindowUnderOne(ImGuiWindow* under_this_window, ImGuiWindow* ignore_window, ImGuiViewport* filter_viewport, ImGuiFocusRequestFlags flags);
	IMGUI_API void          BringWindowToFocusFront(ImGuiWindow* window);
	IMGUI_API void          BringWindowToDisplayFront(ImGuiWindow* window);
	IMGUI_API void          BringWindowToDisplayBack(ImGuiWindow* window);
	IMGUI_API void          BringWindowToDisplayBehind(ImGuiWindow* window, ImGuiWindow* above_window);
	IMGUI_API int           FindWindowDisplayIndex(ImGuiWindow* window);
	IMGUI_API ImGuiWindow*  FindBottomMostVisibleWindowWithinBeginStack(ImGuiWindow* window);

	// Fonts, drawing
	IMGUI_API void          SetCurrentFont(ImFont* font);
	IMGUI_API void          AddDrawListToDrawDataEx(ImDrawData* draw_data, ImVector<ImDrawList*>* out_list, ImDrawList* draw_list);

	// Init
	IMGUI_API void          Initialize();
	IMGUI_API void          Shutdown();    // Since 1.60 this is a _private_ function. You can call DestroyContext() to destroy the context created by CreateContext().

	// NewFrame
	IMGUI_API void          UpdateInputEvents(bool trickle_fast_inputs);
	IMGUI_API void          UpdateHoveredWindowAndCaptureFlags();
	IMGUI_API void          StartMouseMovingWindow(ImGuiWindow* window);
	IMGUI_API void          StartMouseMovingWindowOrNode(ImGuiWindow* window, ImGuiDockNode* node, bool undock);
	IMGUI_API void          UpdateMouseMovingWindowNewFrame();
	IMGUI_API void          UpdateMouseMovingWindowEndFrame();

	// Generic context hooks
	IMGUI_API ImGuiID       AddContextHook(ImGuiContext* context, const(ImGuiContextHook)* hook);
	IMGUI_API void          RemoveContextHook(ImGuiContext* context, ImGuiID hook_to_remove);
	IMGUI_API void          CallContextHooks(ImGuiContext* context, ImGuiContextHookType type);

	// Viewports
	IMGUI_API void          TranslateWindowsInViewport(ImGuiViewportP* viewport, const ImVec2& old_pos, const ImVec2& new_pos);
	IMGUI_API void          ScaleWindowsInViewport(ImGuiViewportP* viewport, float scale);
	IMGUI_API void          DestroyPlatformWindow(ImGuiViewportP* viewport);
	IMGUI_API void          SetWindowViewport(ImGuiWindow* window, ImGuiViewportP* viewport);
	IMGUI_API void          SetCurrentViewport(ImGuiWindow* window, ImGuiViewportP* viewport);
	IMGUI_API const(ImGuiPlatformMonitor)*   GetViewportPlatformMonitor(ImGuiViewport* viewport);
	IMGUI_API ImGuiViewportP*               FindHoveredViewportFromPlatformWindowStack(const ImVec2& mouse_platform_pos);

	// Settings
	IMGUI_API void                  MarkIniSettingsDirty();
	IMGUI_API void                  MarkIniSettingsDirty(ImGuiWindow* window);
	IMGUI_API void                  ClearIniSettings();
	IMGUI_API void                  AddSettingsHandler(const(ImGuiSettingsHandler)* handler);
	IMGUI_API void                  RemoveSettingsHandler(const(char)* type_name);
	IMGUI_API ImGuiSettingsHandler* FindSettingsHandler(const(char)* type_name);

	// Settings - Windows
	IMGUI_API ImGuiWindowSettings*  CreateNewWindowSettings(const(char)* name);
	IMGUI_API ImGuiWindowSettings*  FindWindowSettingsByID(ImGuiID id);
	IMGUI_API ImGuiWindowSettings*  FindWindowSettingsByWindow(ImGuiWindow* window);
	IMGUI_API void                  ClearWindowSettings(const(char)* name);

	// Localization
	IMGUI_API void          LocalizeRegisterEntries(const(ImGuiLocEntry)* entries, int count);

	// Scrolling
	IMGUI_API void          SetScrollX(ImGuiWindow* window, float scroll_x);
	IMGUI_API void          SetScrollY(ImGuiWindow* window, float scroll_y);
	IMGUI_API void          SetScrollFromPosX(ImGuiWindow* window, float local_x, float center_x_ratio);
	IMGUI_API void          SetScrollFromPosY(ImGuiWindow* window, float local_y, float center_y_ratio);

	// Early work-in-progress API (ScrollToItem() will become public)
	IMGUI_API void          ScrollToItem(ImGuiScrollFlags flags = 0);
	IMGUI_API void          ScrollToRect(ImGuiWindow* window, const ImRect& rect, ImGuiScrollFlags flags = 0);
	IMGUI_API ImVec2        ScrollToRectEx(ImGuiWindow* window, const ImRect& rect, ImGuiScrollFlags flags = 0);
//#ifndef IMGUI_DISABLE_OBSOLETE_FUNCTIONS
//#endif

	// Basic Accessors
	IMGUI_API void          SetActiveID(ImGuiID id, ImGuiWindow* window);
	IMGUI_API void          SetFocusID(ImGuiID id, ImGuiWindow* window);
	IMGUI_API void          ClearActiveID();
	IMGUI_API ImGuiID       GetHoveredID();
	IMGUI_API void          SetHoveredID(ImGuiID id);
	IMGUI_API void          KeepAliveID(ImGuiID id);
	IMGUI_API void          MarkItemEdited(ImGuiID id);     // Mark data associated to given item as "edited", used by IsItemDeactivatedAfterEdit() function.
	IMGUI_API void          PushOverrideID(ImGuiID id);     // Push given value as-is at the top of the ID stack (whereas PushID combines old and new hashes)
	IMGUI_API ImGuiID       GetIDWithSeed(const(char)* str_id_begin, const(char)* str_id_end, ImGuiID seed);
	IMGUI_API ImGuiID       GetIDWithSeed(int n, ImGuiID seed);

	// Basic Helpers for widget code
	IMGUI_API void          ItemSize(const ImVec2& size, float text_baseline_y = -1.0f);
	IMGUI_API bool          ItemAdd(const ImRect& bb, ImGuiID id, const(ImRect)* nav_bb = NULL, ImGuiItemFlags extra_flags = 0);
	IMGUI_API bool          ItemHoverable(const ImRect& bb, ImGuiID id, ImGuiItemFlags item_flags);
	IMGUI_API bool          IsWindowContentHoverable(ImGuiWindow* window, ImGuiHoveredFlags flags = 0);
	IMGUI_API bool          IsClippedEx(const ImRect& bb, ImGuiID id);
	IMGUI_API void          SetLastItemData(ImGuiID item_id, ImGuiItemFlags in_flags, ImGuiItemStatusFlags status_flags, const ImRect& item_rect);
	IMGUI_API ImVec2        CalcItemSize(ImVec2 size, float default_w, float default_h);
	IMGUI_API float         CalcWrapWidthForPos(const ImVec2& pos, float wrap_pos_x);
	IMGUI_API void          PushMultiItemsWidths(int components, float width_full);
	IMGUI_API bool          IsItemToggledSelection();                                   // Was the last item selection toggled? (after Selectable(), TreeNode() etc. We only returns toggle _event_ in order to handle clipping correctly)
	IMGUI_API ImVec2        GetContentRegionMaxAbs();
	IMGUI_API void          ShrinkWidths(ImGuiShrinkWidthItem* items, int count, float width_excess);

	// Parameter stacks (shared)
	IMGUI_API void          PushItemFlag(ImGuiItemFlags option, bool enabled);
	IMGUI_API void          PopItemFlag();
	IMGUI_API const(ImGuiDataVarInfo)* GetStyleVarInfo(ImGuiStyleVar idx);

	// Logging/Capture
	IMGUI_API void          LogBegin(ImGuiLogType type, int auto_open_depth);           // -> BeginCapture() when we design v2 api, for now stay under the radar by using the old name.
	IMGUI_API void          LogToBuffer(int auto_open_depth = -1);                      // Start logging/capturing to internal buffer
	IMGUI_API void          LogRenderedText(const(ImVec2)* ref_pos, const(char)* text, const(char)* text_end = NULL);
	IMGUI_API void          LogSetNextTextDecoration(const(char)* prefix, const(char)* suffix);

	// Popups, Modals, Tooltips
	IMGUI_API bool          BeginChildEx(const(char)* name, ImGuiID id, const ImVec2& size_arg, ImGuiChildFlags child_flags, ImGuiWindowFlags window_flags);
	IMGUI_API void          OpenPopupEx(ImGuiID id, ImGuiPopupFlags popup_flags = ImGuiPopupFlags_None);
	IMGUI_API void          ClosePopupToLevel(int remaining, bool restore_focus_to_window_under_popup);
	IMGUI_API void          ClosePopupsOverWindow(ImGuiWindow* ref_window, bool restore_focus_to_window_under_popup);
	IMGUI_API void          ClosePopupsExceptModals();
	IMGUI_API bool          IsPopupOpen(ImGuiID id, ImGuiPopupFlags popup_flags);
	IMGUI_API bool          BeginPopupEx(ImGuiID id, ImGuiWindowFlags extra_flags);
	IMGUI_API bool          BeginTooltipEx(ImGuiTooltipFlags tooltip_flags, ImGuiWindowFlags extra_window_flags);
	IMGUI_API bool          BeginTooltipHidden();
	IMGUI_API ImRect        GetPopupAllowedExtentRect(ImGuiWindow* window);
	IMGUI_API ImGuiWindow*  GetTopMostPopupModal();
	IMGUI_API ImGuiWindow*  GetTopMostAndVisiblePopupModal();
	IMGUI_API ImGuiWindow*  FindBlockingModal(ImGuiWindow* window);
	IMGUI_API ImVec2        FindBestWindowPosForPopup(ImGuiWindow* window);
	IMGUI_API ImVec2        FindBestWindowPosForPopupEx(const ImVec2& ref_pos, const ImVec2& size, ImGuiDir* last_dir, const ImRect& r_outer, const ImRect& r_avoid, ImGuiPopupPositionPolicy policy);

	// Menus
	IMGUI_API bool          BeginViewportSideBar(const(char)* name, ImGuiViewport* viewport, ImGuiDir dir, float size, ImGuiWindowFlags window_flags);
	IMGUI_API bool          BeginMenuEx(const(char)* label, const(char)* icon, bool enabled = true);
	IMGUI_API bool          MenuItemEx(const(char)* label, const(char)* icon, const(char)* shortcut = NULL, bool selected = false, bool enabled = true);

	// Combos
	IMGUI_API bool          BeginComboPopup(ImGuiID popup_id, const ImRect& bb, ImGuiComboFlags flags);
	IMGUI_API bool          BeginComboPreview();
	IMGUI_API void          EndComboPreview();

	// Gamepad/Keyboard Navigation
	IMGUI_API void          NavInitWindow(ImGuiWindow* window, bool force_reinit);
	IMGUI_API void          NavInitRequestApplyResult();
	IMGUI_API bool          NavMoveRequestButNoResultYet();
	IMGUI_API void          NavMoveRequestSubmit(ImGuiDir move_dir, ImGuiDir clip_dir, ImGuiNavMoveFlags move_flags, ImGuiScrollFlags scroll_flags);
	IMGUI_API void          NavMoveRequestForward(ImGuiDir move_dir, ImGuiDir clip_dir, ImGuiNavMoveFlags move_flags, ImGuiScrollFlags scroll_flags);
	IMGUI_API void          NavMoveRequestResolveWithLastItem(ImGuiNavItemData* result);
	IMGUI_API void          NavMoveRequestResolveWithPastTreeNode(ImGuiNavItemData* result, ImGuiNavTreeNodeData* tree_node_data);
	IMGUI_API void          NavMoveRequestCancel();
	IMGUI_API void          NavMoveRequestApplyResult();
	IMGUI_API void          NavMoveRequestTryWrapping(ImGuiWindow* window, ImGuiNavMoveFlags move_flags);
	IMGUI_API void          NavClearPreferredPosForAxis(ImGuiAxis axis);
	IMGUI_API void          NavRestoreHighlightAfterMove();
	IMGUI_API void          NavUpdateCurrentWindowIsScrollPushableX();
	IMGUI_API void          SetNavWindow(ImGuiWindow* window);
	IMGUI_API void          SetNavID(ImGuiID id, ImGuiNavLayer nav_layer, ImGuiID focus_scope_id, const ImRect& rect_rel);

	// Focus/Activation
	// This should be part of a larger set of API: FocusItem(offset = -1), FocusItemByID(id), ActivateItem(offset = -1), ActivateItemByID(id) etc. which are
	// much harder to design and implement than expected. I have a couple of private branches on this matter but it's not simple. For now implementing the easy ones.
	IMGUI_API void          FocusItem();                    // Focus last item (no selection/activation).
	IMGUI_API void          ActivateItemByID(ImGuiID id);   // Activate an item by ID (button, checkbox, tree node etc.). Activation is queued and processed on the next frame when the item is encountered again.

	// Inputs
	// FIXME: Eventually we should aim to move e.g. IsActiveIdUsingKey() into IsKeyXXX functions.

	IMGUI_API ImGuiKeyData* GetKeyData(ImGuiContext* ctx, ImGuiKey key);
	IMGUI_API void          GetKeyChordName(ImGuiKeyChord key_chord, char* out_buf, int out_buf_size);
	IMGUI_API bool          IsMouseDragPastThreshold(ImGuiMouseButton button, float lock_threshold = -1.0f);
	IMGUI_API ImVec2        GetKeyMagnitude2d(ImGuiKey key_left, ImGuiKey key_right, ImGuiKey key_up, ImGuiKey key_down);
	IMGUI_API float         GetNavTweakPressedAmount(ImGuiAxis axis);
	IMGUI_API int           CalcTypematicRepeatAmount(float t0, float t1, float repeat_delay, float repeat_rate);
	IMGUI_API void          GetTypematicRepeatRate(ImGuiInputFlags flags, float* repeat_delay, float* repeat_rate);
	IMGUI_API void          TeleportMousePos(const ImVec2& pos);
	IMGUI_API void          SetActiveIdUsingAllKeyboardKeys();

	// [EXPERIMENTAL] Low-Level: Key/Input Ownership
	// - The idea is that instead of "eating" a given input, we can link to an owner id.
	// - Ownership is most often claimed as a result of reacting to a press/down event (but occasionally may be claimed ahead).
	// - Input queries can then read input by specifying ImGuiKeyOwner_Any (== 0), ImGuiKeyOwner_None (== -1) or a custom ID.
	// - Legacy input queries (without specifying an owner or _Any or _None) are equivalent to using ImGuiKeyOwner_Any (== 0).
	// - Input ownership is automatically released on the frame after a key is released. Therefore:
	//   - for ownership registration happening as a result of a down/press event, the SetKeyOwner() call may be done once (common case).
	//   - for ownership registration happening ahead of a down/press event, the SetKeyOwner() call needs to be made every frame (happens if e.g. claiming ownership on hover).
	// - SetItemKeyOwner() is a shortcut for common simple case. A custom widget will probably want to call SetKeyOwner() multiple times directly based on its interaction state.
	// - This is marked experimental because not all widgets are fully honoring the Set/Test idioms. We will need to move forward step by step.
	//   Please open a GitHub Issue to submit your usage scenario or if there's a use case you need solved.
	IMGUI_API ImGuiID           GetKeyOwner(ImGuiKey key);
	IMGUI_API void              SetKeyOwner(ImGuiKey key, ImGuiID owner_id, ImGuiInputFlags flags = 0);
	IMGUI_API void              SetKeyOwnersForKeyChord(ImGuiKeyChord key, ImGuiID owner_id, ImGuiInputFlags flags = 0);
	IMGUI_API void              SetItemKeyOwner(ImGuiKey key, ImGuiInputFlags flags = 0);           // Set key owner to last item if it is hovered or active. Equivalent to 'if (IsItemHovered() || IsItemActive()) { SetKeyOwner(key, GetItemID());'.
	IMGUI_API bool              TestKeyOwner(ImGuiKey key, ImGuiID owner_id);                       // Test that key is either not owned, either owned by 'owner_id'

	// [EXPERIMENTAL] High-Level: Input Access functions w/ support for Key/Input Ownership
	// - Important: legacy IsKeyPressed(ImGuiKey, bool repeat=true) _DEFAULTS_ to repeat, new IsKeyPressed() requires _EXPLICIT_ ImGuiInputFlags_Repeat flag.
	// - Expected to be later promoted to public API, the prototypes are designed to replace existing ones (since owner_id can default to Any == 0)
	// - Specifying a value for 'ImGuiID owner' will test that EITHER the key is NOT owned (UNLESS locked), EITHER the key is owned by 'owner'.
	//   Legacy functions use ImGuiKeyOwner_Any meaning that they typically ignore ownership, unless a call to SetKeyOwner() explicitly used ImGuiInputFlags_LockThisFrame or ImGuiInputFlags_LockUntilRelease.
	// - Binding generators may want to ignore those for now, or suffix them with Ex() until we decide if this gets moved into public API.
	IMGUI_API bool              IsKeyDown(ImGuiKey key, ImGuiID owner_id);
	IMGUI_API bool              IsKeyPressed(ImGuiKey key, ImGuiID owner_id, ImGuiInputFlags flags = 0);    // Important: when transitioning from old to new IsKeyPressed(): old API has "bool repeat = true", so would default to repeat. New API requiress explicit ImGuiInputFlags_Repeat.
	IMGUI_API bool              IsKeyReleased(ImGuiKey key, ImGuiID owner_id);
	IMGUI_API bool              IsMouseDown(ImGuiMouseButton button, ImGuiID owner_id);
	IMGUI_API bool              IsMouseClicked(ImGuiMouseButton button, ImGuiID owner_id, ImGuiInputFlags flags = 0);
	IMGUI_API bool              IsMouseReleased(ImGuiMouseButton button, ImGuiID owner_id);
	IMGUI_API bool              IsMouseDoubleClicked(ImGuiMouseButton button, ImGuiID owner_id);

	// [EXPERIMENTAL] Shortcut Routing
	// - ImGuiKeyChord = a ImGuiKey optionally OR-red with ImGuiMod_Alt/ImGuiMod_Ctrl/ImGuiMod_Shift/ImGuiMod_Super.
	//     ImGuiKey_C                 (accepted by functions taking ImGuiKey or ImGuiKeyChord)
	//     ImGuiKey_C | ImGuiMod_Ctrl (accepted by functions taking ImGuiKeyChord)
	//   ONLY ImGuiMod_XXX values are legal to 'OR' with an ImGuiKey. You CANNOT 'OR' two ImGuiKey values.
	// - When using one of the routing flags (e.g. ImGuiInputFlags_RouteFocused): routes requested ahead of time given a chord (key + modifiers) and a routing policy.
	// - Routes are resolved during NewFrame(): if keyboard modifiers are matching current ones: SetKeyOwner() is called + route is granted for the frame.
	// - Route is granted to a single owner. When multiple requests are made we have policies to select the winning route.
	// - Multiple read sites may use the same owner id and will all get the granted route.
	// - For routing: when owner_id is 0 we use the current Focus Scope ID as a default owner in order to identify our location.
	// - TL;DR;
	//   - IsKeyChordPressed() compares mods + call IsKeyPressed() -> function has no side-effect.
	//   - Shortcut() submits a route then if currently can be routed calls IsKeyChordPressed() -> function has (desirable) side-effects.
	IMGUI_API bool              IsKeyChordPressed(ImGuiKeyChord key_chord, ImGuiID owner_id, ImGuiInputFlags flags = 0);
	IMGUI_API bool              Shortcut(ImGuiKeyChord key_chord, ImGuiID owner_id = 0, ImGuiInputFlags flags = 0);
	IMGUI_API bool              SetShortcutRouting(ImGuiKeyChord key_chord, ImGuiID owner_id = 0, ImGuiInputFlags flags = 0);
	IMGUI_API bool              TestShortcutRouting(ImGuiKeyChord key_chord, ImGuiID owner_id);
	IMGUI_API ImGuiKeyRoutingData* GetShortcutRoutingData(ImGuiKeyChord key_chord);

	// Docking
	// (some functions are only declared in imgui.cpp, see Docking section)
	IMGUI_API void          DockContextInitialize(ImGuiContext* ctx);
	IMGUI_API void          DockContextShutdown(ImGuiContext* ctx);
	IMGUI_API void          DockContextClearNodes(ImGuiContext* ctx, ImGuiID root_id, bool clear_settings_refs); // Use root_id==0 to clear all
	IMGUI_API void          DockContextRebuildNodes(ImGuiContext* ctx);
	IMGUI_API void          DockContextNewFrameUpdateUndocking(ImGuiContext* ctx);
	IMGUI_API void          DockContextNewFrameUpdateDocking(ImGuiContext* ctx);
	IMGUI_API void          DockContextEndFrame(ImGuiContext* ctx);
	IMGUI_API ImGuiID       DockContextGenNodeID(ImGuiContext* ctx);
	IMGUI_API void          DockContextQueueDock(ImGuiContext* ctx, ImGuiWindow* target, ImGuiDockNode* target_node, ImGuiWindow* payload, ImGuiDir split_dir, float split_ratio, bool split_outer);
	IMGUI_API void          DockContextQueueUndockWindow(ImGuiContext* ctx, ImGuiWindow* window);
	IMGUI_API void          DockContextQueueUndockNode(ImGuiContext* ctx, ImGuiDockNode* node);
	IMGUI_API void          DockContextProcessUndockWindow(ImGuiContext* ctx, ImGuiWindow* window, bool clear_persistent_docking_ref = true);
	IMGUI_API void          DockContextProcessUndockNode(ImGuiContext* ctx, ImGuiDockNode* node);
	IMGUI_API bool          DockContextCalcDropPosForDocking(ImGuiWindow* target, ImGuiDockNode* target_node, ImGuiWindow* payload_window, ImGuiDockNode* payload_node, ImGuiDir split_dir, bool split_outer, ImVec2* out_pos);
	IMGUI_API ImGuiDockNode*DockContextFindNodeByID(ImGuiContext* ctx, ImGuiID id);
	IMGUI_API void          DockNodeWindowMenuHandler_Default(ImGuiContext* ctx, ImGuiDockNode* node, ImGuiTabBar* tab_bar);
	IMGUI_API bool          DockNodeBeginAmendTabBar(ImGuiDockNode* node);
	IMGUI_API void          DockNodeEndAmendTabBar();
	IMGUI_API bool          GetWindowAlwaysWantOwnTabBar(ImGuiWindow* window);
	IMGUI_API void          BeginDocked(ImGuiWindow* window, bool* p_open);
	IMGUI_API void          BeginDockableDragDropSource(ImGuiWindow* window);
	IMGUI_API void          BeginDockableDragDropTarget(ImGuiWindow* window);
	IMGUI_API void          SetWindowDock(ImGuiWindow* window, ImGuiID dock_id, ImGuiCond cond);

	// Docking - Builder function needs to be generally called before the node is used/submitted.
	// - The DockBuilderXXX functions are designed to _eventually_ become a public API, but it is too early to expose it and guarantee stability.
	// - Do not hold on ImGuiDockNode* pointers! They may be invalidated by any split/merge/remove operation and every frame.
	// - To create a DockSpace() node, make sure to set the ImGuiDockNodeFlags_DockSpace flag when calling DockBuilderAddNode().
	//   You can create dockspace nodes (attached to a window) _or_ floating nodes (carry its own window) with this API.
	// - DockBuilderSplitNode() create 2 child nodes within 1 node. The initial node becomes a parent node.
	// - If you intend to split the node immediately after creation using DockBuilderSplitNode(), make sure
	//   to call DockBuilderSetNodeSize() beforehand. If you don't, the resulting split sizes may not be reliable.
	// - Call DockBuilderFinish() after you are done.
	IMGUI_API void          DockBuilderDockWindow(const(char)* window_name, ImGuiID node_id);
	IMGUI_API ImGuiDockNode*DockBuilderGetNode(ImGuiID node_id);
	IMGUI_API ImGuiID       DockBuilderAddNode(ImGuiID node_id = 0, ImGuiDockNodeFlags flags = 0);
	IMGUI_API void          DockBuilderRemoveNode(ImGuiID node_id);                 // Remove node and all its child, undock all windows
	IMGUI_API void          DockBuilderRemoveNodeDockedWindows(ImGuiID node_id, bool clear_settings_refs = true);
	IMGUI_API void          DockBuilderRemoveNodeChildNodes(ImGuiID node_id);       // Remove all split/hierarchy. All remaining docked windows will be re-docked to the remaining root node (node_id).
	IMGUI_API void          DockBuilderSetNodePos(ImGuiID node_id, ImVec2 pos);
	IMGUI_API void          DockBuilderSetNodeSize(ImGuiID node_id, ImVec2 size);
	IMGUI_API ImGuiID       DockBuilderSplitNode(ImGuiID node_id, ImGuiDir split_dir, float size_ratio_for_node_at_dir, ImGuiID* out_id_at_dir, ImGuiID* out_id_at_opposite_dir); // Create 2 child nodes in this parent node.
	IMGUI_API void          DockBuilderCopyDockSpace(ImGuiID src_dockspace_id, ImGuiID dst_dockspace_id, ImVector<const(char)*>* in_window_remap_pairs);
	IMGUI_API void          DockBuilderCopyNode(ImGuiID src_node_id, ImGuiID dst_node_id, ImVector<ImGuiID>* out_node_remap_pairs);
	IMGUI_API void          DockBuilderCopyWindowSettings(const(char)* src_name, const(char)* dst_name);
	IMGUI_API void          DockBuilderFinish(ImGuiID node_id);

	// [EXPERIMENTAL] Focus Scope
	// This is generally used to identify a unique input location (for e.g. a selection set)
	// There is one per window (automatically set in Begin), but:
	// - Selection patterns generally need to react (e.g. clear a selection) when landing on one item of the set.
	//   So in order to identify a set multiple lists in same window may each need a focus scope.
	//   If you imagine an hypothetical BeginSelectionGroup()/EndSelectionGroup() api, it would likely call PushFocusScope()/EndFocusScope()
	// - Shortcut routing also use focus scope as a default location identifier if an owner is not provided.
	// We don't use the ID Stack for this as it is common to want them separate.
	IMGUI_API void          PushFocusScope(ImGuiID id);
	IMGUI_API void          PopFocusScope();

	// Drag and Drop
	IMGUI_API bool          IsDragDropActive();
	IMGUI_API bool          BeginDragDropTargetCustom(const ImRect& bb, ImGuiID id);
	IMGUI_API void          ClearDragDrop();
	IMGUI_API bool          IsDragDropPayloadBeingAccepted();
	IMGUI_API void          RenderDragDropTargetRect(const ImRect& bb);

	// Typing-Select API
	IMGUI_API ImGuiTypingSelectRequest* GetTypingSelectRequest(ImGuiTypingSelectFlags flags = ImGuiTypingSelectFlags_None);
	IMGUI_API int           TypingSelectFindMatch(ImGuiTypingSelectRequest* req, int items_count, const(char)* (*get_item_name_func)(void*, int), void* user_data, int nav_item_idx);
	IMGUI_API int           TypingSelectFindNextSingleCharMatch(ImGuiTypingSelectRequest* req, int items_count, const(char)* (*get_item_name_func)(void*, int), void* user_data, int nav_item_idx);
	IMGUI_API int           TypingSelectFindBestLeadingMatch(ImGuiTypingSelectRequest* req, int items_count, const(char)* (*get_item_name_func)(void*, int), void* user_data);

	// Internal Columns API (this is not exposed because we will encourage transitioning to the Tables API)
	IMGUI_API void          SetWindowClipRectBeforeSetChannel(ImGuiWindow* window, const ImRect& clip_rect);
	IMGUI_API void          BeginColumns(const(char)* str_id, int count, ImGuiOldColumnFlags flags = 0); // setup number of columns. use an identifier to distinguish multiple column sets. close with EndColumns().
	IMGUI_API void          EndColumns();                                                               // close columns
	IMGUI_API void          PushColumnClipRect(int column_index);
	IMGUI_API void          PushColumnsBackground();
	IMGUI_API void          PopColumnsBackground();
	IMGUI_API ImGuiID       GetColumnsID(const(char)* str_id, int count);
	IMGUI_API ImGuiOldColumns* FindOrCreateColumns(ImGuiWindow* window, ImGuiID id);
	IMGUI_API float         GetColumnOffsetFromNorm(const(ImGuiOldColumns)* columns, float offset_norm);
	IMGUI_API float         GetColumnNormFromOffset(const(ImGuiOldColumns)* columns, float offset);

	// Tables: Candidates for public API
	IMGUI_API void          TableOpenContextMenu(int column_n = -1);
	IMGUI_API void          TableSetColumnWidth(int column_n, float width);
	IMGUI_API void          TableSetColumnSortDirection(int column_n, ImGuiSortDirection sort_direction, bool append_to_sort_specs);
	IMGUI_API int           TableGetHoveredColumn();    // May use (TableGetColumnFlags() & ImGuiTableColumnFlags_IsHovered) instead. Return hovered column. return -1 when table is not hovered. return columns_count if the unused space at the right of visible columns is hovered.
	IMGUI_API int           TableGetHoveredRow();       // Retrieve *PREVIOUS FRAME* hovered row. This difference with TableGetHoveredColumn() is the reason why this is not public yet.
	IMGUI_API float         TableGetHeaderRowHeight();
	IMGUI_API float         TableGetHeaderAngledMaxLabelWidth();
	IMGUI_API void          TablePushBackgroundChannel();
	IMGUI_API void          TablePopBackgroundChannel();
	IMGUI_API void          TableAngledHeadersRowEx(float angle, float label_width = 0.0f);

	// Tables: Internals
	IMGUI_API ImGuiTable*   TableFindByID(ImGuiID id);
	IMGUI_API bool          BeginTableEx(const(char)* name, ImGuiID id, int columns_count, ImGuiTableFlags flags = 0, const ImVec2& outer_size = ImVec2(0, 0), float inner_width = 0.0f);
	IMGUI_API void          TableBeginInitMemory(ImGuiTable* table, int columns_count);
	IMGUI_API void          TableBeginApplyRequests(ImGuiTable* table);
	IMGUI_API void          TableSetupDrawChannels(ImGuiTable* table);
	IMGUI_API void          TableUpdateLayout(ImGuiTable* table);
	IMGUI_API void          TableUpdateBorders(ImGuiTable* table);
	IMGUI_API void          TableUpdateColumnsWeightFromWidth(ImGuiTable* table);
	IMGUI_API void          TableDrawBorders(ImGuiTable* table);
	IMGUI_API void          TableDrawDefaultContextMenu(ImGuiTable* table, ImGuiTableFlags flags_for_section_to_display);
	IMGUI_API bool          TableBeginContextMenuPopup(ImGuiTable* table);
	IMGUI_API void          TableMergeDrawChannels(ImGuiTable* table);
	IMGUI_API void          TableSortSpecsSanitize(ImGuiTable* table);
	IMGUI_API void          TableSortSpecsBuild(ImGuiTable* table);
	IMGUI_API ImGuiSortDirection TableGetColumnNextSortDirection(ImGuiTableColumn* column);
	IMGUI_API void          TableFixColumnSortDirection(ImGuiTable* table, ImGuiTableColumn* column);
	IMGUI_API float         TableGetColumnWidthAuto(ImGuiTable* table, ImGuiTableColumn* column);
	IMGUI_API void          TableBeginRow(ImGuiTable* table);
	IMGUI_API void          TableEndRow(ImGuiTable* table);
	IMGUI_API void          TableBeginCell(ImGuiTable* table, int column_n);
	IMGUI_API void          TableEndCell(ImGuiTable* table);
	IMGUI_API ImRect        TableGetCellBgRect(const(ImGuiTable)* table, int column_n);
	IMGUI_API const(char)*   TableGetColumnName(const(ImGuiTable)* table, int column_n);
	IMGUI_API ImGuiID       TableGetColumnResizeID(ImGuiTable* table, int column_n, int instance_no = 0);
	IMGUI_API float         TableGetMaxColumnWidth(const(ImGuiTable)* table, int column_n);
	IMGUI_API void          TableSetColumnWidthAutoSingle(ImGuiTable* table, int column_n);
	IMGUI_API void          TableSetColumnWidthAutoAll(ImGuiTable* table);
	IMGUI_API void          TableRemove(ImGuiTable* table);
	IMGUI_API void          TableGcCompactTransientBuffers(ImGuiTable* table);
	IMGUI_API void          TableGcCompactTransientBuffers(ImGuiTableTempData* table);
	IMGUI_API void          TableGcCompactSettings();

	// Tables: Settings
	IMGUI_API void                  TableLoadSettings(ImGuiTable* table);
	IMGUI_API void                  TableSaveSettings(ImGuiTable* table);
	IMGUI_API void                  TableResetSettings(ImGuiTable* table);
	IMGUI_API ImGuiTableSettings*   TableGetBoundSettings(ImGuiTable* table);
	IMGUI_API void                  TableSettingsAddSettingsHandler();
	IMGUI_API ImGuiTableSettings*   TableSettingsCreate(ImGuiID id, int columns_count);
	IMGUI_API ImGuiTableSettings*   TableSettingsFindByID(ImGuiID id);

	// Tab Bars
	IMGUI_API bool          BeginTabBarEx(ImGuiTabBar* tab_bar, const ImRect& bb, ImGuiTabBarFlags flags);
	IMGUI_API ImGuiTabItem* TabBarFindTabByID(ImGuiTabBar* tab_bar, ImGuiID tab_id);
	IMGUI_API ImGuiTabItem* TabBarFindTabByOrder(ImGuiTabBar* tab_bar, int order);
	IMGUI_API ImGuiTabItem* TabBarFindMostRecentlySelectedTabForActiveWindow(ImGuiTabBar* tab_bar);
	IMGUI_API ImGuiTabItem* TabBarGetCurrentTab(ImGuiTabBar* tab_bar);
	IMGUI_API const(char)*   TabBarGetTabName(ImGuiTabBar* tab_bar, ImGuiTabItem* tab);
	IMGUI_API void          TabBarAddTab(ImGuiTabBar* tab_bar, ImGuiTabItemFlags tab_flags, ImGuiWindow* window);
	IMGUI_API void          TabBarRemoveTab(ImGuiTabBar* tab_bar, ImGuiID tab_id);
	IMGUI_API void          TabBarCloseTab(ImGuiTabBar* tab_bar, ImGuiTabItem* tab);
	IMGUI_API void          TabBarQueueFocus(ImGuiTabBar* tab_bar, ImGuiTabItem* tab);
	IMGUI_API void          TabBarQueueReorder(ImGuiTabBar* tab_bar, ImGuiTabItem* tab, int offset);
	IMGUI_API void          TabBarQueueReorderFromMousePos(ImGuiTabBar* tab_bar, ImGuiTabItem* tab, ImVec2 mouse_pos);
	IMGUI_API bool          TabBarProcessReorder(ImGuiTabBar* tab_bar);
	IMGUI_API bool          TabItemEx(ImGuiTabBar* tab_bar, const(char)* label, bool* p_open, ImGuiTabItemFlags flags, ImGuiWindow* docked_window);
	IMGUI_API ImVec2        TabItemCalcSize(const(char)* label, bool has_close_button_or_unsaved_marker);
	IMGUI_API ImVec2        TabItemCalcSize(ImGuiWindow* window);
	IMGUI_API void          TabItemBackground(ImDrawList* draw_list, const ImRect& bb, ImGuiTabItemFlags flags, uint col);
	IMGUI_API void          TabItemLabelAndCloseButton(ImDrawList* draw_list, const ImRect& bb, ImGuiTabItemFlags flags, ImVec2 frame_padding, const(char)* label, ImGuiID tab_id, ImGuiID close_button_id, bool is_contents_visible, bool* out_just_closed, bool* out_text_clipped);

	// Render helpers
	// AVOID USING OUTSIDE OF IMGUI.CPP! NOT FOR PUBLIC CONSUMPTION. THOSE FUNCTIONS ARE A MESS. THEIR SIGNATURE AND BEHAVIOR WILL CHANGE, THEY NEED TO BE REFACTORED INTO SOMETHING DECENT.
	// NB: All position are in absolute pixels coordinates (we are never using window coordinates internally)
	IMGUI_API void          RenderText(ImVec2 pos, const(char)* text, const(char)* text_end = NULL, bool hide_text_after_hash = true);
	IMGUI_API void          RenderTextWrapped(ImVec2 pos, const(char)* text, const(char)* text_end, float wrap_width);
	IMGUI_API void          RenderTextClipped(const ImVec2& pos_min, const ImVec2& pos_max, const(char)* text, const(char)* text_end, const(ImVec2)* text_size_if_known, const ImVec2& align = ImVec2(0, 0), const(ImRect)* clip_rect = NULL);
	IMGUI_API void          RenderTextClippedEx(ImDrawList* draw_list, const ImVec2& pos_min, const ImVec2& pos_max, const(char)* text, const(char)* text_end, const(ImVec2)* text_size_if_known, const ImVec2& align = ImVec2(0, 0), const(ImRect)* clip_rect = NULL);
	IMGUI_API void          RenderTextEllipsis(ImDrawList* draw_list, const ImVec2& pos_min, const ImVec2& pos_max, float clip_max_x, float ellipsis_max_x, const(char)* text, const(char)* text_end, const(ImVec2)* text_size_if_known);
	IMGUI_API void          RenderFrame(ImVec2 p_min, ImVec2 p_max, uint fill_col, bool border = true, float rounding = 0.0f);
	IMGUI_API void          RenderFrameBorder(ImVec2 p_min, ImVec2 p_max, float rounding = 0.0f);
	IMGUI_API void          RenderColorRectWithAlphaCheckerboard(ImDrawList* draw_list, ImVec2 p_min, ImVec2 p_max, uint fill_col, float grid_step, ImVec2 grid_off, float rounding = 0.0f, ImDrawFlags flags = 0);
	IMGUI_API void          RenderNavHighlight(const ImRect& bb, ImGuiID id, ImGuiNavHighlightFlags flags = ImGuiNavHighlightFlags_TypeDefault); // Navigation highlight
	IMGUI_API const(char)*   FindRenderedTextEnd(const(char)* text, const(char)* text_end = NULL); // Find the optional ## from which we stop displaying text.
	IMGUI_API void          RenderMouseCursor(ImVec2 pos, float scale, ImGuiMouseCursor mouse_cursor, uint col_fill, uint col_border, uint col_shadow);

	// Render helpers (those functions don't access any ImGui state!)
	IMGUI_API void          RenderArrow(ImDrawList* draw_list, ImVec2 pos, uint col, ImGuiDir dir, float scale = 1.0f);
	IMGUI_API void          RenderBullet(ImDrawList* draw_list, ImVec2 pos, uint col);
	IMGUI_API void          RenderCheckMark(ImDrawList* draw_list, ImVec2 pos, uint col, float sz);
	IMGUI_API void          RenderArrowPointingAt(ImDrawList* draw_list, ImVec2 pos, ImVec2 half_sz, ImGuiDir direction, uint col);
	IMGUI_API void          RenderArrowDockMenu(ImDrawList* draw_list, ImVec2 p_min, float sz, uint col);
	IMGUI_API void          RenderRectFilledRangeH(ImDrawList* draw_list, const ImRect& rect, uint col, float x_start_norm, float x_end_norm, float rounding);
	IMGUI_API void          RenderRectFilledWithHole(ImDrawList* draw_list, const ImRect& outer, const ImRect& inner, uint col, float rounding);
	IMGUI_API ImDrawFlags   CalcRoundingFlagsForRectInRect(const ImRect& r_in, const ImRect& r_outer, float threshold);

	// Widgets
	IMGUI_API void          TextEx(const(char)* text, const(char)* text_end = NULL, ImGuiTextFlags flags = 0);
	IMGUI_API bool          ButtonEx(const(char)* label, const ImVec2& size_arg = ImVec2(0, 0), ImGuiButtonFlags flags = 0);
	IMGUI_API bool          ArrowButtonEx(const(char)* str_id, ImGuiDir dir, ImVec2 size_arg, ImGuiButtonFlags flags = 0);
	IMGUI_API bool          ImageButtonEx(ImGuiID id, ImTextureID texture_id, const ImVec2& image_size, const ImVec2& uv0, const ImVec2& uv1, const ImVec4& bg_col, const ImVec4& tint_col, ImGuiButtonFlags flags = 0);
	IMGUI_API void          SeparatorEx(ImGuiSeparatorFlags flags, float thickness = 1.0f);
	IMGUI_API void          SeparatorTextEx(ImGuiID id, const(char)* label, const(char)* label_end, float extra_width);
	IMGUI_API bool          CheckboxFlags(const(char)* label, long* flags, long flags_value);
	IMGUI_API bool          CheckboxFlags(const(char)* label, ulong* flags, ulong flags_value);

	// Widgets: Window Decorations
	IMGUI_API bool          CloseButton(ImGuiID id, const ImVec2& pos);
	IMGUI_API bool          CollapseButton(ImGuiID id, const ImVec2& pos, ImGuiDockNode* dock_node);
	IMGUI_API void          Scrollbar(ImGuiAxis axis);
	IMGUI_API bool          ScrollbarEx(const ImRect& bb, ImGuiID id, ImGuiAxis axis, long* p_scroll_v, long avail_v, long contents_v, ImDrawFlags flags);
	IMGUI_API ImRect        GetWindowScrollbarRect(ImGuiWindow* window, ImGuiAxis axis);
	IMGUI_API ImGuiID       GetWindowScrollbarID(ImGuiWindow* window, ImGuiAxis axis);
	IMGUI_API ImGuiID       GetWindowResizeCornerID(ImGuiWindow* window, int n); // 0..3: corners
	IMGUI_API ImGuiID       GetWindowResizeBorderID(ImGuiWindow* window, ImGuiDir dir);

	// Widgets low-level behaviors
	IMGUI_API bool          ButtonBehavior(const ImRect& bb, ImGuiID id, bool* out_hovered, bool* out_held, ImGuiButtonFlags flags = 0);
	IMGUI_API bool          DragBehavior(ImGuiID id, ImGuiDataType data_type, void* p_v, float v_speed, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags);
	IMGUI_API bool          SliderBehavior(const ImRect& bb, ImGuiID id, ImGuiDataType data_type, void* p_v, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags, ImRect* out_grab_bb);
	IMGUI_API bool          SplitterBehavior(const ImRect& bb, ImGuiID id, ImGuiAxis axis, float* size1, float* size2, float min_size1, float min_size2, float hover_extend = 0.0f, float hover_visibility_delay = 0.0f, uint bg_col = 0);
	IMGUI_API bool          TreeNodeBehavior(ImGuiID id, ImGuiTreeNodeFlags flags, const(char)* label, const(char)* label_end = NULL);
	IMGUI_API void          TreePushOverrideID(ImGuiID id);
	IMGUI_API void          TreeNodeSetOpen(ImGuiID id, bool open);
	IMGUI_API bool          TreeNodeUpdateNextOpen(ImGuiID id, ImGuiTreeNodeFlags flags);   // Return open state. Consume previous SetNextItemOpen() data, if any. May return true when logging.
	IMGUI_API void          SetNextItemSelectionUserData(ImGuiSelectionUserData selection_user_data);

	// Template functions are instantiated in imgui_widgets.cpp for a finite number of types.
	// To use them externally (for custom widget) you may need an "extern template" statement in your code in order to link to existing instances and silence Clang warnings (see #2036).
	// e.g. " extern template IMGUI_API float RoundScalarWithFormatT<float, float>(const(char)* format, ImGuiDataType data_type, float v); "
	template<typename T, typename SIGNED_T, typename FLOAT_T>   IMGUI_API float ScaleRatioFromValueT(ImGuiDataType data_type, T v, T v_min, T v_max, bool is_logarithmic, float logarithmic_zero_epsilon, float zero_deadzone_size);
	template<typename T, typename SIGNED_T, typename FLOAT_T>   IMGUI_API T     ScaleValueFromRatioT(ImGuiDataType data_type, float t, T v_min, T v_max, bool is_logarithmic, float logarithmic_zero_epsilon, float zero_deadzone_size);
	template<typename T, typename SIGNED_T, typename FLOAT_T>   IMGUI_API bool  DragBehaviorT(ImGuiDataType data_type, T* v, float v_speed, T v_min, T v_max, const(char)* format, ImGuiSliderFlags flags);
	template<typename T, typename SIGNED_T, typename FLOAT_T>   IMGUI_API bool  SliderBehaviorT(const ImRect& bb, ImGuiID id, ImGuiDataType data_type, T* v, T v_min, T v_max, const(char)* format, ImGuiSliderFlags flags, ImRect* out_grab_bb);
	template<typename T>                                        IMGUI_API T     RoundScalarWithFormatT(const(char)* format, ImGuiDataType data_type, T v);
	template<typename T>                                        IMGUI_API bool  CheckboxFlagsT(const(char)* label, T* flags, T flags_value);

	// Data type helpers
	IMGUI_API const(ImGuiDataTypeInfo)*  DataTypeGetInfo(ImGuiDataType data_type);
	IMGUI_API int           DataTypeFormatString(char* buf, int buf_size, ImGuiDataType data_type, const(void)* p_data, const(char)* format);
	IMGUI_API void          DataTypeApplyOp(ImGuiDataType data_type, int op, void* output, const(void)* arg_1, const(void)* arg_2);
	IMGUI_API bool          DataTypeApplyFromText(const(char)* buf, ImGuiDataType data_type, void* p_data, const(char)* format);
	IMGUI_API int           DataTypeCompare(ImGuiDataType data_type, const(void)* arg_1, const(void)* arg_2);
	IMGUI_API bool          DataTypeClamp(ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max);

	// InputText
	IMGUI_API bool          InputTextEx(const(char)* label, const(char)* hint, char* buf, int buf_size, const ImVec2& size_arg, ImGuiInputTextFlags flags, ImGuiInputTextCallback callback = NULL, void* user_data = NULL);
	IMGUI_API void          InputTextDeactivateHook(ImGuiID id);
	IMGUI_API bool          TempInputText(const ImRect& bb, ImGuiID id, const(char)* label, char* buf, int buf_size, ImGuiInputTextFlags flags);
	IMGUI_API bool          TempInputScalar(const ImRect& bb, ImGuiID id, const(char)* label, ImGuiDataType data_type, void* p_data, const(char)* format, const(void)* p_clamp_min = NULL, const(void)* p_clamp_max = NULL);

	// Color
	IMGUI_API void          ColorTooltip(const(char)* text, const(float)* col, ImGuiColorEditFlags flags);
	IMGUI_API void          ColorEditOptionsPopup(const(float)* col, ImGuiColorEditFlags flags);
	IMGUI_API void          ColorPickerOptionsPopup(const(float)* ref_col, ImGuiColorEditFlags flags);

	// Plot
	IMGUI_API int           PlotEx(ImGuiPlotType plot_type, const(char)* label, float (*values_getter)(void* data, int idx), void* data, int values_count, int values_offset, const(char)* overlay_text, float scale_min, float scale_max, const ImVec2& size_arg);

	// Shade functions (write over already created vertices)
	IMGUI_API void          ShadeVertsLinearColorGradientKeepAlpha(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, ImVec2 gradient_p0, ImVec2 gradient_p1, uint col0, uint col1);
	IMGUI_API void          ShadeVertsLinearUV(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, const ImVec2& a, const ImVec2& b, const ImVec2& uv_a, const ImVec2& uv_b, bool clamp);
	IMGUI_API void          ShadeVertsTransformPos(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, const ImVec2& pivot_in, float cos_a, float sin_a, const ImVec2& pivot_out);

	// Garbage collection
	IMGUI_API void          GcCompactTransientMiscBuffers();
	IMGUI_API void          GcCompactTransientWindowBuffers(ImGuiWindow* window);
	IMGUI_API void          GcAwakeTransientWindowBuffers(ImGuiWindow* window);

	// Debug Log
	IMGUI_API void          DebugLog(const(char)* fmt, ...) IM_FMTARGS(1);
	IMGUI_API void          DebugLogV(const(char)* fmt, va_list args) IM_FMTLIST(1);
	IMGUI_API void          DebugAllocHook(ImGuiDebugAllocInfo* info, int frame_count, void* ptr, size_t size); // size >= 0 : alloc, size = -1 : free

	// Debug Tools
	IMGUI_API void          ErrorCheckEndFrameRecover(ImGuiErrorLogCallback logCallback, void* userData=null);
	IMGUI_API void          ErrorCheckEndWindowRecover(ImGuiErrorLogCallback logCallback, void* userData=null);
	IMGUI_API void          ErrorCheckUsingSetCursorPosToExtendParentBoundaries();
	IMGUI_API void          DebugDrawCursorPos(uint col = IM_COL32(255, 0, 0, 255));
	IMGUI_API void          DebugDrawLineExtents(uint col = IM_COL32(255, 0, 0, 255));
	IMGUI_API void          DebugDrawItemRect(uint col = IM_COL32(255, 0, 0, 255));
	IMGUI_API void          DebugLocateItem(ImGuiID target_id);                     // Call sparingly: only 1 at the same time!
	IMGUI_API void          DebugLocateItemOnHover(ImGuiID target_id);              // Only call on reaction to a mouse Hover: because only 1 at the same time!
	IMGUI_API void          DebugLocateItemResolveWithLastItem();
	IMGUI_API void          ShowFontAtlas(ImFontAtlas* atlas);
	IMGUI_API void          DebugHookIdInfo(ImGuiID id, ImGuiDataType data_type, const(void)* data_id, const(void)* data_id_end);
	IMGUI_API void          DebugNodeColumns(ImGuiOldColumns* columns);
	IMGUI_API void          DebugNodeDockNode(ImGuiDockNode* node, const(char)* label);
	IMGUI_API void          DebugNodeDrawList(ImGuiWindow* window, ImGuiViewportP* viewport, const(ImDrawList)* draw_list, const(char)* label);
	IMGUI_API void          DebugNodeDrawCmdShowMeshAndBoundingBox(ImDrawList* out_draw_list, const(ImDrawList)* draw_list, const(ImDrawCmd)* draw_cmd, bool show_mesh, bool show_aabb);
	IMGUI_API void          DebugNodeFont(ImFont* font);
	IMGUI_API void          DebugNodeFontGlyph(ImFont* font, const(ImFontGlyph)* glyph);
	IMGUI_API void          DebugNodeStorage(ImGuiStorage* storage, const(char)* label);
	IMGUI_API void          DebugNodeTabBar(ImGuiTabBar* tab_bar, const(char)* label);
	IMGUI_API void          DebugNodeTable(ImGuiTable* table);
	IMGUI_API void          DebugNodeTableSettings(ImGuiTableSettings* settings);
	IMGUI_API void          DebugNodeInputTextState(ImGuiInputTextState* state);
	IMGUI_API void          DebugNodeTypingSelectState(ImGuiTypingSelectState* state);
	IMGUI_API void          DebugNodeWindow(ImGuiWindow* window, const(char)* label);
	IMGUI_API void          DebugNodeWindowSettings(ImGuiWindowSettings* settings);
	IMGUI_API void          DebugNodeWindowsList(ImVector<ImGuiWindow*>* windows, const(char)* label);
	IMGUI_API void          DebugNodeWindowsListByBeginStackParent(ImGuiWindow** windows, int windows_size, ImGuiWindow* parent_in_begin_stack);
	IMGUI_API void          DebugNodeViewport(ImGuiViewportP* viewport);
	IMGUI_API void          DebugRenderKeyboardPreview(ImDrawList* draw_list);
	IMGUI_API void          DebugRenderViewportThumbnail(ImDrawList* draw_list, ImGuiViewportP* viewport, const ImRect& bb);


}
	];
	version(ImGui_DisableObsoleteFunctions){
	}else{
		FnBind[] add = [
		];
		ret ~= add;
	}
	return ret;
}(), "));

//-----------------------------------------------------------------------------
// [SECTION] ImFontAtlas internal API
//-----------------------------------------------------------------------------

// This structure is likely to evolve as we add support for incremental atlas updates
struct ImFontBuilderIO
{
	bool    (*FontBuilder_Build)(ImFontAtlas* atlas);
};

// Helper for font builder
#ifdef IMGUI_ENABLE_STB_TRUETYPE
IMGUI_API const(ImFontBuilderIO)* ImFontAtlasGetBuilderForStbTruetype();
#endif
IMGUI_API void      ImFontAtlasUpdateConfigDataPointers(ImFontAtlas* atlas);
IMGUI_API void      ImFontAtlasBuildInit(ImFontAtlas* atlas);
IMGUI_API void      ImFontAtlasBuildSetupFont(ImFontAtlas* atlas, ImFont* font, ImFontConfig* font_config, float ascent, float descent);
IMGUI_API void      ImFontAtlasBuildPackCustomRects(ImFontAtlas* atlas, void* stbrp_context_opaque);
IMGUI_API void      ImFontAtlasBuildFinish(ImFontAtlas* atlas);
IMGUI_API void      ImFontAtlasBuildRender8bppRectFromString(ImFontAtlas* atlas, int x, int y, int w, int h, const(char)* in_str, char in_marker_char, unsigned char in_marker_pixel_value);
IMGUI_API void      ImFontAtlasBuildRender32bppRectFromString(ImFontAtlas* atlas, int x, int y, int w, int h, const(char)* in_str, char in_marker_char, unsigned int in_marker_pixel_value);
IMGUI_API void      ImFontAtlasBuildMultiplyCalcLookupTable(unsigned char out_table[256], float in_multiply_factor);
IMGUI_API void      ImFontAtlasBuildMultiplyRectAlpha8(const unsigned char table[256], unsigned char* pixels, int x, int y, int w, int h, int stride);

//-----------------------------------------------------------------------------
// [SECTION] Test Engine specific hooks (imgui_test_engine)
//-----------------------------------------------------------------------------

#ifdef IMGUI_ENABLE_TEST_ENGINE
extern void         ImGuiTestEngineHook_ItemAdd(ImGuiContext* ctx, ImGuiID id, const ImRect& bb, const(ImGuiLastItemData)* item_data);           // item_data may be NULL
extern void         ImGuiTestEngineHook_ItemInfo(ImGuiContext* ctx, ImGuiID id, const(char)* label, ImGuiItemStatusFlags flags);
extern void         ImGuiTestEngineHook_Log(ImGuiContext* ctx, const(char)* fmt, ...);
extern const(char)*  ImGuiTestEngine_FindItemDebugLabel(ImGuiContext* ctx, ImGuiID id);

// In IMGUI_VERSION_NUM >= 18934: changed IMGUI_TEST_ENGINE_ITEM_ADD(bb,id) to IMGUI_TEST_ENGINE_ITEM_ADD(id,bb,item_data);
#define IMGUI_TEST_ENGINE_ITEM_ADD(_ID,_BB,_ITEM_DATA)      if (g.TestEngineHookItems) ImGuiTestEngineHook_ItemAdd(&g, _ID, _BB, _ITEM_DATA)    // Register item bounding box
#define IMGUI_TEST_ENGINE_ITEM_INFO(_ID,_LABEL,_FLAGS)      if (g.TestEngineHookItems) ImGuiTestEngineHook_ItemInfo(&g, _ID, _LABEL, _FLAGS)    // Register item label and status flags (optional)
#define IMGUI_TEST_ENGINE_LOG(_FMT,...)                     if (g.TestEngineHookItems) ImGuiTestEngineHook_Log(&g, _FMT, __VA_ARGS__)           // Custom log entry from user land into test log
#else
#define IMGUI_TEST_ENGINE_ITEM_ADD(_BB,_ID)                 ((void)0)
#define IMGUI_TEST_ENGINE_ITEM_INFO(_ID,_LABEL,_FLAGS)      ((void)g)
#endif

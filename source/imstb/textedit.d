/+
+            Copyright 2023 – 2024 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imstb.textedit;

enum STB_TEXTEDIT_UNDOSTATECOUNT = 99;
enum STB_TEXTEDIT_UNDOCHARCOUNT = 999;
alias STB_TEXTEDIT_CHARTYPE = ImWchar;
alias STB_TEXTEDIT_POSITIONTYPE = int;

extern(C++, "ImStb") struct StbUndoRecord{
	private:
	STB_TEXTEDIT_POSITIONTYPE where;
	STB_TEXTEDIT_POSITIONTYPE insertLength;
	STB_TEXTEDIT_POSITIONTYPE deleteLength;
	int charStorage;
}

extern(C++, "ImStb") struct StbUndoState{
	private:
	StbUndoRecord[STB_TEXTEDIT_UNDOSTATECOUNT] undoRec;
	STB_TEXTEDIT_CHARTYPE[STB_TEXTEDIT_UNDOCHARCOUNT] undoChar;
	short undoPoint, redoPoint;
	int undoCharPoint, redoCharPoint;
}

extern(C++, "ImStb") struct STB_TexteditState{
	int cursor;
	
	int selectStart;
	int selectEnd;
	
	ubyte insertMode;
	
	int rowCountPerPage;
	
	private:
	ubyte cursorAtEndOfLine;
	ubyte initialized;
	ubyte hasPreferredX;
	ubyte singleLine;
	ubyte padding1, padding2, padding3;
	float preferredX;
	StbUndoState undostate;
}

extern(C++, "ImStb") struct StbTexteditRow{
	float x0, x1;
	float baselineYDelta;
	float yMin, yMax;
	int numChars;
}

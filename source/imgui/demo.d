/+
+                Copyright 2023 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui.demo;

import bindbc.imgui.config;

version(ImGui_DisableDemoWindows){
}else:

extern(C++):
void ShowExampleAppDocuments(bool* p_open);
void ShowExampleAppMainMenuBar();
void ShowExampleAppConsole(bool* p_open);
void ShowExampleAppLog(bool* p_open);
void ShowExampleAppLayout(bool* p_open);
void ShowExampleAppPropertyEditor(bool* p_open);
void ShowExampleAppLongText(bool* p_open);
void ShowExampleAppAutoResize(bool* p_open);
void ShowExampleAppConstrainedResize(bool* p_open);
void ShowExampleAppSimpleOverlay(bool* p_open);
void ShowExampleAppFullscreen(bool* p_open);
void ShowExampleAppWindowTitles(bool* p_open);
void ShowExampleAppCustomRendering(bool* p_open);
void ShowExampleMenuFile();

//pragma(mangle, "_ZL21ShowDemoWindowWidgetsv")
	void ShowDemoWindowWidgets();
void ShowDemoWindowLayout();
void ShowDemoWindowPopups();
void ShowDemoWindowTables();
void ShowDemoWindowColumns();
void ShowDemoWindowInputs();

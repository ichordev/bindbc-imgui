/+
+                Copyright 2023 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module bindbc.imgui.config;

enum staticBinding = (){
	version(BindBC_Static)         return true;
	else version(BindImGui_Static) return true;
	else return false;
}();

public import bindbc.common.versions;

enum imguiVersion = (){
	version(any)           return Version(1,89,6); //ImGui_1_89_6
	else                   return Version(1,89,6);
}();

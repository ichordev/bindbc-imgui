/+
+            Copyright 2023 – 2024 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module bindbc.imgui.config;

public import bindbc.common.types: c_longlong, c_ulonglong, va_list, wchar_t;

enum staticBinding = (){
	version(BindBC_Static)         return true;
	else version(BindImGui_Static) return true;
	else return false;
}();

enum cStyleEnums = (){
	version(SDL_C_Enums_Only)         return true;
	else version(BindBC_D_Enums_Only) return false;
	else version(SDL_D_Enums_Only)    return false;
	else return true;
}();

enum dStyleEnums = (){
	version(SDL_D_Enums_Only)         return true;
	else version(BindBC_C_Enums_Only) return false;
	else version(SDL_C_Enums_Only)    return false;
	else return true;
}();

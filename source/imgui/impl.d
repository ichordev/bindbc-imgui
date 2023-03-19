/+
+                Copyright 2023 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui.impl;

import bindbc.imgui.config;

extern(C++):
version(ImGui_Impl_SDL2){
	import bindbc.sdl;
	
	bool ImGui_ImplSDL2_InitForOpenGL(SDL_Window* window, void* sdl_gl_context);
	bool ImGui_ImplSDL2_InitForVulkan(SDL_Window* window);
	bool ImGui_ImplSDL2_InitForD3D(SDL_Window* window);
	bool ImGui_ImplSDL2_InitForMetal(SDL_Window* window);
	bool ImGui_ImplSDL2_InitForSDLRenderer(SDL_Window* window, SDL_Renderer* renderer);
	void ImGui_ImplSDL2_Shutdown();
	void ImGui_ImplSDL2_NewFrame();
	bool ImGui_ImplSDL2_ProcessEvent(const(SDL_Event)* event);
	
	version(ImGui_DisableObsoleteFunctions){
	}else{
		pragma(inline,true) void ImGui_ImplSDL2_NewFrame(SDL_Window*){ ImGui_ImplSDL2_NewFrame(); }
	}
}

version(ImGui_Impl_SDLRenderer){
	import imgui: ImDrawData;
	import bindbc.sdl;
	
	bool ImGui_ImplSDLRenderer_Init(SDL_Renderer* renderer);
	void ImGui_ImplSDLRenderer_Shutdown();
	void ImGui_ImplSDLRenderer_NewFrame();
	void ImGui_ImplSDLRenderer_RenderDrawData(ImDrawData* draw_data);

	bool ImGui_ImplSDLRenderer_CreateFontsTexture();
	void ImGui_ImplSDLRenderer_DestroyFontsTexture();
	bool ImGui_ImplSDLRenderer_CreateDeviceObjects();
	void ImGui_ImplSDLRenderer_DestroyDeviceObjects();
}
/+
+                Copyright 2023 Aya Partridge
+ Distributed under the Boost Software License, Version 1.0.
+     (See accompanying file LICENSE_1_0.txt or copy at
+           http://www.boost.org/LICENSE_1_0.txt)
+/
module imgui.impl;

import bindbc.imgui.config;

import imgui: ImDrawData;

extern(C++):

version(ImGui_Impl_Metal){
	version(D_ObjectiveC){
		import metal;
		extern(Objective-C):
		
		bool ImGui_ImplMetal_Init(MTLDevice device);
		void ImGui_ImplMetal_Shutdown();
		void ImGui_ImplMetal_NewFrame(MTLRenderPassDescriptor renderPassDescriptor);
		void ImGui_ImplMetal_RenderDrawData(ImDrawData* drawData, MTLCommandBuffer commandBuffer, MTLRenderCommandEncoder commandEncoder);
		
		bool ImGui_ImplMetal_CreateFontsTexture(MTLDevice device);
		void ImGui_ImplMetal_DestroyFontsTexture();
		bool ImGui_ImplMetal_CreateDeviceObjects(MTLDevice device);
		void ImGui_ImplMetal_DestroyDeviceObjects();
	}else static assert(0, "Your compiler doesn't support Objective-C interoperability");
}

version(ImGui_Impl_OpenGL3){
	import bindbc.opengl;
	
	bool ImGui_ImplOpenGL2_Init();
	void ImGui_ImplOpenGL2_Shutdown();
	void ImGui_ImplOpenGL2_NewFrame();
	void ImGui_ImplOpenGL2_RenderDrawData(ImDrawData* draw_data);
	
	bool ImGui_ImplOpenGL2_CreateFontsTexture();
	void ImGui_ImplOpenGL2_DestroyFontsTexture();
	bool ImGui_ImplOpenGL2_CreateDeviceObjects();
	void ImGui_ImplOpenGL2_DestroyDeviceObjects();
}

version(ImGui_Impl_OpenGL3){
	import bindbc.opengl;
	
	bool ImGui_ImplOpenGL3_Init(const(char)* glsl_version=null);
	void ImGui_ImplOpenGL3_Shutdown();
	void ImGui_ImplOpenGL3_NewFrame();
	void ImGui_ImplOpenGL3_RenderDrawData(ImDrawData* draw_data);
	
	bool ImGui_ImplOpenGL3_CreateFontsTexture();
	void ImGui_ImplOpenGL3_DestroyFontsTexture();
	bool ImGui_ImplOpenGL3_CreateDeviceObjects();
	void ImGui_ImplOpenGL3_DestroyDeviceObjects();
}

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
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

version(ImGui_Impl_Allegro5){
	import bindbc.allegro5: ALLEGRO_DISPLAY, ALLEGRO_EVENT;
	
	bool ImGui_ImplAllegro5_Init(ALLEGRO_DISPLAY* display);
	void ImGui_ImplAllegro5_Shutdown();
	void ImGui_ImplAllegro5_NewFrame();
	void ImGui_ImplAllegro5_RenderDrawData(ImDrawData* draw_data);
	bool ImGui_ImplAllegro5_ProcessEvent(ALLEGRO_EVENT* event);
	
	bool ImGui_ImplAllegro5_CreateDeviceObjects();
	void ImGui_ImplAllegro5_InvalidateDeviceObjects();
}

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

version(ImGui_Impl_OpenGL2){
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

version(ImGui_Impl_Vulkan){
	import erupted;
	import core.stdc.string: memset;
	
	struct ImGui_ImplVulkan_InitInfo{
		VkInstance Instance;
		VkPhysicalDevice PhysicalDevice;
		VkDevice Device;
		uint32_t QueueFamily;
		VkQueue Queue;
		VkPipelineCache PipelineCache;
		VkDescriptorPool DescriptorPool;
		uint32_t Subpass;
		uint32_t MinImageCount;
		uint32_t ImageCount;
		VkSampleCountFlagBits MSAASamples;
		const(VkAllocationCallbacks)* Allocator;
		void function(VkResult err) CheckVkResultFn;
	}
	
	bool ImGui_ImplVulkan_Init(ImGui_ImplVulkan_InitInfo* info, VkRenderPass render_pass);
	void ImGui_ImplVulkan_Shutdown();
	void ImGui_ImplVulkan_NewFrame();
	void ImGui_ImplVulkan_RenderDrawData(ImDrawData* draw_data, VkCommandBuffer command_buffer, VkPipeline pipeline=VK_NULL_ND_HANDLE);
	bool ImGui_ImplVulkan_CreateFontsTexture(VkCommandBuffer command_buffer);
	void ImGui_ImplVulkan_DestroyFontUploadObjects();
	void ImGui_ImplVulkan_SetMinImageCount(uint32_t min_image_count);
	
	VkDescriptorSet ImGui_ImplVulkan_AddTexture(VkSampler sampler, VkImageView image_view, VkImageLayout image_layout);
	void ImGui_ImplVulkan_RemoveTexture(VkDescriptorSet descriptor_set);
	
	bool ImGui_ImplVulkan_LoadFunctions(PFN_vkVoidFunction function(const(char)* loader_func, void* user_data), void* user_data=null);
	
	void ImGui_ImplVulkanH_CreateOrResizeWindow(VkInstance instance, VkPhysicalDevice physical_device, VkDevice device, ImGui_ImplVulkanH_Window* wnd, uint32_t queue_family, const(VkAllocationCallbacks)* allocator, int w, int h, uint32_t min_image_count);
	void ImGui_ImplVulkanH_DestroyWindow(VkInstance instance, VkDevice device, ImGui_ImplVulkanH_Window* wnd, const(VkAllocationCallbacks)* allocator);
	VkSurfaceFormatKHR ImGui_ImplVulkanH_SelectSurfaceFormat(VkPhysicalDevice physical_device, VkSurfaceKHR surface, const(VkFormat)* request_formats, int request_formats_count, VkColorSpaceKHR request_color_space);
	VkPresentModeKHR ImGui_ImplVulkanH_SelectPresentMode(VkPhysicalDevice physical_device, VkSurfaceKHR surface, const(VkPresentModeKHR)* request_modes, int request_modes_count);
	int ImGui_ImplVulkanH_GetMinImageCountFromPresentMode(VkPresentModeKHR present_mode);
	
	struct ImGui_ImplVulkanH_Frame{
		VkCommandPool CommandPool;
		VkCommandBuffer CommandBuffer;
		VkFence Fence;
		VkImage Backbuffer;
		VkImageView BackbufferView;
		VkFramebuffer Framebuffer;
	}
	
	struct ImGui_ImplVulkanH_FrameSemaphores{
		VkSemaphore ImageAcquiredSemaphore;
		VkSemaphore RenderCompleteSemaphore;
	}
	
	struct ImGui_ImplVulkanH_Window{
		int Width = 0;
		int Height = 0;
		VkSwapchainKHR Swapchain = VK_NULL_ND_HANDLE;
		VkSurfaceKHR Surface = VK_NULL_ND_HANDLE;
		VkSurfaceFormatKHR SurfaceFormat;
		VkPresentModeKHR PresentMode = VK_PRESENT_MODE_MAX_ENUM_KHR;
		VkRenderPass RenderPass = VK_NULL_ND_HANDLE;
		VkPipeline Pipeline = VK_NULL_ND_HANDLE;
		bool ClearEnable = true;
		VkClearValue ClearValue;
		uint32_t FrameIndex = 0;
		uint32_t ImageCount = 0;
		uint32_t SemaphoreIndex = 0;
		ImGui_ImplVulkanH_Frame* Frames = null;
		ImGui_ImplVulkanH_FrameSemaphores* FrameSemaphores = null;
	}
}

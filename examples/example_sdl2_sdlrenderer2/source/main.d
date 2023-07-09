import std.stdio;
import bindbc.imgui;
import bindbc.sdl;

static assert(SDL_VERSION_ATLEAST(2,0,17), "This backend requires SDL 2.0.17+ because of SDL_RenderGeometry() function");

// Main code
int main(){
	static if(!bindbc.sdl.config.staticBinding){
		if(loadSDL() != sdlSupport){
			import bindbc.loader;
			import core.stdc.stdio: printf;
			foreach(error; errors){
				printf("%s: %s\n", error.error, error.message);
			}
			return 0;
		}
	}
	
	// Setup SDL
	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0){
		printf("Error: %s\n", SDL_GetError());
		return -1;
	}
	
	// From 2.0.18: Enable native IME.
	SDL_SetHint(SDL_HINT_IME_SHOW_UI, "1");
	
	// Create window with SDL_Renderer graphics context
	SDL_WindowFlags window_flags = cast(SDL_WindowFlags)(SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
	SDL_Window* window = SDL_CreateWindow("Dear ImGui SDL2+SDL_Renderer example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, window_flags);
	SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (renderer == null){
		SDL_Log("Error creating SDL_Renderer!");
		return 0;
	}
	//SDL_RendererInfo info;
	//SDL_GetRendererInfo(renderer, &info);
	//SDL_Log("Current SDL_Renderer: %s", info.name);
	
	// Setup Dear ImGui context
	IMGUI_CHECKVERSION();
	imgui.CreateContext();
	ImGuiIO* io = GetIO();
	io.ConfigFlags |= ImGuiConfigFlags.NavEnableKeyboard; // Enable Keyboard Controls
	io.ConfigFlags |= ImGuiConfigFlags.NavEnableGamepad; // Enable Gamepad Controls
	
	// Setup Dear ImGui style
	imgui.StyleColorsDark();
	//imgui.StyleColorsLight();
	
	// Setup Platform/Renderer backends
	ImGui_ImplSDL2_InitForSDLRenderer(window, renderer);
	ImGui_ImplSDLRenderer_Init(renderer);
	
	// Load Fonts
	// - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use imgui.PushFont()/PopFont() to select them.
	// - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
	// - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
	// - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
	// - Use '#define IMGUI_ENABLE_FREETYPE' in your imconfig file to use Freetype for higher quality font rendering.
	// - Read 'docs/FONTS.md' for more instructions and details.
	// - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
	//io.Fonts->AddFontDefault();
	//io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\segoeui.ttf", 18.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
	//ImFont* font = io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());
	//IM_ASSERT(font != NULL);
	
	// Our state
	bool show_demo_window = true;
	bool show_another_window = false;
	ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
	
	// Main loop
	bool done = false;
	while(!done){
		// Poll and handle events (inputs, window resize, etc.)
		// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
		// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
		// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
		// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
		SDL_Event event;
		while (SDL_PollEvent(&event)){
			ImGui_ImplSDL2_ProcessEvent(&event);
			if(event.type == SDL_QUIT) done = true;
			if(event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window)) done = true;
		}
		
		// Start the Dear ImGui frame
		ImGui_ImplSDLRenderer_NewFrame();
		ImGui_ImplSDL2_NewFrame();
		imgui.NewFrame();
		
		// 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
		if(show_demo_window) imgui.ShowDemoWindow(&show_demo_window);
		
		// 2. Show a simple window that we create ourselves. We use a Begin/End pair to create a named window.
		{
			static float f = 0.0f;
			static int counter = 0;
			
			imgui.Begin("Hello, world!");						  // Create a window called "Hello, world!" and append into it.
			
			imgui.Text("This is some useful text.");			   // Display some text (you can use a format strings too)
			imgui.Checkbox("Demo Window", &show_demo_window);	  // Edit bools storing our window open/close state
			imgui.Checkbox("Another Window", &show_another_window);
			
			imgui.SliderFloat("float", &f, 0.0f, 1.0f);			// Edit 1 float using a slider from 0.0f to 1.0f
			imgui.ColorEdit3("clear color", cast(float*)&clear_color); // Edit 3 floats representing a color
			
			if(imgui.Button("Button"))							// Buttons return true when clicked (most widgets return true when edited/activated)
				counter++;
			imgui.SameLine();
			imgui.Text("counter = %d", counter);

			imgui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);
			imgui.End();
		}
		
		// 3. Show another simple window.
		if(show_another_window){
			imgui.Begin("Another Window", &show_another_window);   // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
			imgui.Text("Hello from another window!");
			if(imgui.Button("Close Me"))
				show_another_window = false;
			imgui.End();
		}
		
		// Rendering
		imgui.Render();
		SDL_RenderSetScale(renderer, io.DisplayFramebufferScale.x, io.DisplayFramebufferScale.y);
		SDL_SetRenderDrawColor(renderer, cast(ubyte)(clear_color.x * 255), cast(ubyte)(clear_color.y * 255), cast(ubyte)(clear_color.z * 255), cast(ubyte)(clear_color.w * 255));
		SDL_RenderClear(renderer);
		ImGui_ImplSDLRenderer_RenderDrawData(imgui.GetDrawData());
		SDL_RenderPresent(renderer);
	}
	
	// Cleanup
	ImGui_ImplSDLRenderer_Shutdown();
	ImGui_ImplSDL2_Shutdown();
	imgui.DestroyContext();
	
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();

	return 0;
}

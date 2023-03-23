// Dear ImGui: standalone example application forAllegro 5
// ifyou are new to Dear ImGui, read documentation from the docs/ folder + read the top of imgui.cpp.
// Read online: https://github.com/ocornut/imgui/tree/master/docs

// On Windows, you can install Allegro5 using vcpkg:
//   git clone https://github.com/Microsoft/vcpkg
//   cd vcpkg
//   bootstrap - vcpkg.bat
//   vcpkg install allegro5 --triplet=x86-windows   ; forwin32
//   vcpkg install allegro5 --triplet=x64-windows   ; forwin64
//   vcpkg integrate install                        ; register include and libs in Visual Studio

import core.stdc.stdint;
import bindbc.allegro5;
import bindbc.allegro5.allegro_primitives;
import bindbc.imgui;

int main(){
	static if(!bindbc.allegro5.config.staticBinding){
		if(loadAllegro() != allegroSupport){
			import bindbc.loader;
			import core.stdc.stdio: printf;
			foreach(error; errors){
				printf("%s: %s\n", error.error, error.message);
			}
			return 0;
		}
		loadAllegroPrimitives();
	}
	
	// Set up Allegro
	al_init();
	al_install_keyboard();
	al_install_mouse();
	al_init_primitives_addon();
	al_set_new_display_flags(ALLEGRO_RESIZABLE);
	ALLEGRO_DISPLAY* display = al_create_display(1280, 720);
	al_set_window_title(display, "Dear ImGui Allegro 5 example");
	ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
	al_register_event_source(queue, al_get_display_event_source(display));
	al_register_event_source(queue, al_get_keyboard_event_source());
	al_register_event_source(queue, al_get_mouse_event_source());

	// Set up Dear ImGui context
	IMGUI_CHECKVERSION();
	imgui.CreateContext();
	ImGuiIO* io = imgui.GetIO();
	io.ConfigFlags |= ImGuiConfigFlags.NavEnableKeyboard;  // Enable Keyboard Controls

	// Set up Dear ImGui style
	imgui.StyleColorsDark();
	//imgui.StyleColorsLight();

	// Set up Platform/Renderer backends
	ImGui_ImplAllegro5_Init(display);

	// Load Fonts
	// - ifno fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use imgui.PushFont()/PopFont() to select them.
	// - AddFontFromFileTTF() will return the ImFont* so you can store it ifyou need to select the font among multiple.
	// - ifthe file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
	// - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
	// - Use '#define IMGUI_ENABLE_FREETYPE' in your imconfig file to use Freetype forhigher quality font rendering.
	// - Read 'docs/FONTS.md' formore instructions and details.
	// - Remember that in C/C++ ifyou want to include a backslash \ in a string literal you need to write a double backslash \\ !
	//io.Fonts->AddFontDefault();
	//io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\segoeui.ttf", 18.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
	//ImFont* font = io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());
	//IM_ASSERT(font != NULL);

	bool show_demo_window = true;
	bool show_another_window = false;
	ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

	// Main loop
	bool running = true;
	while(running){
		// Poll and handle events (inputs, window resize, etc.)
		// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell ifdear imgui wants to use your inputs.
		// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
		// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
		// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
		ALLEGRO_EVENT ev;
		while(al_get_next_event(queue, &ev)){
			ImGui_ImplAllegro5_ProcessEvent(&ev);
			if(ev.type == ALLEGRO_EVENT_DISPLAY_CLOSE)
				running = false;
			if(ev.type == ALLEGRO_EVENT_DISPLAY_RESIZE){
				ImGui_ImplAllegro5_InvalidateDeviceObjects();
				al_acknowledge_resize(display);
				ImGui_ImplAllegro5_CreateDeviceObjects();
			}
		}

		// Start the Dear ImGui frame
		ImGui_ImplAllegro5_NewFrame();
		imgui.NewFrame();

		// 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
		if(show_demo_window)
			imgui.ShowDemoWindow(&show_demo_window);

		// 2. Show a simple window that we create ourselves. We use a Begin/End pair to create a named window.
		{
			static float f = 0.0f;
			static int counter = 0;

			imgui.Begin("Hello, world!");                          // Create a window called "Hello, world!" and append into it.

			imgui.Text("This is some useful text.");               // Display some text (you can use a format strings too)
			imgui.Checkbox("Demo Window", &show_demo_window);      // Edit bools storing our window open/close state
			imgui.Checkbox("Another Window", &show_another_window);

			imgui.SliderFloat("float", &f, 0.0f, 1.0f);            // Edit 1 float using a slider from 0.0f to 1.0f
			imgui.ColorEdit3("clear color", cast(float*)&clear_color); // Edit 3 floats representing a color

			if(imgui.Button("Button"))                            // Buttons return true when clicked (most widgets return true when edited/activated)
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
		al_clear_to_color(al_map_rgba_f(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w));
		ImGui_ImplAllegro5_RenderDrawData(imgui.GetDrawData());
		al_flip_display();
	}

	// Cleanup
	ImGui_ImplAllegro5_Shutdown();
	imgui.DestroyContext();
	al_destroy_event_queue(queue);
	al_destroy_display(display);

	return 0;
}
//'setup' is a noun, not a verb. Sorry, English is bad!

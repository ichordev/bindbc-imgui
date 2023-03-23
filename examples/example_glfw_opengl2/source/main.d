// Dear ImGui: standalone example application for GLFW + OpenGL2, using legacy fixed pipeline
// (GLFW is a cross-platform general purpose library for handling windows, inputs, OpenGL/Vulkan/Metal graphics context creation, etc.)
// ifyou are new to Dear ImGui, read documentation from the docs/ folder + read the top of imgui.cpp.
// Read online: https://github.com/ocornut/imgui/tree/master/docs

// **DO NOT USE THIS CODE ifYOUR CODE/ENGINE IS USING MODERN OPENGL (SHADERS, VBO, VAO, etc.)**
// **Prefer using the code in the example_glfw_opengl2/ folder**
// See imgui_impl_glfw.cpp for details.

import bindbc.imgui;
import core.stdc.stdio;
// #ifdef __APPLE__
// #define GL_SILENCE_DEPRECATION
// #endif
import bindbc.opengl;
import bindbc.glfw;

// [Win32] Our example includes a copy of glfw3.lib pre-compiled with VS2010 to maximize ease of testing and compatibility with old VS compilers.
// To link with VS2010-era libraries, VS2015+ requires linking with legacy_stdio_definitions.lib, which we do using this pragma.
// Your own project should not be affected, as you are likely to link with a newer binary of GLFW that is adequate for your version of Visual Studio.
// #ifdefined(_MSC_VER) && (_MSC_VER >= 1900) && !defined(IMGUI_DISABLE_WIN32_FUNCTIONS)
// #pragma comment(lib, "legacy_stdio_definitions")
// #endif

extern(C) static void glfw_error_callback(int error, const(char)* description) nothrow{
	fprintf(stderr, "GLFW Error %d: %s\n", error, description);
}

// Main code
int main(){
	version(BindGLFW_Static){ //TODO: add bindStatic to bindbc.glfw and then change this :)
	}else{
		if(loadGLFW() != glfwSupport){
			import bindbc.loader;
			foreach(error; errors){
				printf("%s: %s\n", error.error, error.message);
			}
			return 0;
		}
	}
	
	glfwSetErrorCallback(&glfw_error_callback);
	if(!glfwInit())
		return 1;
	
	// Create window with graphics context
	GLFWwindow* window = glfwCreateWindow(1280, 720, "Dear ImGui GLFW+OpenGL2 example", null, null);
	if(window == null)
		return 1;
	
	if(loadOpenGL() != glSupport){
		import bindbc.loader;
		foreach(error; errors){
			printf("%s: %s\n", error.error, error.message);
		}
		return 0;
	}
	
	glfwMakeContextCurrent(window);
	glfwSwapInterval(1); // Enable vsync
	
	// Setup Dear ImGui context
	IMGUI_CHECKVERSION();
	imgui.CreateContext();
	ImGuiIO* io = imgui.GetIO();
	io.ConfigFlags |= ImGuiConfigFlags.NavEnableKeyboard;     // Enable Keyboard Controls
	io.ConfigFlags |= ImGuiConfigFlags.NavEnableGamepad;      // Enable Gamepad Controls

	// Setup Dear ImGui style
	imgui.StyleColorsDark();
	//imgui.StyleColorsLight();

	// Setup Platform/Renderer backends
	ImGui_ImplGlfw_InitForOpenGL(window, true);
	ImGui_ImplOpenGL2_Init();

	// Load Fonts
	// - ifno fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use imgui.PushFont()/PopFont() to select them.
	// - AddFontFromFileTTF() will return the ImFont* so you can store it ifyou need to select the font among multiple.
	// - ifthe file cannot be loaded, the function will return null. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
	// - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
	// - Use '#define IMGUI_ENABLE_FREETYPE' in your imconfig file to use Freetype for higher quality font rendering.
	// - Read 'docs/FONTS.md' for more instructions and details.
	// - Remember that in C/C++ ifyou want to include a backslash \ in a string literal you need to write a double backslash \\ !
	//io.Fonts->AddFontDefault();
	//io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\segoeui.ttf", 18.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
	//ImFont* font = io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, null, io.Fonts->GetGlyphRangesJapanese());
	//IM_ASSERT(font != null);

	// Our state
	bool show_demo_window = true;
	bool show_another_window = false;
	ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

	// Main loop
	while(!glfwWindowShouldClose(window)){
		// Poll and handle events (inputs, window resize, etc.)
		// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell ifdear imgui wants to use your inputs.
		// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
		// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
		// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
		glfwPollEvents();

		// Start the Dear ImGui frame
		ImGui_ImplOpenGL2_NewFrame();
		ImGui_ImplGlfw_NewFrame();
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
		if(show_another_window)
		{
			imgui.Begin("Another Window", &show_another_window);   // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
			imgui.Text("Hello from another window!");
			if(imgui.Button("Close Me"))
				show_another_window = false;
			imgui.End();
		}

		// Rendering
		imgui.Render();
		int display_w, display_h;
		glfwGetFramebufferSize(window, &display_w, &display_h);
		glViewport(0, 0, display_w, display_h);
		glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
		glClear(GL_COLOR_BUFFER_BIT);

		// ifyou are using this code with non-legacy OpenGL header/contexts (which you should not, prefer using imgui_impl_opengl3.cpp!!),
		// you may need to backup/reset/restore other state, e.g. for current shader using the commented lines below.
		//GLint last_program;
		//glGetIntegerv(GL_CURRENT_PROGRAM, &last_program);
		//glUseProgram(0);
		ImGui_ImplOpenGL2_RenderDrawData(imgui.GetDrawData());
		//glUseProgram(last_program);

		glfwMakeContextCurrent(window);
		glfwSwapBuffers(window);
	}

	// Cleanup
	ImGui_ImplOpenGL2_Shutdown();
	ImGui_ImplGlfw_Shutdown();
	imgui.DestroyContext();

	glfwDestroyWindow(window);
	glfwTerminate();

	return 0;
}

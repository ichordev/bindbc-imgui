// dear imgui: "null" example application
// (compile and link imgui, create context, run headless with NO INPUTS, NO GRAPHICS OUTPUT)
// This is useful to test building, but you cannot interact with anything here!
import bindbc.imgui;
import std.stdio;

int main(){
	IMGUI_CHECKVERSION();
	imgui.CreateContext();
	ImGuiIO* io = imgui.GetIO();

	// Build atlas
	ubyte* tex_pixels = null;
	int tex_w, tex_h;
	io.Fonts.GetTexDataAsRGBA32(&tex_pixels, &tex_w, &tex_h);

	for(int n = 0; n < 20; n++){
		printf("NewFrame() %d\n", n);
		io.DisplaySize = ImVec2(1920, 1080);
		io.DeltaTime = 1.0f / 60.0f;
		imgui.NewFrame();

		static float f = 0.0f;
		imgui.Text("Hello, world!");
		imgui.SliderFloat("float", &f, 0.0f, 1.0f);
		imgui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);
		imgui.ShowDemoWindow(null);
		
		imgui.Render();
	}

	printf("DestroyContext()\n");
	imgui.DestroyContext();
	return 0;
}

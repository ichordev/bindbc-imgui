import std.stdio;
import bindbc.imgui;

void main(){
	bool test = true;
	ShowDemoWindowWidgets();
	/*
	//IMGUI_CHECKVERSION();
	CreateContext();
	ImGuiIO* io = GetIO();
	
	// Build atlas
	ubyte* tex_pixels = null;
	int tex_w, tex_h;
	//io.Fonts->GetTexDataAsRGBA32(&tex_pixels, &tex_w, &tex_h);
	
	for(int n = 0; n < 20; n++){
		printf("NewFrame() %d\n", n);
		//io.DisplaySize = ImVec2(1920, 1080);
		//io.DeltaTime = 1.0f / 60.0f;
		NewFrame();
		
		static float f = 0.0f;
		Text("Hello, world!");
		pragma(msg, "HEY! ",SliderFloat.mangleof);
		SliderFloat("float", &f, 0.0f, 1.0f);
		Text("Application average %.3f ms/frame (%.1f FPS)", 60, 60);
		ShowDemoWindow();
		
		Render();
	}
	
	printf("DestroyContext()\n");
	DestroyContext();
	//*/
}

import json
from copy import deepcopy

buildTypes = {
	"static": {
		"versions": ["BindImGui_Static"],
	},
	"staticBC": {
		"subConfigurations": {"bindbc-common": "yesBC"},
		"buildOptions": ["betterC"],
		"versions": ["BindImGui_Static"],
	},
}
implFrontends = {
	"Allegro5": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_allegro5.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_allegro5.obj"],
		"dependencies": {"bindbc-allegro5": "~>1.0.0"},
		"versions": ["ImGui_Impl_Allegro5"],
	},
	# "Android": {
	# 	"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_android.o"],
	# 	"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_android.obj"],
	# 	"versions": ["ImGui_Impl_Android"],
	# },
	"GLFW": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_glfw.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_glfw.obj"],
		"dependencies": {"bindbc-glfw": "~>1.0.0"},
		"versions": ["ImGui_Impl_GLFW"],
	},
	"macOS": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_osx.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_osx.obj"],
		"versions": ["ImGui_Impl_macOS"],
	},
	"SDL2": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_sdl2.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_sdl2.obj"],
		"dependencies": {"bindbc-sdl": "~>1.3.0"},
		"versions": ["ImGui_Impl_SDL2"],
	},
	# "SDL3": {
	# 	"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_sdl3.o"],
	# 	"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_sdl3.obj"],
	# 	"versions": ["ImGui_Impl_SDL3"],
	# },
	# "Win32": {
	# 	"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_win32.o"],
	# 	"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_win32.obj"],
	# 	"versions": ["ImGui_Impl_Win32"],
	# },
}
implRenderers = {
	# "DX9": {
	# 	"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx9.o"],
	# 	"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx9.obj"],
	# 	"versions": ["ImGui_Impl_DX9"],
	# },
	# "DX10": {
	# 	"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx10.o"],
	# 	"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx10.obj"],
	# 	"versions": ["ImGui_Impl_DX10"],
	# },
	# "DX11": {
	# 	"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx11.o"],
	# 	"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx11.obj"],
	# 	"versions": ["ImGui_Impl_DX11"],
	# },
	# "DX12": {
	# 	"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx12.o"],
	# 	"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_dx12.obj"],
	# 	"versions": ["ImGui_Impl_DX12"],
	# },
	"Metal": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_metal.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_metal.obj"],
		"dependencies": {"d-metal-binding": "~>1.0.12"},
		"versions": ["ImGui_Impl_Metal"],
		"lflags": [
			"-framework CoreFoundation",
			"-framework QuartzCore",
			"-framework Metal",
			"-framework MetalKit",
			"-framework Cocoa",
			"-framework IOKit",
			"-framework CoreVideo",
		],
	},
	"OpenGL2": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_opengl2.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_opengl2.obj"],
		"dependencies": {"bindbc-opengl": "~>1.0.0"},
		"versions": ["ImGui_Impl_OpenGL2"],
	},
	"OpenGL3": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_opengl3.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_opengl3.obj"],
		"dependencies": {"bindbc-opengl": "~>1.0.0"},
		"versions": ["ImGui_Impl_OpenGL3", "GL_30"],
	},
	"SDLRenderer": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_sdlrenderer.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_sdlrenderer.obj"],
		"dependencies": {"bindbc-sdl": "~>1.3.0"},
		"versions": ["ImGui_Impl_SDLRenderer"],
	},
	"Vulkan": {
		"sourceFiles-posix": ["$BIND_IMGUI_OBJDIR/imgui_impl_vulkan.o"],
		"sourceFiles-windows": ["$BIND_IMGUI_OBJDIR/imgui_impl_vulkan.obj"],
		"dependencies": {"erupted": "~>2.1.0"},
		"versions": ["ImGui_Impl_Vulkan"],
	},
}

configs = []

def mergeDict(a, b):
	c = deepcopy(a)
	for key, value in b.items():
		if type(value) is list:
			if key in c:
				c[key].extend(b[key])
			else:
				c[key] = b[key]
		elif type(value) is dict:
			if key in c:
				c[key] = mergeDict(c[key], b[key])
			else:
				c[key] = b[key]
		else:
			c[key] = b[key]
	return c


for buildName, buildType in buildTypes.items():
	configA = mergeDict({'name': f'{buildName}'}, buildType)
	configs.append(configA)
	
	for frontendName, implFrontend in implFrontends.items():
		configB = mergeDict(configA.copy(), implFrontend)
		configB['name'] += f'-{frontendName}'
		configs.append(configB)
		
		for rendererName, implRenderer in implRenderers.items():
			configC = mergeDict(configB.copy(), implRenderer)
			configC['name'] += f'-{rendererName}'
			configs.append(configC)

print(json.dumps({'configurations': configs}, indent='\t'))

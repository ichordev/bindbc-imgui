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
		"dependencies": {"bindbc-allegro5": "~>1.0.0"},
		"versions": ["ImGui_Impl_Allegro5"],
	},
	# "Android": {
	# 	"versions": ["ImGui_Impl_Android"],
	# },
	"GLFW": {
		"dependencies": {"bindbc-glfw": "~>1.0.0"},
		"versions": ["ImGui_Impl_GLFW"],
	},
	"macOS": {
		"versions": ["ImGui_Impl_macOS"],
	},
	"SDL2": {
		"dependencies": {"bindbc-sdl": "~>1.3.0"},
		"versions": ["ImGui_Impl_SDL2"],
	},
	# "SDL3": {
	# 	"versions": ["ImGui_Impl_SDL3"],
	# },
	# "Win32": {
	# 	"versions": ["ImGui_Impl_Win32"],
	# },
}
implRenderers = {
	# "DX9": {
	# 	"versions": ["ImGui_Impl_DX9"],
	# },
	# "DX10": {
	# 	"versions": ["ImGui_Impl_DX10"],
	# },
	# "DX11": {
	# 	"versions": ["ImGui_Impl_DX11"],
	# },
	# "DX12": {
	# 	"versions": ["ImGui_Impl_DX12"],
	# },
	"Metal": {
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
		"dependencies": {"bindbc-opengl": "~>1.0.0"},
		"versions": ["ImGui_Impl_OpenGL2"],
	},
	"OpenGL3": {
		"dependencies": {"bindbc-opengl": "~>1.0.0"},
		"versions": ["ImGui_Impl_OpenGL3", "GL_30"],
	},
	"SDLRenderer": {
		"dependencies": {"bindbc-sdl": "~>1.3.0"},
		"versions": ["ImGui_Impl_SDLRenderer"],
	},
	"Vulkan": {
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

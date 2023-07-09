
## Quickstart guide

Environment variable `$BIND_IMGUI_OBJDIR` has must point to a path with built object files for Dear ImGui and any Dear ImGui backends you use.

## Binding-specific changes

### Enums
Dear ImGui enums in these bindings are reformatted like so:
```d
void ImFn(ImGuiDir flags); //x
//becomes:
void ImFn(ImGuiDir_ flags); //x_

ImFn(ImFontAtlasFlags_NoMouseCursors); //x_y
//becomes:
ImFn(ImFontAtlasFlags.NoMouseCursors); //x.y
```

### Default constructors
D completely disallows default constructors. Because of this, any default constructors
from Dear ImGui take a single `int` as their first parameter.
This `int` parameter is always discarded, so you may supply any number, but a `0` is recommended for consistency:
```d
auto clipper = ImGuiListClipper(0);
```
Failing to call the default constructor of an ImGui struct that has one may lead to unintended consequences, and is therefore not recommended:
```d
//The constructor will not be called in either of these cases:
ImGuiListClipper clipper1;
auto clipper2 = ImGuiListClipper(); //no `int` parameter!
```

### ImVec Operator Overloads
Operator overloads for `ImVec2` and `ImVec4` are defined unconditionally.

## Backends

### Input/Windowing & Rendering
| Name       | Description |
|------------|-------------|
| `Allegro5` | Requires `bindbc-allegro` ~>1.0.0 |

### Input/Windowing only
| Name       | Description |
|------------|-------------|
| `Android`  | Not currently supported. |
| `GLFW`     | Untested. Requires `bindbc-glfw` ~>1.1.0. |
| `macOS`    | Untested. Example not finished. |
| `SDL2`     | Requires `bindbc-sdl` ~>1.4.0. |
| `SDL3`     | Will be added once SDL3 is stable and BindBC-SDL has updated. |
| `Win32`    | Not currently supported. |

### Rendering only

| Name           | Description |
|----------------|-------------|
| `bgfx`         | Coming soon. |
| `DX9`          | Not currently supported. |
| `DX10`         | Not currently supported. |
| `DX11`         | Not currently supported. |
| `DX12`         | Not currently supported. |
| `Metal`        | Untested. Requires `d-metal-binding` ~>1.1.0. x86_64 only due to Objective-C interoperability being DMD-exclusive. |
| `OpenGL2`      | Untested. Requires `bindbc-opengl` ~>1.1.0. |
| `OpenGL3`      | Requires `bindbc-opengl` ~>1.1.0. |
| `SDLRenderer2` | Requires `bindbc-sdl` ~>1.4.0. |
| `Vulkan`       | Requires `erupted` ~>2.1.0. |

## Configuration

| Version identifier               | Description |
|----------------------------------|-------------|
| `ImGui_Internal`                 | Enable bindings of `imgui_internal.h`. |
| `ImGui_DisableObsoleteFunctions` | Don't define obsolete functions/behaviours. Consider enabling from time to time after updating to avoid using soon-to-be obsolete function/names. |
| `ImGui_ImDrawIdx32`              | Use 32-bit indices. Default is 16-bit. |
| `ImGui_WChar32`                  | Use 32-bit `wchar`s. Default is 16-bit. |
| `ImGui_BGRAPackedCol`            | Pack colours to BGRA8 instead of RGBA8. (To avoid converting from one to another) |
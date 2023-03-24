
#Quickstart guide

Environment variable `$BIND_IMGUI_OBJDIR` has must point to a path with built object files for ImGui and any backends you use.

#Binding-specific changes

##Enums
Dear ImGui enums in these bindings ae reformatted like so:
```d
void ImFn(ImGuiDir flags); //x
//becomes:
void ImFn(ImGuiDir_ flags); //x_

ImFn(ImFontAtlasFlags_NoMouseCursors); //x_y
//becomes:
ImFn(ImFontAtlasFlags.NoMouseCursors); //x.y
```

##Default constructors
Any default constructors (that is, constructors with no parameters) from
Dear ImGui are modified to take a single `int` to avoid compiler errors.
Since this `int` is discarded, it's recommended to always supply `0`:
```d
auto clipper = ImGuiListClipper(0);
```
It's only recommended for you to use the `.init` of a struct when it
is strictly necessary.

#Backends

## API & Rendering
| Name       | Description |
|------------|-------------|
| `Allegro5` | Untested. Requires `bindbc-allegro` >=1.0.0 |

## API-only
| Name       | Description |
|------------|-------------|
| `Android`  | Not currently supported. |
| `GLFW`     | Untested. |
| `macOS`    | Untested. Example not finished. |
| `SDL2`     | Requires `bindbc-sdl` >=1.3.0. |
| `SDL3`     | Not currently supported. |
| `Win32`    | Not currently supported. |

## Rendering-only

| Name          | Description |
|---------------|-------------|
| `DX9`         | Not currently supported. |
| `DX10`        | Not currently supported. |
| `DX11`        | Not currently supported. |
| `DX12`        | Not currently supported. |
| `Metal`       | Untested. Requires `d-metal-binding` ~>1.0.12. x86_64 only due to Objective-C interoperability being DMD-exclusive. |
| `OpenGL2`     | Untested. Requires `bindbc-opengl` ~>1.0.0. |
| `OpenGL3`     | Requires `bindbc-opengl` ~>1.0.0. |
| `SDLRenderer` | Requires `bindbc-sdl` ~>1.3.0. |
| `Vulkan`      | Requires `erupted` ~>2.1.0. |

#Configuration

| Version identifier               | Description |
|----------------------------------|-------------|
| `ImGui_DisableObsoleteFunctions` | Don't define obsolete functions/behaviors. Consider enabling from time to time after updating to avoid using soon-to-be obsolete function/names. |
| `ImGui_DisableObsoleteKeyIO`     | 1.87: disable legacy io.KeyMap[]+io.KeysDown[] in favor io.AddKeyEvent(). This will be folded into ImGui_DisableObsoleteFunctions in a few versions. |
| `ImGui_ImDrawIdx32`              | Use 32-bit indices. Default is 16-bit. |
| `ImGui_WChar32`                  | Use 32-bit "wchar"s. Default is 16-bit. |
| `ImGui_BGRAPackedCol`            | Pack colors to BGRA8 instead of RGBA8. (To avoid converting from one to another) |


| Configuration suffix | Description |
|----------------------|-------------|
| `Allegro5`           | Not currently supported. |
| `Android`            | Not currently supported. |
| `Apple`              | Not currently supported. |
| `GLFW`               | Not currently supported. |
| `SDL2`               | Requires bindbc-sdl >=1.2.0. |
| `SDL3`               | Not currently supported. |
| `Win32`              | Not currently supported. |

| Version identifier               | Description |
|----------------------------------|-------------|
| `ImGui_Impl_SDLRenderer`         | Not recommended for production use. |

| Version identifier               | Description |
|----------------------------------|-------------|
| `ImGui_DisableObsoleteFunctions` | Don't define obsolete functions/behaviors. Consider enabling from time to time after updating to avoid using soon-to-be obsolete function/names. |
| `ImGui_DisableObsoleteKeyIO`     | 1.87: disable legacy io.KeyMap[]+io.KeysDown[] in favor io.AddKeyEvent(). This will be folded into ImGui_DisableObsoleteFunctions in a few versions. |
| `ImGui_DisableDemoWindows`       | Disable demo windows: ShowDemoWindow()/ShowStyleEditor() will be empty. |
| `ImGui_ImDrawIdx32`              | Use 32-bit indices. Default is 16-bit. |
| `ImGui_WChar32`                  | Use 32-bit "wchar"s. Default is 16-bit. |
| `ImGui_BGRAPackedCol`            | Pack colors to BGRA8 instead of RGBA8. (To avoid converting from one to another) |
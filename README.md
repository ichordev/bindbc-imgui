

| Version identifier    | Description |
|-----------------------|-------------|
| `ImGui_Impl_Allegro5` |  |
| `ImGui_Impl_Android`  |  |
| `ImGui_Impl_DX9`      |  |
| `ImGui_Impl_DX10`     |  |
| `ImGui_Impl_DX11`     |  |
| `ImGui_Impl_DX12`     |  |
| `ImGui_Impl_GLFW`     |  |
| `ImGui_Impl_Metal`    |  |
| `ImGui_Impl_OpenGL2`  |  |
| `ImGui_Impl_OpenGL3`  |  |
| `ImGui_Impl_macOS`    |  |
| `ImGui_Impl_SDL2`     |  |
| `ImGui_Impl_SDL3`     |  |
| `ImGui_Impl_Vulkan`   |  |
| `ImGui_Impl_WGPU`     |  |
| `ImGui_Impl_Win32`    |  |

| Version identifier               | Description |
|----------------------------------|-------------|
| `ImGui_DisableObsoleteFunctions` | Don't define obsolete functions/behaviors. Consider enabling from time to time after updating to avoid using soon-to-be obsolete function/names. |
| `ImGui_DisableObsoleteKeyIO`     | 1.87: disable legacy io.KeyMap[]+io.KeysDown[] in favor io.AddKeyEvent(). This will be folded into ImGui_DisableObsoleteFunctions in a few versions. |
| `ImGui_DisableDemoWindows`       | Disable demo windows: ShowDemoWindow()/ShowStyleEditor() will be empty. |
| `ImGui_ImDrawIdx32`              | Use 32-bit indices. Default is 16-bit. |
| `ImGui_WChar32`                  | Use 32-bit "wchar"s. Default is 16-bit. |
| `ImGui_BGRAPackedCol`            | Pack colors to BGRA8 instead of RGBA8 (to avoid converting from one to another) |
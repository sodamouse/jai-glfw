// Bindings for GLFW.

#scope_module

size_t :: u64;

#if OS == .WINDOWS {
    #import "Basic";
    assert(false);
    #load "windows.jai";
} else {
    #load "unix.jai";
}

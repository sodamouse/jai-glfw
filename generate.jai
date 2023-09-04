GLFW3_PATH :: "glfw";
COMPILE :: true;

#run build();

build :: () {
    set_build_options_dc(.{do_output = false});

    #if COMPILE {
        #import "File";
        #import "BuildCpp";
        glfwSourceFiles : [..] string;

        array_add(*glfwSourceFiles, tprint("%/src/context.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/init.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/input.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/monitor.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/platform.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/vulkan.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/window.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/egl_context.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/osmesa_context.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/null_joystick.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/null_init.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/null_monitor.c", GLFW3_PATH));
        array_add(*glfwSourceFiles, tprint("%/src/null_window.c", GLFW3_PATH));

        #if OS == .LINUX {
            array_add(*glfwSourceFiles, tprint("%/src/posix_poll.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/posix_module.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/posix_time.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/posix_thread.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/linux_joystick.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/x11_init.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/x11_monitor.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/x11_window.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/xkb_unicode.c", GLFW3_PATH));
            array_add(*glfwSourceFiles, tprint("%/src/glx_context.c", GLFW3_PATH));
        }

        #if COMPILE {
            make_directory_if_it_does_not_exist("linux");
            build_cpp_dynamic_lib("linux/glfw", ..glfwSourceFiles, debug=true, extra=.["-D_GLFW_X11", "-D_GLFW_BUILD_DLL"]);
            build_cpp_static_lib("linux/glfw", ..glfwSourceFiles, extra = .["-fno-exceptions", "-D_GLFW_X11"], debug=true);
        }
    }

    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
        return;
    }
}

generate_bindings :: () -> bool {
    output_filename : string;
    opts : Generate_Bindings_Options;
    opts.try_to_preserve_comments = false;
    {
        using opts;
        #if OS == .WINDOWS {
            array_add(*libpaths, "windows");
            output_filename = "windows.jai";
        } else {
            #if OS == .LINUX {
                array_add(*libpaths, "linux");
            } else #if OS == .MACOS {
                array_add(*libpaths, "macos");
            }
            output_filename = "unix.jai";
        }

        array_add(*libnames, "glfw");
        array_add(*source_files, tprint("%/include/GLFW/glfw3.h", GLFW3_PATH));
        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");
        strip_flags |= .INLINED_FUNCTIONS;
    }

    return generate_bindings(opts, output_filename);
}

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";

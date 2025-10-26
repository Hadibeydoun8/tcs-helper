cmake_minimum_required(VERSION 3.20)

# Only set compilers if not using a toolchain file (i.e., building on host macOS)
if(NOT CMAKE_TOOLCHAIN_FILE)
  # Check if we're on macOS with Homebrew LLVM
  if(APPLE AND EXISTS "/opt/homebrew/opt/llvm/bin/clang")
    set(CMAKE_C_COMPILER /opt/homebrew/opt/llvm/bin/clang)
    set(CMAKE_CXX_COMPILER /opt/homebrew/opt/llvm/bin/clang++)
  endif()
endif()

project(TCS_Helper LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 20)

# If cross-compiling (or the compiler does not support automated module scanning),
# disable CMake's C++ module scanning which requires a working compiler-assisted
# dependency discovery. This avoids the "compiler does not provide a way to
# discover the import graph dependencies" CMake error in cross-compile/devcontainer.
if(CMAKE_CROSSCOMPILING OR NOT CMAKE_CXX_COMPILER_ID)
  set(CMAKE_CXX_SCAN_FOR_MODULES OFF CACHE BOOL "Disable C++ module import scanning" FORCE)
endif()

# Only apply macOS-specific settings when building on host macOS (not cross-compiling)
if(APPLE AND NOT CMAKE_CROSSCOMPILING)
  if(NOT CMAKE_OSX_SYSROOT)
    execute_process(COMMAND xcrun --show-sdk-path
                    OUTPUT_VARIABLE _MACOS_SDK_PATH
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_QUIET)
    if(_MACOS_SDK_PATH AND EXISTS "${_MACOS_SDK_PATH}")
      set(CMAKE_OSX_SYSROOT "${_MACOS_SDK_PATH}" CACHE PATH "macOS SDK root" FORCE)
      message(STATUS "CMAKE_OSX_SYSROOT set to ${CMAKE_OSX_SYSROOT}")
    else()
      message(WARNING "Could not determine macOS SDK path via xcrun; ensure Xcode Command Line Tools are installed: xcode-select --install")
    endif()
  endif()
endif()

# Create executable
add_executable(TCS_Helper main.cpp)

# Add C++20 modules. When cross-compiling or if the compiler doesn't support
# module dependency scanning, add the modules as regular source files instead
# of using FILE_SET CXX_MODULES (which requires scanning support).
if(CMAKE_CROSSCOMPILING OR NOT CMAKE_CXX_COMPILER_ID)
  # Cross-compiling: add modules as regular source files
  target_sources(TCS_Helper PRIVATE
      lib/dataclasses.ixx
      lib/meet_manager.ixx
  )
  message(STATUS "Adding module files as regular sources (cross-compiling or no compiler ID)")
else()
  # Native build with module support: use FILE_SET CXX_MODULES for proper dependency scanning
  target_sources(TCS_Helper
      PRIVATE
          FILE_SET
              CXX_MODULES
          BASE_DIRS
              lib
          FILES
              lib/dataclasses.ixx
              lib/meet_manager.ixx
  )
  message(STATUS "Using FILE_SET CXX_MODULES for module dependency scanning")
endif()

# Only apply Homebrew-specific include/link settings when building on host macOS
if(APPLE AND NOT CMAKE_CROSSCOMPILING AND EXISTS "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain")
  # Use system-provided libc++ instead of Homebrew's libc++
  target_include_directories(TCS_Helper PRIVATE /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1)
  target_link_directories(TCS_Helper PRIVATE /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib)
endif()

# Ensure libc++ is used (works on both host and cross-compile)
target_compile_options(TCS_Helper PRIVATE -stdlib=libc++ -Wno-duplicate-decl-specifier)
target_compile_definitions(TCS_Helper PRIVATE _LIBCPP_DISABLE_PROMOTE)
target_link_options(TCS_Helper PRIVATE -stdlib=libc++)

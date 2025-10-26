# Set the target system to Darwin (macOS)
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_OSX_SYSROOT /opt/osxcross/target/SDK/MacOSX.sdk)

# Build for ARM64 (Apple Silicon)
set(CMAKE_OSX_ARCHITECTURES "arm64")

# Try multiple possible ARM64 compiler names that osxcross might create
set(POSSIBLE_C_COMPILERS
  "/opt/osxcross/target/bin/arm64-apple-darwin23-clang"
  "/opt/osxcross/target/bin/aarch64-apple-darwin23-clang"
  "/opt/osxcross/target/bin/o64-clang"
  "/opt/osxcross/target/bin/oa64-clang"
)

set(POSSIBLE_CXX_COMPILERS
  "/opt/osxcross/target/bin/arm64-apple-darwin23-clang++"
  "/opt/osxcross/target/bin/aarch64-apple-darwin23-clang++"
  "/opt/osxcross/target/bin/o64-clang++"
  "/opt/osxcross/target/bin/oa64-clang++"
)

# Find the first available C compiler
foreach(compiler ${POSSIBLE_C_COMPILERS})
  if(EXISTS "${compiler}")
    set(CMAKE_C_COMPILER "${compiler}")
    message(STATUS "Found ARM64 C compiler: ${compiler}")
    break()
  endif()
endforeach()

# Find the first available C++ compiler
foreach(compiler ${POSSIBLE_CXX_COMPILERS})
  if(EXISTS "${compiler}")
    set(CMAKE_CXX_COMPILER "${compiler}")
    message(STATUS "Found ARM64 C++ compiler: ${compiler}")
    break()
  endif()
endforeach()

# Fallback if no osxcross compiler found
if(NOT CMAKE_C_COMPILER)
  message(WARNING "No ARM64 osxcross C compiler found — using system clang with -target flag")
  find_program(CMAKE_C_COMPILER clang)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -target arm64-apple-darwin")
endif()

if(NOT CMAKE_CXX_COMPILER)
  message(WARNING "No ARM64 osxcross C++ compiler found — using system clang++ with -target flag")
  find_program(CMAKE_CXX_COMPILER clang++)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -target arm64-apple-darwin")
endif()

set(CMAKE_C_FLAGS "-O3 -Wall")
set(CMAKE_CXX_FLAGS "-O3 -Wall -std=c++20")

# Optional: Link-time optimization for speed
set(CMAKE_EXE_LINKER_FLAGS "-flto")

# glslang-zig

Zig bindings, build system and package for the Khronos reference frontend for
glsl, [glslang](https://github.com/KhronosGroup/glslang).

This project contains a clean-room zig build system for glslang, which only
depends on zig. Changes required to build glslang are kept up to date when
needed. This project allows for linking to glslang statically, as well as
producing the glslang compiler driver executable.

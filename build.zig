pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const glslang_dep = builder.dependency("glslang", .{});

    const glslang_module = builder.addModule("glslang-zig", .{
        .root_source_file = builder.path("src/root.zig"),
        .link_libcpp = true,
        .link_libc = true,
        .sanitize_c = false,
    });

    glslang_module.addIncludePath(glslang_dep.path(""));
    glslang_module.addCSourceFiles(.{
        .root = glslang_dep.path(""),
        .files = &[_][]const u8{
            //cinterface
            "glslang/CInterface/glslang_c_interface.cpp",

            //Codegen
            "glslang/GenericCodeGen/Link.cpp",
            "glslang/GenericCodeGen/CodeGen.cpp",

            //Preprocessor
            "glslang/MachineIndependent/preprocessor/Pp.cpp",
            "glslang/MachineIndependent/preprocessor/PpAtom.cpp",
            "glslang/MachineIndependent/preprocessor/PpContext.cpp",
            "glslang/MachineIndependent/preprocessor/PpScanner.cpp",
            "glslang/MachineIndependent/preprocessor/PpTokens.cpp",

            "glslang/MachineIndependent/limits.cpp",
            "glslang/MachineIndependent/linkValidate.cpp",
            "glslang/MachineIndependent/parseConst.cpp",
            "glslang/MachineIndependent/ParseContextBase.cpp",
            "glslang/MachineIndependent/ParseHelper.cpp",
            "glslang/MachineIndependent/PoolAlloc.cpp",
            "glslang/MachineIndependent/reflection.cpp",
            "glslang/MachineIndependent/RemoveTree.cpp",
            "glslang/MachineIndependent/Scan.cpp",
            "glslang/MachineIndependent/ShaderLang.cpp",
            "glslang/MachineIndependent/SpirvIntrinsics.cpp",
            "glslang/MachineIndependent/SymbolTable.cpp",
            "glslang/MachineIndependent/Versions.cpp",
            "glslang/MachineIndependent/Intermediate.cpp",
            "glslang/MachineIndependent/Constant.cpp",
            "glslang/MachineIndependent/attribute.cpp",
            "glslang/MachineIndependent/glslang_tab.cpp",
            "glslang/MachineIndependent/InfoSink.cpp",
            "glslang/MachineIndependent/Initialize.cpp",
            "glslang/MachineIndependent/intermOut.cpp",
            "glslang/MachineIndependent/IntermTraverse.cpp",
            "glslang/MachineIndependent/propagateNoContraction.cpp",
            "glslang/MachineIndependent/iomapper.cpp",

            //OsDependent
            switch (target.result.os.tag) {
                .linux => "glslang/OSDependent/Unix/ossource.cpp",
                .windows => "glslang/OSDependent/Windows/ossource.cpp",
                else => return error.UnsupportedOs,
            },

            "glslang/ResourceLimits/resource_limits_c.cpp",
            "glslang/ResourceLimits/ResourceLimits.cpp",

            //SPIRV backend
            "SPIRV/CInterface/spirv_c_interface.cpp",
            "SPIRV/GlslangToSpv.cpp",
            "SPIRV/SpvPostProcess.cpp",
            "SPIRV/SPVRemapper.cpp",
            "SPIRV/SpvTools.cpp",
            "SPIRV/SpvBuilder.cpp",
            "SPIRV/Logger.cpp",
            "SPIRV/InReadableOrder.cpp",
            "SPIRV/doc.cpp",
        },
        .flags = &[_][]const u8{},
    });

    const lib_unit_tests = builder.addTest(.{
        .root_source_file = builder.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_unit_tests.is_linking_libc = true;

    const run_lib_unit_tests = builder.addRunArtifact(lib_unit_tests);

    const test_step = builder.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const std = @import("std");

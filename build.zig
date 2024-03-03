const std = @import("std");

pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const glslang_dep = builder.dependency("glslang", .{});

    const glslang_module = builder.addModule("glslang-zig", .{
        .root_source_file = .{ .path = "src/root.zig" },
        .link_libcpp = true,
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
    glslang_module.sanitize_c = false;

    const lib = builder.addStaticLibrary(.{
        .name = "glslang-zig",
        .target = target,
        .optimize = optimize,
    });

    lib.root_module.addImport("glslang", glslang_module);

    builder.installArtifact(lib);

    // const exe = builder.addExecutable(.{
    //     .name = "glslang-zig",
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // builder.installArtifact(exe);

    // const run_cmd = builder.addRunArtifact(exe);

    // run_cmd.step.dependOn(builder.getInstallStep());

    // if (builder.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // const run_step = builder.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = builder.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = builder.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = builder.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = builder.addRunArtifact(exe_unit_tests);

    const test_step = builder.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

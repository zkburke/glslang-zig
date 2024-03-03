//! Khronos reference frontend for glsl

pub fn init() error{FailedToInitializeProcess}!void {
    if (glslang_c.glslang_initialize_process() == 0) {
        return error.FailedToInitializeProcess;
    }
}

pub fn deinit() void {
    glslang_c.glslang_finalize_process();
}

pub const ShaderInput = struct {
    language: SourceLanguage = .glsl,
    stage: Stage,
    source: [:0]const u8,
    include_local_fn: glslang_c.glsl_include_local_func = null,
    include_system_fn: glslang_c.glsl_include_local_func = null,
    include_context: ?*anyopaque = null,

    pub const SourceLanguage = enum {
        glsl,
    };

    pub const Stage = enum {
        vertex,
        fragment,
        compute,
    };

    pub const IncludeLocalFn = fn (
        context: ?*anyopaque,
        header_name: [*c]const u8,
        includer_name: [*c]const u8,
        include_depth: usize,
    ) callconv(.C) [*c]glslang_c.glsl_include_result_t;
};

pub const Shader = opaque {
    pub fn init(
        input: ShaderInput,
        options: packed struct {
            auto_map_locations: bool = false,
        },
    ) error{FailedToCreateShader}!*Shader {
        const glslang_input = shaderInputToCStruct(input);

        const shader = glslang_c.glslang_shader_create(@ptrCast(&glslang_input)) orelse return error.FailedToCreateShader;

        if (options.auto_map_locations) {
            glslang_c.glslang_shader_set_options(shader, glslang_c.GLSLANG_SHADER_AUTO_MAP_LOCATIONS);
        }

        return @ptrCast(shader);
    }

    pub fn deinit(self: *Shader) void {
        glslang_c.glslang_shader_delete(@ptrCast(self));
    }

    pub fn getInfoLog(self: *Shader) [:0]const u8 {
        return std.mem.span(@as([*:0]const u8, @ptrCast(glslang_c.glslang_shader_get_info_log(@ptrCast(self)))));
    }

    pub fn compile(self: *Shader) error{
        ParseFailed,
        PreprocessFailed,
        LinkFailed,
    }!struct {
        spirv: []u32,
    } {
        _ = self; // autofix
    }
};

inline fn shaderInputToCStruct(
    input: ShaderInput,
) glslang_c.glslang_input_s {
    return .{
        .language = switch (input.language) {
            .glsl => glslang_c.GLSLANG_SOURCE_GLSL,
        },
        .stage = switch (input.stage) {
            .vertex => glslang_c.GLSLANG_STAGE_VERTEX,
            .fragment => glslang_c.GLSLANG_STAGE_FRAGMENT,
            .compute => glslang_c.GLSLANG_STAGE_COMPUTE,
        },
        .client = glslang_c.GLSLANG_CLIENT_VULKAN,
        .client_version = glslang_c.GLSLANG_TARGET_VULKAN_1_3,
        .target_language = glslang_c.GLSLANG_TARGET_SPV,
        .target_language_version = glslang_c.GLSLANG_TARGET_SPV_1_5,
        .code = @ptrCast(input.source.ptr),
        .default_version = 450,
        .default_profile = glslang_c.GLSLANG_NO_PROFILE,
        .force_default_version_and_profile = @intFromBool(false),
        .forward_compatible = @intFromBool(false),
        .messages = glslang_c.GLSLANG_MSG_DEFAULT_BIT | glslang_c.GLSLANG_MSG_DEBUG_INFO_BIT | glslang_c.GLSLANG_MSG_ENHANCED | glslang_c.GLSLANG_MSG_CASCADING_ERRORS_BIT,
        .resource = glslang_default_resource(),
        .callbacks = .{
            .include_local = input.include_local_fn,
            .include_system = input.include_system_fn,
            .free_include_result = null,
        },
        .context = input.include_context,
    };
}

const glslang_c = @cImport(
    @cInclude("glslang/Include/glslang_c_interface.h"),
);

///Not specified by glslang_c_interface.h
extern fn glslang_default_resource() callconv(.C) *const glslang_c.glslang_resource_t;

test {
    std.testing.refAllDecls(@This());
}

const std = @import("std");

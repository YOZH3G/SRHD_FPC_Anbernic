// Planet generation only. SDL still owns all scene composition and presentation.
#include "planet.h"
#include "shaders.h"
#include <SDL.h>
#include <GLES3/gl31.h>
#include <array>
#include <cstdlib>
#include <cstring>
#include <unordered_map>

namespace {
uint32_t generation, renderer_generation;
SDL_GLContext context;
GLuint programs[2], vertex_array;
bool failed, initialized, drawing_failed;
GLuint compute_programs[2];
bool compute_requested, compute_supported, compute_initialized, compute_failed, dispatching;
bool compute_forced, diagnostics;
int dispatch_width, dispatch_height;
uint64_t renders, fallbacks;
#ifdef RANGERS_GPU_PLANET_TEST
int compute_attempts;
#endif
struct OutputTarget {
    GLuint framebuffer{}, texture{};
    SDL_Texture *output{};
    uint64_t serial{};
    bool complete{};
    bool immutable{};
};
std::unordered_map<void *, std::array<OutputTarget, 4>> outputs;

void failure(const char *reason) {
    if (fallbacks++ < 8)
        SDL_Log("GPU planet fallback: %s (renders=%llu)", reason,
                static_cast<unsigned long long>(renders));
}

// No SDL calls occur while this guard is active. Restore everything the helper
// changes so SDL's private cached state remains valid, including other texture units.
struct State {
    GLint program, draw_fbo, read_fbo, vao, active, viewport[4], unpack[4], pbo;
    GLint textures[6], samplers[6];
    GLint image[6];
    bool save_image;
    GLboolean blend, depth, stencil, cull, scissor, dither, mask[4];
    State(bool compute = false): save_image(compute) {
        glGetIntegerv(GL_CURRENT_PROGRAM, &program);
        glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &draw_fbo);
        glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING, &read_fbo);
        glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &vao);
        glGetIntegerv(GL_ACTIVE_TEXTURE, &active);
        glGetIntegerv(GL_VIEWPORT, viewport);
        glGetIntegerv(GL_UNPACK_ALIGNMENT, &unpack[0]);
        glGetIntegerv(GL_UNPACK_ROW_LENGTH, &unpack[1]);
        glGetIntegerv(GL_UNPACK_SKIP_PIXELS, &unpack[2]);
        glGetIntegerv(GL_UNPACK_SKIP_ROWS, &unpack[3]);
        glGetIntegerv(GL_PIXEL_UNPACK_BUFFER_BINDING, &pbo);
        blend = glIsEnabled(GL_BLEND);
        depth = glIsEnabled(GL_DEPTH_TEST);
        stencil = glIsEnabled(GL_STENCIL_TEST);
        cull = glIsEnabled(GL_CULL_FACE);
        scissor = glIsEnabled(GL_SCISSOR_TEST);
        dither = glIsEnabled(GL_DITHER);
        glGetBooleanv(GL_COLOR_WRITEMASK, mask);
        if (save_image) {
            const GLenum fields[] = {GL_IMAGE_BINDING_NAME, GL_IMAGE_BINDING_LEVEL,
                GL_IMAGE_BINDING_LAYERED, GL_IMAGE_BINDING_LAYER,
                GL_IMAGE_BINDING_ACCESS, GL_IMAGE_BINDING_FORMAT};
            for (int i = 0; i < 6; ++i) glGetIntegeri_v(fields[i], 0, &image[i]);
        }
        for (int i = 0; i < 6; ++i) {
            glActiveTexture(GL_TEXTURE0 + i);
            glGetIntegerv(GL_TEXTURE_BINDING_2D, &textures[i]);
            glGetIntegerv(GL_SAMPLER_BINDING, &samplers[i]);
            glBindSampler(i, 0);
        }
        glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
        glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
        glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
    }
    static void enable(GLenum capability, GLboolean enabled) {
        if (enabled) glEnable(capability); else glDisable(capability);
    }
    ~State() {
        glUseProgram(program);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, draw_fbo);
        glBindFramebuffer(GL_READ_FRAMEBUFFER, read_fbo);
        glBindVertexArray(vao);
        glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);
        glPixelStorei(GL_UNPACK_ALIGNMENT, unpack[0]);
        glPixelStorei(GL_UNPACK_ROW_LENGTH, unpack[1]);
        glPixelStorei(GL_UNPACK_SKIP_PIXELS, unpack[2]);
        glPixelStorei(GL_UNPACK_SKIP_ROWS, unpack[3]);
        glBindBuffer(GL_PIXEL_UNPACK_BUFFER, pbo);
        enable(GL_BLEND, blend);
        enable(GL_DEPTH_TEST, depth);
        enable(GL_STENCIL_TEST, stencil);
        enable(GL_CULL_FACE, cull);
        enable(GL_SCISSOR_TEST, scissor);
        enable(GL_DITHER, dither);
        glColorMask(mask[0], mask[1], mask[2], mask[3]);
        for (int i = 0; i < 6; ++i) {
            glActiveTexture(GL_TEXTURE0 + i);
            glBindTexture(GL_TEXTURE_2D, textures[i]);
            glBindSampler(i, samplers[i]);
        }
        glActiveTexture(active);
        if (save_image)
            glBindImageTexture(0, image[0], image[1], image[2], image[3], image[4], image[5]);
    }
};

GLuint shader(GLenum type, const char *source) {
    GLuint result = glCreateShader(type);
    if (type == GL_COMPUTE_SHADER) {
        const char *parts[] = {"#version 310 es\n#define COMPUTE\n", std::strchr(source, '\n') + 1};
        glShaderSource(result, 2, parts, nullptr);
    } else {
        glShaderSource(result, 1, &source, nullptr);
    }
    glCompileShader(result);
    GLint success;
    glGetShaderiv(result, GL_COMPILE_STATUS, &success);
    if (!success) {
        char message[2048];
        glGetShaderInfoLog(result, sizeof(message), nullptr, message);
        SDL_Log("GPU planet shader: %s", message);
        glDeleteShader(result);
        return 0;
    }
    return result;
}

bool setup() {
    if (initialized) return !failed;
    initialized = true;
    constexpr const char *vertex = R"GLSL(#version 300 es
    void main() {
        vec2 p = vec2(float((gl_VertexID << 1) & 2), float(gl_VertexID & 2));
        gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
    })GLSL";
    GLuint vs = shader(GL_VERTEX_SHADER, vertex);
    if (!vs) return !(failed = true);
    const char *sources[] = {planet_fs, atmosphere_fs};
    for (int i = 0; i < 2; ++i) {
        GLuint fs = shader(GL_FRAGMENT_SHADER, sources[i]);
        if (!fs) { failed = true; break; }
        programs[i] = glCreateProgram();
        glAttachShader(programs[i], vs);
        glAttachShader(programs[i], fs);
        glLinkProgram(programs[i]);
        glDeleteShader(fs);
        GLint success;
        glGetProgramiv(programs[i], GL_LINK_STATUS, &success);
        if (!success) { failed = true; break; }
    }
    glDeleteShader(vs);
    glGenVertexArrays(1, &vertex_array);
    SDL_Log("GPU planet shaders: %s", failed ? "unavailable" : "ready");
    return !failed;
}

bool setup_compute() {
    if (compute_initialized) return !compute_failed;
    compute_initialized = true;
#ifdef RANGERS_GPU_PLANET_TEST
    ++compute_attempts;
    if (std::getenv("RANGERS_GPU_PLANET_TEST_COMPUTE_FAILURE")) {
        compute_failed = true;
        failure("injected compute initialization failure");
        return false;
    }
#endif
    const char *sources[] = {planet_fs, atmosphere_fs};
    for (int i = 0; i < 2; ++i) {
        GLuint cs = shader(GL_COMPUTE_SHADER, sources[i]);
        if (!cs) { compute_failed = true; break; }
        compute_programs[i] = glCreateProgram();
        glAttachShader(compute_programs[i], cs);
        glLinkProgram(compute_programs[i]);
        glDeleteShader(cs);
        GLint success;
        glGetProgramiv(compute_programs[i], GL_LINK_STATUS, &success);
        if (!success) { compute_failed = true; break; }
    }
    if (compute_failed)
        for (auto &program : compute_programs) {
            if (program) glDeleteProgram(program);
            program = 0;
        }
    SDL_Log("GPU planet compute: %s", compute_failed ? "unavailable" : "ready");
    return !compute_failed;
}
}

#ifdef RANGERS_GPU_PLANET_TEST
extern "C" int sr_planet_test_compute_attempts() { return compute_attempts; }
#endif
uint32_t rangers_gpu_generation() { return generation; }
void rangers_gpu_release_outputs(void *object) {
    if (!object) return;
    auto found = outputs.find(object);
    if (found == outputs.end()) return;
    if (SDL_GL_GetCurrentContext() == context)
        for (auto &target : found->second)
            if (target.framebuffer) glDeleteFramebuffers(1, &target.framebuffer);
    outputs.erase(found);
}
void rangers_gpu_destroy_image(rangers_gpu_image image) {
    if (SDL_GL_GetCurrentContext() == context) glDeleteTextures(1, &image);
}
rangers_gpu_image rangers_gpu_create_image(int width, int height, int format, int) {
    const GLenum internal[] = {GL_R8, GL_RG8, GL_RGBA8, GL_RGBA32F};
    const GLenum external[] = {GL_RED, GL_RG, GL_RGBA, GL_RGBA};
    GLuint result;
    glGenTextures(1, &result);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, result);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, internal[format], width, height, 0, external[format],
                 format == RANGERS_GPU_RGBA32F ? GL_FLOAT : GL_UNSIGNED_BYTE, nullptr);
    if (glGetError() != GL_NO_ERROR) {
        glDeleteTextures(1, &result);
        return 0;
    }
    return result;
}
int rangers_gpu_upload(rangers_gpu_image image, int x, int y, int width, int height,
                      const void *pixels, int pitch, int format) {
    const GLenum external[] = {GL_RED, GL_RG, GL_RGBA, GL_RGBA};
    const int bytes[] = {1, 2, 4, 16};
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, image);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, pitch / bytes[format]);
    glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, external[format],
                    format == RANGERS_GPU_RGBA32F ? GL_FLOAT : GL_UNSIGNED_BYTE, pixels);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
    return glGetError() == GL_NO_ERROR;
}
void rangers_gpu_draw_material(int material, const rangers_gpu_image *images, int image_count,
                              const float *uniforms, int uniform_count,
                              const rangers_gpu_vertex *, int) {
    GLuint program = (dispatching ? compute_programs : programs)[material == RANGERS_GPU_PLANET ? 0 : 1];
    glUseProgram(program);
    const char *planet_names[] = {"projection_tex", "map_tex", "light_tex", "palette_tex",
                                  "cosine_tex", "light_rotation_tex"};
    const char *atmosphere_names[] = {"atmosphere_tex", "atmosphere_mask_tex",
                                      "atmosphere_rotation_tex"};
    const char **names = material == RANGERS_GPU_PLANET ? planet_names : atmosphere_names;
    for (int i = 0; i < image_count; ++i) {
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, images[i]);
        glUniform1i(glGetUniformLocation(program, names[i]), i);
    }
    const char *params[] = {"params0", "params1", "params2"};
    for (int i = 0; i < uniform_count; ++i)
        glUniform4fv(glGetUniformLocation(program, params[i]), 1, uniforms + i * 4);
    if (dispatching) {
        // Finish previously queued texture readers before replacing their pixels.
        glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);
        glDispatchCompute((dispatch_width + 7) / 8, (dispatch_height + 7) / 8, 1);
        glMemoryBarrier(GL_TEXTURE_FETCH_BARRIER_BIT | GL_FRAMEBUFFER_BARRIER_BIT |
                        GL_TEXTURE_UPDATE_BARRIER_BIT);
    } else {
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
    drawing_failed = glGetError() != GL_NO_ERROR;
#ifdef RANGERS_GPU_PLANET_TEST
    if (dispatching && std::getenv("RANGERS_GPU_PLANET_TEST_DRAW_FAILURE"))
        drawing_failed = true;
#endif
}

extern "C" int sr_planet_available(SDL_Renderer *renderer, uint32_t current_generation) {
    const char *enabled = std::getenv("RANGERS_GPU_PLANETS");
    if (enabled && !std::strcmp(enabled, "0")) return 0;
    compute_forced = enabled && !std::strcmp(enabled, "compute");
    // An explicit "1"/"fbo" retains the measured raster backend for comparisons.
    // The default chooses compute when supported and falls back to raster once.
    compute_requested = !enabled || !*enabled || !std::strcmp(enabled, "auto") || compute_forced;
    SDL_RendererInfo info{};
    if (SDL_GetRendererInfo(renderer, &info) || std::strcmp(info.name, "opengles2")) return 0;
    auto current = SDL_GL_GetCurrentContext();
    if (renderer_generation != current_generation || context != current) {
        // Only context initialization needs a global barrier. The public texture
        // bind below flushes queued consumers of the specific output texture.
        if (SDL_RenderFlush(renderer)) return 0;
        current = SDL_GL_GetCurrentContext();
        renderer_generation = current_generation;
        ++generation;
        context = current;
        initialized = failed = false;
        compute_initialized = compute_failed = false;
        const char *logging = std::getenv("RANGERS_GPU_PLANET_DIAGNOSTICS");
        diagnostics = logging && !std::strcmp(logging, "1");
        programs[0] = programs[1] = vertex_array = 0;
        compute_programs[0] = compute_programs[1] = 0;
        // The old context owns these names; deleting them in the new context
        // could delete unrelated objects whose numeric names were recycled.
        outputs.clear();
        const char *version = reinterpret_cast<const char *>(glGetString(GL_VERSION));
        compute_supported = version && (std::strstr(version, "OpenGL ES 3.1") ||
                                         std::strstr(version, "OpenGL ES 3.2"));
        SDL_Log("GPU planet context: %s generation=%u", version ? version : "none", generation);
        if (!version || !std::strstr(version, "OpenGL ES 3.")) {
            initialized = failed = true;
            failure("GLES 3 required for exact integer lookup arithmetic");
        }
    }
    return !failed && (!compute_forced || (compute_supported && !compute_failed));
}

extern "C" int sr_planet_render_versioned(void *object, int layer, int offset, uint32_t color,
                                         SDL_Renderer *renderer, SDL_Texture *output,
                                         uint32_t current_generation, uint64_t output_serial) {
    if (!object || layer < -1 || layer > 3) return 0;
    if (!sr_planet_available(renderer, current_generation)) return 0;
    OutputTarget *target;
    try { target = &outputs[object][layer < 0 ? 0 : layer]; }
    catch (...) { failure("output cache allocation"); return 0; }
    Uint32 format;
    int width, height;
    if (SDL_QueryTexture(output, &format, nullptr, &width, &height) ||
        format != SDL_PIXELFORMAT_ARGB8888) return 0;
    if (SDL_GL_BindTexture(output, nullptr, nullptr)) return 0;
    GLint output_name;
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &output_name);
    int success = 0;
    bool compute = compute_requested && compute_supported && !compute_failed;
    {
        State state(compute);
        bool ready = compute ? setup_compute() : setup();
        if (!ready && compute && !compute_forced) {
            compute = false;
            ready = setup();
        }
        if (ready) {
            if (target->output &&
                (target->serial != output_serial || target->output != output ||
                 target->texture != GLuint(output_name))) {
                if (target->framebuffer) glDeleteFramebuffers(1, &target->framebuffer);
                *target = {};
            }
            target->texture = output_name;
            target->output = output;
            target->serial = output_serial;
            if (compute && !target->immutable) {
                GLint immutable;
                glBindTexture(GL_TEXTURE_2D, output_name);
                glGetTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_IMMUTABLE_FORMAT, &immutable);
                if (!immutable) glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA8, width, height);
                target->immutable = glGetError() == GL_NO_ERROR;
            }
            if (!compute && !target->framebuffer) {
                glGenFramebuffers(1, &target->framebuffer);
                glBindFramebuffer(GL_FRAMEBUFFER, target->framebuffer);
                glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D,
                                       output_name, 0);
                target->complete = glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE;
            } else if (!compute) {
                glBindFramebuffer(GL_FRAMEBUFFER, target->framebuffer);
            }
            if (compute ? target->immutable : target->complete) {
                dispatching = compute;
                dispatch_width = width;
                dispatch_height = height;
                if (compute)
                    glBindImageTexture(0, output_name, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA8);
                else {
                    glViewport(0, 0, width, height);
                    glDisable(GL_SCISSOR_TEST);
                    glDisable(GL_BLEND);
                    glDisable(GL_DEPTH_TEST);
                    glDisable(GL_STENCIL_TEST);
                    glDisable(GL_CULL_FACE);
                    glDisable(GL_DITHER);
                    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
                    glBindVertexArray(vertex_array);
                }
                drawing_failed = false;
                rangers_gpu_vertex dummy{};
                if (layer >= 0)
                    success = rangers_gpu_planet_draw(object, layer, offset, 0, &dummy, 3);
                else
                    success = rangers_gpu_atmosphere_draw(object, color, 0, &dummy, 3);
                success = success && !drawing_failed;
            }
        }
    }
    SDL_GL_UnbindTexture(output);
    if (!success) {
        // A failed optional backend must not repeat binding/dispatch work every
        // frame. Auto mode can try the raster backend on the next complete draw.
        if (compute) compute_failed = true; else failed = true;
        failure(compute ? "compute generation disabled for this context" :
                          "raster generation disabled for this context");
    } else if (++renders == 1 || (diagnostics && renders % 600 == 0))
        SDL_Log("GPU planet textures: renders=%llu fallbacks=%llu",
                static_cast<unsigned long long>(renders),
                static_cast<unsigned long long>(fallbacks));
    return success;
}

// Compatibility for diagnostic builds made before output realization serials
// were added. Production callers use the versioned entry point, since both SDL
// pointers and GL texture names can be recycled after texture replacement.
extern "C" int sr_planet_render(void *object, int layer, int offset, uint32_t color,
                               SDL_Renderer *renderer, SDL_Texture *output,
                               uint32_t current_generation) {
    return sr_planet_render_versioned(object, layer, offset, color, renderer, output,
                                     current_generation, 0);
}

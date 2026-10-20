#include "planet.h"
#include "../../vendor/okgf/include/okgf.h"
#include <algorithm>
#include <array>
#include <cstring>
#include <memory>
#include <vector>

namespace {
constexpr uint8_t cosine_light[64 * 64] = {
#include "../../vendor/okgf/src/tables/planet_light_table.inc"
};

struct Image {
    int width = 0, height = 0, format = RANGERS_GPU_R8, stride = 0;
    uint32_t generation = 0;
    rangers_gpu_image handle = 0;
    std::vector<uint8_t> data;
    bool dirty = true;
    ~Image() { release(); }
    void release() {
        if (handle && generation == rangers_gpu_generation())
            rangers_gpu_destroy_image(handle);
        handle = 0;
    }
    void allocate(int w, int h, int fmt, int bytes_per_pixel) {
        if (width != w || height != h || format != fmt)
            release();
        width = w;
        height = h;
        format = fmt;
        stride = w * bytes_per_pixel;
        data.assign(size_t(stride) * h, 0);
        dirty = true;
    }
    bool realize() {
        if (data.empty())
            return false;
        if (generation != rangers_gpu_generation()) {
            handle = 0;
            dirty = true;
        }
        generation = rangers_gpu_generation();
        if (!handle) {
            handle = rangers_gpu_create_image(width, height, format, 0);
            dirty = true;
        }
        if (!handle)
            return false;
        if (dirty) {
            if (!rangers_gpu_upload(handle, 0, 0, width, height, data.data(), stride, format))
                return false;
            dirty = false;
        }
        return true;
    }
};

struct Layer {
    Image map, palette;
    int variant = 0;
};
struct Planet {
    Image projection, light, cosine, rotation;
    std::array<Layer, 4> layers;
    int light_width = 0, light_height = 0, light_x = 0, light_y = 0, angle = 0;
    bool rotated = false;
};
struct Atmosphere {
    Image image, mask, rotation;
    int angle = 0;
};

bool dimensions(int w, int h) { return w > 0 && h > 0 && w <= 16384 && h <= 16384; }

bool import_rotation(Image &out, const void *rotation, int width, int height) {
    if (!rotation || !dimensions(width, height) || size_t(height) * 512 * 16 > 16 * 1024 * 1024)
        return false;
    Image lookup;
    // Two RGBA32F texels per scanline, one pair per angle. Integer high/low
    // halves of the signed 16.16 steps are exactly representable as floats.
    // This is O(height) records per angle, not 256 precomposed pixel masks.
    lookup.allocate(512, height, RANGERS_GPU_RGBA32F, 16);
    const auto &source = *static_cast<const OkgfRotationBuffer *>(rotation);
    for (int angle = 0; angle < 256; ++angle) {
        const auto &frame = source.frames[angle];
        if (frame.scanline_count < 0 || frame.scanline_count > 32768 ||
            (frame.scanline_count && !frame.scanlines))
            return false;
        for (int row = 0; row < frame.scanline_count; ++row) {
            const int64_t y = int64_t(height / 2) + frame.dest_y + row;
            if (y < 0 || y >= height)
                continue;
            const auto &line = frame.scanlines[row];
            if (line.pixel_count < 0 || line.pixel_count > 32768 || line.dest_x < -32768 ||
                line.dest_x > 32767 || line.source_x_start < -32768 ||
                line.source_x_start > 32767 || line.source_y_start < -32768 ||
                line.source_y_start > 32767)
                return false;
            const float values[] = {
                float(width / 2 + line.dest_x),
                float(line.pixel_count),
                float(line.source_x_start),
                float(line.source_y_start),
                float((int64_t(line.source_dx_16_16) - (uint32_t(line.source_dx_16_16) & 65535)) /
                      65536),
                float(uint32_t(line.source_dx_16_16) & 65535),
                float((int64_t(line.source_dy_16_16) - (uint32_t(line.source_dy_16_16) & 65535)) /
                      65536),
                float(uint32_t(line.source_dy_16_16) & 65535)};
            std::memcpy(lookup.data.data() + (size_t(y) * 512 + angle * 2) * 16, values,
                        sizeof(values));
        }
    }
    out.release();
    out.width = lookup.width;
    out.height = lookup.height;
    out.format = lookup.format;
    out.stride = lookup.stride;
    out.data.swap(lookup.data);
    out.dirty = true;
    return true;
}
} // namespace

extern "C" void *rangers_gpu_planet_create(const void *projection, int width, int height) {
    if (!projection || !dimensions(width, height))
        return nullptr;
    try {
        auto result = std::make_unique<Planet>();
        result->projection.allocate(width, height, RANGERS_GPU_RGBA32F, 16);
        result->light.allocate(width, height, RANGERS_GPU_R8, 1);
        result->cosine.allocate(64, 64, RANGERS_GPU_R8, 1);
        result->rotation.allocate(1, 1, RANGERS_GPU_RGBA32F, 16);
        std::memcpy(result->cosine.data.data(), cosine_light, sizeof(cosine_light));
        const auto &templ = *static_cast<const OkgfPlanetTemplate *>(projection);
        if (templ.height <= 0 || !templ.scanlines)
            return nullptr;
        for (int row = 0; row < templ.height; ++row) {
            const auto &line = templ.scanlines[row];
            const int y = height / 2 + templ.origin_y + row;
            if (y < 0 || y >= height)
                continue;
            if (line.pixel_count < 0 || !line.samples)
                return nullptr;
            for (int i = 0; i < line.pixel_count; ++i) {
                const int x = width / 2 + line.dest_x + i;
                if (x < 0 || x >= width)
                    continue;
                const bool edge =
                    i < line.left_alpha_count || i >= line.left_alpha_count + line.opaque_count;
                const float value[4] = {float(line.samples[i].source_x), float(line.source_y),
                                        float(line.samples[i].edge_alpha63), edge ? 2.0f : 1.0f};
                std::memcpy(result->projection.data.data() + size_t(y * width + x) * sizeof(value),
                            value, sizeof(value));
            }
        }
        return result.release();
    } catch (...) {
        return nullptr;
    }
}

extern "C" void rangers_gpu_planet_destroy(void *planet) {
    rangers_gpu_release_outputs(planet);
    delete static_cast<Planet *>(planet);
}

extern "C" int rangers_gpu_planet_layer(void *planet, int layer, const void *pixels, int width,
                                        int height, int pitch, int bytes_per_pixel,
                                        const void *palette, int palette_count, int variant) {
    if (!planet || layer < 0 || layer >= 4 || !pixels || !palette || !dimensions(width, height) ||
        (bytes_per_pixel != 1 && bytes_per_pixel != 2) || pitch < width * bytes_per_pixel ||
        palette_count < 1 || palette_count > 256 || variant < 2 || variant > 4 ||
        (variant > 2 && bytes_per_pixel != 2) || (width & (width - 1)))
        return 0;
    try {
        auto &dest = static_cast<Planet *>(planet)->layers[layer];
        dest.map.allocate(width, height, RANGERS_GPU_RG8, 2);
        const auto *source = static_cast<const uint8_t *>(pixels);
        for (int y = 0; y < height; ++y)
            for (int x = 0; x < width; ++x) {
                dest.map.data[size_t(y * width + x) * 2] =
                    source[size_t(y) * pitch + x * bytes_per_pixel];
                dest.map.data[size_t(y * width + x) * 2 + 1] =
                    bytes_per_pixel == 2 ? source[size_t(y) * pitch + x * 2 + 1] : 0;
            }
        dest.palette.allocate(64, 256, RANGERS_GPU_RGBA8, 4);
        // Palette data is explicitly little endian, like the OKGF decoder.
        const auto *colors = static_cast<const uint8_t *>(palette);
        for (int i = 0; i < 64 * palette_count; ++i) {
            const unsigned c = colors[2 * i] | (unsigned(colors[2 * i + 1]) << 8);
            auto *rgba = dest.palette.data.data() + 4 * i;
            rgba[0] = uint8_t((c >> 8) & 248);
            rgba[1] = uint8_t((c >> 3) & 252);
            rgba[2] = uint8_t(c << 3);
            rgba[3] = 255;
        }
        dest.variant = variant;
        return 1;
    } catch (...) {
        return 0;
    }
}

extern "C" int rangers_gpu_planet_light(void *planet, const void *light) {
    if (!planet || !light)
        return 0;
    try {
        auto &p = *static_cast<Planet *>(planet);
        auto &dest = p.light;
        const auto &source = *static_cast<const OkgfLightBuffer *>(light);
        if (!source.pixels || source.pitch_bytes < source.width)
            return 0;
        if (p.rotated)
            dest.allocate(p.projection.width, p.projection.height, RANGERS_GPU_R8, 1);
        p.rotated = false;
        // The projection is centered at width/2,height/2 by the legacy draw entry.
        // Cropping makes the per-fragment light lookup a single fetch.
        std::fill(dest.data.begin(), dest.data.end(), 0);
        for (int y = 0; y < dest.height; ++y) {
            const int sy = source.origin_y + y - dest.height / 2;
            if (sy < 0 || sy >= source.height)
                continue;
            for (int x = 0; x < dest.width; ++x) {
                const int sx = source.origin_x + x - dest.width / 2;
                if (sx >= 0 && sx < source.width)
                    dest.data[size_t(y) * dest.width + x] =
                        source.pixels[size_t(sy) * source.pitch_bytes + sx];
            }
        }
        dest.dirty = true;
        return 1;
    } catch (...) {
        return 0;
    }
}

extern "C" int rangers_gpu_planet_light_source(void *planet, const void *light,
                                               const void *rotation) {
    if (!planet || !light || !rotation)
        return 0;
    const auto &source = *static_cast<const OkgfLightBuffer *>(light);
    // Transparent BYTE rotation reads two adjacent bytes, including initialized
    // row padding at the right edge. Preserve that second byte explicitly.
    if (!source.pixels || source.width <= 0 || source.width >= 16384 ||
        !dimensions(source.width + 1, source.height) || source.origin_x < -32768 ||
        source.origin_x > 32767 || source.origin_y < -32768 || source.origin_y > 32767 ||
        source.pitch_bytes <= source.width)
        return 0;
    try {
        auto &p = *static_cast<Planet *>(planet);
        if (!import_rotation(p.rotation, rotation, p.projection.width, p.projection.height))
            return 0;
        p.light.allocate(source.width + 1, source.height, RANGERS_GPU_R8, 1);
        for (int y = 0; y < source.height; ++y)
            std::memcpy(p.light.data.data() + size_t(y) * p.light.width,
                        source.pixels + size_t(y) * source.pitch_bytes, p.light.width);
        p.light_width = source.width;
        p.light_height = source.height;
        p.light_x = source.origin_x;
        p.light_y = source.origin_y;
        p.rotated = true;
        return 1;
    } catch (...) {
        return 0;
    }
}

extern "C" void rangers_gpu_planet_light_angle(void *planet, int angle) {
    if (planet)
        static_cast<Planet *>(planet)->angle = uint8_t(angle);
}

extern "C" int rangers_gpu_planet_draw(void *planet, int layer, int map_offset, int linear,
                                       const rangers_gpu_vertex *vertices, int count) {
    if (!planet || layer < 0 || layer >= 4 || !vertices || count <= 0)
        return 0;
    auto &p = *static_cast<Planet *>(planet);
    auto &l = p.layers[layer];
    if (!l.variant || !p.projection.realize() || !p.light.realize() || !p.cosine.realize() ||
        !l.map.realize() || !l.palette.realize() || !p.rotation.realize())
        return 0;
    const rangers_gpu_image images[] = {p.projection.handle, l.map.handle,    p.light.handle,
                                        l.palette.handle,    p.cosine.handle, p.rotation.handle};
    const float uniforms[] = {float(uint32_t(map_offset) & uint32_t(l.map.width - 1)),
                              float(l.map.width),
                              float(l.variant),
                              float(linear != 0),
                              float(p.projection.width),
                              float(p.projection.height),
                              float(p.angle),
                              float(p.rotated),
                              float(p.light_width),
                              float(p.light_height),
                              float(p.light_x),
                              float(p.light_y)};
    rangers_gpu_draw_material(RANGERS_GPU_PLANET, images, 6, uniforms, 3, vertices, count);
    return 1;
}

extern "C" int rangers_gpu_planet_ready(void *planet) {
    if (!planet)
        return 0;
    auto &p = *static_cast<Planet *>(planet);
    if (!p.projection.realize() || !p.light.realize() || !p.cosine.realize() ||
        !p.rotation.realize())
        return 0;
    for (auto &layer : p.layers)
        if (layer.variant && (!layer.map.realize() || !layer.palette.realize()))
            return 0;
    return 1;
}

extern "C" void *rangers_gpu_atmosphere_create(const void *image, int width, int height,
                                               int pitch) {
    if (!image || !dimensions(width, height) || pitch < width)
        return nullptr;
    try {
        auto result = std::make_unique<Atmosphere>();
        result->image.allocate(width, height, RANGERS_GPU_R8, 1);
        result->mask.allocate(width, height, RANGERS_GPU_R8, 1);
        for (int y = 0; y < height; ++y)
            std::memcpy(result->image.data.data() + size_t(y) * width,
                        static_cast<const uint8_t *>(image) + size_t(y) * pitch, width);
        return result.release();
    } catch (...) {
        return nullptr;
    }
}

extern "C" void rangers_gpu_atmosphere_destroy(void *atmosphere) {
    rangers_gpu_release_outputs(atmosphere);
    delete static_cast<Atmosphere *>(atmosphere);
}

extern "C" int rangers_gpu_atmosphere_mask(void *atmosphere, const void *mask, int width,
                                           int height, int pitch, const void *rotation, int angle) {
    if (!rangers_gpu_atmosphere_source(atmosphere, mask, width, height, pitch, rotation))
        return 0;
    rangers_gpu_atmosphere_angle(atmosphere, angle);
    return 1;
}

extern "C" int rangers_gpu_atmosphere_source(void *atmosphere, const void *mask, int width,
                                             int height, int pitch, const void *rotation) {
    if (!atmosphere || !mask || !rotation || !dimensions(width, height) || pitch < width)
        return 0;
    try {
        auto &p = *static_cast<Atmosphere *>(atmosphere);
        if (!import_rotation(p.rotation, rotation, p.image.width, p.image.height))
            return 0;
        p.mask.allocate(width, height, RANGERS_GPU_R8, 1);
        for (int y = 0; y < height; ++y)
            std::memcpy(p.mask.data.data() + size_t(y) * width,
                        static_cast<const uint8_t *>(mask) + size_t(y) * pitch, width);
        return 1;
    } catch (...) {
        return 0;
    }
}

extern "C" void rangers_gpu_atmosphere_angle(void *atmosphere, int angle) {
    if (atmosphere)
        static_cast<Atmosphere *>(atmosphere)->angle = uint8_t(angle);
}

extern "C" int rangers_gpu_atmosphere_draw(void *atmosphere, uint32_t color, int linear,
                                           const rangers_gpu_vertex *vertices, int count) {
    if (!atmosphere || !vertices || count <= 0)
        return 0;
    auto &p = *static_cast<Atmosphere *>(atmosphere);
    if (!p.image.realize() || !p.mask.realize() || !p.rotation.realize())
        return 0;
    const rangers_gpu_image images[] = {p.image.handle, p.mask.handle, p.rotation.handle};
    const float uniforms[] = {float(color & 248) / 255,
                              float((color >> 8) & 248) / 255,
                              float((color >> 16) & 248) / 255,
                              float(linear != 0),
                              float(p.image.width),
                              float(p.image.height),
                              float(p.angle),
                              0};
    rangers_gpu_draw_material(4 /* RANGERS_GPU_ATMOSPHERE */, images, 3, uniforms, 2, vertices,
                              count);
    return 1;
}

extern "C" int rangers_gpu_atmosphere_ready(void *atmosphere) {
    if (!atmosphere)
        return 0;
    auto &p = *static_cast<Atmosphere *>(atmosphere);
    return p.image.realize() && p.mask.realize() && p.rotation.realize();
}

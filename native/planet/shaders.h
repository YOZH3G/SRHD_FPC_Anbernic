// Exact legacy lookup arithmetic; generated textures use SDL ARGB8888 byte order.
static constexpr const char *planet_fs = R"GLSL(#version 300 es
precision highp float;
precision highp int;
uniform vec4 params0; // map offset, map width, variant (2/3/4), linear filtering
uniform vec4 params1; // projection width, height, light angle, rotated light
uniform vec4 params2; // original light width, height, origin x, origin y
uniform highp sampler2D projection_tex;
uniform highp sampler2D map_tex;
uniform highp sampler2D light_tex;
uniform highp sampler2D palette_tex;
uniform highp sampler2D cosine_tex;
uniform highp sampler2D light_rotation_tex;


#ifdef COMPUTE
layout(local_size_x=8, local_size_y=8) in;
layout(rgba8, binding=0) writeonly uniform highp image2D output_tex;
#else
out vec4 frag_color;
#endif
ivec2 light_pair(ivec2 p) {
    ivec2 size = textureSize(light_tex,0);
    if (p.x < 0 || p.y < 0 || p.x+1 >= size.x || p.y >= size.y) return ivec2(0);
    return ivec2(floor(vec2(texelFetch(light_tex,p,0).r,
        texelFetch(light_tex,p+ivec2(1,0),0).r)*255.0+0.5));
}
ivec2 light_source(ivec4 line, ivec4 step, int sample_index) {
    // Split multiplication is exact for the original signed 16.16 walker and
    // samples 0..32767, without relying on float interpolation or 64-bit GLSL.
    return line.zw + ivec2(step.x*sample_index+((step.y*sample_index)>>16),
        step.z*sample_index+((step.w*sample_index)>>16));
}
int light_value(ivec2 p) {
    if (params1.w < 0.5)
        return int(floor(texelFetch(light_tex,p,0).r*255.0+0.5));
    ivec2 original = p + ivec2(params2.zw) - ivec2(params1.xy)/2;
    if (any(lessThan(original,ivec2(0))) || any(greaterThanEqual(original,ivec2(params2.xy)))) return 0;
    int column = int(params1.z)*2;
    ivec4 line = ivec4(texelFetch(light_rotation_tex,ivec2(column,p.y),0));
    ivec4 step = ivec4(texelFetch(light_rotation_tex,ivec2(column+1,p.y),0));
    int sample_index = p.x-line.x;
    if (sample_index >= 0 && sample_index < line.y) {
        ivec2 value = light_pair(light_source(line,step,sample_index));
        if (any(notEqual(value,ivec2(0)))) return value.x;
    }
    // The legacy transparent BYTE entry writes overlapping two-byte samples.
    // A transparent current word leaves the previous sample's high byte intact.
    if (original.x > 0 && sample_index > 0 && sample_index <= line.y)
        return light_pair(light_source(line,step,sample_index-1)).y;
    return 0;
}
vec4 planet_texel(ivec2 p) {
    p = clamp(p, ivec2(0), ivec2(params1.xy)-ivec2(1));
    vec4 projection = texelFetch(projection_tex, p, 0);
    if (projection.w < 0.5) return vec4(0.0);
    int sx = int(mod(projection.x + params0.x, params0.y));
    ivec2 source = ivec2(sx, int(projection.y));
    ivec2 texel = ivec2(floor(texelFetch(map_tex, source, 0).rg * 255.0 + 0.5));
    int bucket = light_value(p) / 4;
    if (params0.z == 3.0)
        bucket = int(floor(texelFetch(cosine_tex, ivec2(texel.y / 4,bucket), 0).r * 255.0 + 0.5));
    vec4 result = texelFetch(palette_tex, ivec2(bucket,texel.x), 0);
    bool edge = projection.w > 1.5;
    int alpha = edge ? int(projection.z) : 63;
    if (params0.z == 4.0) {
        alpha = edge ? (alpha * (texel.y / 4) + 31) / 63 : texel.y / 4;
        result.a = float(edge ? alpha * 4 : texel.y) / 255.0;
    } else {
        result.a = edge ? float(alpha * 4) / 255.0 : 1.0;
    }
    return result;
}
void main() {
#ifdef COMPUTE
    ivec2 p = ivec2(gl_GlobalInvocationID.xy);
    if (any(greaterThanEqual(p, ivec2(params1.xy)))) return;
    imageStore(output_tex, p, planet_texel(p).bgra);
#else
    frag_color = planet_texel(ivec2(gl_FragCoord.xy)).bgra;
#endif
}
)GLSL";

static constexpr const char *atmosphere_fs = R"GLSL(#version 300 es
precision highp float;
precision highp int;
uniform vec4 params0; // quantized RGB, linear filtering
uniform vec4 params1; // image width, height, angle
uniform highp sampler2D atmosphere_tex;
uniform highp sampler2D atmosphere_mask_tex;
uniform highp sampler2D atmosphere_rotation_tex;


#ifdef COMPUTE
layout(local_size_x=8, local_size_y=8) in;
layout(rgba8, binding=0) writeonly uniform highp image2D output_tex;
#else
out vec4 frag_color;
#endif
int atmosphere_mask(ivec2 p) {
    int column = int(params1.z)*2;
    ivec4 line = ivec4(texelFetch(atmosphere_rotation_tex,ivec2(column,p.y),0));
    int sample_index = p.x-line.x;
    if (sample_index < 0 || sample_index >= line.y) return 0;
    ivec4 step = ivec4(texelFetch(atmosphere_rotation_tex,ivec2(column+1,p.y),0));
    ivec2 source = line.zw + ivec2(step.x*sample_index+((step.y*sample_index)>>16),
        step.z*sample_index+((step.w*sample_index)>>16));
    ivec2 size = textureSize(atmosphere_mask_tex,0);
    if (any(lessThan(source,ivec2(0))) || any(greaterThanEqual(source,size))) return 0;
    return int(floor(texelFetch(atmosphere_mask_tex,source,0).r*255.0+0.5));
}
float atmosphere_alpha(ivec2 p) {
    p = clamp(p, ivec2(0), ivec2(params1.xy)-ivec2(1));
    int image_value = int(floor(texelFetch(atmosphere_tex, p, 0).r * 255.0 + 0.5));
    int mask_value = atmosphere_mask(p);
    return float(((image_value * mask_value + 127) / 255) / 8 * 8) / 255.0;
}
void main() {
#ifdef COMPUTE
    ivec2 p = ivec2(gl_GlobalInvocationID.xy);
    if (any(greaterThanEqual(p, ivec2(params1.xy)))) return;
    imageStore(output_tex, p, vec4(params0.rgb, atmosphere_alpha(p)).bgra);
#else
    frag_color = vec4(params0.rgb, atmosphere_alpha(ivec2(gl_FragCoord.xy))).bgra;
#endif
}
)GLSL";

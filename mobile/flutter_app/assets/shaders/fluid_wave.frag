#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_color;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / u_resolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    float d = length(uv);
    
    // Wave distortion
    vec2 wave_uv = uv;
    wave_uv.x += sin(u_time * 2.0 + uv.y * 5.0) * 0.1;
    wave_uv.y += cos(u_time * 1.5 + uv.x * 4.0) * 0.1;

    // Glowing fluid math
    float fluid = 0.05 / length(wave_uv);
    
    // Smooth coloring over time
    vec3 color = u_color * fluid;
    color *= vec3(sin(u_time) * 0.5 + 0.5, cos(u_time * 1.2) * 0.5 + 0.5, 1.0);

    // Vignette
    float vignette = 1.0 - smoothstep(0.5, 1.5, d);
    color *= vignette;

    fragColor = vec4(color, 1.0);
}

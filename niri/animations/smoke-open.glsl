// Smoke Open Animation Shader
// ─────────────────────────────────────────────────────────────────────────────
// Fluid dissipate effect: window appears from smoke/mist using Perlin-like noise
// Time: 0.0 → 1.0 (normalized animation duration)
// ─────────────────────────────────────────────────────────────────────────────

#version 330 core

in vec2 uv;
out vec4 out_color;

uniform sampler2D u_texture;
uniform float u_time;           // 0.0 to 1.0
uniform float u_animation_progress;

// Simple noise function (Perlin-like)
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Fractional Brownian Motion for smooth turbulence
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

void main() {
    vec2 coord = uv;
    float progress = u_animation_progress;
    
    // Generate turbulent noise pattern
    float noise_val = fbm(coord * 5.0 + vec2(0.0, progress * 2.0));
    
    // Create smoke/dissipation effect
    // Start with high threshold (mostly transparent) → reduce threshold (reveal texture)
    float threshold = mix(1.0, -0.2, progress);
    float smoke_mask = smoothstep(threshold, threshold + 0.3, noise_val);
    
    // Add subtle displacement to edges
    vec2 displacement = vec2(
        (noise_val - 0.5) * 0.02,
        (fbm(coord * 3.0) - 0.5) * 0.02
    ) * (1.0 - progress);
    
    vec2 sample_coord = coord + displacement;
    
    // Sample original texture
    vec4 original = texture(u_texture, sample_coord);
    
    // Blend: start transparent, end opaque
    float alpha = mix(0.0, original.a, smoke_mask);
    
    out_color = vec4(original.rgb, alpha);
}

// Glitch Open Animation Shader
// ─────────────────────────────────────────────────────────────────────────────
// Chromatic aberration + scanlines reveal effect
// Creates digital glitch distortion as window opens
// Time: 0.0 → 1.0 (normalized animation duration)
// ─────────────────────────────────────────────────────────────────────────────

#version 330 core

in vec2 uv;
out vec4 out_color;

uniform sampler2D u_texture;
uniform float u_time;
uniform float u_animation_progress;

// Pseudo-random function
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
    vec2 coord = uv;
    float progress = u_animation_progress;
    
    // ─── Glitch displacement offset ────────────────────────────────────────
    // Random glitch offset based on scanlines
    float glitch_amount = (1.0 - progress) * 0.1;  // Decreases as animation progresses
    float glitch_line = floor(coord.y * 80.0);    // 80 scanlines
    float line_hash = hash(vec2(glitch_line, u_time));
    
    // Create vertical jitter effect
    float glitch_offset = (line_hash - 0.5) * 2.0 * glitch_amount;
    
    // ─── Chromatic aberration (RGB channel separation) ─────────────────────
    // Start with high aberration, fade out to normal
    float aberration = mix(0.03, 0.0, progress);
    
    vec2 offset_r = vec2(aberration, 0.0);
    vec2 offset_g = vec2(0.0, 0.0);
    vec2 offset_b = vec2(-aberration, 0.0);
    
    // Apply glitch displacement
    offset_r.x += glitch_offset;
    offset_b.x += glitch_offset;
    
    // Sample color channels separately
    float r = texture(u_texture, coord + offset_r).r;
    float g = texture(u_texture, coord + offset_g).g;
    float b = texture(u_texture, coord + offset_b).b;
    vec4 original = texture(u_texture, coord);
    
    // Reassemble with chromatic aberration
    vec4 glitched = vec4(r, g, b, original.a);
    
    // ─── Scanlines effect ──────────────────────────────────────────────────
    // Create horizontal lines that fade with progress
    float scanline = sin(coord.y * 3.14159 * 80.0) * 0.5 + 0.5;
    float scanline_intensity = mix(0.2, 0.0, progress);
    
    vec4 with_scanlines = glitched;
    with_scanlines.rgb *= (1.0 - scanline_intensity * scanline);
    
    // ─── Progressive reveal ────────────────────────────────────────────────
    // Sweep from top to bottom
    float reveal_mask = smoothstep(-0.1, 0.1, coord.y - progress * 1.2);
    
    // Blend between glitch effect and normal
    out_color = mix(with_scanlines, original, reveal_mask);
    
    // Fade in alpha
    out_color.a *= progress;
}

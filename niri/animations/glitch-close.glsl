// Glitch Close Animation Shader
// ─────────────────────────────────────────────────────────────────────────────
// Aggressive chromatic aberration + scanlines dissolution effect
// Creates intense digital glitch as window closes
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
    
    // ─── Intensifying glitch displacement ──────────────────────────────────
    // Maximum glitch at end (opposite of open animation)
    float glitch_amount = progress * 0.15;  // Increases with progress
    
    // Multiple scanline glitches
    float glitch_line1 = floor(coord.y * 60.0);
    float glitch_line2 = floor(coord.y * 120.0);
    float line_hash = hash(vec2(glitch_line1 + glitch_line2, u_time));
    
    // Create more aggressive vertical jitter
    float glitch_offset = (line_hash - 0.5) * 2.0 * glitch_amount;
    float glitch_offset2 = (hash(vec2(glitch_line2, u_time + 0.1)) - 0.5) * glitch_amount * 1.5;
    
    // ─── Aggressive chromatic aberration ───────────────────────────────────
    // Increase aberration as window closes
    float aberration = mix(0.0, 0.08, progress);
    
    vec2 offset_r = vec2(aberration, 0.0);
    vec2 offset_g = vec2(0.0, aberration * 0.5);
    vec2 offset_b = vec2(-aberration, 0.0);
    
    // Apply glitch displacement
    offset_r += vec2(glitch_offset + glitch_offset2 * 0.5, 0.0);
    offset_b += vec2(glitch_offset - glitch_offset2 * 0.5, 0.0);
    
    // Sample color channels with displacements
    float r = texture(u_texture, coord + offset_r).r;
    float g = texture(u_texture, coord + offset_g).g;
    float b = texture(u_texture, coord + offset_b).b;
    vec4 original = texture(u_texture, coord);
    
    // Reassemble with chromatic aberration
    vec4 glitched = vec4(r, g, b, original.a);
    
    // ─── Intense scanlines effect ──────────────────────────────────────────
    // Become more prominent as window closes
    float scanline = sin(coord.y * 3.14159 * 100.0) * 0.5 + 0.5;
    float scanline_intensity = mix(0.0, 0.4, progress);
    
    vec4 with_scanlines = glitched;
    with_scanlines.rgb *= (1.0 - scanline_intensity * scanline);
    
    // Add color shift during close (increased saturation)
    float color_shift = progress * 0.1;
    with_scanlines.r += color_shift * 0.5;
    with_scanlines.b -= color_shift * 0.3;
    
    // ─── Progressive dissolution ──────────────────────────────────────────
    // Shatter from center outward
    vec2 center = vec2(0.5, 0.5);
    vec2 to_center = coord - center;
    float dist_from_center = length(to_center);
    
    float dissolution_threshold = mix(0.0, 0.707, progress);  // 0.707 = sqrt(2)/2
    float dissolve_mask = smoothstep(dissolution_threshold + 0.1, dissolution_threshold - 0.1, dist_from_center);
    
    // ─── Final blend and alpha fade ────────────────────────────────────────
    out_color = mix(with_scanlines, original, dissolve_mask);
    
    // Fade out alpha (reverse of open)
    out_color.a *= (1.0 - progress);
}

shader_type canvas_item;

uniform vec4 color_center : source_color = vec4(0.9, 0.8, 0.95, 1.0);
uniform vec4 color_outer : source_color = vec4(0.45, 0.20, 0.65, 1.0);
uniform float radius : hint_range(0.1, 2.0) = 0.8;
uniform float softness : hint_range(0.1, 2.0) = 1.0;
uniform vec2 center = vec2(0.5, 0.5);
uniform float aspect_y : hint_range(0.1, 3.0) = 1.0; // ← contrôle l’étirement vertical

void fragment() {
    vec2 uv = UV - center;
    uv.y *= aspect_y; // ← on étire verticalement le dégradé
    float dist = length(uv * 2.0);
    float t = smoothstep(radius, radius - softness, dist);
    COLOR = mix(color_center, color_outer, t);
}
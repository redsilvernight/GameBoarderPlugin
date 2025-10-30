shader_type canvas_item;

uniform float radius = 20.0;

void fragment() {
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pos = UV * size;
	vec2 half_size = size * 0.5;

	float dist = length(max(abs(pos - half_size) - half_size + radius, 0.0));
	float alpha = 1.0 - smoothstep(radius - 1.0, radius + 1.0, dist);

	COLOR = texture(TEXTURE, UV);
	COLOR.a *= alpha;
}
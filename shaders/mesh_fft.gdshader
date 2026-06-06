shader_type spatial;
render_mode world_vertex_coords, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D color;
uniform sampler2D data_tex;
uniform int data_size;
uniform float max_radius = 0.7;
uniform float height_scale = 1.0;
uniform float texel = 0.015625;

void vertex() {
	float dist = distance(vec2(0.,0.), VERTEX.xz);
	float u = clamp(dist / max_radius, 0.0, 1.0);
	float height = texture(data_tex, vec2(u, 0.5)).r;
    VERTEX.y = height * height_scale;
}
void fragment() {
	float dist = length(VERTEX.xz);
	float u = clamp(dist / max_radius, 0.0, 1.0);

	float h  = texture(data_tex, vec2(u, 0.5)).r * height_scale;
	float hl = texture(data_tex, vec2(u - texel, 0.5)).r * height_scale;
	float hr = texture(data_tex, vec2(u + texel, 0.5)).r * height_scale;

	float hx = hr - hl;

	// fake tangent directions
	vec3 dx = vec3(1.0, hx, 0.0);
	vec3 dz = vec3(0.0, 1.0, 1.0);

	NORMAL = normalize(cross(dz, dx));
}
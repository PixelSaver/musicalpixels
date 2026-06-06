shader_type spatial;
render_mode wireframe;

uniform sampler2D color;
uniform sampler2D data_tex;
uniform sampler2D noise_tex;
uniform sampler2D gradient;
uniform int data_size;
uniform float max_radius = 0.7;
uniform float height_scale = 1.0;
uniform float texel = 0.015625;
uniform float max_energy;
uniform float noise_level;

void vertex() {
	float dist = distance(vec2(0.,0.), VERTEX.xz);
	float u = clamp(dist / max_radius, 0.0, 1.0);
	float height = texture(data_tex, vec2(u, 0.5)).r;
	float n = texture(noise_tex, VERTEX.xz + vec2(sin(TIME*.1)*0.3, cos(TIME*.1+1.3)*1.4)).y;
    float y = height * height_scale + n * noise_level * log(max_energy + 1.) * .01;
	VERTEX.y = y;
	float t = clamp(
		(y - 0.1) / (80. - 0.1),
		0.0,
		1.0
	);
	COLOR = texture(gradient, vec2(t, 0.5));
}
void fragment() {
	ALBEDO = COLOR.rgb;
}
	//float dist = length(VERTEX.xz);
	//float u = clamp(dist / max_radius, 0.0, 1.0);
//
	//float h  = texture(data_tex, vec2(u, 0.5)).r * height_scale;
	//float hl = texture(data_tex, vec2(u - texel, 0.5)).r * height_scale;
	//float hr = texture(data_tex, vec2(u + texel, 0.5)).r * height_scale;
//
	//float hx = hr - hl;
//
	//// fake tangent directions
	//vec3 dx = vec3(1.0, hx, 0.0);
	//vec3 dz = vec3(0.0, 1.0, 1.0);
//
	//NORMAL = normalize(cross(dz, dx));
//}
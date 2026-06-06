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
	float og_len = length(VERTEX.xyz);
	vec3 dir = normalize(VERTEX.xyz);
	vec3 blend = abs(dir);
	blend = pow(blend, vec3(4.0)); // sharpness of blend
	blend /= blend.x + blend.y + blend.z;

	float nx = texture(noise_tex, dir.yz).r;
	float ny = texture(noise_tex, dir.xz).r;
	float nz = texture(noise_tex, dir.xy).r;
	float n = nx * blend.x + ny * blend.y + nz * blend.z;

	float u = atan(dir.z, dir.x) / (2.0 * PI) + 0.5;
	float height = texture(data_tex, vec2(u, 0.5)).r;
	float y = height * height_scale + n * noise_level * log(max_energy + 1.) * 0.01;
	y = y + og_len;
	VERTEX = dir * y;
	float t = clamp(
		y/ 8.,
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
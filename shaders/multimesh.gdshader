shader_type spatial;
uniform sampler2D data_tex;
uniform float rings = 3.0;
uniform float points = 5.0;

uniform float radius_step = 3.;
uniform float height_scale = 50.0;

uniform sampler2D noise_tex;
uniform float noise_level;

void vertex() {
	float ring = INSTANCE_CUSTOM.r * rings;
	float point = INSTANCE_CUSTOM.g * points;
	float angle = point/points * TAU;
	float radius = 1.5 + (ring) * radius_step;
	
	vec3 base = vec3(0.);
	base.x = cos(angle) * radius;
	base.z = sin(angle) * radius;
	
	float fft = texture(
		data_tex,
		vec2(ring / rings, 0.5)
	).r;
	
	vec3 offset;
	offset.y = fft * height_scale;
	vec2 uv = base.xz * 0.2 + TIME * .1;
	
	float ny = texture(noise_tex, uv).r * noise_level * ring;
	offset.y += (ny - 0.5) * 2.0;
	float nx = texture(noise_tex, fract(uv+ny)).r * noise_level * ring;
	offset.x = (nx - 0.5) * 2.0;
	float nz = texture(noise_tex, fract(uv+ny*.3)).r * noise_level * ring;
	offset.z = (nz - 0.5) * 2.0;
	
	VERTEX += base + offset;
}
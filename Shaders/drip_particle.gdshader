shader_type particles;

uniform vec4 drip_shade : hint_color = vec4(1f);
uniform vec4 fall_shade : hint_color = vec4(1f);
uniform sampler2D surface_texture;
uniform vec2 surface_offset;
uniform vec2 emission_bounds;
uniform vec3 gravity = vec3(0.0, 98.0, 0.0);
uniform float jam_friction = 20.0;


float rand_from_seed(inout uint seed){
	int k;
	int s = int(seed);
	if (s == 0)
		s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

vec2 rand_vec2(inout uint seed){
	return vec2(
		rand_from_seed(seed),
		rand_from_seed(seed)
	);
}

uint hash(uint x){
	x = ((x >> uint(16)) ^ x) * uint (73244475);
	x = ((x >> uint(16)) ^ x) * uint (73244475);
	return (x >> uint(16)) ^ x;
}

vec4 surface_color_at(vec2 pos){
	vec2 surfSize = vec2(textureSize(surface_texture, 0));
	return texture(surface_texture, pos/surfSize);
}

float normalized_range(float minv, float maxv, float v){
	if (minv > maxv){return 0.0;}
	if (minv == maxv){return (v == maxv) ? 1.0 : 0.0;}
	float dist = maxv - minv;
	return max(0.0, min(1.0, (v-minv) / dist));
	
}

void vertex(){
	uint seed = hash(NUMBER + uint(1) + RANDOM_SEED);
	
	vec4 color = drip_shade;//color_falling;
	
	if (RESTART){
		vec2 spawn_pos = (rand_vec2(seed) * emission_bounds);
		vec4 surfColor = surface_color_at(spawn_pos + surface_offset);
		if (surfColor.a != 0f){
			TRANSFORM[3].xy = spawn_pos;
			if (rand_from_seed(seed) < 0.5)
				TRANSFORM[0].x *= -1f;
			VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
			TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
			VELOCITY.z = 0.0;
			TRANSFORM[3].z = 0.0;
		} else {
			color = vec4(0f);
			ACTIVE = false;
		}
	} else {
		vec4 surfColor = surface_color_at(TRANSFORM[3].xy + surface_offset);
		vec3 force = gravity + ((surfColor.a != 0f) ? (VELOCITY * -jam_friction) : vec3(0f));
		VELOCITY += force * DELTA;
		color = mix(drip_shade, fall_shade, normalized_range(16f, 28f, VELOCITY.y));
		//color = (VELOCITY.y < 10.0) ? drip_shade : fall_shade;
		//color = (surfColor.a != 0f) ? mix(mix(surfColor, vec4(0,0,0,1), 0.75), drip_shade, 0.35) : fall_shade;
	}
	COLOR = color;
}
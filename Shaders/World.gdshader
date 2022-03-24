shader_type canvas_item;

uniform vec4 portal_color : hint_color = vec4(1);
uniform float blend : hint_range(0.0, 1.0) = 0.0;
uniform float transit : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture;
uniform sampler2D real_world;
uniform sampler2D alt_world;
uniform bool in_real_world = true;


vec4 calculate_color(vec2 uv, float time){
	vec4 from_color = (in_real_world) ? texture(real_world, uv) : texture(alt_world, uv);
	vec4 to_color = (in_real_world) ? texture(alt_world, uv) : texture(real_world, uv);
	float ht = 0.1 * transit;

	if (distance(portal_color, from_color) < 0.001){
		return to_color;
	}
	
	//float noise = step(texture(noise_texture, uv).x, smoothstep(-0.5, 1.0, transit));
	float noise = mix(0.5, 1.5, texture(noise_texture, uv * normalize(vec2(sin(time), cos(time)))).x);
	float max_dist = 0.7071 * transit; // Distance between (0, 0) and (0.5, 0.5) multiplied by transit
	float uv_distance = distance(uv, vec2(0.5, 0.5)) * noise;
	float weight = step(uv_distance, max_dist);
	
	/*if (invert)
		weight = 1.0 - weight;
	if (uv_distance < max_dist && uv_distance >= max_dist - wave_thickness)
		weight = step(noise, shift_blend);*/
	return mix(from_color, to_color, weight);
}


void fragment() {
	//COLOR = texture(noise_texture, UV);
	COLOR = calculate_color(UV, TIME);
}
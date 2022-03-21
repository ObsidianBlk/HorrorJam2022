shader_type canvas_item;

uniform vec4 portal_color : hint_color = vec4(1);
uniform sampler2D noise_texture;
uniform sampler2D real_world;
uniform sampler2D alt_world;
uniform float blend : hint_range(0.0, 1.0) = 0.0;
uniform float wave_thickness : hint_range(0.0, 1.0) = 0.2;
uniform bool invert = false;


vec4 calculate_color(vec2 uv, float time){
	float shift_blend = ((invert) ? 1.0 : blend * 2f) - blend;
	
	vec4 color = vec4(1);
	if (blend <= 0.5f){
		color = texture(real_world, uv);
	} else {
		color = texture(alt_world, uv);
	}
	

	if (distance(portal_color, color) < 0.001){
		color = mix(texture(real_world, uv), texture(alt_world, uv), 1.0 - blend);
	} else {
		float max_dist = 0.7071 * shift_blend; // Distance between (0, 0) and (0.5, 0.5) multiplied by blend
		float uv_distance = distance(uv, vec2(0.5, 0.5));
		float noise = texture(noise_texture, uv).x;
		float weight = step(uv_distance, max_dist);
		if (invert)
			weight = 1.0 - weight;
		if (uv_distance < max_dist && uv_distance >= max_dist - wave_thickness)
			weight = step(noise, shift_blend);
		color = mix(texture(real_world, uv), texture(alt_world, uv), weight);
	}
	
	return color;
}


void fragment() {
	//COLOR = texture(noise_texture, UV);
	COLOR = calculate_color(UV, TIME);
}
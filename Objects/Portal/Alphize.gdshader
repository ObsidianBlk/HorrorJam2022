shader_type canvas_item;
render_mode unshaded;

uniform vec4 replace_color : hint_color = vec4(1,1,1,1);
uniform float alpha_min : hint_range(0.0, 1.0) = 0.2;
uniform float alpha_max : hint_range(0.0, 1.0) = 1.0;
uniform float speed : hint_range(0.0, 10.0) = 0.2;

void fragment() {
	float PI = 3.14159;
	float alpha_dist = alpha_max - alpha_min;
	float dist = sin(mod(TIME * speed, PI));
	float alpha_shift = alpha_min + (dist * alpha_dist);
	
	vec4 color = texture(TEXTURE, UV);
	if (distance(color.rgb, vec3(0f)) < alpha_shift){
		color.a = 0f;
	} else {
		color = vec4(replace_color.rgb, 1);
	}
	COLOR = color;
}
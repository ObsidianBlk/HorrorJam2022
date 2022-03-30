shader_type canvas_item;
render_mode unshaded;

uniform vec4 replace_color : hint_color = vec4(1,1,1,1);

void fragment() {
	
	vec4 color = texture(TEXTURE, UV);
	if (distance(color.rgb, vec3(0f)) < 0.2){
		color.a = 0f;
	} else {
		color = vec4(replace_color.rgb, 1);
	}
	COLOR = color;
}
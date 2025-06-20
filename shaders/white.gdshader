shader_type canvas_item;

uniform bool active = false;

void fragment(){
	vec4 prev_color = texture(TEXTURE, UV);
	vec4 white = vec4(1.0, 1.0, 1.0, prev_color.a);
	vec4 new_color = prev_color;
	if(active == true){
		new_color = white;
	}
	COLOR = new_color;
}
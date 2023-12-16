shader_type canvas_item;

uniform bool tint;
uniform vec3 color;

void fragment() {
	// first greyscale
	COLOR.rgb = vec3(dot(COLOR.rgb, vec3(0.299, 0.587, 0.114)));
	
	// then apply tint
	if(tint){
		COLOR.rgb = (COLOR.rgb + color.rgb) / 2.0;
	}
	
	
}

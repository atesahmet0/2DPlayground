shader_type canvas_item;

uniform vec2 direction = vec2(1.0, 0.0);
uniform float velocity_scale = 0.2;

void fragment(){
	COLOR = texture(TEXTURE, UV + TIME * direction * velocity_scale);
}

shader_type canvas_item;

uniform vec2 direction = vec2(1.0, 0.0);
uniform float velocity_scale = 0.2;
global uniform float time_seed = 0;

void fragment(){
	COLOR = texture(TEXTURE, UV + time_seed * direction * velocity_scale);
}

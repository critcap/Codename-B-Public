shader_type canvas_item;

uniform float quanitity : hint_range(0.0, 1.0);
uniform vec4 tint : source_color = vec4(1.0);
uniform vec3 flash_color : source_color = vec3(1.0);
uniform vec3 danger_color : source_color = vec3(1.0,0.0,0.0);
uniform bool is_rotation = false;
uniform bool is_danger = false;
uniform float blink_frequency = 1.0;


void fragment() {
	vec4 base = texture(TEXTURE, UV) * tint;
	vec4 flash = vec4(flash_color, base.a);
	vec4 danger = vec4(danger_color, base.a);
	base = mix(base, flash, quanitity);
	base = mix(base, danger, min(.5*(1.0 + sin(2.0* PI * blink_frequency * TIME)), float(is_danger)));
	COLOR = base;
}

uniform float speed = 1.0;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x
	) + pivot;
}

void vertex() {
	if (is_rotation){
		VERTEX = rotateUV(VERTEX, vec2(0), TIME * speed);
	}
}
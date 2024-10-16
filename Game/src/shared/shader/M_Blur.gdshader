shader_type canvas_item;

uniform vec4 bg_color: source_color;
uniform float strength: hint_range(0.0, 10.0, 0.1);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, strength);
    COLOR = mix(color, bg_color, 0.4);
}
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 grid_size = vec2(10.0, 6.0);
uniform float feather : hint_range(0.0, 1.0) = 0.05;
uniform bool invert = false;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec2 grid = UV * grid_size;
    vec2 cell = floor(grid);
    
    float rnd = hash(cell);
    float cell_progress = clamp((progress - rnd * 0.3) * 1.5, 0.0, 1.0);
    vec4 base_color = vec4(0,0,0,1);
    vec2 local_uv = fract(grid);
    vec2 center_offset = abs(local_uv - 0.5);
    float dist_from_center = max(center_offset.x, center_offset.y);
    
    float growth_radius = cell_progress * 0.5;
    float cell_mask = smoothstep(growth_radius + feather, growth_radius, dist_from_center);
    
    if (invert) {
        cell_mask = 1.0 - cell_mask;
    }
    
   	COLOR = base_color;
    COLOR.a *= cell_mask;
	
	COLOR.rgb *= COLOR.a;
}
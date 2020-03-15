extern number threshold;
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
	if (pixel.b>=threshold){
		return pixel;
	} else {
		return vec4( 0.0, 0.0, 0.0, pixel.a );
	}
}

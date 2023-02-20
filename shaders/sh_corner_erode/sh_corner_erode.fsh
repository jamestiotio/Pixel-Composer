//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float size;

#define TAU   6.28318

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	float tau_div = TAU / 64.;
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(length(gl_FragColor.rgb) * gl_FragColor.a <= 0.) 
		return;
	
	for(float i = 1.; i <= size; i++)
	for(float j = 0.; j < 80.; j++) {
		float ang = j * tau_div;
		vec2 pxs = (pixelPosition + vec2( cos(ang) * i,  sin(ang) * i)) / dimension;
		
		if(pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.) {
			gl_FragColor = vec4(i / size, 0., 0., 1.);
			return;
		}
		
		vec4 sam = texture2D( gm_BaseTexture, pxs );
		if(length(sam.rgb) == 0.) {
			gl_FragColor = vec4(i / size, 0., 0., 1.);
			return;
		}
	}
}
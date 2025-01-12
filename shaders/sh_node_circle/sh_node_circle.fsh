varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;

void main() {
	float dist  = abs(length(v_vTexcoord - .5) * 2. - 0.9);
		  
	float a;
	vec4  c = vec4(0.);
	
	a = smoothstep(.1, .05, dist);
	c = mix(c, color, a);
	
	gl_FragColor = c;
}

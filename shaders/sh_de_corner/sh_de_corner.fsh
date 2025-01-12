//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float tolerance;
uniform int   strict;

float d(in vec4 c1, in vec4 c2) { return length(c1.rgb * c1.a - c2.rgb * c2.a) / sqrt(3.); }
bool  s(in vec4 c1, in vec4 c2) { return d(c1, c2) <= tolerance; }

float bright(in vec4 c) { return dot(c.rgb, vec3(0.2126, 0.7152, 0.0722)) * c.a; }

#region select closet color
	vec4  sel2(in vec4 c, in vec4 c0, in vec4 c1) {
		float d0 = d(c, c0);
		float d1 = d(c, c1);
	
		float mn = min(d0, d1);
	
		if(mn == d0) return c0;
		             return c1;
	}

	vec4  sel3(in vec4 c, in vec4 c0, in vec4 c1, in vec4 c2) {
		float d0 = d(c, c0);
		float d1 = d(c, c1);
		float d2 = d(c, c2);
	
		float mn = min(min(d0, d1), d2);
	
		if(mn == d0) return c0;
		if(mn == d1) return c1;
		             return c2;
	}

	vec4  sel4(in vec4 c, in vec4 c0, in vec4 c1, in vec4 c2, in vec4 c3) {
		float d0 = d(c, c0);
		float d1 = d(c, c1);
		float d2 = d(c, c2);
		float d3 = d(c, c3);
	
		float mn = min(min(d0, d1), min(d2, d3));
	
		if(mn == d0) return c0;
		if(mn == d1) return c1;
		if(mn == d2) return c2;
		             return c3;
	}
#endregion

vec4 sample(vec2 st) {
	if(st.x < 0. || st.y < 0.) return vec4(0.);
	if(st.x > 1. || st.y > 1.) return vec4(0.);
	return texture2D( gm_BaseTexture, st);
}

void main() {
	
	// 0 1 2 
	// 3 4 5
	// 6 7 8
	
	vec4 a4 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 tx = 1. / dimension;
	gl_FragColor = a4; 
	
	if(a4.a == 0.) return;
	
	vec4 a0 = sample( v_vTexcoord + vec2(-tx.x,  -tx.y) );
	vec4 a1 = sample( v_vTexcoord + vec2(    0., -tx.y) );
	vec4 a2 = sample( v_vTexcoord + vec2( tx.x,  -tx.y) );
													    
	vec4 a3 = sample( v_vTexcoord + vec2(-tx.x,     .0) );
	vec4 a5 = sample( v_vTexcoord + vec2( tx.x,     .0) );
													    
	vec4 a6 = sample( v_vTexcoord + vec2(-tx.x,   tx.y) );
	vec4 a7 = sample( v_vTexcoord + vec2(    0.,  tx.y) );
	vec4 a8 = sample( v_vTexcoord + vec2( tx.x,   tx.y) );
		
	if(strict == 0) {
		
		if(s(a4, a0) && s(a4, a1) && s(a4, a3) && !s(a4, a2) && !s(a4, a5) && !s(a4, a6) && !s(a4, a7) && !s(a4, a8)) {	// A A 2 
																														// A A 5
																														// 6 7 8
			gl_FragColor = sel3(a4, sel2(a4, a2, a6), sel2(a4, a5, a7), a8);
			return; 
		}
		
		if(s(a4, a1) && s(a4, a2) && s(a4, a5) && !s(a4, a0) && !s(a4, a3) && !s(a4, a6) && !s(a4, a7) && !s(a4, a8)) {	// 0 A A 
																														// 3 A A
																														// 6 7 8
			gl_FragColor = sel3(a4, sel2(a4, a0, a8), sel2(a4, a3, a7), a6);
			return;
		}
		
		if(s(a4, a3) && s(a4, a6) && s(a4, a7) && !s(a4, a0) && !s(a4, a1) && !s(a4, a2) && !s(a4, a5) && !s(a4, a8)) {	// 0 1 2 
																														// A A 5
																														// A A 8
			gl_FragColor = sel3(a4, sel2(a4, a0, a8), sel2(a4, a1, a5), a2);
			return;
		}
		
		if(s(a4, a5) && s(a4, a7) && s(a4, a8) && !s(a4, a0) && !s(a4, a1) && !s(a4, a2) && !s(a4, a3) && !s(a4, a6)) {	// 0 1 2 
																														// 3 A A
																														// 6 A A
			gl_FragColor = sel3(a4, sel2(a4, a2, a6), sel2(a4, a1, a3), a0);
			return;
		}
		
	} else if(strict == 1) {
		if(s(a5, a7) && s(a4, a1) && s(a4, a3) && s(a4, a0) && !s(a4, a2) && !s(a4, a5) && !s(a4, a6) && !s(a4, a7)) {	// B B C 
																														// B B A
																														// C A 8
			gl_FragColor = sel3(a4, sel2(a4, a2, a6), sel2(a4, a5, a7), a8);
			return;
		}
	
		if(s(a3, a7) && s(a4, a1) && s(a4, a2) && s(a4, a5) && !s(a4, a0) && !s(a4, a3) && !s(a4, a7) && !s(a4, a8)) {	// C B B 
																														// A B B
																														// 6 A C
			gl_FragColor = sel3(a4, sel2(a4, a0, a8), sel2(a4, a3, a7), a6);
			return;
		}
	
		if(s(a5, a1) && s(a4, a3) && s(a4, a6) && s(a4, a7) && !s(a4, a0) && !s(a4, a1) && !s(a4, a5) && !s(a4, a8)) {	// C A 2 
																														// B B A
																														// B B C
			gl_FragColor = sel3(a4, sel2(a4, a0, a8), sel2(a4, a1, a5), a2);
			return;
		}
	
		if(s(a3, a1) && s(a4, a5) && s(a4, a8) && s(a4, a7) && !s(a4, a2) && !s(a4, a1) && !s(a4, a3) && !s(a4, a6)) {	// 0 A C
																														// A B B
																														// C B B
			gl_FragColor = sel3(a4, sel2(a4, a2, a6), sel2(a4, a1, a3), a0);
			return;
		}
	}
}

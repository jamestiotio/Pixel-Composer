function Node_Strand_Break(_x, _y, _group = noone) : _Node_Strand_Affector(_x, _y, _group) constructor {
	name = "Strand Break";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	w = 96;
	
	inputs[| input_fix_len + 0] = nodeValue("Chance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	array_push(input_display_list, 
		["Break",	false], input_fix_len + 0, input_fix_len + 1
	);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _cha = inputs[| input_fix_len + 0].getValue();
		var _sed = inputs[| input_fix_len + 1].getValue();
		
		STRAND_EFFECTOR_PRE
			if(_sed && random1D(h.id) < _cha * mulp)
				h.free = true;
			else if(!_sed && random(1) < _cha * mulp)
				h.free = true;
		STRAND_EFFECTOR_POST
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_break, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
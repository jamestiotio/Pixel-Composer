function Node_Strand_Update(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Strand Update";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	w = 96;
	
	inputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.input, VALUE_TYPE.strands, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
	
	outputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.output, VALUE_TYPE.strands, noone);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _str = inputs[| 0].getValue();
		var _itr = inputs[| 1].getValue();
		
		if(_str == noone) return;
		var __str = _str;
		if(!is_array(_str)) __str = [ _str ];
		
		for( var i = 0; i < array_length(__str); i++ ) 
			__str[i].step(_itr);
		outputs[| 0].setValue(_str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_update, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
function Node_Iterator_Each_Length(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Array Length";
	destroy_when_upgroup = true;
	color = COLORS.node_blend_loop;
	previewable = false;
	
	w = 96;
	min_h = 80;
	
	outputs[| 0] = nodeValue("Length", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	static update = function(frame = ANIMATOR.current_frame) { 
		if(!variable_struct_exists(group, "iterated")) return;
		var val = group.inputs[| 0].getValue();
		outputs[| 0].setValue(array_length(val));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_iterator_amount, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
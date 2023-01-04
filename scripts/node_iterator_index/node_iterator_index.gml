function Node_Iterator_Index(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Index";
	color = COLORS.node_blend_loop;
	previewable = false;
	
	w = 96;
	min_h = 80;
	
	outputs[| 0] = nodeValue(0, "Loop index", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	static update = function() { 
		if(!variable_struct_exists(group, "iterated")) return;
		outputs[| 0].setValue(group.iterated);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_iterator_index, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
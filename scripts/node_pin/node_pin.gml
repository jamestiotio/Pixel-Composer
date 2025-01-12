function Node_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Pin";
	setDimension(32, 32);
	
	auto_height      = false;
	junction_shift_y = 16;
	
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	
	bg_spr     = THEME.node_pin_bg;
	bg_sel_spr = THEME.node_pin_bg_active;
	
	inputs[| 0] = nodeValue("In", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static step = function() { #region
		if(inputs[| 0].value_from == noone) return;
		
		inputs[| 0].setType(inputs[| 0].value_from.type);
		outputs[| 0].setType(inputs[| 0].value_from.type);
		
		inputs[| 0].color_display  = inputs[| 0].value_from.color_display;
		outputs[| 0].color_display = inputs[| 0].color_display;
	} #endregion
	
	static update = function() { #region
		var _val = getInputData(0);
		outputs[| 0].setValue(_val);
	} #endregion
	
	static pointIn = function(_x, _y, _mx, _my, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	} #endregion
	
	static preDraw = function(_x, _y, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		inputs[| 0].x = xx;
		inputs[| 0].y = yy;
		
		outputs[| 0].x = xx;
		outputs[| 0].y = yy;
	} #endregion
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s) {}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) { #region
		
		var _dval = PANEL_GRAPH.value_dragging;
		var hover = _dval == noone || _dval.connect_type == JUNCTION_CONNECT.input? outputs[| 0] : inputs[| 0];
		var xx	  = x * _s + _x;
		var yy	  = y * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		var jhov = hover.drawJunction(_s, _mx, _my);
		
		if(!isHovering) return noone;
		
		hover_scale_to = 1;
		return jhov? hover : noone;
	} #endregion
	
	static drawNode = function(_x, _y, _mx, _my, _s) { #region
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		hover_alpha = 0.5;
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		}
		
		if(hover_scale > 0) {
			var _r = hover_scale * _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, hover_alpha);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
			shader_reset();
		}
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to, 3);
		hover_scale_to = 0;
		
		if(renamed && display_name != "" && display_name != "Pin") {
			draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
			draw_text_transformed(xx, yy - 12 * _s, display_name, _s * 0.4, _s * 0.4, 0);
		}
		
		return drawJunctions(_x, _y, _mx, _my, _s);
	} #endregion
}
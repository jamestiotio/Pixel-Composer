function Node_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	inputs[| 4] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	inputs[| 5] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| 6] = nodeValue("Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(11);
	
	__init_mask_modifier(1); // inputs 7, 8, 
	
	inputs[| 9] = nodeValue("Radius mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Linear",         s_node_curve, 2), 
												 new scrollItem("Inverse Square", s_node_curve, 1), 
												 new scrollItem("Logarithm",      s_node_curve, 3), ]);
	
	inputs[| 10] = nodeValue("Swap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValueMap("Blend map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 12] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3, 4,
		["Surfaces", false], 0, 1, 2, 7, 8, 12, 
		["Effect",   false], 5, 6, 11, 9, 10, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 6].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_polar);
			shader_set_interpolation( _data[0]);
			shader_set_i("invert",    _data[5]);
			shader_set_i("distMode",  _data[9]);
			shader_set_f_map("blend", _data[6], _data[11], inputs[| 6]);
			shader_set_i("swap",      _data[10]);
			shader_set_f("tile",      _data[12]);
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}
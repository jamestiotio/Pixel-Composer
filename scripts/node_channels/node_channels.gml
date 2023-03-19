function Node_RGB_Channel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RGBA Extract";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Output type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Channel value", "Greyscale"]);
	
	outputs[| 0] = nodeValue("Red", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	outputs[| 1] = nodeValue("Green", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	outputs[| 2] = nodeValue("Blue", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	outputs[| 3] = nodeValue("Alpha", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static process_data = function(_outSurf, _data, output_index) {
		var _out = _data[1];
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
			switch(output_index) {
				case 0 : shader_set(_out? sh_channel_R_grey : sh_channel_R); break;
				case 1 : shader_set(_out? sh_channel_G_grey : sh_channel_G); break;
				case 2 : shader_set(_out? sh_channel_B_grey : sh_channel_B); break;
				case 3 : shader_set(_out? sh_channel_A_grey : sh_channel_A); break;
			}
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}
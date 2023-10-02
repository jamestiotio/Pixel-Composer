function Node_BW(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "BW";
	
	shader = sh_bw;
	uniform_exp = shader_get_uniform(shader, "brightness");
	uniform_con = shader_get_uniform(shader, "contrast");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01] });
	
	inputs[| 2] = nodeValue("Contrast",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 4, 0.01] });
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	input_display_list = [ 5, 
		["Output",	 true], 0, 3, 4, 
		["BW",		false], 1, 2, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _exp = _data[1];
		var _con = _data[2];
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f(uniform_exp, _exp);
			shader_set_uniform_f(uniform_con, _con);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		
		return _outSurf;
	} #endregion
}
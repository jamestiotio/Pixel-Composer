function Node_Diffuse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Diffuse";
	
	inputs[| 0] = nodeValue("Density field", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Dissipation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.05)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -0.2, 0.2, 0.001] });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 3] = nodeValue("Randomness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 4] = nodeValue("Flow rate", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 1, 0.01] });
	
	inputs[| 5] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.7 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		
	inputs[| 6] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 6].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 7] = nodeValue("External", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 8] = nodeValue("External Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -0.25, 0.25, 0.01] });
	
	inputs[| 9] = nodeValue("Detail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
	
	inputs[| 10] = nodeValue("External Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Vector" ]);
		
	inputs[| 11] = nodeValue("External Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0, 6, 
		["Diffuse",		false], 1, 
		["Flow",		false], 2, 9, 3, 4, 
		["Forces",		false], 10, 8, 11, 
		["Rendering",	false], 5, 
	]
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static step = function() {
		var _ftyp = getInputData(10);
		
		inputs[| 11].setVisible(_ftyp == 1);
	}
	
	static update = function() {
		var _surf = getInputData(0);
		var _diss = getInputData(1);
		var _scal = getInputData(2);
		var _rand = getInputData(3);
		var _flow = getInputData(4);
		var _thre = getInputData(5);
		var _seed = getInputData(6);
		var _fstr = getInputData(8);
		var _detl = getInputData(9);
		var _ftyp = getInputData(10);
		var _fdir = getInputData(11);
		
		if(!is_surface(_surf)) return;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _outSurf = outputs[| 0].getValue();
		    _outSurf = surface_verify(_outSurf, _sw, _sh);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		surface_set_shader(temp_surface[0], sh_diffuse_dissipate);
			shader_set_f("dimension",   _sw, _sh);
			shader_set_f("dissipation", 1 - _diss);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_diffuse_flow);
			shader_set_f("dimension", _sw, _sh);
			shader_set_f("scale",     _scal);
			shader_set_i("iteration", _detl);
			shader_set_f("flowRate",  _flow);
			shader_set_f("seed",      _seed + CURRENT_FRAME * _rand / 100);
			shader_set_i("externalForceType", _ftyp);
			shader_set_f("externalForce",     _fstr);
			shader_set_f("externalForceDir",  degtorad(_fdir));
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_diffuse_post);
			shader_set_f("dimension", _sw, _sh);
			shader_set_f("threshold", _thre);
			
			draw_surface_safe(temp_surface[1]);
		surface_reset_shader();
		
		outputs[| 0].setValue(_outSurf);
	}
}
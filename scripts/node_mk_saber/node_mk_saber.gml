function Node_MK_Saber(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Saber";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Point 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Point 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
	
	inputs[| 4] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white))
	
	inputs[| 5] = nodeValue("Trace", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 6] = nodeValue("Fix length", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Gradient step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[| 8] = nodeValue("Glow intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Glow radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	input_display_list = [ 0, 
		["Saber",		false], 1, 2, 3, 6, 
		["Render",		false], 4, 7, 5, 8, 9, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	prev_points  = noone;
	fixed_length = 0;
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	surface_blur_init();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _p1 = getSingleValue(1);
		var _p2 = getSingleValue(2);
		
		var _p1x = _x + _p1[0] * _s;
		var _p1y = _y + _p1[1] * _s;
		var _p2x = _x + _p2[0] * _s;
		var _p2y = _y + _p2[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(_p1x, _p1y, _p2x, _p2y);
		
		var _a = inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny); active &= _a;
		var _a = inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny); active &= _a;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pnt1 = _data[1];
		var _pnt2 = _data[2];
		var _thck = _data[3];
		var _colr = _data[4];
		var _trac = _data[5];
		var _fixl = _data[6];
		var _grds = max(1, _data[7]);
		var _gint = _data[8];
		var _grad = _data[9];
		
		draw_set_circle_precision(32);
		
		var _p1x = round(_pnt1[0] - 1);
		var _p1y = round(_pnt1[1] - 1);
		var _p2x = round(_pnt2[0] - 1);
		var _p2y = round(_pnt2[1] - 1);
		var _dir = point_direction(_p1x, _p1y, _p2x, _p2y);
		var _cur;
		
		if(prev_points == noone || CURRENT_FRAME == 0) prev_points = [];
		if(!is_array(array_safe_get(prev_points, _array_index)))
			prev_points[_array_index] = [];
		
		if(_fixl) { #region
			var _prevArr = prev_points[_array_index];
			
			if(CURRENT_FRAME == 0)
				fixed_length = point_distance(_pnt1[0], _pnt1[1], _pnt2[0], _pnt2[1]);
			else if(!array_empty(_prevArr)){
				var _prev = _prevArr[array_length(_prevArr) - 1];
				
				var _pr1x = _prev[2][0];
				var _pr1y = _prev[2][1];
				var _pr2x = _prev[3][0];
				var _pr2y = _prev[3][1];
				
				var _dsp = point_distance(_pr1x, _pr1y, _pr2x, _pr2y);
				var _dsc = point_distance(_p1x, _p1y, _p2x, _p2y);
				var _ds1 = point_distance(_p1x, _p1y, _pr1x, _pr1y);
				var _ds2 = point_distance(_p2x, _p2y, _pr2x, _pr2y);
				
				var _ds_off = _dsp - _dsc;
				var _ds_of1 = _ds_off * (_ds1 / (_ds1 + _ds2));
				var _ds_of2 = _ds_off * (_ds2 / (_ds1 + _ds2));
				
				var __p2x = _p2x + lengthdir_x(_ds_of2, _dir);
				var __p2y = _p2y + lengthdir_y(_ds_of2, _dir);
				var __p1x = _p1x - lengthdir_x(_ds_of1, _dir);
				var __p1y = _p1y - lengthdir_y(_ds_of1, _dir);
				
				_p1x = __p1x;
				_p1y = __p1y;
				_p2x = __p2x;
				_p2y = __p2y;
			}
		} #endregion
		
		if(_thck) {
			_cur = [
				[ _p1x - lengthdir_x(_thck / 2, _dir), _p1y - lengthdir_y(_thck / 2, _dir) ], 
				[ _p2x + lengthdir_x(_thck / 2, _dir), _p2y + lengthdir_y(_thck / 2, _dir) ],
				[ _p1x, _p1y ], [ _p2x, _p2y ]
			];
		} else
			_cur = [[ _p1x, _p1y ], [ _p2x, _p2y ], [ _p1x, _p1y ], [ _p2x, _p2y ]];
		
		for( var i = 0; i < array_length(temp_surface); i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			
			draw_set_color(_colr.eval(1));
			if(_trac > 0 && CURRENT_FRAME > 0 && prev_points != noone) { #region
				var _prevArr = prev_points[_array_index];
				var _inds    = max(0, array_length(_prevArr) - _trac);
				
				for( var i = _inds, n = array_length(_prevArr); i < n; i++ ) {
					var _prev = _prevArr[i];
					var _curr = i + 1 == n? _cur : _prevArr[i + 1];
					
					var _pr1x = _prev[0][0];
					var _pr1y = _prev[0][1];
					var _pr2x = _prev[1][0];
					var _pr2y = _prev[1][1];
					
					var _pp1x = _curr[0][0];
					var _pp1y = _curr[0][1];
					var _pp2x = _curr[1][0];
					var _pp2y = _curr[1][1];
					
					draw_triangle(_pr1x, _pr1y, _pr2x, _pr2y, _pp1x, _pp1y, false);
					draw_triangle(_pr2x, _pr2y, _pp1x, _pp1y, _pp2x, _pp2y, false);
				}
			} #endregion
			
			if(_thck == 1) {
				draw_set_color(_colr.eval(1));
				draw_line(_p1x, _p1y, _p2x, _p2y);
			} else {
				for( var i = _thck; i > 0; i -= _grds ) {
					draw_set_color(_colr.eval((i - 1) / (_thck - 1)));
					draw_line_round(_p1x, _p1y, _p2x, _p2y, i);
				}
			}
		surface_reset_target();
		
		if(_gint > 0) { #region
			surface_set_target(temp_surface[1]);
				draw_clear(c_black);
				draw_surface(temp_surface[0], 0, 0);
			surface_reset_target();	
		
			temp_surface[2] = surface_apply_gaussian(temp_surface[1], _grad, false, 0, 1);
		} #endregion
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			if(_gint > 0) {
				BLEND_OVERRIDE
				shader_set(sh_mk_saber_glow);
					shader_set_color("color", _colr.eval(1));
					shader_set_f("intensity", _gint);
					draw_surface(temp_surface[2], 0, 0);
				shader_reset();
			}
			
			BLEND_ALPHA_MULP
			draw_surface(temp_surface[0], 0, 0);
			
			BLEND_NORMAL
		surface_reset_target();
		
		array_push(prev_points[_array_index], _cur);
		
		return _outSurf;
	}
}
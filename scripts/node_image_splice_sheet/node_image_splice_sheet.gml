function Node_Image_Sheet(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Splice Spritesheet";
	
	surf_array = [];
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1]  = nodeValue("Sprite size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 32, 32 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2]  = nodeValue("Row", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1); //unused
	inputs[| 3]  = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4]  = nodeValue("Offset", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5]  = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6]  = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
	
	inputs[| 7]  = nodeValue("Output", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Animation", "Array"]);
	
	inputs[| 8]  = nodeValue("Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 9]  = nodeValue("Orientation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Horizontal", "Vertical"]);
	
	inputs[| 10] = nodeValue("Auto fill", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0, "Automatically set amount based on sprite size.")
		.setDisplay(VALUE_DISPLAY.button, { name: "Auto fill", onClick: function() { 
			var _sur = getInputData(0);
			if(!is_surface(_sur) || _sur == DEF_SURFACE) return;
			var ww = surface_get_width_safe(_sur);
			var hh = surface_get_height_safe(_sur);
		
			var _size = getInputData(1);
			var _offs = getInputData(4);
			var _spac = getInputData(5);
			var _orie = getInputData(9);
		
			var sh_w = _size[0] + _spac[0];
			var sh_h = _size[1] + _spac[1];
		
			var fill_w = floor((ww - _offs[0]) / sh_w);
			var fill_h = floor((hh - _offs[1]) / sh_h);
			
			if(_orie == 0)
				inputs[| 3].setValue([ fill_w, fill_h ]);
			else
				inputs[| 3].setValue([ fill_h, fill_w ]);
		
			inspector1Update();
		} });
		
	inputs[| 11] = nodeValue("Sync animation", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0)
		.setDisplay(VALUE_DISPLAY.button, { name: "Sync frames", onClick: function() { 
			var _atl = outputs[| 1].getValue();
			var _spd = getInputData(8);
			TOTAL_FRAMES = max(1, _spd == 0? 1 : ceil(array_length(_atl) / _spd));
		} });
		
	inputs[| 12] = nodeValue("Filter empty output", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 13] = nodeValue("Filtered Pixel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Transparent", "Color" ]);
	
	inputs[| 14] = nodeValue("Filtered Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black)
	
	input_display_list = [
		["Sprite", false],	0, 1, 6, 
		["Sheet",  false],	3, 10, 9, 4, 5, 
		["Output", false],	7, 8, 12, 13, 14, 11
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	attribute_surface_depth();
	
	drag_type = 0;	
	drag_sx   = 0;
	drag_sy   = 0;
	drag_mx   = 0;
	drag_my   = 0;
	curr_off  = [0, 0];
	curr_dim  = [0, 0];
	curr_amo  = [0, 0];
	
	sprite_valid = [];
	
	static getPreviewValues = function() { return getInputData(0); }
	
	function getSpritePosition(index) {
		var _dim = curr_dim;
		var _col = curr_amo[0];
		var _off = curr_off;
		var _spa = getInputData(5);
		var _ori = getInputData(9);
		
		var _irow = floor(index / _col);
		var _icol = safe_mod(index, _col);
		
		var _x, _y;
		
		var _x = _off[0] + _icol * (_dim[0] + _spa[0]);
		var _y = _off[1] + _irow * (_dim[1] + _spa[1]);
		
		if(_ori == 0)
			return [_x, _y];
		else
			return [_y, _x];
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _inSurf  = getInputData(0);
		if(!is_surface(_inSurf)) return;
		
		var _out = getInputData(7);
		var _spc = getInputData(5);
		
		if(drag_type == 0) {
			curr_dim = getInputData(1);
			curr_amo = getInputData(3);
			curr_off = getInputData(4);
		}
		
		var _amo = array_safe_get(curr_amo, 0) * array_safe_get(curr_amo, 1);
		
		for(var i = _amo - 1; i >= 0; i--) {
			if(!array_safe_get(sprite_valid, i, true))
				continue;
				
			var _f = getSpritePosition(i);
			var _fx0 = _x + _f[0] * _s;
			var _fy0 = _y + _f[1] * _s;
			var _fx1 = _fx0 + curr_dim[0] * _s;
			var _fy1 = _fy0 + curr_dim[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(i == 0? 1 : 0.75);
			draw_rectangle(_fx0, _fy0, _fx1 - 1, _fy1 - 1, true);
			draw_set_alpha(1);
			
			//draw_set_text(f_p1, fa_left, fa_top);
			//draw_text(_fx0 + 2, _fy0 + 2, string(i));
		}
		
		var __ax = curr_off[0];
		var __ay = curr_off[1];
		var __aw = curr_dim[0];
		var __ah = curr_dim[1];
						
		var _ax = __ax * _s + _x;
		var _ay = __ay * _s + _y;
		var _aw = __aw * _s;
		var _ah = __ah * _s;
		
		var _bw = curr_amo[0] * (curr_dim[0] + _spc[0]) - _spc[0]; _bw *= _s;
		var _bh = curr_amo[1] * (curr_dim[1] + _spc[1]) - _spc[1]; _bh *= _s;
		
		draw_sprite_colored(THEME.anchor, 0, _ax, _ay);
		draw_sprite_colored(THEME.anchor_selector, 0, _ax + _aw, _ay + _ah);
		draw_sprite_colored(THEME.anchor_arrow, 0, _ax + _bw + _s * 4, _ay + _bh / 2);
		draw_sprite_colored(THEME.anchor_arrow, 0, _ax + _bw / 2, _ay + _bh + _s * 4,, -90);
		
		if(active) {
			if(point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8))
				draw_sprite_colored(THEME.anchor_selector, 1, _ax + _aw, _ay + _ah);
			else if(point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah))
				draw_sprite_colored(THEME.anchor, 0, _ax, _ay, 1.25, c_white);
			else if(point_in_circle(_mx, _my, _ax + _bw + _s * 4, _ay + _bh / 2, 8))
				draw_sprite_colored(THEME.anchor_arrow, 1, _ax + _bw + _s * 4, _ay + _bh / 2);
			else if(point_in_circle(_mx, _my, _ax + _bw / 2, _ay + _bh + _s * 4, 8))
				draw_sprite_colored(THEME.anchor_arrow, 1, _ax + _bw / 2, _ay + _bh + _s * 4,, -90);
		}
		
		#region area
			var __dim = getInputData(1);
			var __amo = getInputData(3);
			var __off = getInputData(4);
						
			var _ax = __off[0] * _s + _x;
			var _ay = __off[1] * _s + _y;
			var _aw = __dim[0] * _s;
			var _ah = __dim[1] * _s;
						
			//draw_set_color(COLORS._main_accent);
			//draw_rectangle(_ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah, true);
						
			if(drag_type == 1) {
				var _xx = value_snap(round(drag_sx + (_mx - drag_mx) / _s), _snx);
				var _yy = value_snap(round(drag_sy + (_my - drag_my) / _s), _sny);
							
				var off = [_xx, _yy];
				curr_off = off;
			
				if(mouse_release(mb_left)) {
					drag_type = 0;
					inputs[| 4].setValue(off);
				}
			} else if(drag_type == 2) {
				var _dx = value_snap(round(abs((_mx - drag_mx) / _s)), _snx);
				var _dy = value_snap(round(abs((_my - drag_my) / _s)), _sny);
				
				var dim = [_dx, _dy];
				curr_dim = dim;
							
				if(key_mod_press(SHIFT)) {
					dim[0] = max(_dx, _dy);
					dim[1] = max(_dx, _dy);
				}
				
				if(mouse_release(mb_left)) {
					drag_type = 0;
					inputs[| 1].setValue(dim);
				}
			} else if(drag_type == 3) {
				var _col = floor((abs(_mx - drag_mx) / _s - _spc[0]) / (__dim[0] + _spc[0]));
				curr_amo[0] = _col;
				
				if(mouse_release(mb_left)) {
					drag_type = 0;
					inputs[| 3].setValue(curr_amo);
				}
			} else if(drag_type == 4) {
				var _row = floor((abs(_my - drag_my) / _s - _spc[1]) / (__dim[1] + _spc[1]));
				curr_amo[1] = _row;
				
				if(mouse_release(mb_left)) {
					drag_type = 0;
					inputs[| 3].setValue(curr_amo);
				}
			}
						
			if(mouse_press(mb_left, active)) {
				if(point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8)) { // drag size
					drag_type = 2;
					drag_mx   = _ax;
					drag_my   = _ay;
				} else if(point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah)) { // drag position
					drag_type = 1;	
					drag_sx   = __off[0];
					drag_sy   = __off[1];
					drag_mx   = _mx;
					drag_my   = _my;
				} else if(point_in_circle(_mx, _my, _ax + _bw + _s * 4, _ay + _bh / 2, 8)) { // drag col
					drag_type = 3;
					drag_mx   = _ax;
					drag_my   = _ay;
				} else if(point_in_circle(_mx, _my, _ax + _bw / 2, _ay + _bh + _s * 4, 8)) { // drag row
					drag_type = 4;
					drag_mx   = _ax;
					drag_my   = _ay;
				}
			}
		#endregion
	}
	
	static step = function() {
		var _out  = getInputData(7);
		var _filt = getInputData(12);
		var _flty = getInputData(13);
		
		inputs[| 11].setVisible(!_out);
		inputs[|  8].setVisible(!_out);
		inputs[| 13].setVisible(_filt);
		inputs[| 14].setVisible(_filt && _flty);
	}
	
	static onInspector1Update = function() {
		if(isInLoop())	Render();
		else			doInspectorAction();
	}
	
	static doInspectorAction = function() {
		var _atl	 = [];
		var _inSurf  = getInputData(0);
		if(!is_surface(_inSurf)) return;
		
		var _outSurf = outputs[| 0].getValue();
		var _out	 = getInputData(7);
		
		var _dim	= getInputData(1);
		var _amo	= getInputData(3);
		var _off	= getInputData(4);
		var _total  = _amo[0] * _amo[1];
		var _pad	= getInputData(6);
		
		var ww   = _dim[0] + _pad[0] + _pad[2];
		var hh   = _dim[1] + _pad[1] + _pad[3];
		
		var _filt = getInputData(12);
		var _fltp = getInputData(13);
		var _flcl = getInputData(14);
		
		var cDep  = attrDepth();
		curr_dim = _dim;
		curr_amo = is_array(_amo)? _amo : [1, 1];
		curr_off = _off;
		
		var filSize = 4;
		var _empS = surface_create_valid(filSize, filSize, cDep);
		var _buff = buffer_create(filSize * filSize * surface_format_get_bytes(cDep), buffer_fixed, 2);
		
		surf_array = [];
		for( var i = 0, n = array_length(surf_array); i < n; i++ ) {
			if(is_surface(surf_array[i]))
				surface_free(surf_array[i]);
		}
		
		for(var i = 0; i < _total; i++) {
			var _s = surface_create_valid(ww, hh, cDep);
			var _spr_pos = getSpritePosition(i);
			
			surface_set_target(_s);
				draw_clear_alpha(c_black, 0);
				BLEND_OVERRIDE;
				draw_surface_part_ext_safe(_inSurf, _spr_pos[0], _spr_pos[1], _dim[0], _dim[1], _pad[2], _pad[1]);
				BLEND_NORMAL;
			surface_reset_target();
				
			if(_filt) {
				gpu_set_tex_filter(true);
				surface_set_target(_empS);
				DRAW_CLEAR
				BLEND_OVERRIDE;
				draw_surface_stretched_safe(_s, 0, 0, filSize, filSize);
				BLEND_NORMAL;
				surface_reset_target();
				gpu_set_tex_filter(false);
					
				buffer_get_surface(_buff, _empS, 0);
				buffer_seek(_buff, buffer_seek_start, 0);
				var empty = true;
				
				repeat(filSize * filSize - 1) {
					var c = buffer_read(_buff, buffer_u32);
					if(_fltp == 0 && ((c & 0xFF000000) >> 24) != 0) {
						empty = false;
						break;
					} else if(_fltp == 1 && (c & 0x00FFFFFF) != _flcl) {
						empty = false;
						break;
					}
				}
					
				if(!empty) {
					array_push(_atl, new SurfaceAtlas(_s, _spr_pos[0], _spr_pos[1]));
					array_push(surf_array, _s);
				}
				sprite_valid[i] = !empty;
			} else {
				array_push(_atl, new SurfaceAtlas(_s, _spr_pos[0], _spr_pos[1]));
				array_push(surf_array, _s);
				sprite_valid[i] = true;
			}
		}
			
		if(_out == 1) outputs[| 0].setValue(surf_array);
		outputs[| 1].setValue(_atl);
		
		buffer_delete(_buff);
		surface_free(_empS);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(isInLoop()) doInspectorAction();
		
		var _out  = getInputData(7);
		if(_out == 1) {
			outputs[| 0].setValue(surf_array);
			update_on_frame = false;
			return;
		}
		
		var _spd = getInputData(8);
		update_on_frame = true;
		
		if(array_length(surf_array)) {
			var ind = safe_mod(CURRENT_FRAME * _spd, array_length(surf_array));
			outputs[| 0].setValue(array_safe_get(surf_array, ind));
		}
	}
}
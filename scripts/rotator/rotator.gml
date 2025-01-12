function rotator(_onModify, _step = -1) : widget() constructor {
	onModify = _onModify;
	valStep	 = _step;
	
	scale    = 1;
	dragging = noone;
	drag_sv  = 0;
	real_val = 0;
	slide_speed = 1 / 10;
	side_button = noone;
	
	spr_bg   = THEME.rotator_bg;
	spr_knob = THEME.rotator_knob;
	
	tb_value = new textBox(TEXTBOX_INPUT.number, onModify).setSlidable([ 0.1, 15 ], true);
	tb_value.hide = true;
	
	halign = fa_center;
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
		tb_value.interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
		tb_value.register(parent);
	} #endregion
	
	static isHovering = function() { return dragging || tb_value.hovering; }
	
	static drawParam = function(params) { #region
		setParam(params);
		tb_value.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _data, _m, draw_tb = true) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(!is_real(_data)) return;
		 
		var _r  = _h;
		var _bs      = min(_h, ui(32));
		var _drawRot = _w - _r > ui(64);
		
		if(_drawRot && side_button) {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
			_w -= _bs + ui(4);
		}
		
		var _tx = _drawRot? _x + _r + ui(4) : _x;
		var _tw = _drawRot? _w - _r - ui(4) : _w;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _y, _tw, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _y, _tw, _h, c_white, 0.5 + 0.5 * interactable);	
		
		tb_value.setFocusHover(active, hover);
		tb_value.draw(_tx, _y, _tw, _h, _data, _m);
		
		if(_drawRot) {
			var _kx = _x + _r / 2;
			var _ky = _y + _r / 2;
			var _kr = (_r - ui(12)) / 2;
			var _kc = COLORS._main_icon;
		
			if(dragging) {
				_kc = COLORS._main_icon_light;
			
				var real_val = round(dragging.delta_acc + drag_sv);
				var val      = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
			
				if(valStep != -1) val = round(real_val / valStep) * valStep;
			
				if(onModify(val))
					UNDO_HOLDING = true;
			
				MOUSE_BLOCK = true;
			
				if(mouse_check_button_pressed(mb_right)) {
					onModify(drag_sv);
					instance_destroy(dragging);
					dragging     = noone;
					UNDO_HOLDING = false;	
				
				} else if(mouse_release(mb_left)) {
					instance_destroy(dragging);
					dragging     = noone;
					UNDO_HOLDING = false;
				}
			
			} else if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _r, _y + _r)) {
				_kc = COLORS._main_icon_light;
			
				if(mouse_press(mb_left, active)) {
					dragging = instance_create(0, 0, rotator_Rotator).init(_m, _kx, _ky);
					drag_sv  = _data;
				}
			
				if(key_mod_press(SHIFT)) {
					var amo = 1;
					if(key_mod_press(CTRL)) amo *= 10;
					if(key_mod_press(ALT))  amo /= 10;
			
					if(mouse_wheel_down())	onModify(_data + amo * SCROLL_SPEED);
					if(mouse_wheel_up())	onModify(_data - amo * SCROLL_SPEED);
				}
			}
		
			shader_set(sh_widget_rotator);
				shader_set_color("color", _kc);
				shader_set_f("side",     _r);
				shader_set_f("angle",    degtorad(_data));
			
				draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _r, _r);
			shader_reset();
		}
		
		resetFocus();
		
		return h;
	} #endregion
	
	static clone = function() { #region
		var cln = new rotator(onModify, valStep);
		
		return cln;
	} #endregion
}
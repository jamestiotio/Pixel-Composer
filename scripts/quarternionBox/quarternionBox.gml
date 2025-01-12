enum QUARTERNION_DISPLAY {
	quarterion,
	euler,
}

function quarternionBox(_onModify) : widget() constructor {
	onModify      = _onModify;
	current_value = [ 0, 0, 0, 0 ];
	current_unit  = QUARTERNION_DISPLAY.quarterion;
	
	onModifyIndex = function(index, val) { 
		var v = toNumber(val);
		
		if(current_unit == QUARTERNION_DISPLAY.quarterion) {
			return onModify(index, v); 
			
		} else {
			var v  = toNumber(val);
			var qv = [
				current_value[0], 
				current_value[1], 
				current_value[2], 
			];
			
			qv[index] = v;
			return onModify(noone, qv);
		}
	}
	
	size    = 4;
	axis    = [ "x", "y", "z", "w" ];
	tooltip = new tooltipSelector("Angle type", [__txt("Quaternion"), __txt("Euler")]);
	
	disp_w    = noone;
	clickable = true;
	
	onModifySingle[0] = function(val) { return onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { return onModifyIndex(2, val); }
	onModifySingle[3] = function(val) { return onModifyIndex(3, val); }
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].label    = axis[i];
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < size; i++)
			tb[i].setSlidable(speed);
	}
	
	static setInteract = function(interactable) { 
		self.interactable = interactable;
		
		for( var i = 0; i < size; i++ ) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		for( var i = 0; i < size; i++ ) 
			tb[i].register(parent);
	}
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static apply = function() {
		for( var i = 0; i < size; i++ ) {
			tb[i].apply();
			current_value[i] = toNumber(tb[i]._input_text);
		}
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < 4; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(!is_array(_data))   return 0;
		if(array_empty(_data)) return 0;
		if(is_array(_data[0])) return 0;
		
		var _bs   = min(_h, ui(32));
		var _disp = struct_try_get(_display_data, "angle_display");
		
		if(_display_data.angle_display == QUARTERNION_DISPLAY.quarterion || (!tb[0].sliding && !tb[1].sliding && !tb[2].sliding)) {
			current_value[0] = _data[0];
			current_value[1] = _data[1];
			current_value[2] = _data[2];
			
			if(_display_data.angle_display == QUARTERNION_DISPLAY.quarterion)
				current_value[3] = _data[3];
		}
		
		if((_w - _bs) / 2 > ui(64)) {
			var bx = _x + _w - _bs;
			var by = _y + _h / 2 - _bs / 2;
			tooltip.index = _disp;
			
			if(buttonInstant(THEME.button_hide, bx, by, _bs, _bs, _m, iactive, ihover, tooltip, THEME.unit_angle, _disp, c_white) == 2) {
				clickable = false;
				_display_data.angle_display = (_disp + 1) % 2;
			}
			_w -= _bs + ui(8);
		}
		
		current_unit = _display_data.angle_display;
			
		size = _disp? 3 : 4;
		var ww = _w / size;
		var bx = _x;
		disp_w = disp_w == noone? ww : lerp_float(disp_w, ww, 3);
		
		var _dispDat = _data;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);	
		
		for(var i = 0; i < size; i++) {
			var _a = _dispDat[i];
			
			tb[i].hide = true;
			tb[i].setFocusHover(clickable && active, hover);
			tb[i].draw(bx, _y, disp_w, _h, _a, _m);
			
			bx += disp_w;
		}
		
		clickable = true;
		resetFocus();
		
		return _h;
	}
	
	static clone = function() { #region
		var cln = new quarternionBox(onModify);
		return cln;
	} #endregion
}
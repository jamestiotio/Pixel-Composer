function cornerBox(_onModify, _unit = noone) : widget() constructor {
	onModify = _onModify;
	unit     = _unit;
	
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(index, val) { 
		if(linked) {
			for( var i = 0; i < 4; i++ )
				onModify(i, toNumber(val)); 
			return;
		}
		
		onModify(index, toNumber(val)); 
	}
	
	onModifySingle[0] = function(val) { onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { onModifyIndex(2, val); }
	onModifySingle[3] = function(val) { onModifyIndex(3, val); }
	
	labels = [ "r", "t", "l", "b" ];
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].label    = labels[i];
		tb[i].slidable = true;
		tb[i].hide     = true;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < 4; i++)
			tb[i].setSlidable(speed);
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		b_link.interactable = interactable;
		
		for( var i = 0; i < 4; i++ ) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		b_link.register();
		
		tb[0].register(parent);
		tb[1].register(parent);
		tb[2].register(parent);
		tb[3].register(parent);
	}
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) { 
		setParam(params);
		for(var i = 0; i < 4; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m); 
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h + ui(4) + _h;
		
		for(var i = 0; i < 4; i++) tb[i].setFocusHover(active, hover);
		
		var _bs = min(_h, ui(32));
		
		if((_w - _bs) / 2 > ui(64)) {
			b_link.setFocusHover(active, hover);
			b_link.icon_index = linked;
			b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
			b_link.tooltip = linked? __txt("Unlink values") : __txt("Link values");
		
			var _bx = _x;
			var _by = _y + _h / 2 - _bs / 2;
			b_link.draw(_bx, _by, _bs, _bs, _m, THEME.button_hide);
		
			_w -= _bs + ui(4);
			_x += _bs + ui(4);
		}
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);	
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y + _h + ui(4), _w, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y + _h + ui(4), _w, _h, c_white, 0.5 + 0.5 * interactable);	
		
		var tb_w = _w / 2;
		var tb_h = _h;
		
		var tb_lx = _x;
		var tb_ly = _y;
			
		var tb_rx = _x + tb_w;
		var tb_ry = _y;
			
		var tb_tx = _x;
		var tb_ty = _y + _h + ui(4);
			
		var tb_bx = _x + tb_w;
		var tb_by = _y + _h + ui(4);
			
		tb[2].draw(tb_lx, tb_ly, tb_w, tb_h, array_safe_get_fast(_data, 2), _m);
		tb[0].draw(tb_rx, tb_ry, tb_w, tb_h, array_safe_get_fast(_data, 0), _m);
			
		tb[1].draw(tb_tx, tb_ty, tb_w, tb_h, array_safe_get_fast(_data, 1), _m);
		tb[3].draw(tb_bx, tb_by, tb_w, tb_h, array_safe_get_fast(_data, 3), _m);
			
		resetFocus();
		
		return h;
	}
	
	static clone = function() { #region
		var cln = new cornerBox(onModify, unit);
		
		return cln;
	} #endregion
}
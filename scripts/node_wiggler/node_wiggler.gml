function Node_create_Wiggler(_x, _y) {
	var node = new Node_Wiggler(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Wiggler(_x, _y) : Node_Value_Processor(_x, _y) constructor {
	name			= "Wiggler";
	update_on_frame = true;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 3, 5 ] )
		.setDisplay(VALUE_DISPLAY.slider_range, [1, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(9999999) );
	
	inputs[| 3] = nodeValue(3, "Display", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Number", "Graph"])
	
	outputs[| 0] = nodeValue(0, "Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	input_display_list = [
		["Display",	true],	3,
		["Wiggle",	false], 2, 0, 1,
	];
	
	random_value = array_create(64, 0);
	
	static onValueUpdate = function(index) {
		var ran = inputs[| 0].getValue();
		var fre = inputs[| 1].getValue();
		var sed = inputs[| 2].getValue();
		
		var _fmin = ANIMATOR.frames_total / max(1, min(fre[0], fre[1]));
		var _fmax = ANIMATOR.frames_total / max(1, max(fre[0], fre[1]));
		var _val;
		
		for( var i = 0; i < ANIMATOR.frames_total + 1; i++ ) {
			_val = getWiggle(ran[0], ran[1], _fmin, _fmax, i, sed);
			random_value[i] = _val;
		}
	}
	
	function process_value_data(_data, index = 0) { 
		if(array_length(random_value) != ANIMATOR.frames_total + 1) {
			array_resize(random_value, ANIMATOR.frames_total + 1);
			onValueUpdate(0);
		}
		
		var time = ANIMATOR.current_frame;
		return random_value[time];
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		if(array_length(random_value) != ANIMATOR.frames_total + 1) {
			array_resize(random_value, ANIMATOR.frames_total + 1);
			onValueUpdate(0);
		}
		
		var disp = inputs[| 3].getValue();
		var time = ANIMATOR.current_frame;
		var total_time = ANIMATOR.frames_total;
		
		switch(disp) {
			case 0 :
				min_h = 0;
				draw_set_text(f_h5, fa_center, fa_center, c_white);
				var str	= string(random_value[time]);
				var ss	= string_scale(str, (w - 16) * _s, (h - 16) * _s - 20);
				draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, ss, ss, 0);
				break;
			case 1 :
				w = 128;
				min_h = 96;
				
				var ran = inputs[| 0].getValue();
				var fre = inputs[| 1].getValue();
				var sed = inputs[| 2].getValue();
				
				var _min = ran[0];
				var _max = ran[1];
				var val  = (_min + _max) / 2;
				var _ran = _max - _min;
				var _fmin = max(1, fre[0]);
				var _fmax = max(1, fre[1]);
				
				var x0 = xx + 8 * _s;
				var x1 = xx + (w - 8) * _s;
				var y0 = yy + 20 + 8  * _s;
				var y1 = yy + (h - 8) * _s;
				var ww = x1 - x0;
				var hh = y1 - y0;
				
				var yc = (y0 + y1) / 2;
				draw_set_color(c_ui_blue_grey);
				draw_line(x0, yc, x1, yc);
				var _fx = x0 + (time / total_time * ww);
				draw_line(_fx, y0, _fx, y1);
				
				var lw = ww / (array_length(random_value) - 1);
				draw_set_color(c_white);
				var ox, oy;
				for( var i = 0; i < array_length(random_value); i++ ) {
					var _x = x0 + i * lw;
					var _y = yc - (random_value[i] - val) / (_ran * 2) * hh;
					if(i)
						draw_line(ox, oy, _x, _y);
					
					ox = _x;
					oy = _y;
				}
				
				draw_set_color(c_ui_blue_grey);
				draw_rectangle(x0, y0, x1, y1, true);
				break;
		}
	}
}
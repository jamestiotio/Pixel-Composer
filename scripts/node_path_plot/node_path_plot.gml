function Node_Path_Plot(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Plot Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Output scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 8, 8 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Coordinate", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Cartesian", "Polar" ]);
	
	eq_type_car = [ "x function", "y function", "parametric" ];
	eq_type_pol = [ "r function", "O function", "parametric" ];
	inputs[| 2] = nodeValue("Equation type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, eq_type_car);
	
	inputs[| 3] = nodeValue("0 function", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	inputs[| 4] = nodeValue("1 function", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 5] = nodeValue("Origin", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 6] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [ -1, 1, 0.01 ]);
		
	inputs[| 7] = nodeValue("Input scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 8] = nodeValue("Input shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	input_display_list = [
		[ "Variable",  false ], 5, 7, 8, 0, 
		[ "Equation",  false ], 1, 2, 3, 4, 6, 
	]
	
	boundary = new BoundingBox( 0, 0, 1, 1 );
	
	static getLineCount		= function() { return 1; }
	static getSegmentCount	= function() { return 0; }
	static getBoundary		= function() { return boundary; }
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static getPointRatio = function(_rat, ind = 0) {
		var _sca  = inputs[| 0].getValue();
		var _coor = inputs[| 1].getValue();
		var _eqa  = inputs[| 2].getValue();
		var _eq0  = inputs[| 3].getValue();
		var _eq1  = inputs[| 4].getValue();
		var _orig = inputs[| 5].getValue();
		var _ran  = inputs[| 6].getValue();
		var _iran = inputs[| 7].getValue();
		var _shf  = inputs[| 8].getValue();
		
		_rat = _ran[0] + (_rat * (_ran[1] - _ran[0]));
		
		var _p = new Point();
		
		switch(_coor) {
			case 0 :
				switch(_eqa) {
					case 0 : 
						_p.x = _rat * _iran[0] + _shf[0];
						_p.y = evaluateFunction(_eq0, { x: _rat * _iran[0] + _shf[0] });
						break;
					case 1 : 
						_p.x = evaluateFunction(_eq0, { y: _rat * _iran[1] + _shf[1] });
						_p.y = _rat * _iran[1] + _shf[1];
						break;
					case 2 : 
						_p.x = evaluateFunction(_eq0, { t: _rat * _iran[0] + _shf[0] });
						_p.y = evaluateFunction(_eq1, { t: _rat * _iran[1] + _shf[1] });
						break;
				}
				break;
			case 1 :
				var _a = new Point();
				switch(_eqa) {
					case 0 : 
						_a.x = _rat * _iran[0] + _shf[0];
						_a.y = evaluateFunction(_eq0, { r: _rat * _iran[0] + _shf[0] });
						break;
					case 1 : 
						_a.x = evaluateFunction(_eq0, { O: _rat * _iran[1] + _shf[1] });
						_a.y = _rat * _iran[1] + _shf[1];
						break;
					case 2 : 
						_a.x = evaluateFunction(_eq0, { t: _rat * _iran[0] + _shf[0] });
						_a.y = evaluateFunction(_eq1, { t: _rat * _iran[1] + _shf[1] });
						break;
				}
				
				_p.x =  cos(_a.y) * _a.x;
				_p.y = -sin(_a.y) * _a.x;
				break;
		}
		
		_p.x =  _p.x * _sca[0] + _orig[0];
		_p.y = -_p.y * _sca[1] + _orig[1];
		
		return _p;
	}
	
	function step() { 
		var _coor = inputs[| 1].getValue();
		var _eqa  = inputs[| 2].getValue();
		
		inputs[| 2].editWidget.data_list = _coor? eq_type_pol : eq_type_car;
		inputs[| 2].display_data         = _coor? eq_type_pol : eq_type_car;
		
		switch(_coor) {
			case 0 :
				switch(_eqa) {
					case 0 : 
						inputs[| 3].name = "f(x) = ";
						inputs[| 4].setVisible(false);
						inputs[| 6].name = "x range";
						break;
					case 1 : 
						inputs[| 3].name = "f(y) = ";
						inputs[| 4].setVisible(false);
						inputs[| 6].name = "y range";
						break;
					case 2 : 
						inputs[| 3].name = "x(t) = ";
						inputs[| 4].name = "y(t) = ";
						inputs[| 4].setVisible(true);
						inputs[| 6].name = "t range";
						break;
				}
				break;
			case 1 :
				switch(_eqa) {
					case 0 : 
						inputs[| 3].name = "f(r) = ";
						inputs[| 4].setVisible(false);
						inputs[| 6].name = "r range";
						break;
					case 1 : 
						inputs[| 3].name = "f(O) = ";
						inputs[| 4].setVisible(false);
						inputs[| 6].name = "O range";
						break;
					case 2 : 
						inputs[| 3].name = "r(t) = ";
						inputs[| 4].name = "O(t) = ";
						inputs[| 4].setVisible(true);
						inputs[| 6].name = "t range";
						break;
				}
				break;
		}
	}
	
	function update() { 
		updateBoundary();
		outputs[| 0].setValue(self); 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
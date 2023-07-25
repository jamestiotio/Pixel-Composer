function Node_Path_Builder(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Path Builder";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Point array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setVisible(true, true)
		.setArrayDepth(2);
	
	inputs[| 1] = nodeValue("Connected", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "If set to true, will draw a single path from one point to another. If not set will treat each pair of points as an individual line.");
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static getLineCount = function() { 
		var _lines = inputs[| 0].getValue();
		var _conn  = inputs[| 1].getValue();
		
		return _conn? 1 : floor(array_length(_lines) / 2); 
	}
	
	static getBoundary		= function() { 
		var boundary = new BoundingBox();
		var _lines = inputs[| 0].getValue();
		for( var i = 0, n = array_length(_lines); i < n; i++ )
			boundary.addPoint(_lines[i][0], _lines[i][1]);
		
		return boundary; 
	}
	
	static getPointRatio = function(_rat, _ind = 0) {
		var _lines = inputs[| 0].getValue();
		var _conn  = inputs[| 1].getValue();
		var _p0, _p1;
		var _x, _y;
		
		if(_conn) {
			var _st = _rat * (array_length(_lines) - 1);
			_p0 = array_safe_get(_lines, floor(_st) + 0,, ARRAY_OVERFLOW._default);
			_p1 = array_safe_get(_lines, floor(_st) + 1,, ARRAY_OVERFLOW._default);
			
			if(!is_array(_p0)) return new Point();
			if(!is_array(_p1)) return new Point();
			
			_x  = lerp(_p0[0], _p1[0], frac(_st));
			_y  = lerp(_p0[1], _p1[1], frac(_st));
		
			return new Point( _x, _y );
		} else {
			_p0 = array_safe_get(_lines, _ind * 2 + 0,, ARRAY_OVERFLOW._default);
			_p1 = array_safe_get(_lines, _ind * 2 + 1,, ARRAY_OVERFLOW._default);
			
			if(!is_array(_p0)) return new Point();
			if(!is_array(_p1)) return new Point();
			
			_x  = lerp(_p0[0], _p1[0], _rat);
			_y  = lerp(_p0[1], _p1[1], _rat);
		
			return new Point( _x, _y );
		}
	}
	
	function update() { 
		var _lines = inputs[| 0].getValue();
		var _conn  = inputs[| 1].getValue();
		
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_builder, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
function Node_Gradient_Out(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gradient";
	setDimension(96);
	
	inputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject([ cola(c_black), cola(c_white) ]) );
	
	inputs[| 1] = nodeValue("Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Position to sample a color from the gradient.")
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Gradient", self, JUNCTION_CONNECT.output, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	outputs[| 1] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, c_white);
	
	_pal = -1;
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var pal = _data[0];
		var pos = _data[1];
		
		if(!is_instanceof(pal, gradientObject)) return 0;
		
		if(_output_index == 0) return pal;
		if(_output_index == 1) return pal.eval(pos);
		return 0;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var grad = outputs[| 0].getValue();
		if(!is_array(grad)) grad = [ grad ];
		var _h = array_length(grad) * 32;
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(grad);
			
		for( var i = 0, n = array_length(grad); i < n; i++ ) {
			grad[i].draw(bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
		
		if(_h != min_h) will_setHeight = true;
		min_h = _h;	
	} #endregion
}
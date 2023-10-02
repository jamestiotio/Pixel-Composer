function Node_Atlas_Set(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Atlas Set";
	previewable = true;
	
	inputs[| 0] = nodeValue("Atlas", self, JUNCTION_CONNECT.input, VALUE_TYPE.atlas, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
	
	inputs[| 3] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
		
	inputs[| 5] = nodeValue("Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [])
		.setArrayDepth(1);
		
	inputs[| 6] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1);
	
	outputs[| 0] = nodeValue("Atlas", self, JUNCTION_CONNECT.output, VALUE_TYPE.atlas, noone);
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var atl = getInputData(0);
		
		if(atl == noone) return;
		if(is_array(atl) && array_length(atl) == 0) return;
		
		if(!is_array(atl))
			atl = [ atl ];
		
		var surf = getInputData(1);
		var posi = getInputData(2);
		var rota = getInputData(3);
		var scal = getInputData(4);
		var blns = getInputData(5);
		var alph = getInputData(6);
		
		var use = [ 0 ];
		for( var i = 1; i < 7; i++ ) use[i] = inputs[| i].value_from != noone;
		
		var natl = [];
		
		for( var i = 0, n = array_length(atl); i < n; i++ ) {
			natl[i] = atl[i].clone();
			
			if(use[1]) natl[i].surface.set(array_safe_get(surf, i));
			if(use[2]) natl[i].position =  array_safe_get(posi, i);
			if(use[3]) natl[i].rotation =  array_safe_get(rota, i);
			if(use[4]) natl[i].scale    =  array_safe_get(scal, i);
			if(use[5]) natl[i].blend    =  array_safe_get(blns, i);
			if(use[6]) natl[i].alpha    =  array_safe_get(alph, i);
		}
		
		outputs[| 0].setValue(natl);
	}
}
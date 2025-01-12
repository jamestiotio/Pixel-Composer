function Node_Iterate_Filter(_x, _y, _group = noone) : Node_Iterator(_x, _y, _group) constructor {
	name  = "Filter Array";
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, noone );
	
	custom_input_index  = ds_list_size(inputs);
	custom_output_index = ds_list_size(inputs);
	
	if(NODE_NEW_MANUAL) { #region
		var input  = nodeBuild("Node_Iterator_Filter_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Filter_Output", 256, -32, self);
		
		output.inputs[| 0].setFrom(input.outputs[| 0]);
	} #endregion
	
	static onStep = function() { #region
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].setType(type);
	} #endregion
	
	static doInitLoop = function() { #region
		var arrIn  = getInputData(0);
		var arrOut = outputs[| 0].getValue();
		
		var _int = noone;
		var _oup = noone;
		
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var _n = nodes[| i];
			
			if(is_instanceof(_n, Node_Iterator_Filter_Input))
				_int = _n;
			if(is_instanceof(_n, Node_Iterator_Filter_Output))
				_oup = _n;
		}
		
		if(_int == noone) {
			noti_warning("Filter Array: Input node not found.");
			return;
		}
		
		if(_oup == noone) {
			noti_warning("Filter Array: Output node not found.");
			return;
		}
		
		var _ofr = _oup.inputs[| 0].value_from;
		var _imm = _ofr && is_instanceof(_ofr.node, Node_Iterator_Filter_Input);
		
		if(!_imm) surface_array_free(arrOut);
		outputs[| 0].setValue([])
	} #endregion
	
	static getIterationCount = function() { #region
		var arrIn = getInputData(0);
		var maxIter = is_array(arrIn)? array_length(arrIn) : 0;
		if(!is_real(maxIter)) maxIter = 1;
		
		return maxIter;
	} #endregion
}
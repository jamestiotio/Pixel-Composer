function Node_Lua_Surface(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lua Surface";
	preview_channel = 1;
	update_on_frame = true;
	
	inputs[| 0]  = nodeValue("Function name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "render" + string(irandom_range(100000, 999999)));
	
	inputs[| 1]  = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 2]  = nodeValue("Lua code", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", o_dialog_lua_reference)
		.setDisplay(VALUE_DISPLAY.codeLUA);
	
	inputs[| 3]  = nodeValue("Execution thread", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, noone)
		.setVisible(false, true);
	
	inputs[| 4]  = nodeValue("Execute on frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	outputs[| 0] = nodeValue("Execution thread", self, JUNCTION_CONNECT.output, VALUE_TYPE.node, noone );
	
	outputs[| 1] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	argumentRenderer(global.lua_arguments);
	
	input_display_list = [ 3, 4, 
		["Function",	false], 0, 1,
		["Arguments",	false], argument_renderer,
		["Script",		false], 2,
		["Inputs",		 true], 
	];

	setIsDynamicInput(3, false);
	
	argument_name = [];
	argument_val  = [];
	
	lua_state = lua_create();
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Argument name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue("Argument type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
			.setDisplay(VALUE_DISPLAY.enum_scroll, { data: [ "Number", "String", "Surface", "Struct" ], update_hover: false });
		inputs[| index + 1].editWidget.interactable = false;
		
		inputs[| index + 2] = nodeValue("Argument value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
		inputs[| index + 2].editWidget.interactable = false;
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
	static getState = function() { #region
		if(inputs[| 3].value_from == noone) 
			return lua_state;
		return inputs[| 3].value_from.node.getState();
	} #endregion
	
	static refreshDynamicInput = function() { #region
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(getInputData(i) != "") {
				ds_list_add(_in, inputs[| i + 0]);
				ds_list_add(_in, inputs[| i + 1]);
				ds_list_add(_in, inputs[| i + 2]);
				
				inputs[| i + 1].editWidget.interactable = true;
				if(inputs[| i + 2].editWidget != noone)
					inputs[| i + 2].editWidget.interactable = true;
				
				var type = getInputData(i + 1);
				switch(type) {
					case 0 : inputs[| i + 2].setType(VALUE_TYPE.float);		break;
					case 1 : inputs[| i + 2].setType(VALUE_TYPE.text);		break;
					case 2 : inputs[| i + 2].setType(VALUE_TYPE.surface);	break;
					case 3 : inputs[| i + 2].setType(VALUE_TYPE.struct);	break;
				}
					
				inputs[| i + 2].setDisplay(VALUE_DISPLAY._default);
				array_push(input_display_list, i + 2);
			} else {
				delete inputs[| i + 0];
				delete inputs[| i + 1];
				delete inputs[| i + 2];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(LOADING || APPENDING) return;
		
		if((index - input_fix_len) % data_length == 0) refreshDynamicInput();
	} #endregion
	
	static step = function() { #region
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var name = getInputData(i + 0);
			inputs[| i + 2].name = name;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _func = getInputData(0);
		var _dimm = getInputData(1);
		var _exec = getInputData(4);
		update_on_frame = _exec;
		
		argument_val  = [];
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length )
			array_push(argument_val, getInputData(i + 2));
		
		lua_projectData(getState());
		addCode();
		
		var _outSurf = outputs[| 1].getValue();
		_outSurf = surface_verify(_outSurf, _dimm[0], _dimm[1], attrDepth());
		
		surface_set_target(_outSurf);
			try      { lua_call_w(getState(), _func, argument_val); }
			catch(e) { noti_warning(exception_print(e),, self);     }
		surface_reset_target();
		
		outputs[| 1].setValue(_outSurf);
	} #endregion
	
	static addCode = function() { #region
		var _func = getInputData(0);
		var _code = getInputData(2);
		argument_name = [];
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			array_push(argument_name, getInputData(i + 0));
		}
		
		var lua_code = $"function {_func}(";
		for( var i = 0, n = array_length(argument_name); i < n; i++ ) {
			if(i) lua_code += ", "
			lua_code += argument_name[i];
		}
		
		lua_code += $")\n{_code}\nend";
		
		lua_add_code(getState(), lua_code);
	} #endregion
	
	static doApplyDeserialize = function() { #region
		refreshDynamicInput();
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var name = getInputData(i + 0);
			var type = getInputData(i + 1);
			
			inputs[| i + 2].name = name;
			
			switch(type) {
				case 0 : inputs[| i + 2].setType(VALUE_TYPE.float);		break;
				case 1 : inputs[| i + 2].setType(VALUE_TYPE.text);		break;
				case 2 : inputs[| i + 2].setType(VALUE_TYPE.surface);	break;
				case 3 : inputs[| i + 2].setType(VALUE_TYPE.struct);	break;
			}
			
			inputs[| i + 2].setDisplay(VALUE_DISPLAY._default);
		}
		
		doCompile();
	} #endregion
	
	static onDestroy = function() { #region
		lua_state_destroy(lua_state);
	} #endregion
}
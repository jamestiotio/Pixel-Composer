function Node_VCT(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "VCT";
	icon   = THEME.vct;
	color  = COLORS.node_blend_vct;
	vct    = new VCT(self);
	
	inputs[| 0] = nodeValue("Editor", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, { name: "Editor", onClick: function() {
			vct.createDialog();
		} });
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	input_display_list = [ 0, 
		["Automations", false], 
	];

	setIsDynamicInput(1);
	
	static createNewInput = function(key = "") {
		var index = ds_list_size(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		var name  = string_title(string_replace_all(key, "_", " "));
		
		var _var  = vct[$ key];
		
		inputs[| index] = nodeValue(name, self, JUNCTION_CONNECT.input, _var.type, 0)
			.setDisplay(_var.disp, _var.disp_data);
		inputs[| index].display_data.key = key;
		
		array_append(input_display_list, [ index ]);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		for( var i = 1; i < array_length(_data); i++ )
			vct[$ inputs[| i].display_data.key].setDirect(_data[i]);
			
		var params = {
			frame: CURRENT_FRAME
		};
		
		return vct.process(params);
	}
	
	static onDoubleClick = function(panel) {
		vct.createDialog();
	}
	
	static doSerialize = function(_map) {
		_map.vct = vct.serialize();
	}
	
	static postDeserialize = function() {
		vct.deserialize(load_map.vct);
		
		//for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
		//	createNewInput(_inputs[i].display_data.key);
	}
}
function Node_create_Image_Animated(_x, _y, _group = noone) { #region
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filenames_compat("image|*.png;*.jpg", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node  = new Node_Image_Animated(_x, _y, _group);
	var paths = string_splice(path, "\n");
	node.inputs[| 0].setValue(paths);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
} #endregion

function Node_create_Image_Animated_path(_x, _y, _path) { #region
	var node = new Node_Image_Animated(_x, _y, PANEL_GRAPH.getCurrentContext());
	
	node.inputs[| 0].setValue(_path);
	node.doUpdate();
	
	return node;
} #endregion

enum ANIMATION_END {
	loop,
	ping,
	hold,
	hide
}

function Node_Image_Animated(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Animation";
	spr   = [];
	color = COLORS.node_blend_input;
	
	update_on_frame = true;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, [])
		.setDisplay(VALUE_DISPLAY.path_array, { filter: ["image|*.png;*.jpg", ""] });
	
	inputs[| 1]  = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding)
		.rejectArray();
		
	inputs[| 2] = nodeValue("Stretch frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Stretch animation speed to match project length.")
		.rejectArray();
	
	inputs[| 3] = nodeValue("Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.rejectArray();
		
	inputs[| 4] = nodeValue("Loop modes", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Loop", "Ping pong", "Hold last frame", "Hide"])
		.rejectArray();
		
	inputs[| 5] = nodeValue("Set animation length to match", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Match length", UI : true, onClick: function() { 
				if(array_length(spr) == 0) return;
				TOTAL_FRAMES = array_length(spr);
			} });
	
	inputs[| 6]  = nodeValue("Custom frame order", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7]  = nodeValue("Frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);

	inputs[| 8] = nodeValue("Canvas size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2) 
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "First", "Minimum", "Maximum" ])
		.rejectArray();
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Image", false],		0, 1, 8, 
		["Animation", false],	5, 4, 2, 3, 
		["Custom Frame Order", false, 6], 7, 
	];
	
	attribute_surface_depth();
	
	path_current = [];
	edit_time    = 0;
	
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() { return attributes.file_checker; }, 
		new checkBox(function() { attributes.file_checker = !attributes.file_checker; }) ]);
	
	on_drop_file = function(path) { #region
		if(directory_exists(path)) {
			with(dialogCall(o_dialog_drag_folder, WIN_W / 2, WIN_H / 2)) {
				dir_paths = path;
				target    = other;
			}
			return true;
		}
		
		var paths = paths_to_array_ext(path);
		
		inputs[| 0].setValue(paths);
		if(updatePaths(paths)) {
			doUpdate();
			return true;
		}
		
		return false;
	} #endregion
	
	function updatePaths(paths = path_current) { #region
		if(!is_array(paths) && ds_exists(paths, ds_type_list))
			paths = ds_list_to_array(paths);
		
		for(var i = 0; i < array_length(spr); i++) {
			if(spr[i] && sprite_exists(spr[i]))
				sprite_delete(spr[i]);
		}
		
		spr = [];
		path_current = [];
		
		for( var i = 0, n = array_length(paths); i < n; i++ )  {
			var _path = path_get(paths[i]);
			if(_path == -1) continue;
			
			array_push(path_current, _path);
			setDisplayName(filename_name_only(_path));
			
			var ext = string_lower(filename_ext(_path));
			
			switch(ext) {
				case ".png"	 :
				case ".jpg"	 :
				case ".jpeg" :
					var _spr = sprite_add(_path, 1, false, false, 0, 0);
					
					if(_spr == -1) {
						noti_warning($"Image node: File not a valid image.");
						return false;
					}
					
					edit_time = max(edit_time, file_get_modify_s(_path));
					array_push(spr, _spr);
					break;
			}
		}
		
		return true;
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		updatePaths(path_get(getInputData(0)));
		triggerRender();
	} #endregion
	
	static step = function() { #region
		var str  = getInputData(2);
		var _cus = getInputData(6);
		
		inputs[| 2].setVisible(!_cus);
		inputs[| 3].setVisible(!_cus && !str);
		inputs[| 4].setVisible(!_cus && !str);
		
		if(attributes.file_checker)
		for( var i = 0, n = array_length(path_current); i < n; i++ ) {
			if(file_get_modify_s(path_current[i]) > edit_time) {
				updatePaths();
				triggerRender();
				break;
			}
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = path_get(getInputData(0));
		if(!array_equals(path_current, path)) 
			updatePaths(path);
			
		if(array_length(spr) == 0) return;
		
		var _pad = getInputData(1);
		
		var _cus = getInputData(6);
		var _str = getInputData(2);
		var _end = getInputData(4);
		var _spd = _str? (TOTAL_FRAMES + 1) / array_length(spr) : 1 / getInputData(3);
		if(_spd == 0) _spd = 1;
		var _frame = _cus? getInputData(7) : floor(CURRENT_FRAME / _spd);
		
		var _len = array_length(spr);
		var _drw = true;
		
		var _siz = getInputData(8); 
		var sw = sprite_get_width(spr[0]); 
		var sh = sprite_get_height(spr[0]);
		
		if(_siz) {
			for( var i = 1, n = array_length(spr); i < n; i++ ) {
				var _sw = sprite_get_width(spr[i]); 
				var _sh = sprite_get_height(spr[i]);
				
				if(_siz == 1) {
					sw = min(_sw, sw);
					sh = min(_sh, sh);
				} else if(_siz == 2) {
					sw = max(_sw, sw);
					sh = max(_sh, sh);
				}
			}
		}
		
		var ww = sw;
		var hh = sh;
		
		ww += _pad[0] + _pad[2];
		hh += _pad[1] + _pad[3];
		
		var surfs = outputs[| 0].getValue();
		surfs = surface_verify(surfs, ww, hh, attrDepth());
		outputs[| 0].setValue(surfs);
		
		switch(_end) {
			case ANIMATION_END.loop : 
				_frame = safe_mod(_frame, _len);
				break;
			case ANIMATION_END.ping :
				_frame = safe_mod(_frame, _len * 2 - 2);
				if(_frame >= _len)
					_frame = _len * 2 - 2 - _frame;
				break;
			case ANIMATION_END.hold :
				_frame = min(_frame, _len - 1);
				break;
			case ANIMATION_END.hide :	
				if(_frame < 0 || _frame >= _len) 
					_drw = false;
				break;
		}
		
		var _spr   = array_safe_get_fast(spr, _frame, noone);
		if(_spr == noone) return;
		
		var curr_w = sprite_get_width(spr[_frame]);
		var curr_h = sprite_get_height(spr[_frame]);
		var curr_x = _pad[2] + (sw - curr_w) / 2;
		var curr_y = _pad[1] + (sh - curr_h) / 2;
		
		surface_set_shader(surfs);
			if(_drw) draw_sprite(spr[_frame], 0, curr_x, curr_y);
		surface_reset_shader();
	} #endregion
}
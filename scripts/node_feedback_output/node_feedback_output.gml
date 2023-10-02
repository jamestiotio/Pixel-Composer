function Node_Feedback_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Feedback Output";
	color = COLORS.node_blend_feedback;
	
	w = 96;
	h = 32 + 24 * 2;
	min_h = h;
	
	inputs[| 2] = nodeValue("Feedback loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.node, -1)
		.setVisible(true, true);
	
	cache_value = -1;
	
	static update = function(frame = PROJECT.animator.current_frame) {
		if(inputs[| 0].value_from == noone) return;
		if(PROJECT.animator.current_frame == PROJECT.animator.frames_total - 1) {
			cache_value = noone;
			return;
		}
		
		var _val_get = getInputData(0);
		var _arr     = inputs[| 0].value_from.isArray();
		var is_surf	 = inputs[| 0].type == VALUE_TYPE.surface;
		
		if(is_array(cache_value)) {
			for( var i = 0, n = array_length(cache_value); i < n; i++ ) {
				if(is_surface(cache_value[i])) 
					surface_free(cache_value[i]);
			}
		} else if(is_surface(cache_value)) 
			surface_free(cache_value);
		
		if(_arr) {
			var amo = is_array(_val_get)? array_length(_val_get) : 0;
			cache_value = array_create(amo);
			
			if(is_surf) {
				for( var i = 0; i < amo; i++ ) {
					if(is_surface(_val_get[i]))	
						cache_value[i] = surface_clone(_val_get[i]);
				}
			} else 
				cache_value = _val_get;
		} else {
			if(is_surf) {
				if(is_surface(_val_get))	
					cache_value = surface_clone(_val_get);
			} else
				cache_value = _val_get;
		}
	}
}
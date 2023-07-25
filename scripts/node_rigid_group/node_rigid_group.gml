function Node_Rigid_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "RigidSim";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	update_on_frame = true;
	
	ungroupable		= false;
	update_on_frame = true;
	collIndex		= irandom_range(1, 9999);
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _render = nodeBuild("Node_Rigid_Render", 256, -32, self);
		var _output = nodeBuild("Node_Group_Output", 416, -32, self);
		
		_output.inputs[| 0].setFrom(_render.outputs[| 0]);
	}
	
	static reset = function() { 
		instance_destroy(oRigidbody);
		
		physics_pause_enable(true);
		
		var node_list = getNodeList();
		for( var i = 0; i < ds_list_size(node_list); i++ ) {
			var _node = node_list[| i];
			if(variable_struct_exists(_node, "reset"))
				_node.reset();
		}
		
		physics_pause_enable(false);
	}
	
	static update = function() {
		if(PROJECT.animator.current_frame == 0)
			reset();
	}
	
	PATCH_STATIC
}
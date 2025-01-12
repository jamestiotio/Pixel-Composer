function Node_Rigid_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "RigidSim";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	is_simulation      = true;
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 10 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	if(NODE_NEW_MANUAL) {
		var _object = nodeBuild("Node_Rigid_Object", x,       y);
		var _output = nodeBuild("Node_Rigid_Render", x + 160, y);
		
		_output.inputs[| 2].setFrom(_object.outputs[| 0])
		
		addNode(_object);
		addNode(_output);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _gra = getInputData(0);
		
		physics_world_gravity(_gra[0], _gra[1]);
	}
}
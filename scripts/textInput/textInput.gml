function textInput(_input, _onModify, _extras = noone) : widget() constructor {
	input = _input;
	onModify = _onModify;
	extras = _extras;
	
	static _resetFocus = function() { resetFocus();	}
	
	static onKey = function(key) {}
}
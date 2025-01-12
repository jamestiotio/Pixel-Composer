function NodeTool(name, spr, context = instanceof(other)) constructor {
	ctx         = context;
	self.name   = name;
	self.spr    = spr;
	
	subtools  = is_array(spr)? array_length(spr) : 0;
	selecting = 0;
	settings  = [];
	attribute = {};
	
	toolObject  = noone;
	toolFn      = noone;
	toolFnParam = {};
	
	static checkHotkey = function() {
		INLINE
		
		return getToolHotkey(ctx, name);
	}
	
	static setToolObject = function(toolObject) { self.toolObject = toolObject; return self; }
	static setToolFn     = function(toolFn) {     self.toolFn     = toolFn;     return self; }
	
	static getName = function(index = 0) { return is_array(name)? array_safe_get_fast(name, index, "") : name; }
	
	static getToolObject = function() { return is_array(toolObject)? toolObject[selecting] : toolObject; }
	
	static getDisplayName = function(index = 0) {
		var _nme = getName(index);
		var _key = checkHotkey();
		
		return _key == ""? _nme : new tooltipHotkey(_nme).setKey(_key);
	}
	
	static setSetting = function(sets) { array_push(settings, sets); return self; }
	
	static addSetting = function(name, type, onEdit, keyAttr, val) {
		var w;
		
		switch(type) {
			case VALUE_TYPE.float : 
				w = new textBox(TEXTBOX_INPUT.number, onEdit);
				w.font = f_p3;
				break;
			case VALUE_TYPE.boolean : 
				w = new checkBox(onEdit);
				break;
		}
		
		array_push(settings, [ name, w, keyAttr, attribute ]);
		attribute[$ keyAttr] = val;
		
		return self;
	}
	
	static toggle = function(index = 0) {
		if(toolFn != noone) {
			if(subtools == 0) toolFn(ctx);
			else              toolFn[index](ctx);
			return;
		}
		
		if(subtools == 0) {
			PANEL_PREVIEW.tool_current = PANEL_PREVIEW.tool_current == self? noone : self;
		} else {
			if(PANEL_PREVIEW.tool_current == self && index == selecting) {
				PANEL_PREVIEW.tool_current = noone;
				selecting = 0;
			} else {
				PANEL_PREVIEW.tool_current = self;
				selecting = index;
			}
		}
		
		if(PANEL_PREVIEW.tool_current == self)
			onToggle();
			
		var _obj = getToolObject();
		if(_obj) _obj.init(ctx);
	}
	
	static toggleKeyboard = function() {
		if(subtools == 0) {
			PANEL_PREVIEW.tool_current = PANEL_PREVIEW.tool_current == self? noone : self;
		} else if(PANEL_PREVIEW.tool_current != self) {
			PANEL_PREVIEW.tool_current = self;
			selecting = 0;
		} else if(selecting == subtools - 1) {
			PANEL_PREVIEW.tool_current = noone;
			selecting = 0;
		} else 
			selecting++;
		
		if(PANEL_PREVIEW.tool_current == self)
			onToggle();
	}
	
	static onToggle = function() {}
}
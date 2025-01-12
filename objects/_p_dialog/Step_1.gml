/// @description init
if !ready  exit;
if !active exit;

#region window control
	if(sFOCUS) {
		if(destroy_on_escape && keyboard_check_pressed(vk_escape) && checkClosable())
			instance_destroy(self);
	}
#endregion

#region resize
	if(_dialog_h != dialog_h || _dialog_w != dialog_w) {
		_dialog_h = dialog_h;
		_dialog_w = dialog_w;
		
		if(onResize != -1) onResize();
	}
#endregion
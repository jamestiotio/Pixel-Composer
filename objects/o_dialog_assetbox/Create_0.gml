/// @description init
event_inherited();

#region display
	draggable = false;
	destroy_on_click_out = true;
	
	target = noone;
	
	dialog_w = 608;
	dialog_h = 320;
	
	anchor = ANCHOR.top | ANCHOR.right;
	
	dialog_resizable = true;
	dialog_w_min = 200;
	dialog_h_min = 120;
	dialog_w_max = 640;
	dialog_h_max = 480;
#endregion

#region context
	context = global.ASSETS;
	
	function gotoDir(dirName) {
		for(var i = 0; i < ds_list_size(global.ASSETS.subDir); i++) {
			var d = global.ASSETS.subDir[| i];
			if(d.name != dirName) continue;
			
			d.open = true;
			setContext(d);
		}
	}
	
	function setContext(cont) {
		context = cont;
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	}
#endregion

#region surface
	folderW = 180;
	content_w = dialog_w - 32 - folderW;
	content_h = dialog_h - 32;
	
	function onResize() {
		content_w = dialog_w - 32 - folderW;
		content_h = dialog_h - 32;
		contentPane.resize(content_w, content_h);
		folderPane.resize(folderW - 8, content_h - 32);
	}
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var contents = context.content;
		var amo      = ds_list_size(contents);
		var hh = 0;
		var frame = current_time * PREF_MAP[? "collection_preview_speed"] / 8000;
		
		var grid_size = 64;
		var img_size  = grid_size - 16;
		var grid_space = 12;
		var col = max(1, floor(content_w / (grid_size + grid_space)));
		var row = ceil(amo / col);
		var yy  = _y + grid_space;
			
		hh += grid_space;
		
		for(var i = 0; i < row; i++) {
			for(var j = 0; j < col; j++) {
				var index = i * col + j;
				if(index < amo) {
					var content = contents[| index];
					var xx   = grid_space + (grid_size + grid_space) * j;
					
					BLEND_ADD
					draw_sprite_stretched(s_node_bg, 0, xx, yy, grid_size, grid_size);
					BLEND_NORMAL
						
					if(point_in_rectangle(_m[0], _m[1], xx, yy, xx + grid_size, yy + grid_size)) {
						draw_sprite_stretched(s_node_active, 0, xx, yy, grid_size, grid_size);	
						if(mouse_check_button_pressed(mb_left)) {
							target.onModify(content.path);
							instance_destroy();
						}
					}
					
					if(sprite_exists(content.spr)) {
						var sw = sprite_get_width(content.spr);
						var sh = sprite_get_height(content.spr);
						var ss = img_size / max(sw, sh);
						var sx = xx + (grid_size - sw * ss) / 2;
						var sy = yy + (grid_size - sh * ss) / 2;
						
						draw_sprite_ext(content.spr, frame, sx, sy, ss, ss, 0, c_white, 1);
					}
				}
			}
			var hght = grid_size + grid_space;
			hh += hght;
			yy += hght;
		}
		
		return hh;
	});
	
	folderPane = new scrollPane(folderW - 8, content_h - 48, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		var hh = 8;
		
		for(var i = 0; i < ds_list_size(global.ASSETS.subDir); i++) {
			var hg = global.ASSETS.subDir[| i].draw(self, 8, _y, _m, folderPane.w - 16, HOVER == self, FOCUS == self, global.ASSETS);
			hh += hg;
			_y += hg;
		}
		
		return hh;
	});
#endregion
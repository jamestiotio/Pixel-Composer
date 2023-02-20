/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(56), dialog_y + ui(20), get_text("history_title", "Action history"));
	
	var bx = dialog_x + ui(24);
	var by = dialog_y + ui(18);
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, destroy_on_click_out? get_text("noti_unpin", "Unpin") : get_text("noti_pin", "Pin"), 
		THEME.pin, !destroy_on_click_out, destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light) == 2)
			destroy_on_click_out = !destroy_on_click_out;
	
#endregion

#region preset
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(64);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(64 + padding)
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sc_history.active = sFOCUS;
	sc_history.draw(px, py);
#endregion
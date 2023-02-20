/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), get_text("output_visibility_title", "Outputs visibility"));
#endregion

#region preset
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(56);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(56 + padding)
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sc_outputs.active = sFOCUS;
	sc_outputs.draw(px, py);
#endregion
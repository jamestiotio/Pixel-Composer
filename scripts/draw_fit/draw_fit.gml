function draw_sprite_fit(spr, ind, xx, yy, w, h) {
	var ss = min(w / sprite_get_width(spr), h / sprite_get_height(spr));
	draw_sprite_ext(spr, ind, xx, yy, ss, ss, 0, c_white, 1);
}

function draw_surface_fit(surf, xx, yy, w, h) {
	var ss = min(w / surface_get_width(surf), h / surface_get_height(surf));
	draw_surface_ext_safe(surf, xx, yy, ss, ss);
}

function draw_surface_stretch_fit(surf, xx, yy, w, h, sw, sh) {
	var ss = min(w / sw, h / sh);
	draw_surface_stretched_safe(surf, xx - sw * ss / 2, yy - sh * ss / 2, sw * ss, sh * ss);
}
#region save
	globalvar LOADING, LOADING_VERSION, APPENDING, CLONING, SAFE_MODE;
	globalvar MODIFIED, CURRENT_PATH, READONLY, CONNECTION_CONFLICT, GLOBAL_SEED, ALWAYS_FULL;
	globalvar RENDERING;
	
	RENDERING = false;
	
	LOADING = false;
	CLONING = false;
	LOADING_VERSION = 0;
	APPENDING = false;
	READONLY  = false;
	SAFE_MODE = false;
	
	CURRENT_PATH = "";
	MODIFIED  = false;
	CONNECTION_CONFLICT = ds_queue_create();
	
	randomize();
	GLOBAL_SEED = irandom(9999999999);
	ALWAYS_FULL = false;
#endregion

#region main
	globalvar OS, DEBUG, THEME, CDEF, COLORS, COLOR_KEYS;
	OS = os_type;
	//OS = os_macosx;
	
	DEBUG = false;
	THEME = {};
	COLOR_KEYS = [];
	
	globalvar VERSION, SAVEFILE_VERSION, VERSION_STRING;
	VERSION = 1138;
	SAVEFILE_VERSION = 1138;
	VERSION_STRING = "1.13.8";
	
	globalvar NODES, NODE_MAP, APPEND_MAP, HOTKEYS, HOTKEY_CONTEXT, NODE_INSTANCES;
	
	NODES			= ds_list_create();
	NODE_INSTANCES	= ds_list_create();
	NODE_MAP	= ds_map_create();
	APPEND_MAP  = ds_map_create();
	
	HOTKEYS			= ds_map_create();
	HOTKEY_CONTEXT	= ds_list_create();
	HOTKEY_CONTEXT[| 0] = "";
	
	globalvar CURSOR, TOOLTIP, DIALOG_DEPTH_HOVER;
	globalvar UPDATE, RENDER_QUEUE;
#endregion

#region inputs
	globalvar FOCUS, FOCUS_STR, HOVER, DOUBLE_CLICK, CURRENT_PATH, DIALOG_CLICK;
	
	CURRENT_PATH = "";
	DOUBLE_CLICK = false;
	FOCUS = noone;
	FOCUS_STR = "";
	HOVER = noone;
	DIALOG_CLICK = true;
	
	globalvar ADD_NODE_PAGE;
	ADD_NODE_PAGE = 0;
#endregion

#region macro
	#macro WIN_W window_get_width()
	#macro WIN_H window_get_height()
	
	#macro WIN_SW window_get_width()
	#macro WIN_SH window_get_height()
	
	#macro UI_SCALE PREF_MAP[? "display_scaling"]
	
	#macro mouse_mx device_mouse_x_to_gui(0)
	#macro mouse_my device_mouse_y_to_gui(0)
	#macro mouse_ui [device_mouse_x_to_gui(0), device_mouse_y_to_gui(0)]
	
	#macro sFOCUS FOCUS == self.id
	#macro sHOVER HOVER == self.id
	
	#macro DELTA_TIME delta_time / 1_000_000
	
	#macro CONF_TESTING false
	#macro Tester:CONF_TESTING true
	globalvar TESTING;
	TESTING = CONF_TESTING;
	
	#macro DEMO false
	#macro Demo:DEMO true
	
	#region color
		#macro c_ui_blue_dkblack	$251919
		#macro c_ui_blue_mdblack	$2c1e1e
		#macro c_ui_blue_black		$362727
		#macro c_ui_blue_dkgrey		$4e3b3b
		#macro c_ui_blue_grey		$816d6d
		#macro c_ui_blue_ltgrey		$8f7e7e
		#macro c_ui_blue_white		$e8d6d6
		#macro c_ui_cyan			$e9ff88
		
		#macro c_ui_yellow			$78e4ff
		#macro c_ui_orange			$6691ff
		#macro c_ui_orange_light	$92c2ff
		
		#macro c_ui_red				$4b00eb
		#macro c_ui_pink			$b700eb
		#macro c_ui_purple			$d40092
		
		#macro c_ui_lime_dark		$38995e
		#macro c_ui_lime			$5dde8f
		#macro c_ui_lime_light		$b2ffd0
		
		#macro c_ui_white			$ffffff
	#endregion
	
	#region functions
		#macro BLEND_NORMAL gpu_set_blendmode(bm_normal)
		#macro BLEND_ADD gpu_set_blendmode(bm_add)
		#macro BLEND_OVERRIDE gpu_set_blendmode_ext(bm_one, bm_zero)
		
		#macro BLEND_ALPHA gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_alpha, bm_one, bm_one)
		#macro BLEND_ALPHA_MULP gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one)
	#endregion
	
	#macro printlog if(log) show_debug_message
	
	#macro RETURN_ON_REST if(!ANIMATOR.is_playing || !ANIMATOR.frame_progress) return;
	
	function print(str) {
		show_debug_message(string(str));
		noti_status(string(str));
	}
	
	function printIf(cond, log) {
		if(!cond) return;
		show_debug_message(log);
	}
#endregion

#region presets
	function INIT_FOLDERS() {
		if(!directory_exists(DIRECTORY + "Palettes"))
			directory_create(DIRECTORY + "Palettes");
		if(!directory_exists(DIRECTORY + "Gradients"))
			directory_create(DIRECTORY + "Gradients");
	}
#endregion

#region default
	globalvar DEF_SURFACE;
	function DEF_SURFACE_RESET() {
		DEF_SURFACE = surface_create_valid(1, 1);
		surface_set_target(DEF_SURFACE);
			draw_clear_alpha(c_white, 0);
		surface_reset_target();
	}
	DEF_SURFACE_RESET();
#endregion
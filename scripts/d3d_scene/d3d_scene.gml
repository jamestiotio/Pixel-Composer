#region global preview camera
	globalvar D3D_GLOBAL_PREVIEW;
	
	function set3DGlobalPreview() {
		var d3_view_camera = new __3dCamera();
		d3_view_camera.setViewSize(2, 2);
		d3_view_camera.setFocusAngle(135, 45, 8);
		d3_view_camera.position.set(calculate_3d_position(0, 0, 0, d3_view_camera.focus_angle_x, d3_view_camera.focus_angle_y, d3_view_camera.focus_dist));
		
		d3_view_camera.projection = CAMERA_PROJECTION.orthograph;
		d3_view_camera.setMatrix();
		
		D3D_GLOBAL_PREVIEW = new __3dScene(d3_view_camera);
		D3D_GLOBAL_PREVIEW.apply_transform = true;
		D3D_GLOBAL_PREVIEW.defer_normal    = false;
	
		var d3_scene_light0 = new __3dLightDirectional();
		d3_scene_light0.transform.position.set(-1, -2, 3);
		d3_scene_light0.color  = $AAAAAA;
		
		var d3_scene_light1 = new __3dLightDirectional();
		d3_scene_light1.transform.position.set(1, 2, 3);
		d3_scene_light1.color  = $FFFFFF;
	
		D3D_GLOBAL_PREVIEW.lightAmbient = $404040;
		D3D_GLOBAL_PREVIEW.addLightDirectional(d3_scene_light0);
		D3D_GLOBAL_PREVIEW.addLightDirectional(d3_scene_light1);
	}
#endregion

function __3dScene(camera) constructor {
	self.camera = camera;
	name = "New scene";
	
	apply_transform  = false;
	custom_transform = new __transform();
	
	lightAmbient		= c_black;
	lightDir_max		= 16;
	lightDir_shadow_max = 2;
	lightPnt_max		= 16;
	lightPnt_shadow_max = 2;
	
	cull_mode       = cull_noculling;
	enviroment_map  = noone;
	gammaCorrection = true;
	
	draw_background = false;
	
	defer_normal        = true;
	defer_normal_radius = 0;
	
	show_normal  = false;
	
	geometry_data = [ noone, noone, noone ];
	
	ssao_enabled  = false;
	ssao		  = noone;
	ssao_sample   = 32;
	ssao_radius   = 0.1;
	ssao_bias     = 0.1;
	ssao_strength = 1.;
	
	static reset = function() { #region
		lightDir_count     = 0;
		lightDir_direction = [];
		lightDir_color     = [];
		lightDir_intensity = [];
		
		lightDir_shadow_count = 0;
		lightDir_shadow    = [];
		lightDir_shadowMap = [];
		lightDir_viewMat   = [];
		lightDir_projMat   = [];
		lightDir_shadowBias = [];
	
		lightPnt_count     = 0;
		lightPnt_position  = [];
		lightPnt_color     = [];
		lightPnt_intensity = [];
		lightPnt_radius    = [];
		
		lightPnt_shadow_count = 0;
		lightPnt_shadow    = [];
		lightPnt_shadowMap = [];
		lightPnt_viewMat   = [];
		lightPnt_projMat   = [];
		lightPnt_shadowBias = [];
	} reset(); #endregion
	
	static applyCamera = function() { camera.applyCamera(); }
	static resetCamera = function() { camera.resetCamera(); }
	
	static _submit = function(callback, object, shader = noone) {
		matrix_stack_clear(); 
		if(apply_transform) custom_transform.submitMatrix(); 
		callback(object, shader);
		if(apply_transform) custom_transform.clearMatrix(); 
	}
	
	static submit		= function(object, shader = noone) { _submit(function(object, shader) { object.submit		(self, shader); }, object, shader) }
	static submitUI		= function(object, shader = noone) { _submit(function(object, shader) { object.submitUI		(self, shader); }, object, shader) }
	static submitSel	= function(object, shader = noone) { _submit(function(object, shader) { object.submitSel	(self, shader); }, object, shader) }
	static submitShader	= function(object, shader = noone) { _submit(function(object, shader) { object.submitShader	(self, shader); }, object, shader) }
	
	static deferPass = function(object, w, h) { #region
		geometryPass(object, w, h);
		ssaoPass();
	} #endregion
	
	static renderBackground = function(w, h) { #region
		var _bgSurf = surface_create(w, h);
		surface_set_shader(_bgSurf, sh_d3d_background);
			shader_set_color("light_ambient",	lightAmbient);
			shader_set_f("cameraPosition",		camera.position.toArray());
			shader_set_i("env_use_mapping",		is_surface(enviroment_map) );
			shader_set_surface("env_map",		enviroment_map );
			shader_set_dim("env_map_dimension",	enviroment_map );
				
			camera.setMatrix();
			camera.applyCamera();
				
			gpu_set_cullmode(cull_noculling);
			var _s = (camera.view_near + camera.view_far) / 2;
			
			matrix_set(matrix_world, matrix_build(camera.position.x, camera.position.y, camera.position.z, 0, 0, 0, _s, _s, _s));
			vertex_submit(global.SKY_SPHERE.VB[0], pr_trianglelist, -1);
			matrix_set(matrix_world, matrix_build_identity());
		surface_reset_shader();
		
		return _bgSurf;
	} #endregion
	
	static geometryPass = function(object, w = 512, h = 512) { #region
		geometry_data[0] = surface_verify(geometry_data[0], w, h, surface_rgba32float);
		geometry_data[1] = surface_verify(geometry_data[1], w, h, surface_rgba32float);
		geometry_data[2] = surface_verify(geometry_data[2], w, h, surface_rgba32float);
		
		surface_set_target_ext(0, geometry_data[0]);
		surface_set_target_ext(1, geometry_data[1]);
		surface_set_target_ext(2, geometry_data[2]);
			gpu_set_zwriteenable(true);
			gpu_set_ztestenable(true);
			
			DRAW_CLEAR
			camera.setMatrix();
			applyCamera();
			
			gpu_set_cullmode(cull_mode);
			
			shader_set(sh_d3d_geometry);
			shader_set_f("planeNear", camera.view_near);
			shader_set_f("planeFar",  camera.view_far);
			
			submit(object, sh_d3d_geometry);
			
			shader_reset();
			gpu_set_ztestenable(false);
		surface_reset_target();
		
		if(defer_normal_radius) {
			var _normal_blurred = surface_create_size(geometry_data[2], surface_rgba32float);
			surface_set_shader(_normal_blurred, sh_d3d_normal_blur);
				shader_set_f("radius", defer_normal_radius);
				shader_set_dim("dimension", geometry_data[2]);
				draw_surface_safe(geometry_data[2]);
			surface_reset_shader();
		
			surface_free(geometry_data[2]);
			geometry_data[2] = _normal_blurred;
		}
	} #endregion
	
	static ssaoPass = function() { #region
		surface_free_safe(ssao);
		if(!ssao_enabled) return;
		
		var _sw = surface_get_width(geometry_data[0]);
		var _sh = surface_get_height(geometry_data[0]);
		var _ssao_surf = surface_create(_sw, _sh);
		
		surface_set_shader(_ssao_surf, sh_d3d_ssao);
			shader_set_surface("vPosition", geometry_data[0]);
			shader_set_surface("vNormal",   geometry_data[2]);
			shader_set_f("radius",   ssao_radius);
			shader_set_f("bias",     ssao_bias);
			shader_set_f("strength", ssao_strength * 2);
			shader_set_f("projMatrix",     camera.getCombinedMatrix());
			shader_set_f("cameraPosition", camera.position.toArray());
		
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _sw, _sh);
		surface_reset_shader();
		
		var _ssao_blur = surface_create(_sw, _sh);
		surface_set_shader(_ssao_blur, sh_d3d_ssao_blur);
			shader_set_f("dimension", _sw, _sh);
			shader_set_surface("vNormal",   geometry_data[2]);
			
			draw_surface_safe(_ssao_surf);
		surface_reset_shader();
		
		surface_free(_ssao_surf);
		
		ssao = _ssao_blur;
	} #endregion
	
	static apply = function() { #region
		shader_set(sh_d3d_default);
			#region ---- background ----
				shader_set_f("light_ambient",		colToVec4(lightAmbient));
				shader_set_i("env_use_mapping",		is_surface(enviroment_map) );
				shader_set_surface("env_map",		enviroment_map, false, true );
				shader_set_dim("env_map_dimension",	enviroment_map );
				shader_set_surface("ao_map",		ssao );
			#endregion
			
			shader_set_i("light_dir_count",		lightDir_count); #region
			if(lightDir_count) {
				shader_set_f("light_dir_direction", lightDir_direction);
				shader_set_f("light_dir_color",		lightDir_color);
				shader_set_f("light_dir_intensity", lightDir_intensity);
				shader_set_i("light_dir_shadow_active", lightDir_shadow);
				for( var i = 0, n = array_length(lightDir_shadowMap); i < n; i++ )
					shader_set_surface($"light_dir_shadowmap_{i}", lightDir_shadowMap[i], true);
				shader_set_f("light_dir_view",		lightDir_viewMat);
				shader_set_f("light_dir_proj",		lightDir_projMat);
				shader_set_f("light_dir_shadow_bias", lightDir_shadowBias);
			} #endregion
			
			shader_set_i("light_pnt_count",		lightPnt_count); #region
			if(lightPnt_count) {
				shader_set_f("light_pnt_position",  lightPnt_position);
				shader_set_f("light_pnt_color",		lightPnt_color);
				shader_set_f("light_pnt_intensity", lightPnt_intensity);
				shader_set_f("light_pnt_radius",    lightPnt_radius);
				shader_set_i("light_pnt_shadow_active", lightPnt_shadow);
				for( var i = 0, n = array_length(lightPnt_shadowMap); i < n; i++ ) 
					shader_set_surface($"light_pnt_shadowmap_{i}", lightPnt_shadowMap[i], true, true);
				shader_set_f("light_pnt_view",		lightPnt_viewMat);
				shader_set_f("light_pnt_proj",		lightPnt_projMat);
				shader_set_f("light_pnt_shadow_bias", lightPnt_shadowBias);
			} #endregion
			
			if(defer_normal && array_length(geometry_data) > 2) {
				shader_set_i("mat_defer_normal", 1);
				shader_set_surface("mat_normal_map", geometry_data[2]);
			} else 
				shader_set_i("mat_defer_normal", 0);
			
			#region ---- camera ----
				shader_set_f("cameraPosition",	camera.position.toArray());
				shader_set_i("gammaCorrection",	gammaCorrection);
				shader_set_f("planeNear",		camera.view_near);
				shader_set_f("planeFar",		camera.view_far );
				
				shader_set_f("viewProjMat",		camera.getCombinedMatrix() );
			#endregion
		shader_reset();
	} #endregion
	
	static addLightDirectional = function(light) { #region
		if(lightDir_count >= lightDir_max) {
			noti_warning("Direction light limit exceeded");
			return self;
		}
		
		array_append(lightDir_direction, [ light.transform.position.x, light.transform.position.y, light.transform.position.z ]);
		array_append(lightDir_color,     colToVec4(light.color));
		
		array_push(lightDir_intensity, light.intensity);
		array_push(lightDir_shadow, light.shadow_active);
		
		if(light.shadow_active) {
			if(lightDir_shadow_count < lightDir_shadow_max) {
				array_push(lightDir_shadowMap, light.shadow_map);
				lightDir_shadow_count++;
			} else 
				noti_warning("Direction light shadow caster limit exceeded");
		}
		array_append(lightDir_viewMat, light.shadow_map_view);
		array_append(lightDir_projMat, light.shadow_map_proj);
		array_push(lightDir_shadowBias, light.shadow_bias);
		lightDir_count++;
		
		return self;
	} #endregion
	
	static addLightPoint = function(light) { #region
		if(lightPnt_count >= lightPnt_max) {
			noti_warning("Point light limit exceeded");
			return self;
		}
		
		array_append(lightPnt_position,  [ light.transform.position.x, light.transform.position.y, light.transform.position.z ]);
		array_append(lightPnt_color,     colToVec4(light.color));
		
		array_push(lightPnt_intensity, light.intensity);
		array_push(lightPnt_radius,    light.radius);
		array_push(lightPnt_shadow,    light.shadow_active);
		
		if(light.shadow_active) {
			if(lightPnt_shadow_count < lightPnt_shadow_max) {
				array_push(lightPnt_shadowMap, light.shadow_map);
				lightPnt_shadow_count++;
			} else 
				noti_warning("Point light shadow caster limit exceeded");
		}
		array_append(lightPnt_viewMat, light.shadow_map_view);
		array_append(lightPnt_projMat, light.shadow_map_proj);
		array_push(lightPnt_shadowBias, light.shadow_bias);
		lightPnt_count++;
		
		return self;
	} #endregion
}
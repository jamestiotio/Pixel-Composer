enum NODE_SCATTER_DIST {
	area,
	border,
	map,
	data,
	path,
	tile
}

function Node_Scatter(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scatter";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Amount", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range, { linked : true });
	
	inputs[| 4] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_random);
	
	onSurfaceSize = function() { return getInputData(1, DEF_SURF); };
	inputs[| 5] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_AREA_REF)
		.setUnitRef(onSurfaceSize, VALUE_UNIT.reference)
		.setDisplay(VALUE_DISPLAY.area, { onSurfaceSize });
	
	inputs[| 6] = nodeValue("Distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 5)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Area", "Border", "Map", "Direct Data", "Path", "Full image + Tile" ]);
	
	inputs[| 7] = nodeValue("Point at center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Rotate each copy to face the spawn center.");
	
	inputs[| 8] = nodeValue("Uniform scaling", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 9] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ]);
	
	inputs[| 10] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 10].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 11] = nodeValue("Random blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
		.setMappable(28);
	
	inputs[| 12] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		
	inputs[| 13] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 14] = nodeValue("Distribution data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 14].array_depth = 1;
	
	inputs[| 15] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, @"What to do when input array of surface.
- Spread: Create Array of output each scattering single surface.
- Mixed: Create single output scattering multiple images.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Spread output", "Index", "Random", "Data", "Texture" ]);
		
	inputs[| 16] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	inputs[| 17] = nodeValue("Use value", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, [ "Scale" ], "Apply the third value in each data point (if exist) on given properties.")
		.setDisplay(VALUE_DISPLAY.text_array, { data: [ "Scale",  "Rotation", "Color" ] });
		
	inputs[| 18] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Normal", "Add", "Max" ]);
		
	inputs[| 19] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone);
		
	inputs[| 20] = nodeValue("Rotate along path", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	inputs[| 21] = nodeValue("Path Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 22] = nodeValue("Scatter Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 23] = nodeValue("Sort Y", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 24] = nodeValue("Array indices", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setArrayDepth(1);
	
	inputs[| 25] = nodeValue("Array texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 26] = nodeValue("Animated array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 27] = nodeValue("Animated array end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Loop", "Ping Pong" ]);
		
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 28] = nodeValueMap("Gradient map", self);
	
	inputs[| 29] = nodeValueGradientRange("Gradient map range", self, inputs[| 11]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 30] = nodeValue("Uniform amount", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 31] = nodeValue("Auto amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 32] = nodeValue("Rotate per radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)	
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 33] = nodeValue("Random position", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 34] = nodeValue("Scale per radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])	
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 35] = nodeValue("Angle range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 360 ])	
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 36] = nodeValue("Shift position", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 37] = nodeValue("Exact", self,  JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.setVisible(false)
		.rejectArrayProcess();
	
	input_display_list = [ 10, 
		["Surfaces", 	 true], 0, 1, 15, 24, 25, 26, 27, 
		["Scatter",		false], 6, 5, 13, 14, 17, 9, 31, 2, 30, 35, 
		["Path",		false], 19, 20, 21, 22, 
		["Position",	false], 33, 36, 37, 
		["Rotation",	false], 7, 4, 32, 
		["Scale",	    false], 3, 8, 34, 
		["Render",		false], 18, 11, 28, 12, 16, 23, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	surface_size_map  = ds_map_create();
	surface_valid_map = ds_map_create();
	
	scatter_data = [];
	scatter_map  = noone;
	scatter_mapa = 0;
	scatter_maps = 0;
	scatter_mapp = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		PROCESSOR_OVERLAY_CHECK
		
		var _distType = current_data[6];
		
		if(_distType < 3) {
			var a = inputs[| 5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !a;
		}
			
		var a = inputs[| 29].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[1]); active &= !a;
	} #endregion
	
	static onValueUpdate = function(index) { #region
		if(index == 15) {
			var _arr = getInputData(15);
			inputs[| 0].array_depth = _arr;
			
			update();
		}
	} #endregion
	
	static step = function() { #region
		var _are = getInputData(5);
		var _dis = getInputData(6);
		var _sct = getInputData(9);
		var _arr = getInputData(15);
		var _amn = getInputData(26);
		
		update_on_frame = _arr && (_amn[0] != 0 || _amn[1] != 0);
		
		inputs[| 0].array_depth = bool(_arr);
		
		inputs[| 13].setVisible(_dis == 2, _dis == 2);
		inputs[| 14].setVisible(_dis == 3, _dis == 3);
		inputs[| 17].setVisible(_dis == 3);
		inputs[|  9].setVisible(_dis != 2 && _dis != 3);
		inputs[| 19].setVisible(_dis == 4, _dis == 4);
		inputs[| 20].setVisible(_dis == 4);
		inputs[| 21].setVisible(_dis == 4);
		inputs[| 22].setVisible(_dis == 4);
		inputs[| 24].setVisible(_arr == 3, _arr == 3);
		inputs[| 25].setVisible(_arr == 4, _arr == 4);
		inputs[| 26].setVisible(_arr);
		inputs[| 27].setVisible(_arr);
		
		inputs[|  5].setVisible(_dis < 3);
		inputs[|  2].setVisible( true);
		inputs[| 30].setVisible(false);
		inputs[| 31].setVisible(false);
		inputs[| 32].setVisible(false);
		inputs[| 34].setVisible(false);
		inputs[| 35].setVisible(false);
		
		if(_dis == 0 && _sct == 0) {
			if(_are[AREA_INDEX.shape] == AREA_SHAPE.elipse) {
				var _aut = getInputData(31);
			
				inputs[|  2].setVisible( _aut);
				inputs[| 30].setVisible(!_aut);
				inputs[| 31].setVisible( true);
				inputs[| 32].setVisible(!_aut);
				inputs[| 34].setVisible(!_aut);
				inputs[| 35].setVisible(!_aut);
				
			} else {
				inputs[|  2].setVisible(false);
				inputs[| 30].setVisible( true);
			}
		} else if(_dis == 5) {
			inputs[|  2].setVisible(_sct == 1);
			inputs[| 30].setVisible(_sct == 0);
		}
		
		inputs[| 11].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		if(_output_index == 1) return scatter_data;
		
		var _inSurf = _data[0];
		if(_inSurf == 0)
			return;
		
		var _dim	= _data[1];
		var _amount	= _data[2];
		var _scale	= _data[3];
		var _rota	= _data[4];
		
		var _area	= _data[5];
		
		var _dist		= _data[ 6];
		var _distMap	= _data[13];
		var _distData	= _data[14];
		var _scat		= _data[ 9];
		
		var _pint	= _data[7];
		var _unis	= _data[8];
		
		var seed	= _data[10];
		var color	= _data[11];
		var clr_map = _data[28];
		var clr_rng = _data[29];
		
		var alpha	= _data[12];
		var _arr    = _data[15];
		var mulpA	= _data[16];
		var useV	= _data[17];
		var blend   = _data[18];
		
		var path    = _data[19];
		var pathRot = _data[20];
		var pathShf = _data[21];
		var pathDis = _data[22];
		var sortY   = _data[23];
		var arrId   = _data[24];
		var arrTex  = _data[25], useArrTex = is_surface(arrTex);
		var arrAnim = _data[26];
		var arrAnimEnd = _data[27];
		
		var uniAmo  = _data[30];
		var uniAut  = _data[31];
		var uniRot  = _data[32];
		var posWig  = _data[33];
		var uniSca  = _data[34];
		var cirRng  = _data[35];
		var posShf  = _data[36];
		var posExt  = _data[37];
		
		var _in_w, _in_h;
		
		var vSca = array_exists(useV, "Scale");
		var vRot = array_exists(useV, "Rotation");
		var vCol = array_exists(useV, "Color");
		
		var surfArray = is_array(_inSurf);
		if(surfArray && array_empty(_inSurf)) return;
		
		#region cache value
			ds_map_clear(surface_size_map);
			ds_map_clear(surface_valid_map);
			
			if(!surfArray) {
				surface_size_map[? _inSurf]  = surface_get_dimension(_inSurf);
				surface_valid_map[? _inSurf] = is_surface(_inSurf);
			} else {
				for( var i = 0, n = array_length(_inSurf); i < n; i++ ) {
					surface_size_map[? _inSurf[i]]  = surface_get_dimension(_inSurf[i]);
					surface_valid_map[? _inSurf[i]] = is_surface(_inSurf[i]);
				}
			}
			
			color.cache();
		#endregion
		
		#region data
			var _posDist = [];
			if(_dist == NODE_SCATTER_DIST.map) {
				if(!is_surface(_distMap))
					return _outSurf;
				
				// if(scatter_map != _distMap || scatter_maps != seed || scatter_mapa != _amount)
					scatter_mapp = get_points_from_dist(_distMap, _amount, seed);
				
				scatter_map  = _distMap;
				scatter_maps = seed;
				scatter_mapa = _amount;
				
				_posDist = scatter_mapp;
			}
			
			if(_dist == NODE_SCATTER_DIST.area) { // Area
				if(_scat == 0 && (!uniAut || _area[AREA_INDEX.shape] == AREA_SHAPE.rectangle)) 
					_amount = uniAmo[0] * uniAmo[1];
			
			} else if(_dist == NODE_SCATTER_DIST.path) { // Path
				var path_valid    = path != noone && struct_has(path, "getPointRatio");
			
				if(!path_valid) return _outSurf;
			
				var _pathProgress = 0;
				var path_amount   = struct_has(path, "getLineCount")? path.getLineCount() : 1;
				var _pre_amount   = _amount;
				_amount *= path_amount;
			
				var path_line_index = 0;
			} else if(_dist == NODE_SCATTER_DIST.tile) {
				if(_scat == 0) _amount = uniAmo[0] * uniAmo[1];
			}
		
			var _sed     = seed;
			var _sct     = array_create(_amount);
			var _sct_len = 0;
			var _arrLen  = array_safe_length(_inSurf);
		
			random_set_seed(_sed);
			
			var _wigX = posWig[0] != 0 || posWig[1] != 0;
			var _wigY = posWig[2] != 0 || posWig[3] != 0;
			
			var _scaUniX = _scale[0] == _scale[1];
			var _scaUniY = _scale[2] == _scale[3];
			
			var _alpUni = alpha[0] == alpha[1];
			
			var _clrUni = !inputs[| 11].attributes.mapped && color.keyLength == 1;
			var _clrSin = color.evalFast(0);
			
			var _useAtl = outputs[| 1].visible;
			
			var _datLen = array_length(scatter_data);
			
			var _p = [ 0, 0 ];
		#endregion
		
		surface_set_target(_outSurf);
			gpu_set_tex_filter(attributes.interpolate);
			
			DRAW_CLEAR
			switch(blend) {
				case 0 :
					if(mulpA) BLEND_ALPHA_MULP;
					else      BLEND_ALPHA;
					break;
					
				case 1 : BLEND_ADD; break;
				case 2 : gpu_set_blendmode(bm_max); break;
			}
			
			var positions = array_create(_amount);
			var posIndex  = 0;
			
			for(var i = 0; i < _amount; i++) {
				var sp = noone, _x = 0, _y = 0;
				var _v = noone;
				
				var _scx = _scaUniX? _scale[0] : random_range(_scale[0], _scale[1]);
				var _scy = _scaUniY? _scale[2] : random_range(_scale[2], _scale[3]); 
				
				switch(_dist) { #region position
					case NODE_SCATTER_DIST.area : 
						if(_scat == 0) {
							var _axc = _area[AREA_INDEX.center_x];
							var _ayc = _area[AREA_INDEX.center_y];
							var _aw  = _area[AREA_INDEX.half_w], _aw2 = _aw * 2;
							var _ah  = _area[AREA_INDEX.half_h], _ah2 = _ah * 2;
							var _ax0 = _axc - _aw, _ax1 = _axc + _aw;
							var _ay0 = _ayc - _ah, _ay1 = _ayc + _ah;
							
							var _acol = i % uniAmo[0];
							var _arow = floor(i / uniAmo[0]);
								
							if(_area[AREA_INDEX.shape] == AREA_SHAPE.rectangle) {
								_x = uniAmo[0] == 1? _axc : _ax0 + (_acol + 0.5) * _aw2 / ( uniAmo[0] );
								_y = uniAmo[1] == 1? _ayc : _ay0 + (_arow + 0.5) * _ah2 / ( uniAmo[1] );
								
							} else if(_area[AREA_INDEX.shape] == AREA_SHAPE.elipse) {
								if(uniAut) {
									sp = area_get_random_point(_area, _dist, _scat, i, _amount);
									_x = sp[0];
									_y = sp[1];
								} else {
									var _ang = cirRng[0] + _acol * (cirRng[1] - cirRng[0]) / uniAmo[0];
									var _rad = uniAmo[1] == 1? 0.5 : _arow / (uniAmo[1] - 1);
									_ang += _arow * uniRot;
									
									_x += _axc + lengthdir_x(_rad * _aw, _ang);
									_y += _ayc + lengthdir_y(_rad * _ah, _ang);
									
									_scx += _arow * uniSca[0];
									_scy += _arow * uniSca[1];
								}
							}
						} else {
							sp = area_get_random_point(_area, _dist, _scat, i, _amount);
							_x = sp[0];
							_y = sp[1];
						}
						break;
						
					case NODE_SCATTER_DIST.border : 
						sp = area_get_random_point(_area, _dist, _scat, i, _amount);
						_x = sp[0];
						_y = sp[1];
						break;
						
					case NODE_SCATTER_DIST.map : 
						sp = array_safe_get_fast(_posDist, i);
						if(!is_array(sp)) continue;
					
						_x = _area[0] + _area[2] * (sp[0] * 2 - 1.);
						_y = _area[1] + _area[3] * (sp[1] * 2 - 1.);
						break;
						
					case NODE_SCATTER_DIST.data : 
						sp = array_safe_get_fast(_distData, i);
						if(!is_array(sp)) continue;
					
						_x = array_safe_get_fast(sp, 0);
						_y = array_safe_get_fast(sp, 1);
						_v = array_safe_get_fast(sp, 2, noone);
						break;
						
					case NODE_SCATTER_DIST.path : 
						_pathProgress = _scat? random(1) : i / max(1, _pre_amount);
						_pathProgress = frac((_pathProgress + pathShf) * 0.9999);
					
						var pp = path.getPointRatio(_pathProgress, path_line_index);
						_x = pp.x + random_range(-pathDis, pathDis);
						_y = pp.y + random_range(-pathDis, pathDis);
						break;
						
					case NODE_SCATTER_DIST.tile : 
						if(_scat == 0) {
							var _acol = i % uniAmo[0];
							var _arow = floor(i / uniAmo[0]);
								
							_x = uniAmo[0] == 1? _dim[0] / 2 : (_acol + 0.5) * _dim[0] / ( uniAmo[0] );
							_y = uniAmo[1] == 1? _dim[1] / 2 : (_arow + 0.5) * _dim[1] / ( uniAmo[1] );
								
						} else if(_scat == 1) {
							_x = random_range(0, _dim[0]);
							_y = random_range(0, _dim[1]);
						}
						break;
						
				} #endregion
				
				if(_wigX) _x += random_range(posWig[0], posWig[1]);
				if(_wigY) _y += random_range(posWig[2], posWig[3]);
				
				_x += posShf[0] * i;
				_y += posShf[1] * i;
				
				if(_unis) {
					_scy = max(_scx, _scy);
					_scx = _scy;
				}
				
				if(vSca && _v != noone) {
					_scx *= _v;
					_scy *= _v;
				}
				
				var _r = (_pint? point_direction(_area[0], _area[1], _x, _y) : 0) + angle_random_eval_fast(_rota);
				
				if(vRot && _v != noone)
					_r *= _v;
					
				if(_dist == NODE_SCATTER_DIST.path && pathRot) {
					var p0 = path.getPointRatio(clamp(_pathProgress - 0.001, 0, 0.9999), path_line_index);
					var p1 = path.getPointRatio(clamp(_pathProgress + 0.001, 0, 0.9999), path_line_index);
					
					var dirr = point_direction(p0.x, p0.y, p1.x, p1.y);
					_r += dirr;
				}
				
				var surf = _inSurf;
				var ind  = 0;
				
				if(surfArray) { #region
					switch(_arr) { 
						case 1 : ind  = safe_mod(i, _arrLen);		 break;
						case 2 : ind  = irandom(_arrLen - 1);		 break;
						case 3 : ind  = array_safe_get_fast(arrId, i, 0); break;
						case 4 : if(useArrTex) ind = colorBrightness(surface_get_pixel(arrTex, _x, _y)) * (_arrLen - 1); break;
					}
					
					if(arrAnim[0] != 0 || arrAnim[1] != 0) {
						var _arrAnim_spd = random_range(arrAnim[0], arrAnim[1]);
						var _arrAnim_shf = random(_arrLen);
						var _animInd     = ind + _arrAnim_shf + CURRENT_FRAME * _arrAnim_spd;
						
						switch(arrAnimEnd) {
							case 0 : 
								ind = safe_mod(_animInd, _arrLen); 
								break;
								
							case 1 :
								var pp = safe_mod(_animInd, _arrLen * 2 - 1);
								ind = pp < _arrLen? pp : _arrLen * 2 - pp;
								break;
						}
					}
					
					surf = array_safe_get_fast(_inSurf, ind, 0); 
				} #endregion
				
				if(surf == 0 || !surface_valid_map[? surf]) continue;
				
				var dim = surface_size_map[? surf];
				var sw  = dim[0];
				var sh  = dim[1];
				
				if(_r == 0) {
					_x -= sw * _scx / 2;
					_y -= sh * _scy / 2;
				} else {
					_p = point_rotate(_x - sw / 2 * _scx, _y - sh * _scy / 2, _x, _y, _r, _p);
					_x = _p[0];
					_y = _p[1];
				}
				
				var grSamp = random(1);
				if(vCol && _v != noone)
					grSamp *= _v;
				
				var clr  = _clrUni? _clrSin  : evaluate_gradient_map(grSamp, color, clr_map, clr_rng, inputs[| 11], true); 
				var alp  = _alpUni? alpha[0] : random_range(alpha[0], alpha[1]);
				var _atl = _sct_len >= _datLen? noone : scatter_data[_sct_len];
				
				if(posExt) {
					_x = round(_x);
					_y = round(_y);
				}
				
				if(_useAtl) {
					if(!is_instanceof(_atl, SurfaceAtlasFast))  _atl = new SurfaceAtlasFast(surf, _x, _y, _r, _scx, _scy, clr, alp);
					else										_atl.set(surf, _x, _y, _r, _scx, _scy, clr, alp);
					
					_atl.w = sw;
					_atl.h = sh;
				} else {
					if(_atl == noone) _atl = {};
					
					_atl.surface  = surf ;
					_atl.x        = _x   ;
					_atl.y        = _y   ;
					_atl.rotation = _r   ;
					_atl.sx       = _scx ;
					_atl.sy       = _scy ;
					_atl.blend    = clr  ;
					_atl.alpha    = alp  ;
					_atl.w        = sw   ;
					_atl.h        = sh   ;
				}
				
				_sct[_sct_len] = _atl;
				_sct_len++;
				
				if(_dist == NODE_SCATTER_DIST.path)
					path_line_index = floor(i / _pre_amount);
			}
			
			array_resize(_sct, _sct_len);
			if(sortY) array_sort(_sct, function(a1, a2) { return a1.y - a2.y; });
			
			for( var i = 0; i < _sct_len; i++ ) {
				var _atl = _sct[i];
				
				surf = _atl.surface;
				_x   = _atl.x;
				_y	 = _atl.y;
				_scx = _atl.sx;
				_scy = _atl.sy;
				_r	 = _atl.rotation;
				clr	 = _atl.blend;
				alp	 = _atl.alpha;
				
				draw_surface_ext(surf, _x, _y, _scx, _scy, _r, clr, alp);
				
				if(_dist == NODE_SCATTER_DIST.tile) {
					var _sw = _atl.w * _scx;
					var _sh = _atl.h * _scy;
					
					if(_x < _sw)				draw_surface_ext(surf, _dim[0] + _x, _y, _scx, _scy, _r, clr, alp);
					if(_y < _sh)				draw_surface_ext(surf, _x, _dim[1] + _y, _scx, _scy, _r, clr, alp);
					if(_x < _sw && _y < _sh)	draw_surface_ext(surf, _dim[0] + _x, _dim[1] + _y, _scx, _scy, _r, clr, alp);
					
					if(_x > _dim[0] - _sw)							draw_surface_ext(surf, _x - _dim[0], _y, _scx, _scy, _r, clr, alp);
					if(_y > _dim[1] - _sh)							draw_surface_ext(surf, _x, _y - _dim[1], _scx, _scy, _r, clr, alp);
					if(_x > _dim[0] - _sw || _y > _dim[1] - _sh)	draw_surface_ext(surf, _x - _dim[0], _y - _dim[1], _scx, _scy, _r, clr, alp);
				}
			}
			
			BLEND_NORMAL
			gpu_set_tex_filter(false);
		surface_reset_target(); 
		
		scatter_data = _sct;
		
		return _outSurf;
	} #endregion
}
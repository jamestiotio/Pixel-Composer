#macro __vec3_forward new __vec3(1.0, 0.0, 0.0)
#macro __vec3_right   new __vec3(0.0, 1.0, 0.0)
#macro __vec3_up      new __vec3(0.0, 0.0, 1.0)

function __vec3(_x = 0, _y = _x, _z = _x) constructor {
	static set = function(_x = 0, _y = _x, _z = _x) {
		if(is_struct(_x) && is_instanceof(_x, __vec3)) {
			x = _x.x;
			y = _x.y;
			z = _x.z;
			return self;
		}
		
		if(is_struct(_x) && is_instanceof(_x, BBMOD_Vec3)) {
			x = _x.X;
			y = _x.Y;
			z = _x.Z;
			return self;
		}
		
		if(is_array(_x)) {
			x = _x[0];
			y = _x[1];
			z = _x[2];
			return self;
		}
		
		x = _x;
		y = _y;
		z = _z;
		return self;
	} set(_x, _y, _z);
	
	static isZero = function() {
		gml_pragma("forceinline");
		return x == 0 && y == 0 && z == 0;
	}
	
	static setIndex = function(index, value) {
		gml_pragma("forceinline");
		switch(index) {
			case 0 : x = value; break;
			case 1 : y = value; break;
			case 2 : z = value; break;
		}
		return self;
	}
	
	static getIndex = function(index) {
		switch(index) {
			case 0 : return x;
			case 1 : return y;
			case 2 : return z;
		}
		return 0;
	}

	static add = function(_vec3) {
		gml_pragma("forceinline");
		return new __vec3(x + _vec3.x, y + _vec3.y, z + _vec3.z);
	}

	static subtract = function(_vec3) {
		gml_pragma("forceinline");
		return new __vec3(x - _vec3.x, y - _vec3.y, z - _vec3.z);
	}

	static multiply = function(_scalar) {
		gml_pragma("forceinline");
		return new __vec3(x * _scalar, y * _scalar, z * _scalar);
	}

	static multiplyVec = function(_vec) {
		gml_pragma("forceinline");
		return new __vec3(x * _vec.x, y * _vec.y, z * _vec.z);
	}

	static divide = function(_scalar) {
		gml_pragma("forceinline");
		if (_scalar != 0)
			return new __vec3(x / _scalar, y / _scalar, z / _scalar);
		
		return new __vec3(x, y, z); // Avoid division by zero
	}

	static dot = function(_vec3) {
		gml_pragma("forceinline");
		return x * _vec3.x + y * _vec3.y + z * _vec3.z;
	}
	
	static cross = function(_vec3) {
		gml_pragma("forceinline");
	    var cross_x = y * _vec3.z - z * _vec3.y;
	    var cross_y = z * _vec3.x - x * _vec3.z;
	    var cross_z = x * _vec3.y - y * _vec3.x;
	    return new __vec3(cross_x, cross_y, cross_z);
	}

	// In-place computation functions
	static _add = function(_vec3) {
		gml_pragma("forceinline");
		x += _vec3.x;
		y += _vec3.y;
		z += _vec3.z;
		return self;
	}

	static _subtract = function(_vec3) {
		gml_pragma("forceinline");
		x -= _vec3.x;
		y -= _vec3.y;
		z -= _vec3.z;
		return self;
	}

	static _multiply = function(_scalar) {
		gml_pragma("forceinline");
		x *= _scalar;
		y *= _scalar;
		z *= _scalar;
		return self;
	}

	static _multiplyVec = function(_vec) {
		gml_pragma("forceinline");
		x *= _vec.x;
		y *= _vec.y;
		z *= _vec.z;
		return self;
	}

	static _divide = function(_scalar) {
		gml_pragma("forceinline");
		if (_scalar != 0) {
			x /= _scalar;
			y /= _scalar;
			z /= _scalar;
		}
		return self;
	}
	
	static distance = function(_vec3) {
		gml_pragma("forceinline");
		var dx = _vec3.x - x;
		var dy = _vec3.y - y;
		var dz = _vec3.z - z;
		return sqrt(dx * dx + dy * dy + dz * dz);
	}
	
	static length = function() {
		gml_pragma("forceinline");
		return sqrt(x * x + y * y + z * z);
	}

	static normalize = function() {
		gml_pragma("forceinline");
		return clone()._normalize();
	}
	
	static _normalize = function() {
		gml_pragma("forceinline");
		var _length = length();
		if (_length != 0) {
			x /= _length;
			y /= _length;
			z /= _length;
		}
		return self;
	}
	
	static _lerp = function(to, speed = 0.3) {
		gml_pragma("forceinline");
		x = lerp(x, to.x, speed);
		y = lerp(y, to.y, speed);
		z = lerp(z, to.z, speed);
	}
	
    static _lerp_float = function(to, speed = 5, pre = 0.01) {
        gml_pragma("forceinline");
        x = lerp_float(x, to.x, speed, pre);
        y = lerp_float(y, to.y, speed, pre);
        z = lerp_float(z, to.z, speed, pre);
    }

	static equal = function(to) {
		gml_pragma("forceinline");
		return x == to.x && y == to.y && z == to.z;
	}
	
	static minVal = function(vec) {
		gml_pragma("forceinline");
		return new __vec3(
			min(x, vec.x),
			min(y, vec.y),
			min(z, vec.z),
		);
	}
	
	static maxVal = function(vec) {
		gml_pragma("forceinline");
		return new __vec3(
			max(x, vec.x),
			max(y, vec.y),
			max(z, vec.z),
		);
	}
	
	static clone = function() {
		gml_pragma("forceinline");
		return new __vec3(x, y, z);
	}
	
	static toString = function() { return $"[{x}, {y}, {z}]"; }
	
	static toBBMOD = function() { return new BBMOD_Vec3(x, y, z); }
	
	static toArray = function() { return [ x, y, z ]; }
}
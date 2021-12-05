function Style() constructor {
	offset_x = 0
	offset_y = 0
	color = c_white
	font = f_text_default
	scale_x = 1
	scale_y = 1
	angle = 0
	alpha = 1
	line = -1
	
	static copy = function() {
		var result = new Style()
		result.offset_x = offset_x
		result.offset_y = offset_y
		result.color = color
		result.font = font
		result.scale_x = scale_x
		result.scale_y = scale_y
		result.angle = angle
		result.alpha = alpha
		result.line = line
		return result
	}
	
	static equals = function(compare) {
		if (compare.offset_x != offset_x) return false
		if (compare.offset_y != offset_y) return false
		if (compare.color != color) return false
		if (compare.font != font) return false
		if (compare.scale_x != scale_x) return false
		if (compare.scale_y != scale_y) return false
		if (compare.angle != angle) return false
		if (compare.alpha != alpha) return false
		if (compare.line != line) return false
		return true
	}
}

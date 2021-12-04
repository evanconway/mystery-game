/// @func Text(string)
function Text(_string) constructor {
	source_string = _string
	char_array = array_create(string_length(source_string))
	draw_set_font(f_text_default)
	for (var i = 0; i < array_length(char_array); i++) {
		var char = string_char_at(source_string, i + 1)
		char_array[i] = {
			character:	char,
			color:		c_white,
			font:		f_text_default,
			X:			0,
			Y:			0,
			scale_x:	1,
			scale_y:	1,
			angle:		0,
			alpha:		1,
			offset_x:	0,
			offset_y:	0,
			width:		string_width(char),
			height:		string_width(char),
			line:		0
		}
	}
	
	// determine char x/y position and line breaks
	line_heights = []
	var _x = 0;
	var _y = 0
	for (var i = 0; i < array_length(char_array); i++) {
		var c = char_array[i]
		c.X = _x
		c.Y = _y
		_x += c.width
	}
}

function text_draw(x, y, text) {
	with (text) {
		for (var i = 0; i < array_length(char_array); i++) {
			var c = char_array[i]
			draw_set_font(c.font)
			draw_set_color(c.color)
			draw_set_alpha(c.alpha)
			var _x = x + c.X + c.offset_x
			var _y = y + c.Y + c.offset_y
			draw_text_transformed(_x, _y, c.character, c.scale_x, c.scale_y, c.angle)
		}
	}
}

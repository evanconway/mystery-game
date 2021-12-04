/// @func Text(string, *width)
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
			height:		string_height(char),
			line:		-1
		}
	}
	
	max_width = argument_count >= 2 ? argument[1] : power(2, 32)
	
	// determine line breaks
	var word_width = 0
	var line_width = 0
	var line_index = 0
	var parsing_word_end = false
	for (var i = 0; i < array_length(char_array); i++) {
		var c = char_array[i]
		var char = c.character // for debug only
		
		if (c.character == " ") {
			// space discovered, beginning of the word end found
			word_width += c.width
			parsing_word_end = true
		} else if (parsing_word_end) {
			// not space, but we had found the end of the word? This is a new word! Determine line break
			if (line_width + word_width > max_width) {
				line_width = 0
				line_index++
			}
			var backup = i - 1
			while (backup >= 0 && char_array[backup].line == -1) {
				char_array[backup].line = line_index
				backup--
			}
			line_width += word_width
			word_width = c.width
			parsing_word_end = false
		} else {
			// we were not checking for end end, so this is just another letter in the word. 
			word_width += c.width
		}
	}
	
	// perform line break logic for last word
	if (line_width + word_width > max_width) {
		line_index++
	}
	var backup = array_length(char_array) - 1
	while (backup >= 0 && char_array[backup].line == -1) {
		char_array[backup].line = line_index
		backup--
	}
	
	// line heights
	line_heights = array_create(line_index + 1, -1)
	for (var i = 0; i < array_length(char_array); i++) {
		var c = char_array[i]
		if (c.height > line_heights[c.line]) line_heights[c.line] = c.height
	}
	
	// set x/y values
	var _curr_line = char_array[0].line // don't assume first line index is 0, first word could've been too big for first line
	var _x = 0
	var _y = 0
	for (var i = 0; i < array_length(char_array); i++) {
		var c = char_array[i]
		if (c.line != _curr_line) {
			_y += line_heights[_curr_line]
			_x = 0
			_curr_line = c.line
		}
		c.X = _x
		c.Y = _y
		_x += c.width
	}
	
	show_debug_message("text creation done")
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

/// @func Text(string, *width)
function Text(_string) constructor {
	if (!is_string(_string) || string_length(_string) <= 0) throw "Text Error: string must be of type string and length of 1 or greater."
	
	source_string = _string
	char_array = array_create(string_length(source_string))
	
	draw_set_font(f_text_default)
	for (var i = 0; i < array_length(char_array); i++) {
		var char = string_char_at(source_string, i + 1)
		char_array[i] = {
			character:	char,
			style:		new Style(),
			X:			0,
			Y:			0,
			width:		0,
			height:		0,
		}
	}
	
	max_width = argument_count >= 2 ? argument[1] : power(2, 32)
	
	line_heights = []
	
	static calculate_char_positions = function() {
		// determine char width/height and reset line
		for (var i = 0; i < array_length(char_array); i++) {
			var c = char_array[i]
			draw_set_font(c.style.font)
			c.width = c.style.scale_x * string_width(c.character)
			c.height = c.style.scale_y * string_height(c.character)
			c.style.line = -1
		}
		
		// note that line break information is stored style of characters for easier comparison
		var word_width = 0
		var line_width = 0
		var line_index = 0
		var parsing_word_end = false
		for (var i = 0; i < array_length(char_array); i++) {
			var c = char_array[i]
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
				while (backup >= 0 && char_array[backup].style.line == -1) {
					char_array[backup].style.line = line_index
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
		while (backup >= 0 && char_array[backup].style.line == -1) {
			char_array[backup].style.line = line_index
			backup--
		}
	
		// line heights
		line_heights = array_create(line_index + 1, -1)
		for (var i = 0; i < array_length(char_array); i++) {
			var c = char_array[i]
			if (c.height > line_heights[c.style.line]) line_heights[c.style.line] = c.height
		}
		
		// set x/y values
		var _curr_line = char_array[0].style.line // don't assume first line index is 0, first word could've been too big for first line
		var _x = 0
		var _y = 0
		for (var i = 0; i < array_length(char_array); i++) {
			var c = char_array[i]
			if (c.style.line != _curr_line) {
				_y += line_heights[_curr_line]
				_x = 0
				_curr_line = c.style.line
			}
			c.X = _x
			c.Y = _y
			_x += c.width
		}
	}
	
	calculate_char_positions()
	
	linked_list = undefined
	
	static generate_linked_list = function() {
		linked_list = {
			text:			char_array[0].character,
			style:			char_array[0].style.copy(),
			previous:		undefined,
			next:			undefined,
			index_start:	0,	// index in char array
			index_end:		0	// index in char array, inclusive
		}
		var curr_link = linked_list
		for (var i = 1; i < array_length(char_array); i++) {
			var c = char_array[i]
			if (curr_link.style.equals(c.style)) {
				curr_link.text += c.character
				curr_link.index_end = i
			} else {
				var new_link = {
					text:			c.character,
					style:			c.style.copy(),
					previous:		curr_link,
					next:			undefined,
					index_start:	i,
					index_end:		0
				}
				curr_link.next = new_link
				curr_link = new_link
			}
		}
	}
	
	generate_linked_list()
	
	// base style setters (end index is inclusive)
	/*
	font
	scale_x 
	scale_y
	offset_x
	offset_y
	color
	angle 
	alpha
	*/
	
	// end_index is inclusive
	static set_base_font = function(start_index, end_index, font) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.font = font
		}
		calculate_char_positions()
		generate_linked_list()
	}
	
	static set_base_scale_x = function(start_index, end_index, scale_x) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.scale_x = scale_x
		}
		calculate_char_positions()
		generate_linked_list()
	}
	
	static set_base_scale_y = function(start_index, end_index, scale_y) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.scale_y = scale_y
		}
		calculate_char_positions()
		generate_linked_list()
	}
}

function text_draw(x, y, text) {
	with (text) {
		var curr_link = linked_list
		while (curr_link != undefined) {
			var style = curr_link.style
			draw_set_font(style.font)
			draw_set_color(style.color)
			draw_set_alpha(style.alpha)
			var _x = x + char_array[curr_link.index_start].X + style.offset_x
			var _y = y + char_array[curr_link.index_start].Y + style.offset_y
			draw_text_transformed(_x, _y, curr_link.text, style.scale_x, style.scale_y, style.angle)
			curr_link = curr_link.next
		}
	}
}

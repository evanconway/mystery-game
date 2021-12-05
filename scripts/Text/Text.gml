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
			x:			0,
			y:			0,
			width:		string_width(char),
			height:		string_height(char),
		}
	}
	
	max_width = argument_count >= 2 ? argument[1] : power(2, 32)
	
	// determine line breaks
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
		c.x = _x
		c.y = _y
		_x += c.width
	}
	
	// generate linked list
	linked_list = {
		text:			char_array[0].character,
		style:			char_array[0].style.copy(),
		previous:		undefined,
		next:			undefined,
		index_start:	0,
		index_end:		0
	}
	var curr_link = linked_list
	var curr_line = char_array[0].style.line
	// at first, all characters will have same style, so only thing creating different links is line breaks
	for (var i = 1; i < array_length(char_array); i++) {
		var c = char_array[i]
		if (c.style.line == curr_line) {
			curr_link.text += c.character
		}
	}
}

function text_draw(x, y, text) {
	with (text) {
		for (var i = 0; i < array_length(char_array); i++) {
			var c = char_array[i]
			var s = c.style
			draw_set_font(s.font)
			draw_set_color(s.color)
			draw_set_alpha(s.alpha)
			var _x = x + c.x + s.offset_x
			var _y = y + c.y + s.offset_y
			draw_text_transformed(_x, _y, c.character, s.scale_x, s.scale_y, s.angle)
		}
	}
}

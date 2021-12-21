
/// @func Text(string, *width)
function Text(_string) constructor {
	if (!is_string(_string) || string_length(_string) <= 0) throw "Text Error: string must be of type string and length of 1 or greater."
	
	source_string = _string
	char_array = array_create(string_length(source_string))
	
	static get_length = function() {
		return array_length(char_array)
	}
	
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
			line_break:	false	// force line break to occur after this character
		}
	}
	
	static get_char_at = function(index) {
		return char_array[index].character
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
			if (c.character == " " && !c.line_break) {
				// space discovered, beginning of the word end found
				word_width += c.width
				parsing_word_end = true
			} else if (parsing_word_end || c.line_break) {
				// not space, but we had found the end of the word? This is a new word! Determine line break
				if (line_width + word_width > max_width) {
					line_width = 0
					line_index++
				}
				// assign line index to new word (which is chars with unassigned value -1)
				var backup = i - 1
				while (backup >= 0 && char_array[backup].style.line == -1) {
					char_array[backup].style.line = line_index
					backup--
				}
				line_width += word_width
				word_width = c.width
				parsing_word_end = false
				if (c.line_break) {
					line_index++
				}
			} else {
				// we were not checking for word end, so this is just another letter in the word. 
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
					next:			undefined,
					index_start:	i,
					index_end:		i
				}
				curr_link.next = new_link
				curr_link = new_link
			}
		}
	}
	
	generate_linked_list()
	
	// base style setters (end index is inclusive)
	// must call calculate_char_positions if changes char width or height
	// all bast setters must call generate linked list
	
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
	
	static set_line_break = function(index) {
		char_array[index].line_break = true
		calculate_char_positions()
		generate_linked_list()
	}
	
	static set_base_offset_x = function(start_index, end_index, offset_x) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.offset_x = offset_x
		}
		generate_linked_list()
	}
	
	static set_base_offset_y = function(start_index, end_index, offset_y) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.offset_y = offset_y
		}
		generate_linked_list()
	}
	
	static set_base_color = function(start_index, end_index, color) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.color = color
		}
		generate_linked_list()
	}
	
	static set_base_angle = function(start_index, end_index, angle) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.angle = angle
		}
		generate_linked_list()
	}
	
	static set_base_alpha = function(start_index, end_index, alpha) {
		for (var i = start_index; i <= end_index; i++) {
			char_array[i].style.alpha = alpha
		}
		generate_linked_list()
	}
	
	/*
	Both get cut functions when making a separation in the linked list will shorten
	the text in the link containing the given index create a new next link contain
	the remainder of that text. This helps prevent a bug where the second get cut
	call could modify the value returned by the first. 
	*/

	static get_start_cut_at_index = function(index) {
		var curs = linked_list
		var searching = true
		while (searching) {
			if (index >= curs.index_start && index <= curs.index_end) {
				searching = false
			} else {
				curs = curs.next
			}
		}
		if (curs.index_start == index) {
			return curs
		} else {
			/*
			before cut
			previous -> link -> next
							^
					contains start index
	
			after cut
			previous -> link -> new_link -> next
									^
					returned value (starts with given index)
			*/
			var char_index = index - curs.index_start + 1
			var left_cut_text = string_copy(curs.text, 1, char_index - 1)
			var right_cut_text = string_copy(curs.text, char_index, curs.index_end - index + 1)
			var new_link = {
				text:			right_cut_text,
				style:			curs.style.copy(),
				next:			curs.next,
				index_start:	index,
				index_end:		curs.index_end
			}
			curs.next = new_link
			curs.text = left_cut_text
			curs.index_end = index - 1
			return new_link
		}
	}

	static get_end_cut_at_index = function(index) {
		var curs = linked_list
		var searching = true
		while (searching) {
			if (index >= curs.index_start && index <= curs.index_end) {
				searching = false
			} else {
				curs = curs.next
			}
		}
		if (curs.index_end == index) {
			return curs
		} else {
			/*
			before cut
			previous -> link -> next
						  ^
				 contains end index
	
			after cut
			previous -> link -> new_link -> next
						  ^
			  returned value (ends with given index)
			*/
			var char_index = index - curs.index_start + 1
			var left_cut_text = string_copy(curs.text, 1, char_index)
			var right_cut_text = string_copy(curs.text, char_index + 1, curs.index_end - index)
			var new_link = {
				text:			right_cut_text,
				style:			curs.style.copy(),
				next:			curs.next,
				index_start:	index + 1,
				index_end:		curs.index_end
			}
			curs.next = new_link
			curs.text = left_cut_text
			curs.index_end = index
			return curs
		}
	}
	
	// temporary style modifiers (end index is inclusive)
	// these are not setters because the value is adjusted by the given amout, and it is reverted after each draw
	// (except color and font, these can only be set)
	/*
	angle = 0
	alpha = 1
	*/
	
	static mod_offset_x = function(start_index, end_index, offset_x) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.offset_x += offset_x
			curs = curs.next
		}
		curs.style.offset_x = +offset_x
	}
	
	static mod_offset_y = function(start_index, end_index, offset_y) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.offset_y += offset_y
			curs = curs.next
		}
		curs.style.offset_y += offset_y
	}
	
	static mod_color = function(start_index, end_index, color) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.color = color
			curs = curs.next
		}
		curs.style.color = color
	}
	
	static mod_font = function(start_index, end_index, font) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.font = font
			curs = curs.next
		}
		curs.style.font = font
	}
	
	static mod_scale_x = function(start_index, end_index, scale_x) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.scale_x *= scale_x
			curs = curs.next
		}
		curs.style.scale_x *= scale_x
	}
	
	static mod_scale_y = function(start_index, end_index, scale_y) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.scale_y = scale_y
			curs = curs.next
		}
		curs.style.scale_y += scale_y
	}
	
	static mod_angle = function(start_index, end_index, angle) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.angle += angle
			curs = curs.next
		}
		curs.style.angle += angle
	}
	
	static mod_alpha = function(start_index, end_index, alpha) {
		var curs = get_start_cut_at_index(start_index)
		var stop = get_end_cut_at_index(end_index)
		while (curs != stop) {
			curs.style.alpha *= alpha
			curs = curs.next
		}
		curs.style.alpha *= alpha
	}
	
	static link_can_merge_next = function(link) {
		// "link" is link in linked_list
		if (link.next == undefined) return false
		return link.style.equals(link.next.style)
	}
	
	static merge_link_with_next = function(link) {
		var next = link.next
		link.text += next.text
		link.index_end = next.index_end
		link.next = next.next
	}
	
	static draw_link = function(x, y, link) {
		var style = link.style
		draw_set_font(style.font)
		draw_set_color(style.color)
		draw_set_alpha(style.alpha)
		var _x = x + char_array[link.index_start].X + style.offset_x
		var _y = y + char_array[link.index_start].Y + style.offset_y
		draw_text_transformed(_x, _y, link.text, style.scale_x, style.scale_y, style.angle)
	}
	
	static draw = function(x, y) {
		var curr_link = linked_list
		while (curr_link != undefined) {
			if (link_can_merge_next(curr_link)) {
				merge_link_with_next(curr_link)
			} else {
				draw_link(x, y, curr_link)
				curr_link.style = char_array[curr_link.index_start].style.copy() // resets styles
				curr_link = curr_link.next
			}
		}
	}
}

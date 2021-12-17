global.text_random_arr = array_create(power(2, 16))
for (var i = 0; i < array_length(global.text_random_arr); i++) {
	global.text_random_arr[i] = random(1)
}

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
	
	/*
	Effects!
	All effects need at least a start_index, and end_index, an update_count, and an update_increment.
	The indexes are self explanatory. It's expected that update count will be incremented each frame.
	The update_increment is the percentage of the cycle each increase in the update count will trigger.
	For example, if the update increment is 0.1, it will take 10 increments to update_count to perform
	a full cycle of any given effect. The definition of a cycle varies from effect to effect.
	*/
	
	// utility functions
	
	/*
	Given a magnitude and index in the random array, returns -magnitude, magnitude, or 0 depending on 
	value in char array. If magnitude is 0, returns 0 or 1. Given index can be greater than length
	of random array and will account for wrap around.
	*/
	static get_rand_offset = function(index, magnitude, allow_zero) {
		var result = 0
		var rand = global.text_random_arr[index % array_length(global.text_random_arr)]
		if (magnitude <= 0) {
			if (allow_zero) result = rand < 0.5 ? 0 : 1
			else result = 1
		} else if (allow_zero) {
			if (rand < 0.33) result = magnitude * -1
			else if (rand < 0.66) result = 0
			else result = magnitude
		} else {
			if (rand < 0.5) result = magnitude * -1
			else result = magnitude
		}
		return result
	}
	
	
	static fx_hover = function(start_index, end_index, update_count, update_increment, magnitude) {
		var mod_y = sin(update_count * update_increment * 2 * pi + pi * 0.5) * magnitude * -1 // recall y is reversed
		mod_offset_y(start_index, end_index, mod_y)
	}
	
	static fx_fade = function(start_index, end_index, update_count, update_increment, alpha_max, alpha_min) {
		// triangle function (looks better than sin IMO)
		var m = (update_count * update_increment * 2 + 1) % 2
		m = m <= 1 ? m : 2 - m
		m = (alpha_max - alpha_min) * m + alpha_min
		mod_alpha(start_index, end_index, m)
	}
	
	/*
	Each character will be in its own position in the sin wave. Increment separator is the distance 
	along the sin wave between each character.
	*/
	static fx_wave = function(start_index, end_index, update_count, update_increment, magnitude, increment_separator) {
		for (var i = start_index; i <= end_index; i++) {
			var inc_mod = (i - start_index) * increment_separator * 2 * pi
			var mod_y = sin(update_count * update_increment * 2 * pi + pi * 0.5 - inc_mod) * magnitude * -1 // recall y is reversed
			mod_offset_y(i, i, mod_y)
		}
	}
	
	static fx_shake = function(start_index, end_index, update_count, update_increment, magnitude) {
		var arr_offset = power(2, 10)
		for (var i = 0; i < end_index - start_index; i++) {
			var arr_index = floor(update_count * update_increment) + i * arr_offset
			var m_x = get_rand_offset(arr_index, magnitude)
			var m_y = get_rand_offset(arr_index + array_length(global.text_random_arr) / 2, magnitude)
			mod_offset_x(start_index + i, start_index + i, m_x, true)
			mod_offset_y(start_index + i, start_index + i, m_y, true)
		}
	}
	
	static fx_twitch = function(start_index, end_index, update_count, update_increment, magnitude, probability, time, num_of_twitches) {
		var rand_arr = global.text_random_arr
		var arr_length = array_length(rand_arr)
		var update_index = floor(update_count * update_increment)
		var under_time = ((update_increment * update_count) % 1) < time
		var offset = power(2, 10)
		for (var i = 0; i < num_of_twitches; i++) {
			var perform_twitch = rand_arr[(update_index + offset * i) % arr_length] < probability
			if (under_time && perform_twitch) {
				var quarter = floor(arr_length / 4)
				var twitched_index = floor(rand_arr[(update_index + quarter + offset * i) % arr_length] * (end_index - start_index + 1) + start_index)
				var offset_x = get_rand_offset((update_index + offset * i + quarter * 2) % arr_length, magnitude)
				var offset_y = get_rand_offset((update_index + offset * i + arr_length / 2 + quarter * 3) % arr_length, magnitude)
				mod_offset_x(twitched_index, twitched_index, offset_x, false)
				mod_offset_y(twitched_index, twitched_index, offset_y, false)
			}
		}
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

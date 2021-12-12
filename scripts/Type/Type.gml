function Type(_text) constructor {
	text = _text
	
	linked_list = {
		index_start:	0,
		index_end:		text.get_length() - 1,	// inclusive
		alpha:			0,						// chars start invisible
		next:			undefined
	}
	
	// only alphas of 1 or 0 can be used
	static set_char_alpha = function(index, new_alpha) {
		if (new_alpha != 0 && new_alpha != 1) throw "Typer Error: new_alpha must be 0 or 1"
		
		var searching = true
		var curs = linked_list
		var prev = undefined // link behind curs
		while (searching) {
			if (curs.index_start <= index && curs.index_end >= index) {
				searching = false
			} else {
				prev = curs
				curs = curs.next
			}
		}
		if (curs.alpha == new_alpha) {
			return
		}
		
		if (curs.index_start == curs.index_end) {
			curs.alpha = new_alpha
			if (curs.next != undefined) {
				curs.index_end = curs.next.index_end
				curs.next = curs.next.next
			}
			if (prev != undefined) {
				prev.index_end = curs.index_end
				prev.next = curs.next
			}
		} else if (curs.index_start != index && curs.index_end != index) {
			var next_link = {
				index_start:	index + 1,
				index_end:		curs.index_end,
				alpha:			curs.alpha,
				next:			curs.next
			}
			var index_link = {
				index_start:	index,
				index_end:		index,
				alpha:			new_alpha,
				next:			next_link
			}
			curs.next = index_link
			curs.index_end = index - 1
		} else if (curs.index_start == index) {
			/*
			If the prev is undefined, we're at the head of the linked list, and need
			to create a new link as the head. Otherwise we just change start/end indexes
			of prev and curs
			*/
			if (prev == undefined) {
				linked_list = {
					index_start:	index,
					index_end:		index,
					alpha:			new_alpha,
					next:			curs
				}
			} else {
				prev.index_end += 1
			}
			curs.index_start += 1
		} else if (curs.index_end == index) {
			/*
			If next is undefined, we're at the end of the list and need to make a new link.
			Otherwise just change values of curs and next.
			*/
			if (curs.next == undefined) {
				curs.next = {
					index_start:	index,
					index_end:		index,
					alpha:			new_alpha,
					next:			undefined
				}
			} else {
				curs.next.index_start -= 1
			}
			curs.index_end -= 1
		}
	}
	
	// order char indexes are typed in
	char_order = array_create(text.get_length(), 0)
	
	static set_order_forward = function() {
		for (var i = 0; i < array_length(char_order); i++) {
			char_order[i] = i
		}
	}
	
	static set_order_backward = function() {
		for (var i = 0; i < array_length(char_order); i++) {
			char_order[i] = array_length(char_order) - 1 - i
		}
	}
	
	static set_order_random = function() {
		var list = ds_list_create()
		for (var i = 0; i < array_length(char_order); i++) {
			ds_list_add(list, i)
		}
		ds_list_shuffle(list)
		for (var i = 0; i < array_length(char_order); i++) {
			char_order[i] = ds_list_find_value(list, i)
		}
	}
	
	set_order_forward()
	
	index_to_type = 0
	
	static get_char_to_type = function() {
		if (index_to_type >= array_length(char_order)) {
			return undefined
		}
		return text.get_char_at(char_order[index_to_type])
	}
	
	static type_char = function() {
		audio_play_sound(Sound1, 1, false)
		set_char_alpha(char_order[index_to_type], 1)
		index_to_type += 1
	}
	
	/*
	Note that the effects applied to the text are not permenant. You must call the update every
	frame you draw the text or the text will appear as normal.
	*/
	update_value = 0
	char_value = 0
	punctuation_timing = true
	static update = function(increment, num_of_chars) {
		if (increment <= 0) {
			num_of_chars = 0
		}
		update_value += increment
		char_value += num_of_chars
		if (update_value >= 1 && index_to_type < array_length(char_order)) {
			for (var i = 0; i < floor(char_value) && index_to_type < array_length(char_order); i++) {
				var char = get_char_to_type()
				while (char == " " && index_to_type < array_length(char_order)) {
					type_char()
					char = get_char_to_type()
				}
				char = get_char_to_type()
				if (punctuation_timing) {
					if (get_char_to_type() == "." || get_char_to_type() == "!" || get_char_to_type() == "?") {
						update_value = -3
						i = char_value
					} if (get_char_to_type() == "," || get_char_to_type() == ";" || get_char_to_type() == ":") {
						update_value = -1
						i = char_value
					}
				}
				if (index_to_type < array_length(char_order)) {
					type_char()
				}
			}
			if (update_value > 0) update_value = update_value % 1
		}
		
		char_value = char_value % 1
		
		var curs = linked_list
		while (curs != undefined) {
			text.mod_alpha(curs.index_start, curs.index_end, curs.alpha)
			curs = curs.next
		}
	}
}

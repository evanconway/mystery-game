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
	
	char_data = ds_map_create()
	for (var i = 0; i < text.get_length(); i++) {
		ds_map_add(char_data, i, {
			alpha:	0,
			entry:	[]
		})
	}
	
	type_random = function(num_of_chars) {
		
	}
	
	last_typed_char = -1
	type_forward = function(num_of_chars) {
		if (last_typed_char >= ds_map_size(char_data) - 1) {
			return
		}
		for (var i = 0; i < num_of_chars; i++) {
			last_typed_char += 1
			set_char_alpha(last_typed_char, 1)
		}
	}
	
	type_chars = type_forward
	
	update_value = 0
	static update = function(increment, num_of_chars) {
		update_value += increment
		if (update_value >= 1) {
			type_chars(num_of_chars)
			update_value = 0
		}
		
		var curs = linked_list
		while (curs != undefined) {
			text.mod_alpha(curs.index_start, curs.index_end, curs.alpha)
			curs = curs.next
		}
	}
}

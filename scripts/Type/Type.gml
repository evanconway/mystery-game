

function Type(_text) constructor {
	text = _text
	
	linked_list = undefined
	
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
	
	char_effects = ds_map_create()
	for (var i = 0; i < array_length(char_order); i++) {
		ds_map_add(char_effects, i, {
			entry:	[],
			leave:	[]
		})
	}
	
	/* 
	format of all entry effects:
	{
		done:	boolean		// starts false
		index:	int			// character index
		text:	text		// reference to text struct
		update:	function	// must set done to true when finished
		reset:	function	// reset all custom values, and set done to false
	}
	can contain other variables as needed
	*/
	
	effects_entry = []
	effects_leave = []
	
	static add_entry_effect = function(index, effect) {
		array_push(ds_map_find_value(char_effects, index).entry, effect)
	}
	
	static add_leave_effect = function(index, effect) {
		array_push(ds_map_find_value(char_effects, index).leave, effect)
	}
	
	for (var i = 0; i < array_length(char_order); i++) {
		add_entry_effect(i, {
			done:	false,
			index:	i,
			alpha:	0,
			text:	text,
			update:	function() {
				text.mod_alpha(index, index, alpha)
				alpha += 3/60
				if (alpha >= 1) done = true
			},
			reset:	function() {
				done = false
				alpha = 0
			}
		})
		add_entry_effect(i, {
			done:	false,
			index:	i,
			mod_y:	-10,
			text:	text,
			update:	function() {
				text.mod_offset_y(index, index, mod_y)
				mod_y *= 0.7
				if (abs(mod_y) <= 0.3) done = true
			},
			reset:	function() {
				done = false
				mod_y = -10
			}
		})
	}
	
	static type_char = function() {
		var char_index = char_order[index_to_type]
		set_char_alpha(char_index, 1)
		if (get_char_to_type() != " ") {
			var entry_arr = ds_map_find_value(char_effects, char_index).entry
			for (var i = 0; i < array_length(entry_arr); i++) {
				entry_arr[i].reset()
				array_push(effects_entry, {
					index_char:		char_index,
					index_effect:	i
				})
			}
		}
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
		if (update_value >= 1 && index_to_type < array_length(char_order)) {
			char_value += num_of_chars
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
			if (update_value > 0) update_value = 0 // update is reset instead of % 1 to solve bug
			audio_play_sound(Sound1, 1, false)
		}
		
		char_value = char_value % 1
		
		var curs = linked_list
		while (curs != undefined) {
			text.mod_alpha(curs.index_start, curs.index_end, curs.alpha)
			curs = curs.next
		}
		
		// udpdate entry effects
		for (var i = 0; i < array_length(effects_entry); i++) {
			var index_char = effects_entry[i].index_char
			var index_effect = effects_entry[i].index_effect
			var effect = ds_map_find_value(char_effects, index_char).entry[index_effect]
			effect.update()
			if (effect.done) {
				array_delete(effects_entry, i, 1)
				i -= 1
			}
		}
		
		// update leave effects
		// will add later
	}
	
	static typing_is_finished = function() {
		return index_to_type >= array_length(char_order)
	}
	
	static set_finished = function() {
		linked_list = {
			index_start:	0,
			index_end:		text.get_length() - 1,	// inclusive
			alpha:			1,						// chars start invisible
			next:			undefined
		}
		index_to_type = text.get_length()
		update_value = 0
		char_value = 0
	}
	
	static reset = function() {
		linked_list = {
			index_start:	0,
			index_end:		text.get_length() - 1,	// inclusive
			alpha:			0,						// chars start invisible
			next:			undefined
		}
		index_to_type = 0
		update_value = 0
		char_value = 0
	}
	
	reset()
}

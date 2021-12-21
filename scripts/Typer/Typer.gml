function Typer(_text) constructor {
	text = _text // a Text struct
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
	
	char_data = array_create(text.get_length(), undefined)
	for (var i = 0; i < array_length(char_order); i++) {
		char_data[i] = {
			entry:	[],
			leave:	[],
			type_data:	{
				increment:	0.15,
				num_chars:	3.3,
				pause:		3,
				stop:		5
			}
		}
	}
	
	/* 
	format of all entry effects:
	{
		done:		boolean		// starts false
		index:		int			// character index
		text:		text		// reference to text struct
		progress:	number		// starts 0, effects is complete when this reaches 1
		apply:		function	// modifys the text object based on progress and effect
		update:		function	// increases progress, must set done to true when finished
	}
	can contain other variables as needed
	*/
	
	effects_entry = [] // we should rename this to something like active entry effect references
	effects_leave = [] // same
	
	static add_entry_effect = function(index, effect) {
		array_push(char_data[index].entry, effect)
	}
	
	static add_leave_effect = function(index, effect) {
		array_push(char_data[index].leave, effect)
	}
	
	// default rise and fade in effect
	for (var i = 0; i < array_length(char_order); i++) {
		add_entry_effect(i, {
			done:		false,
			index:		i,
			progress:	0,
			text:		text,
			update:	function(mult = 1) {
				progress += 4/60 * mult
				if (progress >= 1) {
					progress = 1
					done = true
				}
			},
			apply: function() {
				text.mod_alpha(index, index, progress)
			}
		})
		add_entry_effect(i, {
			done:		false,
			index:		i,
			mod_y:		-10,
			progress:	0,
			text:		text,
			update:		function(mult = 1) {
				progress += 0.1 * mult
				if (progress >= 1) {
					progress = 1
					done = true
				}
			},
			apply:	function() {
				// hand picked magic numbers!
				text.mod_offset_y(index, index, mod_y * (1 / (progress + 0.63) - 0.63))
			}
		})
	}
	
	static type_char = function() {
		var char_index = char_order[index_to_type]
		set_char_alpha(char_index, 1)
		if (get_char_to_type() != " ") {
			var entry_arr = char_data[char_index].entry
			for (var i = 0; i < array_length(entry_arr); i++) {
				
				// reset effect
				entry_arr[i].done = false
				entry_arr[i].progress = 0
				
				// add reference to active effects arr
				array_push(effects_entry, {
					index_char:		char_index,
					index_effect:	i
				})
			}
		}
		index_to_type += 1
	}
	
	static typing_is_finished = function() {
		return index_to_type >= array_length(char_order)
	}
	
	current_type_data = {
		increment:	0,
		num_chars:	0,
		pause:		0,
		stop:		0
	}
	
	static set_typing_data_to_index = function(index) {
		current_type_data.increment = char_data[index].type_data.increment
		current_type_data.num_chars = char_data[index].type_data.num_chars
		current_type_data.pause = char_data[index].type_data.pause
		current_type_data.stop = char_data[index].type_data.stop
	}
	
	static set_char_type_data = function(index, type_data) {
		char_data[index].type_data = type_data
	}
	
	static typing_data_index_equals_current = function(index) {
		var compare = char_data[index].type_data
		if (current_type_data.increment != compare.increment) return false
		if (current_type_data.num_chars != compare.num_chars) return false
		if (current_type_data.pause != compare.pause) return false
		if (current_type_data.stop != compare.stop) return false
		return true
	}
	
	/*
	Note that the effects applied to the text are not permenant. You must call the update every
	frame you draw the text or the text will appear as normal.
	*/
	update_value = 0	// keeps track of increment additions, start at 0 for instantaneous type at start
	char_value = 0		// keeps track of num_of_char additions (they could be non-integer)
	static update = function(mult = 1) {
		update_value -= current_type_data.increment * mult
		if (update_value <= 0 && !typing_is_finished()) {
			char_value += current_type_data.num_chars
			for (var i = 0; i < floor(char_value) && !typing_is_finished(); i++) {
				var char = get_char_to_type()
				/*
					Characters should be typed until i equals floor(char_value), but there are some exceptions.
					Firstly, all spaces are automatically typed. If new typing data is discovered, the typing will
					stop on that character, unless it's a space which we still always type all of. If the character
					is an end or pause mark, we'll stop on that as well.
				*/
				
				// handle spaces
				while (char == " " && !typing_is_finished()) {
					type_char()
					char = get_char_to_type()
				}
				
				if (!typing_is_finished()) {
					// handle type data changing
					if (!typing_data_index_equals_current(index_to_type)) {
						set_typing_data_to_index(index_to_type)
						i = char_value
					}
				
					// handle punctuation
					if (get_char_to_type() == "," || get_char_to_type() == ";" || get_char_to_type() == ":") {
						update_value = current_type_data.pause
						i = char_value
					}
					if (get_char_to_type() == "." || get_char_to_type() == "!" || get_char_to_type() == "?") {
						update_value = current_type_data.stop
						i = char_value
					}
					type_char()
				}
			}
			if (update_value <= 0) update_value = 1
			audio_play_sound(Sound1, 1, false)
		}
		
		char_value = char_value % 1
		
		// udpdate entry effects
		for (var i = 0; i < array_length(effects_entry); i++) {
			var index_char = effects_entry[i].index_char
			var index_effect = effects_entry[i].index_effect
			var effect = char_data[index_char].entry[index_effect]
			effect.update()
			if (effect.done) {
				array_delete(effects_entry, i, 1)
				i -= 1
			}
		}
		
		// update leave effects
		// will add later
	}
	
	static draw = function() {
		var curs = linked_list
		while (curs != undefined) {
			text.mod_alpha(curs.index_start, curs.index_end, curs.alpha)
			curs = curs.next
		}
		
		for (var i = 0; i < array_length(effects_entry); i++) {
			var index_char = effects_entry[i].index_char
			var index_effect = effects_entry[i].index_effect
			var effect = char_data[index_char].entry[index_effect]
			effect.apply()
		}
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
		effects_entry = []
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
		set_typing_data_to_index(index_to_type)
	}
	
	reset()
}

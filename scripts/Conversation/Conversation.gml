/// @func Conversation(lines, detect_start, detect_advance, select_next_option, select_previous_option)
function Conversation(line_array, start, advance, next, previous) constructor {
	detect_start = start
	detect_advance = advance
	next_option = next
	previous_option = previous
	active = false
	selected_option = 0
	
	/* 
	line of dialog
	{
		label: string,
		body: string,
		goto: string || goto{}
		close: boolean				conversation ends if true
	}
	
	goto struct
	{
		display: string		the displayed name for next line
		label:				label of next line
	}
	*/
	
	// ensure each line of dialog has a label
	for (var i = 0; i < array_length(line_array); i++) {
		if (!variable_struct_exists(line_array[i], "label")) line_array[i].label = string(i)
	}
	
	// label of current line of dialog, used to access lines (map)
	current = line_array[0].label
	
	// Ensure all lines have valid goto value. Goto is always an array of structs.
	for (var i = 0; i < array_length(line_array) - 1; i++) {
		if (!variable_struct_exists(line_array[i], "goto")) line_array[i].goto = [{ label: line_array[i + 1].label }]
		if (typeof(line_array[i].goto) == "string") line_array[i].goto = [{ label: line_array[i].goto }]
	}
	// final line loops to first by default 
	var final_index = array_length(line_array) - 1
	if (!variable_struct_exists(line_array[final_index], "goto")) line_array[final_index].goto = [{ label: line_array[0].label }]
	if (typeof(line_array[final_index].goto) == "string") line_array[final_index].goto = [{ label: line_array[final_index].goto }]
	
	lines = ds_map_create()
	for (var i = 0; i < array_length(line_array); i++) {
		ds_map_add(lines, line_array[i].label, line_array[i])
	}
	
	show_debug_message("line map creation complete")
}

function conversation_update(conversation) {
	with (conversation) {
		if (active) {
			// handle changing selected goto option
			var line_current = ds_map_find_value(lines, current)
			if (array_length(line_current.goto) > 1) {
				if (previous_option() && selected_option > 0) {
					selected_option -= 1
				}
				if (next_option() && selected_option < array_length(line_current.goto) - 1) {
					selected_option += 1
				}
			}
			if (detect_advance()) {
				if (variable_struct_exists(line_current, "close") && line_current.close) active = false
				current = ds_map_find_value(lines, line_current.goto[selected_option].label).label
				selected_option = 0
			}
		} else if (detect_start()) active = !active
		
	}
}

function conversation_draw(conversation) {
	with (conversation) {
		if (active) {
			var line = ds_map_find_value(lines, current)
			draw_text(0, 0, line.body)
			if (array_length(line.goto) > 1) {
				var Y = 12
				for (var i = 0; i < array_length(line.goto); i++) {
					var text = variable_struct_exists(line.goto[i], "display") ? line.goto[i].display : line.goto[i].label
					if (i == selected_option) text += " *"
					draw_text(0, Y, text)
					Y += 12
				}
			}
		}
	}
}

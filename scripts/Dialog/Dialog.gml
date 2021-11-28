
function Dialog() constructor{
	// "lines" means lines of dialog, or chunk of text to be displayed for each "state"
	// hard coded example for now
	var lines = [
		{
			body: "Hello! Welcome to the example dialog."
		},
		{
			body: "Do you prefer A or B?",
			options: [
				["A", "a"],
				["B", "b"]
			]
		},
		{
			label: "a",
			body: "You chose A!",
			next: "end"
		},
		{
			label: "b",
			body: "You chose B!",
			next: "end"
		},
		{
			label: "end",
			body: "goodbye",
		}
	]
	
	/*
	To make our data useable, we're going to move all the data from the array into
	a map. The first step to doing this is creating a label for each line if it
	does not already have one. 
	*/
	for (var i = 0; i < array_length(lines); i++) {
		if (!variable_struct_exists(lines[i], "label")) lines[i].label = string(i)
	}
	
	// the current line of dialog for this dialog state
	current = lines[0].label
	
	/*
	Next, we ensure all lines have a next value. If it does not, we assume the next
	line in the array is where the line of dialog should go. Note however that for
	lines with options, the next field is totally ignored by the conversation
	logic. Any line with a next value of undefined is considered an "ender". The final
	line of dialog will always have its next value assigned to undefined to ensure 
	correct logic.
	*/
	for (var i = 0; i < array_length(lines) - 1; i++) {
		if (!variable_struct_exists(lines[i], "next")) lines[i].next = lines[i + 1].label
	}
	lines[array_length(lines) - 1].next = undefined
	
	line_map = ds_map_create()
	
	for (var i = 0; i < array_length(lines); i++) {
		ds_map_add(line_map, lines[i].label, lines[i])
	}
	
	show_debug_message("line map creation complete")
}

function dialog_get_body() {
	return 
}
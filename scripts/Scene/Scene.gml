/* beat struct:
{
	label:			string,
	onEnter:		function(),
	update:			function(),
	draw:			function(),	// probably necessary
	readyToLeave:	function(),
	onLeave:		function(),
	goto:			string[]	// labels of other scene structs
	selectedGoto:	int,		// index in goto array
}
*/

function __scene_check_goto(beat, existing_labels) {
	if (!is_array(beat.goto)) throw "Scene Error: goto is not array"
	for (var g = 0; g < array_length(beat.goto); g++) {
		if (!is_string(beat.goto[g])) throw "Scene Error: entry in goto is not string"
		if (!ds_map_exists(existing_labels, beat.goto[g])) throw "Scene Error: no beat has label in goto"
	}
}

/// @func Scene(beats_array)
function Scene(beats_array, _detect_start) constructor {
	detect_start = _detect_start // function that returns true if scene should start
	active = false
	
	if (!is_array(beats_array)) throw "Scene Error: constructor did not receive an array"
	if (array_length(beats_array) <= 0) throw "Scene Error: beats_array must contain at least 1 element"
	
	// ensure each beat is a struct, and has valid label
	var labels = ds_map_create() // for keeping track of found labels, used to ensure gotos are correct
	for (var i = 0; i < array_length(beats_array); i++) {
		var beat = beats_array[i]
		if (!is_struct(beat)) throw "Scene Error: beat is not a struct"
		if (!variable_struct_exists(beat, "label")) beat.label = string(i)
		if (!is_string(beat.label)) throw "Scene Error: beat label is not a string"
		ds_map_add(labels, beat.label, undefined)
	}
	
	// label of current beat, used to access beat map
	current = beats_array[0].label
	
	// Ensure all beats (except last) have valid goto value: an array of labels.
	for (var i = 0; i < array_length(beats_array) - 1; i++) {
		var beat = beats_array[i]
		if (!variable_struct_exists(beat, "goto")) beat.goto = [ beats_array[i + 1].label ]
		else __scene_check_goto(beat, labels)
	}
	
	// Ensure final beat is valid, and that it loops to first beat by default.
	var final_index = array_length(beats_array) - 1
	if (!variable_struct_exists(beats_array[final_index], "goto")) beats_array[final_index].goto = [ beats_array[0].label ]
	else __scene_check_goto(beats_array[final_index], labels)
	ds_map_destroy(labels)
	
	// create beat map
	beats = ds_map_create()
	for (var i = 0; i < array_length(beats_array); i++) {
		ds_map_add(beats, beats_array[i].label, beats_array[i])
	}
	
	show_debug_message("line map creation complete")
}

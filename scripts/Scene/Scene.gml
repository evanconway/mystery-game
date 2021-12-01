/* beat struct:
{
	label:			string,
	on_start:		function(),
	update:			function(),
	draw:			function(),	// probably necessary
	ready_to_end:	function(),
	on_end:			function(),
	goto:			string[]	// labels of other scene structs
	selected_goto:	int,		// index in goto array
	end_scene:		boolean		// if true, scene ends when beat ends
}
*/

/// @func Scene(beats_array, detect_start)
function Scene(beats_array, _detect_start) constructor {
	detect_start = _detect_start // function that returns true if scene should start
	active = false
	
	var check_goto = function(beat, existing_labels) {
		if (!is_array(beat.goto)) throw "Scene Error: goto is not array"
		for (var g = 0; g < array_length(beat.goto); g++) {
			if (!is_string(beat.goto[g])) throw "Scene Error: entry in goto is not string"
			if (!ds_map_exists(existing_labels, beat.goto[g])) throw "Scene Error: no beat has label in goto"
		}
	}
	
	var err = "Scene Error: "
	
	if (!is_array(beats_array)) throw err +"constructor did not receive an array"
	if (array_length(beats_array) <= 0) throw err + "beats_array must contain at least 1 element"
	
	// ensure each beat is a struct, and has valid label
	var labels = ds_map_create() // for keeping track of found labels, used to ensure gotos are correct
	for (var i = 0; i < array_length(beats_array); i++) {
		var beat = beats_array[i]
		if (!is_struct(beat)) throw err + "beat is not a struct"
		if (!variable_struct_exists(beat, "label")) beat.label = string(i)
		if (!is_string(beat.label)) throw err + "beat label is not a string"
		ds_map_add(labels, beat.label, undefined)
	}
	
	// label of current beat, used to access beat map
	current = beats_array[0].label
	
	// Ensure all beats (except last) have valid goto value: an array of labels.
	for (var i = 0; i < array_length(beats_array) - 1; i++) {
		var beat = beats_array[i]
		if (!variable_struct_exists(beat, "goto")) beat.goto = [ beats_array[i + 1].label ]
		else check_goto(beat, labels)
	}
	
	// Ensure final beat is valid, and that it loops to first beat by default.
	var final_index = array_length(beats_array) - 1
	if (!variable_struct_exists(beats_array[final_index], "goto")) beats_array[final_index].goto = [ beats_array[0].label ]
	else check_goto(beats_array[final_index], labels)
	ds_map_destroy(labels)
	
	// finally, ensure supplied values for remaining beat fields are correct, or they have default values
	var do_nothing = function() {}
	for (var i = 0; i < array_length(beats_array); i++) {
		var beat = beats_array[i]
		if (!variable_struct_exists(beat, "on_start")) beat.on_start = do_nothing
		if (!variable_struct_exists(beat, "update")) beat.update = do_nothing
		if (!variable_struct_exists(beat, "draw")) beat.draw = do_nothing
		if (!variable_struct_exists(beat, "ready_to_end")) beat.ready_to_end = do_nothing
		if (!variable_struct_exists(beat, "on_end")) beat.on_end = do_nothing
		if (!variable_struct_exists(beat, "end_scene")) beat.end_scene = false
		
		beat.selected_goto = 0 // no reason to allow customizable selected_goto start value
		
		if (!is_method(beat.on_start)) throw err + "beat on_start must be method function"
		if (!is_method(beat.update)) throw err + "beat update must be method function"
		if (!is_method(beat.draw)) throw err + "beat draw must be method function"
		if (!is_method(beat.ready_to_end)) throw err + "beat ready_to_end must be method function"
		if (!is_method(beat.on_end)) throw err + "beat on_end must be method function"
		
		// in YYC, and HTML I think, booleans are still considered numbers :(
		if (!is_bool(beat.end_scene) && !is_numeric(beat.end_scene)) throw err + "beat end_scene must be boolean"
	}
	
	// create beat map
	beats = ds_map_create()
	for (var i = 0; i < array_length(beats_array); i++) {
		ds_map_add(beats, beats_array[i].label, beats_array[i])
	}
}

function scene_update(scene) {
	with (scene) {
		var beat = ds_map_find_value(beats, current)
		if (active) {
			beat.update()
			if (beat.ready_to_end()) {
				current = beat.goto[beat.selected_goto]
				beat.on_end()
				if (beat.end_scene) active = false
			}
		} else if (detect_start()) {
			active = true
			beat.on_start()
		}
	}
}

function scene_draw(scene) {
	with (scene) {
		if (active) ds_map_find_value(beats, current).draw()
	}
}

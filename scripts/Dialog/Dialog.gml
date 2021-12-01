// This is a dialog focused beat constructor for a scene.

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



/* choice struct
The choices parameter is an array of choice structs. The label field 
is for a label in the beat map. The display field is an alias for this label
that's displayed to the user in the dialog. For example:
{
	body: "Would you like to hear that again?"
	choices: [
		new Dialog_Choice("yes", "start),
		new Dialog_Choice("no", "end")
	]
}
*/

/// @func Dialog_Choice(display, label)
function Dialog_Choice(_display, _label) constructor {
	display = _display
	label = _label
}

/// @func Dialog(body, label, choices, specific_goto, end_scene)
function Dialog(_body, _label, _choices, _specific_goto, _end_scene) constructor {
	body = _body
	
	ready_to_end = function() {
		return keyboard_check_pressed(vk_space)
	}
	
	if (!is_undefined(_label)) {
		label = _label
	}
	
	choices = []
	if (!is_undefined(_choices)) {
		goto = []
		for (var i = 0; i < array_length(_choices); i++) {
			array_push(choices, _choices[i].display)
			array_push(goto, _choices[i].label)
		}
	}
	
	if (!is_undefined(_specific_goto)) {
		goto = [_specific_goto]
	}
	
	if (!is_undefined(_end_scene)) {
		end_scene = _end_scene
	}
	
	update = function() {
		if (keyboard_check_pressed(vk_up) && selected_goto > 0) selected_goto -= 1
		if (keyboard_check_pressed(vk_down) && selected_goto < array_length(goto) - 1) selected_goto += 1
	}
	
	draw = function() {
		draw_text(0, 0, body)
		if (array_length(choices) <= 0) exit
		var Y = 12
		for (var i = 0; i < array_length(choices); i++) {
			var text = choices[i]
			if (i == selected_goto) text += " *"
			draw_text(0, Y, text)
			Y += 12
		}
	}
	
	on_end = function() {
		selected_goto = 0
	}
}


function Parse(_source_string) constructor {
	result_string = ""
	
	static string_split = function(s, delimiter) {
		var result = []
		for (var i = 1; i <= string_length(s);) {
			var next = string_pos_ext(delimiter, s, i - 1)
			if (next > 0) {
				var substr = string_copy(s, i, next - i)
				if (substr != "") {
					array_push(result, substr)
				}	
				i = next + string_length(delimiter)
			} else {
				array_push(result, string_copy(s, i, string_length(s)))
				i = string_length(s) + 1
			}
		}
		return result
	}
	
	static parse_effects = function(str) {
		var arr = string_split(str, " ")
		for (var i = 0; i < array_length(arr); i++) {
			var command_args = string_split(arr[i], ":")
			var _command = command_args[0]
			var _ender = false
			var _marked = false // effect can only be closed by specific end tag
			if (string_char_at(_command, 1) == "/") {
				_command = string_copy(_command, 2, string_length(_command) - 1)
				_ender = true
			}
			if (string_char_at(_command, string_length(_command)) == "/") {
				_command = string_copy(_command, 1, string_length(_command) - 1)
				_marked = true
			}
			var _args = array_length(command_args) > 1 ? string_split(command_args[1], ",") : []
			arr[i] = {
				ender:		_ender,
				marked:		_marked,
				command:	_command,
				args:		_args,
			}
		}
		return arr
	}
	
	effects = []
	var fx_map = ds_map_create()
	
	for (var i = 1; i <= string_length(_source_string); i++) {
		var char = string_char_at(_source_string, i)
		if (char == "<") {
			var next_pos = string_pos_ext(">", _source_string, i)
			if (next_pos == 0) next_pos = string_length(_source_string)
			var fx_str = string_copy(_source_string, i + 1, next_pos - i - 1)
			var parsed = parse_effects(fx_str)
			
			// determine start/end effect data
			var _index_start = string_length(result_string)
			var _index_end = _index_start - 1
			
			for (var f = 0; f < array_length(parsed); f++) {
				if (parsed[f].ender && ds_map_exists(fx_map, parsed[f].command)) {
					var found_fx = ds_map_find_value(fx_map, parsed[f].command)
					array_push(effects, {
						command:		parsed[f].command,
						args:			found_fx.args,
						index_start:	found_fx.index_start,
						index_end:		_index_end
					})
					ds_map_delete(fx_map, parsed[f].command)
				} else {
					ds_map_add(fx_map, parsed[f].command, {
						args:			parsed[f].args,
						index_start:	string_length(result_string),
						marked:			parsed[f].marked // effect can only be ended by ender, not empty tag
					})
				}
			}
			
			// end all invalid and unmarked effects if empty tag
			if (fx_str == "") {
				var fx_key = ds_map_find_first(fx_map)
				var to_delete = []
				while (fx_key != undefined) {
					var fx_val = ds_map_find_value(fx_map, fx_key)
					if (_index_end < fx_val.index_start) {
						array_push(to_delete, fx_key)
					} else if (!fx_val.marked) {
						array_push(effects, {
							command:		fx_key,
							args:			fx_val.args,
							index_start:	fx_val.index_start,
							index_end:		_index_end
						})
						array_push(to_delete, fx_key)
					}
					fx_key = ds_map_find_next(fx_map, fx_key)
				}
				for (var d = 0; d < array_length(to_delete); d++) {
					ds_map_delete(fx_map, to_delete[d])
				}
			}
			
			i = next_pos
		} else {
			var next_pos = string_pos_ext("<", _source_string, i)
			if (next_pos == 0) next_pos = string_length(_source_string) + 1
			var text = string_copy(_source_string, i, next_pos - i)
			result_string += text
			i = next_pos - 1
		}
	}
	
	// end all effects
	while (!ds_map_empty(fx_map)) {
		var fx_key = ds_map_find_first(fx_map)
		var fx_val = ds_map_find_value(fx_map, fx_key)
		if (string_length(result_string) - 1 >= fx_val.index_start) {
			array_push(effects, {
				command:		fx_key,
				args:			fx_val.args,
				index_start:	fx_val.index_start,
				index_end:		string_length(result_string) - 1
			})
		}
		ds_map_delete(fx_map, fx_key)
	}
	
	ds_map_destroy(fx_map)
}

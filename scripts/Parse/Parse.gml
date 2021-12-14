
function Parse(_source_string) constructor {
	source_string = ""
	
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
	
	// there may still be a bug where args causes YYC to fail, rename to argz if true
	static parse_effects = function(str) {
		var arr = string_split(str, " ")
		for (var i = 0; i < array_length(arr); i++) {
			var command_args = string_split(arr[i], ":")
			var command = command_args[0]
			var args = array_length(command_args) > 1 ? string_split(command_args[1], ",") : []
			arr[i] = {
				command:	command,
				args:		args
			}
		}
		return arr
	}
	
	// later, look over ways to speed this up by having i jump to the next correct position
	var parsing_fx = false
	var fx_str = ""
	for (var i = 1; i <= string_length(_source_string); i++) {
		var char = string_char_at(_source_string, i)
		if (char == "<") {
			parsing_fx = true
		} else if (char == ">") {
			var effects = parse_effects(fx_str)
			parsing_fx = false
		} else if (parsing_fx) {
			fx_str += char
		} else {
			source_string += char
		}
	}
}

function __randomize_position(position, magnitude) {
	var rand = random(1)
	if (magnitude == 0) {
		if (rand < 0.5) {
			position.x = 0
		} else {
			position.x = 1
		}
	} else if (rand < 1/3) {
		position.x = magnitude * -1
	} else if (rand < 2/3) {
		position.x = 0
	} else {
		position.x = magnitude
	}
	rand = random(1)
	if (magnitude == 0) {
		if (rand < 0.5) {
			position.y = 0
		} else {
			position.y = 1
		}
	} else if (rand < 1/3) {
		position.y = magnitude * -1
	} else if (rand < 2/3) {
		position.y = 0
	} else {
		position.y = magnitude
	}
}

/// @func Animated_Text(text, *width)
function Animated_Text() constructor {
	var parsed = new Parse(argument0)
	text = argument_count > 1 ? new Text(parsed.result_string, argument[1]) : new Text(parsed.result_string)
	typer = new Typer(text)
	typer.set_finished()
	typing = false
	var parsed_effects = parsed.effects

	static color_to_rgb = function(fx) {
		var set_rgb = false
		if (fx.command == "aqua") {
			set_rgb = true
			fx.args = [color_get_red(c_aqua), color_get_green(c_aqua), color_get_blue(c_aqua)]
		}
		if (fx.command == "black") {
			set_rgb = true
			fx.args = [0, 0, 0]
		}
		if (fx.command == "blue") {
			set_rgb = true
			fx.args = [color_get_red(c_blue), color_get_green(c_blue), color_get_blue(c_blue)]
		}
		if (fx.command == "dkgray" || fx.command == "dkgrey") {
			set_rgb = true
			fx.args = [color_get_red(c_dkgray), color_get_green(c_dkgray), color_get_blue(c_dkgray)]
		}
		if (fx.command == "fuchsia" || fx.command == "pink") {
			set_rgb = true
			fx.args = [color_get_red(c_fuchsia), color_get_green(c_fuchsia), color_get_blue(c_fuchsia)]
		}
		if (fx.command == "gray" || fx.command == "grey") {
			set_rgb = true
			fx.args = [color_get_red(c_gray), color_get_green(c_gray), color_get_blue(c_gray)]
		}
		if (fx.command == "green") {
			set_rgb = true
			fx.args = [color_get_red(c_green), color_get_green(c_green), color_get_blue(c_green)]
		}
		if (fx.command == "lime") {
			set_rgb = true
			fx.args = [color_get_red(c_lime), color_get_green(c_lime), color_get_blue(c_lime)]
		}
		if (fx.command == "ltgray" || fx.command == "ltgrey") {
			set_rgb = true
			fx.args = [color_get_red(c_ltgray), color_get_green(c_ltgray), color_get_blue(c_ltgray)]
		}
		if (fx.command == "maroon") {
			set_rgb = true
			fx.args = [color_get_red(c_maroon), color_get_green(c_maroon), color_get_blue(c_maroon)]
		}
		if (fx.command == "navy") {
			set_rgb = true
			fx.args = [color_get_red(c_navy), color_get_green(c_navy), color_get_blue(c_navy)]
		}
		if (fx.command == "olive") {
			set_rgb = true
			fx.args = [color_get_red(c_olive), color_get_green(c_olive), color_get_blue(c_olive)]
		}
		if (fx.command == "orange") {
			set_rgb = true
			fx.args = [color_get_red(c_orange), color_get_green(c_orange), color_get_blue(c_orange)]
		}
		if (fx.command == "purple") {
			set_rgb = true
			fx.args = [color_get_red(c_purple), color_get_green(c_purple), color_get_blue(c_purple)]
		}
		if (fx.command == "red") {
			set_rgb = true
			fx.args = [color_get_red(c_red), color_get_green(c_red), color_get_blue(c_red)]
		}
		if (fx.command == "silver") {
			set_rgb = true
			fx.args = [color_get_red(c_silver), color_get_green(c_silver), color_get_blue(c_silver)]
		}
		if (fx.command == "teal") {
			set_rgb = true
			fx.args = [color_get_red(c_teal), color_get_green(c_teal), color_get_blue(c_teal)]
		}
		if (fx.command == "white") {
			set_rgb = true
			fx.args = [255, 255, 255]
		}
		if (fx.command == "yellow") {
			set_rgb = true
			fx.args = [color_get_red(c_yellow), color_get_green(c_yellow), color_get_blue(c_yellow)]
		}
		
		if (set_rgb) {
			fx.command = "rgb"
		}
	}

	effects = []
	for (var parsed_index = 0; parsed_index < array_length(parsed_effects); parsed_index++) {
		var fx = parsed_effects[parsed_index]
		
		// typing effects
		
		// regular effects
		color_to_rgb(fx)
		
		if (fx.command == "rgb") {
			if (array_length(fx.args) != 3) throw "Animated Text Error: rgb command must have 3 arguments"
			text.set_base_color(fx.index_start, fx.index_end, make_color_rgb(fx.args[0], fx.args[1], fx.args[2]))
		}
		
		if (fx.command == "hover") {
			array_push(effects, {
				text:		text,
				i_start:	fx.index_start,
				i_end:		fx.index_end,
				increment:	array_length(fx.args) > 0 && is_real(fx.args[0]) ? fx.args[0] : 1/60,
				magnitude:	array_length(fx.args) > 1 && is_real(fx.args[1]) ? fx.args[1] : 4,
				progress:	0,
				reset:		function() {
					progress = 0
				},
				update:		function(mult = 1) {
					progress += increment * mult
				},
				draw:		function() {
					var mod_y = sin(progress * 2 * pi + pi * 0.5) * magnitude * -1 // -1 starts function at top
					text.mod_offset_y(i_start, i_end, mod_y)
				}
			})
		}
		
		if (fx.command == "wave") {
			array_push(effects, {
				text:		text,
				i_start:	fx.index_start,
				i_end:		fx.index_end,
				increment:	array_length(fx.args) > 0 && is_real(fx.args[0]) ? fx.args[0] : 1/60,
				magnitude:	array_length(fx.args) > 1 && is_real(fx.args[1]) ? fx.args[1] : 4,
				offset:		array_length(fx.args) > 2 && is_real(fx.args[2]) ? fx.args[2] : 1/4,
				progress:	0,
				reset:		function() {
					progress = 0
				},
				update:		function(mult = 1) {
					progress += increment * mult
				},
				draw:		function() {
					for (var i = 0; i <= i_end - i_start; i++) {
						var mod_y = sin(progress * 2 * pi + pi * 0.5 - i * offset) * magnitude * -1 // recall y is reversed
						text.mod_offset_y(i_start + i, i_start + i, mod_y)
					}
				}
			})
		}
		
		if (fx.command == "fade") {
			array_push(effects, {
				text:		text,
				i_start:	fx.index_start,
				i_end:		fx.index_end,
				increment:	array_length(fx.args) > 0 && is_real(fx.args[0]) ? fx.args[0] : 1/120,
				alpha_min:	array_length(fx.args) > 1 && is_real(fx.args[1]) ? fx.args[1] : 0.2,
				alpha_max:		array_length(fx.args) > 2 && is_real(fx.args[2]) ? fx.args[2] : 1,
				progress:	0,
				reset:		function() {
					progress = 0
				},
				update:		function(mult = 1) {
					progress += increment * mult
					// triangle function (looks better than sin IMO)
					var m = (progress * 2 + 1) % 2
					m = m <= 1 ? m : 2 - m
					m = (alpha_max - alpha_min) * m + alpha_min
					text.mod_alpha(i_start, i_end, m)
				},
				draw:		function() {
					// triangle function (looks better than sin IMO)
					var m = (progress * 2 + 1) % 2
					m = m <= 1 ? m : 2 - m
					m = (alpha_max - alpha_min) * m + alpha_min
					text.mod_alpha(i_start, i_end, m)
				}
			})
		}
		
		if (fx.command == "shake" || fx.command == "tremble") {
			/*
			Effect data is the same for shake and tremble. But if effect is tremble, instead we create
			an instance of the effect for each character.
			*/
			for (var i = fx.index_start; i <= fx.index_end; i += fx.command == "tremble" ? 1 : fx.index_end) {
				array_push(effects, {
					text:		text,
					i_start:	i,
					i_end:		fx.command == "tremble"? i : fx.index_end,
					increment:	array_length(fx.args) > 0 && is_real(fx.args[0]) ? fx.args[0] : 1/4,
					magnitude:	array_length(fx.args) > 1 && is_real(fx.args[1]) ? fx.args[1] : 1,
					position:	{x: 0, y: 0},
					progress:	0,
					reset:		function() {
						progress = 0
						position = {x: 0, y: 0}
					},
					update:		function(mult = 1) {
						progress += increment * mult
						if (progress >= 1) {
							__randomize_position(position, magnitude)
							progress -= 1
						}
					},
					draw:		function() {
						text.mod_offset_x(i_start, i_end, position.x)
						text.mod_offset_y(i_start, i_end, position.y)
					}
				})
			}
		}
		
		if (fx.command == "twitch") { 
			// arg order: num_of_twitches, increment, twitch_time, wait_min, wait_max
			var num_of_twitches = array_length(fx.args) > 0 ? fx.args[0] : 10
			for (var i = 0; i < num_of_twitches; i++) {
				array_push(effects, {
					text:		text,
					i_start:	fx.index_start,
					i_end:		fx.index_end,
					position:	{x: 0, y: 0},
					choice:		fx.index_start,
					increment:	array_length(fx.args) > 1 && is_real(fx.args[1]) ? fx.args[1] : 1/30,
					magnitude:	array_length(fx.args) > 2 && is_real(fx.args[2]) ? fx.args[2] : 1,
					time:		array_length(fx.args) > 3 && is_real(fx.args[3]) ? fx.args[3] : 1/30,
					wait_min:	array_length(fx.args) > 4 && is_real(fx.args[4]) ? fx.args[4] : 0.5,
					wait_max:	array_length(fx.args) > 5 && is_real(fx.args[5]) ? fx.args[5] : 1,
					wait:		array_length(fx.args) > 5 && is_real(fx.args[5]) ? fx.args[5] : 1, // not custom parameter, random calculated wait time
					progress:	0,
					reset:		function() {
						progress = 0
						position = {x: 0, y: 0}
						choice = fx.index_start
					},
					update:		function(mult = 1) {
						progress += increment * mult
						if (progress > time + wait) {
							wait = (random(1) * (wait_max - wait_min)) + wait_min
							choice = floor(random(1) * (i_end - i_start + 1)) + i_start
							__randomize_position(position, magnitude)
							progress = 0
						}
					},
					draw:		function() {
						if (progress <= time) {
							text.mod_offset_x(choice, choice, position.x)
							text.mod_offset_y(choice, choice, position.y)
						}
					}
				})
			}
		}
	}
}

function animated_text_typing_start(animated_text) {
	if (!animated_text_typing_is_finished(animated_text)) {
		animated_text.typing = true
	}
}

function animated_text_typing_pause(animated_text) {
	animated_text.typing = false
}

function animated_text_is_typing(animated_text) {
	return animated_text.typing && !animated_text.typer.typing_is_finished()
}

function animated_text_typing_is_finished(animated_text) {
	return animated_text.typer.typing_is_finished()
}

function animated_text_typing_set_finished(animated_text) {
	animated_text.typer.set_finished()
	animated_text.typing = false
}

function animated_text_typing_reset(animated_text) {
	animated_text.typer.reset()
	animated_text.typing = false
}

/// @func animated_string_update(animated_string, *update_multiplier)
function animated_text_update() {
	var anim_string = argument0
	var mult = argument_count > 1 ? argument[1] : 1
	with (anim_string) {
		if (typing) typer.update(0.3, 4)
		for (var i = 0; i < array_length(effects); i++) {
			effects[i].update(mult)
		}
	}
}

function animated_text_draw(x, y, animated_text) {
	with (animated_text) {
		typer.draw()
		for (var i = 0; i < array_length(effects); i++) {
			effects[i].draw()
		}
		text.draw(x, y)
	}
}
/// @description Insert description here
// You can write your code in this editor

var get_draw = function(body) {
	return function() {
		draw_text(0, 0, body)
	}
}

var advance = function() {
	return keyboard_check_pressed(vk_space)
}

var beats = [
	{
		draw: function() { draw_text(0, 0, "Greetings!")},
		ready_to_end: advance
	},
	{
		draw: function() { draw_text(0, 0, "Beautiful weather today isn't it?")},
		ready_to_end: advance
	},
	{
		draw: function() { draw_text(0, 0, "Talk to you later!")},
		ready_to_end: advance,
		end_scene: true
	},
	{
		draw: function() { draw_text(0, 0, "Oh...")},
		ready_to_end: advance
	},
	{
		draw: function() { draw_text(0, 0, "No I don't know the way to funky town. Sorry.")},
		ready_to_end: advance,
		end_scene: true
	},
	{
		draw: function() { draw_text(0, 0, "Ah, I see you're persistant.")},
		ready_to_end: advance
	},
	{
		draw: function() { draw_text(0, 0, "Very well, here's a super cool item for your adventure.")},
		ready_to_end: advance
	},
	{
		label: "end",
		draw: function() { draw_text(0, 0, "Good luck to you!")},
		ready_to_end: advance,
		goto: ["end"],
		end_scene: true
	}
]

scene = new Scene(beats, advance)
/// @description Insert description here
// You can write your code in this editor

var advance = function() {
	return keyboard_check_pressed(vk_space)
}

var beats1 = [
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

var beats2 = [
	new Dialog("Hello! Welcome to the example dialog.", "start1"),
	new Dialog("Do you prefer A or B?", undefined, [
		new Dialog_Choice("A", "a"),
		new Dialog_Choice("B", "b")
	]),
	new Dialog("You chose A!", "a", undefined, "end1"),
	new Dialog("You chose B!", "b", undefined, "end1"),
	new Dialog("goodbye", "end1", undefined, undefined, true),
	new Dialog("Oh, you're talking to me again?", "start2"),
	new Dialog("I wasn't expecting that."),
	new Dialog("Would you like to make another choice?", undefined, [
		new Dialog_Choice("Yes", "yes"),
		new Dialog_Choice("No", "no"),
		new Dialog_Choice("Maybe?", "maybe"),
	]),
	new Dialog("Good, because I just gave you one.", "yes", undefined, "end2"),
	new Dialog("Shame, because I just gave you one.", "no", undefined, "end2"),
	new Dialog("You must have more conviction", "maybe", undefined, "end2"),
	new Dialog("Goodbye again.", "end2", undefined, undefined, true)
]

scene = new Scene(beats2, advance)
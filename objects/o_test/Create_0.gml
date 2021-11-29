/// @description Insert description here
// You can write your code in this editor

dialog = new Dialog(
	[
		{
			label: "start1",
			body: "Hello! Welcome to the example dialog."
			
		},
		{
			body: "Do you prefer A or B?",
			goto: [
				{
					display: "A",
					label: "a"
				},
				{
					display: "B",
					label: "b"
				}
			]
		},
		{
			label: "a",
			body: "You chose A!",
			goto: "end1"
		},
		{
			label: "b",
			body: "You chose B!",
			goto: "end1"
		},
		{
			label: "end1",
			body: "goodbye",
			close: true
		},
		{
			label: "start2",
			body: "Oh, you're talking to me again?"
		},
		{
			body: "I wasn't expecting that."
		},
		{
			body: "Would you like make another choice?",
			goto: [
				{
					display: "Yes",
					label: "yes"
				},
				{
					display: "No",
					label: "no"
				},
				{
					display: "Maybe?",
					label: "maybe"
				}
			]
		},
		{
			label: "yes",
			body: "Good, because I just gave you one.",
			goto: "end2"
		},
		{
			label: "no",
			body: "Shame, because I just gave you one.",
			goto: "end2"
		},
		{
			label: "maybe",
			body: "You must have more conviction.",
			goto: "end2"
		},
		{
			label: "end2",
			body: "Goodbye again",
			close: true
		}
	],
	function() {
		return keyboard_check_pressed(vk_enter)
	}, function() {
		return keyboard_check_pressed(vk_space)
	}, function() {
		return keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_down)
	}, function() {
		return keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_up)
	}
)

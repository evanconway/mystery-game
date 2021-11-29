/// @description Insert description here
// You can write your code in this editor

dialog = new Dialog(
	[
		{
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
			goto: "end"
		},
		{
			label: "b",
			body: "You chose B!",
			goto: "end"
		},
		{
			label: "end",
			body: "goodbye",
			close: true
		}
	],
	function() {
		return keyboard_check_pressed(vk_enter)
	}, function() {
		return keyboard_check_pressed(vk_space)
	}, function() {
		return keyboard_check_pressed(vk_right)
	}, function() {
		return keyboard_check_pressed(vk_left)
	}
)

/// @description Insert description here
// You can write your code in this editor

conversation = new Conversation(function() {
	return keyboard_check_pressed(vk_enter)
}, function() {
	return keyboard_check_pressed(vk_space)
}, function() {
	return keyboard_check_pressed(vk_right)
}, function() {
	return keyboard_check_pressed(vk_left)
})

dialog = new Dialog()
/// @description Insert description here
// You can write your code in this editor

if (keyboard_check_pressed(ord("R"))) {
	animated_text_typing_reset(test)
}

if (keyboard_check_pressed(vk_space)) {
	if (animated_text_is_typing(test)) {
		animated_text_typing_pause(test)
	} else {
		animated_text_typing_start(test)
	}
}


animated_text_draw(100, 100, test)
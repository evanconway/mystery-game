/// @description Insert description here
// You can write your code in this editor
var adjust = 10

if (keyboard_check_pressed(vk_left)) {
	width -= adjust;
	text = new Text(source_string, width)
}
if (keyboard_check_pressed(vk_right)) {
	width += adjust
	text = new Text(source_string, width)
}


if (keyboard_check_pressed(vk_up)) {
	text.set_base_font(0, 10, f_text_default)
}

if (keyboard_check_pressed(vk_down)) {
	text.set_base_font(0, 10, f_text_handwritten)
}

draw_set_color(c_lime)
draw_text(0, 0, fps_real)
draw_set_color(c_white)
draw_text(0, 20, "width: " + string(width))
text_draw(100, 300, text)
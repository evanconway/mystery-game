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

if (keyboard_check_pressed(ord("F"))) {
	toggle_font = !toggle_font
	if (toggle_font) text.set_base_font(0, 10, f_text_default)
	else text.set_base_font(0, 10, f_text_handwritten)
}

if (keyboard_check_pressed(ord("S"))) {
	toggle_scale = !toggle_scale
	if (toggle_scale) {
		text.set_base_scale_x(20, 40, 1)
		text.set_base_scale_y(10, 30, 1)
	} else {
		text.set_base_scale_x(20, 40, 2)
		text.set_base_scale_y(10, 30, 2)
	}
}

if (keyboard_check_pressed(ord("O"))) {
	toggle_offset = !toggle_offset
	if (toggle_offset) {
		text.set_base_offset_x(5, 33, 0)
		text.set_base_offset_y(35, 43, 0)
	} else {
		text.set_base_offset_x(5, 33, -10)
		text.set_base_offset_y(35, 43, 20)
	}
}

draw_set_color(c_lime)
draw_text(0, 0, fps_real)
draw_set_color(c_white)
draw_text(0, 20, "width: " + string(width))
text_draw(100, 300, text)
/// @description Insert description here
// You can write your code in this editor
var adjust = 20

if (keyboard_check_pressed(vk_left)) {
	width -= adjust;
	text = new Text(source_string, width)
}

if (keyboard_check_pressed(vk_right)) {
	width += adjust
	text = new Text(source_string, width)
}

//text.set_color(6, 22, c_yellow)
//text.set_offset_x(8, 15, -5)
//text.set_offset_y(18, 23, 5)
//text.set_alpha(32, 41, 0.3)

text.fx_twitch(6, 22, update_count, 0.05, 0, 0.1, 0.4)
update_count++

draw_set_color(c_lime)
draw_text(0, 0, fps_real)
draw_set_color(c_white)
draw_text(0, 20, "width: " + string(width))
text_draw(100, 300, text)

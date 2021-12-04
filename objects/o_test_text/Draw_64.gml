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

draw_text(0, 0, "width: " + string(width))
text_draw(100, 100, text)
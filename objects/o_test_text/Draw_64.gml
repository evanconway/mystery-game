/// @description Insert description here
// You can write your code in this editor
var adjust = 20

if (keyboard_check_pressed(vk_left)) {
	width -= adjust;
	text = new Text(source_string, width)
	typer = new Type(text)
}

if (keyboard_check_pressed(vk_right)) {
	width += adjust
	text = new Text(source_string, width)
	typer = new Type(text)
}

text.mod_color(6, 22, c_yellow)
//text.mod_offset_x(25, 35, -5)
//text.mod_offset_y(40, 50, 5)
text.mod_alpha(55, 71, 0.3)

text.fx_hover(0, 100, update_count, 1/60, 2) 
text.fx_fade(150, 350, update_count, 1/60, 0.2, 1)
text.fx_twitch(500, 600, update_count, 0.1, 2, 0.5, 0.3, 2)
text.fx_wave(700, 780, update_count, 1/60, 3, 0.1)
update_count++

draw_set_color(c_lime)
draw_text(0, 0, fps_real)
draw_set_color(c_white)
draw_text(0, 20, "width: " + string(width))

if (keyboard_check_pressed(vk_space)) start = true
if (start) typer.update(0.15, 2.8)
else typer.update(0, 0)

if (keyboard_check_pressed(ord("F"))) {
	typer.set_finished()
}

text_draw(100, 300, text)

if (keyboard_check_pressed(ord("R"))) {
	typer.reset()
	start = false
}
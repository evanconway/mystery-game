/// @func Conversation(detect_start, detect_advance, select_next_option, select_previous_option)
function Conversation(start, advance, next, previous) constructor {
	detect_start = start
	detect_advance = advance
	next_option = next
	previous_option = previous
	active = false
	dialog = new Dialog()
}

function conversation_update(conversation) {
	with (conversation) {
		if (detect_start()) {
			show_debug_message("detect start invoked!")
			active = !active
		}
		if (active) {
			if (next_option()) show_debug_message("choose next option invoked!")
			if (previous_option()) show_debug_message("choose previous option invoked!")
			if (detect_advance()) show_debug_message("detect advance invoked!")
		}
	}
}

function conversation_draw(conversation) {
	with (conversation) {
		if (active) draw_text(0, 0, "The conversation is active!")
	}
}

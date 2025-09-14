extends CodeEdit

var return_counter: int = 0

var where_lines_returned: Array[bool] = [false, false, false]

func _on_text_changed() -> void:
	if text:
		%RecordAudioButton.hide()
		%MessageSendButton.show()
		
		var line_count: int = get_line_count()
		var line_wrapped_count: int = get_line_wrap_count(0)
		
		match line_count:
			2:
				if !where_lines_returned[0]:
					where_lines_returned[0] = true
					custom_minimum_size.y = size.y + (get_line_height())
			3:
				if !where_lines_returned[1]:
					where_lines_returned[1] = true
					custom_minimum_size.y = custom_minimum_size.y + (get_line_height())
			4:
				if !where_lines_returned[2]:
					where_lines_returned[2] = true
					custom_minimum_size.y = custom_minimum_size.y + (get_line_height())
	else:
		%RecordAudioButton.show()
		%MessageSendButton.hide()

func _on_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.

func _on_text_set() -> void:
	if text:
		%RecordAudioButton.hide()
		%MessageSendButton.show()
	else:
		%RecordAudioButton.show()
		%MessageSendButton.hide()

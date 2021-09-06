extends Popup









func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		togglePauseMenu()


func togglePauseMenu():
	get_tree().paused = !get_tree().paused
	
	if (get_tree().paused):
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		hide()
#		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

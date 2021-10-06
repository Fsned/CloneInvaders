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


func _on_ResumeButton_pressed():
	togglePauseMenu()


func _on_ExitButton_pressed():
	toggleConfirmMenu()
	
	
	
func toggleConfirmMenu():
	$NinePatchRect/CenterContainer/VBoxContainer/NinePatchRect/ConfirmMenu.visible = !$NinePatchRect/CenterContainer/VBoxContainer/NinePatchRect/ConfirmMenu.visible

func _on_SureYes_pressed():
	get_tree().quit()


func _on_SureNo_pressed():
	toggleConfirmMenu()


func _on_MenuButton_pressed():
	togglePauseMenu()
	var _a = get_tree().change_scene("res://4. Scenes/Menus/welcomeMenu.tscn")
	get_tree().call_group("dialogs", "closeAllDialogs")

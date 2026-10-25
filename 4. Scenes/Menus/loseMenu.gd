extends Control





func _ready():
	pass
	
	

	
	
func setScore(value):
	$CenterContainer/VBoxContainer/HBoxContainer/scoreLabel.text = str(value)




func _on_tryAgainButton_pressed():
	var _a = get_tree().change_scene_to_file("res://3. Levels/Level1.tscn")
	get_tree().paused = false
	
	


func _on_ReturnToMenuButton_pressed():
	var _a = get_tree().change_scene_to_file("res://4. Scenes/Menus/welcomeMenu.tscn")
	get_tree().paused = false



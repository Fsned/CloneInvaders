extends Node2D


func _ready():
	Input.set_custom_mouse_cursor(load("res://1. GFX/GUI/Reticle3.png"), 0, Vector2(24,24))
	
	
	
func _on_NewGameButton_pressed():
	print ("New game")
	var _a = get_tree().change_scene("res://3. Levels/Level1.tscn")
	


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_LoadGameButton_pressed():
	print ("Load game")
	get_tree().call_group("levelManager", "loadGame")


func _on_PlayTutorialButton_pressed():
	print ("Play tutorial")
	var _a = get_tree().change_scene("res://3. Levels/LevelTutorial.tscn")

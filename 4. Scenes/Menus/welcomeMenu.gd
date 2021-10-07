extends Node2D


func _ready():
	Input.set_custom_mouse_cursor(load("res://1. GFX/GUI/Reticle3.png"), 0, Vector2(24,24))
	
	var highscore = GameData.getKey("score")
	
	if highscore == 0: $Background/CenterContainer3.visible = false
	else: 
		$Background/CenterContainer3.visible = true
		$Background/CenterContainer3/HBoxContainer/Label2.text = str(highscore)
	
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


func _on_SettingButton_pressed():
	$settings.show()
	
#func loadSavedData():
##	var levelNode = get_tree().get_root().find_node("Level1", true, false)
##
##	var saveData
##
##	if levelNode.has_method("load"):
##		saveData = levelNode.call("load")
##
##	if saveData["score"] != null:
##		var savedScore = saveData["score"]
##		print("score is: " + savedScore)
##	else:
##		print ("score is null :()")
	
	
	



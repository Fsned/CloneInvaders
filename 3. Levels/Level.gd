extends Node2D

var enemyCount = 0


func _ready():
	enemyCount = find_node("Enemies", true, false).get_child_count()
	print ("Enemycount is : " + str(enemyCount))
	get_tree().call_group("GUI", "setLevel", 1)
	
	



func mobDied():
	print ("Killed an enemy")
	enemyCount -= 1
	if enemyCount <= 0:
		win()



func win():
	get_tree().change_scene("res://4. Scenes/Menus/welcomeMenu.tscn")




func loseGame():
	print ("You lost!")

extends "res://4. Scenes/CharacterTemplate.gd"




func _process(_delta):
	followMouse()
	handlePlayerInput()
	handlePlayerMovement()

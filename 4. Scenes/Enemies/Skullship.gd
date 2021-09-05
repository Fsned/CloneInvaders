extends "res://4. Scenes/CharacterTemplate.gd"

export var health = 10
	
func _process(_delta):
	handleEnemyInput()
	
	
	
func hurt():
	health -= 2
	if health > 0:
		$AnimationPlayer.play("hurt")
	else:
		if health == 0:
			$AnimationPlayer.play("die")
			get_tree().call_group("levelManager", "mobDied")
		
		
	

extends "res://4. Scenes/CharacterTemplate.gd"

export var health = 10
	
func _process(_delta):
	handleEnemyInput()
	
	
	
func hurt():
	if $hurtTimer.is_stopped():
		health -= 2
		if health > 0:
			$AnimationPlayer.play("hurt")
			$hurtTimer.start()
		else:
			if health == 0:
				$AnimationPlayer.play("die")
				get_tree().call_group("levelManager", "mobDied")
		
		
	

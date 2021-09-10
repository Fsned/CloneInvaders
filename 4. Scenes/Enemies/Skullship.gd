extends "res://4. Scenes/CharacterTemplate.gd"

export var expReward = 50
export var meteoReward = 5



func _ready():
	health = 10

func _process(_delta):
	handleEnemyInput()
	
	
	
func hurt(amount):
	if is_alive():
		if $hurtTimer.is_stopped():
			damage(amount)
			
		if !is_alive():
			$AnimationPlayer.play("die")
			get_tree().call_group("levelManager", "mobDied")
			get_tree().call_group("player", "getKill", expReward, meteoReward)
		else:	
			$AnimationPlayer.play("hurt")
			$hurtTimer.start()
				
				
		
		
	

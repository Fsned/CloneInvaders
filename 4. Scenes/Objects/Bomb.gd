extends "res://4. Scenes/Characters/CharacterTemplate.gd"

var speed = 0

func _ready():
	properties.setMaxHealth(25)
	speed = rand_range(-10000, -15000)
	
	
func _process(delta):
	var _a = move_and_slide(Vector2(speed * delta, 0))
	
	
func _on_Area2D_body_entered(body):
	
	match (unitType):
		4: # Bomb
			if body.has_method("hurt"):
				body.hurt(50)
		5: # Freezer
			if body.has_method("freeze"):
				body.freeze(2)
			

func _on_Bomb_died(_unitType):
	$AnimationPlayer.play("explode")
	



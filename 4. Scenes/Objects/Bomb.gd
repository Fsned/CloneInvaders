extends "res://4. Scenes/Characters/CharacterTemplate.gd"

var speed = 0

func _ready():
	super()
	properties.setMaxHealth(25)
	speed = randf_range(-10000, -15000)
	
	
func _process(delta):
	set_velocity(Vector2(speed * delta, 0))
	move_and_slide()
	var _a = velocity
	
	
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
	



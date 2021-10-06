extends RigidBody2D

var rotationScale = 0.0

const asteroidFragment = preload("res://4. Scenes/Obstacles/asteroidFragment.tscn")

export var damage = 50
export var shatterChance = 100
export var fragmentSpeed = 350

func ready():
	randomize()
	
	
	
func _on_despawnTimer_timeout():
	queue_free()


func _on_Asteroid_body_entered(body):
	if (body.collision_layer != 1 and body.collision_layer != 2):
		return
		
	
	if (not body.has_method("hurt")):
		return
	
	body.hurt(damage)
	
	randomize()
	var shatterRoll = randi() % 100
	if (shatterRoll <= shatterChance):
		explode()
	else:
		print("ShatterRoll: " + str(shatterRoll))
		
				
				
				
				
func explode():
#	Spawn 3-5 fragments
	randomize()
	var noOfFragments = randi() % 5 + 2
	
	$AnimationPlayer.play("explode")
	
	for _a in range(noOfFragments):
		var shatterFragmentObject = asteroidFragment.instance()
		get_parent().add_child(shatterFragmentObject)
		shatterFragmentObject.global_transform = global_transform
		shatterFragmentObject.linear_velocity = Vector2.LEFT.rotated(rad2deg(randi() % 6)) * fragmentSpeed
	
	collision_layer = 0


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

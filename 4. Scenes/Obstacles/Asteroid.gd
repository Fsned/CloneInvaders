extends RigidBody2D

var rotationScale = 0.0

const asteroidFragmentPath = "res://4. Scenes/Obstacles/asteroidFragment.tscn"

export var damage = 50
export var shatterChance = 100
export var fragmentSpeed = 150

func ready():
	randomize()
	angular_velocity = randi() % 4 + 2
	
	
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
	var noOfFragments = randi() % 5 +1
	
	print ("Shattering into: " + str(noOfFragments) + " fragments!!")
	
	for a in range(noOfFragments):
		var shatterFragmentObject = load(asteroidFragmentPath).instance()
		add_child(shatterFragmentObject)
		shatterFragmentObject.set_as_toplevel(true)
		shatterFragmentObject.global_transform = global_transform
		shatterFragmentObject.linear_velocity = Vector2.LEFT.rotated(randi() % 2*PI) * ((randi() % 110 + 90)/100.0 * fragmentSpeed)
		
	
	
			
		

extends RigidBody2D

var rotationScale = 0.0

func ready():
	randomize()
	angular_velocity = randi() % 8 + 2
func _on_despawnTimer_timeout():
	queue_free()


func _on_Asteroid_body_entered(body):
	if (body.collision_layer == 1):
		print ("Hit the player!!!")
		if (body.has_method("hurt")):
			body.hurt()

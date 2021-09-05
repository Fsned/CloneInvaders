extends RigidBody2D


func _ready():
	$despawnTimer.start()







func _on_despawnTimer_timeout():
	queue_free()



func _on_LaserBullet_body_entered(body):
	if (body.collision_layer == 2 || body.collision_layer == 1):
		if (body.has_method("hurt")):
			body.hurt()
		queue_free()

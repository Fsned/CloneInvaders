extends RigidBody2D


export var damage = 25








func _on_despawnTimer_timeout():
	queue_free()



func _on_LaserBullet_body_entered(body):
	if (body.has_method("hurt")):
		body.hurt(damage)
	
	$Particles2D.set_as_toplevel(true)
	$Particles2D.global_position = global_position
	$Particles2D.emitting = true
			
	$Sprite.visible = false
	collision_layer = 0
	collision_mask = 0
	$despawnTimer.start()

func set_projectile_modulation(color):
	$Sprite.self_modulate = color
	$Particles2D.process_material.color = color


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

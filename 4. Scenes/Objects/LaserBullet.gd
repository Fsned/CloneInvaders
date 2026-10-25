extends RigidBody2D


@export var damage = 25








func _on_despawnTimer_timeout():
	queue_free()



func _on_LaserBullet_body_entered(body):
	if (body.has_method("hurt")):
		body.hurt(damage)
	
	$GPUParticles2D.set_as_top_level(true)
	$GPUParticles2D.global_position = global_position
	$GPUParticles2D.emitting = true
			
	$Sprite2D.visible = false
	collision_layer = 0
	collision_mask = 0
	$despawnTimer.start()

func set_projectile_modulation(color):
	$Sprite2D.self_modulate = color
	$GPUParticles2D.process_material.color = color


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

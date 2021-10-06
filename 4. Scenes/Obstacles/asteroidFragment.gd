extends RigidBody2D


const damage = 5


func _on_asteroidFragment_body_entered(body):
	if (not body.has_method("hurt")):
		return
	
	body.hurt(damage)
	$AnimationPlayer.play("explode")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

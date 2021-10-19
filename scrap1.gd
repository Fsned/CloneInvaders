extends Area2D

var disappearing = false

func _on_scrap1_body_entered(body):
	if body.has_method("collectCoin") && disappearing == false:
		disappearing = true
		
		if (body.collectCoin()):
			$AnimationPlayer.play("disappear")


func _on_Area2D_body_entered(body):
	$AnimationPlayer.stop()
	if body.has_method("collectCoin") && disappearing == false:
		disappearing = true
		
		if (body.collectCoin()):
			$AnimationPlayer.play("disappear")

extends RigidBody2D

enum pickupType {
	aye,
	health,
	power,
	shootingSpeed,
	armor,
	bomb,
	freeze
}

func _ready():
	$Particles2D.texture = $upgradeSprite.texture
	$Particles2D.scale = Vector2(0.2, 0.2)



export (pickupType) var unitType = pickupType.aye


func _on_Pickup_body_entered(body):
	if body.has_method("pickup"):
		body.pickup(unitType)
	queue_free()

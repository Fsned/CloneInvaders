extends RigidBody2D

enum pickupType {
	health,
	power,
	shootingSpeed,
	armor,
	bomb,
	freeze
}

export (pickupType) var unitType = pickupType.health

func _ready():
#	Set corresponding sprite here
	match unitType:
		pickupType.health:
			pass
		pickupType.power:
			pass
		pickupType.shootingSpeed:
			pass
		pickupType.armor:
			pass
		pickupType.bomb:
			pass
		pickupType.freeze:
			pass
	

	


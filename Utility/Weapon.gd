extends Node2D

class_name Weapons

enum weaponType {
	basic,
	double,
	triple,
	cone
}

var shotCooldown = false
var currentProjectile = preload("res://4. Scenes/Objects/LaserBullet.tscn")	
var type = weaponType.basic 
var projectileSpeed = 10
var cooldown = 0.5



func _ready():
	switchWeapon(type)
	

func _process(_delta):
	pass

func switchWeapon(type):
	pass

func timerTimeout():
	print("Hello12")

func fire(_color):
	match type:
		weaponType.basic:
			if shotCooldown == false:
				shotCooldown = true
				spawnProjectile(projectileSpeed)
				get_tree().create_timer(0.5)
				
		weaponType.double:
			if shotCooldown == false:
				shotCooldown = true
				for a in range(0, 2):
					spawnProjectile(projectileSpeed, -0.15 + (a*0.3))
				get_tree().create_timer(0.5)
		weaponType.triple:
			
			if shotCooldown == false:
				shotCooldown = true
				for a in range(0, 3):
					spawnProjectile(projectileSpeed, -0.15 + (a*0.15))
				get_tree().create_timer(0.5)
		weaponType.cone:
			if shotCooldown == false:
				shotCooldown = true
				for a in range(0, 8):
					spawnProjectile(projectileSpeed, -0.8 + (a*(1.6/8.0)))
				get_tree().create_timer(0.5)


func spawnProjectile(speed, rotation = 0, _scenePath = "res://4. Scenes/Projectiles/LaserBullet.tscn", color = "e3e01a"):
	var projectile = currentProjectile.instance()
	projectile.set_as_toplevel(true)
	projectile.global_transform = global_transform
	
	projectile.linear_velocity = ((Vector2(global_position - global_position)) * speed).rotated(rotation)
#	projectile.set_projectile_modulation(color)
	add_child(projectile)


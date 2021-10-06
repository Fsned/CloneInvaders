extends KinematicBody2D

var properties = PlayerProperties.new()

export(int, "Player", "Enemy", "Boss", "Pickup") var unitType = 0

enum weapon {
	basic,
	double,
	triple,
	cone
}

var weaponCooldowns = {	"basic": 0.25,
						"double": 0.25,
						"triple": 0.25,
						"cone": 0.25 }

export (int, "Basic", "Double", "Triple", "Cone") var currentWeapon = weapon.basic

export var SPEED = 10000
export var invincible = true
export (int, 0.1, 5) var shotCooldown = 0.25
var motion = Vector2.ZERO
var projectileSpeed = 20
var currentProjectile = preload("res://4. Scenes/Projectiles/LaserBullet.tscn")	
var alive = true
var health = 50
var playerColor = "e3e01a"

signal healthChanged
#signal powerChanged
signal died
signal weaponChanged
	
func _ready():
	switchWeapon(currentWeapon, true)	
	$shotCooldown.wait_time = shotCooldown
	

func followMouse():	
	look_at(get_global_mouse_position())

func handleEnemyInput():
	if $RayCast2D.is_colliding():
		fire("c91e1e")
		
func handlePlayerInput():
	if is_alive():
		if Input.is_action_pressed("Shoot"):
			fire(playerColor)
	

func handlePlayerMovement():
	if is_alive():
		var x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
		var y = Input.get_action_strength("Back") - Input.get_action_strength("Forward")
		
		motion.x = x
		motion.y = y

		var _a = move_and_slide(motion * SPEED)



func switchWeapon(newWeapon, forcedUpdate = false):
	if (is_alive() && currentWeapon != newWeapon) or forcedUpdate:
		currentWeapon = newWeapon
		
		match currentWeapon:
			weapon.basic:
				$showCooldown.wait_time = weaponCooldowns["basic"]
#				$shotCooldown.wait_time = 0.25 + (unitType*1)
			weapon.double:
				$shotCooldown.wait_time = 0.25 + (unitType*1)
			weapon.triple:
				$shotCooldown.wait_time = 0.25 + (unitType*1)
			weapon.cone:
				$shotCooldown.wait_time = 0.25 + (unitType*1)
				
		emit_signal("weaponChanged")


func fire(colour = "e3e01a"):
	
	match currentWeapon:
		weapon.basic:
			if $shotCooldown.is_stopped():
				spawnProjectile(projectileSpeed)
				$shotCooldown.start()
				
		weapon.double:
			if $shotCooldown.is_stopped():
				for a in range(0, 2):
					spawnProjectile(projectileSpeed, -0.15 + (a*0.3))
				$shotCooldown.start()
		weapon.triple:
			
			if $shotCooldown.is_stopped():
				for a in range(0, 3):
					spawnProjectile(projectileSpeed, -0.15 + (a*0.15))
				$shotCooldown.start()
		weapon.cone:
			if $shotCooldown.is_stopped():
				for a in range(0, 8):
					spawnProjectile(projectileSpeed, -0.8 + (a*(1.6/8.0)))
				$shotCooldown.start()
	
func is_alive():
	return alive
	
			
func hurt(amount):
	if invincible: return
	
	if !is_alive():
		return false
	
	properties.currentHealth -= amount
	emit_signal("healthChanged", properties.currentHealth)
	
	if properties.currentHealth <= 0:
		if $AnimationPlayer.has_animation("die"):
			$AnimationPlayer.play("die")
		alive = false
		emit_signal("died", unitType)
		if unitType == 1 or unitType == 2:
			get_tree().call_group("levelManager", "unitDied", unitType)
		return
	
	if $AnimationPlayer.has_animation("hurt"):
		$AnimationPlayer.play("hurt")
		
	


func spawnProjectile(speed, rotation = 0, scenePath = "res://4. Scenes/Projectiles/LaserBullet.tscn", color = "e3e01a"):
	var projectile = currentProjectile.instance()
	projectile.set_as_toplevel(true)
	projectile.global_transform = $Forward.global_transform
	projectile.linear_velocity = ((Vector2($Forward.global_position - global_position)) * speed).rotated(rotation)
	projectile.set_projectile_modulation(color)
	add_child(projectile)

extends CharacterBody2D

var properties = PlayerProperties.new()

# Physics layer bits (see Project Settings > Layer Names > 2D Physics)
const LAYER_PLAYER = 1
const LAYER_ENEMY = 2
const LAYER_SCENERY = 4
const LAYER_PROJECTILES = 8

#var weapon = Weapon.new()

@export var unitType = 0 # (int, "Player", "Enemy", "Boss", "Pickup", "Bomb", "Freezer")
enum pickupType {
	aye,
	health,
	power,
	shootingSpeed,
	armor,
	bomb,
	freeze
}

enum weapon {
	basic,
	double,
	triple,
	cone
}

var weaponCooldowns = {	"basic": 1,
						"double": 0.25,
						"triple": 0.25,
						"cone": 0.25 }

@export var currentWeapon = weapon.basic # (int, "Basic", "Double", "Triple", "Cone")

@export var SPEED = 10000
@export var invincible = true
@export var canMove = true
@export var frozenTimer = 0
@export var shotCooldown = 1 # (float, 0.1, 5)
var motion = Vector2.ZERO
var projectileSpeed = 20
var projectileDamage = 25
var currentProjectile = preload("res://4. Scenes/Objects/LaserBullet.tscn")	
var alive = true
var health = 50
var playerColor = "e3e01a"
@export var canCollectCoins = false

signal healthChanged
#signal powerChanged
signal died
signal weaponChanged
signal coinsChanged
	
func _ready():
	# Top-down game: no floors/walls, so use floating motion instead of platformer-style "grounded"
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	switchWeapon(currentWeapon, true)
	

func followMouse():	
	if canMove:
		look_at(get_global_mouse_position())

func handleEnemyInput(delta = 0):
	if frozenTimer > 0:
		frozenTimer -= delta
		if frozenTimer <= 0:
			canMove = true
	
	if $RayCast2D.is_colliding():
		fire("c91e1e")
		
func handlePlayerInput():
	if is_alive():
		if Input.is_action_pressed("Shoot"):
			fire(playerColor)
	

func handlePlayerMovement(delta = 0):
	if is_alive():
		if frozenTimer > 0:
			frozenTimer -= delta
			if frozenTimer <= 0:
				canMove = true
				frozenTimer = 0
		if canMove: 
			var x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
			var y = Input.get_action_strength("Back") - Input.get_action_strength("Forward")
			
			motion.x = x
			motion.y = y
		else:
			motion = Vector2.ZERO

		set_velocity(motion * SPEED)
		move_and_slide()
		var _a = velocity



func switchWeapon(newWeapon, forcedUpdate = false):
	if (is_alive() && currentWeapon != newWeapon) or forcedUpdate:
		currentWeapon = newWeapon
#
#		match currentWeapon:
#			weapon.basic:
#				$shotCooldown.wait_time = weaponCooldowns["basic"]
##				$shotCooldown.wait_time = 0.25 + (unitType*1)
#			weapon.double:
#				$shotCooldown.wait_time = 0.25 + (unitType*1)
#			weapon.triple:
#				$shotCooldown.wait_time = 0.25 + (unitType*1)
#			weapon.cone:
#				$shotCooldown.wait_time = 0.25 + (unitType*1)
				
		emit_signal("weaponChanged")

func setWeaponCooldown(time):
	$shotCooldown.wait_time = time
	
func getWeaponCooldown():
	return $shotCooldown.wait_time

func fire(colour = "e3e01a"):
	if not $shotCooldown.is_stopped():
		return

	match currentWeapon:
		weapon.basic:
			spawnProjectile(projectileSpeed, 0.0, "", colour)
		weapon.double:
			for a in range(0, 2):
				spawnProjectile(projectileSpeed, -0.08 + (a*0.16), "", colour)
		weapon.triple:
			for a in range(0, 3):
				spawnProjectile(projectileSpeed, -0.15 + (a*0.15), "", colour)
		weapon.cone:
			for a in range(0, 5):
				spawnProjectile(projectileSpeed, -0.4 + (a*0.2), "", colour)
	$shotCooldown.start()
	
func is_alive():
	return alive
	
			
func hurt(amount):
	if invincible: return
	
	if !is_alive():
		return false
	
	properties.currentHealth -= amount
	emit_signal("healthChanged", properties.getNormalizedHealth())

	
	if properties.currentHealth <= 0:
		if $AnimationPlayer.has_animation("die"):
			$AnimationPlayer.play("die")
		alive = false
		emit_signal("died", unitType)
		$CollisionShape2D.set_deferred("disabled", true)
#		if unitType == 1 or unitType == 2:
		get_tree().call_group("levelManager", "unitDied", unitType)
		return
	
	if $AnimationPlayer.has_animation("hurt"):
		$AnimationPlayer.play("hurt")
		
	


func spawnProjectile(speed, angleOffset = 0.0, _scenePath = "res://4. Scenes/Projectiles/LaserBullet.tscn", color = "e3e01a"):
	var projectile = currentProjectile.instantiate()
	projectile.set_as_top_level(true)
	projectile.global_transform = $Forward.global_transform
	projectile.linear_velocity = ((Vector2($Forward.global_position - global_position)) * speed).rotated(angleOffset)
	projectile.set_projectile_modulation(Color(color))
	projectile.damage = projectileDamage
	# Bullets only hit the other side (+ scenery): player shots hit enemies, enemy shots hit the player
	projectile.collision_mask = (LAYER_ENEMY if unitType == 0 else LAYER_PLAYER) | LAYER_SCENERY
	add_child(projectile)


func pickup(pickType):
	match(pickType):
		pickupType.health:
			properties.heal(20)
			print ("picked up health! new health: " + str(properties.currentHealth) + " / " + str(properties.maxHealth))
			emit_signal("healthChanged", properties.getNormalizedHealth())
			
		pickupType.shootingSpeed:
			var newShotSpeed = getShootingSpeed() * 0.9
			setShootingSpeed(newShotSpeed)
			print ("Setting speed to: " + str(newShotSpeed))
		
		_:
			print ("Caught something: " + str(unitType))			
			
			
			
func getShootingSpeed():
	return $shotCooldown.wait_time
	
	
func setShootingSpeed(value):
	$shotCooldown.wait_time = value
	
	
func collectCoin():
	if canCollectCoins:
		addCoins(1)
		return true
	
	return false
	
func getCoins():
	return properties.coins

func setCoins(amount):
	if properties.coins != amount:
		properties.coins = amount
		emit_signal("coinsChanged", properties.coins)

func addCoins(amount):
	properties.coins += amount
	emit_signal("coinsChanged", properties.coins)
	
func deductCoins(amount, lessThanZero = false):
	var temp = properties.coins
	
	if lessThanZero:
		properties.coins -= amount
	else:
		properties.coins = clamp(properties.coins-amount, 0, 999999999)
	if temp != properties.coins:
		emit_signal("coinsChanged", properties.coins)


func freeze(timeSeconds):
	print ("Frozen for: " + str(timeSeconds) + " seconds")
	canMove = false
	frozenTimer = timeSeconds

extends KinematicBody2D


enum weapon {
	basic,
	double,
	triple,
	cone
}


var motion = Vector2.ZERO
export var SPEED = 200
var projectileSpeed = 1000
var currentProjectile = "res://4. Scenes/Projectiles/LaserBullet.tscn"
var alive = true
var health = 50
	
func followMouse():
	look_at(get_global_mouse_position())

func handleEnemyInput():
	if $RayCast2D.is_colliding():
		fire()
		
func handlePlayerInput():
	if Input.is_action_pressed("Shoot"):
		fire()

func handlePlayerMovement():
	var x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var y = Input.get_action_strength("Back") - Input.get_action_strength("Forward")
	
	
	motion.x = x
	motion.y = y

	move_and_slide(motion * SPEED)



func fire():
	if $shotCooldown.is_stopped():
		var projectile = load(currentProjectile).instance()
		add_child(projectile)
		projectile.set_as_toplevel(true)
		projectile.global_transform = $Forward.global_transform
		var characterForward = global_transform[0].normalized()
		projectile.linear_velocity = characterForward * projectileSpeed
		$shotCooldown.start()
	
	
func is_alive():
	return alive
	
func damage(amount):
	if is_alive():
		health -= amount
		if health <= 0:
			alive = false

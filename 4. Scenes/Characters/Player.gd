extends CharacterBody2D
# The player ship.
#   Move: WASD / arrow keys, or hold the left mouse button to fly towards the cursor
#   Focus: hold Shift - slower, tighter shots, shows the hitbox
#   Bomb: X or right mouse - clears all enemy bullets on screen
# Shooting is automatic. Only the small glowing core (hitRadius) can be hit.

signal hullChanged(current, maximum)
signal bombsChanged(count)
signal died(unitType)
signal grazed(pos)

# -- tuning
const BASE_FIRE_INTERVAL = 0.16
const BASE_DAMAGE = 10.0
const INVULNERABLE_AFTER_HIT = 1.8
const INVULNERABLE_AFTER_BOMB = 2.5
const BOMB_DAMAGE = 90.0
const AUTO_BOMB = true  # a hit while holding a bomb fires the bomb instead of losing hull

var alive = true
var hitRadius = 7.0
var grazeRadius = 36.0
var magnetRadius = 170.0
var moveSpeed = 560.0
var focusSpeedMult = 0.45

var hull = 3
var maxHull = 3
var bombs = 2
var maxBombs = 5

var weaponType = WeaponData.Type.SPREAD
var weaponLevel = 1
var fireRateMult = 1.0
var damageMult = 1.0
var missileLevel = 0

var focused = false
var invulnerable = 0.0
var fireTimer = 0.0
var missileTimer = 0.0
var canControl = true

var field: BulletField

const MISSILE_INTERVAL = [0.0, 1.0, 0.75, 0.5]


func _ready():
	add_to_group("player")
	rotation = -PI / 2  # sprite art points right, ship flies up
	z_index = 6
	$Sprite2D.self_modulate = Color(0.85, 0.95, 1.0)
	invulnerable = 1.0
	_emitAll.call_deferred()

func _emitAll():
	emit_signal("hullChanged", hull, maxHull)
	emit_signal("bombsChanged", bombs)


func _physics_process(delta):
	if not alive:
		return
	focused = Input.is_action_pressed("Focus")
	_move(delta)
	if canControl:
		_shoot(delta)
		if Input.is_action_just_pressed("Bomb"):
			useBomb()

	invulnerable = max(invulnerable - delta, 0.0)
	# blink while invulnerable
	$Sprite2D.visible = invulnerable <= 0.0 or fmod(invulnerable, 0.16) > 0.07
	queue_redraw()


func _move(delta):
	var dir = Vector2(
		Input.get_axis("Left", "Right"),
		Input.get_axis("Forward", "Back"))
	var speed = moveSpeed * (focusSpeedMult if focused else 1.0)
	var step = dir.normalized() * speed * delta if dir.length() > 0.1 else Vector2.ZERO

	# mouse / touch: hold the button and the ship follows the cursor
	if dir.length() <= 0.1 and Input.is_action_pressed("Shoot"):
		var toMouse = get_global_mouse_position() - global_position
		step = toMouse.limit_length(speed * delta)

	if not canControl:
		step = Vector2.ZERO
	var screen = get_viewport_rect().grow(-30)
	global_position = (global_position + step).clamp(screen.position, screen.end)


func _shoot(delta):
	if field == null:
		# looked up lazily: the level creates the BulletField after the player's _ready()
		field = get_tree().get_first_node_in_group("bulletField")
		if field == null:
			return
	fireTimer -= delta
	if fireTimer <= 0.0:
		fireTimer = BASE_FIRE_INTERVAL / fireRateMult
		var muzzle = global_position + Vector2(0, -34)
		var speed = WeaponData.speed(weaponType)
		var kind = "lance" if weaponType == WeaponData.Type.LANCE else "spread"
		for s in WeaponData.shots(weaponType, weaponLevel, focused):
			var vel = Vector2.UP.rotated(deg_to_rad(s[0])) * speed
			field.spawnPlayerBullet(muzzle + Vector2(s[1], 0), vel, BASE_DAMAGE * damageMult * s[2], WeaponData.pierces(weaponType), kind)
		Sfx.play("shoot")

	if missileLevel > 0:
		missileTimer -= delta
		if missileTimer <= 0.0:
			missileTimer = MISSILE_INTERVAL[missileLevel]
			for side in [-1, 1]:
				var vel = Vector2.UP.rotated(deg_to_rad(35 * side)) * 750.0
				field.spawnPlayerBullet(global_position + Vector2(24 * side, 0), vel, 16.0 * damageMult, false, "missile")


func _draw():
	# show the hitbox while focusing (and faintly always), so dodging is readable
	var a = 1.0 if focused else 0.35
	draw_circle(Vector2.ZERO, hitRadius + 3.0, Color(1, 0.2, 0.3, a))
	draw_circle(Vector2.ZERO, hitRadius - 1.0, Color(1, 1, 1, a))


# ---------------------------------------------------------------- called by BulletField / Enemy

func is_vulnerable():
	return alive and invulnerable <= 0.0

func on_hit():
	if not is_vulnerable():
		return
	if AUTO_BOMB and bombs > 0:
		# holding a bomb when hit: it goes off automatically instead of costing hull
		Effects.floatText(self, global_position + Vector2(0, -60), "AUTO-BOMB!", Color(1, 0.7, 0.3), 36)
		useBomb()
		return
	hull -= 1
	emit_signal("hullChanged", hull, maxHull)
	Effects.shake(self, 20)
	Effects.explosion(self, global_position, 0.7)
	Sfx.play("playerHit", 0.0)
	if field:
		# small mercy clear so you don't get hit again the moment invulnerability ends
		field.clearEnemyBullets(global_position, 220.0, false)
	if hull <= 0:
		_die()
	else:
		invulnerable = INVULNERABLE_AFTER_HIT

func on_graze(pos):
	emit_signal("grazed", pos)
	Effects.spark(self, pos, Color(0.6, 0.9, 1.0), 2)
	Sfx.play("graze")

func collect(kind):
	match kind:
		"repair":
			hull = min(hull + 1, maxHull)
			emit_signal("hullChanged", hull, maxHull)
			Effects.floatText(self, global_position + Vector2(0, -50), "REPAIR", Color(0.4, 1, 0.4))
			Sfx.play("powerUp")
		"bomb":
			bombs = min(bombs + 1, maxBombs)
			emit_signal("bombsChanged", bombs)
			Effects.floatText(self, global_position + Vector2(0, -50), "+BOMB", Color(1, 0.7, 0.3))
			Sfx.play("powerUp")
		_:
			Sfx.play("pickup")
	get_tree().call_group("levelManager", "pickupCollected", kind)


func useBomb():
	if bombs <= 0 or not alive:
		return
	bombs -= 1
	emit_signal("bombsChanged", bombs)
	invulnerable = max(invulnerable, INVULNERABLE_AFTER_BOMB)
	if field:
		field.clearEnemyBullets()
	for e in get_tree().get_nodes_in_group("enemies"):
		if get_viewport_rect().has_point(e.global_position):
			e.take_damage(BOMB_DAMAGE)
	Effects.shake(self, 26)
	Sfx.play("bomb", 0.0)
	get_tree().call_group("GUI", "flashScreen", Color(1, 0.9, 0.7, 0.55))


func _die():
	alive = false
	invulnerable = 0.0
	$Sprite2D.visible = true
	if $AnimationPlayer.has_animation("die"):
		$AnimationPlayer.play("die")
	Effects.explosion(self, global_position, 1.6)
	Sfx.play("bigExplosion", 0.0)
	emit_signal("died", 0)


# Legacy hook: old physics bullets/asteroids call hurt(); any damage costs one pip now
func hurt(_amount):
	on_hit()

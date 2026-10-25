extends Node2D
class_name Enemy
# One enemy. Built from a type in EnemyTypes.gd plus a movement setup from the stage script.
#
# Movement modes (set with setup()):
#   "path"       fly with `vel`, optional sine wobble (sineAmp px, sineFreq Hz) sideways
#   "enterStop"  glide to `target`, hold for `hold` seconds, then leave with `exitVel`
#   "dive"       like enterStop, but after holding it rams towards where the player is
#   "boss"       glide to `target`, then sway side to side until killed

signal hpChanged(current, maximum)
signal died(enemy)

# Global difficulty knobs, raised on every loop by the StageDirector
static var hpMult = 1.0
static var bulletSpeedMult = 1.0
static var fireRateMult = 1.0

const NO_FIRE_BELOW_Y = 1150.0

var typeName = ""
var data = {}
var hp = 1.0
var maxHp = 1.0
var hitRadius = 30.0
var alive = true
var blocksBullets = false
var isBoss = false

var mode = "path"
var vel = Vector2(0, 200)
var target = Vector2.ZERO
var startPos = Vector2.ZERO
var enterTime = 1.2
var hold = 2.0
var exitVel = Vector2(0, 260)
var sineAmp = 0.0
var sineFreq = 0.5
var diveSpeed = 750.0

var t = 0.0
var pathT = 0.0
var hasEntered = false
var diving = false
var attackTimers = []
var burstsLeft = []
var spiralAngle = 0.0
var flash = 0.0
var invulnerable = 0.0

# boss
var phase = 0
var phaseTimers = {}

var sprite: Sprite2D
var field: BulletField
var player


func setup(type: String, pos: Vector2, movement = {}):
	typeName = type
	data = EnemyTypes.TYPES[type]
	position = pos
	startPos = pos
	maxHp = data.hp * hpMult
	hp = maxHp
	hitRadius = data.radius
	blocksBullets = data.get("blocksBullets", false)
	isBoss = data.get("boss", false)

	mode = movement.get("mode", "path")
	vel = movement.get("vel", vel)
	target = movement.get("target", pos + Vector2(0, 400))
	enterTime = movement.get("enterTime", enterTime)
	hold = movement.get("hold", hold)
	exitVel = movement.get("exitVel", exitVel)
	sineAmp = movement.get("sineAmp", 0.0)
	sineFreq = movement.get("sineFreq", 0.5)
	diveSpeed = movement.get("diveSpeed", diveSpeed)

	for a in data.attacks:
		attackTimers.append(a.get("delay", 1.0) + randf_range(0.0, 0.4))
		burstsLeft.append(0)
	return self


func _ready():
	add_to_group("enemies")
	z_index = 3
	sprite = Sprite2D.new()
	sprite.texture = load(data.tex)
	sprite.scale = Vector2.ONE * data.scale
	sprite.modulate = data.tint
	if data.faceDown:
		sprite.rotation = PI
	add_child(sprite)
	field = get_tree().get_first_node_in_group("bulletField")
	if isBoss:
		invulnerable = enterTime


func _physics_process(delta):
	if not alive:
		return
	t += delta
	player = get_tree().get_first_node_in_group("player")
	_move(delta)

	var screen = get_viewport_rect()
	if not hasEntered and screen.grow(-20).has_point(global_position):
		hasEntered = true
	if hasEntered and not screen.grow(140).has_point(global_position):
		queue_free()  # flew away: no score, no scrap
		return

	if hasEntered and player and player.alive:
		# fairness rule: no shooting from point-blank range deep in the player's half
		if global_position.y < NO_FIRE_BELOW_Y:
			if isBoss:
				_bossAttacks(delta)
			else:
				_updateAttacks(delta)
		_checkContact()

	if data.has("spin"):
		sprite.rotation += data.spin * delta
	flash = max(flash - delta * 6.0, 0.0)
	invulnerable = max(invulnerable - delta, 0.0)
	sprite.modulate = data.tint.lerp(Color(3, 3, 3), flash)


# ---------------------------------------------------------------- movement

func _move(delta):
	match mode:
		"path":
			pathT += delta
			var side = vel.orthogonal().normalized()
			position = startPos + vel * pathT + side * sin(pathT * TAU * sineFreq) * sineAmp
		"enterStop", "dive":
			if t < enterTime:
				position = startPos.lerp(target, ease(t / enterTime, 0.4))
			elif t < enterTime + hold:
				position = target + Vector2(sin(t * 2.0) * 12.0, 0)
			elif mode == "dive":
				if not diving:
					diving = true
					var aimAt = player.global_position if player else position + Vector2(0, 1)
					vel = (aimAt - position).normalized() * diveSpeed
				position += vel * delta
				sprite.rotation = vel.angle() + PI / 2  # sprites point up; turn nose towards the dive
			else:
				position += exitVel * delta
		"boss":
			if t < enterTime:
				position = startPos.lerp(target, ease(t / enterTime, 0.4))
			else:
				var bt = t - enterTime
				position = target + Vector2(sin(bt * 0.45) * 300.0, sin(bt * 0.8) * 40.0)


# ---------------------------------------------------------------- attacks

func _updateAttacks(delta):
	for i in range(data.attacks.size()):
		var a = data.attacks[i]
		attackTimers[i] -= delta * fireRateMult
		if attackTimers[i] <= 0.0:
			if burstsLeft[i] <= 0:
				burstsLeft[i] = a.get("burst", 1)
			_fireAttack(a)
			burstsLeft[i] -= 1
			attackTimers[i] = a.get("burstGap", 0.1) if burstsLeft[i] > 0 else a.every


func _fireAttack(a, origin = global_position):
	if field == null or player == null:
		return
	var speed = a.get("speed", 300.0) * bulletSpeedMult
	var opts = {"color": a.get("color", Patterns.RED), "radius": a.get("radius", 11.0)}
	var aimAt = player.global_position
	match a.pattern:
		"aimed":
			Patterns.aimed(field, origin, aimAt, speed, a.get("count", 1), a.get("spread", 0.0), opts)
		"fan":
			Patterns.fan(field, origin, a.get("angle", 90.0), a.get("count", 3), a.get("arc", 40.0), speed, opts)
		"ring":
			Patterns.ring(field, origin, a.get("count", 12), speed, randf() * 360.0, opts)
		"ringGap":
			Patterns.ringWithGap(field, origin, aimAt, a.get("count", 20), speed, a.get("gap", 50.0), opts)
		"spiral":
			spiralAngle += a.get("step", 12.0)
			Patterns.ring(field, origin, a.get("arms", 3), speed, spiralAngle, opts)
		"snapRing":
			Patterns.snapRing(field, origin, a.get("count", 16), speed, a.get("wait", 0.8), a.get("snapSpeed", 380.0) * bulletSpeedMult, randf() * 360.0, opts)
		"wall":
			var screen = get_viewport_rect()
			var gapX = clamp(aimAt.x + randf_range(-200, 200), 120.0, screen.size.x - 120.0)
			Patterns.wall(field, global_position.y + 40.0, screen.size.x, gapX, a.get("gap", 170.0), speed, a.get("spacing", 46.0), opts)
	Sfx.play("enemyShoot")


# The Mothership: three phases picked by remaining health. Each phase is a list of attacks
# using the same format as EnemyTypes, so it's easy to tune.
const MOTHERSHIP_PHASES = [
	[  # 1: aimed fans + slow rings - learn the boss
		{"pattern": "aimed", "every": 1.1, "delay": 0.5, "speed": 380, "count": 5, "spread": 48, "color": Color(1.0, 0.25, 0.3)},
		{"pattern": "ring", "every": 2.8, "delay": 1.5, "speed": 200, "count": 18, "color": Color(1.0, 0.6, 0.15)},
	],
	[  # 2: the maze - double spiral plus walls with a gap
		{"pattern": "spiral", "every": 0.11, "delay": 0.8, "speed": 210, "arms": 4, "step": 11, "color": Color(0.75, 0.45, 1.0)},
		{"pattern": "wall", "every": 3.4, "delay": 2.0, "speed": 190, "gap": 190, "color": Color(0.3, 0.9, 1.0), "radius": 10},
	],
	[  # 3: desperation - rings that stop and snap at you, plus a fast aimed stream
		{"pattern": "snapRing", "every": 2.3, "delay": 0.8, "speed": 300, "count": 20, "wait": 0.75, "snapSpeed": 360, "color": Color(1.0, 0.35, 0.8)},
		{"pattern": "aimed", "every": 0.45, "delay": 1.5, "speed": 470, "count": 1, "color": Color(1.0, 0.25, 0.3)},
		{"pattern": "ringGap", "every": 3.1, "delay": 2.5, "speed": 240, "count": 28, "gap": 60, "color": Color(1.0, 0.6, 0.15)},
	],
]

func _bossAttacks(delta):
	if typeName != "mothership":
		_updateAttacks(delta)
		return
	var wantPhase = 0 if hp > maxHp * 0.66 else (1 if hp > maxHp * 0.33 else 2)
	if wantPhase != phase or phaseTimers.is_empty():
		if wantPhase != phase:
			# phase change: wipe the screen and give the player a breather
			field.clearEnemyBullets()
			invulnerable = 1.5
			Effects.shake(self, 18)
			Sfx.play("bossWarning")
			get_tree().call_group("director", "onBossPhase", wantPhase + 1)
		phase = wantPhase
		phaseTimers = {}
		var attacks = MOTHERSHIP_PHASES[phase]
		for i in range(attacks.size()):
			phaseTimers[i] = attacks[i].delay
	if invulnerable > 0.0:
		return
	var attacks = MOTHERSHIP_PHASES[phase]
	for i in range(attacks.size()):
		phaseTimers[i] -= delta * fireRateMult
		if phaseTimers[i] <= 0.0:
			phaseTimers[i] = attacks[i].every
			_fireAttack(attacks[i])


func _checkContact():
	if not player.is_vulnerable():
		return
	if global_position.distance_to(player.global_position) < hitRadius * 0.75 + player.hitRadius:
		player.on_hit()
		if data.get("kamikaze", false):
			take_damage(9999)


# ---------------------------------------------------------------- damage & death

func take_damage(amount):
	if not alive or invulnerable > 0.0 or not hasEntered:
		return
	hp -= amount
	flash = 0.35 if isBoss else 0.8  # bosses get hit constantly; keep their colour readable
	emit_signal("hpChanged", max(hp, 0.0), maxHp)
	if hp <= 0.0:
		die()
	else:
		Sfx.play("hit")


func die():
	if not alive:
		return
	alive = false
	remove_from_group("enemies")

	Effects.explosion(self, global_position, 1.0 + data.radius / 60.0)
	Effects.shake(self, 22 if isBoss else 4)
	Sfx.play("bigExplosion" if isBoss else "explosion")

	if field:
		for i in range(data.scrap):
			field.spawnPickup(global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20)), "scrap")
		if data.has("drop") and randf() < data.get("dropChance", 1.0):
			field.spawnPickup(global_position, data.drop)
		if isBoss:
			field.clearEnemyBullets()
		if data.has("onDeath"):
			var d = data.onDeath
			Patterns.ring(field, global_position, d.count, d.speed * bulletSpeedMult, randf() * 360.0, {"color": d.color})
			for e in get_tree().get_nodes_in_group("enemies"):
				if e.global_position.distance_to(global_position) < d.blastRadius:
					e.take_damage(d.blastDamage)

	emit_signal("died", self)
	get_tree().call_group("levelManager", "enemyKilled", self)
	queue_free()
